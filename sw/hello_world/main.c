// main.c - LED blink with interrupt support
#include <stdint.h>
#include "irq.h"
#include "axi4_lite_timer.h"

#define LED_BASE 0x00006000
volatile uint32_t *leds = (volatile uint32_t *)LED_BASE;
volatile uint32_t irq_count = 0;

uint32_t *irq(uint32_t *regs, uint32_t irqs)
{

  // Trap if either EBREAK/ECALL or Illegal Instruction or BUS Error
	if ((irqs & 6) != 0) {
	  __asm__ volatile ("ebreak");
	}

  irq_count++;
  if (irq_count == 5) {
    __asm__ volatile ("ebreak");
  }

  // Timer interrupt
  if ((irqs & (1 << 3)) != 0) {
    *leds = ~(*leds);
  }

  return regs;
}

int main(void) {
  // Enable timer interrupt
  timer0_configure(0, 5000, 1, 1);
  timer0_enable();
  irq_setmask(~(1 << 3));
  irq_setie(0x1);

  // Initialize LEDs off
  *leds = 0x0;

  // Main loop - blink LEDs every 1 second
  while (1) {
    halt_execution_and_wake_on_irq(~(1u << 3)) ;
  }

  return 0;
}
