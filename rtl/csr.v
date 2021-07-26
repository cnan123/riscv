//================================================================
//   Copyright (C) 2021 Sangfor Ltd. All rights reserved.
//
//   Filename     : csr.v
//   Auther       : cnan
//   Created On   : 2021年05月19日
//   Description  : 
//
//
//================================================================

module csr(
    input                   clk,
    input                   reset_n,

    input  logic            csr_en,
    input  logic [1:0]      csr_op,
    input  logic [11:0]     csr_addr,
    input  logic [31:0]     csr_wdata,
    output logic [31:0]     csr_rdata
);

// Local Variables:
// verilog-library-directories:("." "dir1" "dir2" ...)
// End:

//////////////////////////////////////////////
/*AUTOLOGIC*/
//////////////////////////////////////////////


//////////////////////////////////////////////
//main code


assign u_mode_map = (csr_addr[9:8] == USER_MAP);
assign m_mode_map = (csr_addr[9:8] == MACHINE_MAP);
assign s_mode_map = (csr_addr[9:8] == SUPERVISOR_MAP);
assign h_mode_map = (csr_addr[9:8] == HYPERVISOR_MAP);

assign rw = (csr_addr[11:10] == 2'b00) | (csr_addr[11:10] == 2'b01) | (csr_addr[11:10] == 2'b10);
assign ro = (csr_addr[11:10] == 2'b11);


//=================================================================================================//
//mstatus
//=================================================================================================//
assign mstatus_en = ( (csr_addr[11:0]== MSTATUS) & (privilege_mode[1:0]==MACHINE) ) ;

always @(*)begin
    mstatus_n = mstatus_q;


end



//=================================================================================================//
//mvendorid
//=================================================================================================//
assign mvendorid_en = ( csr_addr[12:0] == MVENDORID );
assign mvendorid_op = csr_op;
assign mvendorid_n  = csr_wdata;
csr_register #(.DEFAULT(MVENDORID_DEFAULT))mvendorid(
    .clk        (clk            ),
    .reset_n    (reset_n        ),
    .en         (mvendorid_en   ),
    .op         (mvendorid_op   ),
    .data_n     (mvendorid_n    ),
    .data_q     (mvendorid      )
);


//=================================================================================================//
//mvendorid
//=================================================================================================//
assign mvendorid_en = ( csr_addr[12:0] == MVENDORID );
assign mvendorid_op = csr_op;
assign mvendorid_n  = csr_wdata;
csr_register #(.DEFAULT(MVENDORID_DEFAULT))mvendorid(
    .clk        (clk            ),
    .reset_n    (reset_n        ),
    .en         (mvendorid_en   ),
    .op         (mvendorid_op   ),
    .data_n     (mvendorid_n    ),
    .data_q     (mvendorid      )
);


endmodule
