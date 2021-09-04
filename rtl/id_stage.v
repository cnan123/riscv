//================================================================
//   Copyright (C) 2021. All rights reserved.
//
//   Filename     : id_stage.v
//   Auther       : cnan
//   Created On   : 2021.04.02
//   Description  : 
//
//
//================================================================

import riscv_pkg::*;

module id_stage(
    input                       clk,
    input                       reset_n,
    
    //if stsge
    input [31:0]                pc_id,
    input [31:0]                instr_payload,
    input                       instr_value,
    input                       instr_fetch_error, //PMP or Bus error respone. TODO

    //pipeline control
    input                       stall_D,
    input                       flush_D,
    input                       ready_ex,
    output                      ready_id,

    //intr
    input                       extern_irq_taken,
    input                       soft_irq_taken,
    input                       timer_irq_taken,

    input                       debug_req, //TODO

    //write back
    input                       forward_ex_en,
    input [TAG_WIDTH-1:0]       forward_ex_tag,
    input [4:0]                 forward_ex_addr,
    input [31:0]                forward_ex_wdata,
    input                       forward_mem_en,
    input [TAG_WIDTH-1:0]       forward_mem_tag,
    input [4:0]                 forward_mem_addr,
    input [31:0]                forward_mem_wdata,
    input                       rf_wr_wb_en,
    input [TAG_WIDTH-1:0]       rf_wr_wb_tag,
    input [4:0]                 rf_wr_wb_addr,
    input [31:0]                rf_wr_wb_data,

    input                       clr_dirty_ex_en,
    input [4:0]                 clr_dirty_ex_addr,
    input                       clr_dirty_mem_en,
    input [4:0]                 clr_dirty_mem_addr,
    input                       clr_dirty_wb_en,
    input [4:0]                 clr_dirty_wb_addr,

    output logic                jump_ex,
    output logic                branch_ex,
    //alu
    output logic                alu_en_ex,
    output alu_op_e             alu_op_ex,
    output logic [31:0]         src_a_ex,         
    output logic [31:0]         src_b_ex,         
    output logic [31:0]         src_c_ex,         
    
    output logic                lsu_en_ex,  
    output lsu_op_e             lsu_op_ex,
    output lsu_dtype_e          lsu_dtype_ex,

    output logic                csr_en_ex,
    output logic [1:0]          csr_op_ex,
    output logic [11:0]         csr_addr_ex,
    output logic [31:0]         csr_wdata_ex,

    output logic                rd_wr_en_ex,
    output logic [TAG_WIDTH-1:0]rd_wr_tag_ex,
    output logic [4:0]          rd_wr_addr_ex,

    output logic                exc_taken_ex,
    output logic                is_ecall,
    output logic                is_ebreak,
    output logic                is_mret,
    output logic                is_sret,
    output logic                is_uret,
    output logic                is_wfi,
    output logic                is_fence,
    output logic                is_illegal_instr,
    output logic                is_instr_acs_fault,
    output logic                is_interrupt,

    output logic [31:0]         pc_ex
);

// Local Variables:
// verilog-auto-inst-param-value:t                                                  
// verilog-library-directories:("." )
// End:

//////////////////////////////////////////////
/*AUTOLOGIC*/

src_a_mux_e             src_a_mux;
src_b_mux_e             src_b_mux;
src_c_mux_e             src_c_mux;

logic [31:0]            src_a_id;
logic [31:0]            src_b_id;
logic [31:0]            src_c_id;

logic                   rs1_rd_en;
logic [4:0]             rs1_rd_addr;
logic [31:0]            rs1_rd_data;
logic                   rs1_rd_value;

logic                   rs2_rd_en;
logic [4:0]             rs2_rd_addr;
logic [31:0]            rs2_rd_data;
logic                   rs2_rd_value;

logic                   rd_rf1_en;
logic [TAG_WIDTH-1:0]   rd_rf1_tag;
logic [4:0]             rd_rf1_addr;
logic [31:0]            rd_rf1_data;
logic                   rd_rf1_dirty;

logic                   rd_rf2_en;
logic [TAG_WIDTH-1:0]   rd_rf2_tag;
logic [4:0]             rd_rf2_addr;
logic [31:0]            rd_rf2_data;
logic                   rd_rf2_dirty;

logic                   alu_en_id;
alu_op_e                alu_op_id;
logic                   branch_id;
logic                   jump_id;

logic                   lsu_en_id;
lsu_op_e                lsu_op_id;
lsu_dtype_e             lsu_dtype_id;

