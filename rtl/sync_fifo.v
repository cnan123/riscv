//================================================================
//   Copyright (C) 2021. All rights reserved.
//
//   Filename     : sync_fifo.v
//   Auther       : cnan
//   Created On   : 2021.03.13
//   Description  : 
//
//
//================================================================

module sync_fifo#(
    parameter DEPTH = 16,
    parameter DATA_WIDTH = 32
)(
    input                       clk,
    input                       reset_n,

    input                       fifo_clear,

    input                       wr_en,
    input [DATA_WIDTH-1:0]      wr_data,
    output                      fifo_full,
    output                      fifo_almost_full,

    input                       rd_en,
    output logic [DATA_WIDTH-1:0]     rd_data,
    output logic                      rd_data_valid,
    output logic                      fifo_empty
);

// Local Variables:
// verilog-library-directories:("." )
// End:

//////////////////////////////////////////////
/*AUTOLOGIC*/
//////////////////////////////////////////////
logic [DEPTH-1:0]valid;
logic [DEPTH-1:0]pushed_valid;
logic [DEPTH-1:0]poped_valid;
logic [DEPTH-1:0]entry;
logic           pop;
logic           push;
logic [DEPTH-1:0]wr_pointer;
logic [DEPTH-1:0]entry_en;

logic [DATA_WIDTH-1:0] fifo_data_q [DEPTH-1:0];
logic [DATA_WIDTH-1:0] fifo_data_d [DEPTH-1:0];


//////////////////////////////////////////////
//main code


assign pop = rd_en;
assign push = wr_en;

for(genvar i = 0; i < DEPTH; i++) begin 
    if(i==0)begin
        assign wr_pointer[i] = (~valid[i]);
    end else begin
        assign wr_pointer[i] = (~valid[i]) & valid[i-1];
    end

    if(i==0)begin
        assign pushed_valid[i] = push ? 1'b1 : valid[i];
    end else begin
        assign pushed_valid[i] = (push & wr_pointer[i]) | valid[i];
    end

    if( i < (DEPTH-1) )begin
        assign poped_valid[i] = pop ? pushed_valid[i+1] : pushed_valid[i];
        assign entry_en[i] = ( pop & pushed_valid[i+1] ) | ( ~pop & wr_pointer[i] & push );

        assign fifo_data_d[i][DATA_WIDTH-1:0] = valid[i+1] ? fifo_data_q[i+1][DATA_WIDTH-1:0] : wr_data[DATA_WIDTH-1:0];
    end else begin
        assign poped_valid[i] = pop ? 1'b0 : pushed_valid[i];
        assign entry_en[i] = (~pop & wr_pointer[i] & push);

        assign fifo_data_d[i][DATA_WIDTH-1:0] = wr_data[DATA_WIDTH-1:0];
    end
end

always @(posedge clk or negedge reset_n )begin
    if(!reset_n)begin
        valid[DEPTH-1:0] <= {DEPTH{1'b0}};
    end else begin
        valid[DEPTH-1:0] <= poped_valid[DEPTH-1:0] & {DEPTH{ (~fifo_clear) }};
    end
end

for(genvar i = 0; i < DEPTH; i++) begin 
    always @(posedge clk or negedge reset_n)begin
        if(!reset_n) begin
            fifo_data_q[i][DATA_WIDTH-1:0] <= {DATA_WIDTH{1'b0}};
        end else if( entry_en[i] )begin
            fifo_data_q[i][DATA_WIDTH-1:0] <= fifo_data_d[i][DATA_WIDTH-1:0];
        end
    end
end

assign rd_data = fifo_data_q[0];
assign rd_data_valid = valid[0];

assign fifo_full = (&valid[DEPTH-1:0]);
assign fifo_almost_full = (&valid[DEPTH-2:0]);
assign fifo_empty = ~(|valid[DEPTH-1:0]);

endmodule
