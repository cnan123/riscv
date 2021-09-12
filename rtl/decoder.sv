//================================================================
//   Copyright (C) 2021. All rights reserved.
//
//   Filename     : decoder.sv
//   Auther       : cnan
//   Created On   : 2021.07.10
//   Description  : 
//
//
//================================================================
import riscv_pkg::*;

module decoder(/*AUTOARG*/
    input           clk,
    input           reset_n,

    input [31:0]    instr_payload,
    input           instr_value,

    output logic          rs1_rd_en,
    output logic  [4:0]   rs1_rd_addr,

    output logic          rs2_rd_en,
    output logic  [4:0]   rs2_rd_addr,

    output logic          rs3_rd_en,
    output logic  [4:0]   rs3_rd_addr,

    output logic          rd_wr_en,
    output logic  [4:0]   rd_wr_addr,

    //jump
    output adder_a_mux_e    adder_a_mux,
    output adder_b_mux_e    adder_b_mux,

    //src 
    output src_a_mux_e      src_a_mux,
    output src_b_mux_e      src_b_mux,
    output src_c_mux_e      src_c_mux,

    //imm
    output logic [31:0]     imm_itype, 
    output logic [31:0]     imm_stype,
    output logic [31:0]     imm_utype,
    output logic [31:0]     imm_btype,
    output logic [31:0]     imm_jtype,
    output logic [31:0]     imm_rs1,

    //alu
    output logic            alu_en,
    output alu_op_e         alu_op,
    output logic            branch,
    output logic            jump,

    //lsu
    output logic            lsu_en,
    output lsu_op_e         lsu_op,
    output lsu_dtype_e      lsu_dtype,

    //mul-div
    output logic            mult_en,
    output mult_op_e        mult_op,

    //csr
    output logic            csr_en,
    output logic [1:0]      csr_op,
    output logic [11:0]     csr_addr,

    //ecall ebreak
    output logic            ecall_en,
    output logic            ebreak_en,
    output logic            mret_en,
    output logic            uret_en,
    output logic            sret_en,
    output logic            wfi_en,
    output logic            fence_en,
    output logic            illegal_instr
);

// Local Variables:
// verilog-library-directories:("." "dir1" "dir2" ...)
// End:

//////////////////////////////////////////////
/*AUTOLOGIC*/
//////////////////////////////////////////////
`define BRANCH_DEC              \
    branch      = 1'b1;         \
    alu_en      = 1'b1;         \
    alu_op      = ALU_ADD;      \
    rs1_rd_en   = 1'b1;         \
    rs2_rd_en   = 1'b1;         \
    src_a_mux   = SRC_A_REG_RS1;      \
    src_b_mux   = SRC_B_REG_RS2;      \
    src_c_mux   = SRC_C_IMM_BTYPE     

`define ALU_R_DEC               \
    alu_en      = 1'b1;         \
    rs1_rd_en   = 1'b1;         \
    rs2_rd_en   = 1'b1;         \
    src_a_mux   = SRC_A_REG_RS1;      \
    src_b_mux   = SRC_B_REG_RS2;      \
    rd_wr_en    = 1'b1;         

`define ALU_I_DEC               \
    alu_en      = 1'b1;         \
    rs1_rd_en   = 1'b1;         \
    src_a_mux   = SRC_A_REG_RS1;      \
    src_b_mux   = SRC_B_IMM_ITYPE;    \
    rd_wr_en    = 1'b1;         

`define MULT_DEC               \
    mult_en      = 1'b1;        \
    rs1_rd_en   = 1'b1;         \
    rs2_rd_en   = 1'b1;         \
    src_a_mux   = SRC_A_REG_RS1;      \
    src_b_mux   = SRC_B_REG_RS2;      \
    rd_wr_en    = 1'b1;         

logic [6:0]     opcode;
logic [2:0]     funct3;
logic [7:0]     funct7;
logic [4:0]     rs1;
logic [4:0]     rs2;
logic [4:0]     rd;

logic           lui_instr;
logic           auipc_instr;
logic           branch_instr;
logic           jalr_instr;
logic           jal_instr;
logic           load_instr;
logic           store_instr;
logic           itype_instr;
logic           rtype_instr;
logic           sys_instr;
logic           mismem_instr;

logic           add_instr;
logic           sub_instr;
logic           xor_instr;
logic           or_instr;
logic           and_instr;
logic           sra_instr;
logic           sll_instr;
logic           srl_instr;
logic           slt_instr;
logic           sltu_instr;

