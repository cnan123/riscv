//================================================================
//   Copyright (C) 2021 Sangfor Ltd. All rights reserved.
//
//   Filename     : riscv_pkg.sv
//   Auther       : cnan
//   Created On   : 2021年05月04日
//   Description  : 
//
//
//================================================================

package riscv_pkg;

    
//////////////////////////////////////////////
//opcodes
//////////////////////////////////////////////
parameter OPCODE_LUI        = 7'b0110111;
parameter OPCODE_AUIPC      = 7'b0010111;
parameter OPCODE_JAL        = 7'b1101111;
parameter OPCODE_JALR       = 7'b1100111;
parameter OPCODE_BRANCH     = 7'b1100011;
parameter OPCODE_LOAD       = 7'b0000011;
parameter OPCODE_STORE      = 7'b0100011;
parameter OPCODE_IMM        = 7'b0010011;
parameter OPCODE_REG        = 7'b0110011;
parameter OPCODE_MISCMEM    = 7'b0001111;
parameter OPCODE_SYSTEM     = 7'b1110011;

//parameter OPCODE_CUST0     = 7'h0b
//parameter OPCODE_CUST1     = 7'h2b


//////////////////////////////////////////////
//funct3
//////////////////////////////////////////////
parameter FUNC_BEQ          = 3'b000;
parameter FUNC_BNE          = 3'b001;
parameter FUNC_BLT          = 3'b100;
parameter FUNC_BGE          = 3'b101;
parameter FUNC_BLTU         = 3'b110;
parameter FUNC_BGEU         = 3'b111;

parameter FUNC_LB           = 3'b000;
parameter FUNC_LH           = 3'b001;
parameter FUNC_LW           = 3'b010;
parameter FUNC_LBU          = 3'b100;
parameter FUNC_LHU          = 3'b101;

parameter FUNC_SB           = 3'b000;
parameter FUNC_SH           = 3'b001;
parameter FUNC_SW           = 3'b010;

parameter FUNC_ADDI         = 3'b000;
parameter FUNC_SLTI         = 3'b010;
parameter FUNC_SLTIU        = 3'b011;
parameter FUNC_XORI         = 3'b100;
parameter FUNC_ORI          = 3'b110;
parameter FUNC_ANDI         = 3'b111;

parameter FUNC_SLLI         = 3'b001;
parameter FUNC_SRLI         = 3'b101;
parameter FUNC_SRAI         = 3'b101;

parameter FUNC_ADD          = 3'b000;
parameter FUNC_SUB          = 3'b000;
parameter FUNC_SLL          = 3'b001;
parameter FUNC_SLT          = 3'b010;
parameter FUNC_SLTU         = 3'b011;
parameter FUNC_XOR          = 3'b100;
parameter FUNC_SRL          = 3'b101;
parameter FUNC_SRA          = 3'b101;
parameter FUNC_OR           = 3'b110;
parameter FUNC_AND          = 3'b111;

parameter BRANCH_BEQ        = 6'b00_0001;
parameter BRANCH_BNE        = 6'b00_0010;
parameter BRANCH_BLT        = 6'b00_0100;
parameter BRANCH_BGE        = 6'b00_1000;
parameter BRANCH_BLTU       = 6'b01_0000;
parameter BRANCH_BGEU       = 6'b10_0000;

//////////////////////////////////////////////////////////////////////////////////////////////
//alu
/////////////////////////////////////////////////////////////////////////////////////////////
parameter ALU_NUM           = 6;

parameter ALU_NONE          = 6'b00_0000;
// adder
parameter ALU_ADD           = 6'b00_0001;
parameter ALU_SUB           = 6'b00_0010;

//logic
parameter ALU_XOR           = 6'b00_1000;
parameter ALU_OR            = 6'b00_1001;
parameter ALU_AND           = 6'b00_1010;

//shift
parameter ALU_SLL           = 6'b01_0000;
parameter ALU_SRA           = 6'b01_0001;
parameter ALU_SRL           = 6'b01_0010;

//compare instr
parameter ALU_SLT           = 6'b01_1000;
parameter ALU_SLTU          = 6'b01_1001;

//branch comparisons
parameter ALU_EQ            = 6'b10_0000;
parameter ALU_NE            = 6'b10_0001;
parameter ALU_LT            = 6'b10_0010;
parameter ALU_GE            = 6'b10_0011;
parameter ALU_LTU           = 6'b10_0100;
parameter ALU_GEU           = 6'b10_0101;


//////////////////////////////////////////////////////////////////////////////////////////////
//lsu
/////////////////////////////////////////////////////////////////////////////////////////////


endpackage
