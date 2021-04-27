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

module id_stage(/*AUTOARG*/
    input                       clk,
    input                       reset_n,

    input   [31:0]              pc_if,
    input                       is_compress_instr,
    input   [31:0]              instruction,
    input                       instruction_value,

    //controller
    input                       flush_if_id,
    input                       stall_id_stage,

    //register access
    output                      register_ch0_rd,
    output  [4:0]               register_ch0_addr,
    input   [31:0]              register_ch0_data,

    output                      register_ch1_rd,
    output  [4:0]               register_ch1_addr,
    input   [31:0]              register_ch1_data,

    //ex stage
    //alu
    output  logic [ALU_NUM-1:0] ex_alu_op,
    output  logic [31:0]        ex_alu_operate_a,
    output  logic [31:0]        ex_alu_operate_b,
    output  logic [31:0]        ex_alu_operate_c,
    output  logic               ex_jump,
    
    output  logic [4:0]         ex_dest_addr,
    
    //mul
    //div
    //lsu
    output  logic               ex_lsu_valid,
    output  logic               ex_lsu_wr_type,
    output  logic [2:0]         ex_lsu_width_type,

    output logic [31:0]         pc_id
);

// Local Variables:
// verilog-library-directories:("." )
// End:

//////////////////////////////////////////////
/*AUTOLOGIC*/
//////////////////////////////////////////////

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

logic           lui_instr;
logic           auipc_instr;
logic           branch_instr;
logic           jalr_instr;
logic           jal_instr;
logic           load_instr;
logic           store_instr;
logic           imm_instr;
logic           reg_instr;
logic           sys_instr;

logic           dest_instr;

logic           read_regfile_ch0_instr;
logic           read_regfile_ch1_instr;

logic           alu_add;
logic           alu_sub;
logic           alu_xor;
logic           alu_or;
logic           alu_and;
logic           alu_sra;
logic           alu_sll;
logic           alu_srl;
logic           alu_slt;
logic           alu_sltu;
logic [ALU_NUM-1:0] alu_op;
logic [31:0]    alu_operate_a;
logic [31:0]    alu_operate_b;
logic [31:0]    alu_operate_c;

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

assign lui_instr     = ( opcode[6:0] == OPCODE_LUI ); //lui
assign auipc_instr   = ( opcode[6:0] == OPCODE_AUIPC ); //luipc
assign branch_instr  = ( opcode[6:0] == OPCODE_BRANCH ); //beq,bne,blt,bge,bltu,bgeu
assign jal_instr     = ( opcode[6:0] == OPCODE_JAL ); //jar
assign jalr_instr    = ( opcode[6:0] == OPCODE_JALR ); //jalr
assign load_instr    = ( opcode[6:0] == OPCODE_LOAD ); //lb,lh,lw,lbu,lhu
assign store_instr   = ( opcode[6:0] == OPCODE_STORE ); //sb,sh,sw
assign imm_instr     = ( opcode[6:0] == OPCODE_IMM ); //addi,slti,sltiu,xori,andi,slli,srli,srai
assign reg_instr     = ( opcode[6:0] == OPCODE_REG ); //add,sub,sll,slt,sltu,xor,srl,sra,or,and
assign sys_instr     = ( opcode[6:0] == OPCODE_SYSTEM ); //csrrw,csrrs,csrrc,csrrwi,csrrsi,csrrci

//the instr have dest register
assign dest_instr = lui_instr | auipc_instr | jal_instr | jalr_instr | load_instr | imm_instr | reg_instr | sys_instr;

//////////////////////////////////////////////
//read register file ch0
//////////////////////////////////////////////
assign operate_a_read_ch0 = (
            reg_instr    | 
            load_instr   | 
            imm_instr    | 
            branch_instr | 
            store_instr  | 
            jalr_instr   | 
            load_instr   | 
            store_instr
);

assign read_regfile_ch0_instr   = operate_a_read_ch0;
assign register_ch0_rd          = ( instruction_value & read_regfile_ch0_instr );
assign register_ch0_addr[4:0]   = rs1[4:0];


//////////////////////////////////////////////
//read register file ch1
//////////////////////////////////////////////
assign operate_b_read_ch1 = (
            reg_instr       | 
            branch_instr     
);

assign operate_c_read_ch1 = store_instr;

assign read_regfile_ch1_instr   = operate_b_read_ch1 | operate_c_read_ch1;
assign register_ch1_rd          = ( instruction_value & read_regfile_ch1_instr );
assign register_ch1_addr[4:0]   = rs2[4:0];


