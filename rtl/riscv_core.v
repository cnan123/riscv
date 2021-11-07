//================================================================
//   Copyright (C) 2021. All rights reserved.
//
//   Filename     : riscv_core.v
//   Auther       : cnan
//   Created On   : 2021.04.05
//   Description  : 
//
//
//================================================================

module riscv_core#(
    parameter ILLEGAL_CSR_EN = 1'b0,
    parameter BRANCH_PREDICTION = 1'b0,
    parameter ENA_BHT = 1,
    parameter ENA_BTB = 1,
    parameter ENA_RAS = 0,
    parameter ENA_JUMP = 1
)(
    input           clk,
    input           reset_n,

    input           extern_irq,
    input           soft_irq,
    input           timer_irq,

    input           debug_req, //TODO

    input [31:0]    hart_id,
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
    output [3:0]    data_be,
    input [31:0]    data_rdata,
    input           data_valid,
    input           data_error
);

import riscv_pkg::*;

// Local Variables:
// verilog-library-directories:(".")
// End:

//////////////////////////////////////////////
/*AUTOLOGIC*/
// Beginning of automatic wires (for undeclared instantiated-module outputs)
logic			adder_en_ex;		// From id_stage of id_stage.v
logic [31:0]		bht_pc;			// From ex_stage of ex_stage.v
logic			bht_taken;		// From ex_stage of ex_stage.v
logic			bht_updata;		// From ex_stage of ex_stage.v
logic			branch_ex;		// From id_stage of id_stage.v
logic			branch_taken;		// From ex_stage of ex_stage.v
logic [31:0]		branch_target_addr;	// From ex_stage of ex_stage.v
logic			btb_invalid;		// From ex_stage of ex_stage.v
logic [31:0]		btb_pc;			// From ex_stage of ex_stage.v
logic [31:0]		btb_target;		// From ex_stage of ex_stage.v
logic			btb_update;		// From ex_stage of ex_stage.v
logic [4:0]		clr_dirty_ex_addr;	// From ex_stage of ex_stage.v
logic			clr_dirty_ex_en;	// From ex_stage of ex_stage.v
logic [4:0]		clr_dirty_mem_addr;	// From mem_stage of mem_stage.v
logic			clr_dirty_mem_en;	// From mem_stage of mem_stage.v
logic [4:0]		clr_dirty_wb_addr;	// From wb_stage of wb_stage.v
logic			clr_dirty_wb_en;	// From wb_stage of wb_stage.v
logic			comp_en_ex;		// From id_stage of id_stage.v
logic			compress_instr_ex;	// From id_stage of id_stage.v
logic			compress_instr_id;	// From if_stage of if_stage.v
logic [11:0]		csr_addr_ex;		// From id_stage of id_stage.v
logic			csr_en_ex;		// From id_stage of id_stage.v
logic [1:0]		csr_op_ex;		// From id_stage of id_stage.v
logic [31:0]		csr_wdata_ex;		// From id_stage of id_stage.v
logic			exc_taken;		// From wb_stage of wb_stage.v
logic			exc_taken_ex;		// From id_stage of id_stage.v
logic			exc_taken_mem;		// From ex_stage of ex_stage.v
logic			exc_taken_wb;		// From mem_stage of mem_stage.v
logic			extern_irq_taken;	// From plic of plic.v
logic			fetch_enable;		// From controller of controller.v
logic			flush_D;		// From controller of controller.v
logic			flush_E;		// From controller of controller.v
logic			flush_F;		// From controller of controller.v
logic			flush_M;		// From controller of controller.v
logic			flush_W;		// From controller of controller.v
logic [4:0]		forward_ex_addr;	// From ex_stage of ex_stage.v
logic			forward_ex_en;		// From ex_stage of ex_stage.v
logic [TAG_WIDTH-1:0]	forward_ex_tag;		// From ex_stage of ex_stage.v
logic [31:0]		forward_ex_wdata;	// From ex_stage of ex_stage.v
logic [4:0]		forward_mem_addr;	// From mem_stage of mem_stage.v
logic			forward_mem_en;		// From mem_stage of mem_stage.v
logic [TAG_WIDTH-1:0]	forward_mem_tag;	// From mem_stage of mem_stage.v
logic [31:0]		forward_mem_wdata;	// From mem_stage of mem_stage.v
logic			instr_fetch_error;	// From if_stage of if_stage.v
logic [31:0]		instr_payload_id;	// From if_stage of if_stage.v
logic			instr_value_id;		// From if_stage of if_stage.v
logic			iretire_ex;		// From id_stage of id_stage.v
logic			iretire_mem;		// From ex_stage of ex_stage.v
logic			iretire_wb;		// From mem_stage of mem_stage.v
logic			irq_ack;		// From controller of controller.v
logic			is_ebreak;		// From id_stage of id_stage.v
logic			is_ecall;		// From id_stage of id_stage.v
logic			is_fence;		// From id_stage of id_stage.v
logic			is_illegal_csr;		// From ex_stage of ex_stage.v
logic			is_illegal_instr;	// From id_stage of id_stage.v
logic			is_instr_acs_fault;	// From id_stage of id_stage.v
logic			is_interrupt;		// From id_stage of id_stage.v
logic			is_lsu_load_err;	// From wb_stage of wb_stage.v
logic			is_lsu_store_err;	// From wb_stage of wb_stage.v
logic			is_mret;		// From id_stage of id_stage.v
logic			is_sret;		// From id_stage of id_stage.v
logic			is_uret;		// From id_stage of id_stage.v
logic			is_wfi;			// From id_stage of id_stage.v
logic			jalr_ex;		// From id_stage of id_stage.v
logic			jump_ex;		// From id_stage of id_stage.v
logic			jump_taken;		// From ex_stage of ex_stage.v
logic [31:0]		jump_target_addr;	// From ex_stage of ex_stage.v
logic			logic_en_ex;		// From id_stage of id_stage.v
logic [31:0]		lsu_addr_mem;		// From ex_stage of ex_stage.v
logic			lsu_en_ex;		// From id_stage of id_stage.v
logic			lsu_en_mem;		// From ex_stage of ex_stage.v
logic			lsu_en_wb;		// From mem_stage of mem_stage.v
logic			lsu_err_wb;		// From mem_stage of mem_stage.v
logic [31:0]		lsu_rdata_wb;		// From mem_stage of mem_stage.v
logic			lsu_valid_wb;		// From mem_stage of mem_stage.v
logic [31:0]		lsu_wdata_mem;		// From ex_stage of ex_stage.v
logic			mcause_update;		// From controller of controller.v
logic [31:0]		mepc;			// From ex_stage of ex_stage.v
logic			mepc_updata;		// From controller of controller.v
logic [31:0]		mie;			// From ex_stage of ex_stage.v
logic			mstatus_mie;		// From ex_stage of ex_stage.v
logic [31:0]		mtvec;			// From ex_stage of ex_stage.v
logic			mult_en_ex;		// From id_stage of id_stage.v
logic [31:0]		pc_ex;			// From id_stage of id_stage.v
logic [31:0]		pc_id;			// From if_stage of if_stage.v
logic [31:0]		pc_if;			// From if_stage of if_stage.v
logic [31:0]		pc_mem;			// From ex_stage of ex_stage.v
logic [31:0]		pc_wb;			// From mem_stage of mem_stage.v
logic			predict_fail;		// From ex_stage of ex_stage.v
logic [31:0]		predict_pc_id;		// From if_stage of if_stage.v
logic			predict_taken_ex;	// From id_stage of id_stage.v
logic			predict_taken_id;	// From if_stage of if_stage.v
logic [4:0]		rd_wr_addr_ex;		// From id_stage of id_stage.v
logic [4:0]		rd_wr_addr_mem;		// From ex_stage of ex_stage.v
logic [4:0]		rd_wr_addr_wb;		// From mem_stage of mem_stage.v
logic [31:0]		rd_wr_data_mem;		// From ex_stage of ex_stage.v
logic [31:0]		rd_wr_data_wb;		// From mem_stage of mem_stage.v
logic			rd_wr_en_ex;		// From id_stage of id_stage.v
logic			rd_wr_en_mem;		// From ex_stage of ex_stage.v
logic			rd_wr_en_wb;		// From mem_stage of mem_stage.v
logic [TAG_WIDTH-1:0]	rd_wr_tag_ex;		// From id_stage of id_stage.v
logic [TAG_WIDTH-1:0]	rd_wr_tag_mem;		// From ex_stage of ex_stage.v
logic [TAG_WIDTH-1:0]	rd_wr_tag_wb;		// From mem_stage of mem_stage.v
logic			ready_ex;		// From ex_stage of ex_stage.v
logic			ready_id;		// From id_stage of id_stage.v
logic			ready_mem;		// From mem_stage of mem_stage.v
logic			ready_wb;		// From wb_stage of wb_stage.v
logic [4:0]		rf_wr_addr;		// From wb_stage of wb_stage.v
logic [31:0]		rf_wr_data;		// From wb_stage of wb_stage.v
logic			rf_wr_en;		// From wb_stage of wb_stage.v
logic [TAG_WIDTH-1:0]	rf_wr_tag;		// From wb_stage of wb_stage.v
logic [31:0]		set_pc;			// From controller of controller.v
logic			set_pc_valid;		// From controller of controller.v
logic			shift_en_ex;		// From id_stage of id_stage.v
logic			sign_ex;		// From id_stage of id_stage.v
logic			soft_irq_taken;		// From plic of plic.v
logic [31:0]		src_a_ex;		// From id_stage of id_stage.v
logic [31:0]		src_b_ex;		// From id_stage of id_stage.v
logic [31:0]		src_c_ex;		// From id_stage of id_stage.v
logic			stall_D;		// From controller of controller.v
logic			stall_E;		// From controller of controller.v
logic			stall_F;		// From controller of controller.v
logic			stall_M;		// From controller of controller.v
logic			stall_W;		// From controller of controller.v
logic			timer_irq_taken;	// From plic of plic.v
// End of automatics
//////////////////////////////////////////////

