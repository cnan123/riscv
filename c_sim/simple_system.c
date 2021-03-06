//================================================================
//   Copyright (C) 2021 Sangfor Ltd. All rights reserved.
//
//   Filename     : simple_system.c
//   Auther       : cnan
//   Created On   : 2021年04月03日
//   Description  : 
//
//
//================================================================
#include "simple_system.h"

typedef void (*interrupt_handle_t)( void * arg );
typedef void (*exception_handle_t)( void * arg );

void *interrupt_handle[32][2];
void *exc_handle[2];

void interupt_enable( int interupt_num, void *handle, void * arg )
{
    interrupt_handle[interupt_num][0] = handle;
    interrupt_handle[interupt_num][1] = arg;

    asm volatile("csrrs x0, mstatus, %0" : : "r"( 1<<3) ); //MIE
    //asm volatile("csrrs x0, mstatus, %0" : : "r"( 0x3<<11) ); //MPP
    //
    asm volatile("csrrs x0, mie, %0" : : "r"( 1<<interupt_num) ); //MIE

}

void trap_handle( uint32_t mcause, uint32_t mepc )
{
    unsigned int num;
    num = mcause &  ( ~( 1<<31 ) );
    //printinfo("enter intr handle!!!\n",1);
    //printinfo("mcause is %d\n",num);

    if( interrupt_handle[num] != 0){
        ( (interrupt_handle_t)(interrupt_handle[num][0]) )( interrupt_handle[num][1] );
    }else{
        printinfo("interrupt handle not registerd\n",1);
    }
    
    return;
}


void exception_enable( void *handle, void * arg )
{
    exc_handle[0] = handle;
    exc_handle[1] = arg;
}


void exception_handle ( uint32_t mcause, uint32_t mepc )
{
    printinfo("enter exception handle!!!\n",1);
    printinfo("mcause is %h\n",mcause);
    //printinfo("mcause is %h\n",1);

    if( exc_handle != 0){
        ( (exception_handle_t)(exc_handle[0]) )( exc_handle[1] );
    }else{
        //while(1){;}
        fail("Fail Hart Exception\n");
    }

}

void printinfo( const char *msg, int sig )
{
    while( *msg ){
        if( *msg == '%' ){
            msg++;
            switch( *msg ){
                case 'd' :{ print_dec( sig );break; }
                case 'h' :{ print_hex( sig );break; }
                default:{ print_hex( sig );break; }
            }
            msg++;
        }else{
            my_putchar( *msg++ );
        }
    }
}

void print_dec( uint32_t n)
{
    if(n >= 10){
        print_dec( n/10 );
        n %= 10;
    }

    my_putchar( (char)( n + '0') );
}

void print_hex(const unsigned int hex)
{
    int i = 8;
    unsigned char c;
    unsigned int temp;
    temp = hex;

    my_putchar('0'); 
    my_putchar('x'); 
    while (i--){
        c = ( temp & 0xF0000000 ) >> 28;
        my_putchar( c < 0xa ? c+'0' : c-0xa+'a' );
        temp = temp<<4;
    }
}

void my_putchar ( const char c )
{
    //*( (volatile char *)(UART) ) = c;
    asm volatile("sb %0, 0(%1)" :: "r"(c), "r"(UART) );

}


void pass( const char *msg )
{
    printinfo(msg, 0);
    REG_WR(CMD, PASS);
}

void fail( const char *msg )
{
    printinfo(msg, 0);
    REG_WR(CMD, FAIL);
}

void extern_irq_set(void)
{
    REG_WR(CMD, IRQ);
    REG_WR(ARG, EXTERN_IRQ_REQ);
    asm("nop");
}

void extern_irq_clr(void)
{
    REG_WR(CMD, IRQ);
    REG_WR(ARG, EXTERN_IRQ_RLS);
    asm("nop");
}

void timer_irq_set(void)
{
    REG_WR(CMD, IRQ);
    REG_WR(ARG, TIMER_IRQ_REQ);
    asm("nop");
}

void timer_irq_clr(void)
{
    REG_WR(CMD, IRQ);
    REG_WR(ARG, TIMER_IRQ_RLS);
    asm("nop");
}

void soft_irq_set(void)
{
    REG_WR(CMD, IRQ);
    REG_WR(ARG, SOFT_IRQ_REQ);
    asm("nop");
}

void soft_irq_clr(void)
{
    REG_WR(CMD, IRQ);
    REG_WR(ARG, SOFT_IRQ_RLS);
    asm("nop");
}


void timer_config( unsigned int count ){
    REG_WR(CMD, TIMER);
    REG_WR(ARG, count);
}


int putchar(int c) {
  REG_WR( UART, (unsigned char)c);

  return c;
}

///////////////////////////////////////////////////////////
void pcount_reset() {
  asm volatile( "csrw mcycle,         x0\n");
}

void pcount_enable(int enable) {
  // Note cycle is disabled with everything else
  //unsigned int inhibit_val = enable ? 0x0 : 0xFFFFFFFF;
  // CSR 0x320 was called `mucounteren` in the privileged spec v1.9.1, it was
  // then dropped in v1.10, and then re-added in v1.11 with the name
  // `mcountinhibit`. Unfortunately, the version of binutils we use only allows
  // the old name, and LLVM only supports the new name (though this is changed
  // on trunk to support both), so we use the numeric value here for maximum
  // compatibility.
  asm volatile("csrw  0x320, %0\n" : : "r"(enable));
}

