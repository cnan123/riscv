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
logic			branch_taken;		// From ex_stage of ex_stage.v
logic [31:0]		branch_target_addr;	// From ex_stage of ex_stage.v
logic [ALU_NUM-1:0]	ex_alu_op;		// From id_stage of id_stage.v
logic [31:0]		ex_alu_operate_a;	// From id_stage of id_stage.v
logic [31:0]		ex_alu_operate_b;	// From id_stage of id_stage.v
logic [31:0]		ex_alu_operate_c;	// From id_stage of id_stage.v
logic [4:0]		ex_dest_addr;		// From id_stage of id_stage.v
logic [4:0]		ex_dest_we_addr;	// From ex_stage of ex_stage.v
logic [31:0]		ex_dest_we_data;	// From ex_stage of ex_stage.v
logic			ex_dest_we_valid;	// From ex_stage of ex_stage.v
logic			ex_jump;		// From id_stage of id_stage.v
logic			ex_lsu_valid;		// From id_stage of id_stage.v
logic [2:0]		ex_lsu_width_type;	// From id_stage of id_stage.v
logic			ex_lsu_wr_type;		// From id_stage of id_stage.v
logic			ex_stage_ready;		// From ex_stage of ex_stage.v
logic			flush_id;		// From controller of controller.v
logic			flush_if;		// From controller of controller.v
logic [4:0]		id_reg_ch0_addr;	// From id_stage of id_stage.v
logic [31:0]		id_reg_ch0_data;	// From data_bypass of data_bypass.v
logic			id_reg_ch0_rd;		// From id_stage of id_stage.v
logic [4:0]		id_reg_ch1_addr;	// From id_stage of id_stage.v
logic [31:0]		id_reg_ch1_data;	// From data_bypass of data_bypass.v
logic			id_reg_ch1_rd;		// From id_stage of id_stage.v
logic [31:0]		instruction;		// From if_stage of if_stage.v
logic			instruction_value;	// From if_stage of if_stage.v
logic			is_compress_intr;	// From if_stage of if_stage.v
logic [31:0]		jump_target_addr;	// From ex_stage of ex_stage.v
logic			load_instr_in_ex;	// From ex_stage of ex_stage.v
logic			load_instr_in_mem;	// From mem_stage of mem_stage.v
logic [4:0]		mem_dest_we_addr;	// From ex_stage of ex_stage.v
logic [31:0]		mem_dest_we_data;	// From ex_stage of ex_stage.v
logic			mem_dest_we_valid;	// From ex_stage of ex_stage.v
logic [31:0]		mem_lsu_addr;		// From ex_stage of ex_stage.v
logic			mem_lsu_valid;		// From ex_stage of ex_stage.v
logic [31:0]		mem_lsu_wdata;		// From ex_stage of ex_stage.v
logic [2:0]		mem_lsu_width_type;	// From ex_stage of ex_stage.v
logic			mem_lsu_wr_type;	// From ex_stage of ex_stage.v
logic			mem_stage_ready;	// From mem_stage of mem_stage.v
logic [31:0]		pc_ex;			// From ex_stage of ex_stage.v
logic [31:0]		pc_id;			// From id_stage of id_stage.v
logic [31:0]		pc_if;			// From if_stage of if_stage.v
logic [4:0]		rd_ch0_addr;		// From data_bypass of data_bypass.v
logic [31:0]		rd_ch0_data;		// From register_file of register_file.v
logic			rd_ch0_en;		// From data_bypass of data_bypass.v
logic [4:0]		rd_ch1_addr;		// From data_bypass of data_bypass.v
logic [31:0]		rd_ch1_data;		// From register_file of register_file.v
logic			rd_ch1_en;		// From data_bypass of data_bypass.v
logic			set_pc_valid;		// From controller of controller.v
logic			stall_ex_stage;		// From controller of controller.v
logic			stall_id_stage;		// From controller of controller.v
logic			stall_if_stage;		// From controller of controller.v
logic			stall_mem_stage;	// From controller of controller.v
logic			wb_stage_ready;		// From mem_stage of mem_stage.v
logic [4:0]		wb_we_addr;		// From mem_stage of mem_stage.v
logic [31:0]		wb_we_data;		// From mem_stage of mem_stage.v
logic			wb_we_valid;		// From mem_stage of mem_stage.v
// End of automatics
//////////////////////////////////////////////