//////////////////////////////////////////////
//main code

adder_op_e          adder_op_ex;
comp_op_e           comp_op_ex;
logic_op_e          logic_op_ex;
shift_op_e          shift_op_ex;

lsu_op_e            lsu_op_ex;
lsu_dtype_e         lsu_dtype_ex;
lsu_op_e            lsu_op_mem;
lsu_dtype_e         lsu_dtype_mem;
lsu_op_e            lsu_op_wb;

mult_op_e           mult_op_ex;

mcause_e            mcause;
mepc_mux_e          mepc_mux;
privilege_e         privilege_mode;

// Local Variables:                                                                 
// verilog-auto-inst-param-value:t                                                  
// End:
//

/* if_stage #(
    .BRANCH_PREDICTION  (BRANCH_PREDICTION)
)AUTO_TEMPLATE(
);
*/
if_stage #(
    /*AUTOINSTPARAM*/
	   // Parameters
	   .BRANCH_PREDICTION		(BRANCH_PREDICTION),
	   .ENA_BHT			(ENA_BHT),
	   .ENA_BTB			(ENA_BTB),
	   .ENA_RAS			(ENA_RAS),
	   .ENA_JUMP			(ENA_JUMP))if_stage(
    /*AUTOINST*/
							    // Outputs
							    .pc_if		(pc_if[31:0]),
							    .pc_id		(pc_id[31:0]),
							    .instr_payload_id	(instr_payload_id[31:0]),
							    .instr_value_id	(instr_value_id),
							    .compress_instr_id	(compress_instr_id),
							    .predict_taken_id	(predict_taken_id),
							    .predict_pc_id	(predict_pc_id[31:0]),
							    .instr_fetch_error	(instr_fetch_error),
							    .instr_req		(instr_req),
							    .instr_addr		(instr_addr[31:0]),
							    // Inputs
							    .clk		(clk),
							    .reset_n		(reset_n),
							    .boot_addr		(boot_addr[31:0]),
							    .fetch_enable	(fetch_enable),
							    .flush_F		(flush_F),
							    .stall_F		(stall_F),
							    .ready_id		(ready_id),
							    .set_pc_valid	(set_pc_valid),
							    .set_pc		(set_pc[31:0]),
							    .predict_fail	(predict_fail),
							    .btb_invalid	(btb_invalid),
							    .btb_update		(btb_update),
							    .btb_pc		(btb_pc[31:0]),
							    .btb_target		(btb_target[31:0]),
							    .bht_updata		(bht_updata),
							    .bht_pc		(bht_pc[31:0]),
							    .bht_taken		(bht_taken),
							    .instr_gnt		(instr_gnt),
							    .instr_rdata	(instr_rdata[31:0]),
							    .instr_err		(instr_err),
							    .instr_valid	(instr_valid));

