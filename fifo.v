//================================================================
//   Copyright (C) 2021 Sangfor Ltd. All rights reserved.
//
//   Filename     : fifo.v
//   Auther       : cnan
//   Created On   : 2021年03月27日
//   Description  : 
//
//
//================================================================

module fifo#(
    parameter DEPTH = 4,
    parameter DATA_WIDTH = 32
)(/*AUTOARG*/
    input                       clk,
    input                       reset_n,

    //pop
    input                       rd_en,
    output  [DATA_WIDTH-1:0]    rd_data,
    output                      rd_data_valid,
    output                      fifo_empty,
    output  [$clog2(DEPTH)-1:0)]fifo_rcount,

    //push
    input                       wr_en,
    input   [DATA_WIDTH-1:0]    wr_data,
    output  [$clog2(DEPTH)-1:0] fifo_wcount,
    output                      fifo_full
);

// Local Variables:
// verilog-library-directories:("." "dir1" "dir2" ...)
// End:

//////////////////////////////////////////////
/*AUTOLOGIC*/
//////////////////////////////////////////////


//////////////////////////////////////////////
//main code
generate
for(genvar n=0; n<DEPTH; n=n+1)begin
    always @(posedge clk or negedge reset_n)begin
        if( !reset_n )begin
            MEM[i] <= {DEPTH{1'b0}};
        end else if( wr_en & (~fifo_full) & (wr_addr[ADDR_WIDTH-1:0]==n) )begin
            MEM[i] <= wr_data[DATA_WIDTH-1:0];  
        end
end
endgenerate

/*****************************************************************/
//wr addr
/*****************************************************************/




endmodule
