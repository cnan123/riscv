//================================================================
//   Copyright (C) 2021 Sangfor Ltd. All rights reserved.
//
//   Filename     : register_file.v
//   Auther       : cnan
//   Created On   : 2021年04月05日
//   Description  : 
//
//
//================================================================

module register_file#(
    parameter TAG_WIDTH = 2
)(/*AUTOARG*/
        input                       clk,
        input                       reset_n,

        input                       clr_dirty_ex_en,
        input [4:0]                 clr_dirty_ex_addr,
        input                       clr_dirty_mem_en,
        input [4:0]                 clr_dirty_mem_addr,
        input                       clr_dirty_wb_en,
        input [4:0]                 clr_dirty_wb_addr,

        input                       invalid_en,
        input [4:0]                 invalid_addr,
        output [TAG_WIDTH-1:0]      new_tag,

        input                       rd_ch0_en,
        input [4:0]                 rd_ch0_addr,
        output [31:0]               rd_ch0_data,
        output                      rd_ch0_dirty,
        output [TAG_WIDTH-1:0]      rd_ch0_tag,

        input                       rd_ch1_en,
        input [4:0]                 rd_ch1_addr,
        output [31:0]               rd_ch1_data,
        output                      rd_ch1_dirty,
        output [TAG_WIDTH-1:0]      rd_ch1_tag,

        input                       wr_ch0_en,
        input [4:0]                 wr_ch0_addr,
        input [TAG_WIDTH-1:0]       wr_ch0_tag,
        input [31:0]                wr_ch0_data
);

// Local Variables:
// verilog-library-directories:(".")
// End:

//////////////////////////////////////////////
/*AUTOLOGIC*/
//////////////////////////////////////////////

logic [31:0] MEM [31:0];
logic [31:0] dirty_en;
logic [31:0] clr_dirty;
logic [TAG_WIDTH-1:0] tag [31:0];
logic [TAG_WIDTH-1:0] tag_n [31:0];

//////////////////////////////////////////////
//main code

assign MEM[0][31:0] = 32'h0;
assign dirty_en[0] = 1'b0;

assign tag[0][TAG_WIDTH-1:0] = {TAG_WIDTH{1'b0}};
assign tag_n[0][TAG_WIDTH-1:0] = {TAG_WIDTH{1'b0}};

generate
for(genvar n=1; n<32; n=n+1)begin: register
    always @(posedge clk or negedge reset_n)begin
        if(!reset_n)begin
            MEM[n][31:0] <= 32'h0;
        end else if( wr_ch0_en && (wr_ch0_addr==n))begin
            MEM[n][31:0] <= wr_ch0_data[31:0];
        end
    end
    
    assign clr_dirty[n] = (
        ( clr_dirty_ex_en   & (clr_dirty_ex_addr==n)    ) |
        ( clr_dirty_mem_en  & (clr_dirty_mem_addr==n)   ) |
        ( clr_dirty_wb_en   & (clr_dirty_wb_addr==n)    )
    );

    always @(posedge clk or negedge reset_n)begin
        if(!reset_n)begin
            dirty_en[n] <= 1'b0;
        end else if(clr_dirty[n])begin
            dirty_en[n] <= 1'b0;
        end else if(invalid_en & (invalid_addr==n))begin
            dirty_en[n] <= 1'b1;
        end else if( wr_ch0_en && (wr_ch0_addr==n) & (wr_ch0_tag==tag[n]) )begin
            dirty_en[n] <= 1'b0;
        end
    end
    
    always @(posedge clk or negedge reset_n)begin
        if( !reset_n )begin
            tag[n][TAG_WIDTH-1:0] <= {TAG_WIDTH{1'b0}};
        end else begin
            tag[n][TAG_WIDTH-1:0] <= tag_n[n][TAG_WIDTH-1:0];
        end
    end

    always @(*)begin
        tag_n[n][TAG_WIDTH-1:0] = tag[n][TAG_WIDTH-1:0];
        if(invalid_en & invalid_addr==n)begin
            tag_n[n][TAG_WIDTH-1:0] = tag[n][TAG_WIDTH-1:0] + 1'b1;
        end
    end
end
endgenerate

assign new_tag[TAG_WIDTH-1:0]   = tag_n[invalid_addr[4:0]];

assign rd_ch0_data[31:0]            = {32{rd_ch0_en}} & MEM[rd_ch0_addr[4:0]];
assign rd_ch0_dirty                 = rd_ch0_en & dirty_en[rd_ch0_addr[4:0]];
assign rd_ch0_tag[TAG_WIDTH-1:0]    = tag[rd_ch0_addr[4:0]];

assign rd_ch1_data[31:0]            = {32{rd_ch1_en}} & MEM[rd_ch1_addr[4:0]];
assign rd_ch1_dirty                 = rd_ch1_en & dirty_en[rd_ch1_addr[4:0]];
assign rd_ch1_tag[TAG_WIDTH-1:0]    = tag[rd_ch1_addr[4:0]];

endmodule
