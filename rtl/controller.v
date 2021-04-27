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

    //read register_file
    input           read_a_in_id,
    input [4:0]     read_a_addr,
    input           read_b_in_id,
    input [4:0]     read_b_addr,
    input           load_instr_in_ex,
    input [4:0]     ex_dest_we_addr,
    input           load_instr_in_mem,
    input [4:0]     mem_dest_we_addr,

    input           jump,
    input [31:0]    jump_target_addr,

    input           branch_taken,
    input [31:0]    branch_target_addr,

    output          set_pc_valid,
    output [31:0]   set_pc,

    input           ex_stage_ready,
    input           mem_stage_ready,
    input           wb_stage_ready,

    output          stall_if_stage,
    output          stall_id_stage,
    output          stall_ex_stage,
    output          stall_mem_stage,
    output          flush_if,
    output          flush_id
);

// Local Variables:
// verilog-library-directories:("." "dir1" "dir2" ...)
// End:

//////////////////////////////////////////////
/*AUTOLOGIC*/
//////////////////////////////////////////////

logic control_stall_if;
logic control_stall_id;
logic load_stall;

//////////////////////////////////////////////
//main code
//
//
assign load_stall = (
            ( read_a_in_id & load_instr_in_ex   & (read_a_addr==ex_dest_we_addr    ) ) |
            ( read_a_in_id & load_instr_in_mem  & (read_a_addr==mem_dest_we_addr   ) ) |
            ( read_b_in_id & load_instr_in_ex   & (read_b_addr==ex_dest_we_addr    ) ) |
            ( read_b_in_id & load_instr_in_mem  & (read_b_addr==mem_dest_we_addr   ) ) 
);


assign set_pc_valid = branch_taken | jump;
assign set_pc[31:0] = (
    ( {32{branch_taken}}    & branch_target_addr[31:0]  ) |
    ( {32{jump}}            & jump_target_addr[31:0]    )
);


//////////////////////////////////////////////
//pipeline controller
//////////////////////////////////////////////
assign flush_if_id = branch_taken | jump;

assign flush_if     = flush_if_id;
assign flush_id     = flush_if_id | ( load_stall & mem_stage_ready );

assign stall_if_stage   = (~wb_stage_ready) | (~mem_stage_ready)| (~ex_stage_ready) | load_stall | control_stall_if;
assign stall_id_stage   = (~wb_stage_ready) | (~mem_stage_ready)| (~ex_stage_ready) | load_stall | control_stall_id;
assign stall_ex_stage   = (~wb_stage_ready) | (~mem_stage_ready);
assign stall_mem_stage  = (~wb_stage_ready);

//////////////////////////////////////////////
//interrupt exception
//////////////////////////////////////////////
//TODO
assign control_stall_if = 1'b0;
assign control_stall_id = 1'b0;

endmodule
