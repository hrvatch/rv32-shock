# start.S - Startup file
#include "custom_ops.S"

.section .text.start
.global _start
.global _irq_handler

_start:
    j _init                  # Jump to initialization

# ==============================================================================
# IRQ Handler - force to 0x1010 using .org
# ==============================================================================
.org 0x10                    # Offset 0x10 from section start (0x1000 + 0x10 = 0x1010)

_irq_handler:
  picorv32_setq_insn(q2, x1)
  picorv32_setq_insn(q3, x2)
  lui x1, %hi(irq_regs)
  addi x1, x1, %lo(irq_regs)
  picorv32_getq_insn(x2, q0)
  sw x2,   0*4(x1)
  picorv32_getq_insn(x2, q2)
  sw x2,   1*4(x1)
  picorv32_getq_insn(x2, q3)
  sw x2,   2*4(x1)

  # Save context
  sw x5,   5*4(x1)
	sw x6,   6*4(x1)
	sw x7,   7*4(x1)
	sw x10, 10*4(x1)
	sw x11, 11*4(x1)
	sw x12, 12*4(x1)
	sw x13, 13*4(x1)
	sw x14, 14*4(x1)
	sw x15, 15*4(x1)
	sw x16, 16*4(x1)
	sw x17, 17*4(x1)
	sw x28, 28*4(x1)
	sw x29, 29*4(x1)
	sw x30, 30*4(x1)
	sw x31, 31*4(x1)

  # Call interrupt handler C function
  lui sp, %hi(irq_stack)
  addi sp, sp, %lo(irq_stack)

  # arg0 = address of regs
  lui a0, %hi(irq_regs)
  addi a0, a0, %lo(irq_regs)

  # arg1 = interrupt type
  picorv32_getq_insn(a1, q1)

  # Call to C function
  jal ra, irq

  # new irq_regs address returned from C code in a0
  addi x1, a0, 0
  lw x2,   0*4(x1)
  picorv32_setq_insn(q0, x2)
  lw x2,   1*4(x1)
  picorv32_setq_insn(q1, x2)
  lw x2,   2*4(x1)
  picorv32_setq_insn(q2, x2)

  # Restore context
	lw x5,   5*4(x1)
	lw x6,   6*4(x1)
	lw x7,   7*4(x1)
	lw x10, 10*4(x1)
	lw x11, 11*4(x1)
	lw x12, 12*4(x1)
	lw x13, 13*4(x1)
	lw x14, 14*4(x1)
	lw x15, 15*4(x1)
	lw x16, 16*4(x1)
	lw x17, 17*4(x1)
	lw x28, 28*4(x1)
	lw x29, 29*4(x1)
	lw x30, 30*4(x1)
	lw x31, 31*4(x1)

  picorv32_getq_insn(x1, q1)
  picorv32_getq_insn(x2, q2)
  picorv32_retirq_insn()

# ==============================================================================
# Initialization code
# ==============================================================================
_init:
	# zero-initialize all registers
	addi x1, zero, 0
	addi x2, zero, 0
	addi x3, zero, 0
	addi x4, zero, 0
	addi x5, zero, 0
	addi x6, zero, 0
	addi x7, zero, 0
	addi x8, zero, 0
	addi x9, zero, 0
	addi x10, zero, 0
	addi x11, zero, 0
	addi x12, zero, 0
	addi x13, zero, 0
	addi x14, zero, 0
	addi x15, zero, 0
	addi x16, zero, 0
	addi x17, zero, 0
	addi x18, zero, 0
	addi x19, zero, 0
	addi x20, zero, 0
	addi x21, zero, 0
	addi x22, zero, 0
	addi x23, zero, 0
	addi x24, zero, 0
	addi x25, zero, 0
	addi x26, zero, 0
	addi x27, zero, 0
	addi x28, zero, 0
	addi x29, zero, 0
	addi x30, zero, 0
	addi x31, zero, 0
  # Initialize stack
  la sp, _stack_top
  
  # Clear BSS
  la t0, _bss_start
  la t1, _bss_end
1:
  bge t0, t1, 2f
  sw zero, 0(t0)
  addi t0, t0, 4
  j 1b
2:
  # Call main
  call main
  
  # Trap if main returns (should never happen)
  ebreak

# ==============================================================================
# Helper functions - picorv32 timer, interrupts
# ==============================================================================

# Halt picorv32 execution until woken up by timer
.global _set_wake_on_irq
_set_wake_on_irq:
  picorv32_waitirq_insn(a0)
  ret

# Set picorv32 timer
.global _set_picorv32_timer
_set_picorv32_timer:
  picorv32_timer_insn(zero, a0)
  ret

# Enable interrupts by copying the software mask to the hardware mask
.global _irq_enable
_irq_enable:
  /* Set _irq_enabled to true */
  la t0, _irq_enabled
  addi t1, zero, 1
  sw t1, 0(t0)
  /* Set the HW IRQ mask to _irq_mask */
  la t0, _irq_mask
  lw t0, 0(t0)
  picorv32_maskirq_insn(zero, t0)
  ret

# Disable interrupts by masking all interrupts (the mask should already be
# up to date)
.global _irq_disable
_irq_disable:
  /* Mask all IRQs */
  li t0, 0xffffffff
  picorv32_maskirq_insn(zero, t0)
  /* Set _irq_enabled to false */
  la t0, _irq_enabled
  sw zero, (t0)
  ret

# Set interrrupt mask.
# This updates the software mask (for readback and interrupt inable/disable)
# and the hardware mask.
# 1 means interrupt is masked (disabled).
.global _irq_setmask
_irq_setmask:
  /* Update _irq_mask */
  la t0, _irq_mask
  sw a0, (t0)
  /* Are interrupts enabled? */
  la t0, _irq_enabled
  lw t0, 0(t0)
  beq t0, zero, 1f
  /* If so, update the HW IRQ mask */
  picorv32_maskirq_insn(zero, a0)
1:
  ret

.section .bss
irq_regs:
  # registers are saved to this memory region during interrupt handling
  # the program counter is saved as register 0
  .fill 32,4

  # stack for the interrupt handler
  .fill 128,4
irq_stack:

# Software copy of enabled interrupts. Do not write directly, use
# _irq_set_mask instead.
.global _irq_mask
_irq_mask:
  .word 0

# Software state of global interrupts being enabled or disabled. Do not write
# directly, use _irq_disable / _irq_enable instead.
.global _irq_enabled
_irq_enabled:
  .word 0
