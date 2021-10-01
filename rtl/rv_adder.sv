//================================================================
//   Copyright (C) 2021. All rights reserved.
//
//   Filename     : rv_adder.sv
//   Auther       : cnan
//   Created On   : 2021.10.01
//   Description  : 
//
//
//================================================================

module rv_adder(
    input               en,
    input adder_op_e    op,

    input [31:0]        op_a,
    input [31:0]        op_b,

    output [31:0]       res
);

// Local Variables:
// verilog-library-directories:("." "dir1" "dir2" ...)
// End:

//////////////////////////////////////////////
/*AUTOLOGIC*/
//////////////////////////////////////////////

logic [31:0] op_a_neg;
logic [31:0] op_b_neg;

logic [32:0] adder_op_a;
logic [32:0] adder_op_b;

logic [32:0] adder_extend_result;

//////////////////////////////////////////////
//main code

assign op_a_neg = ~op_a;
assign op_b_neg = ~op_b;

assign adder_op_a = { op_a, 1'b1 };
assign adder_op_b = (op == ALU_SUB) ? { op_b_neg, 1'b1 } : { op_b, 1'b0 };

assign adder_extend_result[32:0] = adder_op_a[32:0] + adder_op_b[32:0];

assign res = adder_extend_result[32:1];

endmodule
