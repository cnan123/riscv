//================================================================
//   Copyright (C) 2021. All rights reserved.
//
//   Filename     : if_stage.sv
//   Auther       : cnan
//   Created On   : 2021.02.28
//   Description  : 
//
//
//================================================================

module if_stage#(
    parameter BRANCH_PREDICTION = 1'b0,
    parameter ENA_BHT = 1,
    parameter ENA_BTB = 1,
    parameter ENA_RAS = 0,
    parameter ENA_JUMP = 0
)(
    input                   clk,
    input                   reset_n,
    
    input [31:0]            boot_addr,
    input                   fetch_enable,

    //from controller
    input                   flush_F,
    input                   stall_F,
    input                   ready_id,
    input                   set_pc_valid,
    input [31:0]            set_pc,
    
    //decoder
    output logic [31:0]     pc_if,
    output logic [31:0]     pc_id,
    output logic [31:0]     instr_payload_id,
    output logic            instr_value_id,
    output logic            compress_instr_id,
    output logic            predict_taken_id,
    output logic [31:0]     predict_pc_id,
    output logic            instr_fetch_error,

    //branch prediction
    input                   predict_fail,
    input                   btb_invalid,
    input                   btb_update,
    input [31:0]            btb_pc,
    input [31:0]            btb_target,
    input                   bht_updata,
    input [31:0]            bht_pc,
    input                   bht_taken,
    
    //instruction interface
    output logic            instr_req,
    output logic [31:0]     instr_addr,
    input                   instr_gnt,
    input [31:0]            instr_rdata,
    input                   instr_err,
    input                   instr_valid
);

localparam IDLE      = 2'd0;
localparam WAIT_GNT  = 2'd1;
localparam WAIT_DATA = 2'd2;
localparam FLUSH     = 2'd3;

// Local Variables:
// verilog-library-directories:(".")
// End:

//////////////////////////////////////////////
/*AUTOLOGIC*/
// Beginning of automatic wires (for undeclared instantiated-module outputs)
logic			illegal_instr_o;	// From compress_decoder of compress_decoder.v
logic [31:0]		insn_new;		// From compress_decoder of compress_decoder.v
logic [31:0]		predict_pc_new;		// From branch_predict of branch_predict.v
logic			predict_taken_new;	// From branch_predict of branch_predict.v
// End of automatics
//////////////////////////////////////////////
logic [31:0]    next_pc;
logic           is_boot;

logic           ready_if;
logic           pipe_busy;
logic           pipe_ready;

logic [31:0]    insn_if;
logic           insn_value_if;
logic           insn_compress_if;
logic           insn_err_if;
logic           predict_taken_if;
logic [31:0]    predict_pc_if;

logic [31:0]    insn_q;
logic           insn_value_q;
logic           insn_compress_q;
logic           insn_err_q;
logic           predict_taken_q;
logic [31:0]    predict_pc_q;

logic           fetch_en;
logic           pc_unalign;
logic           read_from_fifo;
logic           read_from_hold;
logic           rdata_value;
logic           rdata_err;
logic [32:0]    rdata;
logic           fifo_pop;
logic           bypass;

logic [31:0]    instruction;
logic           instruction_value;
logic           instruction_err;

logic [15:0]    hold_rdata;
logic           hold_rdata_value;
logic           hold_rdata_err;
logic           hold_data_is_compress;

logic           insn_compress_new;
logic           insn_value_new;
logic           insn_err_new;

logic [31:0]    set_instr_addr;
logic [31:0]    instr_prefetch_addr;
logic [31:0]    next_instr_addr;
logic [1:0]     fsm_fetch_cs;
logic [1:0]     fsm_fetch_ns;

logic           fifo_push;
logic [32:0]    fifo_push_data;

logic           fifo_full;
logic           fifo_almost_full;
logic [32:0]    fifo_rdata;
logic           fifo_rdata_valid;
logic           fifo_empty;
logic           fifo_clear;

//////////////////////////////////////////////
//main code

//gen pc
always @(*)begin
    if(set_pc_valid)begin
        next_pc = set_pc;
    end else if(predict_taken_if)begin
        next_pc = predict_pc_if;        
    end else if( insn_value_if & insn_compress_if )begin
        next_pc = pc_if + 2;
    end else if(insn_value_if )begin
        next_pc = pc_if + 4;
    end else begin
        next_pc = pc_if;
    end
end

always @(posedge clk or negedge reset_n)begin
    if(!reset_n)begin
        is_boot <= 1'b0;
    end else begin
        is_boot <= 1'b1;
    end
end

