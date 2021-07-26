//================================================================
//   Copyright (C) 2021 Sangfor Ltd. All rights reserved.
//
//   Filename     : riscv_core.v
//   Auther       : cnan
//   Created On   : 2021年04月05日
//   Description  : 
//
//
//================================================================
import riscv_pkg::*;

module riscv_core(
    input           clk,
    input           reset_n,

    //TODO
    input           intr,

    input           fetch_enable,
    input [31:0]    boot_addr,

    output          instr_req,
    output [31:0]   instr_addr,
    input           instr_gnt,
    input [31:0]    instr_rdata,
    input           instr_err,
    input           instr_valid,

    output          data_req,
    output          data_wr,
    input           data_gnt,
    output [31:0]   data_addr,
    output [31:0]   data_wdata,
    output [3:0]    data_byteen,
    input [31:0]    data_rdata,
    input           data_valid
);

// Local Variables:
// verilog-library-directories:(".")
// End:

//////////////////////////////////////////////
/*AUTOLOGIC*/
// Beginning of automatic wires (for undeclared instantiated-module outputs)
logic			alu_en_ex;		// From id_stage of id_stage.v
logic			branch_ex;		// From id_stage of id_stage.v
logic			branch_taken;		// From ex_stage of ex_stage.v
logic [31:0]		branch_target_addr;	// From ex_stage of ex_stage.v
logic [11:0]		csr_addr_ex;		// From id_stage of id_stage.v
logic			csr_en_ex;		// From id_stage of id_stage.v
logic [1:0]		csr_op_ex;		// From id_stage of id_stage.v
logic [31:0]		csr_wdata_ex;		// From id_stage of id_stage.v
logic [3:0]		data_be;		// From mem_stage of mem_stage.v
logic [5:0]		exc_cause_ex;		// From id_stage of id_stage.v
logic [5:0]		exc_cause_mem;		// From ex_stage of ex_stage.v
logic [5:0]		exc_cause_wb;		// From mem_stage of mem_stage.v
logic			exc_taken_ex;		// From id_stage of id_stage.v
logic			exc_taken_mem;		// From ex_stage of ex_stage.v
logic			exc_taken_wb;		// From mem_stage of mem_stage.v
logic [31:0]		exc_tval_ex;		// From id_stage of id_stage.v
logic [31:0]		exc_tval_mem;		// From ex_stage of ex_stage.v
logic [31:0]		exc_tval_wb;		// From mem_stage of mem_stage.v
logic			flush_D;		// From controller of controller.v
logic			flush_E;		// From controller of controller.v
logic			flush_F;		// From controller of controller.v
logic			flush_M;		// From controller of controller.v
logic			flush_W;		// From controller of controller.v
logic [4:0]		forward_ex_addr;	// From ex_stage of ex_stage.v
logic			forward_ex_en;		// From ex_stage of ex_stage.v
logic [31:0]		forward_ex_wdata;	// From ex_stage of ex_stage.v
logic [4:0]		forward_mem_addr;	// From mem_stage of mem_stage.v
logic			forward_mem_en;		// From mem_stage of mem_stage.v
logic [31:0]		forward_mem_wdata;	// From mem_stage of mem_stage.v
logic			instr_fetch_error;	// From if_stage of if_stage.v
logic [31:0]		instr_payload_id;	// From if_stage of if_stage.v
logic			instr_value_id;		// From if_stage of if_stage.v
logic			irq_ack;		// From id_stage of id_stage.v, ...
logic			is_compress_intr;	// From if_stage of if_stage.v
logic			jump_ex;		// From id_stage of id_stage.v
logic			jump_taken;		// From ex_stage of ex_stage.v
logic [31:0]		jump_target_addr;	// From ex_stage of ex_stage.v
logic [31:0]		lsu_addr_mem;		// From ex_stage of ex_stage.v
logic			lsu_en_ex;		// From id_stage of id_stage.v
logic			lsu_en_mem;		// From ex_stage of ex_stage.v
logic			lsu_en_wb;		// From mem_stage of mem_stage.v
logic			lsu_err;		// From mem_stage of mem_stage.v
logic [31:0]		lsu_rdata;		// From mem_stage of mem_stage.v
logic			lsu_valid;		// From mem_stage of mem_stage.v
logic [31:0]		lsu_wdata_mem;		// From ex_stage of ex_stage.v
logic [31:0]		pc_ex;			// From ex_stage of ex_stage.v
logic [31:0]		pc_id;			// From id_stage of id_stage.v
logic [31:0]		pc_if;			// From if_stage of if_stage.v
logic [4:0]		rd_wr_addr_ex;		// From id_stage of id_stage.v
logic [4:0]		rd_wr_addr_mem;		// From ex_stage of ex_stage.v
logic [4:0]		rd_wr_addr_wb;		// From mem_stage of mem_stage.v
logic [31:0]		rd_wr_data_mem;		// From ex_stage of ex_stage.v
logic [31:0]		rd_wr_data_wb;		// From mem_stage of mem_stage.v
logic			rd_wr_en_ex;		// From id_stage of id_stage.v
logic			rd_wr_en_mem;		// From ex_stage of ex_stage.v
logic			rd_wr_en_wb;		// From mem_stage of mem_stage.v
logic			ready_ex;		// From ex_stage of ex_stage.v
logic			ready_id;		// From id_stage of id_stage.v
logic			ready_mem;		// From mem_stage of mem_stage.v
logic			ready_wb;		// From wb_stage of wb_stage.v
logic [4:0]		rf_wr_addr;		// From wb_stage of wb_stage.v
logic [31:0]		rf_wr_data;		// From wb_stage of wb_stage.v
logic			rf_wr_en;		// From wb_stage of wb_stage.v
logic [31:0]		set_pc;			// From controller of controller.v
logic			set_pc_valid;		// From controller of controller.v
logic [31:0]		src_a_ex;		// From id_stage of id_stage.v
logic [31:0]		src_b_ex;		// From id_stage of id_stage.v
logic [31:0]		src_c_ex;		// From id_stage of id_stage.v
logic			stall_D;		// From controller of controller.v
logic			stall_E;		// From controller of controller.v
logic			stall_F;		// From controller of controller.v
logic			stall_M;		// From controller of controller.v
logic			stall_W;		// From controller of controller.v
logic			wb_data_mux;		// From mem_stage of mem_stage.v
// End of automatics
//////////////////////////////////////////////