logic [31:0]    set_pc;

//////////////////////////////////////////////
//main code

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
		  .id_instruction	(instruction[31:0]),	 // Templated
		  .id_instruction_value	(instruction_value),	 // Templated
		  .is_compress_intr	(is_compress_intr),
		  .instr_req		(instr_req),
		  .instr_addr		(instr_addr[31:0]),
		  // Inputs
		  .clk			(clk),
		  .reset_n		(reset_n),
		  .boot_addr		(boot_addr[31:0]),
		  .fetch_enable		(fetch_enable),
		  .flush_if_id		(flush_if),		 // Templated
		  .stall_if_stage	(stall_if_stage),
		  .set_pc_valid		(set_pc_valid),
		  .set_pc		(set_pc[31:0]),
		  .instr_gnt		(instr_gnt),
		  .instr_rdata		(instr_rdata[31:0]),
		  .instr_err		(instr_err),
		  .instr_valid		(instr_valid));

/* id_stage AUTO_TEMPLATE(
    .register_\(.*\)     (id_reg_\1[]),
		  .flush_if_id		(flush_id),
    .id_stage_ready     (id_stage_ready),
);
*/
id_stage id_stage(
    /*AUTOINST*/
		  // Outputs
		  .register_ch0_rd	(id_reg_ch0_rd),	 // Templated
		  .register_ch0_addr	(id_reg_ch0_addr[4:0]),	 // Templated
		  .register_ch1_rd	(id_reg_ch1_rd),	 // Templated
		  .register_ch1_addr	(id_reg_ch1_addr[4:0]),	 // Templated
		  .ex_alu_op		(ex_alu_op[ALU_NUM-1:0]),
		  .ex_alu_operate_a	(ex_alu_operate_a[31:0]),
		  .ex_alu_operate_b	(ex_alu_operate_b[31:0]),
		  .ex_alu_operate_c	(ex_alu_operate_c[31:0]),
		  .ex_jump		(ex_jump),
		  .ex_dest_addr		(ex_dest_addr[4:0]),
		  .ex_lsu_valid		(ex_lsu_valid),
		  .ex_lsu_wr_type	(ex_lsu_wr_type),
		  .ex_lsu_width_type	(ex_lsu_width_type[2:0]),
		  .pc_id		(pc_id[31:0]),
		  // Inputs
		  .clk			(clk),
		  .reset_n		(reset_n),
		  .pc_if		(pc_if[31:0]),
		  .is_compress_instr	(is_compress_instr),
		  .instruction		(instruction[31:0]),
		  .instruction_value	(instruction_value),
		  .flush_if_id		(flush_id),		 // Templated
		  .stall_id_stage	(stall_id_stage),
		  .register_ch0_data	(id_reg_ch0_data[31:0]), // Templated
		  .register_ch1_data	(id_reg_ch1_data[31:0])); // Templated

/* ex_stage AUTO_TEMPLATE(
    .alu_operator   (ex_alu_op[]),
    .alu_operate_a  (ex_alu_operate_a[]),
    .alu_operate_b  (ex_alu_operate_b[]),
    .alu_operate_c  (ex_alu_operate_c[]),
    .jump           (ex_jump),
	.branch_op		(ex_branch_op[]),
	.branch_offset	(ex_branch_offset[]),
    .ex_dest_addr   (ex_dest_addr[]),
   );*/
