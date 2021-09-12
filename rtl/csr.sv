//================================================================
//   Copyright (C) 2021. All rights reserved.
//
//   Filename     : csr.sv
//   Auther       : cnan
//   Created On   : 2021.05.04
//   Description  : 
//
//
//================================================================

module csr(
        input                   clk,
        input                   reset_n,

        input           [31:0]  hartid,
        input           [31:0]  pc_if,
        input           [31:0]  pc_wb,

        input                   is_mret,
        input                   mepc_updata,
        input mepc_mux_e        mepc_mux,
        input                   mcause_update,
        input mcause_e          mcause,

        //csr instr
        input                   csr_en,
        input           [1:0]   csr_op,
        input           [11:0]  csr_addr,
        input           [31:0]  csr_wdata,
        output  logic   [31:0]  csr_rdata,
        output  logic           illegal_csr,

        //interrupt
        input                   extern_intr,
        input                   timer_intr,
        input                   software_intr,

        //constrol status register
        output privilege_e      privilege_mode,
        output logic            mstatus_mie,
        output logic [31:0]     mepc,
        output logic [31:0]     mtvec,
        output logic [31:0]     mie
);

// Local Variables:
// verilog-library-directories:("." "dir1" "dir2" ...)
// End:

//////////////////////////////////////////////
/*AUTOLOGIC*/
//////////////////////////////////////////////

logic       mvendorid_en            ;
logic       marchid_en              ; 
logic       mimpid_en               ;
logic       mhartid_en              ;
logic       mstatus_en              ;
logic       misa_en                 ;
logic       mie_en                  ;
logic       mtvec_en                ;
logic       mscratch_en             ;
logic       mepc_en                 ;
logic       mcause_en               ;
logic       mtval_en                ;
logic       mip_en                  ;
logic       mcounter_en;
logic       mcountinhit_en;
logic       mcycle_en;
logic       illegal_csr_register    ;


status_rv_t mstatus_n,mstatus_q;
privilege_e privilege_mode_q,privilege_mode_n;

logic [31:0] mie_n,mie_q;
logic [31:0] mip_q;
logic [31:0] mtvec_n,mtvec_q;

logic [31:0] mvendorid_q; 
logic [31:0] marchid_q;   
logic [31:0] mimpid_q;    
logic [31:0] mhartid_q;   
logic [31:0] misa_q;      
logic [31:0] mscratch_q;  
logic [31:0] mepc_n,mepc_q;      
logic [31:0] mcause_n,mcause_q;    
logic [31:0] mcounteren_n,mcounteren_q;    
logic [31:0] mcountinhit_n,mcountinhit_q;    
logic [31:0] mcycle_n,mcycle_q;    

logic [31:0] mtval_q;     

logic [31:0] rdata;

//////////////////////////////////////////////
//main code

