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
    input                   clk,
    input                   reset_n,

    //controller
    input                   stall_ex_stage,
    output logic            ex_stage_ready,
    output logic            load_instr_in_ex,

    input [31:0]            pc_id,
    output logic [31:0]     pc_ex,

    output logic            ex_dest_we_valid,
    output logic [4:0]      ex_dest_we_addr,
    output logic [31:0]     ex_dest_we_data,

    output logic            mem_dest_we_valid,
    output logic [4:0]      mem_dest_we_addr,
    output logic [31:0]     mem_dest_we_data,

    //branch taken
    output logic            branch_taken,
    output logic [31:0]     branch_target_addr,

    //alu
    input [ALU_NUM-1:0]     alu_operator,
    input [31:0]            alu_operate_a,
    input [31:0]            alu_operate_b,
    input [31:0]            alu_operate_c,
    input                   jump,
    output logic [31:0]     jump_target_addr,

    input logic [4:0]       ex_dest_addr,

    //lsu
    input                   ex_lsu_valid,
    input                   ex_lsu_wr_type,
    input   [2:0]           ex_lsu_width_type,
    
    output logic            mem_lsu_valid,
    output logic            mem_lsu_wr_type,
    output logic [2:0]      mem_lsu_width_type,
    output logic [31:0]     mem_lsu_addr,
    output logic [31:0]     mem_lsu_wdata
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

logic [31:0]    return_addr;
logic           ex_stage_valid;
logic           multicycle_instr;
logic           multicycle_ready;
logic           load;
logic           store;
//////////////////////////////////////////////
//main code

/* alu AUTO_TEMPLATE(
   	.operator			(alu_operator[]),
	.operator_a			(alu_operate_a[]),
	.operator_b			(alu_operate_b[]));
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
	  .operator			(alu_operator[ALU_NUM-1:0]), // Templated
	  .operator_a			(alu_operate_a[31:0]),	 // Templated
	  .operator_b			(alu_operate_b[31:0]));	 // Templated


//////////////////////////////////////////////
//branch
//////////////////////////////////////////////
assign branch_taken = branch_compare_result;
assign branch_target_addr = pc_ex + alu_operate_c;

//////////////////////////////////////////////
//branch
//////////////////////////////////////////////
assign jump_target_addr = adder_result;

//////////////////////////////////////////////
//control
//////////////////////////////////////////////
assign ex_stage_ready   = (~multicycle_instr) | (multicycle_instr & multicycle_ready); //TODO
assign ex_stage_valid   = ( (alu_operator!=ALU_NONE) | jump | ex_lsu_valid ) & ex_stage_ready;
assign load_instr_in_ex = ex_stage_valid & load;

assign return_addr      = pc_ex + 4;

assign ex_dest_we_valid = (alu_result_valid | jump) & (~ex_lsu_valid); 
assign ex_dest_we_data  =   jump    ? return_addr   :
                            store   ? alu_operate_c : alu_result;//TODO
assign ex_dest_we_addr  = ex_dest_addr;

assign multicycle_instr = 1'b0;
assign multicycle_ready = 1'b0;

//////////////////////////////////////////////
//lsu
//////////////////////////////////////////////
assign load     = ( ex_lsu_valid & ~ex_lsu_wr_type );
assign store    = ( ex_lsu_valid & ex_lsu_wr_type );
always @(posedge clk or negedge reset_n)begin
    if(!reset_n)begin
        mem_lsu_valid           <= 1'b0;
        mem_lsu_wr_type         <= 1'b0;
        mem_lsu_width_type[2:0] <= 3'b0;
        mem_lsu_addr[31:0]      <= 32'h0;
    end else if( !ex_stage_valid )begin
        mem_lsu_valid           <= 1'b0;
        mem_lsu_wr_type         <= 1'b0;
        mem_lsu_width_type[2:0] <= 3'b0;
        mem_lsu_addr[31:0]      <= 32'h0;
    end else if(!stall_ex_stage & ex_stage_ready)begin
        mem_lsu_valid           <= ex_lsu_valid;
        mem_lsu_wr_type         <= ex_lsu_wr_type;
        mem_lsu_width_type[2:0] <= ex_lsu_width_type[2:0];
        mem_lsu_addr[31:0]      <= adder_result[31:0];
    end
end
assign mem_lsu_wdata[31:0] = mem_dest_we_data[31:0];

//////////////////////////////////////////////
//pipeline
//////////////////////////////////////////////
always @(posedge clk or negedge reset_n)begin
    if(!reset_n)begin
        mem_dest_we_valid      <= 1'b0;
        mem_dest_we_addr[4:0]  <= 5'h0;
        mem_dest_we_data[31:0] <= 32'h0;
    end else if( !ex_stage_valid )begin
        mem_dest_we_valid      <= 1'b0;
        mem_dest_we_addr[4:0]  <= 5'h0;
        mem_dest_we_data[31:0] <= 32'h0;
    end else if(!stall_ex_stage & ex_stage_valid)begin
        mem_dest_we_valid      <= ex_dest_we_valid;
        mem_dest_we_addr[4:0]  <= ex_dest_we_addr[4:0];
        mem_dest_we_data[31:0] <= ex_dest_we_data[31:0];
    end
end

always @(posedge clk or negedge reset_n)begin
    if(!reset_n)begin
        pc_ex[31:0] <= 32'h0;
    end else if(!stall_ex_stage & ex_stage_valid)begin
        pc_ex[31:0] <= pc_id[31:0];
    end
end

endmodule
