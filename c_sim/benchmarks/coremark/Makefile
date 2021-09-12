# Copyright lowRISC contributors.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Build coremark benchmark for Ibex Simple System

CURDIR = /home/cnan/tree/eagle_tree/study/riscv/riscv/c_sim/benchmarks/coremark
COREMARK_DIR = $(CURDIR)/coremark

export PORT_DIR  = $(CURDIR)
export ITERATIONS = 1
export OPATH = $(CURDIR)/

# Export OPATH above doesn't seem to work so need to explicitly give it on the
# make command line
all:
	$(MAKE) -C $(COREMARK_DIR)

clean:
	$(MAKE) -C $(COREMARK_DIR) clean
