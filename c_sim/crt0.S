
.section .text.entry
.global _start
_start:
    .org 0x00
    mv x1, x0
    mv x2, x1
    mv x3, x1
    mv x4, x1
    mv x5, x1
    mv x6, x1
    mv x7, x1
    mv x8, x1
    mv x9, x1
    mv x10, x1
    mv x11, x1
    mv x12, x1
    mv x13, x1
    mv x14, x1
    mv x15, x1
    mv x16, x1
    mv x17, x1
    mv x18, x1
    mv x19, x1
    mv x20, x1
    mv x21, x1
    mv x22, x1
    mv x23, x1
    mv x24, x1
    mv x25, x1
    mv x26, x1
    mv x27, x1
    mv x28, x1
    mv x29, x1
    mv x30, x1
    mv x31, x1
    
    la x2, _stack_start

    la x26, _bss_start
    la x27, _bss_end
    bge x26, x27, zero_loop_end

zero_loop:
    sw x0, 0(x26)
    addi x26, x26, 4
    ble x26, x27, zero_loop
zero_loop_end:

    addi x10, x0, 0
    addi x11, x0, 0
    //call _init
    call main

loop:
    j loop


.section .vectors, "ax"
.option norvc
.org 0x00
.rept 32
    jal x0, default_common_vector 
.endr

default_common_vector:
    addi sp, sp, -32*4
    sw x1, 1*4(sp)
    sw x2, 2*4(sp)
    sw x3, 3*4(sp)
    sw x4, 4*4(sp)
    sw x5, 5*4(sp)
    sw x6, 6*4(sp)
    sw x7, 7*4(sp)
    sw x8, 8*4(sp)
    sw x9, 9*4(sp)
    sw x10, 10*4(sp)
    sw x11, 11*4(sp)
    sw x12, 12*4(sp)
    sw x13, 13*4(sp)
    sw x14, 14*4(sp)
    sw x15, 15*4(sp)
    sw x16, 16*4(sp)
    sw x17, 17*4(sp)
    sw x18, 18*4(sp)
    sw x19, 19*4(sp)
    sw x20, 20*4(sp)
    sw x21, 21*4(sp)
    sw x22, 22*4(sp)
    sw x23, 23*4(sp)
    sw x24, 24*4(sp)
    sw x25, 25*4(sp)
    sw x26, 26*4(sp)
    sw x27, 27*4(sp)
    sw x28, 28*4(sp)
    sw x29, 29*4(sp)
    sw x30, 30*4(sp)
    sw x31, 31*4(sp)

    csrr a0, mcause
    csrr a1, mepc
    srli a2, a0, 31
    beq a2, x0, default_exception_handle
    call trap_handle
    j return

default_exception_handle:
    call exception_handle

return:
    lw x1, 1*4(sp)
    lw x2, 2*4(sp)
    lw x3, 3*4(sp)
    lw x4, 4*4(sp)
    lw x5, 5*4(sp)
    lw x6, 6*4(sp)
    lw x7, 7*4(sp)
    lw x8, 8*4(sp)
    lw x9, 9*4(sp)
    lw x10, 10*4(sp)
    lw x11, 11*4(sp)
    lw x12, 12*4(sp)
    lw x13, 13*4(sp)
    lw x14, 14*4(sp)
    lw x15, 15*4(sp)
    lw x16, 16*4(sp)
    lw x17, 17*4(sp)
    lw x18, 18*4(sp)
    lw x19, 19*4(sp)
    lw x20, 20*4(sp)
    lw x21, 21*4(sp)
    lw x22, 22*4(sp)
    lw x23, 23*4(sp)
    lw x24, 24*4(sp)
    lw x25, 25*4(sp)
    lw x26, 26*4(sp)
    lw x27, 27*4(sp)
    lw x28, 28*4(sp)
    lw x29, 29*4(sp)
    lw x30, 30*4(sp)
    lw x31, 31*4(sp)

    addi sp, sp, 32*4
    mret
