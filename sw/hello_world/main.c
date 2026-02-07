// main.c - LED blink with interrupt support
#include <stdint.h>
#include "uart.h"
#include "irq.h"
#include "timer.h"

#define LED_BASE             0x00002000
#define UART_BASE_ADDR       0x00003000
#define TIMER_BASE_ADDR      0x00001000

uint32_t const one_second_prescaler = 9999;
uint32_t const one_second_timer     = 9999;

volatile uint32_t *leds = (volatile uint32_t *)LED_BASE;
volatile uint32_t *text = (volatile uint32_t *)(LED_BASE + 4);

static uart_t uart0;
static timer_t timer0;

uint32_t *irq(uint32_t *regs, uint32_t irqs)
{
  // Timer interrupt
  if (timer_get_status(&timer0)) {
    *leds = (*leds << 1) | ((*leds & (1 << 7)) >> 7);
  }

  return regs;
}

int main(void) {

  // Enable timer interrupt
  irq_setmask(~(1 << 2));

  // Global interrupt enable
  irq_setie(0x1);

  // Initialize a single LED
  *leds = 0x1;
  
  /*
     * 1-second tick @ 100 MHz:
     *   prescaler  = 9999  => Fcnt = 100 MHz / 10000 = 10 kHz
     *   threshold  = 9999  => period = 10000 / 10 kHz = 1 s
     *   enable IRQ
     */
  timer_init(&timer0, TIMER_BASE_ADDR);
  timer_start(&timer0, one_second_prescaler, one_second_timer, 1);

  /*
     * Initialize UART 
     *   8 data bits, 1 stop bit, no parity, 921600 baud rate 
     */
  uart_init(&uart0, UART_BASE_ADDR);
  uart_configure(&uart0, UART_CFG_DATA_8 | UART_CFG_BAUD_921600);
  uart_fifo_clear(&uart0, UART_FIFO_CLEAR_TX | UART_FIFO_CLEAR_RX);
  uart_write(&uart0, (const uint8_t *)"UART initialized!\r\n", 19);

  /* Echo loop */
  while (1) {
    uint8_t c = uart_getc(&uart0);
    uart_putc(&uart0, c);
  }

  __asm__ volatile ("ebreak");

  return 0;
}
