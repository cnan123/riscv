//================================================================
//   Copyright (C) 2021 Sangfor Ltd. All rights reserved.
//
//   Filename     : ex_stage.v
//   Auther       : cnan
//   Created On   : 2021年04月04日
//   Description  : 
//
//
//================================================================

module ex_stage(/*AUTOARG*/
    input               clk,
    input               reset_n,

    input               ex_stall,
    input               flush,
    output logic [31:0] pc_ex,

    input [31:0]        pc_id,
    input [4:0]         ex_dest_addr,
    output              ex_dest_valid,
    output [31:0]       ex_dest_data,
    output              ex_busy,

    output logic              mem_dest_valid,
    output logic [4:0]        mem_dest_addr,
    output logic [31:0]       mem_dest_data,

    //branch taken
    output logic            branch_taken,
    output logic [31:0]     branch_target_addr,

    //alu
    input               id_valid,
    input [8:0]         alu_operator,
    input [31:0]        alu_operate_a,
    input [31:0]        alu_operate_b,
    input [5:0]         branch_op,
    input [31:0]        branch_offset,
    input               jump,
    output logic [31:0] jump_target_addr,

    //memory(load/store)
    input   [4:0]       lsu_op,
    input   [31:0]      lsu_wdata,
    output              mem_stage_valid,
    output [2:0]        mem_stage_type,
    output [31:0]       mem_stage_addr,
    output [31:0]       mem_stage_wdata
);

// Local Variables:
// verilog-library-directories:(".")
// End:

//////////////////////////////////////////////
/*AUTOLOGIC*/
//////////////////////////////////////////////
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

logic [31:0] alu_result;
logic [31:0] shift_result;
logic [31:0] alu_add_result;
logic [31:0] alu_add_a;
logic [31:0] alu_add_b;
logic           branch;
logic           alu;
logic           equal_result;
logic           less_than_result;

logic [31:0]    return_addr;
//////////////////////////////////////////////
//main code

assign branch = ( (|branch_op[5:0]) & id_valid );
assign alu = ( (|alu_operator) & id_valid );

assign alu_add_a[31:0] = (
        ( {32{branch}}  & pc_id[31:0]           ) |
        ( {32{jump}}    & alu_operate_a[31:0]   ) |
        ( {32{alu}}     & alu_operate_a[31:0]   )
);

assign alu_add_b[31:0] = (
        ( {32{branch}}  & branch_offset[31:0]   ) |
        ( {32{jump}}    & alu_operate_b[31:0]   ) |
        ( {32{alu}}     & alu_operate_b[31:0]   )
);

assign alu_add_result = alu_add_a + alu_add_b;

always @(*)begin
    case (alu_operator)
        ALU_ADD: alu_result = alu_add_result;
        ALU_SUB: alu_result = alu_operate_a - alu_operate_b;
        ALU_XOR: alu_result = alu_operate_a ^ alu_operate_b;
        ALU_OR:  alu_result = alu_operate_a | alu_operate_b;
        ALU_AND: alu_result = alu_operate_a & alu_operate_b;
        ALU_SRL,ALU_SRL,ALU_SLT,ALU_SLTU: alu_result = shift_result;
        default:alu_result = 32'h0;
    endcase
end
        
//lsu
assign mem_stage_addr   = alu_add_result;
assign mem_stage_wdata  = lsu_wdata;
assign mem_stage_valid  = lsu_op[4];
assign mem_stage_type   = lsu_op[3:0];



//TODO
assign ex_valid = id_valid; //Now only signal cycle exe
assign shift_result[31:0] = 32'h0;

assign mutli_cycle = 1'b0;
assign mutli_cycle_busy = 1'b0;

assign ex_busy = mutli_cycle & mutli_cycle_busy ; //TODO
assign ex_dest_valid = id_valid & ~ex_busy;

assign return_addr = pc_id + 4;
assign ex_dest_data = jump ? return_addr : alu_result;//TODO


//////////////////////////////////////////////
//branch
//////////////////////////////////////////////
always @(*)begin
    branch_taken = 1'b0;
    case (branch_op)
        BRANCH_BEQ : branch_taken = equal_result;
        BRANCH_BNE : branch_taken = ~equal_result;
        BRANCH_BLT : branch_taken = less_than_result;
        BRANCH_BGE : branch_taken = ~less_than_result;
        BRANCH_BLTU: branch_taken = less_than_result;
        BRANCH_BGEU: branch_taken = ~less_than_result;
        default: branch_taken = 1'b0;
    endcase
end

assign equal_result     = (alu_operate_a == alu_operate_b);
assign less_than_result = (alu_operate_a < alu_operate_b);

assign branch_target_addr = alu_add_result;


//////////////////////////////////////////////
//branch
//////////////////////////////////////////////
assign jump_target_addr = alu_add_result;

//////////////////////////////////////////////
//pipeline
//////////////////////////////////////////////
always @(posedge clk or negedge reset_n)begin
    if(!reset_n)begin
       mem_dest_valid  <= 1'b0;
       mem_dest_addr[4:0]   <= 5'h0;
       mem_dest_data[31:0]  <= 32'h0;
    end else if(ex_valid)begin
        mem_dest_valid <= alu | jump;
        mem_dest_addr[4:0]  <= ex_dest_addr[4:0];
        mem_dest_data[31:0] <= ex_dest_data[31:0];
    end else begin
       mem_dest_valid  <= 1'b0;
       mem_dest_addr[4:0]   <= 5'h0;
       mem_dest_data[31:0]  <= 32'h0;
    end
end

always @(posedge clk or negedge reset_n)begin
    if(!reset_n)begin
        pc_ex[31:0] <= 32'h0;
    end else if(id_valid)begin
        pc_ex[31:0] <= pc_id[31:0];
    end
end

endmodule
