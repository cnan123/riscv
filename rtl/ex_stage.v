//================================================================
//   Copyright (C) 2021. All rights reserved.
//
//   Filename     : ex_stage.v
//   Auther       : cnan
//   Created On   : 2021.04.04
//   Description  : 
//
//
//================================================================
import riscv_pkg::*;

module ex_stage#(
    parameter ILLEGAL_CSR_EN = 1'b0
)(
    input                       clk,
    input                       reset_n,

    //pipeline controller
    input                       stall_E, //
    input                       flush_E, //
    input                       ready_mem,
    output logic                ready_ex,

    input [31:0]                pc_id,
    input [31:0]                pc_ex,
    output logic [31:0]         pc_mem,

    //branch jump
    input                       jump_ex,
    output logic [31:0]         jump_target_addr,
    output logic                jump_taken,
    input                       branch_ex,
    output logic [31:0]         branch_target_addr,
    output logic                branch_taken,

    //alu
    input logic                 alu_en_ex,
    input alu_op_e              alu_op_ex,

    input logic [31:0]          src_a_ex,         
    input logic [31:0]          src_b_ex,         
    input logic [31:0]          src_c_ex,         
    
    input logic                 lsu_en_ex,  
    input lsu_op_e              lsu_op_ex,
    input lsu_dtype_e           lsu_dtype_ex,

    input logic                 mult_en_ex,
    input mult_op_e             mult_op_ex,

    input logic                 csr_en_ex,
    input logic [1:0]           csr_op_ex,
    input logic [11:0]          csr_addr_ex,
    input logic [31:0]          csr_wdata_ex,

    input logic                 rd_wr_en_ex,
    input logic [TAG_WIDTH-1:0] rd_wr_tag_ex,
    input logic [4:0]           rd_wr_addr_ex,

    input logic                 exc_taken_ex,

    //next stage
    output logic                lsu_en_mem,  
    output lsu_op_e             lsu_op_mem,
    output lsu_dtype_e          lsu_dtype_mem,
    output logic [31:0]         lsu_addr_mem,
    output logic [31:0]         lsu_wdata_mem,
    
    output logic                exc_taken_mem,
    output logic                is_illegal_csr,

    output logic                rd_wr_en_mem,
    output logic [TAG_WIDTH-1:0]rd_wr_tag_mem,
    output logic [4:0]          rd_wr_addr_mem,
    output logic [31:0]         rd_wr_data_mem,

    output logic                forward_ex_en,
    output logic [TAG_WIDTH-1:0]forward_ex_tag,
    output logic [4:0]          forward_ex_addr,
    output logic [31:0]         forward_ex_wdata,

    output logic                clr_dirty_ex_en,
    output logic [4:0]          clr_dirty_ex_addr,

    //constrol status register
    input         [31:0]        pc_wb,
    input         [31:0]        pc_if,
    input                       extern_intr,
    input                       timer_intr,
    input                       software_intr,
    input   logic [31:0]        hart_id,
    input   logic               is_mret,
    input   logic               mepc_updata,
    input   mepc_mux_e          mepc_mux,
    input                       mcause_update,
    input mcause_e              mcause,
    output privilege_e          privilege_mode,
    output logic                mstatus_mie,
    output logic [31:0]         mtvec,
    output logic [31:0]         mepc,
    output logic [31:0]         mie
);

// Local Variables:
// verilog-library-directories:(".")
// End:

//////////////////////////////////////////////
/*AUTOLOGIC*/
// Beginning of automatic wires (for undeclared instantiated-module outputs)
logic [31:0]		adder_result;		// From u_alu of alu.v
logic			alu_result_valid;	// From u_alu of alu.v
logic			branch_compare_result;	// From u_alu of alu.v
logic [31:0]		csr_rdata;		// From csr_register of csr.v
logic			illegal_csr;		// From csr_register of csr.v
logic [31:0]		logic_result;		// From u_alu of alu.v
logic [63:0]		mul_result;		// From multiplier of multiplier.v
logic [31:0]		quotient;		// From divider of div.v
logic			ready_div;		// From divider of div.v
logic [31:0]		remainder;		// From divider of div.v
// End of automatics
//////////////////////////////////////////////
logic [31:0]    alu_result;
logic [31:0]    shift_result;
logic           branch;
logic           alu;
logic           equal_result;
logic           less_than_result;

logic           mul_en,div_en;
logic           div_sign;
logic [31:0]    mult_res;

logic [31:0]    rd_wr_data_ex;
logic [31:0]    return_addr;
logic           ex_stage_valid;
logic           multicycle_instr;
logic           multicycle_ready;
logic           load;
logic           store;

logic           exc_ex;
//////////////////////////////////////////////
//main code

/* alu AUTO_TEMPLATE(
   	.operator			(alu_op_ex[]),
	.operator_a			(src_a_ex[]),
	.operator_b			(src_b_ex[]));
);
*/

