//================================================================
//   Copyright (C) 2021 Sangfor Ltd. All rights reserved.
//
//   Filename     : id_stage.v
//   Auther       : cnan
//   Created On   : 2021年04月02日
//   Description  : 
//
//
//================================================================

import riscv_pkg::*;

module id_stage(
    input                       clk,
    input                       reset_n,
    
    //if stsge
    input [31:0]                pc_if,
    input [31:0]                instr_payload,
    input                       instr_value,
    input                       instr_fetch_error, //PMP or Bus error respone

    //pipeline control
    input                       stall_D,
    input                       flush_D,
    input                       ready_ex,
    output                      ready_id,

    //intr
    input                       irq_req,
    input [4:0]                 irq_id,
    input                       irq_taken_wb,
    output                      irq_ack,

    input                       debug_req, //TODO

    //write back
    input                       forward_ex_en,
    input [4:0]                 forward_ex_addr,
    input [31:0]                forward_ex_wdata,
    input                       forward_mem_en,
    input [4:0]                 forward_mem_addr,
    input [31:0]                forward_mem_wdata,
    input                       rf_wr_wb_en,
    input [4:0]                 rf_wr_wb_addr,
    input [31:0]                rf_wr_wb_data,

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
    output logic [4:0]          rd_wr_addr_ex,

    output logic                exc_taken_ex,
    output logic [5:0]          exc_cause_ex,
    output logic [31:0]         exc_tval_ex,

    output logic [31:0]         pc_id
);

// Local Variables:
// verilog-auto-inst-param-value:t                                                  
// verilog-library-directories:("." )
// End:

//////////////////////////////////////////////
/*AUTOLOGIC*/

src_a_mux_e     src_a_mux;
src_b_mux_e     src_b_mux;
src_c_mux_e     src_c_mux;

logic [31:0]    src_a_id;
logic [31:0]    src_b_id;
logic [31:0]    src_c_id;

logic           rs1_rd_en;
logic [4:0]     rs1_rd_addr;
logic [31:0]    rs1_rd_data;
logic           rs1_rd_value;

logic           rs2_rd_en;
logic [4:0]     rs2_rd_addr;
logic [31:0]    rs2_rd_data;
logic           rs2_rd_value;

logic           rd_rf1_en;
logic [4:0]     rd_rf1_addr;
logic [31:0]    rd_rf1_data;
logic           rd_rf1_dirty;

logic           rd_rf2_en;
logic [4:0]     rd_rf2_addr;
logic [31:0]    rd_rf2_data;
logic           rd_rf2_dirty;

logic           alu_en_id;
alu_op_e        alu_op_id;
logic           branch_id;
logic           jump_id;

logic           lsu_en_id;
lsu_op_e        lsu_op_id;
lsu_dtype_e     lsu_dtype_id;

logic           csr_en_id;
logic [1:0]     csr_op_id;
logic [11:0]    csr_addr_id;

logic           rd_wr_en_id;
logic [4:0]     rd_wr_addr_id;
   
logic [31:0]    imm_itype; 
logic [31:0]    imm_stype;
logic [31:0]    imm_utype;
logic [31:0]    imm_btype;
logic [31:0]    imm_jtype;
logic [31:0]    imm_rs1;

logic           ecall_en;
logic           ebreak_en;
logic           illegal_instr;

logic [4:0]     exc_cause;
logic [5:0]     exc_casue_id;

logic           read_rf_busy;
logic           exc_taken_id;
logic           valid_id;

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
		.illegal_instr		(illegal_instr)
);


score_board score_board (
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
        .rd_rf1_data		(rd_rf1_data[31:0]),
        .rd_rf1_dirty		(rd_rf1_dirty),

        .rd_rf2_en		    (rd_rf2_en),
        .rd_rf2_addr		(rd_rf2_addr[4:0]),
        .rd_rf2_data		(rd_rf2_data[31:0]),
        .rd_rf2_dirty		(rd_rf2_dirty),

        .forward_ex_en		(forward_ex_en),
        .forward_ex_addr	(forward_ex_addr[4:0]),
        .forward_ex_wdata	(forward_ex_wdata[31:0]),

        .forward_mem_en		(forward_mem_en),
        .forward_mem_addr	(forward_mem_addr[4:0]),
        .forward_mem_wdata	(forward_mem_wdata[31:0]),

        .forward_wb_en		(rf_wr_wb_en),
        .forward_wb_addr	(rf_wr_wb_addr[4:0]),
        .forward_wb_wdata	(rf_wr_wb_data[31:0])
);

