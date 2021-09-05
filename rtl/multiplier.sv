//================================================================
//   Copyright (C) 2021. All rights reserved.
//
//   Filename     : multiplier.sv
//   Auther       : cnan
//   Created On   : 2021.09.05
//   Description  : 
//
//
//================================================================

module multiplier(
    input           en,
    input mult_op_e op,

    input   [31:0]  op_a, 
    input   [31:0]  op_b,

    output  [63:0]  result
);

// Local Variables:
// verilog-library-directories:("." "dir1" "dir2" ...)
// End:

//////////////////////////////////////////////
/*AUTOLOGIC*/
//////////////////////////////////////////////

logic sign_a;
logic sign_b;

logic [32:0] operator_a,operator_b;
logic [65:0] res;

//////////////////////////////////////////////
//main code

always_comb begin
    sign_a = 1'b0;
    sign_b = 1'b0;
    case( op )
        MUL, MULHU:begin
            sign_a = 1'b0;
            sign_b = 1'b0;
        end
        MULHSU:begin
            sign_a = 1'b1;
            sign_b = 1'b0;
        end
        MULH:begin
            sign_a = 1'b1;
            sign_b = 1'b1;
        end
        default:;
    endcase
end

assign operator_a = { (sign_a & op_a[31]), op_a[31:0] };
assign operator_b = { (sign_b & op_b[31]), op_b[31:0] };

assign res = $signed(operator_a[32:0]) * $signed(operator_b[32:0]);

assign result[63:0] = res[63:0]; 

endmodule
