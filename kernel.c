typedef unsigned int of_cell;

/* openfw client calls use a service name and cell based arg frames */
struct of_call_args {
  of_cell service;
  of_cell nargs;
  of_cell nret;
  of_cell cells[5];
};

typedef int (*of_client_entry)(void *);

extern int vof_client_call(void *args);

static void serial_write(const char *message, unsigned int length) {
  volatile unsigned char *const uart =
      (volatile unsigned char *)0xfe0002f8u;

  uart[1] = 0;
  uart[3] = 0x03;
  for (unsigned int i = 0; i < length; i++) {
    while ((uart[5] & 0x20) == 0) {
    }
    uart[0] = (unsigned char)message[i];
  }
}

static int of_call(of_client_entry entry, const char *service, of_cell nargs,
                   of_cell arg0, of_cell arg1, of_cell arg2, of_cell arg3,
                   of_cell arg4) {
  struct of_call_args args = {
      .service = (of_cell)service,
      .nargs = nargs,
      .nret = 1,
      .cells = {arg0, arg1, arg2, arg3, arg4},
  };

  if (entry(&args) < 0) {
    return -1;
  }
  return (int)args.cells[nargs];
}

void kmain(void) {
  of_client_entry entry = vof_client_call;

  /* resolve /chosen and fetch its stdout instance handle */
  int chosen =
      of_call(entry, "finddevice", 1, (of_cell)"/chosen", 0, 0, 0, 0);
  if (chosen <= 0) {
    for (;;) {
      __asm__ volatile("nop");
    }
  }

  of_cell stdout_handle = 0;
  int property_length =
      of_call(entry, "getprop", 4, (of_cell)chosen, (of_cell)"stdout",
              (of_cell)&stdout_handle, sizeof(stdout_handle), 0);
  if (property_length != sizeof(stdout_handle)) {
    for (;;) {
      __asm__ volatile("nop");
    }
  }

  /* write calls but no output backend */
  static const char message[] = "\nhello world\r\n";
  int written = of_call(entry, "write", 3, stdout_handle, (of_cell)message,
                        sizeof(message) - 1, 0, 0);
  if (written < 0) {
    for (;;) {
      __asm__ volatile("nop");
    }
  }

  serial_write(message, sizeof(message) - 1);

  while (1) {
    __asm__ volatile("nop");
  }
}