/* id_stage AUTO_TEMPLATE(
    .instr_payload  (instr_payload_id),
    .instr_value    (instr_value_id),
    .rf_wr_wb_en	(rf_wr_en),
    .rf_wr_wb_tag	(rf_wr_tag[]),
	.rf_wr_wb_addr	(rf_wr_addr[]),
	.rf_wr_wb_data	(rf_wr_data[]),
);
*/
id_stage id_stage(
    /*AUTOINST*/
		  // Interfaces
		  .adder_op_ex		(adder_op_ex),
		  .comp_op_ex		(comp_op_ex),
		  .logic_op_ex		(logic_op_ex),
		  .shift_op_ex		(shift_op_ex),
		  .mult_op_ex		(mult_op_ex),
		  .lsu_op_ex		(lsu_op_ex),
		  .lsu_dtype_ex		(lsu_dtype_ex),
		  // Outputs
		  .ready_id		(ready_id),
		  .compress_instr_ex	(compress_instr_ex),
		  .jalr_ex		(jalr_ex),
		  .jump_ex		(jump_ex),
		  .branch_ex		(branch_ex),
		  .predict_taken_ex	(predict_taken_ex),
		  .sign_ex		(sign_ex),
		  .adder_en_ex		(adder_en_ex),
		  .comp_en_ex		(comp_en_ex),
		  .logic_en_ex		(logic_en_ex),
		  .shift_en_ex		(shift_en_ex),
		  .src_a_ex		(src_a_ex[31:0]),
		  .src_b_ex		(src_b_ex[31:0]),
		  .src_c_ex		(src_c_ex[31:0]),
		  .mult_en_ex		(mult_en_ex),
		  .lsu_en_ex		(lsu_en_ex),
		  .csr_en_ex		(csr_en_ex),
		  .csr_op_ex		(csr_op_ex[1:0]),
		  .csr_addr_ex		(csr_addr_ex[11:0]),
		  .csr_wdata_ex		(csr_wdata_ex[31:0]),
		  .rd_wr_en_ex		(rd_wr_en_ex),
		  .rd_wr_tag_ex		(rd_wr_tag_ex[TAG_WIDTH-1:0]),
		  .rd_wr_addr_ex	(rd_wr_addr_ex[4:0]),
		  .exc_taken_ex		(exc_taken_ex),
		  .is_ecall		(is_ecall),
		  .is_ebreak		(is_ebreak),
		  .is_mret		(is_mret),
		  .is_sret		(is_sret),
		  .is_uret		(is_uret),
		  .is_wfi		(is_wfi),
		  .is_fence		(is_fence),
		  .is_illegal_instr	(is_illegal_instr),
		  .is_instr_acs_fault	(is_instr_acs_fault),
		  .is_interrupt		(is_interrupt),
		  .iretire_ex		(iretire_ex),
		  .pc_ex		(pc_ex[31:0]),
		  // Inputs
		  .clk			(clk),
		  .reset_n		(reset_n),
		  .pc_id		(pc_id[31:0]),
		  .instr_payload	(instr_payload_id),	 // Templated
		  .instr_value		(instr_value_id),	 // Templated
		  .predict_taken_id	(predict_taken_id),
		  .predict_pc_id	(predict_pc_id[31:0]),
		  .compress_instr_id	(compress_instr_id),
		  .instr_fetch_error	(instr_fetch_error),
		  .stall_D		(stall_D),
		  .flush_D		(flush_D),
		  .ready_ex		(ready_ex),
		  .extern_irq_taken	(extern_irq_taken),
		  .soft_irq_taken	(soft_irq_taken),
		  .timer_irq_taken	(timer_irq_taken),
		  .debug_req		(debug_req),
		  .forward_ex_en	(forward_ex_en),
		  .forward_ex_tag	(forward_ex_tag[TAG_WIDTH-1:0]),
		  .forward_ex_addr	(forward_ex_addr[4:0]),
		  .forward_ex_wdata	(forward_ex_wdata[31:0]),
		  .forward_mem_en	(forward_mem_en),
		  .forward_mem_tag	(forward_mem_tag[TAG_WIDTH-1:0]),
		  .forward_mem_addr	(forward_mem_addr[4:0]),
		  .forward_mem_wdata	(forward_mem_wdata[31:0]),
		  .rf_wr_wb_en		(rf_wr_en),		 // Templated
		  .rf_wr_wb_tag		(rf_wr_tag[TAG_WIDTH-1:0]), // Templated
		  .rf_wr_wb_addr	(rf_wr_addr[4:0]),	 // Templated
		  .rf_wr_wb_data	(rf_wr_data[31:0]),	 // Templated
		  .clr_dirty_ex_en	(clr_dirty_ex_en),
		  .clr_dirty_ex_addr	(clr_dirty_ex_addr[4:0]),
		  .clr_dirty_mem_en	(clr_dirty_mem_en),
		  .clr_dirty_mem_addr	(clr_dirty_mem_addr[4:0]),
		  .clr_dirty_wb_en	(clr_dirty_wb_en),
		  .clr_dirty_wb_addr	(clr_dirty_wb_addr[4:0]));

