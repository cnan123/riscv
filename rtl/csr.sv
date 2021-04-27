//================================================================
//   Copyright (C) 2021 Sangfor Ltd. All rights reserved.
//
//   Filename     : csr.sv
//   Auther       : cnan
//   Created On   : 2021年05月04日
//   Description  : 
//
//
//================================================================

module csr(
        input           clk,
        input           reset_n,

        //csr instr
        input   logic [1:0]     csr_op,
        input   logic [11:0]    csr_addr,
        input   logic [31:0]    csr_wdata,
        output  logic [31:0]    csr_rdata
);

// Local Variables:
// verilog-library-directories:("." "dir1" "dir2" ...)
// End:

//////////////////////////////////////////////
/*AUTOLOGIC*/
//////////////////////////////////////////////


//////////////////////////////////////////////
//main code


endmodule
