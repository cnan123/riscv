//================================================================
//   Copyright (C) 2021. All rights reserved.
//
//   Filename     : mem_wrap.sv
//   Auther       : cnan
//   Created On   : 2021.09.21
//   Description  : 
//
//
//================================================================

module mem_wrap#(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    input                               clk,
    input                               reset_n,

    input                               en,
    input                               wr,
    input           [ADDR_WIDTH-1:0]    addr,
    input           [DATA_WIDTH-1:0]    wdata,
    output logic    [DATA_WIDTH-1:0]    rdata
);

// Local Variables:
// verilog-library-directories:("." "dir1" "dir2" ...)
// End:

//////////////////////////////////////////////
/*AUTOLOGIC*/
//////////////////////////////////////////////

parameter DEPTH = 1<<ADDR_WIDTH;

logic [DATA_WIDTH-1:0] MEM[DEPTH-1:0];

//////////////////////////////////////////////
//main code

always @(posedge clk or negedge reset_n)begin
    if(!reset_n)begin
        for(int i=0; i<DEPTH;i++)begin
            MEM[i] <= {DATA_WIDTH{1'b0}};
        end
    end else if(en & wr)begin
        MEM[addr] <= wdata;
    end
end


always @(posedge clk or negedge reset_n)begin
    if(!reset_n)begin
        rdata[DATA_WIDTH-1:0] <= {DATA_WIDTH{1'b0}};
    end else if( en & ~wr )begin
        rdata[DATA_WIDTH-1:0] <= MEM[addr];
    end
end

endmodule
