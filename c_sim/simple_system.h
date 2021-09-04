//================================================================
//   Copyright (C) 2021 Sangfor Ltd. All rights reserved.
//
//   Filename     : simple_system.h
//   Auther       : cnan
//   Created On   : 2021.04.03
//   Description  : 
//
//
//================================================================
#ifndef _SIMPLE_SYSTEM_H
#define _SIMPLE_SYSTEM_H

#define CMD     0xfffffffc
#define ARG     0xfffffff8
#define UART    0xfffffff4
#define NULL 0

#define PASS 0
#define FAIL 2
#define IRQ  3
#define TIMER  4

#define EXTERN_IRQ_REQ  0
#define SOFT_IRQ_REQ    1
#define TIMER_IRQ_REQ   2
#define EXTERN_IRQ_RLS  3
#define SOFT_IRQ_RLS    4
#define TIMER_IRQ_RLS   5

#define REG_WR(addr, val) (*( (volatile uint32_t *)(addr) ) = val)
#define REG_RD(addr, val) ( val = *( (volatile uint32_t *)(addr) ) )

#define SOFT_IRQ    3
#define TIMER_IRQ   7
#define EXTERN_IRQ  11

//#define CSR_RD( csr, dst ) asm volatile("csrr %0, "#name" ": "=r"(dst) : )

typedef unsigned int uint32_t;

void interupt_enable( int interupt_num, void* handle, void* arg );
void trap_handle( uint32_t mcause, uint32_t mepc );
void exception_handle ( uint32_t mcause, uint32_t mepc );
void exception_enable( void *handle, void * arg );

void printinfo( const char *msg, int sig );
void print_dec( uint32_t n);
void print_hex(unsigned int hex);
void my_putchar ( char c );

void pass( const char *msg );
void fail( const char *msg );

void extern_irq_set(void);
void timer_irq_set(void);
void soft_irq_set(void);
void extern_irq_clr(void);
void timer_irq_clr(void);
void soft_irq_clr(void);
void timer_config( unsigned int count );
#endif

