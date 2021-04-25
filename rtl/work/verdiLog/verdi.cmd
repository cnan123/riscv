debImport "-sv" "-f" "../if.lst"
verdiWindowResize -win $_Verdi_1 "57" "17" "1853" "1025"
wvCreateWindow
wvSetPosition -win $_nWave2 {("G1" 0)}
wvOpenFile -win $_nWave2 \
           {/home/cnan/tree/eagle_tree/study/riscv/my_riscv/rtl/work/verilog.fsdb}
srcHBSelect "if_stage_bench.if_stage" -win $_nTrace1
srcSetScope -win $_nTrace1 "if_stage_bench.if_stage" -delim "."
srcHBSelect "if_stage_bench.if_stage.perfetch_fifo" -win $_nTrace1
srcSetScope -win $_nTrace1 "if_stage_bench.if_stage.perfetch_fifo" -delim "."
srcDeselectAll -win $_nTrace1
srcSelect -win $_nTrace1 -range {16 29 1 1 1 1}
srcAddSelectedToWave -win $_nTrace1
wvSelectSignal -win $_nWave2 {( "G1" 8 )} 
wvSetPosition -win $_nWave2 {("G1" 8)}
wvSetPosition -win $_nWave2 {("G1" 7)}
wvSetPosition -win $_nWave2 {("G1" 6)}
wvSetPosition -win $_nWave2 {("G1" 5)}
wvSetPosition -win $_nWave2 {("G1" 10)}
wvSetPosition -win $_nWave2 {("G1" 2)}
wvSetPosition -win $_nWave2 {("G1" 1)}
wvSetPosition -win $_nWave2 {("G1" 10)}
srcTraceConnectivity "if_stage_bench.if_stage.perfetch_fifo.rd_data\[31:0\]" -win \
           $_nTrace1
