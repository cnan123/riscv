# RISC-V
## Overview
The puspose of this project is to implement a basic 5-stage pipeline of riscv cpu.

## Targets
+ IMC ISA
+ interrupt
+ exception
+ machine user mode
+ misalign access
+ debug mode
+ hardware breakpoint

## Supports
+ IMC extend ISA
+ interrupt(software, timer, external)
+ exception(ecall, ebreak, illegal_instr, illegal_instr_acs, illegal_csr, load_fault, store_fault)
+ wfi
+ misalign access


## Performance

| Performance | CoreMark |
| - | - |
| jump taken EX | 2.84 |
| jump taken ID | 2.87 |


+ BTB

| Entry | Way | Coremark |
| - | - | - |
| 2048 | 4 | 3.02 |
| 2048 | 1 | 3.03 |
| 512 |  1 | 3.03 |

## Tool Requirements

* vcs
* verdi

> now only support vcs/verdi for simualtion

## Get Started

* contents
	+ c_sim( simulation with c case)
	+ doc( document )
	+ riscv_riscv-tests(riscv isa test case)
	+ rtl( rtl )
	+ script
	+ sim(run case)
	
* Started
```
$ source setenv
$ cd sim
$ cd work
$ run_sim.pl -module case -case hello_test
$ verdi -sv -f sim.lst -ssf verilog.fsdb
```
* Run Coremark
```
$ source setenv
$ cd sim
$ cd work
$ run_sim.pl -coremark
```


## Version Log

+ run coremark test
+ support compress instr
+ support divider
+ support multiple
+ support wfi
+ support interrupt
+ 2021.7.23 Refactor the CPU Pipeline
+ base cpu, support IM isa




***
