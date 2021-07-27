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

parameter TAG_WIDTH = 2;
    
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
parameter ALU_OP_WIDTH      = 6;

typedef enum logic [ALU_OP_WIDTH-1:0] {
    // adder
    ALU_ADD           = 6'b00_0001,
    ALU_SUB           = 6'b00_0010,
    
    //logic
    ALU_XOR           = 6'b00_1000,
    ALU_OR            = 6'b00_1001,
    ALU_AND           = 6'b00_1010,
    
    //shift
    ALU_SLL           = 6'b01_0000,
    ALU_SRA           = 6'b01_0001,
    ALU_SRL           = 6'b01_0010,
    
    //compare instr
    ALU_SLT           = 6'b01_1000,
    ALU_SLTU          = 6'b01_1001,
    
    //branch comparisons
    ALU_EQ            = 6'b10_0000,
    ALU_NE            = 6'b10_0001,
    ALU_LT            = 6'b10_0010,
    ALU_GE            = 6'b10_0011,
    ALU_LTU           = 6'b10_0100,
    ALU_GEU           = 6'b10_0101
} alu_op_e;


//////////////////////////////////////////////////////////////////////////////////////////////
//lsu
/////////////////////////////////////////////////////////////////////////////////////////////
parameter LSU_OP_WIDTH = 1;

typedef enum logic [LSU_OP_WIDTH-1:0] {
    LSU_OP_LD,
    LSU_OP_WR
} lsu_op_e;

typedef enum logic [2:0] {
    LSU_DTYPE_U_BYTE      = 3'b000,
    LSU_DTYPE_U_HALFWORD  = 3'b001,
    LSU_DTYPE_U_WORD      = 3'b010,
    LSU_DTYPE_S_BYTE      = 3'b100,
    LSU_DTYPE_S_HALFWORD  = 3'b101,
    LSU_DTYPE_S_WORD      = 3'b110
} lsu_dtype_e;

typedef enum logic [1:0] {
    SRC_A_REG_RS1,
    SRC_A_IMM_UTYPE,
    SRC_A_PC_ID,
    SRC_A_IMM_RS1
} src_a_mux_e;

typedef enum logic [2:0] {
    SRC_B_REG_RS2,
    SRC_B_IMM_UTYPE,
    SRC_B_IMM_ITYPE,
    SRC_B_IMM_JTYPE,
    SRC_B_IMM_STYPE,
    SRC_B_ZERO
} src_b_mux_e;

typedef enum logic [1:0] {
    SRC_C_IMM_BTYPE,
    SRC_C_REG_RS2,
    SRC_C_CSR_ADDR
} src_c_mux_e;

//////////////////////////////////////////////////////////////////////////////////////////////
//csr
/////////////////////////////////////////////////////////////////////////////////////////////
parameter CSR_OP_READ       = 2'b00;
parameter CSR_OP_WRITE      = 2'b01;
parameter CSR_OP_SET        = 2'b10;
parameter CSR_OP_CLEAR      = 2'b11;

parameter USER_MAP          = 2'b00;
parameter MACHINE_MAP       = 2'b10;
parameter SUPERVISOR_MAP    = 2'b01;
parameter HYPERVISOR_MAP    = 2'b11;

parameter USTATUS           = 12'h000;
parameter UIE               = 12'h004;
parameter UTVEC             = 12'h005;
parameter USCRATCH          = 12'h040;
parameter UEPC              = 12'h041;
parameter UCAUSE            = 12'h042;
parameter UTVAL             = 12'h043;
parameter UIP               = 12'h044;

parameter FFLAGS            = 12'h001;
parameter FRM               = 12'h002;
parameter FSCR              = 12'h003;

