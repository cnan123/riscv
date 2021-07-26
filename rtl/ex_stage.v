//================================================================
//   Copyright (C) 2021 Sangfor Ltd. All rights reserved.
//
//   Filename     : ex_stage.v
//   Auther       : cnan
//   Created On   : 2021年04月04日
//   Description  : 
//
//
//================================================================
import riscv_pkg::*;

module ex_stage(
    input                       clk,
    input                       reset_n,

    //pipeline controller
    input                       stall_E, //
    input                       ready_mem,
    output logic                ready_ex,

    input [31:0]                pc_id,
    output logic [31:0]         pc_ex,

    //branch jump
    input                       jump_ex,
    output logic [31:0]         jump_target_addr,
    output logic                jump_taken,
    input                       branch_ex,
    output logic [31:0]         branch_target_addr,
    output logic                branch_taken,

    //alu
    input logic                 alu_en_ex,
    input alu_op_e              alu_op_ex,

    input logic [31:0]          src_a_ex,         
    input logic [31:0]          src_b_ex,         
    input logic [31:0]          src_c_ex,         
    
    input logic                 lsu_en_ex,  
    input lsu_op_e              lsu_op_ex,
    input lsu_dtype_e           lsu_dtype_ex,

    input logic                 csr_en_ex,
    input logic [1:0]           csr_op_ex,
    input logic [11:0]          csr_addr_ex,
    input logic [31:0]          csr_wdata_ex,

    input logic                 rd_wr_en_ex,
    input logic [4:0]           rd_wr_addr_ex,

    input logic                 exc_taken_ex,
    input logic [5:0]           exc_cause_ex,
    input logic [31:0]          exc_tval_ex,

    //next stage
    output logic                lsu_en_mem,  
    output lsu_op_e             lsu_op_mem,
    output lsu_dtype_e          lsu_dtype_mem,
    output logic [31:0]         lsu_addr_mem,
    output logic [31:0]         lsu_wdata_mem,
    
    output logic                exc_taken_mem,
    output logic [5:0]          exc_cause_mem,
    output logic [31:0]         exc_tval_mem,

    output logic                rd_wr_en_mem,
    output logic [4:0]          rd_wr_addr_mem,
    output logic [31:0]         rd_wr_data_mem,

    output logic                forward_ex_en,
    output logic [4:0]          forward_ex_addr,
    output logic [31:0]         forward_ex_wdata
);

// Local Variables:
// verilog-library-directories:(".")
// End:

//////////////////////////////////////////////
/*AUTOLOGIC*/
// Beginning of automatic wires (for undeclared instantiated-module outputs)
logic [31:0]		adder_result;		// From u_alu of alu.v
logic			alu_result_valid;	// From u_alu of alu.v
logic			branch_compare_result;	// From u_alu of alu.v
logic [31:0]		logic_result;		// From u_alu of alu.v
// End of automatics
//////////////////////////////////////////////
logic [31:0]    alu_result;
logic [31:0]    shift_result;
logic           branch;
logic           alu;
logic           equal_result;
logic           less_than_result;

logic [31:0]    rd_wr_data_ex;
logic [31:0]    return_addr;
logic           ex_stage_valid;
logic           multicycle_instr;
logic           multicycle_ready;
logic           load;
logic           store;
//////////////////////////////////////////////
//main code

/* alu AUTO_TEMPLATE(
   	.operator			(alu_op_ex[]),
	.operator_a			(src_a_ex[]),
	.operator_b			(src_b_ex[]));
);
*/

alu u_alu(/*AUTOINST*/
	  // Outputs
	  .adder_result			(adder_result[31:0]),
	  .logic_result			(logic_result[31:0]),
	  .shift_result			(shift_result[31:0]),
	  .branch_compare_result	(branch_compare_result),
	  .alu_result			(alu_result[31:0]),
	  .alu_result_valid		(alu_result_valid),
	  // Inputs
	  .operator			(alu_op_ex[ALU_NUM-1:0]), // Templated
	  .operator_a			(src_a_ex[31:0]),	 // Templated
	  .operator_b			(src_b_ex[31:0]));	 // Templated