/* ex_stage AUTO_TEMPLATE(
    .extern_intr	(extern_irq_taken),
	.timer_intr		(timer_irq_taken),
	.software_intr	(soft_irq_taken),

);*/
ex_stage #( /*AUTOINSTPARAM*/
	   // Parameters
	   .ILLEGAL_CSR_EN		(ILLEGAL_CSR_EN))ex_stage( 
/*AUTOINST*/
								  // Interfaces
								  .adder_op_ex		(adder_op_ex),
								  .comp_op_ex		(comp_op_ex),
								  .logic_op_ex		(logic_op_ex),
								  .shift_op_ex		(shift_op_ex),
								  .lsu_op_ex		(lsu_op_ex),
								  .lsu_dtype_ex		(lsu_dtype_ex),
								  .mult_op_ex		(mult_op_ex),
								  .lsu_op_mem		(lsu_op_mem),
								  .lsu_dtype_mem	(lsu_dtype_mem),
								  .mepc_mux		(mepc_mux),
								  .mcause		(mcause),
								  .privilege_mode	(privilege_mode),
								  // Outputs
								  .ready_ex		(ready_ex),
								  .pc_mem		(pc_mem[31:0]),
								  .iretire_mem		(iretire_mem),
								  .jump_target_addr	(jump_target_addr[31:0]),
								  .jump_taken		(jump_taken),
								  .branch_target_addr	(branch_target_addr[31:0]),
								  .branch_taken		(branch_taken),
								  .predict_fail		(predict_fail),
								  .btb_invalid		(btb_invalid),
								  .btb_update		(btb_update),
								  .btb_pc		(btb_pc[31:0]),
								  .btb_target		(btb_target[31:0]),
								  .bht_updata		(bht_updata),
								  .bht_pc		(bht_pc[31:0]),
								  .bht_taken		(bht_taken),
								  .lsu_en_mem		(lsu_en_mem),
								  .lsu_addr_mem		(lsu_addr_mem[31:0]),
								  .lsu_wdata_mem	(lsu_wdata_mem[31:0]),
								  .exc_taken_mem	(exc_taken_mem),
								  .is_illegal_csr	(is_illegal_csr),
								  .rd_wr_en_mem		(rd_wr_en_mem),
								  .rd_wr_tag_mem	(rd_wr_tag_mem[TAG_WIDTH-1:0]),
								  .rd_wr_addr_mem	(rd_wr_addr_mem[4:0]),
								  .rd_wr_data_mem	(rd_wr_data_mem[31:0]),
								  .forward_ex_en	(forward_ex_en),
								  .forward_ex_tag	(forward_ex_tag[TAG_WIDTH-1:0]),
								  .forward_ex_addr	(forward_ex_addr[4:0]),
								  .forward_ex_wdata	(forward_ex_wdata[31:0]),
								  .clr_dirty_ex_en	(clr_dirty_ex_en),
								  .clr_dirty_ex_addr	(clr_dirty_ex_addr[4:0]),
								  .mstatus_mie		(mstatus_mie),
								  .mtvec		(mtvec[31:0]),
								  .mepc			(mepc[31:0]),
								  .mie			(mie[31:0]),
								  // Inputs
								  .clk			(clk),
								  .reset_n		(reset_n),
								  .stall_E		(stall_E),
								  .flush_E		(flush_E),
								  .ready_mem		(ready_mem),
								  .iretire_ex		(iretire_ex),
								  .pc_id		(pc_id[31:0]),
								  .pc_ex		(pc_ex[31:0]),
								  .jalr_ex		(jalr_ex),
								  .jump_ex		(jump_ex),
								  .branch_ex		(branch_ex),
								  .compress_instr_ex	(compress_instr_ex),
								  .predict_taken_ex	(predict_taken_ex),
								  .sign_ex		(sign_ex),
								  .adder_en_ex		(adder_en_ex),
								  .comp_en_ex		(comp_en_ex),
								  .logic_en_ex		(logic_en_ex),
								  .shift_en_ex		(shift_en_ex),
								  .src_a_ex		(src_a_ex[31:0]),
								  .src_b_ex		(src_b_ex[31:0]),
								  .src_c_ex		(src_c_ex[31:0]),
								  .lsu_en_ex		(lsu_en_ex),
								  .mult_en_ex		(mult_en_ex),
								  .csr_en_ex		(csr_en_ex),
								  .csr_op_ex		(csr_op_ex[1:0]),
								  .csr_addr_ex		(csr_addr_ex[11:0]),
								  .csr_wdata_ex		(csr_wdata_ex[31:0]),
								  .rd_wr_en_ex		(rd_wr_en_ex),
								  .rd_wr_tag_ex		(rd_wr_tag_ex[TAG_WIDTH-1:0]),
								  .rd_wr_addr_ex	(rd_wr_addr_ex[4:0]),
								  .exc_taken_ex		(exc_taken_ex),
								  .pc_wb		(pc_wb[31:0]),
								  .pc_if		(pc_if[31:0]),
								  .extern_intr		(extern_irq_taken), // Templated
								  .timer_intr		(timer_irq_taken), // Templated
								  .software_intr	(soft_irq_taken), // Templated
								  .hart_id		(hart_id[31:0]),
								  .is_mret		(is_mret),
								  .mepc_updata		(mepc_updata),
								  .mcause_update	(mcause_update));

