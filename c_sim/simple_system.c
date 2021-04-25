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

#include "simple_system.h"
typedef void (*interrupt_handle_t)( void * arg );

void *interrupt_handle[32][2];

void interupt_enable( int interupt_num, void *handle, void * arg )
{
    interrupt_handle[interupt_num][0] = handle;
    interrupt_handle[interupt_num][1] = arg;
}

void trap_handle( uint32_t mcause, uint32_t mepc )
{
    unsigned int num;
    num = mcause & ( 1<<31 );

    if( interrupt_handle[num] != NULL){
        ( (interrupt_handle_t)(interrupt_handle[num][0]) )( interrupt_handle[num][1] );
    }else{
        printinfo("interrupt handle not registerd\n",1);
    }
}

void exception_handle ( uint32_t mcause, uint32_t mepc )
{
    printinfo("enter exception handle!!!\n",1);
    printinfo("mcause is %h\n",1);
    while(1){;}
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

void print_hex(unsigned int hex)
{
    int i = 8;
    my_putchar('0'); 
    my_putchar('x'); 
    while (i--){
        unsigned char c = ( hex & 0xF0000000 ) >> 28;
        my_putchar( c < 0xa ? c+'0' : c-0xa+'a' );
        hex <<= 4;
    }
}

void my_putchar ( char c )
{
    REG_WR( UART, c );
}

