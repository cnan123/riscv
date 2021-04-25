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
logic			ex_busy;		// From ex_stage of ex_stage.v
logic [31:0]		ex_dest_data;		// From ex_stage of ex_stage.v
logic			ex_dest_valid;		// From ex_stage of ex_stage.v
logic			flush;			// From controller of controller.v
logic [4:0]		id_reg_ch0_addr;	// From id_stage of id_stage.v
logic [31:0]		id_reg_ch0_data;	// From data_bypass of data_bypass.v
logic			id_reg_ch0_rd;		// From id_stage of id_stage.v
logic [4:0]		id_reg_ch1_addr;	// From id_stage of id_stage.v
logic [31:0]		id_reg_ch1_data;	// From data_bypass of data_bypass.v
logic			id_reg_ch1_rd;		// From id_stage of id_stage.v
logic			id_stage_ready;		// From id_stage of id_stage.v
logic			id_valid;		// From id_stage of id_stage.v
logic [31:0]		instruction;		// From if_stage of if_stage.v
logic			instruction_value;	// From if_stage of if_stage.v
logic			is_compress_intr;	// From if_stage of if_stage.v
logic [31:0]		jump_target_addr;	// From ex_stage of ex_stage.v
logic			mem_busy;		// From mem_stage of mem_stage.v
logic [4:0]		mem_dest_addr;		// From ex_stage of ex_stage.v
logic [31:0]		mem_dest_data;		// From ex_stage of ex_stage.v
logic			mem_dest_valid;		// From ex_stage of ex_stage.v
logic [31:0]		mem_stage_addr;		// From ex_stage of ex_stage.v
logic [2:0]		mem_stage_type;		// From ex_stage of ex_stage.v
logic			mem_stage_valid;	// From ex_stage of ex_stage.v
logic [31:0]		mem_stage_wdata;	// From ex_stage of ex_stage.v
logic [31:0]		pc_ex;			// From ex_stage of ex_stage.v
logic [31:0]		pc_id;			// From id_stage of id_stage.v
logic [31:0]		pc_if;			// From if_stage of if_stage.v
logic [8:0]		pipe_alu_op;		// From id_stage of id_stage.v
logic [31:0]		pipe_alu_operate_a;	// From id_stage of id_stage.v
logic [31:0]		pipe_alu_operate_b;	// From id_stage of id_stage.v
logic [31:0]		pipe_branch_offset;	// From id_stage of id_stage.v
logic [5:0]		pipe_branch_op;		// From id_stage of id_stage.v
logic [4:0]		pipe_dest_addr;		// From id_stage of id_stage.v
logic			pipe_jump;		// From id_stage of id_stage.v
logic [3:0]		pipe_lsu_op;		// From id_stage of id_stage.v
logic [31:0]		pipe_lsu_wdata;		// From id_stage of id_stage.v
logic [4:0]		rd_ch0_addr;		// From data_bypass of data_bypass.v
logic [31:0]		rd_ch0_data;		// From register_file of register_file.v
logic			rd_ch0_en;		// From data_bypass of data_bypass.v
logic [4:0]		rd_ch1_addr;		// From data_bypass of data_bypass.v
logic [31:0]		rd_ch1_data;		// From register_file of register_file.v
logic			rd_ch1_en;		// From data_bypass of data_bypass.v
logic			set_pc_valid;		// From controller of controller.v
logic			stall_id;		// From controller of controller.v
logic			stall_if;		// From controller of controller.v
logic [4:0]		wb_addr;		// From mem_stage of mem_stage.v
logic [31:0]		wb_data;		// From mem_stage of mem_stage.v
logic			wb_valid;		// From mem_stage of mem_stage.v
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
);
*/
if_stage if_stage(
    /*AUTOINST*/
		  // Outputs
		  .pc_if		(pc_if[31:0]),
		  .instruction		(instruction[31:0]),
		  .instruction_value	(instruction_value),
		  .is_compress_intr	(is_compress_intr),
		  .instr_req		(instr_req),
		  .instr_addr		(instr_addr[31:0]),
		  // Inputs
		  .clk			(clk),
		  .reset_n		(reset_n),
		  .boot_addr		(boot_addr[31:0]),
		  .fetch_enable		(fetch_enable),
		  .flush		(flush),
		  .set_pc_valid		(set_pc_valid),
		  .set_pc		(set_pc[31:0]),
		  .pc_id_ready		(id_stage_ready),	 // Templated
		  .instr_gnt		(instr_gnt),
		  .instr_rdata		(instr_rdata[31:0]),
		  .instr_err		(instr_err),
		  .instr_valid		(instr_valid));

