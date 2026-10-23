#define UART0_BASE ((volatile unsigned char *)0xe0004500)

void uart_init(void) {
  UART0_BASE[1] = 0x00; // Disable interrupts
  UART0_BASE[3] = 0x80; // Enable DLAB (set baud rate divisor)
  UART0_BASE[0] = 0x01; // Divisor latch low (baud rate)
  UART0_BASE[1] = 0x00; // Divisor latch high
  UART0_BASE[3] = 0x03; // 8 bits, no parity, 1 stop bit
  UART0_BASE[2] = 0xC7; // Enable FIFO, clear them
}

void early_putc(char c) {
  // Wait for Transmit Holding Register Empty
  while (!(UART0_BASE[5] & 0x20)) {
    // 'sync' replaces 'eieio' for Book-E compatibility
    __asm__ volatile("sync" : : : "memory");
  }
  UART0_BASE[0] = c;
  __asm__ volatile("sync" : : : "memory");
}

void kmain() {
  uart_init();
  early_putc('a');
  early_putc('\r');
  early_putc('\n');
  while (1) {
    __asm__ volatile("nop");
  }
}
