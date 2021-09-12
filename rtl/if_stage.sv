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
    parameter BRANCH_PREDICTION = 1'b0
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
    output logic            instr_fetch_error,
    output logic            is_compress_intr,
    
    //instruction interface
    output logic            instr_req,
    output logic [31:0]     instr_addr,
    input                   instr_gnt,
    input [31:0]            instr_rdata,
    input                   instr_err,
    input                   instr_valid
);


// Local Variables:
// verilog-library-directories:(".")
// End:

//////////////////////////////////////////////
/*AUTOLOGIC*/
// Beginning of automatic wires (for undeclared instantiated-module outputs)
logic			illegal_instr_o;	// From compress_decoder of compress_decoder.v
logic [31:0]		instruction_if;		// From compress_decoder of compress_decoder.v
// End of automatics
//////////////////////////////////////////////
logic [31:0]    instruction;
logic           instruction_value;

logic [31:0]    next_pc;
logic           is_boot;
logic           pc_unalign;
logic           rdata_value;
logic           rdata_err;
logic [32:0]    rdata;
logic [31:0]    instruction_temp;
logic [15:0]    hold_rdata;
logic           hold_rdata_value;
logic           hold_rdata_err;
logic           fetch_from_mem;
logic           fetch_en;
logic           fifo_pop;
logic           fifo_clear;
logic           hold_data_is_compress;
logic           read_from_fifo;

logic [31:0]    next_instr_addr;
logic [1:0]     fsm_fetch_cs;
logic [1:0]     fsm_fetch_ns;
logic [31:0]    set_instr_addr;
logic [31:0]    instr_prefetch_addr;

logic           fifo_push;
logic [32:0]    fifo_push_data;

logic           branch_prediction_taken;
logic [31:0]    branch_prediction_pc;

logic           fifo_full;
logic           fifo_almost_full;
logic [32:0]    fifo_rdata;
logic           fifo_rdata_valid;
logic           fifo_empty;

logic           ready_if;

parameter IDLE      = 2'd0;
parameter WAIT_GNT  = 2'd1;
parameter WAIT_DATA = 2'd2;
parameter FLUSH     = 2'd3;

//////////////////////////////////////////////
//main code

//gen pc
always @(*)begin
    if(set_pc_valid)begin
        next_pc = set_pc;
    end else if(branch_prediction_taken)begin
        next_pc = branch_prediction_pc;
    end else if( instruction_value & is_compress_intr )begin
        next_pc = pc_if + 2;
    end else if(instruction_value )begin
        next_pc = pc_if + 4;
    end else begin
        next_pc = pc_if;
    end
end

always @(posedge clk or negedge reset_n)begin
    if(!reset_n)begin
        is_boot <= 1'b0;
    end else if( ready_if | set_pc ) begin
        is_boot <= 1'b1;
    end
end

always @(posedge clk or negedge reset_n)begin
    if(!reset_n)begin
        pc_if <= boot_addr;
    end else if( ready_if | set_pc )begin
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

assign pc_unalign = pc_if[1];


assign rdata_value  = fifo_pop ? 1'b1 : instr_valid;
assign rdata_err    = rdata[32];
assign rdata[32:0]  = fifo_pop ? fifo_rdata[32:0] : {instr_err,instr_rdata};

assign instruction_temp = pc_unalign ? {rdata[15:0],hold_rdata[15:0]} : rdata;
assign instruction[31:16] = is_compress_intr ? 16'h0 : instruction_temp[31:16];
assign instruction[15:0] = instruction_temp[15:0];

assign instruction_value = pc_unalign ? hold_data_is_compress | (rdata_value && hold_rdata_value) : rdata_value & fetch_en;
assign instruction_err = pc_unalign ? ( (hold_rdata_value & hold_rdata_err) | (rdata_value & rdata_err) ) : (rdata_value & rdata_err); 


//////////////////////////////////////////////////////////////////////
//pipeline
assign ready_if = ready_id & (~stall_F);

always @(posedge clk or negedge reset_n)begin
    if( !reset_n )begin
        instr_payload_id    <= 32'h0;
        instr_value_id      <= 1'b0;
        instr_fetch_error   <= 1'b0;
    end else if( flush_F )begin
        instr_payload_id    <= 32'h0;
        instr_value_id      <= 1'b0;
        instr_fetch_error   <= 1'b0;
    end else if(ready_if) begin
        instr_payload_id    <= instruction_if;
        instr_value_id      <= instruction_value;
        instr_fetch_error   <= instruction_err;
    end
end

always @(posedge clk or negedge reset_n)begin
    if(!reset_n)begin
        hold_rdata <= 16'h0;
        hold_rdata_value <= 1'b0;
        hold_rdata_err <= 1'b0;
    end else if( fifo_clear )begin
        hold_rdata <= 16'h0;
        hold_rdata_value <= 1'b0;
        hold_rdata_err <= 1'b0;
    end else if( ~ready_if )begin
        hold_rdata <= hold_rdata;
        hold_rdata_value <= hold_rdata_value;
        hold_rdata_err <= hold_rdata_err;
    end else if(fetch_en & ( (pc_unalign & rdata_value) | is_compress_intr ))begin
        hold_rdata <= rdata[31:16];
        hold_rdata_value <= 1'b1;
        hold_rdata_err <= rdata[32];
    end else begin
        hold_rdata <= hold_rdata;
        hold_rdata_value <= 1'b0;
        hold_rdata_err <= 1'b0;
    end
end

assign fetch_en = is_boot && (set_pc_valid | branch_prediction_taken | ready_if);

assign hold_data_is_compress = (hold_rdata[1:0]!=2'b11) & hold_rdata_value & pc_unalign;
assign fifo_pop = fetch_en && (~fifo_empty) && (~hold_data_is_compress);
assign fifo_clear = set_pc_valid | branch_prediction_taken;

assign read_from_fifo = fifo_pop | hold_data_is_compress | (is_compress_intr & pc_unalign);

/////////////////////////////////////////////////
//fetch control
/////////////////////////////////////////////////

/////////////////////////////////////////////////
//compress instruction decoder
/////////////////////////////////////////////////
assign is_compress_intr = ( instruction[1:0] != 2'b11 ) & instruction_value;

/*compress_decoder AUTO_TEMPLATE(
    .instr_i (instruction[]),
    .instr_valid    (instruction_value),
    .instr_o    (instruction_if[]),
);*/
compress_decoder compress_decoder(
    /*AUTOINST*/
				  // Outputs
				  .instr_o		(instruction_if[31:0]), // Templated
				  .illegal_instr_o	(illegal_instr_o),
				  // Inputs
				  .instr_valid		(instruction_value), // Templated
				  .instr_i		(instruction[31:0])); // Templated


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

assign set_instr_addr = (
        ( {32{set_pc_valid              }} & set_pc ) |
        ( {32{branch_prediction_taken   }} & branch_prediction_pc )
);

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

assign fifo_push = ( read_from_fifo | (!fetch_en) ) & instr_valid & (fsm_fetch_cs==WAIT_DATA) ;
assign fifo_push_data = {instr_err, instr_rdata};


/////////////////////////////////////////////////
//fetch from program memroy
/////////////////////////////////////////////////
generate
if(BRANCH_PREDICTION == 1)begin: gen_branch_prediction
    //TODO
    assign branch_prediction_taken = 1'b0;
    assign branch_prediction_pc = 32'h0;
end else begin: gen_no_branch_prediction
    assign branch_prediction_taken = 1'b0;
    assign branch_prediction_pc = 32'h0;
end
endgenerate

endmodule
