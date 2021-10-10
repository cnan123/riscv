//================================================================
//   Copyright (C) 2021. All rights reserved.
//
//   Filename     : branch_predict.sv
//   Auther       : cnan
//   Created On   : 2021.10.09
//   Description  : 
//
//
//================================================================

module branch_predict#(
    parameter ENA_BHT   = 1,
    parameter ENA_BTB   = 1,
    parameter ENA_JUMP  = 0,
    parameter ENA_RAS   = 0
)(
    input logic         clk,
    input logic         reset_n,

    input               predict_en,
    input logic [31:0]  fetch_pc_n, // next pc
    input logic [31:0]  fetch_pc,
    input logic [31:0]  fetch_rdata,
    input logic         fetch_valid,
    
    input               predict_fail,

    //updata bht        
    input               bht_updata,
    input [31:0]        bht_pc,
    input               bht_taken,

    //update btb
    input               btb_invalid,
    input               btb_update,
    input [31:0]        btb_pc,
    input [31:0]        btb_target,

    output logic        predict_taken,
    output logic [31:0] predict_pc
);
import riscv_pkg::*;

// Local Variables:
// verilog-library-directories:("." "dir1" "dir2" ...)
// End:

//////////////////////////////////////////////
/*AUTOLOGIC*/
//////////////////////////////////////////////

localparam PREDICTION_IDLE = 2'b00;
localparam PREDICTION_DATA = 2'b01;
localparam PREDICTION_HOLD = 2'b10;

logic [31:0]    instr;

logic           is_rvc;
logic           is_jal_r;
logic           rvc_jal;
logic           rvc_jalr;
logic           rvc_j;
logic           rvc_jr;
logic           rvc_jump;
logic           rvc_call;
logic           rvc_return;
logic           rvc_branch;
logic [31:0]    imm_cj_type;
logic [31:0]    imm_cb_type;
logic [31:0]    rvc_imm;

logic [4:0]     rs1;
logic [4:0]     rs2;
logic [4:0]     rd;

logic           rv_branch;
logic           rv_jump;
logic           rv_jalr;
logic           rv_call;
logic           rv_return;

logic [31:0]    imm_jtype;
logic [31:0]    imm_btype;
logic [31:0]    rv_imm;

logic           is_branch;
logic           is_jump;
logic           is_return;
logic           is_jalr;

logic [31:0]    imm;
logic [31:0]    bht_addr;
logic [31:0]    jump_addr;

logic           btb_rd;
logic [1:0]     fsm_prediction_cs,fsm_prediction_ns;
logic           btb_predict;
logic           btb_hit;
logic [31:1]    btb_addr;

logic           bht_predict;
logic           bht_rd;

//////////////////////////////////////////////
//main code

////////////////////////////////////////////////////////////////////////////////////////////////////////
//rvc
////////////////////////////////////////////////////////////////////////////////////////////////////////

