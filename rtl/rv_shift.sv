//================================================================
//   Copyright (C) 2021. All rights reserved.
//
//   Filename     : rv_shift.sv
//   Auther       : cnan
//   Created On   : 2021.10.01
//   Description  : 
//
//
//================================================================

module rv_shift(/*AUTOARG*/
    input shift_op_e    op,
    input [31:0]        op_a,
    input [31:0]        op_a_rev,
    input [4:0]         amt,

    output [31:0]       res
);

// Local Variables:
// verilog-library-directories:("." "dir1" "dir2" ...)
// End:

//////////////////////////////////////////////
/*AUTOLOGIC*/
//////////////////////////////////////////////
logic shift_left;
logic shift_arith;
logic shift_signed;

logic [31:0] shift_operate;
logic [31:0] shift_right_result;
logic [31:0] shift_left_result;

genvar i;

//////////////////////////////////////////////
//main code
assign shift_left   = (op==ALU_SLL);
assign shift_arith  = (op==ALU_SRA);

assign shift_operate    = shift_left ? op_a_rev : op_a;
assign shift_signed     = shift_arith & op_a[31];

assign shift_right_result = ($signed({shift_signed,shift_operate}) >>> amt[4:0]);

generate
for(i=0;i<32;i=i+1)begin: shiftresult
    assign shift_left_result[i] = shift_right_result[31-i];
end
endgenerate

assign res = shift_left ? shift_left_result : shift_right_result; 

endmodule
