//================================================================
//   Copyright (C) 2021 Sangfor Ltd. All rights reserved.
//
//   Filename     : controller.v
//   Auther       : cnan
//   Created On   : 2021年04月11日
//   Description  : 
//
//
//================================================================

module controller(
    input           clk,
    input           reset_n,

    input           ex_busy,

    input           jump,
    input [31:0]    jump_target_addr,

    input           branch_taken,
    input [31:0]    branch_target_addr,

    output          set_pc_valid,
    output [31:0]   set_pc,

    output          stall_id,
    output          stall_if,
    output          flush
);

// Local Variables:
// verilog-library-directories:("." "dir1" "dir2" ...)
// End:

//////////////////////////////////////////////
/*AUTOLOGIC*/
//////////////////////////////////////////////


//////////////////////////////////////////////
//main code

assign set_pc_valid = branch_taken | jump;
assign set_pc[31:0] = (
    ( {32{branch_taken}}    & branch_target_addr[31:0]  ) |
    ( {32{jump}}            & jump_target_addr[31:0]    )
);

assign flush = branch_taken | jump;
assign stall_if = ex_busy;
assign stall_id = ex_busy;

endmodule
