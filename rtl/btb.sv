//================================================================
//   Copyright (C) 2021. All rights reserved.
//
//   Filename     : btb.sv
//   Auther       : cnan
//   Created On   : 2021.09.21
//   Description  : 
//
//
//================================================================

module btb(
    input           clk,
    input           reset_n,

    input           btb_rd,
    input   [31:1]  pc_r,
    output          btb_hit,
    output  [31:1]  target_pc_r,

    input           btb_wr,
    input           btb_invalid,
    input   [31:1]  pc_w,
    input   [31:0]  target_pc_w
);

// Local Variables:
// verilog-library-directories:("." "dir1" "dir2" ...)
// End:

//////////////////////////////////////////////
/*AUTOLOGIC*/
//////////////////////////////////////////////

parameter TAG_DEPTH         = 1024;
parameter TAG_ADDR_WIDTH    = $clog2(TAG_DEPTH);

parameter GROUP_WIDTH       = 1;
parameter INDEX_WIDTH       = 31-TAG_ADDR_WIDTH-GROUP_WIDTH;

parameter TAG_DATA_WIDTH    = GROUP_WIDTH+INDEX_WIDTH+1;

parameter DATA_ADDR_WIDTH   =  $clog2(TAG_DEPTH);
parameter DATA_DATA_WIDTH   =  31;

typedef struct packed {
    logic                   valid;
    logic [INDEX_WIDTH-1:0] tag;
    logic [GROUP_WIDTH-1:0] group;
    logic [31:1]            target;
} btb_tag_t;

//////////////////////////////////////////////
//main code
logic tag_en;
logic tag_wr;
logic [TAG_ADDR_WIDTH-1:0] tag_addr;
logic [TAG_DATA_WIDTH-1:0] tag_wdata;
logic [TAG_DATA_WIDTH-1:0] tag_rdata;

logic                       data_en;
logic                       data_wr;
logic [DATA_ADDR_WIDTH-1:0] data_addr;
logic [DATA_DATA_WIDTH-1:0] data_wdata;
logic [DATA_DATA_WIDTH-1:0] data_rdata;
logic [31:1] pc_r_hold;
logic        rd_pick;

btb_tag_t btb_tag;

//////////////////////////////////////////////
//rd btb
//////////////////////////////////////////////
always @(posedge clk or negedge reset_n)begin
    if( !reset_n )begin
        rd_pick         <= 1'b0; 
        pc_r_hold[31:1] <= {30{1'b0}};
    end else if(btb_rd)begin
        rd_pick         <= btb_rd; 
        pc_r_hold[31:1] <= pc_r[31:1];
    end
end

assign btb_tag.valid    = tag_rdata[TAG_DATA_WIDTH-1];
assign btb_tag.group    = tag_rdata[0+:GROUP_WIDTH];
assign btb_tag.tag      = tag_rdata[GROUP_WIDTH+:INDEX_WIDTH];
assign btb_tag.target   = data_rdata[30:0];

assign btb_hit = (
    btb_tag.valid & 
    rd_pick                         & 
    ( btb_tag.group == pc_r_hold[1+:GROUP_WIDTH] )  & 
    ( btb_tag.tag == pc_r_hold[(1+GROUP_WIDTH+TAG_ADDR_WIDTH)+:INDEX_WIDTH] )
);

assign target_pc_r = btb_tag.target;


//////////////////////////////////////////////
//tag memory
//////////////////////////////////////////////
assign tag_en                           = btb_rd | btb_wr;
assign tag_wr                           = btb_wr;
assign tag_addr[TAG_ADDR_WIDTH-1:0]     = btb_wr ? pc_w[(1+GROUP_WIDTH)+:TAG_ADDR_WIDTH] : pc_r[(1+GROUP_WIDTH)+:TAG_ADDR_WIDTH];
assign tag_wdata                        = {(~btb_invalid), pc_w[(1+GROUP_WIDTH+TAG_ADDR_WIDTH)+:INDEX_WIDTH], pc_w[1+:GROUP_WIDTH] };

assign data_en                          = btb_rd | btb_wr;
assign data_wr                          = btb_wr;
assign data_addr[DATA_ADDR_WIDTH-1:0]   = btb_wr ? pc_w[(1+GROUP_WIDTH)+:DATA_ADDR_WIDTH] : pc_r[(1+GROUP_WIDTH)+:DATA_ADDR_WIDTH];
assign data_wdata                       = target_pc_w[31:1];


mem_wrap #(
    .ADDR_WIDTH( TAG_ADDR_WIDTH),
    .DATA_WIDTH( TAG_DATA_WIDTH)
)btb_tag_mem(
    .clk        (clk        ),
    .reset_n    (reset_n    ),
    .en         (tag_en     ),
    .wr         (tag_wr     ),
    .addr       (tag_addr   ),
    .wdata      (tag_wdata  ),
    .rdata      (tag_rdata  )
);


mem_wrap #(
    .ADDR_WIDTH( DATA_ADDR_WIDTH),
    .DATA_WIDTH( DATA_DATA_WIDTH)
)btb_data_mem(
    .clk        (clk        ),
    .reset_n    (reset_n    ),
    .en         (data_en    ),
    .wr         (data_wr    ),
    .addr       (data_addr  ),
    .wdata      (data_wdata ),
    .rdata      (data_rdata )
);

endmodule
