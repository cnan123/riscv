//================================================================
//   Copyright (C) 2021. All rights reserved.
//
//   Filename     : controller.v
//   Auther       : cnan
//   Created On   : 2021.04.11
//   Description  : 
//
//
//================================================================

module controller(
    input                       clk,
    input                       reset_n,

    input                       jump_taken,
    input                       branch_taken,
    input                       fence,
    input [31:0]                jump_target_addr,
    input [31:0]                branch_target_addr,
    input [31:0]                pc_if,
    input [31:0]                pc_id,
    input [31:0]                pc_ex,
    input [31:0]                pc_mem,
    input [31:0]                pc_wb,

    output                      set_pc_valid,
    output [31:0]               set_pc,

    //plic
    input logic                 extern_irq_taken,
    input logic                 soft_irq_taken,
    input logic                 timer_irq_taken,

    //lsu exception
    input logic                 lsu_en_wb,
    input lsu_op_e              lsu_op_wb,
    input logic                 lsu_valid_wb,
    input logic                 lsu_err_wb,
    //decoder exception
    input logic                 exc_taken_wb,
    input logic                 is_mret,
    input logic                 is_ecall,
    input logic                 is_ebreak,
    input logic                 is_fence,
    input logic                 is_illegal_instr,
    input logic                 is_instr_acs_fault,
    input logic                 is_interrupt,

    //control status register
    input privilege_e           privilege_mode, 
    input logic [31:0]          mepc,
    input logic [31:0]          mtvec,
    output logic                mcause_update,
    output mcause_e             mcause,
    output logic                mepc_updata,

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

    output                      irq_taken_wb
);

// Local Variables:
// verilog-library-directories:("." "dir1" "dir2" ...)
// End:

//////////////////////////////////////////////
/*AUTOLOGIC*/
//////////////////////////////////////////////

parameter IDLE          = 1'b0;
parameter EXC_FLUSH     = 1'b1;

logic           branch_jump;
logic           exc_taken;
logic           exc_fetch;
logic [31:0]    exc_fetch_pc;
logic           fsm_control_ns;
logic           fsm_control_cs;

//////////////////////////////////////////////
//main code
//

assign set_pc_valid = branch_taken | jump_taken | (fsm_control_cs==EXC_FLUSH);
assign set_pc[31:0] = (
    ( {32{branch_taken}}    & branch_target_addr[31:0]  ) |
    ( {32{jump_taken}}      & jump_target_addr[31:0]    ) |
    ( {32{exc_fetch}}       & exc_fetch_pc[31:0]        ) |
    ( {32{fence}}           & pc_if[31:0]               )
);

//////////////////////////////////////////////
//pipeline controller
//////////////////////////////////////////////
assign branch_jump = branch_taken | jump_taken;
assign exc_taken = exc_taken_wb | (lsu_valid_wb & lsu_err_wb);

assign exc_fetch = (fsm_control_cs == EXC_FLUSH);
assign exc_fetch_pc = (
    is_mret ? mepc : 
    is_fence ? pc_if : { mtvec[31:8], 8'h0 }
);  

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

assign irq_taken_wb = 1'b0; //TODO 

always @(*)begin
    mcause_update = 1'b0;
    mcause = MCAUSE_INSTR_ADDR_MISALIGN;
    if(exc_taken)begin
        if( lsu_valid_wb & lsu_err_wb )begin
            mcause_update = 1'b1;
            if(lsu_op_wb == LSU_OP_LD)begin
                mcause = MCAUSE_LOAD_ACS_FAULT;
            end else begin
                mcause = MCAUSE_STORE_ACS_FAULT;
            end
        end else begin
            unique case(1)
                is_ecall            : begin mcause_update=1'b1;mcause = (privilege_mode == PRIV_LVL_U) ? MCAUSE_ECALL_U : MCAUSE_ECALL_M;end
                is_ebreak           : begin mcause_update=1'b1;mcause = MCAUSE_BREAKPOINT;end
                is_illegal_instr    : begin mcause_update=1'b1;mcause = MCAUSE_ILLEGAL_INSTR;end
                is_instr_acs_fault  : begin mcause_update=1'b1;mcause = MCAUSE_INSTR_ACS_FAULT;end
                is_interrupt        : begin 
                    mcause_update=1'b1;
                    if(extern_irq_taken)
                        mcause = MCAUSE_M_EXTERNAL_INT;
                    else if(soft_irq_taken)
                        mcause = MCAUSE_M_SOFTWARE_INT;
                    else if(timer_irq_taken)
                        mcause = MCAUSE_M_TIMER_INT;
                end
                default:;
            endcase
        end
    end
end

assign mepc_updata = mcause_update;

//////////////////////////////////////////////////////
//just need one cycle to flush pipeline
//mode switch need another cycle to switch context
//////////////////////////////////////////////////////

assign flush_F  = (fsm_control_cs==EXC_FLUSH) | branch_jump | fence;
assign flush_D  = (fsm_control_cs==EXC_FLUSH) | branch_jump ;
assign flush_E  = (fsm_control_cs==EXC_FLUSH);
assign flush_M  = (fsm_control_cs==EXC_FLUSH);
assign flush_W  = (fsm_control_cs==EXC_FLUSH);

//This reverserd for pipeline extern 
assign stall_F  = 1'b0;
assign stall_D  = 1'b0;
assign stall_E  = 1'b0;
assign stall_M  = 1'b0;
assign stall_W  = 1'b0;

endmodule
