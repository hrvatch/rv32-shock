OUTPUT_ARCH("riscv")
ENTRY(_bootloader_start)

MEMORY
{
    BOOTLOADER (rx) : ORIGIN = 0x8000, LENGTH = 4K
}

SECTIONS
{
    .text : {
        *(.text.init)
        *(.text*)
    } > BOOTLOADER

    .rodata : {
        *(.rodata*)
    } > BOOTLOADER

    .data : {
        *(.data*)
    } > BOOTLOADER

    .bss : {
        *(.bss*)
    } > BOOTLOADER
}
