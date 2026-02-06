# bootloader.S - Bootloader for the picorv32 based SoC, Simulation version
# This version simply jumps to the SRAM program

.section .text.init

# SRAM configuration
.equ SRAM_BASE,           0x4000
.equ SRAM_SIZE,           16384      # 16KB

.section .text.init
.global _bootloader_start

_bootloader_start:
    # Jump to loaded program at SRAM base
    li t0, SRAM_BASE
    jr t0
