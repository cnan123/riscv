//================================================================
//   Copyright (C) 2021. All rights reserved.
//
//   Filename     : score_board.sv
//   Auther       : cnan
//   Created On   : 2021.07.10
//   Description  : 
//
//
//================================================================

module score_board#(
    parameter TAG_WIDTH = 2
)(/*AUTOARG*/
    input                   rs1_rd_en,
    input  [4:0]            rs1_rd_addr,
    output [31:0]           rs1_rd_data,
    output                  rs1_rd_value, 
    
    input                   rs2_rd_en,
    input  [4:0]            rs2_rd_addr,
    output [31:0]           rs2_rd_data,
    output                  rs2_rd_value, 

    //no forward port for timing
    input                   rs3_rd_en,
    input  [4:0]            rs3_rd_addr,
    output [31:0]           rs3_rd_data,
    output                  rs3_rd_value, 
    
    input                   forward_ex_en,
    input   [TAG_WIDTH-1:0] forward_ex_tag,
    input   [4:0]           forward_ex_addr,    
    input   [31:0]          forward_ex_wdata,

    input                   forward_mem_en,
    input   [TAG_WIDTH-1:0] forward_mem_tag,
    input   [4:0]           forward_mem_addr,    
    input   [31:0]          forward_mem_wdata,

    input                   forward_wb_en,
    input   [TAG_WIDTH-1:0] forward_wb_tag,
    input   [4:0]           forward_wb_addr,    
    input   [31:0]          forward_wb_wdata,

    output                  rd_rf1_en,
    output  [4:0]           rd_rf1_addr,
    input [TAG_WIDTH-1:0]   rd_rf1_tag,
    input [31:0]            rd_rf1_data,
    input                   rd_rf1_dirty,

    output                  rd_rf2_en,
    output  [4:0]           rd_rf2_addr,
    input [TAG_WIDTH-1:0]   rd_rf2_tag,
    input [31:0]            rd_rf2_data,
    input                   rd_rf2_dirty,

    output                  rd_rf3_en,
    output  [4:0]           rd_rf3_addr,
    input [TAG_WIDTH-1:0]   rd_rf3_tag,
    input [31:0]            rd_rf3_data,
    input                   rd_rf3_dirty
);

// Local Variables:
// verilog-library-directories:("." "dir1" "dir2" ...)
// End:

//////////////////////////////////////////////
/*AUTOLOGIC*/
//////////////////////////////////////////////
logic rs1_ex_bypass;
logic rs1_mem_bypass;
logic rs1_wb_bypass;
logic rs2_ex_bypass;
logic rs2_mem_bypass;
logic rs2_wb_bypass;
logic rs3_ex_bypass;
logic rs3_mem_bypass;
logic rs3_wb_bypass;

//////////////////////////////////////////////
//main code


//////////////////////////////////////////////
//rf0
assign rd_rf1_en        = rs1_rd_en;
assign rd_rf1_addr      = rs1_rd_addr;

assign rs1_rd_value     = (
    ( ~rd_rf1_dirty ) |
    ( rs1_ex_bypass ) |
    ( rs1_mem_bypass) |
    ( rs1_wb_bypass ) 
);

assign rs1_rd_data[31:0]    = (
    ( {32{~rd_rf1_dirty}}   & rd_rf1_data[31:0] ) |
    ( {32{rs1_ex_bypass}}   & forward_ex_wdata[31:0] ) |
    ( {32{rs1_mem_bypass}}  & forward_mem_wdata[31:0] ) |
    ( {32{rs1_wb_bypass}}   & forward_wb_wdata[31:0] ) 
); 

assign rs1_ex_bypass    = ( ( rs1_rd_en & forward_ex_en ) & ( rs1_rd_addr == forward_ex_addr ) & (rs1_rd_addr != 0) & (rd_rf1_tag == forward_ex_tag) );
assign rs1_mem_bypass   = ( ( rs1_rd_en & forward_mem_en) & ( rs1_rd_addr == forward_mem_addr) & (rs1_rd_addr != 0) & (rd_rf1_tag == forward_mem_tag) );
assign rs1_wb_bypass    = ( ( rs1_rd_en & forward_wb_en ) & ( rs1_rd_addr == forward_wb_addr ) & (rs1_rd_addr != 0) & (rd_rf1_tag == forward_wb_tag) );

//////////////////////////////////////////////
//rf1
assign rd_rf2_en        = rs2_rd_en;
assign rd_rf2_addr      = rs2_rd_addr;

assign rs2_rd_value     = (
    ( ~rd_rf2_dirty ) |
    ( rs2_ex_bypass ) |
    ( rs2_mem_bypass) |
    ( rs2_wb_bypass ) 
);

assign rs2_rd_data[31:0]    = (
    ( {32{~rd_rf2_dirty}}   & rd_rf2_data[31:0] ) |
    ( {32{rs2_ex_bypass}}   & forward_ex_wdata[31:0] ) |
    ( {32{rs2_mem_bypass}}  & forward_mem_wdata[31:0] ) |
    ( {32{rs2_wb_bypass}}   & forward_wb_wdata[31:0] ) 
); 

assign rs2_ex_bypass    = ( ( rs2_rd_en & forward_ex_en )   & ( rs2_rd_addr == forward_ex_addr  ) & (rs2_rd_addr != 0) & (rd_rf2_tag == forward_ex_tag) );
assign rs2_mem_bypass   = ( ( rs2_rd_en & forward_mem_en )  & ( rs2_rd_addr == forward_mem_addr ) & (rs2_rd_addr != 0) & (rd_rf2_tag == forward_mem_tag) );
assign rs2_wb_bypass    = ( ( rs2_rd_en & forward_wb_en )   & ( rs2_rd_addr == forward_wb_addr  ) & (rs2_rd_addr != 0) & (rd_rf2_tag == forward_wb_tag) );


//////////////////////////////////////////////
//rf3
assign rd_rf3_en        = rs3_rd_en;
assign rd_rf3_addr      = rs3_rd_addr;

assign rs3_rd_value     = (
    ( ~rd_rf3_dirty ) |
    ( rs3_mem_bypass) 
);

assign rs3_rd_data[31:0]    = (
    ( {32{~rd_rf3_dirty}}   & rd_rf3_data[31:0] ) |
    ( {32{rs3_mem_bypass}}  & forward_mem_wdata[31:0] )
); 

assign rs3_mem_bypass   = ( ( rs3_rd_en & forward_mem_en )  & ( rs3_rd_addr == forward_mem_addr ) & (rs3_rd_addr != 0) & (rd_rf3_tag == forward_mem_tag) );


endmodule
