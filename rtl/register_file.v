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

module register_file(/*AUTOARG*/
        input           clk,
        input           reset_n,

        input           invalid_en,
        input [4:0]     invalid_addr,

        input           rd_ch0_en,
        input [4:0]     rd_ch0_addr,
        output [31:0]   rd_ch0_data,
        output          rd_ch0_dirty,

        input           rd_ch1_en,
        input [4:0]     rd_ch1_addr,
        output [31:0]   rd_ch1_data,
        output          rd_ch1_dirty,

        input           wr_ch0_en,
        input [4:0]     wr_ch0_addr,
        input [31:0]    wr_ch0_data
);

// Local Variables:
// verilog-library-directories:(".")
// End:

//////////////////////////////////////////////
/*AUTOLOGIC*/
//////////////////////////////////////////////

logic [31:0] MEM [31:0];
logic [31:0] dirty_en;

//////////////////////////////////////////////
//main code

assign MEM[0][31:0] = 32'h0;
assign dirty_en[0] = 1'b0;

generate
for(genvar n=1; n<32; n=n+1)begin: register
    always @(posedge clk or negedge reset_n)begin
        if(!reset_n)begin
            MEM[n][31:0] <= 32'h0;
        end else if( wr_ch0_en && (wr_ch0_addr==n))begin
            MEM[n][31:0] <= wr_ch0_data[31:0];
        end
    end
    
    always @(posedge clk or negedge reset_n)begin
        if(!reset_n)begin
            dirty_en[n] <= 1'b0;
        end else if(invalid_en & (invalid_addr==n))begin
            dirty_en[n] <= 1'b1;
        end else if( wr_ch0_en && (wr_ch0_addr==n))begin
            dirty_en[n] <= 1'b0;
        end
    end
end
endgenerate


assign rd_ch0_data[31:0] = {32{rd_ch0_en}} & MEM[rd_ch0_addr[4:0]];
assign rd_ch0_dirty      = rd_ch0_en & dirty_en[rd_ch0_addr[4:0]];

assign rd_ch1_data[31:0] = {32{rd_ch1_en}} & MEM[rd_ch1_addr[4:0]];
assign rd_ch1_dirty      = rd_ch1_en & dirty_en[rd_ch1_addr[4:0]];

endmodule