//////////////////////////////////////////////
//main code

//TODO
logic irq_req;
logic [4:0]irq_id;
logic debug_req;

assign irq_req = 1'b0;
assign debug_req = 1'b0;
assign irq_id = 'd0;

import riscv_pkg::*;

alu_op_e            alu_op_ex;
lsu_op_e            lsu_op_ex;
lsu_dtype_e         lsu_dtype_ex;
lsu_op_e            lsu_op_mem;
lsu_dtype_e         lsu_dtype_mem;

// Local Variables:                                                                 
// verilog-auto-inst-param-value:t                                                  
// End:
//

/* if_stage AUTO_TEMPLATE(
    .pc_id_ready     (id_stage_ready),
		  .flush_if_id		(flush_if),
    .id_instruction		(instruction[31:0]),
    .id_instruction_value	(instruction_value),
);
*/
if_stage if_stage(
    /*AUTOINST*/
		  // Outputs
		  .pc_if		(pc_if[31:0]),
		  .instr_payload_id	(instr_payload_id[31:0]),
		  .instr_value_id	(instr_value_id),
		  .instr_fetch_error	(instr_fetch_error),
		  .is_compress_intr	(is_compress_intr),
		  .instr_req		(instr_req),
		  .instr_addr		(instr_addr[31:0]),
		  // Inputs
		  .clk			(clk),
		  .reset_n		(reset_n),
		  .boot_addr		(boot_addr[31:0]),
		  .fetch_enable		(fetch_enable),
		  .flush_F		(flush_F),
		  .stall_F		(stall_F),
		  .ready_id		(ready_id),
		  .set_pc_valid		(set_pc_valid),
		  .set_pc		(set_pc[31:0]),
		  .instr_gnt		(instr_gnt),
		  .instr_rdata		(instr_rdata[31:0]),
		  .instr_err		(instr_err),
		  .instr_valid		(instr_valid));