logic           addi_instr;
logic           xori_instr;
logic           ori_instr;
logic           andi_instr;
logic           srai_instr;
logic           slli_instr;
logic           srli_instr;
logic           slti_instr;
logic           sltui_instr;

logic           beq;
logic           bne;
logic           blt;
logic           bge;
logic           bltu;
logic           bgeu;

logic           mul_instr;     
logic           mulh_instr;    
logic           mulhsu_instr;  
logic           mulhu_instr;   
logic           div_instr;     
logic           divu_instr;    
logic           rem_instr;     
logic           remu_instr;    

logic           csrrw;
logic           csrrs;
logic           csrrc;
logic           csr_r_instr;
logic           csr_i_instr;

logic           ecall_instr;
logic           ebreak_instr;
logic           mret_instr;
logic           sret_instr;
logic           uret_instr;
logic           wfi_instr;

logic           fence_instr;
logic           fence_i_instr;

//////////////////////////////////////////////
//main code
assign opcode[6:0]  = instr_payload[6:0];
assign funct3[2:0]  = instr_payload[14:12];
assign funct7[7:0]  = instr_payload[31:25];
assign rs1[4:0]     = instr_payload[19:15];
assign rs2[4:0]     = instr_payload[24:20];
assign rd[4:0]      = instr_payload[11:7];
 
