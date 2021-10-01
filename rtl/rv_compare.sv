//================================================================
//   Copyright (C) 2021. All rights reserved.
//
//   Filename     : rv_compare.sv
//   Auther       : cnan
//   Created On   : 2021.10.01
//   Description  : 
//
//
//================================================================

module rv_compare(/*AUTOARG*/
    input               en,
    input               sign,
    input comp_op_e     op,

    input [31:0]        adder_res,
    input [31:0]        op_a,
    input [31:0]        op_b,

    output              res
);

// Local Variables:
// verilog-library-directories:("." "dir1" "dir2" ...)
// End:

//////////////////////////////////////////////
/*AUTOLOGIC*/
//////////////////////////////////////////////
logic is_equal;
logic is_great_equal;
logic cmp_result;


//////////////////////////////////////////////
//main code

assign is_equal = ( adder_res[31:0] == 32'b0 );

always_comb begin
    if( (op_a[31]^op_b[31]) == 1'b0 )begin
        is_great_equal = (adder_res[31]==1'b0);
    end else begin
        is_great_equal = op_a[31] ^ sign;
    end
end

always_comb begin
    unique case(op)
        ALU_EQ : cmp_result = is_equal;
        ALU_NE : cmp_result = ~is_equal;
        ALU_LT : cmp_result = ~is_great_equal;
        ALU_GE : cmp_result = is_great_equal;
        default: cmp_result = 1'b0;
    endcase
end

assign res = cmp_result;


endmodule