//////////////////////////////////////////////
//alu 
//////////////////////////////////////////////
assign alu_add = (
    ( reg_instr & (funct3==FUNC_ADD)    & (funct7==7'b000_0000)    ) |
    ( imm_instr & (funct3==FUNC_ADDI)    ) |
    ( lui_instr                          ) |
    ( auipc_instr                        ) |
    ( load_instr                         ) |
    ( store_instr                        ) |
    ( jal_instr                          ) |
    ( jalr_instr                         ) |
    ( load_instr                         ) |
    ( store_instr                        ) 
);

assign alu_sub = ( reg_instr & (funct3==FUNC_SUB) & (funct7==7'b010_0000) );

//logic
assign alu_xor = (
    ( reg_instr & (funct3==FUNC_XOR)    & (funct7==7'b000_0000)     ) |
    ( imm_instr & (funct3==FUNC_XORI)                               ) 
);

assign alu_or = (
    ( reg_instr & (funct3==FUNC_OR)     & (funct7==7'b000_0000)     ) |
    ( imm_instr & (funct3==FUNC_ORI)                                ) 
);

assign alu_and = (
    ( reg_instr & (funct3==FUNC_AND)    & (funct7==7'b000_0000)     ) |
    ( imm_instr & (funct3==FUNC_ANDI)                               ) 
);

//shift
assign alu_sll = (
    ( reg_instr & (funct3==FUNC_SLL)    & (funct7==7'b000_0000)     ) |
    ( imm_instr & (funct3==FUNC_SLLI)   & (funct7==7'b000_0000)     )
);

assign alu_sra = (
    ( reg_instr & (funct3==FUNC_SRA)    & (funct7==7'b010_0000)     ) |
    ( imm_instr & (funct3==FUNC_SRAI)   & (funct7==7'b010_0000)     ) 
);

assign alu_srl = (
    ( reg_instr & (funct3==FUNC_SRL)    & (funct7==7'b000_0000)     ) |
    ( imm_instr & (funct3==FUNC_SRLI)   & (funct7==7'b000_0000)     )
);

//compare
assign alu_slt = (
    ( reg_instr & (funct3==FUNC_SLT)    & (funct7==7'b000_0000)     ) |
    ( imm_instr & (funct3==FUNC_SLTI)                               )
);

assign alu_sltu = (
    ( reg_instr & (funct3==FUNC_SLTU)    & (funct7==7'b000_0000)    ) |
    ( imm_instr & (funct3==FUNC_SLTIU)                              )
);



//////////////////////////////////////////////
assign alu_op[ALU_NUM-1:0] = (
    ( {ALU_NUM{ alu_add     } } & ALU_ADD ) |
    ( {ALU_NUM{ alu_sub     } } & ALU_SUB ) |
    ( {ALU_NUM{ alu_xor     } } & ALU_XOR ) |
    ( {ALU_NUM{ alu_or      } } & ALU_OR  ) |
    ( {ALU_NUM{ alu_and     } } & ALU_AND ) |
    ( {ALU_NUM{ alu_sll     } } & ALU_SLL ) |
    ( {ALU_NUM{ alu_sra     } } & ALU_SRA ) |
    ( {ALU_NUM{ alu_srl     } } & ALU_SRL ) |
    ( {ALU_NUM{ alu_slt     } } & ALU_SLT ) |
    ( {ALU_NUM{ alu_sltu    } } & ALU_SLTU) |
    ( {ALU_NUM{ branch_instr} } & branch_op[ALU_NUM-1:0] ) 
);

assign alu_operate_a = (
        ( {32{lui_instr                 }} & {imm_utype[31:0]}          ) |
        ( {32{auipc_instr               }} & {pc_id[31:0]}              ) |
        ( {32{jal_instr                 }} & {pc_id[31:0]}              ) |
        ( {32{operate_a_read_ch0        }} & {register_ch0_data[31:0]}  ) 
);

assign alu_operate_b = (
        ( {32{lui_instr                 }} & 32'h0                      ) |
        ( {32{auipc_instr               }} & imm_utype[31:0]            ) |
        ( {32{jal_instr                 }} & imm_jtype[31:0]            ) |
        ( {32{jalr_instr                }} & imm_itype[31:0]            ) |
        ( {32{operate_b_read_ch1        }} & register_ch1_data[31:0]    ) |
        ( {32{imm_instr                 }} & imm_itype[31:0]            ) |
        ( {32{load_instr                }} & imm_itype[31:0]            ) |
        ( {32{store_instr               }} & imm_stype[31:0]            )
); 

assign alu_operate_c = (
        ( {32{branch_instr              }} & branch_offset[31:0]        ) |
        ( {32{operate_c_read_ch1        }} & register_ch1_data[31:0]    ) 
);


//////////////////////////////////////////////
// branch instr
//////////////////////////////////////////////
assign beq = branch_instr & ( funct3[2:0] == FUNC_BEQ );
assign bne = branch_instr & ( funct3[2:0] == FUNC_BNE );
assign blt = branch_instr & ( funct3[2:0] == FUNC_BLT );
assign bge = branch_instr & ( funct3[2:0] == FUNC_BGE );
assign bltu= branch_instr & ( funct3[2:0] == FUNC_BLTU);
assign bgeu= branch_instr & ( funct3[2:0] == FUNC_BGEU);

assign branch_op[ALU_NUM-1:0] = (
        ( {ALU_NUM{beq}}  & ALU_EQ  ) |
        ( {ALU_NUM{bne}}  & ALU_NE  ) |
        ( {ALU_NUM{blt}}  & ALU_LT  ) |
        ( {ALU_NUM{bge}}  & ALU_GE  ) |
        ( {ALU_NUM{bltu}} & ALU_LTU ) |
        ( {ALU_NUM{bgeu}} & ALU_GEU ) 
);

assign branch_offset[31:0] = imm_btype[31:0];


//////////////////////////////////////////////
// jump instr
//////////////////////////////////////////////
assign jump = jal_instr | jalr_instr;


//////////////////////////////////////////////
// lsu instr
//////////////////////////////////////////////
assign load_store = load_instr | store_instr;
assign mem_width[2:0] = funct3[2:0];



//////////////////////////////////////////////
//pipeline register
//////////////////////////////////////////////

always @(posedge clk or negedge reset_n)begin
    if(!reset_n)begin
        pc_id[31:0] <= 32'b0;
    end else if(!stall_id_stage ) begin
        pc_id[31:0] <= pc_if[31:0];
    end
end

//alu
always @(posedge clk or negedge reset_n)begin
    if(!reset_n)begin
        ex_alu_op[ALU_NUM-1:0]  <= {ALU_NUM{1'b0}};
        ex_alu_operate_a[31:0]  <= 32'h0;
        ex_alu_operate_b[31:0]  <= 32'h0;
        ex_alu_operate_c[31:0]  <= 32'h0;
        ex_jump                 <= 1'b0;
        ex_dest_addr[4:0]       <= 4'h0;
    end else if( flush_if_id )begin
        ex_alu_op[ALU_NUM-1:0]    <= {ALU_NUM{1'b0}};
        ex_alu_operate_a[31:0]    <= 32'h0;
        ex_alu_operate_b[31:0]    <= 32'h0;
        ex_alu_operate_c[31:0]    <= 32'h0;
        ex_dest_addr[4:0]         <= 4'h0;
        ex_jump                   <= 1'b0;
    end else if( !stall_id_stage & instruction_value )begin
        ex_alu_op[ALU_NUM-1:0]    <= alu_op[ALU_NUM-1:0];
        ex_alu_operate_a[31:0]    <= alu_operate_a[31:0];
        ex_alu_operate_b[31:0]    <= alu_operate_b[31:0];
        ex_alu_operate_c[31:0]    <= alu_operate_c[31:0];
        ex_dest_addr[4:0]         <= rd[4:0];
        ex_jump                   <= jump;
    end
end

//lsu
always @(posedge clk or negedge reset_n)begin
    if(!reset_n)begin
        ex_lsu_valid              <= 1'b0;
        ex_lsu_wr_type            <= 1'b0;
        ex_lsu_width_type[2:0]    <= 3'b0;
    end else if(flush_if_id)begin
        ex_lsu_valid              <= 1'b0;
        ex_lsu_wr_type            <= 1'b0;
        ex_lsu_width_type[2:0]    <= 3'b0;
    end else if(!stall_id_stage & instruction_value)begin
        ex_lsu_valid              <= load_store;
        ex_lsu_wr_type            <= store_instr;
        ex_lsu_width_type[2:0]    <= mem_width[2:0];
    end
end

//TODO fpu
//TODO mult
//TODO div

endmodule
