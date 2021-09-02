//================================================================
//   Copyright (C) 2021. All rights reserved.
//
//   Filename     : lsu.sv
//   Auther       : cnan
//   Created On   : 2021.07.18
//   Description  : 
//
//
//================================================================

module lsu(
    input                       clk,
    input                       reset_n,

    input logic                 lsu_en,  
    input lsu_op_e              lsu_op,
    input lsu_dtype_e           lsu_dtype,
    input logic [31:0]          lsu_addr,
    input logic [31:0]          lsu_wdata,
    output logic                lsu_ready,

    output logic [31:0]         lsu_rdata,
    output logic                lsu_valid,
    output logic                lsu_err,

    //data req
    output logic                data_req,
    output logic                data_wr,
    input  logic                data_gnt,
    output logic [31:0]         data_addr,
    output logic [31:0]         data_wdata,
    output logic [3:0]          data_be,
    input  logic [31:0]         data_rdata,
    input  logic                data_valid,
    input                       data_error // PMP check fail or error reponse
);

// Local Variables:
// verilog-library-directories:("." "dir1" "dir2" ...)
// End:

//////////////////////////////////////////////
/*AUTOLOGIC*/
//////////////////////////////////////////////

logic [1:0]     addr_offset;
logic [1:0]     addr_offset_q;
logic           req_unalign;
logic           unalign_q;
logic [31:8]    data_rdata_q;
lsu_dtype_e     lsu_dtype_q;
logic           signed_extend;
logic [31:0]    rdata_byte;
logic [31:0]    rdata_halfword;
logic [31:0]    rdata_word;
logic           unalign_first_err;
logic           unalign_wb;

//////////////////////////////////////////////
//main code

localparam BYTE = 2'b00;
localparam HALF_WORD = 2'b01;
localparam WORD = 2'b10;

//if lsu_ready isn't 1, lsu_en/lsu_op/lsu_addr/lsu_wdata must hold
//when lsu_ready is 1, pipeline can go to WB stage
//At WB stage wait lsu_rdata_value
always @(*)begin
    lsu_ready = 1'b1;
    if(lsu_en)begin
        if( req_unalign )begin
            lsu_ready = unalign_q & data_gnt;
        end else begin
            lsu_ready = data_gnt;
        end
    end
end

assign data_req     = lsu_en;
assign data_addr    = unalign_q ? lsu_addr+4 : lsu_addr;
assign data_wr      = (lsu_op == LSU_OP_WR);

assign addr_offset[1:0] = lsu_addr[1:0];

always @(*)begin
    data_be[3:0]        = 4'h0;
    data_wdata[31:0]    = 32'h0;
    case( lsu_dtype[1:0] )
        BYTE:begin
             data_wdata[31:0] = {4{lsu_wdata[7:0]}};
             case( addr_offset[1:0] )
                 2'b00: data_be[3:0] = 4'b0001;
                 2'b01: data_be[3:0] = 4'b0010;
                 2'b10: data_be[3:0] = 4'b0100;
                 2'b11: data_be[3:0] = 4'b1000;
             endcase
        end
        HALF_WORD:begin
            data_wdata[31:0] = {2{lsu_wdata[15:0]}};
            case( addr_offset[1:0] )
                    2'b00: data_be[3:0] = 4'b0011;
                    2'b01: data_be[3:0] = 4'b0110;
                    2'b10: data_be[3:0] = 4'b1100;
                    2'b11: begin
                        if(unalign_q) data_be[3:0] = 4'b0001;
                        else data_be[3:0] = 4'b1000;
                    end
            endcase
        end
        WORD:begin
            data_wdata[31:0] = lsu_wdata[31:0];
            case( addr_offset[1:0] )
                2'b00: data_be[3:0] = 4'b1111;
                2'b01: begin
                    if(unalign_q) data_be[3:0] = 4'b0001;
                    else data_be[3:0] = 4'b1110;
                end
                2'b10: begin
                    if(unalign_q) data_be[3:0] = 4'b0011;
                    else data_be[3:0] = 4'b1100;
                end
                2'b11: begin
                    if(unalign_q) data_be[3:0] = 4'b0111;
                    else data_be[3:0] =4'b1000;
                end
            endcase
        end
        default: data_be[3:0] = 4'b1111;
    endcase
end