alu u_alu(/*AUTOINST*/
	  // Interfaces
	  .operator			(alu_op_ex),		 // Templated
	  // Outputs
	  .adder_result			(adder_result[31:0]),
	  .logic_result			(logic_result[31:0]),
	  .shift_result			(shift_result[31:0]),
	  .branch_compare_result	(branch_compare_result),
	  .alu_result			(alu_result[31:0]),
	  .alu_result_valid		(alu_result_valid),
	  // Inputs
	  .operator_a			(src_a_ex[31:0]),	 // Templated
	  .operator_b			(src_b_ex[31:0]));	 // Templated



  
/*csr AUTO_TEMPLATE(
    .csr_en		(csr_en_ex),
	.csr_op		(csr_op_ex[]),
	.csr_addr	(csr_addr_ex[]),
	.csr_wdata	(csr_wdata_ex[]),
	.hartid		(hart_id[]),
);
*/
csr csr_register(
    /*AUTOINST*/
		 // Interfaces
		 .mepc_mux		(mepc_mux),
		 .mcause		(mcause),
		 .privilege_mode	(privilege_mode),
		 // Outputs
		 .csr_rdata		(csr_rdata[31:0]),
		 .illegal_csr		(illegal_csr),
		 .mstatus_mie		(mstatus_mie),
		 .mepc			(mepc[31:0]),
		 .mtvec			(mtvec[31:0]),
		 .mie			(mie[31:0]),
		 // Inputs
		 .clk			(clk),
		 .reset_n		(reset_n),
		 .hartid		(hart_id[31:0]),	 // Templated
		 .pc_if			(pc_if[31:0]),
		 .pc_wb			(pc_wb[31:0]),
		 .is_mret		(is_mret),
		 .mepc_updata		(mepc_updata),
		 .mcause_update		(mcause_update),
		 .csr_en		(csr_en_ex),		 // Templated
		 .csr_op		(csr_op_ex[1:0]),	 // Templated
		 .csr_addr		(csr_addr_ex[11:0]),	 // Templated
		 .csr_wdata		(csr_wdata_ex[31:0]),	 // Templated
		 .extern_intr		(extern_intr),
		 .timer_intr		(timer_intr),
		 .software_intr		(software_intr));


//////////////////////////////////////////////
//multiplier
//////////////////////////////////////////////
assign mul_en = mult_en_ex & ( mult_op_ex inside {MUL, MULH, MULHU, MULHSU} );
assign div_en = mult_en_ex & ( mult_op_ex inside {DIV, DIVU, REM, REMU} );
assign div_sign =  ( mult_op_ex inside {DIV, REM} );

always_comb begin
    mult_res[31:0] = 32'h0;
    if(mult_en_ex)begin
        unique case(mult_op_ex)
            MULH, MULHU, MULHSU: mult_res = mul_result[63:32];
            MUL: mult_res = mul_result[31:0];
            DIV, DIVU: mult_res = quotient[31:0];
            REM, REMU: mult_res = remainder[31:0];
            default: mult_res = 32'h0;
        endcase
    end
end

/*multiplier AUTO_TEMPLATE(
    .en (mul_en),
    .result (mul_result[]),
    .op (mult_op_ex),
    .op_a   (src_a_ex[]),
    .op_b   (src_b_ex[]),
);
*/
multiplier multiplier(/*AUTOINST*/
		      // Interfaces
		      .op		(mult_op_ex),		 // Templated
		      // Outputs
		      .result		(mul_result[63:0]),	 // Templated
		      // Inputs
		      .en		(mul_en),		 // Templated
		      .op_a		(src_a_ex[31:0]),	 // Templated
		      .op_b		(src_b_ex[31:0]));	 // Templated


/*div AUTO_TEMPLATE(
    .ready (ready_div ),
    .flush  (flush_E ),
    .en     (div_en),
    .sign   (div_sign),
    .op_a   (src_a_ex[]),
    .op_b   (src_b_ex[]),
);*/
div divider(/*AUTOINST*/
	    // Outputs
	    .quotient			(quotient[31:0]),
	    .remainder			(remainder[31:0]),
	    .ready			(ready_div ),		 // Templated
	    // Inputs
	    .clk			(clk),
	    .reset_n			(reset_n),
	    .flush			(flush_E ),		 // Templated
	    .en				(div_en),		 // Templated
	    .sign			(div_sign),		 // Templated
	    .op_a			(src_a_ex[31:0]),	 // Templated
	    .op_b			(src_b_ex[31:0]));	 // Templated

//////////////////////////////////////////////
//branch
//////////////////////////////////////////////
assign branch_taken = branch_compare_result & alu_en_ex;
assign branch_target_addr = pc_ex + src_c_ex;

