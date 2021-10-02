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



always_comb begin: update_bht
    sat_counter_n = sat_counter_q;

    if( update_en )begin
        if( sat_counter_q[updata_pc][][1:0] == 2'b11 )begin
            if(!taken)begin
                sat_counter[1:0] <= sat_counter[1:0] - 1;
            end
        end else if( sat_counter[1:0] == 2'b00 ) begin
            if(taken)begin
                sat_counter[1:0] <= sat_counter[1:0] + 1;
            end
        end else begin
            if( taken )begin
                sat_counter[1:0] <= sat_counter[1:0] + 1;
            end else begin
                sat_counter[1:0] <= sat_counter[1:0] - 1;
            end
        end
    end
end



endmodule
