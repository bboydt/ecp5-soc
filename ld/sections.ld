OUTPUT_FORMAT("elf32-littleriscv")
OUTPUT_ARCH(riscv)
ENTRY(_start)

SECTIONS
{
    .text : ALIGN(4)
    {
        KEEP(*(.text._start));
        *(.text);
        . = ALIGN(4);
    } > ROM

    .rodata : ALIGN(4)
    {
        *(.rodata);
        . = ALIGN(4);
    } > ROM

    .data : ALIGN(4)
    {
        __data_start = .;
        PROVIDE(__global_pointer$ = .);
        *(.data);
        . = ALIGN(4);
        __data_end = .;
    } > SRAM AT > ROM

    .bss : ALIGN(4)
    {
        __bss_start = .;
        *(.bss);
        . = ALIGN(4);
        __bss_end = .;
    } > SRAM
}

__stack_begin = ORIGIN(SRAM) + LENGTH(SRAM) - 4;
__data_load_start = LOADADDR(.data);