//////////////////////////////////////////////
//jump
//////////////////////////////////////////////
assign jump_taken = jump_ex;
assign jump_target_addr = adder_result;

//////////////////////////////////////////////
//control
//////////////////////////////////////////////

assign ready_ex = (~stall_E) & ready_mem & ready_div & (~exc_ex)  ;
assign valid_ex = (~stall_E) & ready_mem & ready_div;

assign return_addr  = pc_id; //next instr


//////////////////////////////////////////////
//pipeline
//////////////////////////////////////////////
always @(posedge clk or negedge reset_n)begin
    if(!reset_n)begin
        lsu_en_mem          <= 1'b0;
        lsu_op_mem          <= LSU_OP_LD;
        lsu_dtype_mem[2:0]  <= LSU_DTYPE_U_BYTE;
        lsu_addr_mem[31:0]  <= 32'h0;
    end else if( (ready_ex & flush_E) | (~ready_ex & ready_mem) )begin
        lsu_en_mem          <= 1'b0;
        lsu_op_mem          <= LSU_OP_LD;
        lsu_dtype_mem[2:0]  <= LSU_DTYPE_U_BYTE;
        lsu_addr_mem[31:0]  <= 32'h0;
    end else if(valid_ex)begin
        lsu_en_mem          <= lsu_en_ex;
        lsu_op_mem          <= lsu_op_ex;
        lsu_dtype_mem[2:0]  <= lsu_dtype_ex[2:0];
        lsu_addr_mem[31:0]  <= adder_result[31:0];
    end
end
assign lsu_wdata_mem[31:0] = rd_wr_data_mem[31:0];

always @(posedge clk or negedge reset_n)begin
    if(!reset_n)begin
        rd_wr_en_mem            <= 1'b0;
        rd_wr_tag_mem           <= {TAG_WIDTH{1'b0}};
        rd_wr_addr_mem[4:0]     <= 5'h0;
        rd_wr_data_mem[31:0]    <= 32'h0;
    end else if( (ready_ex & flush_E) | (~ready_ex & ready_mem) )begin
        rd_wr_en_mem            <= 1'b0;
        rd_wr_addr_mem[4:0]     <= 5'h0;
        rd_wr_data_mem[31:0]    <= 32'h0;
    end else if(valid_ex)begin
        rd_wr_en_mem            <= rd_wr_en_ex;
        rd_wr_tag_mem           <= rd_wr_tag_ex;
        rd_wr_addr_mem[4:0]     <= rd_wr_addr_ex[4:0];
        rd_wr_data_mem[31:0]    <= rd_wr_data_ex[31:0];
    end
end


always @(*)begin
    rd_wr_data_ex = 32'h0;
    if(alu_en_ex)begin
        if(jump_ex)begin
            rd_wr_data_ex = return_addr;
        end else begin
            rd_wr_data_ex = alu_result;
        end
    end

    unique case(1)
        lsu_en_ex:begin
            rd_wr_data_ex = src_c_ex;
        end
        csr_en_ex:begin
            rd_wr_data_ex = csr_rdata;
        end
        mult_en_ex:begin
            rd_wr_data_ex = mult_res;
        end
        default:;
    endcase
end

assign forward_ex_en    = rd_wr_en_ex & valid_ex & (alu_en_ex | div_en ) & (~lsu_en_ex);
assign forward_ex_tag   = rd_wr_tag_ex;
assign forward_ex_addr  = rd_wr_addr_ex;
assign forward_ex_wdata = rd_wr_data_ex;

assign clr_dirty_ex_en      = rd_wr_en_ex & flush_E;
assign clr_dirty_ex_addr    = rd_wr_addr_ex;



//////////////////////////////////////////////////////////////////////////////
//exc control
//exc_taken_id is from ID stage's exc
//illegal_csr is EX stage's exc
/////////////////////////////////////////////////////////////////////////////
always @(posedge clk or negedge reset_n)begin
    if(!reset_n)begin
        pc_mem[31:0] <= 32'h0;
    end else if(valid_ex)begin
        pc_mem[31:0] <= pc_ex[31:0];
    end
end

always @(posedge clk or negedge reset_n)begin
    if(!reset_n)begin
        exc_taken_mem        <= 1'b0;
    end else if((valid_ex & flush_E) | (~valid_ex & ready_mem))begin
        exc_taken_mem        <= 1'b0;
    end else if( valid_ex )begin
        exc_taken_mem        <= exc_taken_ex | exc_ex;
    end
end

generate
if( ILLEGAL_CSR_EN==1)begin:en_illegal_csr
    assign exc_ex = illegal_csr;
    assign is_illegal_csr = illegal_csr & ready_mem;
end else begin: gen_unused_illegal
    assign exc_ex = 1'b0;
    assign is_illegal_csr = 1'b0;
end
endgenerate

endmodule
