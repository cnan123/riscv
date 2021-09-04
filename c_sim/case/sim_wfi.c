//================================================================
//   Copyright (C) 2021. All rights reserved.
//
//   Filename     : sim_wfi.c
//   Auther       : cnan
//   Created On   : 2021.09.04
//   Description  : 
//
//
//================================================================
#include "simple_system.h"

void timer_irq(void){

    printinfo("enter timer irq\n",1);
    timer_irq_clr();
}


int main(void){

    interupt_enable(TIMER_IRQ, timer_irq, (void*)1 );
    timer_config(1000); 
    asm("wfi");

    pass("pass\n");

}


