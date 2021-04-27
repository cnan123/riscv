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

parameter CMD_ADDR = 32'hffff_fffc;
parameter ARG_ADDR = 32'hffff_fff8;

`define PASS 32'h0
`define FAIL 32'h1

class monitor;
    
    task main;
        fork
            sim_control;
            //print;
        join
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

    task sim_control;
        logic [31:0] cmd;

        wait_cmd(cmd);
        if( cmd == `PASS        ) pass;
        else if( cmd == `FAIL   ) fail;
    endtask

    task pass;
        $display(">>>>>> PASS <<<<<<");
        #1000;
        $finish;
    endtask

    task fail;
        logic [31:0] arg;

        wait_arg(arg);
        $display(">>>>>> FAIL <<<<<<");
        $display(">>>>>>ID: %x<<<<<<",arg);
        #1000;
        $finish;
    endtask

    task print;
        $display(">>>>>> PRINT <<<<<<");
    endtask

endclass

