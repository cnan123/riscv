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

    input           mem_dest_valid,
    input [4:0]     mem_dest_addr,
    input [31:0]    mem_dest_data,

    input           mem_stage_valid,
    input [4:0]     mem_stage_type,
    input [31:0]    mem_stage_addr,
    input [31:0]    mem_stage_wdata,

    output          wb_valid,
    output [4:0]    wb_addr,
    output [31:0]   wb_data,

    output          mem_busy,

    //LSU
    output          data_req,
    output          data_wr,
    input           data_gnt,
    output [31:0]   data_addr,
    output [31:0]   data_wdata,
    output [3:0]    data_byteen,
    input [31:0]    data_rdata,
    input           data_valid
);

// Local Variables:
// verilog-library-directories:(".")
// End:

//////////////////////////////////////////////
/*AUTOLOGIC*/
//////////////////////////////////////////////

logic           dest_addr_valid_pipe;
logic [4:0]     dest_addr_pipe;
logic [31:0]    dest_data_pipe;

logic           store;

//////////////////////////////////////////////
//main code
assign req = mem_stage_type[4];
assign wr = mem_stage_type[3];
assign width = mem_stage_type[2:0];

always @(posedge clk or negedge reset_n)begin
    if(!reset_n)begin
        fsm_lsu_cs[1:0] <= IDLE;
    end else begin
        fsm_lsu_cs[1:0] <= DATA;
    end
end

always @(*)begin
    fsm_lsu_ns = fsm_lsu_cs;
    case( fsm_lsu_cs )
        IDLE: begin
            if(data_req & data_gnt)begin
                fsm_lsu_ns == DATA;
            end
        end
        DATA:begin
            if( data_valid )begin
                if( data_req )begin
                    fsm_lsu_ns == DATA;
                end else begin
                    fsm_lsu_ns == IDLE;
                end
            end
        end
        default: fsm_lsu_ns == IDLE;
        end
    endcase
end

assign data_req = req;
assign data_addr = mem_stage_addr;
assign data_wdata = mem_stage_wdata;

always @(*)begin
    data_be[3:0] = 4'h0;
    case( width[2:0] )
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
                    else data_be[3:0] = 3'b1100;
                end
                2'b11: begin
                    if(unalign_q) data_be[3:0] = 4'b0111;
                    else data_be[3:0] =4'b1000;
                end
            end
        end
        default: data_be[3:0] = 4'b1111;
    endcase
end

always @(posedge clk or negedge reset_n)begin
    if(!reset_n)begin
        mem_type_q[1:0] <= 2'b0;
    end else begin
    end
end


//////////////////////////////////////////////
//write back
//////////////////////////////////////////////
assign wb_addr  = dest_addr_pipe;
assign wb_valid = ( dest_addr_valid_pipe & (~store) );
assign wb_data  = dest_data_pipe;

always @(posedge clk or negedge reset_n)begin
    if( !reset_n )begin
        dest_addr_valid_pipe    <= 1'b0;
        dest_addr_pipe          <= 5'b0;
        dest_data_pipe          <= 32'h0;
    end else begin
        dest_addr_valid_pipe    <= mem_dest_valid;
        dest_addr_pipe          <= mem_dest_addr;
        dest_data_pipe          <= mem_dest_data;
    end
end

//TODO
assign data_req         = 1'b0;
assign data_addr[31:0]  = 32'h0;
assign data_wdata[31:0] = 32'h0;
assign data_byteen[3:0] = 4'h0;

assign mem_busy         = 1'b0;
assign store            = 1'b0;

endmodule
