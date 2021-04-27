//================================================================
//   Copyright (C) 2021 Sangfor Ltd. All rights reserved.
//
//   Filename     : mem_stage.v
//   Auther       : cnan
//   Created On   : 2021年04月04日
//   Description  : 
//
//
//================================================================

module mem_stage(/*AUTOARG*/
    input           clk,
    input           reset_n,

    input           mem_dest_we_valid,
    input [4:0]     mem_dest_we_addr,
    input [31:0]    mem_dest_we_data,

    input           lsu_valid,
    input           lsu_wr_type,
    input [2:0]     lsu_width_type,
    input [31:0]    lsu_addr,
    input [31:0]    lsu_wdata,

    output          wb_we_valid,
    output [4:0]    wb_we_addr,
    output [31:0]   wb_we_data,

    //controller
    output          mem_stage_ready,
    output          wb_stage_ready,
    input           stall_mem_stage,
    output          load_instr_in_mem,

    //LSU
    output logic          data_req,
    output logic          data_wr,
    input  logic          data_gnt,
    output logic [31:0]   data_addr,
    output logic [31:0]   data_wdata,
    output logic [3:0]    data_be,
    input  logic [31:0]    data_rdata,
    input  logic          data_valid
);

// Local Variables:
// verilog-library-directories:(".")
// End:

//////////////////////////////////////////////
/*AUTOLOGIC*/
//////////////////////////////////////////////
parameter IDLE = 2'b01;
parameter DATA = 2'b10;

parameter BYTE      = 2'b0;
parameter HALF_WORD = 2'd1;
parameter WORD      = 2'd2;

logic           dest_addr_valid_pipe;
logic [4:0]     dest_addr_pipe;
logic [31:0]    dest_data_pipe;

logic       req_unalign;
logic       unalign_q;
logic [31:8]data_rdata_q;
logic [1:0] addr_offset;
logic       wb_lsu_valid;
logic [1:0] wb_lsu_addr_offset;
logic [2:0] wb_lsu_width_type;
logic [31:0]rdata_byte;
logic [31:0]rdata_halfword;
logic [31:0]rdata_word;
logic [31:0]rdata;
logic       signed_extend;

//////////////////////////////////////////////
//main code

assign data_req     = lsu_valid;
assign data_addr    = unalign_q ? lsu_addr+4 : lsu_addr;
assign data_wdata   = lsu_wdata;
assign data_wr      = lsu_wr_type;

assign addr_offset[1:0] = lsu_addr[1:0];

always @(*)begin
    data_be[3:0] = 4'h0;
    case( lsu_width_type[1:0] )
        BYTE:begin
                case( addr_offset[1:0] )
                    2'b00: data_be[3:0] = 4'b0001;
                    2'b01: data_be[3:0] = 4'b0010;
                    2'b10: data_be[3:0] = 4'b0100;
                    2'b11: data_be[3:0] = 4'b1000;
                endcase
        end
        HALF_WORD:begin
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
        ( (lsu_width_type[1:0] == HALF_WORD)    & (addr_offset[1:0] == 2'b11) ) |
        ( (lsu_width_type[1:0] == WORD)         & (addr_offset[1:0] != 2'b00) ) 
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
    end else if(unalign_q & data_valid)begin
        data_rdata_q[31:8] <= data_rdata[31:8];
    end
end

assign mem_stage_ready = lsu_valid ? ( data_gnt & (~req_unalign) ) : 1'b1;
assign load_instr_in_mem = lsu_valid & (~lsu_wr_type);

//////////////////////////////////////////////
//write back
//////////////////////////////////////////////

always @(posedge clk or negedge reset_n)begin
    if( !reset_n )begin
        dest_addr_valid_pipe    <= 1'b0;
        dest_addr_pipe          <= 5'b0;
        dest_data_pipe          <= 32'h0;
        wb_lsu_valid            <= 1'b0;
        wb_lsu_addr_offset[1:0] <= 2'b0;
        wb_lsu_width_type[2:0]  <= 3'b0;
    end else if(~stall_mem_stage & mem_stage_ready) begin
        dest_addr_valid_pipe    <= mem_dest_we_valid;
        dest_addr_pipe          <= mem_dest_we_addr;
        dest_data_pipe          <= mem_dest_we_data;
        wb_lsu_valid            <= load_instr_in_mem;
        wb_lsu_addr_offset[1:0] <= addr_offset[1:0];
        wb_lsu_width_type[2:0]  <= lsu_width_type[2:0];
    end
end

assign signed_extend = ~wb_lsu_width_type[2];
//byte
always @(*)begin
    rdata_byte[31:0] = 32'h0;
    case(wb_lsu_addr_offset[1:0])
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
    case(wb_lsu_addr_offset[1:0])
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
    case(wb_lsu_addr_offset[1:0])
        2'b00:begin rdata_word[31:0] = data_rdata[31:0]; end
        2'b01:begin rdata_word[31:0] = { data_rdata[7:0], data_rdata_q[31:8] }; end
        2'b10:begin rdata_word[31:0] = { data_rdata[15:0], data_rdata_q[31:16] }; end
        2'b11:begin rdata_word[31:0] = { data_rdata[23:0], data_rdata_q[31:24] }; end
    endcase
end

always @(*)begin
    rdata = 32'h0;
    case(wb_lsu_width_type[1:0])
        BYTE:       begin rdata[31:0] = rdata_byte[31:0]; end
        HALF_WORD:  begin rdata[31:0] = rdata_halfword[31:0]; end
        WORD:       begin rdata[31:0] = rdata_word[31:0]; end
        default:    begin rdata[31:0] = 32'h0; end
    endcase
end

assign wb_stage_ready = wb_lsu_valid ? data_valid : 1'b1;

assign wb_we_addr  = dest_addr_pipe;
assign wb_we_valid = wb_lsu_valid ? data_valid : dest_addr_valid_pipe;
assign wb_we_data  = wb_lsu_valid ? rdata : dest_data_pipe;

endmodule