/* id_stage AUTO_TEMPLATE(
    .instr_payload  (instr_payload_id),
    .instr_value    (instr_value_id),
    .rf_wr_wb_en	(rf_wr_en),
	.rf_wr_wb_addr	(rf_wr_addr[]),
	.rf_wr_wb_data	(rf_wr_data[]),
);
*/
id_stage id_stage(
    /*AUTOINST*/
		  // Interfaces
		  .alu_op_ex		(alu_op_ex),
		  .lsu_op_ex		(lsu_op_ex),
		  .lsu_dtype_ex		(lsu_dtype_ex),
		  // Outputs
		  .ready_id		(ready_id),
		  .irq_ack		(irq_ack),
		  .jump_ex		(jump_ex),
		  .branch_ex		(branch_ex),
		  .alu_en_ex		(alu_en_ex),
		  .src_a_ex		(src_a_ex[31:0]),
		  .src_b_ex		(src_b_ex[31:0]),
		  .src_c_ex		(src_c_ex[31:0]),
		  .lsu_en_ex		(lsu_en_ex),
		  .csr_en_ex		(csr_en_ex),
		  .csr_op_ex		(csr_op_ex[1:0]),
		  .csr_addr_ex		(csr_addr_ex[11:0]),
		  .csr_wdata_ex		(csr_wdata_ex[31:0]),
		  .rd_wr_en_ex		(rd_wr_en_ex),
		  .rd_wr_addr_ex	(rd_wr_addr_ex[4:0]),
		  .exc_taken_ex		(exc_taken_ex),
		  .exc_cause_ex		(exc_cause_ex[5:0]),
		  .exc_tval_ex		(exc_tval_ex[31:0]),
		  .pc_id		(pc_id[31:0]),
		  // Inputs
		  .clk			(clk),
		  .reset_n		(reset_n),
		  .pc_if		(pc_if[31:0]),
		  .instr_payload	(instr_payload_id),	 // Templated
		  .instr_value		(instr_value_id),	 // Templated
		  .instr_fetch_error	(instr_fetch_error),
		  .stall_D		(stall_D),
		  .flush_D		(flush_D),
		  .ready_ex		(ready_ex),
		  .irq_req		(irq_req),
		  .irq_id		(irq_id[4:0]),
		  .irq_taken_wb		(irq_taken_wb),
		  .debug_req		(debug_req),
		  .forward_ex_en	(forward_ex_en),
		  .forward_ex_addr	(forward_ex_addr[4:0]),
		  .forward_ex_wdata	(forward_ex_wdata[31:0]),
		  .forward_mem_en	(forward_mem_en),
		  .forward_mem_addr	(forward_mem_addr[4:0]),
		  .forward_mem_wdata	(forward_mem_wdata[31:0]),
		  .rf_wr_wb_en		(rf_wr_en),		 // Templated
		  .rf_wr_wb_addr	(rf_wr_addr[4:0]),	 // Templated
		  .rf_wr_wb_data	(rf_wr_data[31:0]));	 // Templated

/* ex_stage AUTO_TEMPLATE(
      );*/
ex_stage ex_stage(
    /*AUTOINST*/
		  // Interfaces
		  .alu_op_ex		(alu_op_ex),
		  .lsu_op_ex		(lsu_op_ex),
		  .lsu_dtype_ex		(lsu_dtype_ex),
		  .lsu_op_mem		(lsu_op_mem),
		  .lsu_dtype_mem	(lsu_dtype_mem),
		  // Outputs
		  .ready_ex		(ready_ex),
		  .pc_ex		(pc_ex[31:0]),
		  .jump_target_addr	(jump_target_addr[31:0]),
		  .jump_taken		(jump_taken),
		  .branch_target_addr	(branch_target_addr[31:0]),
		  .branch_taken		(branch_taken),
		  .lsu_en_mem		(lsu_en_mem),
		  .lsu_addr_mem		(lsu_addr_mem[31:0]),
		  .lsu_wdata_mem	(lsu_wdata_mem[31:0]),
		  .exc_taken_mem	(exc_taken_mem),
		  .exc_cause_mem	(exc_cause_mem[5:0]),
		  .exc_tval_mem		(exc_tval_mem[31:0]),
		  .rd_wr_en_mem		(rd_wr_en_mem),
		  .rd_wr_addr_mem	(rd_wr_addr_mem[4:0]),
		  .rd_wr_data_mem	(rd_wr_data_mem[31:0]),
		  .forward_ex_en	(forward_ex_en),
		  .forward_ex_addr	(forward_ex_addr[4:0]),
		  .forward_ex_wdata	(forward_ex_wdata[31:0]),
		  // Inputs
		  .clk			(clk),
		  .reset_n		(reset_n),
		  .stall_E		(stall_E),
		  .ready_mem		(ready_mem),
		  .pc_id		(pc_id[31:0]),
		  .jump_ex		(jump_ex),
		  .branch_ex		(branch_ex),
		  .alu_en_ex		(alu_en_ex),
		  .src_a_ex		(src_a_ex[31:0]),
		  .src_b_ex		(src_b_ex[31:0]),
		  .src_c_ex		(src_c_ex[31:0]),
		  .lsu_en_ex		(lsu_en_ex),
		  .csr_en_ex		(csr_en_ex),
		  .csr_op_ex		(csr_op_ex[1:0]),
		  .csr_addr_ex		(csr_addr_ex[11:0]),
		  .csr_wdata_ex		(csr_wdata_ex[31:0]),
		  .rd_wr_en_ex		(rd_wr_en_ex),
		  .rd_wr_addr_ex	(rd_wr_addr_ex[4:0]),
		  .exc_taken_ex		(exc_taken_ex),
		  .exc_cause_ex		(exc_cause_ex[5:0]),
		  .exc_tval_ex		(exc_tval_ex[31:0]));