ex_stage ex_stage(
    /*AUTOINST*/
		  // Outputs
		  .ex_stage_ready	(ex_stage_ready),
		  .load_instr_in_ex	(load_instr_in_ex),
		  .pc_ex		(pc_ex[31:0]),
		  .ex_dest_we_valid	(ex_dest_we_valid),
		  .ex_dest_we_addr	(ex_dest_we_addr[4:0]),
		  .ex_dest_we_data	(ex_dest_we_data[31:0]),
		  .mem_dest_we_valid	(mem_dest_we_valid),
		  .mem_dest_we_addr	(mem_dest_we_addr[4:0]),
		  .mem_dest_we_data	(mem_dest_we_data[31:0]),
		  .branch_taken		(branch_taken),
		  .branch_target_addr	(branch_target_addr[31:0]),
		  .jump_target_addr	(jump_target_addr[31:0]),
		  .mem_lsu_valid	(mem_lsu_valid),
		  .mem_lsu_wr_type	(mem_lsu_wr_type),
		  .mem_lsu_width_type	(mem_lsu_width_type[2:0]),
		  .mem_lsu_addr		(mem_lsu_addr[31:0]),
		  .mem_lsu_wdata	(mem_lsu_wdata[31:0]),
		  // Inputs
		  .clk			(clk),
		  .reset_n		(reset_n),
		  .stall_ex_stage	(stall_ex_stage),
		  .pc_id		(pc_id[31:0]),
		  .alu_operator		(ex_alu_op[ALU_NUM-1:0]), // Templated
		  .alu_operate_a	(ex_alu_operate_a[31:0]), // Templated
		  .alu_operate_b	(ex_alu_operate_b[31:0]), // Templated
		  .alu_operate_c	(ex_alu_operate_c[31:0]), // Templated
		  .jump			(ex_jump),		 // Templated
		  .ex_dest_addr		(ex_dest_addr[4:0]),	 // Templated
		  .ex_lsu_valid		(ex_lsu_valid),
		  .ex_lsu_wr_type	(ex_lsu_wr_type),
		  .ex_lsu_width_type	(ex_lsu_width_type[2:0]));

/*mem_stage AUTO_TEMPLATE(
            .lsu_valid		(mem_lsu_valid),
		    .lsu_wr_type	(mem_lsu_wr_type),
		    .lsu_width_type	(mem_lsu_width_type[1:0]),
		    .lsu_addr		(mem_lsu_addr[31:0]),
		    .lsu_wdata		(mem_lsu_wdata[31:0]),
            .data_be		(data_byteen[3:0]),
);*/
mem_stage mem_stage(
    /*AUTOINST*/
		    // Outputs
		    .wb_we_valid	(wb_we_valid),
		    .wb_we_addr		(wb_we_addr[4:0]),
		    .wb_we_data		(wb_we_data[31:0]),
		    .mem_stage_ready	(mem_stage_ready),
		    .wb_stage_ready	(wb_stage_ready),
		    .load_instr_in_mem	(load_instr_in_mem),
		    .data_req		(data_req),
		    .data_wr		(data_wr),
		    .data_addr		(data_addr[31:0]),
		    .data_wdata		(data_wdata[31:0]),
		    .data_be		(data_byteen[3:0]),	 // Templated
		    // Inputs
		    .clk		(clk),
		    .reset_n		(reset_n),
		    .mem_dest_we_valid	(mem_dest_we_valid),
		    .mem_dest_we_addr	(mem_dest_we_addr[4:0]),
		    .mem_dest_we_data	(mem_dest_we_data[31:0]),
		    .lsu_valid		(mem_lsu_valid),	 // Templated
		    .lsu_wr_type	(mem_lsu_wr_type),	 // Templated
		    .lsu_width_type	(mem_lsu_width_type[1:0]), // Templated
		    .lsu_addr		(mem_lsu_addr[31:0]),	 // Templated
		    .lsu_wdata		(mem_lsu_wdata[31:0]),	 // Templated
		    .stall_mem_stage	(stall_mem_stage),
		    .data_gnt		(data_gnt),
		    .data_rdata		(data_rdata[31:0]),
		    .data_valid		(data_valid));

/*register_file AUTO_TEMPLATE (
    .wr_ch0_en  (wb_we_valid[]),
    .wr_ch0_addr (wb_we_addr[]),
    .wr_ch0_data    (wb_we_data[]),
);*/
register_file register_file(
    /*AUTOINST*/
			    // Outputs
			    .rd_ch0_data	(rd_ch0_data[31:0]),
			    .rd_ch1_data	(rd_ch1_data[31:0]),
			    // Inputs
			    .clk		(clk),
			    .reset_n		(reset_n),
			    .rd_ch0_en		(rd_ch0_en),
			    .rd_ch0_addr	(rd_ch0_addr[4:0]),
			    .rd_ch1_en		(rd_ch1_en),
			    .rd_ch1_addr	(rd_ch1_addr[4:0]),
			    .wr_ch0_en		(wb_we_valid),	 // Templated
			    .wr_ch0_addr	(wb_we_addr[4:0]), // Templated
			    .wr_ch0_data	(wb_we_data[31:0])); // Templated

