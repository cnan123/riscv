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

module id_stage(/*AUTOARG*/
    input               clk,
    input               reset_n,

    input   [31:0]      pc_if,
    input               is_compress_intr,
    input   [31:0]      instruction,
    input               instruction_value,
    output              id_stage_ready,

    input               stall_id,
    input               flush,

    //register access
    output              register_ch0_rd,
    output  [4:0]       register_ch0_addr,
    input   [31:0]      register_ch0_data,

    output              register_ch1_rd,
    output  [4:0]       register_ch1_addr,
    input   [31:0]      register_ch1_data,

    //ex stage
    //alu
    output  logic [8:0]       pipe_alu_op,
    output  logic [31:0]      pipe_alu_operate_a,
    output  logic [31:0]      pipe_alu_operate_b,
    
    output  logic [5:0]     pipe_branch_op,
    output  logic [31:0]    pipe_branch_offset,
    output  logic           pipe_jump,
    
    output  logic [4:0]       pipe_dest_addr,
    
    //mul
    //div
    //lsu
    output  logic [3:0]     pipe_lsu_op,
    output  logic [31:0]    pipe_lsu_wdata,

    output logic [31:0]     pc_id,
    output logic            id_valid
);

// Local Variables:
// verilog-library-directories:("." )
// End:

//////////////////////////////////////////////
/*AUTOLOGIC*/
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

parameter ALU_NUM           = 9;
parameter ALU_ADD           = 9'b0_0000_0001;
parameter ALU_SUB           = 9'b0_0000_0010;
parameter ALU_XOR           = 9'b0_0000_0100;
parameter ALU_OR            = 9'b0_0000_1000;
parameter ALU_AND           = 9'b0_0001_0000;
parameter ALU_SRA           = 9'b0_0010_0000;
parameter ALU_SRL           = 9'b0_0100_0000;
parameter ALU_SLT           = 9'b0_1000_0000;
parameter ALU_SLTU          = 9'b1_0000_0000;

parameter BRANCH_BEQ        = 6'b00_0001;
parameter BRANCH_BNE        = 6'b00_0010;
parameter BRANCH_BLT        = 6'b00_0100;
parameter BRANCH_BGE        = 6'b00_1000;
parameter BRANCH_BLTU       = 6'b01_0000;
parameter BRANCH_BGEU       = 6'b10_0000;

logic [6:0]     opcode;
logic [2:0]     funct3;
logic [7:0]     funct7;
logic [4:0]     rs1;
logic [4:0]     rs2;
logic [4:0]     rd;
logic [31:0]    imm_itype;
logic [31:0]    imm_stype;
logic [31:0]    imm_utype;
logic [31:0]    imm_btype;
logic [31:0]    imm_jtype;

logic           lui_intr;
logic           auipc_intr;
logic           branch_intr;
logic           jalr_intr;
logic           jal_intr;
logic           load_intr;
logic           store_intr;
logic           imm_intr;
logic           reg_intr;
logic           sys_intr;

logic           read_regfile_ch0_instr;
logic           read_regfile_ch1_instr;

logic           alu_add;
logic           alu_sub;
logic           alu_xor;
logic           alu_or;
logic           alu_and;
logic           alu_sra;
logic           alu_srl;
logic           alu_slt;
logic           alu_sltu;
logic [ALU_NUM-1:0] alu_op;
logic [31:0]    alu_operate_a;
logic [31:0]    alu_operate_b;

logic           beq;
logic           bne;
logic           blt;
logic           bge;
logic           bltu;
logic           bgeu;
logic [5:0]     branch_op;
logic [31:0]    branch_offset;

logic           load_store;
logic [2:0]     mem_width;
//////////////////////////////////////////////
//main code

assign opcode[6:0]  = instruction[6:0];
assign funct3[2:0]  = instruction[14:12];
assign funct7[7:0]  = instruction[31:25];
assign rs1[4:0]     = instruction[19:15];
assign rs2[4:0]     = instruction[24:20];
assign rd[4:0]      = instruction[11:7];
 