assign imm_itype[31:0]  = { {20{instr_payload[31]}}, instr_payload[31:20] };
assign imm_stype[31:0]  = { {20{instr_payload[31]}}, instr_payload[31:25],instr_payload[11:7]};
assign imm_utype[31:0]  = { instr_payload[31:12], 12'h0 };
assign imm_btype[31:0]  = { {19{instr_payload[31]}}, instr_payload[31], instr_payload[7],instr_payload[30:25],instr_payload[11:8],1'b0};
assign imm_jtype[31:0]  = { {12{instr_payload[31]}}, instr_payload[19:12],instr_payload[20],instr_payload[30:21],1'b0};
assign imm_rs1[31:0]    = { 27'h0, rs1[4:0] };

assign lui_instr     = instr_value & ( opcode[6:0] == OPCODE_LUI ); //lui
assign auipc_instr   = instr_value & ( opcode[6:0] == OPCODE_AUIPC ); //luipc
assign branch_instr  = instr_value & ( opcode[6:0] == OPCODE_BRANCH ); //beq,bne,blt,bge,bltu,bgeu
assign jal_instr     = instr_value & ( opcode[6:0] == OPCODE_JAL ); //jar
assign jalr_instr    = instr_value & ( opcode[6:0] == OPCODE_JALR ); //jalr
assign load_instr    = instr_value & ( opcode[6:0] == OPCODE_LOAD ); //lb,lh,lw,lbu,lhu
assign store_instr   = instr_value & ( opcode[6:0] == OPCODE_STORE ); //sb,sh,sw
assign itype_instr   = instr_value & ( opcode[6:0] == OPCODE_OP_IMM ); //addi,slti,sltiu,xori,andi,slli,srli,srai
assign rtype_instr   = instr_value & ( opcode[6:0] == OPCODE_OP ); //add,sub,sll,slt,sltu,xor,srl,sra,or,and
assign sys_instr     = instr_value & ( opcode[6:0] == OPCODE_SYSTEM ); //csrrw,csrrs,csrrc,csrrwi,csrrsi,csrrci
assign mismem_instr  = instr_value & ( opcode[6:0] == OPCODE_MISCMEM ); //fence, fence.i

//adder
assign add_instr  = ( rtype_instr & (funct3==FUNC_ADD) & (funct7==7'b000_0000) );
assign addi_instr = ( itype_instr & (funct3==FUNC_ADDI) );
assign sub_instr  = ( rtype_instr & (funct3==FUNC_SUB) & (funct7==7'b010_0000) );

//logic
assign xor_instr  = ( rtype_instr & (funct3==FUNC_XOR) & (funct7==7'b000_0000) ); 
assign or_instr   = ( rtype_instr & (funct3==FUNC_OR)  & (funct7==7'b000_0000) );
assign and_instr  = ( rtype_instr & (funct3==FUNC_AND) & (funct7==7'b000_0000) );
assign xori_instr = ( itype_instr & (funct3==FUNC_XORI) ); 
assign ori_instr  = ( itype_instr & (funct3==FUNC_ORI ) );
assign andi_instr = ( itype_instr & (funct3==FUNC_ANDI) );

//shift
assign sll_instr  = ( rtype_instr & (funct3==FUNC_SLL) & (funct7==7'b000_0000) );
assign sra_instr  = ( rtype_instr & (funct3==FUNC_SRA) & (funct7==7'b010_0000) );
assign srl_instr  = ( rtype_instr & (funct3==FUNC_SRL) & (funct7==7'b000_0000) );
assign slli_instr = ( itype_instr & (funct3==FUNC_SLLI) & (funct7==7'b000_0000) );
assign srai_instr = ( itype_instr & (funct3==FUNC_SRAI) & (funct7==7'b010_0000) );
assign srli_instr = ( itype_instr & (funct3==FUNC_SRLI) & (funct7==7'b000_0000) );

//compare
assign slt_instr   = ( rtype_instr & (funct3==FUNC_SLT) & (funct7==7'b000_0000) );
assign sltu_instr  = ( rtype_instr & (funct3==FUNC_SLTU)& (funct7==7'b000_0000) );
assign slti_instr  = ( itype_instr & (funct3==FUNC_SLTI) );
assign sltui_instr = ( itype_instr & (funct3==FUNC_SLTIU));

//branch
assign beq  = branch_instr & ( funct3[2:0] == FUNC_BEQ );
assign bne  = branch_instr & ( funct3[2:0] == FUNC_BNE );
assign blt  = branch_instr & ( funct3[2:0] == FUNC_BLT );
assign bge  = branch_instr & ( funct3[2:0] == FUNC_BGE );
assign bltu = branch_instr & ( funct3[2:0] == FUNC_BLTU);
assign bgeu = branch_instr & ( funct3[2:0] == FUNC_BGEU);

//csr
assign csrrw        = sys_instr & ( funct3[1:0] == 2'b01 );
assign csrrs        = sys_instr & ( funct3[1:0] == 2'b10 );
assign csrrc        = sys_instr & ( funct3[1:0] == 2'b11 );
assign csr_r_instr  = ( csrrw | csrrs | csrrc ) & (~funct3[2]);
assign csr_i_instr  = ( csrrw | csrrs | csrrc ) & (funct3[2]);

//ecall ebreak
assign ecall_instr  = sys_instr & (instr_payload[31:20]==12'h0) & (rs1==5'h0) & (funct3==3'b0) & (rd==5'h0);
assign ebreak_instr = sys_instr & (instr_payload[31:20]==12'h1) & (rs1==5'h0) & (funct3==3'b0) & (rd==5'h0);
assign mret_instr   = sys_instr & (funct7==7'b0011000) & (rs2==5'h2) & (rs1==5'h0) & (rd==5'h0) & (funct3==3'h0);
assign sret_instr   = sys_instr & (funct7==7'b0001000) & (rs2==5'h2) & (rs1==5'h0) & (rd==5'h0) & (funct3==3'h0);
assign uret_instr   = sys_instr & (funct7==7'b0000000) & (rs2==5'h2) & (rs1==5'h0) & (rd==5'h0) & (funct3==3'h0);
assign wfi_instr    = sys_instr & (funct7==7'b0001000) & (rs2==5'b00101) & (rs1==5'h0) & (rd==5'h0) & (funct3==3'h0);

//fence, fence.i
assign fence_instr      = mismem_instr & (funct3==3'b000);
assign fence_i_instr    = mismem_instr & (funct3==3'b001);

//mul-div
assign mul_instr        = rtype_instr & (funct7==7'b0000001) & (funct3==3'b000);
assign mulh_instr       = rtype_instr & (funct7==7'b0000001) & (funct3==3'b001);
assign mulhsu_instr     = rtype_instr & (funct7==7'b0000001) & (funct3==3'b010);
assign mulhu_instr      = rtype_instr & (funct7==7'b0000001) & (funct3==3'b011);
assign div_instr        = rtype_instr & (funct7==7'b0000001) & (funct3==3'b100);
assign divu_instr       = rtype_instr & (funct7==7'b0000001) & (funct3==3'b101);
assign rem_instr        = rtype_instr & (funct7==7'b0000001) & (funct3==3'b110);
assign remu_instr       = rtype_instr & (funct7==7'b0000001) & (funct3==3'b111);


assign rs1_rd_addr = rs1;
assign rs2_rd_addr = rs2;
assign rd_wr_addr = rd;

always @(*)begin
    alu_en       = 1'b0;
    alu_op       = ALU_ADD;
    
    mult_en      = 1'b0;
    mult_op      = MUL;

    lsu_en       = 1'b0;
    lsu_op       = LSU_OP_LD;
    lsu_dtype    = LSU_DTYPE_U_BYTE;

    branch      = 1'b0;
    jump        = 1'b0;
    csr_en      = 1'b0;
    ecall_en    = 1'b0;
    ebreak_en   = 1'b0;
    mret_en     = 1'b0;
    uret_en     = 1'b0;
    sret_en     = 1'b0;
    wfi_en      = 1'b0;
    fence_en    = 1'b0;

    rs1_rd_en   = 1'b0;
    rs2_rd_en   = 1'b0;
    rs3_rd_en   = 1'b0;

    rs3_rd_addr = 5'h0;

    src_a_mux   = SRC_A_REG_RS1;
    src_b_mux   = SRC_B_REG_RS2;
    src_c_mux   = SRC_C_IMM_BTYPE;

    adder_a_mux = ADDER_A_PC_ID;
    adder_b_mux = ADDER_B_IMM_JTYPE;

    rd_wr_en        = 1'b0;
    illegal_instr   = 1'b0;

    if(instr_value )begin
        unique case(1)
            lui_instr       :begin 
                alu_en      = 1'b1;
                alu_op      = ALU_ADD;
                src_a_mux   = SRC_A_IMM_UTYPE;
                src_b_mux   = SRC_B_ZERO;
                rd_wr_en    = 1'b1;
            end
            auipc_instr     :begin 
                alu_en      = 1'b1;
                alu_op      = ALU_ADD;
                src_a_mux   = SRC_A_PC_ID;
                src_b_mux   = SRC_B_IMM_UTYPE;
                rd_wr_en    = 1'b1;
            end
            branch_instr    :begin 
                unique case(1)
                    beq     :begin `BRANCH_DEC; alu_op = ALU_EQ ;  end
                    bne     :begin `BRANCH_DEC; alu_op = ALU_NE ;  end
                    blt     :begin `BRANCH_DEC; alu_op = ALU_LT ;  end
                    bge     :begin `BRANCH_DEC; alu_op = ALU_GE ;  end
                    bltu    :begin `BRANCH_DEC; alu_op = ALU_LTU;  end
                    bgeu    :begin `BRANCH_DEC; alu_op = ALU_GEU;  end
                    default :begin illegal_instr = 1'b1; end
                endcase
            end
            jalr_instr      :begin 
                if( funct3[2:0] == 3'b0 )begin
                    alu_en = 1'b1;
                    rs3_rd_en = 1'b1; //no forward
                    rs3_rd_addr = rs1;
                    adder_a_mux = ADDER_A_REG_RS3;
                    adder_b_mux = ADDER_B_IMM_ITYPE;
                    jump = 1'b1;
                    rd_wr_en  = 1'b1;
                end else begin
                    illegal_instr = 1'b1;
                end
            end
            jal_instr       :begin 
                alu_en = 1'b1;
                adder_a_mux = ADDER_A_PC_ID;
                adder_b_mux = ADDER_B_IMM_JTYPE;
                jump = 1'b1;
                rd_wr_en = 1'b1;
            end
            load_instr      :begin 
                lsu_en = 1'b1;
                lsu_op = LSU_OP_LD;
                lsu_dtype = lsu_dtype_e'(funct3[2:0]);
                rs1_rd_en = 1'b1;
                src_a_mux = SRC_A_REG_RS1;
                src_b_mux = SRC_B_IMM_ITYPE;
                rd_wr_en = 1'b1;
                alu_en = 1'b1;
                alu_op = ALU_ADD;
            end
            store_instr     :begin
                lsu_en = 1'b1;
                lsu_op = LSU_OP_WR;
                lsu_dtype = lsu_dtype_e'(funct3[2:0]);
                rs1_rd_en = 1'b1;
                rs2_rd_en = 1'b1;
                src_a_mux = SRC_A_REG_RS1;
                src_b_mux = SRC_B_IMM_STYPE;
                src_c_mux = SRC_C_REG_RS2;
                alu_en = 1'b1;
                alu_op = ALU_ADD;
            end
            itype_instr     :begin
                unique case(1)
                    addi_instr : begin `ALU_I_DEC; alu_op = ALU_ADD; end
                    xori_instr : begin `ALU_I_DEC; alu_op = ALU_XOR; end
                    ori_instr  : begin `ALU_I_DEC; alu_op = ALU_OR;  end
                    andi_instr : begin `ALU_I_DEC; alu_op = ALU_AND; end
                    slli_instr : begin `ALU_I_DEC; alu_op = ALU_SLL; end
                    srai_instr : begin `ALU_I_DEC; alu_op = ALU_SRA; end
                    srli_instr : begin `ALU_I_DEC; alu_op = ALU_SRL; end
                    slti_instr : begin `ALU_I_DEC; alu_op = ALU_SLT; end
                    sltui_instr: begin `ALU_I_DEC; alu_op = ALU_SLTU;end
                    default:begin illegal_instr = 1'b1; end
                endcase
            end
            rtype_instr     :begin
                unique case(1)
                    add_instr : begin `ALU_R_DEC; alu_op = ALU_ADD; end
                    sub_instr : begin `ALU_R_DEC; alu_op = ALU_SUB; end
                    xor_instr : begin `ALU_R_DEC; alu_op = ALU_XOR; end
                    or_instr  : begin `ALU_R_DEC; alu_op = ALU_OR;  end
                    and_instr : begin `ALU_R_DEC; alu_op = ALU_AND; end
                    sll_instr : begin `ALU_R_DEC; alu_op = ALU_SLL; end
                    sra_instr : begin `ALU_R_DEC; alu_op = ALU_SRA; end
                    srl_instr : begin `ALU_R_DEC; alu_op = ALU_SRL; end
                    slt_instr : begin `ALU_R_DEC; alu_op = ALU_SLT; end
                    sltu_instr: begin `ALU_R_DEC; alu_op = ALU_SLTU;end
                    mul_instr :     begin `MULT_DEC; mult_op = MUL; end
                    mulh_instr:     begin `MULT_DEC; mult_op = MULH; end
                    mulhsu_instr:   begin `MULT_DEC; mult_op = MULHSU; end
                    mulhu_instr:    begin `MULT_DEC; mult_op = MULHU; end
                    div_instr:      begin `MULT_DEC; mult_op = DIV;end
                    divu_instr:     begin `MULT_DEC; mult_op = DIVU; end
                    rem_instr:      begin `MULT_DEC; mult_op = REM; end
                    remu_instr:     begin `MULT_DEC; mult_op = REMU; end
                    default:begin illegal_instr = 1'b1; end
                endcase
            end
            sys_instr       :begin //csr, ecall, ebreak
                unique case(1)
                    csr_r_instr :begin 
                        csr_en = 1'b1;
                        rs1_rd_en = 1'b1;
                        src_a_mux = SRC_A_REG_RS1;
                        src_c_mux = SRC_C_CSR_ADDR;
                        rd_wr_en = 1'b1;
                    end
                    csr_i_instr:begin
                        csr_en = 1'b1;
                        src_a_mux = SRC_A_IMM_RS1;
                        src_c_mux = SRC_C_CSR_ADDR;
                        rd_wr_en = 1'b1;
                    end
                    ecall_instr :begin ecall_en = 1'b1; end
                    ebreak_instr:begin ebreak_en = 1'b1; end
                    mret_instr:begin mret_en=1'b1; end
                    uret_instr:begin uret_en=1'b1; end
                    sret_instr:begin /*sret_en=1'b1;*/ illegal_instr=1'b1; end //TODO
                    wfi_instr:begin wfi_en = 1'b1; end
                    default:begin illegal_instr = 1'b1; end
                endcase
            end
            mismem_instr:begin
                unique case(1)
                    fence_instr:begin illegal_instr = 1'b0; end //treat as a nop
                    fence_i_instr:begin fence_en = 1'b1; end //Jump to next instr
                    default:begin illegal_instr = 1'b1; end
                endcase
            end
            default         :begin 
                illegal_instr = 1'b1;
            end
        endcase
    end
end


always @(*)begin
    csr_op[1:0] = CSR_OP_READ;
    if( csrrw )begin
        csr_op[1:0] = CSR_OP_WRITE;
    end else if( (csrrs | csrrc) & (rs1==0) )begin
        csr_op[1:0] = CSR_OP_READ;
    end else if( csrrs )begin
        csr_op[1:0] = CSR_OP_SET;
    end else if( csrrc )begin
        csr_op[1:0] = CSR_OP_CLEAR;
    end
end

assign csr_addr[11:0] = instr_payload[31:20];


endmodule
