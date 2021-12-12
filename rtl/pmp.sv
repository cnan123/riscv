//================================================================
//   Copyright (C) 2021. All rights reserved.
//
//   Filename     : pmp.sv
//   Auther       : cnan
//   Created On   : 2021.11.27
//   Description  : 
//
//
//================================================================

module pmp#(
    parameter PMP_ENTRY     = 16
)(
    input   [PMP_ENTRY-1:0][7:0]    pmpcfg_i,
    input   [PMP_ENTRY-1:0][33:0]   pmpaddr_i,

    input   privilege_e         privilege_mode,
    input                       acs_en_i,
    input   [2:0]               acs_type_i, //[X, W, R]
    input   [31:0]              acs_address_i,
    output                      pmp_err_o
);

// Local Variables:
// verilog-library-directories:("." "dir1" "dir2" ...)
// End:

//////////////////////////////////////////////
/*autodef*/
    //Start of automatic define
    //Start of automatic reg
    //Define flip-flop registers here
    //Define combination registers here
    //End of automatic reg
    //Start of automatic wire
    //Define assign wires here
    logic [PMP_ENTRY-1:0]                    pmp_mode                        ;
    logic [PMP_ENTRY-1:0][2:0]               pmp_pms                         ;
    logic [PMP_ENTRY-1:0]                    pmp_lock                        ;
    logic [PMP_ENTRY-1:0][33:0]              tor_address                     ;
    logic [PMP_ENTRY-1:0][33:0]              na4_address                     ;
    logic [PMP_ENTRY-1:0][33:2]              napot_mask                      ;
    logic [PMP_ENTRY-1:0]                    tor_match                       ;
    logic [PMP_ENTRY-1:0]                    na4_match                       ;
    logic [PMP_ENTRY-1:0]                    napot_match                     ;
    logic [PMP_ENTRY-1:0]                    entry_match                     ;
    logic [PMP_ENTRY-1:0]                    pms_match                       ;
    logic [PMP_ENTRY-1:0]                    u_mode_entry_fail               ;
    logic [PMP_ENTRY-1:0]                    m_mode_entry_fail               ;
    logic [PMP_ENTRY-1:0]                    u_mode_fail               ;
    logic [PMP_ENTRY-1:0]                    m_mode_fail               ;
    integer                                 i                               ;
    //Define instance wires here
    //WIRE_DEL: Wire entry_match_success has been deleted.
    //End of automatic wire
    //End of automatic define
//////////////////////////////////////////////


//////////////////////////////////////////////
//main code

generate
for(genvar n=0; n<PMP_ENTRY; n++)begin: pmp_entry
    assign pmp_mode[n]      = pmpcfg_i[n][4:3];
    assign pmp_pms[n][2:0]  = pmpcfg_i[n][2:0];
    assign pmp_lock[n]      = pmpcfg_i[n][7];

    assign tor_address[n]   = {pmpaddr_i[n][31:0], 2'b0};
    assign na4_address[n]   = {pmpaddr_i[n][31:0], 2'b0};
    
    for(genvar m=2;m<34;m++)begin
        if(m==2)begin 
            assign napot_mask[n][m] = (pmp_mode[n] != NAPOT);
        end else begin
            assign napot_mask[n][m] = ~(&pmpaddr_i[n][m-1:2]);
        end
    end
    
    if(n==0)begin
        assign tor_match[n] = (acs_address_i[31:2] < tor_address[n][31:2]);
    end else begin
        assign tor_match[n] = (
            (acs_address_i[31:2] >= tor_address[n-1][31:2]) &
            (acs_address_i[31:2] <  tor_address[n][31:2])
        );
    end

    assign na4_match[n]     = (acs_address_i[31:2] == tor_address[n][31:2]);
    assign napot_match[n]   = ( (acs_address_i[31:2] & napot_mask[n][31:2]) == (pmpaddr_i[n][31:2] & napot_mask[n][31:2]) );

    assign entry_match[n] = (
        ( (pmp_mode[n] == TOR) && tor_match[n] ) |
        ( (pmp_mode[n] == NA4) && na4_match[n] ) |
        ( (pmp_mode[n] == NAPOT) && napot_match[n] )
    );

    assign pms_match[n] = (
        (pmp_pms[n][0] & acs_type_i[0]) |
        (pmp_pms[n][1] & acs_type_i[1]) |
        (pmp_pms[n][2] & acs_type_i[2]) 
    );

    assign u_mode_entry_fail[n] = entry_match[n] ? ~pms_match[n] : 1'b0;
    assign m_mode_entry_fail[n] = (entry_match[n] & pmp_lock[n]) ? ~pms_match[n] : 1'b0;

    if(n==0)begin
        assign u_mode_fail[n] = u_mode_entry_fail[n];
        assign m_mode_fail[n] = m_mode_entry_fail[n];
    end else begin
        assign u_mode_fail[n] = u_mode_entry_fail[n-1] ? 1'b1 : u_mode_entry_fail[n];
        assign m_mode_fail[n] = m_mode_entry_fail[n-1] ? 1'b1 : m_mode_entry_fail[n];
    end
end
endgenerate

assign pmp_err_o = (privilege_mode == PRIV_LVL_M) ? acs_en_i & m_mode_fail[PMP_ENTRY-1] : acs_en_i & ( u_mode_fail[PMP_ENTRY-1] | ( ~(|entry_match[PMP_ENTRY-1:0]) ) );

endmodule
