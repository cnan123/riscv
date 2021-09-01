//================================================================
//   Copyright (C) 2021 Sangfor Ltd. All rights reserved.
//
//   Filename     : if_stage_bench.v
//   Auther       : cnan
//   Created On   : 2021年03月28日
//   Description  : 
//
//
//================================================================

module if_stage_bench;

// Local Variables:
// verilog-library-directories:(".")
// End:

//////////////////////////////////////////////
/*AUTOLOGIC*/
// Beginning of automatic wires (for undeclared instantiated-module outputs)
logic [31:0]		instr_addr;		// From if_stage of if_stage.v
logic			instr_req;		// From if_stage of if_stage.v
logic [31:0]		instruction;		// From if_stage of if_stage.v
logic			instruction_value;	// From if_stage of if_stage.v
logic [31:0]		pc_if;			// From if_stage of if_stage.v
logic			pc_if_valid;		// From if_stage of if_stage.v
// End of automatics
//////////////////////////////////////////////
logic           clk;
logic           rst_n;
logic   [31:0]  boot_addr;
logic           fetch_enable;
logic           set_pc_valid;
logic   [31:0]  set_pc;
logic           pc_id_ready;
logic           instr_gnt;
logic           instr_err;
logic   [31:0]  instr_rdata;
logic           instr_valid;

//////////////////////////////////////////////
//main code

initial begin
        clk = 0;
        rst_n = 0;

        #100;
        rst_n = 1;

        #10000;
        $finish;
end

always #5 clk<=~clk;

initial begin
    $fsdbDumpfile("verilog.fsdb");
    $fsdbDumpvars();
    $fsdbDumpMDA();
end

assign boot_addr = 32'h8000_0000;
assign fetch_enable = 1'b1;

assign set_pc_valid = 1'b0;
assign set_pc = 32'h0;

assign instr_gnt = 1'b1;
assign instr_err = 1'b0;

always @(posedge clk or negedge rst_n)begin
    if( !rst_n )begin
        instr_valid <= 1'b0;
        instr_rdata <= 32'h0;
    end else if( instr_req )begin
        instr_valid <= 1'b1;
        instr_rdata <= 32'h0;
    end else begin
        instr_valid <= 1'b0;
        instr_rdata <= 32'h0;
    end
end

initial begin
    pc_id_ready = 1'b0;
    @(posedge rst_n);
    pc_id_ready = 1'b1;
    #100;

    pc_id_ready = 1'b0;
    #100;
    pc_id_ready = 1'b1;
end


if_stage if_stage(/*AUTOINST*/
		  // Outputs
		  .pc_if		(pc_if[31:0]),
		  .instruction		(instruction[31:0]),
		  .instruction_value	(instruction_value),
		  .instr_req		(instr_req),
		  .instr_addr		(instr_addr[31:0]),
		  // Inputs
		  .clk			(clk),
		  .rst_n		(rst_n),
		  .boot_addr		(boot_addr[31:0]),
		  .fetch_enable		(fetch_enable),
		  .set_pc_valid		(set_pc_valid),
		  .set_pc		(set_pc[31:0]),
		  .pc_id_ready		(pc_id_ready),
		  .instr_gnt		(instr_gnt),
		  .instr_rdata		(instr_rdata[31:0]),
		  .instr_err		(instr_err),
		  .instr_valid		(instr_valid));

endmodule
