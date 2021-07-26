//================================================================
//   Copyright (C) 2021 Sangfor Ltd. All rights reserved.
//
//   Filename     : alu.sv
//   Auther       : cnan
//   Created On   : 2021年04月30日
//   Description  : 
//
//
//================================================================
import riscv_pkg::*;
module alu (
        input alu_op_e                  operator,
        input logic     [31:0]          operator_a,
        input logic     [31:0]          operator_b,

        output logic    [31:0]          adder_result,
        output logic    [31:0]          logic_result,
        output logic    [31:0]          shift_result,
        output logic                    branch_compare_result,

        output logic    [31:0]          alu_result,
        output logic                    alu_result_valid
);

// Local Variables:
// verilog-library-directories:("." "dir1" "dir2" ...)
// End:

//////////////////////////////////////////////
/*AUTOLOGIC*/
//////////////////////////////////////////////
logic   [31:0]  operator_a_rev;
logic   [31:0]  operator_b_rev;

logic [31:0]    operator_a_neg;
logic [31:0]    operator_b_neg;
logic           adder_op_b_negate;
logic [32:0]    adder_op_a;
logic [32:0]    adder_op_b;
logic [32:0]    adder_extend_result;

logic           sub_op;

logic           branch_compare_op;
logic           compare_instr_op;
logic           cmp_signed;
logic           is_equal;
logic           is_great_equal;
logic           cmp_result;
logic   [31:0]  compare_result;

logic           logic_op;

logic           shift_op;
logic           shift_left;
logic           shift_arith;
logic   [31:0]  shift_operate;
logic   [31:0]  shift_right_result;
logic   [31:0]  shift_left_result;
logic   [4:0]   shift_amt_int;
logic           shift_signed;

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

//////////////////////////////////////////////
//adder
//////////////////////////////////////////////
assign adder_op = (operator==ALU_SUB) | (operator==ALU_ADD);

assign sub_op = (operator == ALU_SUB);
assign adder_op_b_negate = sub_op | branch_compare_op | compare_instr_op;

assign adder_op_a = { operator_a, 1'b1 };
assign adder_op_b = adder_op_b_negate ? { operator_b_neg, 1'b1 } : { operator_b, 1'b0 };

assign adder_extend_result[32:0] = adder_op_a[32:0] + adder_op_b[32:0];
assign adder_result[31:0] = adder_extend_result[32:1];


//////////////////////////////////////////////
//compare
//////////////////////////////////////////////
assign branch_compare_op = ( 
        ( operator == ALU_EQ    ) |
        ( operator == ALU_NE    ) |
        ( operator == ALU_LT    ) |
        ( operator == ALU_GE    ) |
        ( operator == ALU_LTU   ) |
        ( operator == ALU_GEU   ) 
);

assign compare_instr_op = (
        ( operator == ALU_SLT   ) |
        ( operator == ALU_SLTU  ) 
);

assign cmp_signed = (operator == ALU_LT) | (operator == ALU_GE) | (operator == ALU_SLT);

assign is_equal = ( adder_result[31:0] == 32'b0 );

always_comb begin
    if( (operator_a[31]^operator_b[31]) == 1'b0 )begin
        is_great_equal = (adder_result[31]==1'b0);
    end else begin
        is_great_equal = operator_a[31] ^ cmp_signed;
    end
end

always_comb begin
    unique case(operator)
        ALU_EQ : cmp_result = is_equal;
        ALU_NE : cmp_result = ~is_equal;
        ALU_LT : cmp_result = ~is_great_equal;
        ALU_GE : cmp_result = is_great_equal;
        ALU_LTU: cmp_result = ~is_great_equal;
        ALU_GEU: cmp_result = is_great_equal;
        default: cmp_result = 1'b0;
    endcase
end

assign compare_result = {31'h0, ~is_great_equal };
assign branch_compare_result = cmp_result;


//////////////////////////////////////////////
//logic
//////////////////////////////////////////////
assign logic_op = (operator==ALU_AND) | (operator==ALU_OR) | (operator==ALU_XOR);
always_comb begin
    logic_result = 32'h0;
    unique case( operator )
        ALU_AND : logic_result[31:0] = operator_a & operator_b;
        ALU_OR  : logic_result[31:0] = operator_a | operator_b;
        ALU_XOR : logic_result[31:0] = operator_a ^ operator_b;
        default : logic_result[31:0] = 32'h0;
    endcase
end


//////////////////////////////////////////////
//shift
//////////////////////////////////////////////
assign shift_op     = (operator==ALU_SRA) | (operator==ALU_SRL) | (operator==ALU_SLL);
assign shift_left   = (operator==ALU_SLL);
assign shift_arith  = (operator==ALU_SRA);

assign shift_operate    = shift_left ? operator_a_rev : operator_a;
assign shift_signed     = shift_arith & operator_a[31];
assign shift_amt_int[4:0] = operator_b[4:0];

assign shift_right_result = ($signed({shift_signed,shift_operate}) >>> shift_amt_int[4:0]);

generate
for(i=0;i<32;i=i+1)begin: shiftresult
    assign shift_left_result[i] = shift_right_result[31-i];
end
endgenerate

assign shift_result[31:0] = shift_left ? shift_left_result : shift_right_result; 


//////////////////////////////////////////////
//result
//////////////////////////////////////////////
assign alu_result = (
    ( {32{adder_op          }} & adder_result   ) |
    ( {32{logic_op          }} & logic_result   ) |
    ( {32{compare_instr_op  }} & compare_result ) |
    ( {32{shift_op          }} & shift_result   )
);

assign alu_result_valid = adder_op | logic_op | compare_instr_op | shift_op;

endmodule
