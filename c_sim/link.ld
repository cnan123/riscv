
OUTPUT_ARCH(riscv)

MEMORY
{
    rom             : ORIGIN = 0x00000000, LENGTH = 0x1000 
    vector         : ORIGIN = 0x00001000, LENGTH = 0x400 /*1KB*/
    sram            : ORIGIN = 0x00010000, LENGTH = 0x10000
}

_min_stack      = 0x2000;
_stack_len      = LENGTH(sram);
_stack_start    = ORIGIN(sram) + LENGTH(sram);

ENTRY(_start)

SECTIONS
{
    .vectors :
    {
        . = ALIGN(4);
        _vectors_start = .;
        KEEP(*(.vectors))
        _vectors_end = .;
    } > vector

    .text :
    {
        . = ALIGN(4);
        *(.text.entry)
        *(.text)
        *(.text.*)
    } > rom

    .rodata : 
    {
        . = ALIGN(4);
        *(.srodata)
        *(.srodata.*)
        *(.rodata)
        *(.rodata.*)
    } > sram

    .data :
    {
        . = ALIGN(4);
        *(.sdata)
        *(.sdata.*)
        *(.data);
        *(.data.*)
    } > sram

    .bss :
    {
        . = ALIGN(4);
        _bss_start = .;
        *(.sbss)
        *(.sbss.*)
        *(.bss)
        *(.bss.*)
        *(COMMON)
        _bss_end = .;
    } > sram

}
