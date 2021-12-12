

#================================================================
#   Copyright (C) 2021 Sangfor Ltd. All rights reserved.
#   
#   Filename   ：Makefile
#   Auther     ：cnan
#   Creat_Data ：2021.04.03
#
#================================================================

CC		:= /home/tool/riscv-gcc/bin/riscv64-unknown-elf-gcc
AS		:= /home/tool/riscv-gcc/bin/riscv64-unknown-elf-as
GXX		:= /home/tool/riscv-gcc/bin/riscv64-unknown-elf-g++
OBJDUMP	:= /home/tool/riscv-gcc/bin/riscv64-unknown-elf-objdump
GDB		:= /home/tool/riscv-gcc/bin/riscv64-unknown-elf-gdb
AR		:= /home/tool/riscv-gcc/bin/riscv64-unknown-elf-ar
OBJCOPY	:= /home/tool/riscv-gcc/bin/riscv64-unknown-elf-objcopy
READELF	:= /home/tool/riscv-gcc/bin/riscv64-unknown-elf-readelf

RISCV_ARCH		:= rv32imc
RISCV_ABI		:= ilp32
RISCV_MCMODEL	:= medlow

PROGRAM := hello_test
PROGRAM_DIR := case

COMMON_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
C_SRCS += $(PROGRAM_DIR)/$(PROGRAM).c
C_SRCS += $(wildcard $(COMMON_DIR)/*.c)

ASM_SRCS = $(filter %.S, $(C_SRCS))

CRT = $(COMMON_DIR)/crt0.S


ifdef PROGRAM
OUTFILES := $(PROGRAM).elf $(PROGRAM).bin $(PROGRAM).dis $(PROGRAM).dump $(PROGRAM).hex $(PROGRAM).v
else
OUTFILES := $(OBJS)
endif

OBJS := $(C_SRCS:.c=.o) $(ASM_SRCS:.S=.o) $(CRT:.S=.o)
TEMP_FILE := $(C_SRCS:.c=.d) $(ASM_SRCS:.S=.d) $(CRT:.S=.d)

INCLUDES += -I$(COMMON_DIR)

LINK_SCRIPT := $(COMMON_DIR)/link.ld
LD_CFLAGS += -T $(LINK_SCRIPT) -nostartfiles

CFLAGS += -march=$(RISCV_ARCH)
CFLAGS += -mabi=$(RISCV_ABI)
CFLAGS += -mcmodel=$(RISCV_MCMODEL) 
CFLAGS += -ffunction-sections -fdata-sections -fno-builtin-printf -fno-builtin-malloc -Wall -g -ffreestanding -O2 $(USER_CFLAGS)

.PHONY : all clean
all: $(OUTFILES)

$(PROGRAM).elf : $(OBJS) $(LINK_SCRIPT)
	$(CC) $(CFLAGS) $(INCLUDES) $(OBJS) -o $@ $(LD_CFLAGS)

%.v	: %.elf
	$(OBJCOPY) -O verilog $^ $@

%.hex : %.elf
	$(OBJCOPY) -O ihex $^ $@

%.dis : %.elf
	$(OBJCOPY) -O binary $^ $@

%.bin : %.elf
	$(OBJCOPY) -O binary $^ $@

%.dump : %.elf
	$(OBJDUMP) -S  $^ > $@

%.o : %.c
	$(CC) $(CFLAGS) -MMD $(INCLUDES) -c -o $@ $<

%.o : %.S
	$(CC) $(CFLAGS) -MMD $(INCLUDES) -c -o $@ $<

clean :
	$(RM) -f $(OUTFILES) $(OBJS) $(TEMP_FILE) 

