# bootloader.S - Bootloader for the picorv32 based SoC
# This bootloader waits until 'R' (ready) is received via UART. Once this happens,
# every 4 bytes received via bootloader will be stored to SRAM.

.section .text.init

# UART register addresses
.equ UART_BASE,           0x3000
.equ UART_STATUS,         UART_BASE + 0x00
.equ UART_INTERRUPT_EN,   UART_BASE + 0x04
.equ UART_CONFIG,         UART_BASE + 0x08
.equ UART_FIFO_CLEAR,     UART_BASE + 0x0C
.equ UART_RX_FIFO,        UART_BASE + 0x10
.equ UART_TX_FIFO,        UART_BASE + 0x14

# UART configuration
.equ UART_115200N1,       0xE83

# SRAM configuration
.equ SRAM_BASE,           0x4000
.equ SRAM_SIZE,           16384      # 16KB

# LEDs
.equ LED_BASE,            0x2000

.section .text.init
.global _bootloader_start

_bootloader_start:
	  # Zero-initialize all registers
	  # addi x1, zero, 0
	  # addi x2, zero, 0
	  # addi x3, zero, 0
	  # addi x4, zero, 0
	  # addi x5, zero, 0
	  # addi x6, zero, 0
	  # addi x7, zero, 0
	  # addi x8, zero, 0
	  # addi x9, zero, 0
	  # addi x10, zero, 0
	  # addi x11, zero, 0
	  # addi x12, zero, 0
	  # addi x13, zero, 0
	  # addi x14, zero, 0
	  # addi x15, zero, 0
	  # addi x16, zero, 0
	  # addi x17, zero, 0
	  # addi x18, zero, 0
	  # addi x19, zero, 0
	  # addi x20, zero, 0
	  # addi x21, zero, 0
	  # addi x22, zero, 0
	  # addi x23, zero, 0
	  # addi x24, zero, 0
	  # addi x25, zero, 0
	  # addi x26, zero, 0
	  # addi x27, zero, 0
	  # addi x28, zero, 0
	  # addi x29, zero, 0
	  # addi x30, zero, 0
	  # addi x31, zero, 0

    # # Initialize stack (end of bootloader region)
    # li sp, 0x9000
    
    # Initialize UART
    jal uart_init

    # Signal to user UART is initialized; turn on LED0
    li a0, 0x0
    li a1, 0x1
    jal led_write
    
    # Wait for 'R' character
wait_for_r:
    jal uart_recv_byte
    li t0, 'R'
    bne a0, t0, wait_for_r
    
    # Signal to user we've received 'R'; turn on LED1
    li a0, 0x1
    li a1, 0x1
    jal led_write
    
    # Setup for receiving program
    li s0, SRAM_BASE            # s0 = destination pointer
    li s1, SRAM_SIZE            # s1 = bytes remaining
    li s3, 0                    # s3 = total bytes received
    
receive_loop:
    beqz s1, done_loading       # Exit when all bytes received
    
    # Receive 4 bytes and assemble into word (little-endian)
    jal uart_recv_byte
    mv s2, a0                   # Byte 0 (LSB)
    
    jal uart_recv_byte
    slli a0, a0, 8
    or s2, s2, a0               # Byte 1
    
    jal uart_recv_byte
    slli a0, a0, 16
    or s2, s2, a0               # Byte 2
    
    jal uart_recv_byte
    slli a0, a0, 24
    or s2, s2, a0               # Byte 3 (MSB)
    
    # Write word to SRAM
    sw s2, 0(s0)
    
    # Update pointers
    addi s0, s0, 4
    addi s1, s1, -4
    addi s3, s3, 4              # Increment total bytes received
    
    # Check if we've received 1024 bytes since last report
    # 1024 = 2^10, so check if bottom 10 bits are zero
    andi t1, s3, 0x3FF          # Mask bottom 10 bits
    bnez t1, receive_loop       # Skip if not at 1024-byte boundary
    
    # Send progress indicator
    li a0, '.'
    jal uart_send_byte
    
    j receive_loop
    
done_loading:
    # Jump to loaded program at SRAM base
    li t0, SRAM_BASE
    jr t0

# Receive one byte from UART
# Returns: a0 = received byte (lower 8 bits)
uart_recv_byte:
    li t0, UART_STATUS
wait_rx:
    lw t1, 0(t0)                # Read STATUS register
    andi t1, t1, 0x1            # Check bit 0
    bnez t1, wait_rx            # Loop if no valid data
    
    li t0, UART_RX_FIFO         # Read from RX FIFO
    lw a0, 0(t0)
    andi a0, a0, 0xFF           # Mask to ensure only byte
    ret

# Send one byte via UART
# Arguments: a0 = byte to send (lower 8 bits)
uart_send_byte:
    li t0, UART_TX_FIFO
    sw a0, 0(t0)
    ret

# UART initialization
uart_init:
    li t0, UART_CONFIG          # CONFIG register
    li t1, UART_115200N1
    sw t1, 0(t0)
    ret

# Turn LED on/off
led_write:
    li t0, LED_BASE             # LED Control
    lw t1, 0(t0)                # Load current LED state
    li t2, 0x1
    sll t2, t2, a0              # Create bit mask for LED number
    bnez a1, 1f                 # Branch if turning on
    not t2, t2                  # Invert mask to clear bit
    and t1, t1, t2              # Clear the bit
    j 2f
1:
    or t1, t1, t2               # Set the bit
2:
    sw t1, 0(t0)                # Store back to LED_BASE
    ret