/*data_bypass AUTO_TEMPLATE(
    .register_\(.*\)     (\1[]),
    .wb_dest_\(.*\)         (wb_\1[]),
);*/
data_bypass data_bypass(
    /*AUTOINST*/
			// Outputs
			.id_reg_ch0_data(id_reg_ch0_data[31:0]),
			.id_reg_ch1_data(id_reg_ch1_data[31:0]),
			.register_rd_ch0_en(rd_ch0_en),		 // Templated
			.register_rd_ch0_addr(rd_ch0_addr[4:0]), // Templated
			.register_rd_ch1_en(rd_ch1_en),		 // Templated
			.register_rd_ch1_addr(rd_ch1_addr[4:0]), // Templated
			// Inputs
			.clk		(clk),
			.reset_n	(reset_n),
			.id_reg_ch0_rd	(id_reg_ch0_rd),
			.id_reg_ch0_addr(id_reg_ch0_addr[4:0]),
			.id_reg_ch1_rd	(id_reg_ch1_rd),
			.id_reg_ch1_addr(id_reg_ch1_addr[4:0]),
			.ex_dest_we_valid(ex_dest_we_valid),
			.ex_dest_we_addr(ex_dest_we_addr[4:0]),
			.ex_dest_we_data(ex_dest_we_data[31:0]),
			.mem_dest_we_valid(mem_dest_we_valid),
			.mem_dest_we_addr(mem_dest_we_addr[4:0]),
			.mem_dest_we_data(mem_dest_we_data[31:0]),
			.wb_dest_we_valid(wb_we_valid),		 // Templated
			.wb_dest_we_addr(wb_we_addr[4:0]),	 // Templated
			.wb_dest_we_data(wb_we_data[31:0]),	 // Templated
			.register_rd_ch0_data(rd_ch0_data[31:0]), // Templated
			.register_rd_ch1_data(rd_ch1_data[31:0])); // Templated


/*controller AUTO_TEMPLATE(
    .clk (clk),
    .jump   (ex_jump),
    .read_a_in_id	(id_reg_ch0_rd),
	.read_a_addr	(id_reg_ch0_addr[]),
	.read_b_in_id	(id_reg_ch1_rd),
	.read_b_addr	(id_reg_ch1_addr[]),
);*/
controller controller(/*AUTOINST*/
		      // Outputs
		      .set_pc_valid	(set_pc_valid),
		      .set_pc		(set_pc[31:0]),
		      .stall_if_stage	(stall_if_stage),
		      .stall_id_stage	(stall_id_stage),
		      .stall_ex_stage	(stall_ex_stage),
		      .stall_mem_stage	(stall_mem_stage),
		      .flush_if		(flush_if),
		      .flush_id		(flush_id),
		      // Inputs
		      .clk		(clk),			 // Templated
		      .reset_n		(reset_n),
		      .read_a_in_id	(id_reg_ch0_rd),	 // Templated
		      .read_a_addr	(id_reg_ch0_addr[4:0]),	 // Templated
		      .read_b_in_id	(id_reg_ch1_rd),	 // Templated
		      .read_b_addr	(id_reg_ch1_addr[4:0]),	 // Templated
		      .load_instr_in_ex	(load_instr_in_ex),
		      .ex_dest_we_addr	(ex_dest_we_addr[4:0]),
		      .load_instr_in_mem(load_instr_in_mem),
		      .mem_dest_we_addr	(mem_dest_we_addr[4:0]),
		      .jump		(ex_jump),		 // Templated
		      .jump_target_addr	(jump_target_addr[31:0]),
		      .branch_taken	(branch_taken),
		      .branch_target_addr(branch_target_addr[31:0]),
		      .ex_stage_ready	(ex_stage_ready),
		      .mem_stage_ready	(mem_stage_ready),
		      .wb_stage_ready	(wb_stage_ready));


//TODO


endmodule
