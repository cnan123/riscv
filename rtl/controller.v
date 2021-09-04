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
    input [31:0]                jump_target_addr,
    input [31:0]                branch_target_addr,
    input [31:0]                pc_if,
    input [31:0]                pc_id,
    input [31:0]                pc_ex,
    input [31:0]                pc_mem,
    input [31:0]                pc_wb,

    output                      set_pc_valid,
    output [31:0]               set_pc,
    output                      fetch_enable,

    //plic
    input logic                 extern_irq_taken,
    input logic                 soft_irq_taken,
    input logic                 timer_irq_taken,
    output                      irq_ack,

    //exception
    input logic                 exc_taken,
    //ID stage
    input logic                 is_mret,
    input logic                 is_ecall,
    input logic                 is_ebreak,
    input logic                 is_fence,
    input logic                 is_illegal_instr,
    input logic                 is_instr_acs_fault,
    input logic                 is_interrupt,
    input logic                 is_wfi,
    //EX stage
    input logic                 is_illegal_csr,
    //MEM stage  reserved
    //WB stage
    input logic                 is_lsu_load_err,
    input logic                 is_lsu_store_err,

    //control status register
    input privilege_e           privilege_mode, 
    input logic [31:0]          mepc,
    input logic [31:0]          mtvec,
    output logic                mcause_update,
    output mcause_e             mcause,
    output logic                mepc_updata,
    output mepc_mux_e           mepc_mux,

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
    output logic                stall_W  //reserved
);

// Local Variables:
// verilog-library-directories:("." "dir1" "dir2" ...)
// End:

//////////////////////////////////////////////
/*AUTOLOGIC*/
//////////////////////////////////////////////

parameter IDLE          = 2'h0;
parameter EXC_FLUSH     = 2'h1;
parameter SLEEP         = 2'h2;
parameter WAKEUP        = 2'h3;

logic           branch_jump;
logic           exc_fetch;
logic [31:0]    exc_fetch_pc;
logic [1:0]     fsm_control_ns;
logic [1:0]     fsm_control_cs;
logic           interrupt_taken;

//////////////////////////////////////////////
//main code


//////////////////////////////////////////////
//constorl fsm
//////////////////////////////////////////////
always @(posedge clk or negedge reset_n)begin
    if(!reset_n)begin
        fsm_control_cs <= 2'h0;
    end else begin
        fsm_control_cs <= fsm_control_ns;
    end
end

always @(*)begin
    fsm_control_ns = fsm_control_cs;
    case( fsm_control_cs )
        IDLE:begin
            if(exc_taken) fsm_control_ns = EXC_FLUSH;
        end
        EXC_FLUSH: begin
            if(is_wfi)begin
                fsm_control_ns = SLEEP;
            end else begin
                fsm_control_ns = IDLE;
            end
        end
        SLEEP:begin //during this status, IF/ID/EX/MEM/WB stage's clk will be close.
            if(interrupt_taken) begin //from PLIC
                fsm_control_ns = WAKEUP;
            end
        end
        WAKEUP:begin //clock is open, refetch and update csr
            fsm_control_ns = IDLE;
        end
    endcase
end


//////////////////////////////////////////////
//interrupt controller
//////////////////////////////////////////////
assign interrupt_taken = extern_irq_taken | soft_irq_taken | timer_irq_taken;
assign irq_ack  = (
    ( (fsm_control_cs==EXC_FLUSH) & is_interrupt ) |
    ( (fsm_control_cs==WAKEUP)  ) 
);


