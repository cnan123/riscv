//================================================================
//   Copyright (C) 2021. All rights reserved.
//
//   Filename     : div.sv
//   Auther       : cnan
//   Created On   : 2021.09.05
//   Description  : 
//
//
//================================================================

module div(
    input               clk,
    input               reset_n,

    input               flush, //pipeline flush

    input               en,
    input               sign,
    input [31:0]        op_a,
    input [31:0]        op_b,

    output [31:0]       quotient,
    output [31:0]       remainder,
    output              ready
);

// Local Variables:
// verilog-library-directories:("." "dir1" "dir2" ...)
// End:

//////////////////////////////////////////////
/*AUTOLOGIC*/
//////////////////////////////////////////////

parameter IDLE = 2'h0;
parameter WORK = 2'h1;
parameter FINISH = 2'h2;

logic [1:0] fsm_cs,fsm_ns;

logic [4:0] cnt;
logic [31:0] quotient_q;
logic [31:0] remainder_q;
logic [31:0] denominator_q;
logic        r_sign;
logic [32:0] sub_add;
logic [31:0] remainder_u,remainder_s;
logic [31:0] quotient_u, quotient_s;
logic        div_by_zero,div_by_zero_q;

//////////////////////////////////////////////
//main code

assign div_by_zero = ( op_b[31:0] == 0 );

always @(posedge clk or negedge reset_n)begin
    if(!reset_n)begin
        fsm_cs <= IDLE;
    end else if(flush)begin
        fsm_cs <= IDLE;
    end else begin
        fsm_cs <= fsm_ns;
    end
end

always_comb begin
    fsm_ns = fsm_cs;
    case(fsm_cs)
        IDLE:begin
            if( en )begin
                if( div_by_zero )begin
                    fsm_ns = FINISH; 
                end else begin
                    fsm_ns = WORK;
                end
            end
        end 
        WORK: begin
            if( (cnt == 31) )begin
                fsm_ns = FINISH;
            end
        end
        FINISH:begin
            fsm_ns = IDLE;
        end
        default:;
    endcase
end

always @(posedge clk or negedge reset_n)begin
    if( !reset_n )begin
        r_sign          <= 1'b0;
        cnt             <= 5'd0;
        quotient_q      <= 32'h0;
        remainder_q     <= 32'h0;
        denominator_q   <= 32'h0;
        div_by_zero_q   <= 1'b0;
    end else if( (fsm_cs== IDLE) & en )begin
        r_sign          <= 1'b0;
        cnt             <= 5'd0;
        quotient_q      <= 32'h0;
        remainder_q     <= 32'h0;
        denominator_q   <= 32'h0;
        div_by_zero_q   <= div_by_zero;
        
        if(sign)begin
            if( op_a[31] )begin
                quotient_q <= (~op_a + 1);
            end else begin
                quotient_q <= op_a;
            end
        
            if( op_b[31] )begin
                denominator_q <= (~op_b + 1); 
            end else begin
                denominator_q <= op_b;
            end
        end else begin
            quotient_q <= op_a;
            denominator_q <= op_b;
        end
    end else if(fsm_cs == WORK )begin
        r_sign      <= sub_add[32];
        remainder_q <= sub_add[31:0];
        quotient_q  <= { quotient_q[30:0], ~sub_add[32] };
        cnt         <= cnt + 1;
    end
end

assign sub_add = r_sign ? ( { remainder_q[31:0], quotient_q[31]} + { 1'b0, denominator_q[31:0] } ) :
                          ( { remainder_q[31:0], quotient_q[31]} - { 1'b0, denominator_q[31:0] } ) ;

assign remainder_u  = r_sign ? remainder_q + denominator_q : remainder_q;
assign remainder_s  = op_a[31] ? ~remainder_u+1 : remainder_u;

assign quotient_u   = quotient_q;
assign quotient_s   = (op_a[31] ^ op_b[31]) ? ~quotient_u+1 : quotient_u;

assign remainder    = div_by_zero_q ? op_a[31:0] : sign ? remainder_s : remainder_u;
assign quotient     = div_by_zero_q ? {32{1'b1}} : sign ? quotient_s : quotient_u;

assign ready = ( (fsm_cs==IDLE) & ~en ) | (fsm_cs==FINISH);

endmodule
