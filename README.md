# RISC-V
## Overview
The puspose of this project is to implement a basic 5-stage pipeline of riscv cpu.

## Targets
+ support IMC isa
+ support interrupt
+ support exception
+ support machine user mode
+ support misalign access
+ support debug mode
+ support hardware breakpoint

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
	+script
	+ sim(run case)
	
* Started
```
$ source setenv
$ cd sim
$ ./run_sim.pl -module case -case hello_test -fl core.lst
$ verdi -sv -f corelist -ssf verilog.fsdb
```

## First Stage

+ support interrupt
+ 2021.7.23 Refactor the CPU Pipeline
+ base cpu, support IM isa



