//================================================================
//   Copyright (C) 2021. All rights reserved.
//
//   Filename     : wb_stage.sv
//   Auther       : cnan
//   Created On   : 2021.07.18
//   Description  : 
//
//
//================================================================

module wb_stage(/*AUTOARG*/
    input                       clk,
    input                       reset_n,

    input logic [31:0]          pc_wb,

    input logic                 rd_wr_en_wb,
    input logic [TAG_WIDTH-1:0] rd_wr_tag_wb,
    input logic [4:0]           rd_wr_addr_wb,
    input logic [31:0]          rd_wr_data_wb,
    input logic                 lsu_en_wb,
    input lsu_op_e              lsu_op_wb,
    input logic [31:0]          lsu_rdata_wb,
    input logic                 lsu_valid_wb,
    input logic                 lsu_err_wb,
    input logic                 exc_taken_wb,

    output logic                ready_wb,
    input logic                 flush_W,

    output logic                clr_dirty_wb_en,
    output logic [4:0]          clr_dirty_wb_addr,

    output logic                rf_wr_en,
    output logic [TAG_WIDTH-1:0]rf_wr_tag,
    output logic [4:0]          rf_wr_addr,
    output logic [31:0]         rf_wr_data,

    output logic                is_lsu_load_err,
    output logic                is_lsu_store_err,
    output logic                exc_taken
);

// Local Variables:
// verilog-library-directories:("." "dir1" "dir2" ...)
// End:

//////////////////////////////////////////////
/*AUTOLOGIC*/
//////////////////////////////////////////////


//////////////////////////////////////////////
//main code
assign ready_wb    = lsu_en_wb ? lsu_valid_wb & (~lsu_err_wb) : 1'b1;

assign rf_wr_en    = ready_wb & rd_wr_en_wb & (~flush_W);
assign rf_wr_tag   = rd_wr_tag_wb;
assign rf_wr_addr  = rd_wr_addr_wb;
assign rf_wr_data  = (lsu_en_wb & (lsu_op_wb==LSU_OP_LD)) ? lsu_rdata_wb : rd_wr_data_wb;

assign clr_dirty_wb_en      = ready_wb & rd_wr_en_wb & flush_W;
assign clr_dirty_wb_addr    = rd_wr_addr_wb;

assign is_lsu_load_err      = lsu_valid_wb & lsu_err_wb & (lsu_op_wb==LSU_OP_LD);
assign is_lsu_store_err     = lsu_valid_wb & lsu_err_wb & (lsu_op_wb==LSU_OP_WR);

assign exc_taken            = exc_taken_wb | is_lsu_load_err | is_lsu_store_err;

endmodule