register_file rf(
		 .clk			    (clk),
		 .reset_n		    (reset_n),

		 .rd_ch0_en		    (rd_rf1_en),
		 .rd_ch0_addr		(rd_rf1_addr[4:0]),
		 .rd_ch0_data		(rd_rf1_data[31:0]),
		 .rd_ch0_dirty		(rd_rf1_dirty),

		 .rd_ch1_en		    (rd_rf2_en),
		 .rd_ch1_addr		(rd_rf2_addr[4:0]),
		 .rd_ch1_data		(rd_rf2_data[31:0]),
		 .rd_ch1_dirty		(rd_rf2_dirty),

		 .invalid_en		(rd_wr_en_id),
		 .invalid_addr		(rd_wr_addr_id[4:0]),

		 .wr_ch0_en		    (rf_wr_wb_en),
		 .wr_ch0_addr		(rf_wr_wb_addr[4:0]),
		 .wr_ch0_data		(rf_wr_wb_data[31:0])
);


//////////////////////////////////////////////
//pipeline register
//////////////////////////////////////////////
always @(posedge clk or negedge reset_n)begin
    if(!reset_n)begin
        pc_id[31:0] <= 32'b0;
    end else if( valid_id ) begin
        pc_id[31:0] <= pc_if[31:0];
    end
end

//pipeline
assign ready_id = ( ( ~read_rf_busy ) & ready_ex & (~stall_D) ) | (exc_taken_id);
assign valid_id = ( ~read_rf_busy ) & ready_ex & (~stall_D);

assign read_rf_busy = (rs1_rd_en & (~rs1_rd_value)) | (rs2_rd_en & (~rs2_rd_value));

always @(posedge clk or negedge reset_n)begin
    if(!reset_n)begin
        alu_en_ex       <= 1'b0;
        alu_op_ex       <= ALU_ADD;

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
        rd_wr_addr_ex   <= 5'h0;
    end else if( flush_D & ready_id )begin
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
//irq_req must continue to irq_ack
//
//=======================================================================//
assign instr_acs_fault = (instr_value & instr_fetch_error);

assign exception_taken_id = ecall_en | ebreak_en | illegal_instr | instr_acs_fault;
assign interrupt_taken_id = ( instr_value & irq_req );
assign exc_taken_id       = (exception_taken_id | interrupt_taken_id) & valid_id;

always @(*)begin
    exc_cause[4:0] = 5'b0;
    unique case(1)
        ecall_en        :begin exc_cause = ECAUSE_ECALL; end
        ebreak_en       :begin exc_cause = ECAUSE_EBREAK; end
        illegal_instr   :begin exc_cause = ECAUSE_ILLEGAL_INSTR; end
        instr_acs_fault :begin exc_cause = ECAUSE_INSTR_FAULT; end
        default         :begin exc_cause = 5'b0; end
    endcase
end

assign exc_casue_id[5:0] = exception_taken_id ? {1'b0,exc_cause[4:0]} : {1'b1, irq_id[4:0]};

assign irq_ack = irq_taken_wb;

always @(posedge clk or negedge reset_n)begin
    if(!reset_n)begin
        exc_taken_ex        <= 1'b0;
        exc_cause_ex[5:0]   <= 6'h0;
        exc_tval_ex[31:0]   <= 32'h0;
    end else if(valid_id & flush_D)begin
        exc_taken_ex        <= 1'b0;
        exc_cause_ex[5:0]   <= 6'h0;
        exc_tval_ex[31:0]   <= 32'h0;
    end else if( valid_id & exc_taken_ex )begin
        exc_taken_ex        <= exception_taken_id | interrupt_taken_id;
        exc_cause_ex[5:0]   <= exc_casue_id[5:0];
        exc_tval_ex[31:0]   <= 32'h0; //TODO
    end
end

endmodule
