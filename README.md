#RISC-V
##Overview
The puspose of this project is to implement a basic 3-stage pipeline of riscv cpu.

##Features
+ support IMC isa
+ support interrupt
+ support exception
+ support machine user mode
+ support misalign access
+ support debug mode
+ support hardware breakpoint

##Functions

###Architecture
![Architecture](/home/cnan/Documents/core_pipeline.bmp  "it")

| name | port| decription |
| :----| :----| :----|
| clk | input | cpu clock |
| reset_n | input | reset signal |
| intr_req | output | intruction req signal |
| intr_addr | output | address signal |
| intr_data | output | read data |
| intr_data_busy | input | last req not complete  |
| data_req | input | data req signal |
| data_addr | output | address signal |
| data_wdata | output | write data |
| data_rdata |  input | read data |
| data_byteen | output | byte enable |
| data _busy | input | busy signal |
| boot_addr | input | reset PC value |

###Instruction fetch

1. Port signal

| name | port| decription |
| :----| :----| :----|
| clk | input | cpu clock |
| reset_n | input | reset signal |


2. Function decription

