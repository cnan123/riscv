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
logic [31:0]		insn_payload_if;	// From compress_decoder of compress_decoder.v
logic [31:0]		predict_pc_new;		// From branch_predict of branch_predict.v
logic			predict_taken_new;	// From branch_predict of branch_predict.v
// End of automatics
//////////////////////////////////////////////
logic [31:0]    next_pc;
logic           is_boot;

logic           ready_if;

logic           fetch_en;
logic           pc_unalign;

logic [15:0]    hold_rdata;
logic           hold_rdata_value;
logic           hold_rdata_err;

logic           hold_en;
logic           hold_data_is_compress;
logic           fifo_data_is_compress;

logic           insn_value;
logic           insn_err;
logic [31:0]    insn_payload;

logic           insn_value_if;
logic           insn_err_if;

logic           fifo_clear;
logic           fifo_ready;
logic           fifo_valid;
logic [32:0]    fifo_rdata;

logic           fifo_wvalid;
logic [32:0]    fifo_wdata;
logic           fifo_almost_full;

logic           cmd_fifo_push;
logic [1:0]     cmd_fifo_wdata;
logic           cmd_fifo_full;
logic           cmd_fifo_almost_full;
logic           cmd_fifo_pop;
logic [1:0]     cmd_fifo_rdata;
logic           cmd_fifo_rvalid;
logic           cmd_fifo_empty;

logic           pmp_err;

logic           cmd_updiscon;
logic           cmd_pmp_err;
logic           fifo_flush;
logic           updiscon_new;
logic           updiscon;
logic           updiscon_q;

logic [31:0]    set_instr_addr;
logic [31:0]    instr_prefetch_addr;
logic           instr_req_new;
logic           req_fail;

logic           predict_taken_if;
logic [31:0]    predict_pc_if;

logic           insn_compress_if;

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
        instr_payload_id        <= insn_payload_if;
        instr_value_id          <= insn_value_if;
        compress_instr_id       <= insn_compress_if;
        instr_fetch_error       <= insn_err_if;
        predict_taken_id        <= predict_taken_if;
        predict_pc_id           <= predict_pc_if;
    end
end

/////////////////////////////////////////////////
//fetch control
/////////////////////////////////////////////////
assign fetch_en     = is_boot & ( set_pc_valid | ready_if );
assign pc_unalign   = pc_if[1];


always @(posedge clk or negedge reset_n)begin
    if(!reset_n)begin
        hold_rdata          <= 16'h0;
        hold_rdata_value    <= 1'b0;
        hold_rdata_err      <= 1'b0;
    end else if( fifo_clear )begin
        hold_rdata          <= 16'h0;
        hold_rdata_value    <= 1'b0;
        hold_rdata_err      <= 1'b0;
    end else if( ~fetch_en )begin
        hold_rdata          <= hold_rdata;
        hold_rdata_value    <= hold_rdata_value;
        hold_rdata_err      <= hold_rdata_err;
    end else if(hold_en)begin
        hold_rdata          <= fifo_rdata[31:16];
        hold_rdata_value    <= 1'b1;
        hold_rdata_err      <= fifo_rdata[32];
    end else begin
        hold_rdata          <= hold_rdata;
        hold_rdata_value    <= 1'b0;
        hold_rdata_err      <= 1'b0;
    end
end

assign hold_en                  = fetch_en & ((pc_unalign & fifo_valid ) | fifo_data_is_compress) & ~hold_data_is_compress;

