//================================================================
//   Copyright (C) 2021. All rights reserved.
//
//   Filename     : plic.sv
//   Auther       : cnan
//   Created On   : 2021.08.24
//   Description  : 
//
//
//================================================================

module plic(
    input           clk,
    input           reset_n,

    input           extern_irq,
    input           soft_irq,
    input           timer_irq,

    input           is_mret,

    input           mstatus_mie,
    input   [31:0]  mie,

    input           irq_ack,
    output          extern_irq_taken,
    output          soft_irq_taken,
    output          timer_irq_taken
);

// Local Variables:
// verilog-library-directories:("." "dir1" "dir2" ...)
// End:

//////////////////////////////////////////////
/*AUTOLOGIC*/
//////////////////////////////////////////////

logic [1:0] irq_threshold;

//////////////////////////////////////////////
//main code

assign extern_irq_en    = mstatus_mie & mie[BIT_MIE_MEIE];
assign soft_irq_en      = mstatus_mie & mie[BIT_MIE_MSIE];
assign timer_irq_en     = mstatus_mie & mie[BIT_MIE_MTIE];

assign extern_irq_taken    = (irq_threshold[1:0] <= 2'h2) & extern_irq_en   & extern_irq;
assign soft_irq_taken      = (irq_threshold[1:0] <= 2'h1) & soft_irq_en     & soft_irq;
assign timer_irq_taken     = (irq_threshold[1:0] <= 2'h0) & timer_irq_en    & timer_irq;

always @(posedge clk or negedge reset_n)begin
    if(~reset_n)begin
        irq_threshold[1:0] <= 2'h0;
    end else if(is_mret)begin
        irq_threshold[1:0] <= 2'h0;
    end else if(extern_irq_taken & irq_ack)begin
        irq_threshold[1:0] <= 2'h3;
    end else if(soft_irq_taken & irq_ack)begin
        irq_threshold[1:0] <= 2'h2;
    end else if(timer_irq_taken & irq_ack)begin
        irq_threshold[1:0] <= 2'h1;
    end 
end

endmodule