logic                   csr_en_id;
logic [1:0]             csr_op_id;
logic [11:0]            csr_addr_id;

logic                   rd_wr_en_id;
logic [TAG_WIDTH-1:0]   rd_wr_tag_id;
logic [4:0]             rd_wr_addr_id;
   
logic [31:0]            imm_itype; 
logic [31:0]            imm_stype;
logic [31:0]            imm_utype;
logic [31:0]            imm_btype;
logic [31:0]            imm_jtype;
logic [31:0]            imm_rs1;

logic                   ecall_en;
logic                   ebreak_en;
logic                   mret_en;
logic                   sret_en;
logic                   uret_en;
logic                   wfi_en;
logic                   fence_en;
logic                   illegal_instr;

logic [4:0]             exc_cause;
logic [5:0]             exc_casue_id;

logic                   read_rf_busy;
logic                   exc_taken_id;
logic                   valid_id;

//////////////////////////////////////////////
//main code


//////////////////////////////////////////////
//src mux
always @(*)begin
    src_a_id = 32'h0;
    unique case( src_a_mux )
        SRC_A_REG_RS1     :begin src_a_id = rs1_rd_data;end    
        SRC_A_IMM_UTYPE   :begin src_a_id = imm_utype;end
        SRC_A_PC_ID       :begin src_a_id = pc_id;end
        SRC_A_IMM_RS1     :begin src_a_id = imm_rs1;end
        default:begin src_a_id = 32'h0;end
    endcase
end

always @(*)begin
    src_b_id = 32'h0;
    unique case( src_b_mux )
        SRC_B_REG_RS2     :begin src_b_id = rs2_rd_data;end 
        SRC_B_IMM_ITYPE   :begin src_b_id = imm_itype;end
        SRC_B_IMM_UTYPE   :begin src_b_id = imm_utype;end
        SRC_B_IMM_JTYPE   :begin src_b_id = imm_jtype;end
        SRC_B_IMM_STYPE   :begin src_b_id = imm_stype;end        
        SRC_B_ZERO        :begin src_b_id = 32'h0; end
        default:begin src_b_id = 32'h0; end
    endcase
end