assign hold_data_is_compress    = (hold_rdata[1:0]!=2'b11) & hold_rdata_value ;
assign fifo_data_is_compress    = (fifo_rdata[1:0]!=2'b11) & fifo_valid & ~pc_unalign;

assign insn_value   = pc_unalign ? (hold_data_is_compress | (hold_rdata_value & fifo_valid) ) : fifo_valid;
assign insn_payload = pc_unalign ? { fifo_rdata[15:0], hold_rdata[15:0] } : fifo_rdata[31:0];
assign insn_err     = pc_unalign ? (hold_rdata_err | fifo_rdata[32]) : fifo_rdata[32];


/////////////////////////////////////////////////
//compress instruction decoder
/////////////////////////////////////////////////
/*compress_decoder AUTO_TEMPLATE(
    .instr_i (insn_payload[]),
    .instr_valid    (insn_value),
    .instr_o    (insn_payload_if[]),
);*/
compress_decoder compress_decoder(
    /*AUTOINST*/
				  // Outputs
				  .instr_o		(insn_payload_if[31:0]), // Templated
				  .illegal_instr_o	(illegal_instr_o),
				  // Inputs
				  .instr_valid		(insn_value),	 // Templated
				  .instr_i		(insn_payload[31:0])); // Templated

assign insn_value_if    = insn_value;
assign insn_err_if      = insn_err;
assign insn_compress_if = hold_data_is_compress | fifo_data_is_compress;

/////////////////////////////////////////////////
//prefetch fifo
/////////////////////////////////////////////////

// Local Variables:                                                                 
// verilog-auto-inst-param-value:t                                                  
// End:
//
prefetch_fifo #(
    .DATA_WIDTH         (33 ),
    .DEPTH              (4  )
) prefetch_fifo (
    .clk                    (clk                    ),
    .reset_n                (reset_n                ),
    
    .fifo_clear             (fifo_clear             ),
    .fifo_ready             (fifo_ready             ),
    .fifo_valid             (fifo_valid             ),
    .fifo_rdata             (fifo_rdata             ),
   
    .fifo_wvalid            (fifo_wvalid            ),
    .fifo_wdata             (fifo_wdata             ),
    .fifo_almost_full       (fifo_almost_full       )
);

assign fifo_clear   = updiscon_new;
assign fifo_ready   = fetch_en & (~hold_data_is_compress);

assign fifo_wvalid  = fifo_flush ? (instr_valid & cmd_updiscon) : instr_valid;
assign fifo_wdata   = { (instr_err | cmd_pmp_err), instr_rdata[31:0] };


/////////////////////////////////////////////////

sync_fifo #(
    .DEPTH      (2),
    .DATA_WIDTH (2)
) cmd_fifo(
    .clk                    (clk                    ),
    .reset_n                (reset_n                ),
    
    .fifo_clear             (1'b0                   ),
    
    .wr_en                  (cmd_fifo_push          ),
    .wr_data                (cmd_fifo_wdata[1:0]    ),
    .fifo_full              (cmd_fifo_full          ),
    .fifo_almost_full       (cmd_fifo_almost_full   ),

    .rd_en                  (cmd_fifo_pop           ),
    .rd_data                (cmd_fifo_rdata[1:0]    ),
    .rd_data_valid          (cmd_fifo_rvalid        ),
    .fifo_empty             (cmd_fifo_empty         )
);

assign pmp_err          = 1'b0; //TODO

assign cmd_fifo_push    = instr_req & instr_gnt;
assign cmd_fifo_wdata   = { pmp_err, updiscon };

assign cmd_fifo_pop     = instr_valid;

assign cmd_updiscon     = cmd_fifo_rdata[0];
assign cmd_pmp_err      = cmd_fifo_rdata[1];

always @(posedge clk or negedge reset_n)begin
    if(!reset_n)begin
        fifo_flush <= 1'b0;
    end else if( instr_valid & cmd_updiscon )begin
        fifo_flush <= updiscon;
    end else if(updiscon)begin
        fifo_flush <= 1'b1;
    end
end

assign updiscon_new = predict_taken_if | set_pc_valid;
assign updiscon     = updiscon_new | updiscon_q;

always @(posedge clk or negedge reset_n)begin
    if(!reset_n)begin
        updiscon_q <= 1'b0;
    end else if( updiscon_q & instr_gnt )begin
        updiscon_q <= 1'b0;
    end else if( updiscon_new & ~instr_gnt )begin
        updiscon_q <= 1'b1;
    end
end

/////////////////////////////////////////////////
//fetch from program memroy
/////////////////////////////////////////////////

assign set_instr_addr   = ( set_pc_valid ? set_pc : predict_pc_if );

assign instr_req_new    = is_boot & fetch_enable & ~cmd_fifo_full & ( (~fifo_almost_full) | fifo_clear );

assign instr_req        = (instr_req_new | req_fail);
assign instr_addr       = fifo_clear ? {set_instr_addr[31:2],2'h0} : instr_prefetch_addr;

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

always @(posedge clk or negedge reset_n)begin
    if(!reset_n)begin
        req_fail <= 1'b0;
    end else begin
        req_fail <= instr_req & ~instr_gnt;
    end
end


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
    assign predict_taken_if = 1'b0;
    assign predict_pc_if = 32'h0;
end
endgenerate

endmodule
