//================================================================
//   Copyright (C) 2021 Sangfor Ltd. All rights reserved.
//
//   Filename     : tb_memory.v
//   Auther       : cnan
//   Created On   : 2021年04月18日
//   Description  : 
//
//
//================================================================

module tb_memory(
    input               clk,
    input               reset_n,

    input               instr_req,
    input [31:0]        instr_addr,
    output              instr_gnt,
    output [31:0]       instr_rdata,
    output              instr_err,
    output              instr_valid,

    input               data_req,
    input               data_wr,
    output              data_gnt,
    input [31:0]        data_addr,
    input [31:0]        data_wdata,
    input [3:0]         data_byteen,
    output [31:0]       data_rdata,
    output              data_valid
);

// Local Variables:
// verilog-library-directories:(".")
// End:

//////////////////////////////////////////////
/*AUTOLOGIC*/
// Beginning of automatic wires (for undeclared instantiated-module outputs)
// End of automatics
//////////////////////////////////////////////

memory iram(/*AUTOARG*/
    .clk            (clk),
    .reset_n        (reset_n),
    .req            (instr_req),
    .we             (1'b0),
    .be             (4'b0),
    .addr           (instr_addr[31:0]),
    .wdata          (32'h0),
    .gnt            (instr_gnt),
    .rdata          (instr_rdata[31:0]),
    .err            (instr_err),
    .valid          (instr_valid)
);


memory dram(/*AUTOARG*/
    .clk            (clk),
    .reset_n        (reset_n),
    .req            (data_req),
    .we             (data_wr),
    .be             (data_byteen[3:0]),
    .addr           (data_addr[31:0]),
    .wdata          (data_wdata[31:0]),
    .gnt            (data_gnt),
    .rdata          (data_rdata[31:0]),
    .err            (data_err),
    .valid          (data_valid)
);



endmodule