/*mem_stage AUTO_TEMPLATE(
);*/
mem_stage mem_stage(
    /*AUTOINST*/
		    // Interfaces
		    .lsu_op_mem		(lsu_op_mem),
		    .lsu_dtype_mem	(lsu_dtype_mem),
		    // Outputs
		    .ready_mem		(ready_mem),
		    .forward_mem_en	(forward_mem_en),
		    .forward_mem_addr	(forward_mem_addr[4:0]),
		    .forward_mem_wdata	(forward_mem_wdata[31:0]),
		    .rd_wr_en_wb	(rd_wr_en_wb),
		    .rd_wr_addr_wb	(rd_wr_addr_wb[4:0]),
		    .rd_wr_data_wb	(rd_wr_data_wb[31:0]),
		    .lsu_en_wb		(lsu_en_wb),
		    .wb_data_mux	(wb_data_mux),
		    .lsu_rdata		(lsu_rdata[31:0]),
		    .lsu_valid		(lsu_valid),
		    .lsu_err		(lsu_err),
		    .exc_taken_wb	(exc_taken_wb),
		    .exc_cause_wb	(exc_cause_wb[5:0]),
		    .exc_tval_wb	(exc_tval_wb[31:0]),
		    .data_req		(data_req),
		    .data_wr		(data_wr),
		    .data_addr		(data_addr[31:0]),
		    .data_wdata		(data_wdata[31:0]),
		    .data_be		(data_be[3:0]),
		    // Inputs
		    .clk		(clk),
		    .reset_n		(reset_n),
		    .rd_wr_en_mem	(rd_wr_en_mem),
		    .rd_wr_addr_mem	(rd_wr_addr_mem[4:0]),
		    .rd_wr_data_mem	(rd_wr_data_mem[31:0]),
		    .lsu_en_mem		(lsu_en_mem),
		    .lsu_addr_mem	(lsu_addr_mem[31:0]),
		    .lsu_wdata_mem	(lsu_wdata_mem[31:0]),
		    .exc_taken_mem	(exc_taken_mem),
		    .exc_cause_mem	(exc_cause_mem[5:0]),
		    .exc_tval_mem	(exc_tval_mem[31:0]),
		    .flush_M		(flush_M),
		    .ready_wb		(ready_wb),
		    .data_gnt		(data_gnt),
		    .data_rdata		(data_rdata[31:0]),
		    .data_valid		(data_valid),
		    .data_error		(data_error));

wb_stage wb_stage(
    /*AUTOINST*/
		  // Outputs
		  .ready_wb		(ready_wb),
		  .rf_wr_en		(rf_wr_en),
		  .rf_wr_addr		(rf_wr_addr[4:0]),
		  .rf_wr_data		(rf_wr_data[31:0]),
		  // Inputs
		  .clk			(clk),
		  .reset_n		(reset_n),
		  .rd_wr_en_wb		(rd_wr_en_wb),
		  .rd_wr_addr_wb	(rd_wr_addr_wb[4:0]),
		  .rd_wr_data_wb	(rd_wr_data_wb[31:0]),
		  .lsu_en_wb		(lsu_en_wb),
		  .wb_data_mux		(wb_data_mux),
		  .lsu_rdata		(lsu_rdata[31:0]),
		  .lsu_valid		(lsu_valid),
		  .flush_W		(flush_W));

/*controller AUTO_TEMPLATE(
);*/
controller controller(/*AUTOINST*/
		      // Outputs
		      .set_pc_valid	(set_pc_valid),
		      .set_pc		(set_pc[31:0]),
		      .flush_F		(flush_F),
		      .flush_D		(flush_D),
		      .flush_E		(flush_E),
		      .flush_M		(flush_M),
		      .flush_W		(flush_W),
		      .stall_F		(stall_F),
		      .stall_D		(stall_D),
		      .stall_E		(stall_E),
		      .stall_M		(stall_M),
		      .stall_W		(stall_W),
		      .irq_ack		(irq_ack),
		      // Inputs
		      .clk		(clk),
		      .reset_n		(reset_n),
		      .jump		(jump),
		      .branch_taken	(branch_taken),
		      .fence		(fence),
		      .jump_target_addr	(jump_target_addr[31:0]),
		      .branch_target_addr(branch_target_addr[31:0]),
		      .pc_if		(pc_if[31:0]),
		      .lsu_valid	(lsu_valid),
		      .lsu_err		(lsu_err),
		      .exc_taken_wb	(exc_taken_wb),
		      .exc_cause_wb	(exc_cause_wb[5:0]),
		      .exc_tval_wb	(exc_tval_wb[31:0]));



endmodule
