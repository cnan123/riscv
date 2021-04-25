//================================================================
//   Copyright (C) 2021 Sangfor Ltd. All rights reserved.
//
//   Filename     : arbiter.v
//   Auther       : cnan
//   Created On   : 2021年04月18日
//   Description  : 
//
//
//================================================================

module arbiter #(
    parameter NUM = 2
)(
    input               clk,
    input               reset_n,

    input [NUM-1:0]     req,
    output [NUM-1:0]    grant
);

// Local Variables:
// verilog-library-directories:("." "dir1" "dir2" ...)
// End:

//////////////////////////////////////////////
/*AUTOLOGIC*/
//////////////////////////////////////////////

logic [NUM-1:0][1:0]    weight;
logic [1:0]             max_weight;
logic [NUM-1:0]         masked_req;
logic [NUM-1:0]         next_pri;
logic                   update_pri;
logic [NUM-1:0]         prio;
genvar n;
integer i;

//////////////////////////////////////////////
//main code


generate
for(n=0;n<NUM;n=n+1)begin
    assign weight[n][1] = req[n];
    assign weight[n][0] = req[n] & prio[n];
end
endgenerate

always @(*)begin
    max_weight[1:0] = 2'b0;
    for(i=0;i<NUM;i=i+1)begin
        max_weight[1:0] |= weight[i][1:0];
    end
end

for(n=0;n<NUM;n=n+1)begin
    assign masked_req[n] = ( weight[n][1:0] == max_weight[1:0] ) & req[n];

    if(n==0)begin
        assign grant[n] = masked_req[n];
    end else begin
        assign grant[n] = grant[n-1] ? 1'b0 : masked_req[n];
    end

    if(n==NUM)begin
        assign next_pri[n] = 1'b1;
    end else begin
        assign next_pri[n] = grant[n] ? 1'b0 : next_pri[n+1]; 
    end
end

assign update_pri = ( | req[NUM-1:0] );

always @(posedge clk or negedge reset_n)begin
    if(!reset_n)begin
        prio[NUM-1:0] <= {NUM{1'b1}};
    end else if(update_pri)begin
        prio[NUM-1:0] <= next_pri[NUM-1:0];
    end
end

endmodule
