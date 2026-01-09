OUTPUT_ARCH("riscv")
ENTRY(_start)

MEMORY {
    SRAM (rwx) : ORIGIN = 0x00001000, LENGTH = 16K
}

SECTIONS {
    . = 0x00001000;
    
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
        *(COMMON);
        . = ALIGN(4);
        _bss_end = .;
    } > SRAM
    
    _stack_top = 0x5000;
}