parameter CYCLE             = 12'hC00;
parameter TIME              = 12'hC01;
parameter INSTRET           = 12'hC02;
parameter HPCOUNTER3        = 12'hC03;
parameter HPCOUNTER4        = 12'hC04;
parameter HPCOUNTER5        = 12'hC05;
parameter HPCOUNTER6        = 12'hC06;
parameter HPCOUNTER7        = 12'hC07;
parameter HPCOUNTER8        = 12'hC08;
parameter HPCOUNTER9        = 12'hC09;
parameter HPCOUNTER10       = 12'hC0A;
parameter HPCOUNTER11       = 12'hC0B;
parameter HPCOUNTER12       = 12'hC0C;
parameter HPCOUNTER13       = 12'hC0D;
parameter HPCOUNTER14       = 12'hC0E;
parameter HPCOUNTER15       = 12'hC0F;
parameter HPCOUNTER16       = 12'hC10;
parameter HPCOUNTER17       = 12'hC11;
parameter HPCOUNTER18       = 12'hC12;
parameter HPCOUNTER19       = 12'hC13;
parameter HPCOUNTER20       = 12'hC14;
parameter HPCOUNTER21       = 12'hC15;
parameter HPCOUNTER22       = 12'hC16;
parameter HPCOUNTER23       = 12'hC17;
parameter HPCOUNTER24       = 12'hC18;
parameter HPCOUNTER25       = 12'hC19;
parameter HPCOUNTER26       = 12'hC1A;
parameter HPCOUNTER27       = 12'hC1B;
parameter HPCOUNTER28       = 12'hC1C;
parameter HPCOUNTER29       = 12'hC1D;
parameter HPCOUNTER30       = 12'hC1E;
parameter HPCOUNTER31       = 12'hC1F;
parameter CYCLEH            = 12'hC80;
parameter TIMEH             = 12'hC81;
parameter INSTRETH          = 12'hC82;
parameter HPCOUNTER3H       = 12'hC83;
parameter HPCOUNTER4H       = 12'hC84;
parameter HPCOUNTER5H       = 12'hC85;
parameter HPCOUNTER6H       = 12'hC86;
parameter HPCOUNTER7H       = 12'hC87;
parameter HPCOUNTER8H       = 12'hC88;
parameter HPCOUNTER9H       = 12'hC89;
parameter HPCOUNTER10H      = 12'hC8A;
parameter HPCOUNTER11H      = 12'hC8B;
parameter HPCOUNTER12H      = 12'hC8C;
parameter HPCOUNTER13H      = 12'hC8D;
parameter HPCOUNTER14H      = 12'hC8E;
parameter HPCOUNTER15H      = 12'hC8F;
parameter HPCOUNTER16H      = 12'hC90;
parameter HPCOUNTER17H      = 12'hC91;
parameter HPCOUNTER18H      = 12'hC92;
parameter HPCOUNTER19H      = 12'hC93;
parameter HPCOUNTER20H      = 12'hC94;
parameter HPCOUNTER21H      = 12'hC95;
parameter HPCOUNTER22H      = 12'hC96;
parameter HPCOUNTER23H      = 12'hC97;
parameter HPCOUNTER24H      = 12'hC98;
parameter HPCOUNTER25H      = 12'hC99;
parameter HPCOUNTER26H      = 12'hC9A;
parameter HPCOUNTER27H      = 12'hC9B;
parameter HPCOUNTER28H      = 12'hC9C;
parameter HPCOUNTER29H      = 12'hC9D;
parameter HPCOUNTER30H      = 12'hC9E;
parameter HPCOUNTER31H      = 12'hC9F;

//supervisor trap setup
parameter SSTATUS           = 12'h100;
parameter SEDELEG           = 12'h102;
parameter SIDELEG           = 12'h103;
parameter SIE               = 12'h104;
parameter STVEC             = 12'h105;
parameter SCOUNTEREN        = 12'h106;
//supervisor trap handing
parameter SSCRATCH          = 12'h140;
parameter SEPC              = 12'h141;
parameter SCAUSE            = 12'h142;
parameter STVAL             = 12'h143;
parameter SIP               = 12'h144;
//supervisor protection and translation
parameter SATP              = 12'h180;

//hypervisor trap setup
parameter HSTATUS           = 12'h600;
parameter HEDELEG           = 12'h602;
parameter HIDELEG           = 12'h603;
parameter HIE               = 12'h604;
parameter HCOUNTEREN        = 12'h606;
parameter HGEIE             = 12'h607;
//hypervisor trap handing
parameter HTVAL             = 12'h643;
parameter HIP               = 12'h644;
parameter HVIP              = 12'h645;
parameter HTINST            = 12'h64A;
parameter HGEIP             = 12'hE12;
//hypervisor protection and translation
parameter HGATP             = 12'h680;
//hypervisor counter/timer virtualization registers
parameter HTIMEDELTA        = 12'h605;
parameter HTIMEDELTAH       = 12'h615;


//virtual supervisor regsiter
parameter VSSTATUS          = 12'h200;
parameter VSIE              = 12'h204;
parameter VSTEC             = 12'h205;
parameter VSSCRATCH         = 12'h240;
parameter VSEPC             = 12'h241;
parameter VSCAUSE           = 12'h242;
parameter VSTVAL            = 12'h243;
parameter VSIP              = 12'h244;
parameter VSATP             = 12'h280;