always @(*)begin
    src_c_id = 32'h0;
    unique case( src_c_mux )
        SRC_C_IMM_BTYPE   :begin src_c_id = imm_btype;end
        SRC_C_REG_RS2     :begin src_c_id = rs2_rd_data;end
        SRC_C_CSR_ADDR    :begin src_c_id = {20'h0, csr_addr_id[11:0]};end
        default:begin src_c_id = 32'h0; end
    endcase
end

decoder decoder( /*AUTOINST*/
		.clk			    (clk),
		.reset_n		    (reset_n),

		.instr_payload		(instr_payload[31:0]),
		.instr_value		(instr_value),

		.rs1_rd_en		    (rs1_rd_en),
		.rs1_rd_addr		(rs1_rd_addr[4:0]),
		.rs2_rd_en		    (rs2_rd_en),
		.rs2_rd_addr		(rs2_rd_addr[4:0]),

		.alu_en			    (alu_en_id),
		.alu_op			    (alu_op_id),
		.branch			    (branch_id),
        .jump               (jump_id),

		.lsu_en			    (lsu_en_id),
		.lsu_op			    (lsu_op_id),
		.lsu_dtype		    (lsu_dtype_id),

		.csr_en			    (csr_en_id),
		.csr_op			    (csr_op_id[1:0]),
		.csr_addr		    (csr_addr_id[11:0]),

		.src_a_mux		    (src_a_mux),
		.src_b_mux		    (src_b_mux),
		.src_c_mux		    (src_c_mux),
		
        .rd_wr_en		    (rd_wr_en_id),
		.rd_wr_addr		    (rd_wr_addr_id[4:0]),

		.imm_itype		    (imm_itype[31:0]),
		.imm_stype		    (imm_stype[31:0]),
		.imm_utype		    (imm_utype[31:0]),
		.imm_btype		    (imm_btype[31:0]),
		.imm_jtype		    (imm_jtype[31:0]),
		.imm_rs1		    (imm_rs1[31:0]),

		.ecall_en		    (ecall_en),
		.ebreak_en		    (ebreak_en),
		.mret_en		    (mret_en),
		.sret_en		    (sret_en),
		.uret_en		    (uret_en),
		.wfi_en		        (wfi_en),
		.fence_en		    (fence_en),
		.illegal_instr		(illegal_instr)
);


score_board #(
        .TAG_WIDTH          (TAG_WIDTH)
)score_board (
        .rs1_rd_en		    (rs1_rd_en),
        .rs1_rd_addr		(rs1_rd_addr[4:0]),
        .rs1_rd_data		(rs1_rd_data[31:0]),
        .rs1_rd_value		(rs1_rd_value),

        .rs2_rd_en		    (rs2_rd_en),
        .rs2_rd_addr		(rs2_rd_addr[4:0]),
        .rs2_rd_data		(rs2_rd_data[31:0]),
        .rs2_rd_value		(rs2_rd_value),

        .rd_rf1_en		    (rd_rf1_en),
        .rd_rf1_addr		(rd_rf1_addr[4:0]),
        .rd_rf1_tag		    (rd_rf1_tag[TAG_WIDTH-1:0]),
        .rd_rf1_data		(rd_rf1_data[31:0]),
        .rd_rf1_dirty		(rd_rf1_dirty),

        .rd_rf2_en		    (rd_rf2_en),
        .rd_rf2_addr		(rd_rf2_addr[4:0]),
        .rd_rf2_tag		    (rd_rf2_tag[TAG_WIDTH-1:0]),
        .rd_rf2_data		(rd_rf2_data[31:0]),
        .rd_rf2_dirty		(rd_rf2_dirty),

        .forward_ex_en		(forward_ex_en),
        .forward_ex_tag	    (forward_ex_tag[TAG_WIDTH-1:0]),
        .forward_ex_addr	(forward_ex_addr[4:0]),
        .forward_ex_wdata	(forward_ex_wdata[31:0]),

        .forward_mem_en		(forward_mem_en),
        .forward_mem_tag	(forward_mem_tag[TAG_WIDTH-1:0]),
        .forward_mem_addr	(forward_mem_addr[4:0]),
        .forward_mem_wdata	(forward_mem_wdata[31:0]),

        .forward_wb_en		(rf_wr_wb_en),
        .forward_wb_tag	    (rf_wr_wb_tag[TAG_WIDTH-1:0]),
        .forward_wb_addr	(rf_wr_wb_addr[4:0]),
        .forward_wb_wdata	(rf_wr_wb_data[31:0])
);

register_file #(
        .TAG_WIDTH          (TAG_WIDTH)
)rf(
		 .clk			    (clk),
		 .reset_n		    (reset_n),

         .clr_dirty_ex_en   (clr_dirty_ex_en),
         .clr_dirty_ex_addr (clr_dirty_ex_addr),

         .clr_dirty_mem_en  (clr_dirty_mem_en),
         .clr_dirty_mem_addr(clr_dirty_mem_addr),

         .clr_dirty_wb_en   (clr_dirty_wb_en),
         .clr_dirty_wb_addr (clr_dirty_wb_addr),

		 .rd_ch0_en		    (rd_rf1_en),
		 .rd_ch0_addr		(rd_rf1_addr[4:0]),
		 .rd_ch0_data		(rd_rf1_data[31:0]),
		 .rd_ch0_dirty		(rd_rf1_dirty),
         .rd_ch0_tag        (rd_rf1_tag[TAG_WIDTH-1:0]),

		 .rd_ch1_en		    (rd_rf2_en),
		 .rd_ch1_addr		(rd_rf2_addr[4:0]),
		 .rd_ch1_data		(rd_rf2_data[31:0]),
		 .rd_ch1_dirty		(rd_rf2_dirty),
         .rd_ch1_tag        (rd_rf2_tag[TAG_WIDTH-1:0]),

		 .invalid_en		(rd_wr_en_id & ready_id & (~flush_D)),
		 .invalid_addr		(rd_wr_addr_id[4:0]),
         .new_tag           (rd_wr_tag_id[TAG_WIDTH-1:0]),

		 .wr_ch0_en		    (rf_wr_wb_en),
		 .wr_ch0_addr		(rf_wr_wb_addr[4:0]),
         .wr_ch0_tag        (rf_wr_wb_tag[TAG_WIDTH-1:0]),
		 .wr_ch0_data		(rf_wr_wb_data[31:0])
);


//////////////////////////////////////////////
//pipeline register
//////////////////////////////////////////////
always @(posedge clk or negedge reset_n)begin
    if(!reset_n)begin
        pc_ex[31:0] <= 32'b0;
    end else if( valid_id ) begin
        pc_ex[31:0] <= pc_id[31:0];
    end
