//================================================================
//   Copyright (C) 2021. All rights reserved.
//
//   Filename     : alu.sv
//   Auther       : cnan
//   Created On   : 2021.04.30
//   Description  : 
//
//
//================================================================
import riscv_pkg::*;
module alu (
        input logic                     sign,
        input logic                     adder_en,
        input adder_op_e                adder_op,
        input logic                     comp_en,
        input comp_op_e                 comp_op,
        input logic                     logic_en,
        input logic_op_e                logic_op,
        input logic                     shift_en,
        input shift_op_e                shift_op,

        input logic     [31:0]          operator_a,
        input logic     [31:0]          operator_b,

        output logic    [31:0]          adder0_result,
        output logic    [31:0]          logic_result,
        output logic    [31:0]          shift_result,
        output logic                    compare_result,

        input           [31:0]          adder1_op_a,
        input           [31:0]          adder1_op_b,
        output logic    [31:0]          adder1_result,

        input           [31:0]          adder2_op_a,
        input           [31:0]          adder2_op_b,
        output logic    [31:0]          adder2_result,

        output logic    [31:0]          alu_result
);

// Local Variables:
// verilog-library-directories:(".")
// End:

//////////////////////////////////////////////
/*AUTOLOGIC*/
// Beginning of automatic wires (for undeclared instantiated-module outputs)
logic [31:0]		res;			// From comp of rv_compare.v, ...
// End of automatics
//////////////////////////////////////////////
logic   [31:0]  operator_a_rev;
logic   [31:0]  operator_b_rev;

logic [31:0]    operator_a_neg;
logic [31:0]    operator_b_neg;

logic   [31:0]  alu_compare_result;

genvar          i;

//////////////////////////////////////////////
//main code

assign operator_a_neg = ~operator_a;
assign operator_b_neg = ~operator_b;

generate
for(i=0;i<32;i=i+1)begin: op_rev
    assign operator_a_rev[i] = operator_a[31-i];
    assign operator_b_rev[i] = operator_b[31-i];
end
endgenerate

///////////////////////////////////////////////////////////////
//adder
//adder0: support ADD/SUB, used for common operate
//adder1: support ADD, used for generate branch/jump targer
//adder2: support ADD, used for generate branch/jump targer
///////////////////////////////////////////////////////////////
rv_adder rv_adder0(
		  .en			(adder_en           ),
		  .op			(adder_op           ),
		  .op_a			(operator_a[31:0]   ),
		  .op_b			(operator_b[31:0]   ),
		  .res			(adder0_result[31:0])
);

rv_adder rv_adder1(
		  .en			(1'b1               ),
		  .op			(ALU_ADD            ),
		  .op_a			(adder1_op_a[31:0]  ),
		  .op_b			(adder1_op_b[31:0]  ),
		  .res			(adder1_result[31:0])
);

rv_adder rv_adder2(
		  .en			(1'b1               ),
		  .op			(ALU_ADD            ),
		  .op_a			(adder2_op_a[31:0]  ),
		  .op_b			(adder2_op_b[31:0]  ),
		  .res			(adder2_result[31:0])
);

//////////////////////////////////////////////
//compare
//////////////////////////////////////////////
rv_compare comp(
		.en			    (comp_en            ),
		.sign			(sign               ),
		.adder_res		(adder0_result[31:0]),
		.op_a			(operator_a[31:0]   ),
		.op_b			(operator_b[31:0]   ),
		.op			    (comp_op            ),
		.res			(compare_result     )
);

assign alu_compare_result = {31'h0, compare_result };

//////////////////////////////////////////////
//logic
//////////////////////////////////////////////
always_comb begin
    logic_result = 32'h0;
    unique case( logic_op )
        ALU_AND : logic_result[31:0] = operator_a & operator_b;
        ALU_OR  : logic_result[31:0] = operator_a | operator_b;
        ALU_XOR : logic_result[31:0] = operator_a ^ operator_b;
        default : logic_result[31:0] = 32'h0;
    endcase
end


//////////////////////////////////////////////
//shift
//////////////////////////////////////////////
rv_shift shift(
	       .op			(shift_op               ),
	       .op_a		(operator_a[31:0]       ),
	       .op_a_rev	(operator_a_rev[31:0]   ),
	       .amt			(operator_b[4:0]        ),
	       .res			(shift_result[31:0]     )
);

//////////////////////////////////////////////
//result
//////////////////////////////////////////////
always_comb begin
    alu_result          = 32'h0;
    unique case(1)
        adder_en:   alu_result = adder0_result;
        logic_en:   alu_result = logic_result;
        comp_en:    alu_result = alu_compare_result;
        shift_en:   alu_result = shift_result;
        default:;
    endcase
end

endmodule
