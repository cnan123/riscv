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
// Beginning of automatic wires (for undeclared instantiated-module outputs)
// End of automatics
//////////////////////////////////////////////


//////////////////////////////////////////////
//main code
parameter DEPTH         = 16384;
parameter ADDR_WIDTH    = $clog2(DEPTH);

parameter IRAM_ADDR_L    = 32'h00000;
parameter IRAM_ADDR_H    = 32'h0ffff;

parameter DRAM_ADDR_L    = 32'h10000;
parameter DRAM_ADDR_H    = 32'h1ffff;


logic ibus_match_iram,ibus_match_dram,ibus_match_default;
logic ibus_iram_pick,ibus_dram_pick,ibus_none_pick;
logic dbus_match_iram,dbus_match_dram,dbus_match_default;
logic dbus_iram_pick,dbus_dram_pick,dbus_none_pick;

logic [1:0] iram_req,iram_grant;
logic iram_en;
logic iram_we;
logic [ADDR_WIDTH-1:0] iram_addr;
logic [3:0] iram_be;
logic [31:0] iram_wdata;
logic [31:0] iram_rdata;

logic [1:0] dram_req,dram_grant;
logic dram_en;
logic dram_we;
logic [ADDR_WIDTH-1:0] dram_addr;
logic [3:0] dram_be;
logic [31:0] dram_wdata;
logic [31:0] dram_rdata;

//////////////////////////////////////////////
//iram router
//////////////////////////////////////////////
assign ibus_match_iram      = instr_req & ( instr_addr >= IRAM_ADDR_L ) & (instr_addr <= IRAM_ADDR_H );
assign ibus_match_dram      = instr_req & ( instr_addr >= DRAM_ADDR_L ) & (instr_addr <= DRAM_ADDR_H );
assign ibus_match_default   = instr_req & ( ~(ibus_match_iram | ibus_match_dram) );

always @(posedge clk or negedge reset_n)begin
    if(!reset_n)begin
        ibus_iram_pick  <= 1'b0;
        ibus_dram_pick  <= 1'b0;
        ibus_none_pick  <= 1'b0;
    end else if( instr_req & instr_gnt )begin
        ibus_iram_pick  <= ibus_match_iram;
        ibus_dram_pick  <= ibus_match_dram;
        ibus_none_pick  <= ibus_match_default;
    end else begin
        ibus_iram_pick  <= 1'b0;
        ibus_dram_pick  <= 1'b0;
        ibus_none_pick  <= 1'b0;
    end
end

assign instr_gnt            = (
    ( ibus_match_iram & iram_grant[0] ) |
    ( ibus_match_dram & dram_grant[0] ) |
    ( ibus_match_default ) 
);

