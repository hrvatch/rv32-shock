// main.c - LED blink with interrupt support
#include <stdint.h>
#include "uart.h"
#include "irq.h"
#include "timer_driver.h"

#define LED_BASE             0x00002000
#define UART0_BASE_ADDR      0x00003000
#define TIMER_BASE_ADDR      0x00001000
uint32_t const one_second = 500;

volatile uint32_t *leds = (volatile uint32_t *)LED_BASE;
volatile uint32_t *text = (volatile uint32_t *)(LED_BASE + 4);
volatile uint32_t irq_count = 0;

Timer_RegMap *timer;

void uart_hello_world(void)
{
    uart_handle_t uart0;
    uart_config_t config = {
        .baud_rate = UART_BAUD_921600,
        .data_bits = UART_DATA_BITS_8,
        .parity = UART_PARITY_NONE,
        .stop_bits = UART_STOP_BITS_1,
        .tx_threshold = UART_THRESHOLD_1,   // Almost empty
        .rx_threshold = UART_THRESHOLD_14   // Almost full (15 bytes)
    };


    // Initialize UART with default settings (115200 8N1)
    uart_init_with_config(&uart0, UART0_BASE_ADDR, &config);
    
    // Send a string
    uart_puts(&uart0, "Hello, World!\r\n");

    // Wait for transmission to complete
    uart_wait_tx_complete(&uart0, 0);
}

uint32_t *irq(uint32_t *regs, uint32_t irqs)
{
  
  // Timer interrupt
  if ((irqs & (1 << 0)) != 0) {
    Timer_GetStatusAndClear(timer);
    *leds = (*leds << 1) | ((*leds & (1 << 7)) >> 7);
    irq_count++;
  }

  if (irq_count == 50) {
	  __asm__ volatile ("ebreak");
  }

  return regs;
}

int main(void) {
  // Enable timer interrupt
  irq_setmask(~(1 << 0));
  irq_setie(0x1);

  // Initialize timer for 1 second
  timer = Timer_Init(TIMER_BASE_ADDR);
  Timer_SetThreshold(timer, one_second);
  Timer_EnableInterrupt(timer, true);
  Timer_Start(timer);

  // Initialize a single LED
  *leds = 0x1;

  // Print something on UART
  while(1) {
    uart_hello_world();
  }
	__asm__ volatile ("ebreak");

  return 0;
}
