//================================================================
//   Copyright (C) 2021. All rights reserved.
//
//   Filename     : bht.sv
//   Auther       : cnan
//   Created On   : 2021.09.25
//   Description  : 
//
//
//================================================================

module bht#(
    parameter DEPTH     = 128,
    parameter G_DEPTH   = 4
)(
    input           clk,
    input           reset_n,

    input [31:0]    pc,

);

// Local Variables:
// verilog-library-directories:(".")
// End:

//////////////////////////////////////////////
/*AUTOLOGIC*/
//////////////////////////////////////////////


//////////////////////////////////////////////
//main code

sat_counter sat_counter(/*AUTOINST*/
			// Inputs
			.clk		(clk),
			.reset_n	(reset_n),
			.update_en	(update_en),
			.taken		(taken),
			.predict_taken	(predict_taken));


endmodule
