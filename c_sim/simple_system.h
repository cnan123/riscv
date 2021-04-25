//================================================================
//   Copyright (C) 2021 Sangfor Ltd. All rights reserved.
//
//   Filename     : simple_system.h
//   Auther       : cnan
//   Created On   : 2021年04月03日
//   Description  : 
//
//
//================================================================
#ifndef _SIMPLE_SYSTEM_H
#define _SIMPLE_SYSTEM_H

#define UART 0x3c000000
#define NULL 0

#define REG_WR(addr, val) (*( (volatile uint32_t *)(addr) ) = val)
#define REG_RD(addr, val) ( val = *( (volatile uint32_t *)(addr) ) )

//#define CSR_RD( csr, dst ) asm volatile("csrr %0, "#name" ": "=r"(dst) : )

typedef unsigned int uint32_t;

void interupt_enable( int interupt_num, void* handle, void* arg );
void trap_handle( uint32_t mcause, uint32_t mepc );
void exception_handle ( uint32_t mcause, uint32_t mepc );

void printinfo( const char *msg, int sig );
void print_dec( uint32_t n);
void print_hex(unsigned int hex);
void my_putchar ( char c );

#endif