assign imm_itype[31:0] = { {20{instruction[31]}}, instruction[31:20] };
assign imm_stype[31:0] = { {20{instruction[31]}}, instruction[31:25],instruction[11:7]};
assign imm_utype[31:0] = { instruction[31:12], 12'h0 };
assign imm_btype[31:0] = { {19{instruction[31]}}, instruction[31], instruction[7],instruction[30:25],instruction[11:8],1'b0};
assign imm_jtype[31:0] = { {12{instruction[31]}}, instruction[19:12],instruction[20],instruction[30:21],1'b0};

assign lui_intr     = ( opcode[6:0] == OPCODE_LUI ); //lui
assign auipc_intr   = ( opcode[6:0] == OPCODE_AUIPC ); //luipc
assign branch_intr  = ( opcode[6:0] == OPCODE_BRANCH ); //beq,bne,blt,bge,bltu,bgeu
assign jal_intr     = ( opcode[6:0] == OPCODE_JAL ); //jar
assign jalr_intr    = ( opcode[6:0] == OPCODE_JALR ); //jalr
assign load_intr    = ( opcode[6:0] == OPCODE_LOAD ); //lb,lh,lw,lbu,lhu
assign store_intr   = ( opcode[6:0] == OPCODE_STORE ); //sb,sh,sw
assign imm_intr     = ( opcode[6:0] == OPCODE_IMM ); //addi,slti,sltiu,xori,andi,slli,srli,srai
assign reg_intr     = ( opcode[6:0] == OPCODE_REG ); //add,sub,sll,slt,sltu,xor,srl,sra,or,and
assign sys_intr     = ( opcode[6:0] == OPCODE_SYSTEM ); //csrrw,csrrs,csrrc,csrrwi,csrrsi,csrrci


//////////////////////////////////////////////
//read register file ch0
//////////////////////////////////////////////
assign read_regfile_ch0_instr = (
            reg_intr | load_intr | imm_intr | branch_intr | store_intr | jalr_intr | load_intr | store_intr
);

assign register_ch0_rd = ( ( instruction_value & (!stall_id) ) & read_regfile_ch0_instr );
assign register_ch0_addr[4:0] = rs1[4:0];


//////////////////////////////////////////////
//read register file ch1
//////////////////////////////////////////////
assign read_regfile_ch1_instr = reg_intr | branch_intr | store_intr;
assign register_ch1_rd = ( (instruction_value & (!stall_id) ) & read_regfile_ch1_instr );
assign register_ch1_addr[4:0] = rs2[4:0];


//////////////////////////////////////////////
//alu 
//////////////////////////////////////////////
assign alu_add = (
    ( imm_intr & (funct3==FUNC_ADDI)    ) |
    ( reg_intr & (funct3==FUNC_ADD)     ) |
    ( lui_intr                          ) |
    ( auipc_intr                        ) |
    ( load_intr                         ) |
    ( store_intr                        ) |
    ( jal_intr                          ) |
    ( jalr_intr                         ) |
    ( load_intr                         ) |
    ( store_intr                        ) 
);

assign alu_sub = ( reg_intr & (funct3==FUNC_SUB) );

assign alu_xor = (
    ( imm_intr & (funct3==FUNC_XORI)    ) |
    ( reg_intr & (funct3==FUNC_XOR)     )
);

assign alu_or = (
    ( imm_intr & (funct3==FUNC_ORI)     ) |
    ( reg_intr & (funct3==FUNC_OR)      )
);

assign alu_and = (
    ( imm_intr & (funct3==FUNC_ANDI)    ) |
    ( reg_intr & (funct3==FUNC_AND)     )
);

assign alu_sra = (
    ( imm_intr & (funct3==FUNC_SRAI)    ) |
    ( reg_intr & (funct3==FUNC_SRA)     )
);

assign alu_srl = (
    ( imm_intr & (funct3==FUNC_SRLI)    ) |
    ( reg_intr & (funct3==FUNC_SRL)     )
);

assign alu_slt = (
    ( imm_intr & (funct3==FUNC_SLTI)    ) |
    ( reg_intr & (funct3==FUNC_SLT)     )
);

assign alu_sltu = (
    ( imm_intr & (funct3==FUNC_SLTIU)   ) |
    ( reg_intr & (funct3==FUNC_SLTU)    )
);



//////////////////////////////////////////////
assign alu_op[ALU_NUM-1:0] = (
    ( {ALU_NUM{ alu_add } } & ALU_ADD ) |
    ( {ALU_NUM{ alu_sub } } & ALU_SUB ) |
    ( {ALU_NUM{ alu_xor } } & ALU_XOR ) |
    ( {ALU_NUM{ alu_or  } } & ALU_OR  ) |
    ( {ALU_NUM{ alu_and } } & ALU_AND ) |
    ( {ALU_NUM{ alu_sra } } & ALU_SRA ) |
    ( {ALU_NUM{ alu_srl } } & ALU_SRL ) |
    ( {ALU_NUM{ alu_slt } } & ALU_SLT ) |
    ( {ALU_NUM{ alu_sltu} } & ALU_SLTU) 
);

assign alu_operate_a = (
        ( {32{lui_intr              }} & {imm_utype[19:0],12'h0}    ) |
        ( {32{auipc_intr            }} & {pc_if[31:0]}              ) |
        ( {32{jal_intr              }} & {pc_if[31:0]}              ) |
        ( {32{read_regfile_ch0_instr}} & {register_ch0_data[31:0]}  ) 
);

assign alu_operate_b = (
        ( {32{lui_intr              }} & 32'h0                      ) |
        ( {32{auipc_intr            }} & imm_utype[31:0]            ) |
        ( {32{jal_intr              }} & imm_jtype[31:0]            ) |
        ( {32{jalr_intr             }} & imm_itype[31:0]            ) |
        ( {32{read_regfile_ch1_instr}} & register_ch1_data[31:0]    ) |
        ( {32{imm_intr              }} & imm_itype[31:0]            ) |
        ( {32{load_intr             }} & imm_itype[31:0]            ) |
        ( {32{store_intr            }} & imm_stype[31:0]            )
); 


//////////////////////////////////////////////
// branch instr
//////////////////////////////////////////////
assign beq = branch_intr & ( funct3[2:0] == FUNC_BEQ );
assign bne = branch_intr & ( funct3[2:0] == FUNC_BNE );
assign blt = branch_intr & ( funct3[2:0] == FUNC_BLT );
assign bge = branch_intr & ( funct3[2:0] == FUNC_BGE );
assign bltu= branch_intr & ( funct3[2:0] == FUNC_BLTU);
assign bgeu= branch_intr & ( funct3[2:0] == FUNC_BGEU);

assign branch_op[5:0] = (
        ( {6{beq}}  & BRANCH_BEQ  ) |
        ( {6{bne}}  & BRANCH_BNE  ) |
        ( {6{blt}}  & BRANCH_BLT  ) |
        ( {6{bge}}  & BRANCH_BGE  ) |
        ( {6{bltu}} & BRANCH_BLTU ) |
        ( {6{bgeu}} & BRANCH_BGEU ) 
);

assign branch_offset[31:0] = imm_btype[31:0];


//////////////////////////////////////////////
// branch instr
//////////////////////////////////////////////
assign jump = jal_intr | jalr_intr;


//////////////////////////////////////////////
// branch instr
//////////////////////////////////////////////
assign mem_width[2:0] = funct3[2:0];



//////////////////////////////////////////////
//pipeline register
//////////////////////////////////////////////
assign id_stage_ready = ( !stall_id ) | flush;

always @(posedge clk or negedge reset_n)begin
    if(!reset_n)begin
        pc_id[31:0] <= 32'b0;
    end else begin
        pc_id[31:0] <= pc_if[31:0];
    end
end

always @(posedge clk or negedge reset_n)begin
    if(!reset_n)begin
        pipe_alu_op[ALU_NUM-1:0]    <= {ALU_NUM{1'b0}};
        pipe_alu_operate_a[31:0]    <= 32'h0;
        pipe_alu_operate_b[31:0]    <= 32'h0;
        pipe_branch_op[5:0]         <= 6'h0;
        pipe_branch_offset[31:0]    <= 32'h0;
        pipe_dest_addr[4:0]         <= 4'h0;
        pipe_jump                   <= 1'b0;
    end else if( flush )begin
        pipe_alu_op[ALU_NUM-1:0]    <= {ALU_NUM{1'b0}};
        pipe_alu_operate_a[31:0]    <= 32'h0;
        pipe_alu_operate_b[31:0]    <= 32'h0;
        pipe_branch_op[5:0]         <= 6'h0;
        pipe_branch_offset[31:0]    <= 32'h0;
        pipe_dest_addr[4:0]         <= 4'h0;
        pipe_jump                   <= 1'b0;
        pipe_lsu_op[3:0]            <= 4'b0;
    end else if( !stall_id )begin
        pipe_alu_op[ALU_NUM-1:0]    <= alu_op[ALU_NUM-1:0];
        pipe_alu_operate_a[31:0]    <= alu_operate_a[31:0];
        pipe_alu_operate_b[31:0]    <= alu_operate_b[31:0];
        pipe_branch_op[5:0]         <= branch_op[5:0];
        pipe_branch_offset[31:0]    <= branch_offset[31:0];
        pipe_dest_addr[4:0]         <= rd[4:0];
        pipe_jump                   <= jump;
        pipe_lsu_op[3:0]            <= 4'b0;
    end
end

//lsu
assign load_store = load_intr | store_intr;
always @(posedge clk or negedge reset_n)begin
    if(!reset_n)begin
        pipe_lsu_op[4:0]            <= 5'b0;
        pipe_lsu_wdata[31:0]        <= 32'h0;
    end else if(flush)begin
        pipe_lsu_op[4:0]            <= 5'b0;
        pipe_lsu_wdata[31:0]        <= 32'h0;
    end else begin
        pipe_lsu_op[4:0]            <= {load_store,store,mem_width[2:0]};
        pipe_lsu_wdata[31:0]        <= alu_operate_b[31:0];
    end
end


always @(posedge clk or negedge reset_n)begin
    if(!reset_n)begin
        id_valid <= 1'b0;
    end else if(stall_id)begin
        id_valid <= id_valid;
    end else if(flush)begin
        id_valid <= 1'b0;
    end else begin
        id_valid <= instruction_value;
    end
end

//TODO
assign mem_valid_id = 1'b0;
assign mem_type_id[1:0] = 2'b0;

endmodule
