// main.c - LED blink with interrupt support
#include <stdint.h>
#include "uart.h"
#include "irq.h"
#include "axi4_lite_timer.h"

#define LED_BASE             0x00002000
#define UART0_BASE_ADDR      0x00003000

volatile uint32_t *leds = (volatile uint32_t *)LED_BASE;
volatile uint32_t *text = (volatile uint32_t *)(LED_BASE + 4);
volatile uint32_t irq_count = 0;

void uart_hello_world(void)
{
    uart_handle_t uart0;
    
    // Initialize UART with default settings (115200 8N1)
    uart_init(&uart0, UART0_BASE_ADDR);
    
    // Send a string
    uart_puts(&uart0, "Hello, World!\r\n");

    // Wait for transmission to complete
    uart_wait_tx_complete(&uart0, 0);
}

uint32_t *irq(uint32_t *regs, uint32_t irqs)
{

  // Trap if either EBREAK/ECALL or Illegal Instruction or BUS Error
	if ((irqs & 6) != 0) {
	  __asm__ volatile ("ebreak");
	}

  irq_count++;
  if (irq_count == 60) {
    __asm__ volatile ("ebreak");
  }

  // Timer interrupt
  if ((irqs & (1 << 3)) != 0) {
    *leds = (*leds << 1) | ((*leds & (1 << 7)) >> 7);
  }

  return regs;
}

int main(void) {
  // Enable timer interrupt
  timer0_configure(0, 5000, 1, 1);
  timer0_enable();
  irq_setmask(~(1 << 3));
  irq_setie(0x1);

  // Initialize a single LED
  *leds = 0x1;

  // Print something on UART
  uart_hello_world();
	__asm__ volatile ("ebreak");

  return 0;
}