always @(*)begin
    mvendorid_en            = 1'b0;
    marchid_en              = 1'b0; 
    mimpid_en               = 1'b0;
    mhartid_en              = 1'b0;
    mstatus_en              = 1'b0;
    misa_en                 = 1'b0;
    mie_en                  = 1'b0;
    mtvec_en                = 1'b0;
    mscratch_en             = 1'b0;
    mepc_en                 = 1'b0;
    mcause_en               = 1'b0;
    mtval_en                = 1'b0;
    mip_en                  = 1'b0;
    mcounter_en             = 1'b0;
    mcountinhit_en          = 1'b0;
    mcycle_en               = 1'b0;

    csr_rdata               = 32'h0;
    illegal_csr             = 1'b0;

    if( csr_en )begin
        unique case(csr_addr[11:0])
            MVENDORID : begin 
                mvendorid_en    = (~illegal_csr); 
                csr_rdata       = mvendorid_q; 
                illegal_csr     = (privilege_mode_q != PRIV_LVL_M); 
            end
            MARCHID : begin 
                marchid_en  = (~illegal_csr); 
                csr_rdata   = marchid_q;   
                illegal_csr = (privilege_mode_q != PRIV_LVL_M); 
            end
            MIMPID : begin 
                mimpid_en   = (~illegal_csr); 
                csr_rdata   = mimpid_q;    
                illegal_csr = (privilege_mode_q != PRIV_LVL_M); 
            end
            MHARTID : begin 
                mhartid_en  = (~illegal_csr); 
                csr_rdata   = mhartid_q;   
                illegal_csr = (privilege_mode_q != PRIV_LVL_M); 
            end
            MSTARUS : begin 
                mstatus_en  = (~illegal_csr); 
                csr_rdata   = mstatus_q;   
                illegal_csr = (privilege_mode_q != PRIV_LVL_M); 
            end
            MISA : begin 
                misa_en     = (~illegal_csr); 
                csr_rdata   = misa_q;      
                illegal_csr = (privilege_mode_q != PRIV_LVL_M); 
            end
            MIE : begin 
                mie_en      = (~illegal_csr); 
                csr_rdata   = mie_q;       
                illegal_csr = (privilege_mode_q != PRIV_LVL_M); 
            end
            MTVEC : begin 
                mtvec_en    = (~illegal_csr); 
                csr_rdata   = mtvec_q;     
                illegal_csr = (privilege_mode_q != PRIV_LVL_M); 
            end
            MSCRATCH : begin 
                mscratch_en = (~illegal_csr); 
                csr_rdata   = mscratch_q;  
                illegal_csr = (privilege_mode_q != PRIV_LVL_M); 
            end
            MEPC : begin 
                mepc_en     = (~illegal_csr); 
                csr_rdata   = mepc_q;      
                illegal_csr = (privilege_mode_q != PRIV_LVL_M); 
            end
            MCAUSE : begin 
                mcause_en   = (~illegal_csr); 
                csr_rdata   = mcause_q;    
                illegal_csr = (privilege_mode_q != PRIV_LVL_M); 
            end
            MTVAL : begin 
                mtval_en    = (~illegal_csr); 
                csr_rdata   = mtval_q;     
                illegal_csr = (privilege_mode_q != PRIV_LVL_M); 
            end
            MIP : begin 
                mip_en      = (~illegal_csr); 
                csr_rdata   = mip_q;       
                illegal_csr = (privilege_mode_q != PRIV_LVL_M); 
            end
            MCOUNTEREN  : begin
                mcounter_en = (~illegal_csr);
                csr_rdata   = mcounteren_q;
                illegal_csr = (privilege_mode_q != PRIV_LVL_M); 
            end
            MCOUNTINHIBIT :begin 
                mcountinhit_en  = (~illegal_csr);
                csr_rdata       = mcountinhit_q;
                illegal_csr     = (privilege_mode_q != PRIV_LVL_M); 
            end
            MCYCLE : begin 
                mcycle_en   = (~illegal_csr);
                csr_rdata   = mcycle_q;
                illegal_csr = (privilege_mode_q != PRIV_LVL_M); 
            end
            default : begin illegal_csr = 1'b1; end
        endcase
    end
end

//////////////////////////////////////////////
//mvendorid
//////////////////////////////////////////////
assign mvendorid_q = 32'h0;


//////////////////////////////////////////////
//marchid
//////////////////////////////////////////////
assign marchid_q = 32'h0;


//////////////////////////////////////////////
//mimpid
//////////////////////////////////////////////
assign mimpid_q = 32'h0;


//////////////////////////////////////////////
//mhartid
//////////////////////////////////////////////
assign mhartid_q = hartid;


//////////////////////////////////////////////
//misa
//////////////////////////////////////////////
assign misa_q = ISA_CODE;


//////////////////////////////////////////////
//mstatus
//////////////////////////////////////////////
always @(posedge clk or negedge reset_n)begin
    if(!reset_n)begin
        mstatus_q <= '{
            mie     : 1'b0,
            mpie    : 1'b1,
            mpp     : PRIV_LVL_U,
            mprv    : 1'b0,
            default : 'h0
        };
    end else begin
        mstatus_q <= mstatus_n;
    end
end

always @(*)begin
    mstatus_n = mstatus_q;
    if( mstatus_en )begin
        unique case(csr_op)
            CSR_OP_WRITE:begin
                mstatus_n.mie   = csr_wdata[BIT_MSTATUS_MIE];
                mstatus_n.mpie  = csr_wdata[BIT_MSTATUS_MPIE];
                mstatus_n.mpp   = csr_wdata[BIT_MSTATUS_MPP_MSB:BIT_MSTATUS_MPP_LSB];
            end 
            CSR_OP_SET:begin
                mstatus_n.mie   = mstatus_q.mie  | csr_wdata[BIT_MSTATUS_MIE] ;
                mstatus_n.mpie  = mstatus_q.mpie | csr_wdata[BIT_MSTATUS_MPIE];
                mstatus_n.mpp   = mstatus_q.mpp  | csr_wdata[BIT_MSTATUS_MPP_MSB:BIT_MSTATUS_MPP_LSB];
            end
            CSR_OP_CLEAR:begin
                mstatus_n.mie   = mstatus_q.mie  & (~csr_wdata[BIT_MSTATUS_MIE]) ;
                mstatus_n.mpie  = mstatus_q.mpie & (~csr_wdata[BIT_MSTATUS_MPIE]);
                mstatus_n.mpp   = mstatus_q.mpp  & (~csr_wdata[BIT_MSTATUS_MPP_MSB:BIT_MSTATUS_MPP_LSB]);
            end
            default:;
        endcase
    end else if( mcause_update )begin
        mstatus_n.mie   = 1'b0;
        mstatus_n.mpie  = mstatus_q.mie;
        mstatus_n.mpp   = privilege_mode_q;
    end else if( is_mret )begin
        mstatus_n.mie   = mstatus_q.mpie;
        mstatus_n.mpie  = 1'b1;
        mstatus_n.mpp   = PRIV_LVL_U;
    end