/*mem_stage AUTO_TEMPLATE(
);*/
mem_stage mem_stage(
    /*AUTOINST*/
		    // Interfaces
		    .lsu_op_mem		(lsu_op_mem),
		    .lsu_dtype_mem	(lsu_dtype_mem),
		    .lsu_op_wb		(lsu_op_wb),
		    // Outputs
		    .ready_mem		(ready_mem),
		    .forward_mem_en	(forward_mem_en),
		    .forward_mem_tag	(forward_mem_tag[TAG_WIDTH-1:0]),
		    .forward_mem_addr	(forward_mem_addr[4:0]),
		    .forward_mem_wdata	(forward_mem_wdata[31:0]),
		    .clr_dirty_mem_en	(clr_dirty_mem_en),
		    .clr_dirty_mem_addr	(clr_dirty_mem_addr[4:0]),
		    .rd_wr_en_wb	(rd_wr_en_wb),
		    .rd_wr_tag_wb	(rd_wr_tag_wb[TAG_WIDTH-1:0]),
		    .rd_wr_addr_wb	(rd_wr_addr_wb[4:0]),
		    .rd_wr_data_wb	(rd_wr_data_wb[31:0]),
		    .lsu_en_wb		(lsu_en_wb),
		    .lsu_rdata_wb	(lsu_rdata_wb[31:0]),
		    .lsu_valid_wb	(lsu_valid_wb),
		    .lsu_err_wb		(lsu_err_wb),
		    .exc_taken_wb	(exc_taken_wb),
		    .pc_wb		(pc_wb[31:0]),
		    .iretire_wb		(iretire_wb),
		    .data_req		(data_req),
		    .data_wr		(data_wr),
		    .data_addr		(data_addr[31:0]),
		    .data_wdata		(data_wdata[31:0]),
		    .data_be		(data_be[3:0]),
		    // Inputs
		    .clk		(clk),
		    .reset_n		(reset_n),
		    .iretire_mem	(iretire_mem),
		    .pc_mem		(pc_mem[31:0]),
		    .rd_wr_en_mem	(rd_wr_en_mem),
		    .rd_wr_tag_mem	(rd_wr_tag_mem[TAG_WIDTH-1:0]),
		    .rd_wr_addr_mem	(rd_wr_addr_mem[4:0]),
		    .rd_wr_data_mem	(rd_wr_data_mem[31:0]),
		    .lsu_en_mem		(lsu_en_mem),
		    .lsu_addr_mem	(lsu_addr_mem[31:0]),
		    .lsu_wdata_mem	(lsu_wdata_mem[31:0]),
		    .exc_taken_mem	(exc_taken_mem),
		    .flush_M		(flush_M),
		    .ready_wb		(ready_wb),
		    .data_gnt		(data_gnt),
		    .data_rdata		(data_rdata[31:0]),
		    .data_valid		(data_valid),
		    .data_error		(data_error));

