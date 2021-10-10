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
    parameter DEPTH     = 128
)(
    input           clk,
    input           reset_n,

    input           update_en,
    input           taken,
    input [31:0]    pc_ex,

    input           rd_en,
    input [31:0]    pc_if,
    output logic    predict_taken
);

// Local Variables:
// verilog-library-directories:(".")
// End:

//////////////////////////////////////////////
/*AUTOLOGIC*/
//////////////////////////////////////////////
parameter BHT_WIDTH = $clog2(DEPTH);

logic [DEPTH-1:0][1:0] sat_counter_n;
logic [DEPTH-1:0][1:0] sat_counter_q;

logic [BHT_WIDTH-1:0] addr;
logic [BHT_WIDTH-1:0] r_addr;

//////////////////////////////////////////////
//main code

assign r_addr = pc_if[1+:BHT_WIDTH];

always @(posedge clk or negedge reset_n)begin
    if(!reset_n)begin
        predict_taken <= 1'b0;
    end else if(rd_en)begin
        predict_taken <= sat_counter_q[r_addr][1];
    end
end

assign addr = pc_ex[1+:BHT_WIDTH];

always_comb begin: update_bht
    sat_counter_n = sat_counter_q;

    if( update_en )begin
        if( sat_counter_q[addr][1:0] == 2'b11 )begin
            if(!taken)begin
                sat_counter_n[addr][1:0] = sat_counter_q[addr][1:0] - 1;
            end
        end else if( sat_counter_q[addr][1:0] == 2'b00 ) begin
            if(taken)begin
                sat_counter_n[addr][1:0] = sat_counter_q[addr][1:0] + 1;
            end
        end else begin
            if( taken )begin
                sat_counter_n[addr][1:0] = sat_counter_q[addr][1:0] + 1;
            end else begin
                sat_counter_n[addr][1:0] = sat_counter_q[addr][1:0] - 1;
            end
        end
    end
end

always @(posedge  clk or negedge reset_n)begin
    if(!reset_n) begin
        for(int i=0; i<DEPTH; i++)begin
            sat_counter_q[i][1:0] <= 2'h0;
        end
    end else begin
        sat_counter_q <= sat_counter_n;
    end
end

endmodule
