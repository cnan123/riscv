//================================================================
//   Copyright (C) 2021. All rights reserved.
//
//   Filename     : ecall.c
//   Auther       : cnan
//   Created On   : 2021.09.04
//   Description  : 
//
//
//================================================================
#include "simple_system.h"


void ecall_irq(void){
    printinfo("enter ecall irq\n",1);

    unsigned int mepc;
    asm volatile("csrr %0, mepc": "=r"(mepc) : );
    asm volatile("csrrw x0, mepc, %0" : : "r"(mepc+4) );
    
}

int main(void){
    
    exception_enable(ecall_irq, (void*)1 );
    asm("ecall");

    pass("pass\n");

}

