//================================================================
//   Copyright (C) 2021 Sangfor Ltd. All rights reserved.
//
//   Filename     : tb.v
//   Auther       : cnan
//   Created On   : 2021年04月17日
//   Description  : 
//
//
//================================================================

module tb(/*AUTOARG*/);

// Local Variables:
// verilog-library-directories:("." )
// End:

//////////////////////////////////////////////
/*AUTOLOGIC*/
// Beginning of automatic wires (for undeclared instantiated-module outputs)
logic [31:0]		data_addr;		// From riscv_core of riscv_core.v
logic [3:0]		data_be;		// From riscv_core of riscv_core.v
logic			data_req;		// From riscv_core of riscv_core.v
logic [31:0]		data_wdata;		// From riscv_core of riscv_core.v
logic			data_wr;		// From riscv_core of riscv_core.v
logic [31:0]		instr_addr;		// From riscv_core of riscv_core.v
logic			instr_req;		// From riscv_core of riscv_core.v
// End of automatics
//////////////////////////////////////////////
logic clk;
logic reset_n;
logic [31:0] boot_addr;
logic [31:0]    hart_id;
logic           instr_gnt;
logic [31:0]    instr_rdata;
logic           instr_err;
logic           instr_valid;
logic           data_gnt;
logic [31:0]    data_rdata;
logic           data_valid;
logic           data_error;

logic           extern_irq;
logic           soft_irq;
logic           timer_irq;

logic           debug_req;

//////////////////////////////////////////////
//main code

initial begin
    clk     = 0;
    reset_n = 0;

    #100;
    reset_n = 1;

    #10000;
   // $finish;
end

always #1 clk<=~clk;

initial begin
    `ifdef FSDB
        $fsdbDumpfile("verilog.fsdb");
        $fsdbDumpvars("+all");
        $fsdbDumpvars("+struct");
        $fsdbDumpvars("+mda");
        $fsdbDumpvars("+packedmda");
        $fsdbDumpvars("+parameter");

        $fsdbDumpMDA();
    `endif
end

`define PATH_IRAM_MEM tb.tb_memory.iram
`define PATH_DRAM_MEM tb.tb_memory.dram
initial begin
    $readmemh("./program_instr.dat",`PATH_IRAM_MEM.MEM);
    $readmemh("./program_data.dat",`PATH_DRAM_MEM.MEM);
end

assign boot_addr = 32'h0;
assign hart_id = 32'h0;
assign data_error = 1'b0;
assign debug_req = 1'b0;

riscv_core riscv_core(/*AUTOINST*/
		      // Outputs
		      .instr_req	(instr_req),
		      .instr_addr	(instr_addr[31:0]),
		      .data_req		(data_req),
		      .data_wr		(data_wr),
		      .data_addr	(data_addr[31:0]),
		      .data_wdata	(data_wdata[31:0]),
		      .data_be	    (data_be[3:0]),
		      // Inputs
		      .clk		(clk),
		      .reset_n		(reset_n),
		      .extern_irq	(extern_irq),
		      .soft_irq		(soft_irq),
		      .timer_irq	(timer_irq),
		      .debug_req	(debug_req),
		      .hart_id		(hart_id[31:0]),
		      .boot_addr	(boot_addr[31:0]),
		      .instr_gnt	(instr_gnt),
		      .instr_rdata	(instr_rdata[31:0]),
		      .instr_err	(instr_err),
		      .instr_valid	(instr_valid),
		      .data_gnt		(data_gnt),
		      .data_rdata	(data_rdata[31:0]),
		      .data_valid	(data_valid),
		      .data_error	(data_error));


tb_memory tb_memory(/*AUTOINST*/
		    // Outputs
		    .instr_gnt		(instr_gnt),
		    .instr_rdata	(instr_rdata[31:0]),
		    .instr_err		(instr_err),
		    .instr_valid	(instr_valid),
		    .data_gnt		(data_gnt),
		    .data_rdata		(data_rdata[31:0]),
		    .data_valid		(data_valid),
		    // Inputs
		    .clk		(clk),
		    .reset_n		(reset_n),
		    .instr_req		(instr_req),
		    .instr_addr		(instr_addr[31:0]),
		    .data_req		(data_req),
		    .data_wr		(data_wr),
		    .data_addr		(data_addr[31:0]),
		    .data_wdata		(data_wdata[31:0]),
		    .data_byteen	(data_be[3:0]));


`include "monitor.sv"
monitor my_monitor;
initial begin
    my_monitor = new();
    my_monitor.main;
end

`define IRETIRE tb.riscv_core.mem_stage.iretire_wb
`define IRETIRE_PC tb.riscv_core.mem_stage.pc_wb

integer exc_log;
initial begin
    exc_log = $fopen("exc.log");
    while(1)begin
        @(posedge clk);
        if(`IRETIRE)begin
            $fdisplay(exc_log, "PC: 0x%h ", `IRETIRE_PC);
        end
    end
end

endmodule