/* id_stage AUTO_TEMPLATE(
    .register_\(.*\)     (id_reg_\1[]),
    .id_stage_ready     (id_stage_ready),
);
*/
id_stage id_stage(
    /*AUTOINST*/
		  // Outputs
		  .id_stage_ready	(id_stage_ready),	 // Templated
		  .register_ch0_rd	(id_reg_ch0_rd),	 // Templated
		  .register_ch0_addr	(id_reg_ch0_addr[4:0]),	 // Templated
		  .register_ch1_rd	(id_reg_ch1_rd),	 // Templated
		  .register_ch1_addr	(id_reg_ch1_addr[4:0]),	 // Templated
		  .pipe_alu_op		(pipe_alu_op[8:0]),
		  .pipe_alu_operate_a	(pipe_alu_operate_a[31:0]),
		  .pipe_alu_operate_b	(pipe_alu_operate_b[31:0]),
		  .pipe_branch_op	(pipe_branch_op[5:0]),
		  .pipe_branch_offset	(pipe_branch_offset[31:0]),
		  .pipe_jump		(pipe_jump),
		  .pipe_dest_addr	(pipe_dest_addr[4:0]),
		  .pipe_lsu_op		(pipe_lsu_op[3:0]),
		  .pipe_lsu_wdata	(pipe_lsu_wdata[31:0]),
		  .pc_id		(pc_id[31:0]),
		  .id_valid		(id_valid),
		  // Inputs
		  .clk			(clk),
		  .reset_n		(reset_n),
		  .pc_if		(pc_if[31:0]),
		  .is_compress_intr	(is_compress_intr),
		  .instruction		(instruction[31:0]),
		  .instruction_value	(instruction_value),
		  .stall_id		(stall_id),
		  .flush		(flush),
		  .register_ch0_data	(id_reg_ch0_data[31:0]), // Templated
		  .register_ch1_data	(id_reg_ch1_data[31:0])); // Templated

/* ex_stage AUTO_TEMPLATE(
    .alu_operator   (pipe_alu_op[]),
    .alu_operate_a  (pipe_alu_operate_a[]),
    .alu_operate_b  (pipe_alu_operate_b[]),
    .jump           (pipe_jump),
	.branch_op		(pipe_branch_op[]),
	.branch_offset	(pipe_branch_offset),
    .ex_dest_addr   (pipe_dest_addr[]),
    .stall_id_stage (ex_stall_id_stage),
		  .lsu_op		(pipe_lsu_op[3:0]),
		  .lsu_wdata		(pipe_lsu_wdata[31:0]));
);*/
ex_stage ex_stage(
    /*AUTOINST*/
		  // Outputs
		  .pc_ex		(pc_ex[31:0]),
		  .ex_dest_valid	(ex_dest_valid),
		  .ex_dest_data		(ex_dest_data[31:0]),
		  .ex_busy		(ex_busy),
		  .mem_dest_valid	(mem_dest_valid),
		  .mem_dest_addr	(mem_dest_addr[4:0]),
		  .mem_dest_data	(mem_dest_data[31:0]),
		  .branch_taken		(branch_taken),
		  .branch_target_addr	(branch_target_addr[31:0]),
		  .jump_target_addr	(jump_target_addr[31:0]),
		  .mem_stage_valid	(mem_stage_valid),
		  .mem_stage_type	(mem_stage_type[2:0]),
		  .mem_stage_addr	(mem_stage_addr[31:0]),
		  .mem_stage_wdata	(mem_stage_wdata[31:0]),
		  // Inputs
		  .clk			(clk),
		  .reset_n		(reset_n),
		  .ex_stall		(ex_stall),
		  .flush		(flush),
		  .pc_id		(pc_id[31:0]),
		  .ex_dest_addr		(pipe_dest_addr[4:0]),	 // Templated
		  .id_valid		(id_valid),
		  .alu_operator		(pipe_alu_op[8:0]),	 // Templated
		  .alu_operate_a	(pipe_alu_operate_a[31:0]), // Templated
		  .alu_operate_b	(pipe_alu_operate_b[31:0]), // Templated
		  .branch_op		(pipe_branch_op[5:0]),	 // Templated
		  .branch_offset	(pipe_branch_offset),	 // Templated
		  .jump			(pipe_jump),		 // Templated
		  .lsu_op		(pipe_lsu_op[3:0]),	 // Templated
		  .lsu_wdata		(pipe_lsu_wdata[31:0]));	 // Templated