wb_stage wb_stage(
    /*AUTOINST*/
		  // Interfaces
		  .lsu_op_wb		(lsu_op_wb),
		  // Outputs
		  .ready_wb		(ready_wb),
		  .clr_dirty_wb_en	(clr_dirty_wb_en),
		  .clr_dirty_wb_addr	(clr_dirty_wb_addr[4:0]),
		  .rf_wr_en		(rf_wr_en),
		  .rf_wr_tag		(rf_wr_tag[TAG_WIDTH-1:0]),
		  .rf_wr_addr		(rf_wr_addr[4:0]),
		  .rf_wr_data		(rf_wr_data[31:0]),
		  .is_lsu_load_err	(is_lsu_load_err),
		  .is_lsu_store_err	(is_lsu_store_err),
		  .exc_taken		(exc_taken),
		  // Inputs
		  .clk			(clk),
		  .reset_n		(reset_n),
		  .pc_wb		(pc_wb[31:0]),
		  .rd_wr_en_wb		(rd_wr_en_wb),
		  .rd_wr_tag_wb		(rd_wr_tag_wb[TAG_WIDTH-1:0]),
		  .rd_wr_addr_wb	(rd_wr_addr_wb[4:0]),
		  .rd_wr_data_wb	(rd_wr_data_wb[31:0]),
		  .lsu_en_wb		(lsu_en_wb),
		  .lsu_rdata_wb		(lsu_rdata_wb[31:0]),
		  .lsu_valid_wb		(lsu_valid_wb),
		  .lsu_err_wb		(lsu_err_wb),
		  .exc_taken_wb		(exc_taken_wb),
		  .flush_W		(flush_W));