//////////////////////////////////////////////
//pipeline controller
//////////////////////////////////////////////
always @(*)begin
    case( fsm_control_cs )
        EXC_FLUSH:begin
            exc_fetch = 1'b1;
            unique case(1)
                is_fence:   exc_fetch_pc = pc_if[31:0];
                is_mret:    exc_fetch_pc = mepc[31:0];
                is_wfi:     exc_fetch = 1'b0;
                default:    exc_fetch_pc = { mtvec[31:8], 8'h0 };
            endcase
        end
        WAKEUP:begin
            exc_fetch = 1'b1;
            exc_fetch_pc = { mtvec[31:8], 8'h0 };
        end
        default:begin
            exc_fetch = 1'b0;
            exc_fetch_pc = 32'h0;
        end
    endcase
end

assign fetch_enable = (fsm_control_cs != SLEEP);

//////////////////////////////////////////////////////
//csr update
//////////////////////////////////////////////////////
always @(*)begin
    mcause_update = 1'b0;
    mcause = MCAUSE_INSTR_ADDR_MISALIGN;
    mepc_updata = 1'b0;
    mepc_mux = MEPC_PC_WB;
    if(exc_taken)begin
        unique case(1)
            is_lsu_store_err: begin 
                mepc_updata=1'b1; 
                mcause_update=1'b1;
                mcause = MCAUSE_STORE_ACS_FAULT; 
            end
            is_lsu_load_err : begin 
                mepc_updata=1'b1; 
                mcause_update=1'b1;
                mcause = MCAUSE_LOAD_ACS_FAULT; 
            end
            is_ecall: begin 
                mepc_updata=1'b1; 
                mcause_update=1'b1;
                mcause = (privilege_mode == PRIV_LVL_U) ? MCAUSE_ECALL_U : MCAUSE_ECALL_M;
            end
            is_ebreak : begin 
                mepc_updata=1'b1; 
                mcause_update=1'b1;
                mcause = MCAUSE_BREAKPOINT;
            end
            is_illegal_instr, is_illegal_csr: begin 
                mepc_updata=1'b1; 
                mcause_update=1'b1;
                mcause = MCAUSE_ILLEGAL_INSTR;
            end
            is_instr_acs_fault: begin 
                mepc_updata=1'b1; 
                mcause_update=1'b1;
                mcause = MCAUSE_INSTR_ACS_FAULT;
            end
            is_wfi : begin 
                mepc_updata=1'b1; 
                mepc_mux = MEPC_PC_IF; 
            end
            is_interrupt        : begin 
                mepc_updata=1'b1; 
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
    end else if(fsm_control_cs==WAKEUP)begin
        mcause_update=1'b1;
        if(extern_irq_taken)
            mcause = MCAUSE_M_EXTERNAL_INT;
        else if(soft_irq_taken)
            mcause = MCAUSE_M_SOFTWARE_INT;
        else if(timer_irq_taken)
            mcause = MCAUSE_M_TIMER_INT;
    end
end


//////////////////////////////////////////////////////
//set next PC
//////////////////////////////////////////////////////
assign branch_jump = branch_taken | jump_taken;

assign set_pc_valid = branch_taken | jump_taken | exc_fetch;
assign set_pc[31:0] = (
    ( {32{branch_taken}}    & branch_target_addr[31:0]  ) |
    ( {32{jump_taken}}      & jump_target_addr[31:0]    ) |
    ( {32{exc_fetch}}       & exc_fetch_pc[31:0]        ) 
);

//////////////////////////////////////////////////////
//just need one cycle to flush pipeline
//mode switch need another cycle to switch context
//////////////////////////////////////////////////////

assign flush_F  = (fsm_control_cs==EXC_FLUSH) | branch_jump;
assign flush_D  = (fsm_control_cs==EXC_FLUSH) | branch_jump ;
assign flush_E  = (fsm_control_cs==EXC_FLUSH);
assign flush_M  = (fsm_control_cs==EXC_FLUSH);
assign flush_W  = (fsm_control_cs==EXC_FLUSH);

//This reverserd for pipeline extern 
assign stall_F  = (fsm_control_cs==SLEEP);
assign stall_D  = (fsm_control_cs==SLEEP);
assign stall_E  = (fsm_control_cs==SLEEP);
assign stall_M  = (fsm_control_cs==SLEEP);
assign stall_W  = (fsm_control_cs==SLEEP);

endmodule
