//================================================================
//   Copyright (C) 2021 Sangfor Ltd. All rights reserved.
//
//   Filename     : tb_memory.v
//   Auther       : cnan
//   Created On   : 2021年04月18日
//   Description  : 
//
//
//================================================================

module tb_memory(
    input               clk,
    input               reset_n,

    input               instr_req,
    input [31:0]        instr_addr,
    output              instr_gnt,
    output [31:0]       instr_rdata,
    output              instr_err,
    output              instr_valid,

    input               data_req,
    input               data_wr,
    output              data_gnt,
    input [31:0]        data_addr,
    input [31:0]        data_wdata,
    input [3:0]         data_byteen,
    output [31:0]       data_rdata,
    output              data_valid
);

// Local Variables:
// verilog-library-directories:(".")
// End:

//////////////////////////////////////////////
/*AUTOLOGIC*/
//////////////////////////////////////////////


//////////////////////////////////////////////
//main code
parameter DEPTH         = 16384*4;
parameter ADDR_WIDTH    = $clog2(DEPTH);

parameter ADDR_L    = 0;
parameter ADDR_H    = 16'hffff;

logic [31:0]    mem    [0:DEPTH-1];
logic [1:0]     req;
logic [1:0]     grant;
logic           instr_pick;
logic           data_pick;
logic           mem_en;
logic           mem_wr;
logic [3:0]     mem_byteen;
logic [31:0]    mem_wdata;
logic [31:0]    mem_rdata;
logic [ADDR_WIDTH-1:0] mem_addr;
logic [31:0]    data_mask;


logic instr_match_mem,data_match_mem;
logic instr_match_none,data_match_none;
logic match_none_instr_pick,match_none_data_pick;

//////////////////////////////////////////////
//response 
//////////////////////////////////////////////
assign instr_gnt            = (instr_match_mem & grant[0]) | instr_match_none;
assign instr_rdata[31:0]    = instr_pick ? mem_rdata[31:0] : 32'hdeadbeef;
assign instr_valid          = instr_pick | match_none_instr_pick;
assign instr_err            = 1'b0;

assign data_gnt             = (data_match_mem & grant[1]) | data_match_none;
assign data_rdata[31:0]     = data_pick ? mem_rdata[31:0] : 32'hdeadbeef;
assign data_valid           = data_pick | match_none_data_pick;

//////////////////////////////////////////////
// router
//////////////////////////////////////////////

assign instr_match_mem  = instr_req & ( instr_addr >= ADDR_L ) & (instr_addr <= ADDR_H );
assign data_match_mem   = data_req & ( data_addr >= ADDR_L ) & (data_addr <= ADDR_H );

assign instr_match_none = instr_req & (~instr_match_mem);
assign data_match_none = data_req & (~data_match_mem);

always @(posedge clk or negedge reset_n)begin
    if(!reset_n)begin
        match_none_instr_pick <= 1'b0;
        match_none_data_pick <= 1'b0;
    end else begin
        match_none_instr_pick   <= instr_match_none;
        match_none_data_pick    <= data_match_none;
    end
end

//////////////////////////////////////////////
//arbiter
//////////////////////////////////////////////

assign req[0]   = instr_match_mem;
assign req[1]   = data_match_mem;


always @(posedge clk or negedge reset_n)begin
    if(!reset_n)begin
        instr_pick <= 1'b0;
        data_pick <= 1'b0;
    end else begin
        instr_pick <= req[0] & grant[0];
        data_pick <= req[1] & grant[1];
    end
end

arbiter #(
    .NUM        (2)
) arbiter(
    .clk        (clk),
    .reset_n    (reset_n),
    .req        (req[1:0]),
    .grant      (grant[1:0])
);


//////////////////////////////////////////////
//memory
//////////////////////////////////////////////
assign mem_en           = ( |grant[1:0] );
assign mem_wr           = ( grant[1] & data_wr );
assign mem_byteen[3:0]  = ( {4{grant[0]}} & 4'hf ) | ( {4{grant[1]}} & data_byteen[3:0] );
assign mem_wdata[31:0]  = data_wdata[31:0];
assign mem_addr[ADDR_WIDTH-1:0] = (
    ( {ADDR_WIDTH{grant[0]}} & instr_addr[ADDR_WIDTH+1:2] ) |
    ( {ADDR_WIDTH{grant[1]}} & data_addr[ADDR_WIDTH+1:2] )
);

assign data_mask[31:0] = { {8{mem_byteen[3]}},{8{mem_byteen[2]}},{8{mem_byteen[1]}},{8{mem_byteen[0]}} };

always @(posedge clk)begin
    if(mem_en & mem_wr)begin
        mem[mem_addr[ADDR_WIDTH-1:0]][31:0] <= (
            ( mem[mem_addr[ADDR_WIDTH-1:0]][31:0] & (~data_mask[31:0]) ) |
            ( mem_wdata[31:0] & data_mask[31:0] )
        );
    end
end

always @(posedge clk)begin
    if(mem_en & ~mem_wr)begin
       mem_rdata[31:0] <= mem[mem_addr[ADDR_WIDTH-1:0]]; 
    end
end

endmodule
