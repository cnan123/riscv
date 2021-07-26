//================================================================
//   Copyright (C) 2021 Sangfor Ltd. All rights reserved.
//
//   Filename     : csr_register.v
//   Auther       : cnan
//   Created On   : 2021年05月19日
//   Description  : 
//
//
//================================================================

module csr_register#(
    parameter DATA_WIDTH = 32,
    parameter DEFAULT   = 32'h0
)(
    input                   clk,
    input                   reset_n,

    input                   en,
    input [1:0]             op,
    input [DATA_WIDTH-1:0]  data_n,
    output [DATA_WIDTH-1:0] data_q
);

parameter CSR_OP_READ       = 2'b00;
parameter CSR_OP_WRITE      = 2'b01;
parameter CSR_OP_SET        = 2'b10;
parameter CSR_OP_CLEAR      = 2'b11;


// Local Variables:
// verilog-library-directories:("." "dir1" "dir2" ...)
// End:

//////////////////////////////////////////////
/*AUTOLOGIC*/
//////////////////////////////////////////////


//////////////////////////////////////////////
//main code

always @(posedge clk or negedge reset_n)begin
    if(!reset_n)begin
        data_q[DATA_WIDTH-1:0] <= DEFAULT;
    end else if(en)begin
        if( op==CSR_OP_SET )begin
            data_q[DATA_WIDTH-1:0] <= (data_q[DATA_WIDTH-1:0] | data_n[DATA_WIDTH-1:0]);
        end else if( op == CSR_OP_WRITE )begin
            data_q[DATA_WIDTH-1:0] <= data_n[DATA_WIDTH-1:0];
        end else if( op== CSR_OP_CLEAR )begin
            data_q[DATA_WIDTH-1:0] <= data_q[DATA_WIDTH-1:0] & (~data_n[DATA_WIDTH-1:0]);
        end
    end
end

endmodule
