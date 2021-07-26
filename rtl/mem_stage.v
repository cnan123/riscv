//================================================================
//   Copyright (C) 2021 Sangfor Ltd. All rights reserved.
//
//   Filename     : mem_stage.v
//   Auther       : cnan
//   Created On   : 2021年04月04日
//   Description  : 
//
//
//================================================================

module mem_stage(
    input                       clk,
    input                       reset_n,

    input logic                 rd_wr_en_mem,
    input logic [4:0]           rd_wr_addr_mem,
    input logic [31:0]          rd_wr_data_mem,

    input logic                 lsu_en_mem,  
    input lsu_op_e              lsu_op_mem,
    input lsu_dtype_e           lsu_dtype_mem,
    input logic [31:0]          lsu_addr_mem,
    input logic [31:0]          lsu_wdata_mem,
    
    input logic                 exc_taken_mem,
    input logic [5:0]           exc_cause_mem,
    input logic [31:0]          exc_tval_mem,

    //controller
    output                      ready_mem,
    input                       flush_M,
    input                       ready_wb,
    output logic                forward_mem_en,
    output logic [4:0]          forward_mem_addr,
    output logic [31:0]         forward_mem_wdata,

    //write back
    output logic                rd_wr_en_wb,
    output logic [4:0]          rd_wr_addr_wb,
    output logic [31:0]         rd_wr_data_wb,
    output logic                lsu_en_wb,
    output logic                wb_data_mux,
    output logic [31:0]         lsu_rdata,
    output logic                lsu_valid,
    output logic                lsu_err,
    output logic                exc_taken_wb,
    output logic [5:0]          exc_cause_wb,
    output logic [31:0]         exc_tval_wb,

    //LSU
    output logic                data_req,
    output logic                data_wr,
    input  logic                data_gnt,
    output logic [31:0]         data_addr,
    output logic [31:0]         data_wdata,
    output logic [3:0]          data_be,
    input  logic [31:0]         data_rdata,
    input  logic                data_valid,
    input                       data_error // PMP check fail or error reponse
);

// Local Variables:
// verilog-library-directories:(".")
// End:

//////////////////////////////////////////////
/*AUTOLOGIC*/
// Beginning of automatic wires (for undeclared instantiated-module outputs)
logic			lsu_ready;		// From lsu of lsu.v
// End of automatics
//////////////////////////////////////////////

//////////////////////////////////////////////
//main code

/*lsu AUTO_TEMPLATE(
    .lsu_en     (lsu_en_mem ),
    .lsu_op     (lsu_op_mem),
    .lsu_dtype  (lsu_dtype_mem ),
    .lsu_addr   (lsu_dtype_mem),
    .lsu_wdata  (lsu_wdata_mem),
);
*/

lsu lsu(
    /*AUTOINST*/
	// Interfaces
	.lsu_op				(lsu_op_mem),		 // Templated
	.lsu_dtype			(lsu_dtype_mem ),	 // Templated
	// Outputs
	.lsu_ready			(lsu_ready),
	.lsu_rdata			(lsu_rdata[31:0]),
	.lsu_valid			(lsu_valid),
	.lsu_err			(lsu_err),
	.data_req			(data_req),
	.data_wr			(data_wr),
	.data_addr			(data_addr[31:0]),
	.data_wdata			(data_wdata[31:0]),
	.data_be			(data_be[3:0]),
	// Inputs
	.clk				(clk),
	.reset_n			(reset_n),
	.lsu_en				(lsu_en_mem ),		 // Templated
	.lsu_addr			(lsu_dtype_mem),	 // Templated
	.lsu_wdata			(lsu_wdata_mem),	 // Templated
	.data_gnt			(data_gnt),
	.data_rdata			(data_rdata[31:0]),
	.data_valid			(data_valid),
	.data_error			(data_error));

assign lsu_en = lsu_en_mem & (~ready_wb) & (~flush_M);

assign ready_mem = ~( ~ready_wb | ~lsu_ready | exc_taken_mem );      
assign valid_mem = ~( ~ready_wb | ~lsu_ready );

assign forward_mem_en = (~lsu_en_mem) & rd_wr_en_mem;
assign forward_mem_addr = rd_wr_addr_mem;
assign forward_mem_wdata = rd_wr_data_mem;

//////////////////////////////////////////////
//write back
//////////////////////////////////////////////
always @(posedge clk or negedge reset_n)begin
    if( !reset_n )begin
        rd_wr_en_wb         <= 1'b0;
        rd_wr_addr_wb       <= 5'b0;
        rd_wr_data_wb       <= 32'h0;
        lsu_en_wb           <= 1'b0;
        wb_data_mux         <= 1'b0;

        exc_taken_wb        <= 1'b0;
        exc_cause_wb[5:0]   <= 6'h0;
        exc_tval_wb[31:0]   <= 32'h0;

    end else if( flush_M & valid_mem )begin
        rd_wr_en_wb         <= 1'b0;
        rd_wr_addr_wb       <= 5'b0;
        rd_wr_data_wb       <= 32'h0;
        lsu_en_wb           <= 1'b0;
        wb_data_mux         <= 1'b0;

        exc_taken_wb        <= 1'b0;
        exc_cause_wb[5:0]   <= 6'h0;
        exc_tval_wb[31:0]   <= 32'h0;
    end else if( valid_mem ) begin
        rd_wr_en_wb         <= rd_wr_en_mem;
        rd_wr_addr_wb       <= rd_wr_addr_mem;
        rd_wr_data_wb       <= rd_wr_data_mem;
        lsu_en_wb           <= lsu_en_mem;
        wb_data_mux         <= lsu_en_mem & (lsu_op_mem == LSU_OP_LD);

        exc_taken_wb        <= exc_taken_mem;
        exc_cause_wb[5:0]   <= exc_cause_mem[5:0];
        exc_tval_wb[31:0]   <= exc_tval_mem[31:0];
    end
end

endmodule
