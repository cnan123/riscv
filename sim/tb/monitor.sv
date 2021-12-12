//================================================================
//   Copyright (C) 2021 Sangfor Ltd. All rights reserved.
//
//   Filename     : monitor.sv
//   Auther       : cnan
//   Created On   : 2021年05月05日
//   Description  : 
//
//
//================================================================


// Local Variables:
// verilog-library-directories:("." "dir1" "dir2" ...)
// End:

//////////////////////////////////////////////
/*AUTOLOGIC*/
//////////////////////////////////////////////


//////////////////////////////////////////////
//main code
`define CLK tb.clk

`define MONITOR_PATH tb.riscv_core

parameter CMD_ADDR = 32'hffff_fff0;
parameter ARG_ADDR = 32'hffff_fff8;
parameter PRINT_ADDR = 32'hffff_fff4;

`define PASS        32'h0
`define ISA_FAIL    32'h1
`define C_FAIL      32'h2
`define IRQ         32'h3
`define TIMER       32'h4

`define EXTERN_IRQ_REQ  32'h0
`define SOFT_IRQ_REQ    32'h1
`define TIMER_IRQ_REQ   32'h2
`define EXTERN_IRQ_RLS  32'h3
`define SOFT_IRQ_RLS    32'h4
`define TIMER_IRQ_RLS   32'h5

class monitor;
    
    function new();
        extern_irq = 1'b0;
        soft_irq = 1'b0;
        timer_irq = 1'b0;
    endfunction

    task main;
        fork
            sim_control;
            print;
        join
    endtask
    
    task sim_control;
        logic [31:0] cmd;

        while(1)begin
            wait_cmd(cmd);
            case(cmd)
                `PASS       :pass;
                `ISA_FAIL   :isa_fail;
                `C_FAIL     :c_fail;
                `IRQ        :irq; 
                `TIMER      :timer; 
            endcase
        end
    endtask

    task wait_cmd;
        output logic [31:0] cmd;
        while(1)begin
            @(posedge `CLK);
            if( `MONITOR_PATH.data_req & `MONITOR_PATH.data_wr & `MONITOR_PATH.data_addr==CMD_ADDR )begin
                cmd = `MONITOR_PATH.data_wdata;
                break;
            end
        end
    endtask

    task wait_arg;
        output logic [31:0] arg;
        while(1)begin
            @(posedge `CLK);
            if( `MONITOR_PATH.data_req & `MONITOR_PATH.data_wr & `MONITOR_PATH.data_addr==ARG_ADDR )begin
                arg = `MONITOR_PATH.data_wdata;
                break;
            end
        end
    endtask

    task wait_print_data;
        output logic [7:0] arg;
        while(1)begin
            @(posedge `CLK);
            if( `MONITOR_PATH.data_req & `MONITOR_PATH.data_wr & `MONITOR_PATH.data_addr==PRINT_ADDR )begin
                arg = `MONITOR_PATH.data_wdata[7:0];
                //$display("arg: %c",arg);
                break;
            end
        end
    endtask

    task pass;
        $display(">>>>>> PASS <<<<<<");
        @(posedge `CLK);
        $finish;
    endtask

    task c_fail;
        $display(">>>>>> FAIL <<<<<<");
        @(posedge `CLK);
        $finish;
    endtask

    task isa_fail;
        logic [31:0] arg;

        wait_arg(arg);
        $display(">>>>>> FAIL <<<<<<");
        $display(">>>>>>ID: %x<<<<<<",arg);
        @(posedge `CLK);
        $finish;
    endtask

    task irq;
        logic [31:0] arg;
        wait_arg(arg);
        case(arg)
            `EXTERN_IRQ_REQ: extern_irq = 1'b1;
            `EXTERN_IRQ_RLS: extern_irq = 1'b0;
            `SOFT_IRQ_REQ: soft_irq = 1'b1;
            `SOFT_IRQ_RLS: soft_irq = 1'b0;
            `TIMER_IRQ_REQ: timer_irq = 1'b1;
            `TIMER_IRQ_RLS: timer_irq = 1'b0;
            default:;
        endcase
    endtask

    task timer;
        logic [31:0] arg;
        wait_arg(arg);
        $display("arg:%x",arg);
        while(arg--)begin
            @(posedge `CLK);
        end
        timer_irq = 1'b1;
    endtask

    task print;
        logic [7:0] arg;
        while(1) begin
            wait_print_data(arg);
            $write("%c",arg);
        end
        //$display("arg: %c",arg);
    endtask

endclass