end

assign mstatus_mie = mstatus_q.mie;

//////////////////////////////////////////////
//mcause
//////////////////////////////////////////////
always @(posedge clk or negedge reset_n)begin
    if( !reset_n )begin
        mcause_q = 32'h0;
    end else begin
        mcause_q <= mcause_n;
    end
end

always @(*)begin
    mcause_n = mcause_q;
    if( mcause_en )begin
        unique case(csr_op)
            CSR_OP_WRITE:begin
                mcause_n = { csr_wdata[31], 26'h0, csr_wdata[4:0] };
            end 
            CSR_OP_SET:begin
                mcause_n = mcause_q | { csr_wdata[31], 26'h0, csr_wdata[4:0] };
            end
            CSR_OP_CLEAR:begin
                mcause_n = mcause_q & ( ~ { csr_wdata[31], 26'h0, csr_wdata[4:0] } );
            end
            default:;
        endcase
    end else if( mcause_update )begin
        mcause_n = { mcause[5], 26'h0, mcause[4:0] };
    end
end


//////////////////////////////////////////////
//mie
//  11    9     7    5    3    1
// MEIE  SEIE  MTIE STIE MSIE SSIE
//////////////////////////////////////////////

always @(posedge clk or negedge reset_n)begin
    if(!reset_n)begin
        mie_q <= 32'h0;
    end else begin
        mie_q <= mie_n;
    end
end

always @(*)begin
    mie_n = mie_q;
    if( mie_en )begin
        unique case(csr_op)
            CSR_OP_WRITE:begin
                mie_n[BIT_MIE_MEIE]  = csr_wdata[BIT_MIE_MEIE];
                mie_n[BIT_MIE_MTIE]  = csr_wdata[BIT_MIE_MTIE];
                mie_n[BIT_MIE_MSIE]  = csr_wdata[BIT_MIE_MSIE];
            end 
            CSR_OP_SET:begin
                mie_n[BIT_MIE_MEIE] = mie_q[BIT_MIE_MEIE] | csr_wdata[BIT_MIE_MEIE];
                mie_n[BIT_MIE_MTIE] = mie_q[BIT_MIE_MTIE] | csr_wdata[BIT_MIE_MTIE];
                mie_n[BIT_MIE_MSIE] = mie_q[BIT_MIE_MSIE] | csr_wdata[BIT_MIE_MSIE];
            end
            CSR_OP_CLEAR:begin
                mie_n[BIT_MIE_MEIE] = mie_q[BIT_MIE_MEIE] & (~csr_wdata[BIT_MIE_MEIE]);
                mie_n[BIT_MIE_MTIE] = mie_q[BIT_MIE_MTIE] & (~csr_wdata[BIT_MIE_MTIE]);
                mie_n[BIT_MIE_MSIE] = mie_q[BIT_MIE_MSIE] & (~csr_wdata[BIT_MIE_MSIE]);
            end
            default:;
        endcase
    end
end

assign mie = mie_q;

//////////////////////////////////////////////
//mip
//  11    9     7    5    3    1
// MEIP  SEIP  MTIP STIP MSIP SSIP
//////////////////////////////////////////////
always @(posedge clk or negedge reset_n)begin
    if(!reset_n)begin
        mip_q <= 32'h0;
    end else begin
        mip_q <= {20'h0, extern_intr,3'h0, timer_intr,3'h0, software_intr, 3'h0};
    end
end


//////////////////////////////////////////////
//mtvec
//MXLEN-1:2 1:0
// BASE     MODE
//////////////////////////////////////////////
always @(posedge clk or negedge reset_n)begin
    if(!reset_n)begin
        mtvec_q <= 32'h0;
    end else begin
        mtvec_q <= mtvec_n;
    end
end

always @(*)begin
    mtvec_n = mtvec_q;
    if( mtvec_en )begin
        unique case(csr_op)
            CSR_OP_WRITE:   mtvec_n = {csr_wdata[31:8],6'h0,csr_wdata[1:0]};
            CSR_OP_SET:     mtvec_n = mtvec_q | {csr_wdata[31:8],6'h0,csr_wdata[1:0]};
            CSR_OP_CLEAR:   mtvec_n = mtvec_q & (~{csr_wdata[31:8],6'h0,csr_wdata[1:0]});
            default:;
        endcase
    end
end

assign mtvec = mtvec_q;

//////////////////////////////////////////////
//mscratch, mepc, mcause, mtval
//////////////////////////////////////////////
assign mepc = mepc_q;

always @(posedge clk or negedge reset_n)begin
    if(!reset_n)begin
        mepc_q <= 32'h0;
    end else begin
        mepc_q <= mepc_n;
    end
end

always @(*)begin
    mepc_n = mepc_q;
    if( mepc_en )begin
         unique case(csr_op)
            CSR_OP_WRITE:   mepc_n = { csr_wdata[31:1], 1'b0 };
            CSR_OP_SET:     mepc_n = mepc_q | {csr_wdata[31:1],1'b0 };
            CSR_OP_CLEAR:   mepc_n = mepc_q & (~{csr_wdata[31:1],1'b1});
            default:;
        endcase
    end else if( mepc_updata )begin
        unique case(mepc_mux)
            MEPC_PC_IF: mepc_n = { pc_if[31:1], 1'b0 };
            MEPC_PC_WB: mepc_n = { pc_wb[31:1], 1'b0 };
            default:;
        endcase
    end
end


//////////////////////////////////////////////
//privilege_mode
//////////////////////////////////////////////
always @(posedge clk or negedge reset_n)begin
    if(!reset_n)begin
        privilege_mode_q <= PRIV_LVL_M;
    end else begin
        privilege_mode_q <= privilege_mode_n;
    end
end

always @(*)begin
    privilege_mode_n = privilege_mode_q;
    unique case(privilege_mode_q)
        PRIV_LVL_M: begin
            if( is_mret )begin
                privilege_mode_n = privilege_e'(mstatus_q.mpp);
            end
        end
        PRIV_LVL_U: begin
            if( mcause_update )begin
                privilege_mode_n = PRIV_LVL_M;
            end
        end
        default:;
    endcase
end

assign privilege_mode = privilege_mode_q;

//////////////////////////////////////////////
//counter
//////////////////////////////////////////////
always @(posedge clk or negedge reset_n)begin
    if(!reset_n)begin
        mcounteren_q    <= 32'h0;
        mcountinhit_q   <= 32'h0;
        mcycle_q        <= 32'h0;
    end else begin
        mcounteren_q    <= mcounteren_n;
        mcountinhit_q   <= mcountinhit_n;
        mcycle_q        <= mcycle_n;
    end
end

always_comb begin
    mcounteren_n    = mcounteren_q;
    if( mepc_en )begin
        unique case(csr_op)
           CSR_OP_WRITE:   mcounteren_n = csr_wdata[31:0];
           CSR_OP_SET:     mcounteren_n = mcounteren_q | csr_wdata[31:0];
           CSR_OP_CLEAR:   mcounteren_n = mcounteren_q & (~csr_wdata[31:0]);
           default:;
        endcase
    end
end

always_comb begin
    mcountinhit_n    = mcountinhit_q;
    if( mcountinhit_en )begin
        unique case(csr_op)
           CSR_OP_WRITE:   mcountinhit_n = csr_wdata[31:0];
           CSR_OP_SET:     mcountinhit_n = mcountinhit_q | csr_wdata[31:0];
           CSR_OP_CLEAR:   mcountinhit_n = mcountinhit_q & (~ csr_wdata[31:0]);
           default:;
        endcase
    end
end

always_comb begin
    mcycle_n    = mcycle_q + mcountinhit_q[0];
    if( mcycle_en )begin
        unique case(csr_op)
           CSR_OP_WRITE:   mcycle_n = csr_wdata[31:0];
           CSR_OP_SET:     mcycle_n = mcycle_q | csr_wdata[31:0];
           CSR_OP_CLEAR:   mcycle_n = mcycle_q & (~csr_wdata[31:0]);
           default:;
        endcase
    end
end



//
//
endmodule