/*controller AUTO_TEMPLATE(
);*/
controller controller(/*AUTOINST*/
		      // Interfaces
		      .privilege_mode	(privilege_mode),
		      .mcause		(mcause),
		      .mepc_mux		(mepc_mux),
		      // Outputs
		      .set_pc_valid	(set_pc_valid),
		      .set_pc		(set_pc[31:0]),
		      .fetch_enable	(fetch_enable),
		      .irq_ack		(irq_ack),
		      .mcause_update	(mcause_update),
		      .mepc_updata	(mepc_updata),
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
		      // Inputs
		      .clk		(clk),
		      .reset_n		(reset_n),
		      .jump_taken	(jump_taken),
		      .branch_taken	(branch_taken),
		      .jump_target_addr	(jump_target_addr[31:0]),
		      .branch_target_addr(branch_target_addr[31:0]),
		      .pc_if		(pc_if[31:0]),
		      .pc_id		(pc_id[31:0]),
		      .pc_ex		(pc_ex[31:0]),
		      .pc_mem		(pc_mem[31:0]),
		      .pc_wb		(pc_wb[31:0]),
		      .extern_irq_taken	(extern_irq_taken),
		      .soft_irq_taken	(soft_irq_taken),
		      .timer_irq_taken	(timer_irq_taken),
		      .exc_taken	(exc_taken),
		      .is_mret		(is_mret),
		      .is_ecall		(is_ecall),
		      .is_ebreak	(is_ebreak),
		      .is_fence		(is_fence),
		      .is_illegal_instr	(is_illegal_instr),
		      .is_instr_acs_fault(is_instr_acs_fault),
		      .is_interrupt	(is_interrupt),
		      .is_wfi		(is_wfi),
		      .is_illegal_csr	(is_illegal_csr),
		      .is_lsu_load_err	(is_lsu_load_err),
		      .is_lsu_store_err	(is_lsu_store_err),
		      .mepc		(mepc[31:0]),
		      .mtvec		(mtvec[31:0]));


/*plic AUTO_TEMPLATE(
);
*/
plic plic(
    /*AUTOINST*/
	  // Outputs
	  .extern_irq_taken		(extern_irq_taken),
	  .soft_irq_taken		(soft_irq_taken),
	  .timer_irq_taken		(timer_irq_taken),
	  // Inputs
	  .clk				(clk),
	  .reset_n			(reset_n),
	  .extern_irq			(extern_irq),
	  .soft_irq			(soft_irq),
	  .timer_irq			(timer_irq),
	  .is_mret			(is_mret),
	  .mstatus_mie			(mstatus_mie),
	  .mie				(mie[31:0]),
	  .irq_ack			(irq_ack)); 

endmodule