always @(posedge clk or negedge reset_n)begin
    if(!reset_n)begin
        pc_if <= boot_addr;
    end else if( ready_if | set_pc_valid )begin
        pc_if <= next_pc;
    end
end

always @(posedge clk or negedge reset_n)begin
    if(!reset_n)begin
        pc_id <= 32'h0;
    end else if( ready_id )begin
        pc_id <= pc_if;
    end
end


//////////////////////////////////////////////////////////////////////
//pipeline
assign ready_if = ready_id & (~stall_F);

always @(posedge clk or negedge reset_n)begin
    if( !reset_n )begin
        instr_payload_id        <= 32'h0;
        instr_value_id          <= 1'b0;
        compress_instr_id       <= 1'b0;
        instr_fetch_error       <= 1'b0;
        predict_taken_id        <= 1'b0;
        predict_pc_id           <= 32'b0;
    end else if( flush_F )begin
        instr_payload_id        <= 32'h0;
        instr_value_id          <= 1'b0;
        compress_instr_id       <= 1'b0;
        instr_fetch_error       <= 1'b0;
        predict_taken_id        <= 1'b0;
        predict_pc_id           <= 32'b0;
    end else if(ready_if) begin
        instr_payload_id        <= insn_if;
        instr_value_id          <= insn_value_if;
        compress_instr_id       <= insn_compress_if;
        instr_fetch_error       <= insn_err_if;
        predict_taken_id        <= predict_taken_if;
        predict_pc_id           <= predict_pc_if;
    end
end


//////////////////////////////////////////////////////////////////////
always @(posedge clk or negedge reset_n)begin
    if(~reset_n)begin
        pipe_busy <= 1'b0;
    end else begin
        pipe_busy <= ~ready_if;
    end
end 

assign insn_if          = pipe_busy ? insn_q : insn_new;
assign insn_value_if    = pipe_busy ? insn_value_q : insn_value_new;
assign insn_compress_if = pipe_busy ? insn_compress_q : insn_compress_new;
assign insn_err_if      = pipe_busy ? insn_err_q : insn_err_new;
assign predict_taken_if = pipe_busy ? predict_taken_q : predict_taken_new;
assign predict_pc_if    = pipe_busy ? predict_pc_q : predict_pc_new;


assign pipe_ready = ~pipe_busy;

always @(posedge clk or negedge reset_n)begin
    if(!reset_n)begin
        insn_q          <= 32'h0;
        insn_value_q    <= 1'b0;
        insn_compress_q <= 1'b0;
        insn_err_q      <= 1'b0;
        predict_taken_q <= 1'b0;
        predict_pc_q    <= 32'h0;
    end else if(set_pc_valid)begin
        insn_q          <= 32'h0;
        insn_value_q    <= 1'b0;
        insn_compress_q <= 1'b0;
        insn_err_q      <= 1'b0;
        predict_taken_q <= 1'b0;
        predict_pc_q    <= 32'h0;
    end else if(~pipe_busy)begin
        insn_q          <= insn_new;
        insn_value_q    <= insn_value_new;
        insn_compress_q <= insn_compress_new;
        insn_err_q      <= insn_err_new;
        predict_taken_q <= predict_taken_new;
        predict_pc_q    <= predict_pc_new;
    end
end


/////////////////////////////////////////////////
//fetch control
/////////////////////////////////////////////////
assign fetch_en = is_boot & ( set_pc_valid | pipe_ready );

assign pc_unalign   = pc_if[1];

assign read_from_fifo   =  (~fifo_empty) & fetch_en;
assign read_from_hold    = hold_data_is_compress & fetch_en & hold_rdata_value;

assign rdata[32:0]  = ( read_from_fifo | read_from_hold ) ? fifo_rdata[32:0] : {instr_err,instr_rdata};
assign rdata_value  = ( read_from_fifo | read_from_hold ) ? 1'b1 : ( instr_valid & (fsm_fetch_cs != FLUSH) );
assign rdata_err    = rdata[32];