assign instr        = fetch_rdata;
assign is_rvc       = (instr[1:0] != 2'b11);

//jump
assign is_jal_r     = (instr[1:0] == 2'b10) & (instr[15:13]==3'b100) & (instr[6:2]==5'b0) & is_rvc;

assign rvc_jal      = is_rvc & (instr[1:0]==2'b01) & (instr[15:13]==3'b001);
assign rvc_j        = is_rvc & (instr[1:0]==2'b01) & (instr[15:13]==3'b101);

assign rvc_jr       = is_jal_r & ~instr[12];

assign rvc_jalr     = is_jal_r & instr[12];
assign rvc_jump     = rvc_jal | rvc_j;
assign rvc_call     = rvc_jalr | rvc_jal;
assign rvc_return   = rvc_jr & ( (instr[11:7]==5'd1) | (instr[11:7]==5'd5) );

//rvc branch
assign rvc_branch = is_rvc & (instr[1:0]==2'b01) & ( (instr[15:13]==3'b110) | (instr[15:13]==3'b111) );

//rvc imm
assign imm_cj_type = { {20{instr[12]}}, instr[12], instr[8], instr[10:9], instr[6], instr[7], instr[2], instr[11], instr[5:3], 1'b0 }; 
assign imm_cb_type = { {23{instr[12]}}, instr[12], instr[6:5], instr[2], instr[11:10], instr[4:3], 1'b0};
assign rvc_imm = instr[14] ? imm_cb_type : imm_cj_type;


////////////////////////////////////////////////////////////////////////////////////////////////////////
//rv32
////////////////////////////////////////////////////////////////////////////////////////////////////////
assign rs1[4:0]     = instr[19:15];
assign rs2[4:0]     = instr[24:20];
assign rd[4:0]      = instr[11:7];

assign rv_branch = (instr[6:0] == OPCODE_BRANCH);
assign rv_jump   = (instr[6:0] == OPCODE_JAL);
assign rv_jalr   = (instr[6:0] == OPCODE_JALR);

//reserved for return-address stack
assign rv_call   = (rv_jump | rv_jalr ) & ( (rd[4:0]==5'd1) | (rd[4:0]==5'd5) );
assign rv_return = rv_jalr & ( (rs1[4:0]==5'd1) | (rs1[4:0]==5'd5) ) & (rs1[4:0] != rd[4:0]);

assign imm_jtype = { {12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0 };
assign imm_btype = { {19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0 };

assign rv_imm = instr[2] ? imm_jtype : imm_btype;


////////////////////////////////////////////////////////////////////////////////////////////////////////
assign is_branch = fetch_valid & ( rvc_branch  | rv_branch );
assign is_jump   = fetch_valid & ( rvc_jump   | rv_jump );
assign is_jalr   = fetch_valid & ( rvc_jalr | rvc_jr | rv_jalr ) & ( ~ (ENA_RAS & is_return) );
assign is_return = fetch_valid & ( rvc_return | rv_return );

////////////////////////////////////////////////////////////////////////////////////////////////////////
always_comb begin
    predict_taken   = 1'b0;
    predict_pc      = 32'h0;
    unique case({is_branch, is_jalr, is_jump})
        3'b100:begin
            predict_taken   = bht_predict;
            predict_pc      = bht_addr;
        end
        3'b010:begin
            predict_taken   = btb_predict;
            predict_pc      = { btb_addr[31:1], 1'b0 };
        end
        3'b001:begin
            predict_taken   = ENA_JUMP;
            predict_pc      = jump_addr;
        end
        default:;
    endcase
end

assign imm = is_rvc ? rvc_imm : rv_imm;
assign bht_addr     = fetch_pc + imm;
assign jump_addr    = fetch_pc + imm;

////////////////////////////////////////////////////////////////////////////////////////////////////////
//controller
////////////////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////////////////////////////
//btb
generate
if(ENA_BTB)begin
assign btb_rd       = predict_en & ~predict_fail;
assign btb_predict  = btb_hit;

btb #(
    .ENTRY  (128)
)btb(
	.clk				(clk                    ),
	.reset_n			(reset_n                ),
    .flush              (predict_fail           ),
	.pc_r				(fetch_pc_n[31:1]       ),
	.btb_rd				(btb_rd                 ),
	.btb_hit			(btb_hit                ),
	.target_pc_r		(btb_addr[31:1]         ),
	.btb_wr				(btb_update             ),
	.btb_invalid		(btb_invalid            ),	
	.pc_w				(btb_pc[31:1]           ),
	.target_pc_w		(btb_target[31:0]       )
);	 
end else begin
        assign btb_hit = 1'b0;
        assign btb_addr = 32'h0;
        assign btb_predict = 1'b0;
end
endgenerate

////////////////////////////////////////////////////////////////////////////////////////////////////////
//bht
generate
if(ENA_BHT)begin
assign bht_rd   = predict_en;

bht #(
    .DEPTH  (1024)
)bht(
	.clk				(clk                    ),
	.reset_n			(reset_n                ),
	.update_en			(bht_updata             ),
	.taken				(bht_taken              ),
	.pc_ex				(bht_pc[31:0]           ),
	.rd_en				(bht_rd                 ),
	.pc_if				(fetch_pc_n[31:0]       ),
	.predict_taken		(bht_predict            )
);
end else begin
    assign bht_predict = 1'b0;
end
endgenerate
endmodule