nsMsgSwitchTab -tab trace
srcHBSelect "if_stage_bench.if_stage" -win $_nTrace1
verdiDockWidgetSetCurTab -dock widgetDock_<Message>
nsMsgSelect -range {0 1 3-3}
nsMsgAction -tab trace -index {0 1 3}
nsMsgSelect -range {0 1 3-3}
nsMsgSelect -range {0 1 2-2}
nsMsgAction -tab trace -index {0 1 2}
nsMsgSelect -range {0 1 2-2}
srcHBSelect "if_stage_bench.if_stage.gen_no_branch_prediction" -win $_nTrace1
debReload
nsMsgSelect -range {0 0-0}
nsMsgAction -tab cmpl -index {0 0}
nsMsgSelect -range {0 0-0}
srcHBSelect "if_stage_bench.if_stage" -win $_nTrace1
debReload
srcHBSelect "if_stage_bench.if_stage.gen_no_branch_prediction" -win $_nTrace1
debReload
verdiDockWidgetSetCurTab -dock windowDock_nWave_2
wvSelectSignal -win $_nWave2 {( "G1" 2 )} 
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvReloadFile -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G1" 4 )} 
wvSetPosition -win $_nWave2 {("G1" 4)}
wvSetPosition -win $_nWave2 {("G1" 3)}
wvSetPosition -win $_nWave2 {("G1" 10)}
wvSetPosition -win $_nWave2 {("G1" 1)}
wvSetPosition -win $_nWave2 {("G1" 0)}
srcTraceConnectivity "if_stage_bench.if_stage.perfetch_fifo.wr_en" -win $_nTrace1
nsMsgSwitchTab -tab trace
srcHBSelect "if_stage_bench.if_stage.perfetch_fifo" -win $_nTrace1
wvSetPosition -win $_nWave2 {("G1" 10)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "push" -win $_nTrace1
srcAction -pos 55 2 1 -win $_nTrace1 -name "push" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcSelect -signal "wr_en" -win $_nTrace1
srcAction -pos 55 6 3 -win $_nTrace1 -name "wr_en" -ctrlKey off
wvSelectGroup -win $_nWave2 {G1}
wvSelectGroup -win $_nWave2 {G1}
wvSetPosition -win $_nWave2 {("G1" 0)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "instr_valid" -win $_nTrace1
wvSetPosition -win $_nWave2 {("G1" 10)}
wvSetPosition -win $_nWave2 {("G2" 0)}
wvAddSignal -win $_nWave2 "/if_stage_bench/if_stage/instr_valid"
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G2" 1)}
wvSetPosition -win $_nWave2 {("G2" 1)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "fetch_from_fifo" -win $_nTrace1
wvSetPosition -win $_nWave2 {("G1" 0)}
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G2" 1)}
wvSetPosition -win $_nWave2 {("G1" 10)}
wvSetPosition -win $_nWave2 {("G3" 0)}
wvSetPosition -win $_nWave2 {("G2" 1)}
wvAddSignal -win $_nWave2 "/if_stage_bench/if_stage/fetch_from_fifo"
wvSetPosition -win $_nWave2 {("G2" 1)}
wvSetPosition -win $_nWave2 {("G2" 2)}
wvZoom -win $_nWave2 45.540179 468.413265
srcDeselectAll -win $_nTrace1
srcSelect -win $_nTrace1 -range {32 38 1 1 4 1}
wvSetPosition -win $_nWave2 {("G1" 10)}
wvSetPosition -win $_nWave2 {("G1" 0)}
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G2" 1)}
wvSetPosition -win $_nWave2 {("G2" 2)}
wvSetPosition -win $_nWave2 {("G3" 0)}
wvAddSignal -win $_nWave2 "/if_stage_bench/if_stage/instr_req" \
           "/if_stage_bench/if_stage/instr_addr\[31:0\]" \
           "/if_stage_bench/if_stage/instr_gnt" \
           "/if_stage_bench/if_stage/instr_rdata\[31:0\]" \
           "/if_stage_bench/if_stage/instr_err" \
           "/if_stage_bench/if_stage/instr_valid"
wvSetPosition -win $_nWave2 {("G3" 0)}
wvSetPosition -win $_nWave2 {("G3" 6)}
wvSetPosition -win $_nWave2 {("G3" 6)}
wvSetCursor -win $_nWave2 104.332483 -snap {("G3" 2)}
wvZoom -win $_nWave2 84.914841 140.201182
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "instr_req" -win $_nTrace1
srcAction -pos 31 3 6 -win $_nTrace1 -name "instr_req" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcSelect -signal "is_boot" -win $_nTrace1
srcAddSelectedToWave -win $_nTrace1
wvZoomIn -win $_nWave2
wvZoomOut -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "fifo_clear" -win $_nTrace1
wvSelectSignal -win $_nWave2 {( "G2" 2 )} 
wvSetPosition -win $_nWave2 {("G2" 2)}
wvSetPosition -win $_nWave2 {("G2" 1)}
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G3" 7)}
srcTraceConnectivity "if_stage_bench.if_stage.fetch_from_fifo" -win $_nTrace1
srcHBSelect "if_stage_bench.if_stage" -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "fetch_from_fifo" -win $_nTrace1
srcAction -pos 188 12 8 -win $_nTrace1 -name "fetch_from_fifo" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcSelect -signal "fetch_en" -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "fifo_empty" -win $_nTrace1
srcAddSelectedToWave -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "fifo_empty" -win $_nTrace1
srcAction -pos 127 11 2 -win $_nTrace1 -name "fifo_empty" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcSelect -signal "reset_n" -win $_nTrace1
srcAddSelectedToWave -win $_nTrace1
wvZoom -win $_nWave2 91.955853 138.497926
wvZoomOut -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "clk" -win $_nTrace1
srcAddSelectedToWave -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "valid\[DEPTH-1:0\]" -win $_nTrace1
srcAddSelectedToWave -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "valid\[DEPTH-1:0\]" -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "valid\[DEPTH-1:0\]" -win $_nTrace1
srcAction -pos 110 8 3 -win $_nTrace1 -name "valid\[DEPTH-1:0\]" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcSelect -signal "poped_valid\[DEPTH-1:0\]" -win $_nTrace1
wvSetCursor -win $_nWave2 94.864733 -snap {("G3" 10)}
wvSetCursor -win $_nWave2 104.897399 -snap {("G3" 10)}
wvSelectSignal -win $_nWave2 {( "G3" 9 )} 
wvSelectSignal -win $_nWave2 {( "G3" 10 )} 
wvSelectSignal -win $_nWave2 {( "G3" 9 )} 
wvSetPosition -win $_nWave2 {("G3" 9)}
wvSetPosition -win $_nWave2 {("G3" 10)}
wvMoveSelected -win $_nWave2
wvSetPosition -win $_nWave2 {("G3" 10)}
wvSetCursor -win $_nWave2 94.805368 -snap {("G3" 9)}
wvSetCursor -win $_nWave2 104.956764 -snap {("G3" 10)}
wvSetCursor -win $_nWave2 105.312953 -snap {("G3" 9)}
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoom -win $_nWave2 104.600574 106.025332
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
srcAddSelectedToWave -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "poped_valid\[DEPTH-1:0\]" -win $_nTrace1
srcAction -pos 87 5 2 -win $_nTrace1 -name "poped_valid\[DEPTH-1:0\]" -ctrlKey \
          off
srcDeselectAll -win $_nTrace1
srcSelect -signal "push" -win $_nTrace1
srcAddSelectedToWave -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "push" -win $_nTrace1
srcAction -pos 65 7 2 -win $_nTrace1 -name "push" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcSelect -signal "wr_en" -win $_nTrace1
srcAction -pos 55 6 2 -win $_nTrace1 -name "wr_en" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcSelect -signal "instr_valid" -win $_nTrace1
srcAddSelectedToWave -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "fetch_from_fifo" -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "fetch_from_fifo" -win $_nTrace1
srcAction -pos 188 12 6 -win $_nTrace1 -name "fetch_from_fifo" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcSelect -signal "fifo_empty" -win $_nTrace1
srcAddSelectedToWave -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "fetch_from_fifo" -win $_nTrace1
srcAddSelectedToWave -win $_nTrace1
srcBackwardHistory -win $_nTrace1
srcHBSelect "if_stage_bench.if_stage" -win $_nTrace1
srcHBSelect "if_stage_bench.if_stage" -win $_nTrace1
srcHBSelect "if_stage_bench.if_stage.gen_no_branch_prediction" -win $_nTrace1
debReload
wvSelectSignal -win $_nWave2 {( "G3" 3 )} 
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvReloadFile -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvScrollDown -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 11
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -win $_nTrace1 -range {26 30 1 1 3 1}
srcAddSelectedToWave -win $_nTrace1
wvSelectSignal -win $_nWave2 {( "G3" 17 )} 
wvSelectSignal -win $_nWave2 {( "G3" 18 )} 
wvSelectSignal -win $_nWave2 {( "G3" 19 )} 
srcDeselectAll -win $_nTrace1
srcSelect -signal "instruction_value" -win $_nTrace1
srcAction -pos 28 5 8 -win $_nTrace1 -name "instruction_value" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcSelect -signal "pc_unalign" -win $_nTrace1
srcAddSelectedToWave -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "fetch_from_fifo" -win $_nTrace1
srcAddSelectedToWave -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "instr_valid" -win $_nTrace1
srcHBSelect "if_stage_bench" -win $_nTrace1
wvSelectSignal -win $_nWave2 {( "G3" 6 )} 
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvReloadFile -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G3" 19 )} 
wvSetCursor -win $_nWave2 114.938776 -snap {("G3" 19)}
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 11
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvSelectSignal -win $_nWave2 {( "G2" 2 )} 
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvReloadFile -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
srcHBSelect "if_stage_bench.if_stage" -win $_nTrace1
srcHBSelect "if_stage_bench" -win $_nTrace1
debReload
srcDeselectAll -win $_nTrace1
srcSelect -signal "pc_id_ready" -win $_nTrace1
srcAddSelectedToWave -win $_nTrace1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvSetPosition -win $_nWave2 {("G3" 23)}
wvSetPosition -win $_nWave2 {("G4" 0)}
wvMoveSelected -win $_nWave2
wvSetPosition -win $_nWave2 {("G4" 1)}
wvSetPosition -win $_nWave2 {("G4" 1)}
wvScrollDown -win $_nWave2 1
wvScrollUp -win $_nWave2 3
wvScrollUp -win $_nWave2 4
wvScrollUp -win $_nWave2 3
wvSelectGroup -win $_nWave2 {G3}
srcDeselectAll -win $_nTrace1
srcSelect -signal "fetch_en" -win $_nTrace1
srcAddSelectedToWave -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "fifo_pop" -win $_nTrace1
srcAddSelectedToWave -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "fifo_empty" -win $_nTrace1
srcAddSelectedToWave -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "fetch_from_fifo" -win $_nTrace1
srcAddSelectedToWave -win $_nTrace1
srcHBSelect "if_stage_bench.if_stage.gen_no_branch_prediction" -win $_nTrace1
debReload
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomAll -win $_nWave2
wvSelectGroup -win $_nWave2 {G2}
wvSelectGroup -win $_nWave2 {G4}
wvSetPosition -win $_nWave2 {("G4" 0)}
srcHBSelect "if_stage_bench.if_stage" -win $_nTrace1
srcSetScope -win $_nTrace1 "if_stage_bench.if_stage" -delim "."
srcDeselectAll -win $_nTrace1
srcSelect -win $_nTrace1 -range {32 38 1 1 3 1}
wvSetPosition -win $_nWave2 {("G3" 22)}
wvSetPosition -win $_nWave2 {("G5" 0)}
wvAddSignal -win $_nWave2 "/if_stage_bench/if_stage/instr_req" \
           "/if_stage_bench/if_stage/instr_addr\[31:0\]" \
           "/if_stage_bench/if_stage/instr_gnt" \
           "/if_stage_bench/if_stage/instr_rdata\[31:0\]" \
           "/if_stage_bench/if_stage/instr_err" \
           "/if_stage_bench/if_stage/instr_valid"
wvSetPosition -win $_nWave2 {("G5" 0)}
wvSetPosition -win $_nWave2 {("G5" 6)}
wvSetPosition -win $_nWave2 {("G5" 6)}
wvZoom -win $_nWave2 19.524656 299.378063
wvZoom -win $_nWave2 110.833544 133.429253
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "pc_id_ready" -win $_nTrace1
srcAddSelectedToWave -win $_nTrace1
wvZoom -win $_nWave2 0.000000 337.557909
srcHBSelect "if_stage_bench.if_stage.perfetch_fifo" -win $_nTrace1
srcHBSelect "if_stage_bench.if_stage.perfetch_fifo" -win $_nTrace1
srcSetScope -win $_nTrace1 "if_stage_bench.if_stage.perfetch_fifo" -delim "."
srcDeselectAll -win $_nTrace1
srcSelect -signal "wr_en" -win $_nTrace1
srcAddSelectedToWave -win $_nTrace1
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "wr_en" -win $_nTrace1
srcAction -pos 20 3 2 -win $_nTrace1 -name "wr_en" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcSelect -signal "fetch_from_fifo" -win $_nTrace1
srcAddSelectedToWave -win $_nTrace1
srcHBSelect "if_stage_bench.if_stage.gen_no_branch_prediction" -win $_nTrace1
debReload
wvZoom -win $_nWave2 157.273837 453.949484
wvZoom -win $_nWave2 245.628596 281.166844
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvSelectGroup -win $_nWave2 {G1}
wvSelectGroup -win $_nWave2 {G1} {G2} {G3} {G4} {G5} {G6}
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 0)}
srcDeselectAll -win $_nTrace1
srcSelect -win $_nTrace1 -range {32 38 1 1 1 1} -backward
srcAddSelectedToWave -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -win $_nTrace1 -range {26 30 3 1 19 1}
srcAddSelectedToWave -win $_nTrace1
wvZoomOut -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomIn -win $_nWave2
wvSetCursor -win $_nWave2 311.871054 -snap {("G1" 2)}
wvZoom -win $_nWave2 303.968439 312.435527
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 88.778293 342.236929
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "fifo_full" -win $_nTrace1
srcAddSelectedToWave -win $_nTrace1
wvSelectSignal -win $_nWave2 {( "G1" 4 )} 
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvReloadFile -win $_nWave2
wvZoom -win $_nWave2 221.419855 261.342525
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomIn -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "clk" -win $_nTrace1
srcAddSelectedToWave -win $_nTrace1
wvSetPosition -win $_nWave2 {("G1" 11)}
wvSetPosition -win $_nWave2 {("G1" 10)}
wvSetPosition -win $_nWave2 {("G1" 9)}
wvSetPosition -win $_nWave2 {("G1" 8)}
wvSetPosition -win $_nWave2 {("G1" 7)}
wvSetPosition -win $_nWave2 {("G1" 6)}
wvSetPosition -win $_nWave2 {("G1" 5)}
wvSetPosition -win $_nWave2 {("G1" 4)}
wvSetPosition -win $_nWave2 {("G1" 3)}
wvSetPosition -win $_nWave2 {("G1" 2)}
wvSetPosition -win $_nWave2 {("G1" 1)}
wvSetPosition -win $_nWave2 {("G1" 0)}
wvMoveSelected -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 0)}
wvSetPosition -win $_nWave2 {("G1" 1)}
wvSelectSignal -win $_nWave2 {( "G1" 1 )} 
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvReloadFile -win $_nWave2
wvZoom -win $_nWave2 182.518736 216.760815
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
srcHBSelect "if_stage_bench.if_stage.perfetch_fifo" -win $_nTrace1
srcHBSelect "if_stage_bench.if_stage.perfetch_fifo" -win $_nTrace1
srcSetScope -win $_nTrace1 "if_stage_bench.if_stage.perfetch_fifo" -delim "."
srcDeselectAll -win $_nTrace1
srcSelect -signal "wr_en" -win $_nTrace1
srcAddSelectedToWave -win $_nTrace1
wvZoom -win $_nWave2 187.821542 271.942387
debExit