end

//pipeline
assign stall_id = read_rf_busy | stall_D;

assign ready_id = (~stall_id) & ready_ex & (~exc_taken_id);
assign valid_id = (~stall_id) & ready_ex & instr_value;

assign read_rf_busy = (rs1_rd_en & (~rs1_rd_value)) | (rs2_rd_en & (~rs2_rd_value));

always @(posedge clk or negedge reset_n)begin
    if(!reset_n)begin
        alu_en_ex       <= 1'b0;
        alu_op_ex       <= ALU_NONE;

        lsu_en_ex       <= 1'b0;
        lsu_op_ex       <= LSU_OP_LD;
        lsu_dtype_ex    <= LSU_DTYPE_U_BYTE;
        
        csr_en_ex       <= 1'b0;
        csr_op_ex       <= CSR_OP_READ;

        src_a_ex        <= 32'h0;
        src_b_ex        <= 32'h0;
        src_c_ex        <= 32'h0;

        branch_ex       <= 1'b0;
        jump_ex         <= 1'b0;

        rd_wr_en_ex     <= 1'b0;
        rd_wr_tag_ex    <= {TAG_WIDTH{1'b0}};
        rd_wr_addr_ex   <= 5'h0;
    end else if( (flush_D & ready_id) | ((~ready_id) & ready_ex) )begin
    //flush pipeline: program flow was broken such as jump/branch/interrupt/exception
        alu_en_ex       <= 1'b0;
        lsu_en_ex       <= 1'b0;
        csr_en_ex       <= 1'b0;
        branch_ex       <= 1'b0;
        jump_ex         <= 1'b0;
        rd_wr_en_ex     <= 1'b0;
    end else if( ready_id )begin
    //flow pipeline :ID stage is ready
        alu_en_ex       <= alu_en_id;
        alu_op_ex       <= alu_op_id;

        lsu_en_ex       <= lsu_en_id;
        lsu_op_ex       <= lsu_op_id;
        lsu_dtype_ex    <= lsu_dtype_id;
        
        csr_en_ex       <= csr_en_id;
        csr_op_ex       <= csr_op_id;

        src_a_ex        <= src_a_id;
        src_b_ex        <= src_b_id;
        src_c_ex        <= src_c_id;

        branch_ex       <= branch_id;
        jump_ex         <= jump_id;

        rd_wr_en_ex     <= rd_wr_en_id;
        rd_wr_tag_ex    <= rd_wr_tag_id;
        rd_wr_addr_ex   <= rd_wr_addr_id;
    end
end

assign csr_addr_ex[11:0]    = src_c_ex[11:0];
assign csr_wdata_ex[31:0]   = src_a_ex[31:0];


//TODO fpu
//TODO mult
//TODO div

//=======================================================================//
//interrupt/exception control
//if exc taken at ID stage, it will stll F/D until pipeline flush
//only ready_ex the control can get exc status because it can be mask by
//EX/MEM/WB stage's exc
//=======================================================================//
assign instr_acs_fault = (instr_value & instr_fetch_error);

assign exception_taken_id = ecall_en | ebreak_en | illegal_instr | instr_acs_fault | mret_en | uret_en | fence_en | wfi_en;

assign interrupt_taken_id   = (~flush_D) & (extern_irq_taken | soft_irq_taken | timer_irq_taken) & valid_id; 
assign exc_taken_id       = (exception_taken_id | interrupt_taken_id);

always @(posedge clk or negedge reset_n)begin
    if(!reset_n)begin
        exc_taken_ex        <= 1'b0;
    end else if( (valid_id & flush_D) | (~valid_id & ready_ex)  )begin
        exc_taken_ex        <= 1'b0;
    end else if( valid_id & (~exc_taken_ex) )begin
        exc_taken_ex        <= exception_taken_id | interrupt_taken_id;
    end
end

assign is_ecall             = ready_ex & ecall_en;
assign is_ebreak            = ready_ex & ebreak_en;
assign is_mret              = ready_ex & mret_en;
assign is_sret              = ready_ex & sret_en;
assign is_uret              = ready_ex & uret_en;
assign is_wfi               = ready_ex & wfi_en;
assign is_fence             = ready_ex & fence_en;
assign is_illegal_instr     = ready_ex & illegal_instr;
assign is_instr_acs_fault   = ready_ex & instr_acs_fault;
assign is_interrupt         = ready_ex & interrupt_taken_id;

endmodule
