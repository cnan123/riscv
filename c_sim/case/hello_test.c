//================================================================
//   Copyright (C) 2021 Sangfor Ltd. All rights reserved.
//
//   Filename     : hello_test.c
//   Auther       : cnan
//   Created On   : 2021.04.17
//   Description  : 
//
//
//================================================================
#include "simple_system.h"

void soft_irq(void){

    printinfo("enter software irq\n",1);
    soft_irq_clr();
}

void timer_irq(void){

    printinfo("enter timer irq\n",1);
    timer_irq_clr();
}

void extern_irq(void){

    printinfo("enter extern irq\n",1);
    extern_irq_clr();
}




int main( void ){
    //asm("nop");
    //asm("cos x3, x2, x1");

    printinfo("hello-word : %d\n",1);
    //csr_test();
    //

    //interupt_enable(EXTERN_IRQ, extern_irq, (void*)1 );
    //extern_irq_set();

    //interupt_enable(TIMER_IRQ, timer_irq, (void*)1 );
    //timer_irq_set();

    //interupt_enable(SOFT_IRQ , soft_irq, (void*)1 );
    //soft_irq_set();

    pass("pass\n");
}