//machine information registers
parameter MVENDORID         = 12'hF11;
parameter MARCHID           = 12'hF12;
parameter MIMPID            = 12'hF13;
parameter MHARTID           = 12'hF14;
//machine trap setup
parameter MSTARUS           = 12'h300;
parameter MISA              = 12'h301;
parameter MEDELEG           = 12'h302;
parameter MIDELEG           = 12'h303;
parameter MIE               = 12'h304;
parameter MTVEC             = 12'h305;
parameter MCOUNTEREN        = 12'h306;
parameter MSTATUSH          = 12'h310;
//machine trap handing
parameter MSCRATCH          = 12'h340;
parameter MEPC              = 12'h341;
parameter MCAUSE            = 12'h342;
parameter MTVAL             = 12'h343;
parameter MIP               = 12'h344;
parameter MTINST            = 12'h34A;
parameter MTVAL2            = 12'h34B;
//machine memory protection
parameter PMPCFG0           = 12'h3A0; //0~15
parameter PMPADDR0          = 12'h3B0; //0~63

//machine counter/timer
parameter MCYCLE            = 12'hB00;
parameter MINSTRET          = 12'hB02;
parameter MHPCOUNTER3       = 12'hB03;//3~31
parameter MCYCLEH           = 12'hB80;
parameter MINSTRETH         = 12'hB82;
parameter MHPCOUNTER3H      = 12'hB83;//3~31
//machine counter setup
parameter MCOUNTINHIBIT     = 12'h320;
parameter MHPEVENT3         = 12'h323;//3~31

//debug/trace/ register
parameter TSELECT           = 12'h7A0;
parameter TDATA1            = 12'h7A1;
parameter TDATA2            = 12'h7A2;
parameter TDATA3            = 12'h7A3;
// debug mode register
parameter DCSR              = 12'h7B0;
parameter DPC               = 12'h7B1;
parameter DSCRATCH0         = 12'h7B2;
parameter DSCRATCH1         = 12'h7B3;

//=================================================================================================//
//misa
//-------------------------------------------------------
// | MXLEN-1 : MXLEN-2  | MXLEN-3 : 26  | 25:0          |
//-------------------------------------------------------
// |    mxl[1:0]        |   WLRL        | extensions    |
// 
//=================================================================================================//
localparam MXL = 1;
localparam ISA_CODE = (
    (0  << 0) | // A - Atomic Instruction extension
    (0  << 2) | // C - Compressed extension
    (0  << 3) | // D - Dobule-precsision float-point extension
    (0  << 4) | // E - RV32E base ISA
    (0  << 5) | // F - Signal-precsision float-point extension
    (0  << 7) | // H - Hypervisor extension
    (1  << 8) | // I - RV32I/64I/128I base ISA
    (0  << 12)| // M - Integer Multiply/Divide extension
    (0  << 13)| // N - User-level interrupts supported
    (0  << 16)| // Q - Quad-precsision float-point extension
    (0  << 18)| // S - Supervisor mode implemented
    (0  << 20)| // U - User mode implemented
    (0  << 23)| // X - Non-standard extensions present
    ( MXL << 30) //MXL
);



//=================================================================================================//
//mvendorid
//-------------------------------------------------------
// | 31:7 | 6:0     |
// | bank | offset  |
//=================================================================================================//
//localparam MVENDORID = 32'h0;


//=================================================================================================//
//marchid
//=================================================================================================//
//localparam MARCHID = 32'h0;


//=================================================================================================//
//mimpid
//=================================================================================================//
//localparam MIMPID = 32'h0;

typedef struct packed {
      logic         sd;     // signal dirty state - read-only
      logic [30:23] wpri4;  // writes preserved reads ignored
      logic         tsr;    // trap sret
      logic         tw;     // time wait
      logic         tvm;    // trap virtual memory
      logic         mxr;    // make executable readable
      logic         sum;    // permit supervisor user memory access
      logic         mprv;   // modify privilege - privilege level for ld/st
      logic [1:0]   xs;     // extension register - hardwired to zero
      logic [1:0]   fs;     // floating point extension register
      logic [1:0]   mpp;    // holds the previous privilege mode up to machine
      logic [1:0]   wpri2;  // writes preserved reads ignored
      logic         spp;    // holds the previous privilege mode up to supervisor
      logic         mpie;   // machine interrupts enable bit active prior to trap
      logic         ube;  // writes preserved reads ignored
      logic         spie;   // supervisor interrupts enable bit active prior to trap
      logic         upie;   // user interrupts enable bit active prior to trap - hardwired to zero
      logic         mie;    // machine interrupts enable
      logic         wpri0;  // writes preserved reads ignored
      logic         sie;    // supervisor interrupts enable
      logic         uie;    // user interrupts enable - hardwired to zero
} status_rv_t;

parameter ECAUSE_ECALL = 5'd1; //Templete
parameter ECAUSE_EBREAK = 5'd2; //Templete
parameter ECAUSE_ILLEGAL_INSTR = 5'd3; //Templete
parameter ECAUSE_INSTR_FAULT = 5'd4; //Templete

endpackage