assign hold_data_is_compress    = (hold_rdata[1:0]!=2'b11) & hold_rdata_value & pc_unalign;
assign fifo_pop                 = read_from_fifo & (~read_from_hold);
assign fifo_clear               = set_pc_valid | predict_taken_new;

assign bypass                   = ~( read_from_fifo | read_from_hold | (insn_compress_new & pc_unalign) | (~fetch_en) );

always_comb begin
    instruction         = 32'h0;
    instruction_value   = 1'b0;
    instruction_err     = 1'b0;

    if(fetch_en)begin
        if( pc_unalign )begin
            instruction[15:0]   = hold_rdata[15:0];
            if(hold_data_is_compress & hold_rdata_value)begin
                instruction[31:16]  = 16'h0;
                instruction_value   = 1'b1;
                instruction_err     = hold_rdata_err;
            end else begin
                instruction[31:16]  = rdata[15:0];
                instruction_value   = rdata_value & hold_rdata_value;
                instruction_err     = rdata_err | hold_rdata_err;
            end
        end else begin
            instruction[15:0]   = rdata[15:0];
            instruction_value   = rdata_value;
            instruction_err     = rdata_err;
            if(insn_compress_new)begin
                instruction[31:16] = 16'h0;
            end else begin
                instruction[31:16]  = rdata[31:16];
            end
        end
    end else begin
        instruction_value = 1'b0;
    end
end


always @(posedge clk or negedge reset_n)begin
    if(!reset_n)begin
        hold_rdata          <= 16'h0;
        hold_rdata_value    <= 1'b0;
        hold_rdata_err      <= 1'b0;
    end else if( flush_F | predict_taken_if )begin
        hold_rdata          <= 16'h0;
        hold_rdata_value    <= 1'b0;
        hold_rdata_err      <= 1'b0;
    end else if( ~fetch_en )begin
        hold_rdata          <= hold_rdata;
        hold_rdata_value    <= hold_rdata_value;
        hold_rdata_err      <= hold_rdata_err;
    end else if(fetch_en & ( (pc_unalign & rdata_value) | insn_compress_new ))begin
        hold_rdata          <= rdata[31:16];
        hold_rdata_value    <= 1'b1;
        hold_rdata_err      <= rdata[32];
    end else begin
        hold_rdata          <= hold_rdata;
        hold_rdata_value    <= 1'b0;
        hold_rdata_err      <= 1'b0;
    end
end


/////////////////////////////////////////////////
//compress instruction decoder
/////////////////////////////////////////////////
assign insn_compress_new = ( instruction[1:0] != 2'b11 ) & instruction_value;


/*compress_decoder AUTO_TEMPLATE(
    .instr_i (instruction[]),
    .instr_valid    (instruction_value),
    .instr_o    (insn_new[]),
);*/
compress_decoder compress_decoder(
    /*AUTOINST*/
				  // Outputs
				  .instr_o		(insn_new[31:0]), // Templated
				  .illegal_instr_o	(illegal_instr_o),
				  // Inputs
				  .instr_valid		(instruction_value), // Templated
				  .instr_i		(instruction[31:0])); // Templated

assign insn_value_new   = instruction_value;
assign insn_err_new     = instruction_err;

/////////////////////////////////////////////////
//prefetch fifo
/////////////////////////////////////////////////

// Local Variables:                                                                 
// verilog-auto-inst-param-value:t                                                  
// End:
//

sync_fifo #(
    .DEPTH(4),
    .DATA_WIDTH(33)
) perfetch_fifo(
		.clk			(clk                    ),
		.reset_n		(reset_n                  ),

		.fifo_clear		(fifo_clear             ),

		.wr_en			(fifo_push              ),
		.wr_data		(fifo_push_data[32:0]   ),
		.fifo_full		(fifo_full              ),
        .fifo_almost_full(fifo_almost_full      ),

		.rd_en			(fifo_pop               ),
		.rd_data		(fifo_rdata[32:0]       ),
		.rd_data_valid	(fifo_rdata_valid       ),
		.fifo_empty		(fifo_empty             )
);

/////////////////////////////////////////////////
//fetch from program memroy
/////////////////////////////////////////////////

assign set_instr_addr   = ( set_pc_valid ? set_pc : predict_pc_new );

always @(posedge clk or negedge reset_n)begin
    if(!reset_n)begin
        instr_prefetch_addr <= boot_addr;
    end else if(is_boot)begin
        if(fifo_clear)begin
            if(instr_gnt)begin
                instr_prefetch_addr <= instr_addr + 32'h4;
            end else begin
                instr_prefetch_addr <= instr_addr;
            end
        end else if( instr_req & instr_gnt )begin
            instr_prefetch_addr <= instr_prefetch_addr + 32'h4;
        end
    end
end

//instr addr mux
always @(*)begin
    instr_addr = 32'h0;
    case(fsm_fetch_cs)
        IDLE:begin
            if(fifo_clear) begin
                instr_addr = {set_instr_addr[31:2],2'h0};
            end else begin
                instr_addr = instr_prefetch_addr;
            end
        end
        WAIT_GNT:begin
            if(fifo_clear) begin
                instr_addr = {set_instr_addr[31:2],2'h0};
            end else begin
                instr_addr = instr_prefetch_addr;
            end
        end
        WAIT_DATA:begin
            if(fifo_clear & instr_valid)begin
                instr_addr = {set_instr_addr[31:2],2'h0};
            end else begin
                instr_addr = instr_prefetch_addr;
            end
        end
        FLUSH:begin
            instr_addr = instr_prefetch_addr;
        end
        default:;
    endcase
end

assign instr_req = (
    ( (fsm_fetch_cs[1:0]==IDLE) & is_boot & fetch_enable & ( (~fifo_almost_full) | fifo_clear ) ) |
    ( (fsm_fetch_cs[1:0]==WAIT_GNT) ) |
    ( (fsm_fetch_cs[1:0]==WAIT_DATA) & instr_valid & ( (~fifo_almost_full) | fifo_clear ) ) |
    ( (fsm_fetch_cs[1:0]==FLUSH) & instr_valid )
);

always @(posedge clk or negedge reset_n)begin
    if(!reset_n)begin
        fsm_fetch_cs <= IDLE;
    end else begin
        fsm_fetch_cs <= fsm_fetch_ns;
    end
end

always @(*)begin
    fsm_fetch_ns = fsm_fetch_cs;
    case(fsm_fetch_cs)
        IDLE:begin
            if( instr_req & instr_gnt )begin
                fsm_fetch_ns = WAIT_DATA;
            end else if( instr_req )begin
                fsm_fetch_ns = WAIT_GNT;
            end
        end
        WAIT_GNT:begin
            if(instr_gnt)begin
                fsm_fetch_ns = WAIT_DATA;
            end
        end
        WAIT_DATA:begin
            if( instr_valid )begin
                if( instr_req & instr_gnt )begin
                    fsm_fetch_ns = WAIT_DATA;
                end else if(instr_req) begin
                    fsm_fetch_ns = WAIT_GNT;
                end else begin
                    fsm_fetch_ns = IDLE;
                end
            end else begin
                if( fifo_clear )begin
                    fsm_fetch_ns = FLUSH;
                end
            end
        end
        FLUSH:begin
            if(instr_valid)begin
                if(instr_gnt)begin
                    fsm_fetch_ns = WAIT_DATA;
                end else begin
                    fsm_fetch_ns = WAIT_GNT;
                end
            end
        end
        default: fsm_fetch_ns = IDLE;
    endcase
end

assign fifo_push        = ( ~bypass ) & instr_valid & (fsm_fetch_cs==WAIT_DATA) ;
assign fifo_push_data   = {instr_err, instr_rdata};


/////////////////////////////////////////////////
//fetch from program memroy
/////////////////////////////////////////////////
generate
if(BRANCH_PREDICTION == 1)begin: gen_branch_prediction
/*
branch_predict AUTO_TEMPLATE(
	.predict_en		(fetch_en),
    .fetch_pc_n (next_pc[]),
    .fetch_pc   (pc_if[]),
    .fetch_rdata    (instruction[]),
    .fetch_valid    (instruction_value),
    .predict_taken	(predict_taken_new),
    .predict_pc		(predict_pc_new[]),
);
*/
branch_predict #(
/*AUTOINSTPARAM*/
		 // Parameters
		 .ENA_BHT		(ENA_BHT),
		 .ENA_BTB		(ENA_BTB),
		 .ENA_JUMP		(ENA_JUMP),
		 .ENA_RAS		(ENA_RAS)) branch_predict(
/*AUTOINST*/
								  // Outputs
								  .predict_taken	(predict_taken_new), // Templated
								  .predict_pc		(predict_pc_new[31:0]), // Templated
								  // Inputs
								  .clk			(clk),
								  .reset_n		(reset_n),
								  .predict_en		(fetch_en),	 // Templated
								  .fetch_pc_n		(next_pc[31:0]), // Templated
								  .fetch_pc		(pc_if[31:0]),	 // Templated
								  .fetch_rdata		(instruction[31:0]), // Templated
								  .fetch_valid		(instruction_value), // Templated
								  .predict_fail		(predict_fail),
								  .bht_updata		(bht_updata),
								  .bht_pc		(bht_pc[31:0]),
								  .bht_taken		(bht_taken),
								  .btb_invalid		(btb_invalid),
								  .btb_update		(btb_update),
								  .btb_pc		(btb_pc[31:0]),
								  .btb_target		(btb_target[31:0]));


end else begin: gen_no_branch_prediction
    assign predict_taken_new = 1'b0;
    assign predict_pc_new = 32'h0;
end
endgenerate

endmodule
