//================================================================
//   Copyright (C) 2021. All rights reserved.
//
//   Filename     : pmp_test.c
//   Auther       : cnan
//   Created On   : 2021.12.12
//   Description  : 
//
//
//================================================================
#include "simple_system.h"

#define OFF     0
#define TOR     1
#define NA4     2
#define NAPOT   3

void ecall_irq(void){
    printinfo("enter ecall irq\n",1);

    unsigned int mepc;
    asm volatile("csrr %0, mepc": "=r"(mepc) : );
    asm volatile("csrrw x0, mepc, %0" : : "r"(mepc+4) );

    asm volatile("csrrc x0, mstatus, %0" : : "r"(0x3) );
    
}

void pmp_tor_cfg(void){

    unsigned int pmpcfg0 ;
    unsigned int pmpcfg1 ;
    unsigned int pmpcfg2 ;
    unsigned int pmpcfg3 ;
    unsigned int pmpcfg4 ;
    unsigned int pmpcfg5 ;
    unsigned int pmpcfg6 ;
    unsigned int pmpcfg7 ;
    unsigned int pmpcfg8 ;
    unsigned int pmpcfg9 ;
    unsigned int pmpcfg10;
    unsigned int pmpcfg11;
    unsigned int pmpcfg12;
    unsigned int pmpcfg13;
    unsigned int pmpcfg14;
    unsigned int pmpcfg15;
    unsigned int pmpaddr0 ;
    unsigned int pmpaddr1 ;
    unsigned int pmpaddr2 ;
    unsigned int pmpaddr3 ;
    unsigned int pmpaddr4 ;
    unsigned int pmpaddr5 ;
    unsigned int pmpaddr6 ;
    unsigned int pmpaddr7 ;
    unsigned int pmpaddr8 ;
    unsigned int pmpaddr9 ;
    unsigned int pmpaddr10;
    unsigned int pmpaddr11;
    unsigned int pmpaddr12;
    unsigned int pmpaddr13;
    unsigned int pmpaddr14;
    unsigned int pmpaddr15;

    pmpcfg0  = (0<<7) | (TOR<<3) | 0x7;
    pmpcfg1  = (0<<7) | (OFF<<3) | 0x0;
    pmpcfg2  = (0<<7) | (OFF<<3) | 0x0;
    pmpcfg3  = (0<<7) | (OFF<<3) | 0x0;
    pmpcfg4  = (0<<7) | (OFF<<3) | 0x0;
    pmpcfg5  = (0<<7) | (OFF<<3) | 0x0;
    pmpcfg6  = (0<<7) | (OFF<<3) | 0x0;
    pmpcfg7  = (0<<7) | (OFF<<3) | 0x0;
    pmpcfg8  = (0<<7) | (OFF<<3) | 0x0;
    pmpcfg9  = (0<<7) | (OFF<<3) | 0x0;
    pmpcfg10 = (0<<7) | (OFF<<3) | 0x0;
    pmpcfg11 = (0<<7) | (OFF<<3) | 0x0;
    pmpcfg12 = (0<<7) | (OFF<<3) | 0x0;
    pmpcfg13 = (0<<7) | (OFF<<3) | 0x0;
    pmpcfg14 = (0<<7) | (OFF<<3) | 0x0;
    pmpcfg15 = (0<<7) | (OFF<<3) | 0x0;

    pmpaddr0  = 0xFFFFFFFC;
    pmpaddr1  = 0x0;
    pmpaddr2  = 0x0;
    pmpaddr3  = 0x0;
    pmpaddr4  = 0x0;
    pmpaddr5  = 0x0;
    pmpaddr6  = 0x0;
    pmpaddr7  = 0x0;
    pmpaddr8  = 0x0;
    pmpaddr9  = 0x0;
    pmpaddr10 = 0x0;
    pmpaddr11 = 0x0;
    pmpaddr12 = 0x0;
    pmpaddr13 = 0x0;
    pmpaddr14 = 0x0;
    pmpaddr15 = 0x0;

    asm volatile("csrrs x0, pmpcfg0, %0"::"r"(pmpcfg3<<24 | pmpcfg2<<16 | pmpcfg1<<8 | pmpcfg0) );
    asm volatile("csrrs x0, pmpcfg1, %0"::"r"(pmpcfg7<<24 | pmpcfg6<<16 | pmpcfg5<<8 | pmpcfg4) );
    asm volatile("csrrs x0, pmpcfg2, %0"::"r"(pmpcfg11<<24 | pmpcfg10<<16 | pmpcfg9<<8 | pmpcfg8) );
    asm volatile("csrrs x0, pmpcfg3, %0"::"r"(pmpcfg15<<24 | pmpcfg14<<16 | pmpcfg13<<8 | pmpcfg12) );

    asm volatile("csrrs x0, pmpaddr0 , %0"::"r"(pmpaddr0  >> 2) );
    asm volatile("csrrs x0, pmpaddr1 , %0"::"r"(pmpaddr1  >> 2) );
    asm volatile("csrrs x0, pmpaddr2 , %0"::"r"(pmpaddr2  >> 2) );
    asm volatile("csrrs x0, pmpaddr3 , %0"::"r"(pmpaddr3  >> 2) );
    asm volatile("csrrs x0, pmpaddr4 , %0"::"r"(pmpaddr4  >> 2) );
    asm volatile("csrrs x0, pmpaddr5 , %0"::"r"(pmpaddr5  >> 2) );
    asm volatile("csrrs x0, pmpaddr6 , %0"::"r"(pmpaddr6  >> 2) );
    asm volatile("csrrs x0, pmpaddr7 , %0"::"r"(pmpaddr7  >> 2) );
    asm volatile("csrrs x0, pmpaddr8 , %0"::"r"(pmpaddr8  >> 2) );
    asm volatile("csrrs x0, pmpaddr9 , %0"::"r"(pmpaddr9  >> 2) );
    asm volatile("csrrs x0, pmpaddr10, %0"::"r"(pmpaddr10 >> 2) );
    asm volatile("csrrs x0, pmpaddr11, %0"::"r"(pmpaddr11 >> 2) );
    asm volatile("csrrs x0, pmpaddr12, %0"::"r"(pmpaddr12 >> 2) );
    asm volatile("csrrs x0, pmpaddr13, %0"::"r"(pmpaddr13 >> 2) );
    asm volatile("csrrs x0, pmpaddr14, %0"::"r"(pmpaddr14 >> 2) );
    asm volatile("csrrs x0, pmpaddr15, %0"::"r"(pmpaddr15 >> 2) );
}


int main(void){
    
    pmp_tor_cfg();

    exception_enable(ecall_irq, (void*)1 );
    asm("ecall");

    pass("pass\n");

}