assign req_unalign = (
        ( (lsu_dtype[1:0] == HALF_WORD)    & (addr_offset[1:0] == 2'b11) ) |
        ( (lsu_dtype[1:0] == WORD)         & (addr_offset[1:0] != 2'b00) ) 
);

always @(posedge clk or negedge reset_n)begin
    if(!reset_n)begin
        unalign_q <= 1'b0;
    end else if(unalign_q & data_gnt )begin
        unalign_q <= 1'b0;
    end else if(data_gnt) begin
        unalign_q <= req_unalign;
    end
end

always @(posedge clk or negedge reset_n)begin
    if(!reset_n)begin
        data_rdata_q[31:8] <= 24'h0;
        unalign_first_err <= 1'b0;
    end else if(unalign_q & data_valid)begin
        data_rdata_q[31:8] <= data_rdata[31:8];
        unalign_first_err <= data_error;
    end
end

always @(posedge clk or negedge reset_n)begin
    if(!reset_n)begin
        addr_offset_q[1:0]  <= 2'b0;
        lsu_dtype_q[2:0]    <= 3'b0;
    end else if(data_req & data_gnt)begin
        addr_offset_q[1:0]  <= addr_offset;
        lsu_dtype_q         <= lsu_dtype;
    end
end

assign signed_extend = ~lsu_dtype_q[2];
//byte
always @(*)begin
    rdata_byte[31:0] = 32'h0;
    case(addr_offset_q[1:0])
        2'b00:begin
            if(signed_extend)begin
                rdata_byte[31:0] = { {24{data_rdata[7]}}, data_rdata[7:0] };
            end else begin
                rdata_byte[31:0] = { 24'h0,data_rdata[7:0] };
            end
        end
        2'b01:begin
            if(signed_extend)begin
                rdata_byte[31:0] = { {24{data_rdata[15]}}, data_rdata[15:8] };
            end else begin
                rdata_byte[31:0] = { 24'h0,data_rdata[15:8] };
            end
        end
        2'b10:begin
            if(signed_extend)begin
                rdata_byte[31:0] = { {24{data_rdata[23]}}, data_rdata[23:16] };
            end else begin
                rdata_byte[31:0] = { 24'h0,data_rdata[23:16] };
            end
        end
        2'b11:begin
            if(signed_extend)begin
                rdata_byte[31:0] = { {24{data_rdata[31]}}, data_rdata[31:24] };
            end else begin
                rdata_byte[31:0] = { 24'h0,data_rdata[31:24] };
            end
        end
    endcase
end

//halfword
always @(*)begin
    rdata_halfword[31:0] = 32'h0;
    case(addr_offset_q[1:0])
        2'b00:begin
            if(signed_extend)begin
                rdata_halfword[31:0] = { {16{data_rdata[15]}}, data_rdata[15:0] };
            end else begin
                rdata_halfword[31:0] = { 16'h0,data_rdata[15:0] };
            end
        end
        2'b01:begin
            if(signed_extend)begin
                rdata_halfword[31:0] = { {16{data_rdata[23]}}, data_rdata[23:8] };
            end else begin
                rdata_halfword[31:0] = { 16'h0,data_rdata[23:8] };
            end
        end
        2'b10:begin
            if(signed_extend)begin
                rdata_halfword[31:0] = { {16{data_rdata[31]}}, data_rdata[31:16] };
            end else begin
                rdata_halfword[31:0] = { 16'h0,data_rdata[31:16] };
            end
        end
        2'b11:begin
            if(signed_extend)begin
                rdata_halfword[31:0] = { {16{data_rdata[31]}}, data_rdata[7:0],data_rdata_q[31:24] };
            end else begin
                rdata_halfword[31:0] = { 16'h0, data_rdata[7:0],data_rdata_q[31:24] };
            end
        end
    endcase
end

//word
always @(*)begin
    rdata_word[31:0] = 32'h0;
    case(addr_offset_q[1:0])
        2'b00:begin rdata_word[31:0] = data_rdata[31:0]; end
        2'b01:begin rdata_word[31:0] = { data_rdata[7:0], data_rdata_q[31:8] }; end
        2'b10:begin rdata_word[31:0] = { data_rdata[15:0], data_rdata_q[31:16] }; end
        2'b11:begin rdata_word[31:0] = { data_rdata[23:0], data_rdata_q[31:24] }; end
    endcase
end

always @(*)begin
    lsu_rdata = 32'h0;
    case(lsu_dtype_q[1:0])
        BYTE:       begin lsu_rdata[31:0] = rdata_byte[31:0]; end
        HALF_WORD:  begin lsu_rdata[31:0] = rdata_halfword[31:0]; end
        WORD:       begin lsu_rdata[31:0] = rdata_word[31:0]; end
        default:    begin lsu_rdata[31:0] = 32'h0; end
    endcase
end

assign unalign_wb = (
        ( (lsu_dtype_q[1:0] == HALF_WORD)    & (addr_offset_q[1:0] == 2'b11) ) |
        ( (lsu_dtype_q[1:0] == WORD)         & (addr_offset_q[1:0] != 2'b00) ) 
);

assign lsu_valid    = (~unalign_q) & data_valid;
assign lsu_err      = unalign_wb ? ( lsu_valid & (data_error | unalign_first_err) ) : (lsu_valid & data_error);

endmodule
