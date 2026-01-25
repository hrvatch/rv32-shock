OUTPUT_ARCH("riscv")
ENTRY(_start)

MEMORY {
    SRAM (rwx) : ORIGIN = 0x00004000, LENGTH = 16K
}

SECTIONS {
    
    .text : {
        *(.text.start)
        *(.text*)
        *(.rodata*)
    } > SRAM
    
    .data : {
        . = ALIGN(4);
        *(.data*)
        *(.sdata*)
    } > SRAM
    
    .bss : {
        . = ALIGN(4);
        _bss_start = .;
        *(.bss*)
        *(.sbss*)
        *(COMMON)
        . = ALIGN(4);
        _bss_end = .;
    } > SRAM
    
    . = ALIGN(4);
    _end = .;
    
    /* Stack grows down from top of SRAM */
    _stack_top = ORIGIN(SRAM) + LENGTH(SRAM);
}
