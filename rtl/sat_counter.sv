//================================================================
//   Copyright (C) 2021. All rights reserved.
//
//   Filename     : perdict_counter.sv
//   Auther       : cnan
//   Created On   : 2021.10.01
//   Description  : 
//
//
//================================================================

module sat_counter(
    input       clk,
    input       reset_n,

    input       update_en,
    input       taken,

    input       predict_taken
);

// Local Variables:
// verilog-library-directories:("." "dir1" "dir2" ...)
// End:

//////////////////////////////////////////////
/*AUTOLOGIC*/
//////////////////////////////////////////////

logic [1:0] sat_counter;

//////////////////////////////////////////////
//main code

assign predict_taken = sat_counter[1];

always @(posedge clk or negedge reset_n)begin
    if(!reset_n)begin
        sat_counter[1:0] <= 2'h0;
    end else if(update_en)begin
        if( sat_counter[1:0] == 2'b11 )begin
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