mem_stage mem_stage(
    /*AUTOINST*/
		    // Outputs
		    .wb_valid		(wb_valid),
		    .wb_addr		(wb_addr[4:0]),
		    .wb_data		(wb_data[31:0]),
		    .mem_busy		(mem_busy),
		    .data_req		(data_req),
		    .data_wr		(data_wr),
		    .data_addr		(data_addr[31:0]),
		    .data_wdata		(data_wdata[31:0]),
		    .data_byteen	(data_byteen[3:0]),
		    // Inputs
		    .clk		(clk),
		    .reset_n		(reset_n),
		    .mem_dest_valid	(mem_dest_valid),
		    .mem_dest_addr	(mem_dest_addr[4:0]),
		    .mem_dest_data	(mem_dest_data[31:0]),
		    .mem_stage_valid	(mem_stage_valid),
		    .mem_stage_type	(mem_stage_type[1:0]),
		    .mem_stage_addr	(mem_stage_addr[31:0]),
		    .mem_stage_wdata	(mem_stage_wdata[31:0]),
		    .data_gnt		(data_gnt),
		    .data_rdata		(data_rdata[31:0]),
		    .data_valid		(data_valid));

/*register_file AUTO_TEMPLATE (
    .wr_ch0_en  (wb_valid[]),
    .wr_ch0_addr (wb_addr[]),
    .wr_ch0_data    (wb_data[]),
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
			    .wr_ch0_en		(wb_valid),	 // Templated
			    .wr_ch0_addr	(wb_addr[4:0]),	 // Templated
			    .wr_ch0_data	(wb_data[31:0])); // Templated

/*data_bypass AUTO_TEMPLATE(
    .register_\(.*\)     (\1[]),
    .wb_dest_\(.*\)         (wb_\1[]),
    .ex_dest_addr       (pipe_dest_addr[]),
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
			.ex_dest_valid	(ex_dest_valid),
			.ex_dest_addr	(pipe_dest_addr[4:0]),	 // Templated
			.ex_dest_data	(ex_dest_data[31:0]),
			.mem_dest_valid	(mem_dest_valid),
			.mem_dest_addr	(mem_dest_addr[4:0]),
			.mem_dest_data	(mem_dest_data[31:0]),
			.wb_dest_valid	(wb_valid),		 // Templated
			.wb_dest_addr	(wb_addr[4:0]),		 // Templated
			.wb_dest_data	(wb_data[31:0]),	 // Templated
			.register_rd_ch0_data(rd_ch0_data[31:0]), // Templated
			.register_rd_ch1_data(rd_ch1_data[31:0])); // Templated


/*controller AUTO_TEMPLATE(
    .clk (clk),
    .jump   (pipe_jump),
);*/
controller controller(/*AUTOINST*/
		      // Outputs
		      .set_pc_valid	(set_pc_valid),
		      .set_pc		(set_pc[31:0]),
		      .stall_id		(stall_id),
		      .stall_if		(stall_if),
		      .flush		(flush),
		      // Inputs
		      .clk		(clk),			 // Templated
		      .reset_n		(reset_n),
		      .ex_busy		(ex_busy),
		      .jump		(pipe_jump),		 // Templated
		      .jump_target_addr	(jump_target_addr[31:0]),
		      .branch_taken	(branch_taken),
		      .branch_target_addr(branch_target_addr[31:0]));


//TODO


endmodule
