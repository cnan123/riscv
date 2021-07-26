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
    input                       clk,
    input                       reset_n,

    input                       jump,
    input                       branch_taken,
    input                       fence,
    input [31:0]                jump_target_addr,
    input [31:0]                branch_target_addr,
    input [31:0]                pc_if,

    output                      set_pc_valid,
    output [31:0]               set_pc,

    //exception interrupt
    input logic                 lsu_valid,
    input logic                 lsu_err,
    input logic                 exc_taken_wb,
    input logic [5:0]           exc_cause_wb,
    input logic [31:0]          exc_tval_wb,

    //pipeline control
    output logic                flush_F,
    output logic                flush_D,
    output logic                flush_E,
    output logic                flush_M,
    output logic                flush_W,
    output logic                stall_F, //reserved
    output logic                stall_D, //reserved
    output logic                stall_E, //reserved
    output logic                stall_M, //reserved
    output logic                stall_W, //reserved

    output                      irq_ack
);

// Local Variables:
// verilog-library-directories:("." "dir1" "dir2" ...)
// End:

//////////////////////////////////////////////
/*AUTOLOGIC*/
//////////////////////////////////////////////

parameter IDLE = 1'b0;
parameter EXC_FLUSH = 1'b1;

logic           branch_jump;
logic           exc_taken;
logic           exc_fetch;
logic [31:0]    exc_fetch_pc;
logic           fsm_control_ns;
logic           fsm_control_cs;

//////////////////////////////////////////////
//main code
//

assign set_pc_valid = branch_taken | jump;
assign set_pc[31:0] = (
    ( {32{branch_taken}}    & branch_target_addr[31:0]  ) |
    ( {32{jump}}            & jump_target_addr[31:0]    ) |
    ( {32{exc_fetch}}       & exc_fetch_pc[31:0]        ) |
    ( {32{fence}}           & pc_if[31:0]               )
);

//////////////////////////////////////////////
//pipeline controller
//////////////////////////////////////////////
assign branch_jump = branch_taken | jump;
assign exc_taken = exc_taken_wb | (lsu_valid & lsu_err);

assign exc_fetch = (fsm_control_cs == EXC_FLUSH);
assign exc_fetch_pc = 32'h0; //TODO exception entry 

always @(posedge clk or negedge reset_n)begin
    if(!reset_n)begin
        fsm_control_cs <= 1'b0;
    end else begin
        fsm_control_cs <= fsm_control_ns;
    end
end

always @(*)begin
    fsm_control_ns = fsm_control_cs;
    case( fsm_control_cs )
        IDLE:      if(exc_taken) fsm_control_ns = EXC_FLUSH;
        EXC_FLUSH: fsm_control_ns = IDLE;
    endcase
end


//////////////////////////////////////////////////////
//just need one cycle to flush pipeline
//mode switch need another cycle to switch context
//////////////////////////////////////////////////////

assign flush_F  = exc_taken | branch_jump | fence;
assign flush_D  = exc_taken | branch_jump ;
assign flush_E  = exc_taken;
assign flush_M  = exc_taken;
assign flush_W  = exc_taken;

//This reverserd for pipeline extern 
assign stall_F  = 1'b0;
assign stall_D  = 1'b0;
assign stall_E  = 1'b0;
assign stall_M  = 1'b0;
assign stall_W  = 1'b0;

endmodule