assign instr_rdata[31:0]    = (
    ( {32{ibus_iram_pick}} & iram_rdata ) |
    ( {32{ibus_dram_pick}} & dram_rdata ) |
    ( {32{ibus_none_pick}} & 32'hdeadbeef )
);

assign instr_valid = (
    ibus_iram_pick |
    ibus_dram_pick |
    ibus_none_pick 
);

assign instr_err            = 1'b0;


//////////////////////////////////////////////
//dram router
//////////////////////////////////////////////
assign dbus_match_iram      = data_req & ( data_addr >= IRAM_ADDR_L ) & (data_addr <= IRAM_ADDR_H );
assign dbus_match_dram      = data_req & ( data_addr >= DRAM_ADDR_L ) & (data_addr <= DRAM_ADDR_H );
assign dbus_match_default   = data_req & ( ~(dbus_match_iram | dbus_match_dram) );

always @(posedge clk or negedge reset_n)begin
    if(!reset_n)begin
        dbus_iram_pick  <= 1'b0;
        dbus_dram_pick  <= 1'b0;
        dbus_none_pick  <= 1'b0;
    end else if( data_req & data_gnt )begin
        dbus_iram_pick  <= dbus_match_iram;
        dbus_dram_pick  <= dbus_match_dram;
        dbus_none_pick  <= dbus_match_default;
    end else begin
        dbus_iram_pick  <= 1'b0;
        dbus_dram_pick  <= 1'b0;
        dbus_none_pick  <= 1'b0;
    end
end

assign data_gnt            = (
    ( dbus_match_iram & iram_grant[1] ) |
    ( dbus_match_dram & dram_grant[1] ) |
    ( dbus_match_default ) 
);

assign data_rdata[31:0]    = (
    ( {32{dbus_iram_pick}} & iram_rdata ) |
    ( {32{dbus_dram_pick}} & dram_rdata ) |
    ( {32{dbus_none_pick}} & 32'hdeadbeef )
);

assign data_valid = (
    dbus_iram_pick |
    dbus_dram_pick |
    dbus_none_pick 
);


//////////////////////////////////////////////
//iram
//////////////////////////////////////////////
assign iram_req[0] = ibus_match_iram;
assign iram_req[1] = dbus_match_iram;

arbiter #(
    .NUM        (2)
) arbiter_I(
    .clk        (clk),
    .reset_n    (reset_n),
    .req        (iram_req[1:0]),
    .grant      (iram_grant[1:0])
);


assign iram_en = (
    (iram_req[0] & iram_grant[0]) | 
    (iram_req[1] & iram_grant[1])
);

assign iram_we = (
    (iram_req[1] & iram_grant[1] & data_wr )
);

assign iram_addr = (
    ( { ADDR_WIDTH {iram_grant[0]} } & instr_addr[2+:ADDR_WIDTH] ) |
    ( { ADDR_WIDTH {iram_grant[1]} } & data_addr[2+:ADDR_WIDTH] ) 
);

assign iram_be = (
    ( {4{iram_grant[0]}} & 4'hf ) |
    ( {4{iram_grant[1]}} & data_byteen ) 
);

assign iram_wdata = (
    ( {32{iram_grant[1]}} & data_wdata )
);

sram #(
    .DEPTH		(DEPTH)
)iram(
    .clk		(clk),
    .en		    (iram_en),
    .we		    (iram_we),
    .addr		(iram_addr[ADDR_WIDTH-1:0]),
    .be		    (iram_be[3:0]),
    .wdata		(iram_wdata[31:0]),
    .rdata		(iram_rdata[31:0])
);


//////////////////////////////////////////////
//dram
//////////////////////////////////////////////
assign dram_req[0] = ibus_match_dram;
assign dram_req[1] = dbus_match_dram;

arbiter #(
    .NUM        (2)
) arbiter_D(
    .clk        (clk),
    .reset_n    (reset_n),
    .req        (dram_req[1:0]),
    .grant      (dram_grant[1:0])
);


assign dram_en = (
    (dram_req[0] & dram_grant[0]) | 
    (dram_req[1] & dram_grant[1])
);

assign dram_we = (
    (dram_req[1] & dram_grant[1] & data_wr )
);

assign dram_addr = (
    ( { ADDR_WIDTH {dram_grant[0]} } & instr_addr[2+:ADDR_WIDTH] ) |
    ( { ADDR_WIDTH {dram_grant[1]} } & data_addr[2+:ADDR_WIDTH] ) 
);

assign dram_be = (
    ( {4{dram_grant[0]}} & 4'hf ) |
    ( {4{dram_grant[1]}} & data_byteen ) 
);

assign dram_wdata = (
    ( {32{dram_grant[1]}} & data_wdata )
);


sram #(
    .DEPTH		(DEPTH)
)dram(
    .clk		(clk),
    .en		    (dram_en),
    .we		    (dram_we),
    .addr		(dram_addr[ADDR_WIDTH-1:0]),
    .be		    (dram_be[3:0]),
    .wdata		(dram_wdata[31:0]),
    .rdata		(dram_rdata[31:0])
);

endmodule