//////////////////////////////////////////////
//branch
//////////////////////////////////////////////
assign branch_taken = branch_compare_result & (~exc_taken_ex);
assign branch_target_addr = pc_ex + src_c_ex;

//////////////////////////////////////////////
//branch
//////////////////////////////////////////////
assign jump_target_addr = adder_result;

//////////////////////////////////////////////
//control
//////////////////////////////////////////////

assign multicycle_busy = multicycle_instr & (~multicycle_ready);

assign ready_ex = ~( stall_E | (~ready_mem) | multicycle_busy | exc_taken_ex );
assign valid_ex = ~( stall_E | (~ready_mem) | multicycle_busy );

assign return_addr  = pc_ex + 4;

assign multicycle_instr = 1'b0;
assign multicycle_ready = 1'b0;

//////////////////////////////////////////////
//pipeline
//////////////////////////////////////////////
always @(posedge clk or negedge reset_n)begin
    if(!reset_n)begin
        lsu_en_mem          <= 1'b0;
        lsu_op_mem          <= LSU_OP_LD;
        lsu_dtype_mem[2:0]  <= LSU_DTYPE_U_BYTE;
        lsu_addr_mem[31:0]  <= 32'h0;
    //flush EX stage: current stage don't need flush pipeline
    //end else if( ~ready_ex & flush_E )begin
    //    lsu_en_mem          <= 1'b0;
    //    lsu_op_mem          <= 1'b0;
    //    lsu_dtype_mem[2:0]  <= 3'b0;
    //    lsu_addr_mem[31:0]  <= 32'h0;
    end else if(valid_ex)begin
        lsu_en_mem          <= lsu_en_ex;
        lsu_op_mem          <= lsu_op_ex;
        lsu_dtype_mem[2:0]  <= lsu_dtype_ex[2:0];
        lsu_addr_mem[31:0]  <= adder_result[31:0];
    end
end
assign lsu_wdata_mem[31:0] = rd_wr_data_mem[31:0];

always @(posedge clk or negedge reset_n)begin
    if(!reset_n)begin
        rd_wr_en_mem            <= 1'b0;
        rd_wr_addr_mem[4:0]     <= 5'h0;
        rd_wr_data_mem[31:0]    <= 32'h0;
    //end else if( valid_ex & flush_E )begin
    //    rd_wr_en_mem            <= 1'b0;
    //    rd_wr_addr_mem[4:0]     <= 5'h0;
    //    rd_wr_data_mem[31:0]    <= 32'h0;
    end else if(valid_ex)begin
        rd_wr_en_mem            <= rd_wr_en_ex;
        rd_wr_addr_mem[4:0]     <= rd_wr_addr_ex[4:0];
        rd_wr_data_mem[31:0]    <= rd_wr_data_ex[31:0];
    end
end

always @(posedge clk or negedge reset_n)begin
    if(!reset_n)begin
        pc_ex[31:0] <= 32'h0;
    end else if(valid_ex)begin
        if( exc_taken_ex & jump_ex )begin
            pc_ex[31:0] <= jump_target_addr;
        end else if( exc_taken_ex & branch_compare_result )begin
            pc_ex[31:0] <= branch_target_addr;
        end else begin
            pc_ex[31:0] <= pc_id[31:0];
        end
    end
end

assign rd_wr_data_ex  = jump_ex     ? return_addr   :
                        lsu_en_ex   ? src_c_ex : alu_result;//TODO

assign forward_ex_en    = rd_wr_en_ex & valid_ex;
assign forward_ex_addr  = rd_wr_addr_ex;
assign forward_ex_wdata = rd_wr_data_ex;

always @(posedge clk or negedge reset_n)begin
    if(!reset_n)begin
        exc_taken_mem        <= 1'b0;
        exc_cause_mem[5:0]   <= 6'h0;
        exc_tval_mem[31:0]   <= 32'h0;
    end else if( valid_ex )begin
        exc_taken_mem        <= exc_taken_ex;
        exc_cause_mem[5:0]   <= exc_cause_ex[5:0];
        exc_tval_mem[31:0]   <= 32'h0; //TODO
    end
end

endmodule
