//================================================================
//   Copyright (C) 2021 Sangfor Ltd. All rights reserved.
//
//   Filename     : data_bypass.v
//   Auther       : cnan
//   Created On   : 2021年04月11日
//   Description  : 
//
//
//================================================================

module data_bypass(
    input           clk,
    input           reset_n,

    input           id_reg_ch0_rd,
    input [4:0]     id_reg_ch0_addr,
    output [31:0]   id_reg_ch0_data,

    input           id_reg_ch1_rd,
    input [4:0]     id_reg_ch1_addr,
    output [31:0]   id_reg_ch1_data,

    input           ex_dest_valid,
    input [4:0]     ex_dest_addr,
    input [31:0]    ex_dest_data,

    input           mem_dest_valid,
    input [4:0]     mem_dest_addr,
    input [31:0]    mem_dest_data,

    input           wb_dest_valid,
    input [4:0]     wb_dest_addr,
    input [31:0]    wb_dest_data,

    output          register_rd_ch0_en,
    output [4:0]    register_rd_ch0_addr,
    input [31:0]    register_rd_ch0_data,

    output          register_rd_ch1_en,
    output [4:0]    register_rd_ch1_addr,
    input [31:0]    register_rd_ch1_data
);

// Local Variables:
// verilog-library-directories:("." "dir1" "dir2" ...)
// End:

//////////////////////////////////////////////
/*AUTOLOGIC*/
//////////////////////////////////////////////

logic ch0_ex_bypass;
logic ch0_mem_bypass;
logic ch0_wb_bypass;

logic ch1_ex_bypass;
logic ch1_mem_bypass;
logic ch1_wb_bypass;

//////////////////////////////////////////////
//main code

//ch0
assign ch0_ex_bypass    = ( ex_dest_valid  & (ex_dest_addr[4:0] == id_reg_ch0_addr[4:0]) );
assign ch0_mem_bypass   = ( mem_dest_valid & (mem_dest_addr[4:0] == id_reg_ch0_addr[4:0]) );
assign ch0_wb_bypass    = ( wb_dest_valid  & (wb_dest_addr[4:0] == id_reg_ch0_addr[4:0]) );

assign register_rd_ch0_en           = id_reg_ch0_rd & ( ~(ch0_ex_bypass | ch0_mem_bypass | ch0_wb_bypass) );
assign register_rd_ch0_addr[4:0]    = id_reg_ch0_addr[4:0];

assign id_reg_ch0_data[31:0] = (
            ( {32{ch0_ex_bypass}}   & ex_dest_data[31:0]    ) |
            ( {32{ch0_mem_bypass}}  & mem_dest_data[31:0]   ) |
            ( {32{ch0_wb_bypass}}   & wb_dest_data[31:0]    ) |
            ( register_rd_ch0_data[31:0] )
    );

//ch1
assign ch1_ex_bypass    = ( ex_dest_valid  & (ex_dest_addr[4:0] == id_reg_ch1_addr[4:0]) );
assign ch1_mem_bypass   = ( mem_dest_valid & (mem_dest_addr[4:0] == id_reg_ch1_addr[4:0]) );
assign ch1_wb_bypass    = ( wb_dest_valid  & (wb_dest_addr[4:0] == id_reg_ch1_addr[4:0]) );

assign register_rd_ch1_en           = id_reg_ch1_rd & ( ~(ch1_ex_bypass | ch1_mem_bypass | ch1_wb_bypass) );
assign register_rd_ch1_addr[4:0]    = id_reg_ch1_addr[4:0];

assign id_reg_ch1_data[31:0] = (
            ( {32{ch1_ex_bypass}}   & ex_dest_data[31:0]    ) |
            ( {32{ch1_mem_bypass}}  & mem_dest_data[31:0]   ) |
            ( {32{ch1_wb_bypass}}   & wb_dest_data[31:0]    ) |
            ( register_rd_ch1_data[31:0] )
    );

endmodule
