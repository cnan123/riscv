//================================================================
//   Copyright (C) 2021. All rights reserved.
//
//   Filename     : sram.sv
//   Auther       : cnan
//   Created On   : 2021.09.11
//   Description  : 
//
//
//================================================================

module sram #(
    parameter DEPTH = 16384
)(
    input                       clk,

    input                       en,
    input                       we,
    input [$clog2(DEPTH)-1:0]   addr,
    input [3:0]                 be,
    input [31:0]                wdata,
    output logic [31:0]         rdata
);

// Local Variables:
// verilog-library-directories:("." "dir1" "dir2" ...)
// End:

//////////////////////////////////////////////
/*AUTOLOGIC*/
//////////////////////////////////////////////

logic [31:0] MEM [DEPTH-1:0];
logic [31:0] data_mask; 

//////////////////////////////////////////////
//main code
assign data_mask[31:0] = { {8{be[3]}},{8{be[2]}},{8{be[1]}},{8{be[0]}} };

always @(posedge clk)begin
    if( en & we )begin
        MEM[addr][31:0] <= ( MEM[addr][31:0] & (~data_mask[31:0]) ) | (wdata & data_mask);
    end
end

always @(posedge clk)begin
    if(en & (~we) )begin
        rdata <= MEM[addr];
    end
end

endmodule
