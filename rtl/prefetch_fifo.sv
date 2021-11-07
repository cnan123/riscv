//================================================================
//   Copyright (C) 2021. All rights reserved.
//
//   Filename     : prefetch_fifo.sv
//   Auther       : cnan
//   Created On   : 2021.11.05
//   Description  : 
//
//
//================================================================

module prefetch_fifo#(
    parameter DATA_WIDTH = 32,
    parameter DEPTH = 4
)(
    input                   clk,
    input                   reset_n,

    input                   fifo_clear,
    input                   fifo_ready,
    output                  fifo_valid,
    output [DATA_WIDTH-1:0] fifo_rdata,

    input                   fifo_wvalid,
    input  [DATA_WIDTH-1:0] fifo_wdata,
    output                  fifo_almost_full
);

// Local Variables:
// verilog-library-directories:("." "dir1" "dir2" ...)
// End:

//////////////////////////////////////////////
/*AUTOLOGIC*/
//////////////////////////////////////////////

logic [DATA_WIDTH-1:0]  fifo_rdata_int;
logic                   fifo_valid_int;
logic                   fifo_empty;

logic                   fifo_pop;
logic                   fifo_push;

//////////////////////////////////////////////
//main code

sync_fifo #(
    .DEPTH(DEPTH),
    .DATA_WIDTH(DATA_WIDTH)
) perfetch_fifo(
		.clk			    (clk                    ),
		.reset_n		    (reset_n                ),

		.fifo_clear		    (fifo_clear             ),

		.wr_en			    (fifo_push              ),
		.wr_data		    (fifo_wdata             ),
		.fifo_full		    (                       ),
        .fifo_almost_full   (fifo_almost_full       ),

		.rd_en			    (fifo_pop               ),
		.rd_data		    (fifo_rdata_int         ),
		.rd_data_valid	    (fifo_valid_int         ),
		.fifo_empty		    (fifo_empty             )
);

assign fifo_valid = fifo_valid_int | (fifo_empty & fifo_wvalid);
assign fifo_rdata = fifo_pop ? fifo_rdata_int : fifo_wdata;

assign fifo_push = fifo_wvalid & ( (~fifo_ready ) | fifo_valid_int );
assign fifo_pop  = fifo_ready & fifo_valid_int;

endmodule
