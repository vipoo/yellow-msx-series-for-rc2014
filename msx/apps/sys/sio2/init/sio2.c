#include "../sio2.h"
#include <extbio/serial.h>
#include <stdio.h>
#include <sysload/sysload.h>

#define relocated(x)  ((const char *)((uint16_t)(&x) + (uint16_t)(my_header)))
#define relocated2(x) ((uint8_t *)((uint16_t)(x) + (uint16_t)(my_header)))

uint16_t relocated_sio_buf;
uint16_t relocated_sio_rcvbuf;
uint16_t relocated_sio_data_count;
uint16_t relocated_sio_buf_head;
uint16_t relocated_sio_buf_tail;

uint16_t init(installed_sys_t *my_header) __z88dk_fastcall {

  relocated_sio_buf        = (uint16_t)relocated2(sio_buf);
  relocated_sio_data_count = (uint16_t)relocated2(&sio_data_count);
  relocated_sio_buf_head   = (uint16_t)relocated2(&sio_buf_head);
  relocated_sio_buf_tail   = (uint16_t)relocated2(&sio_buf_tail);

  uint8_t sio_detected = sio_probe();
  if (sio_detected == 0) {
    printf("SIO/2:           NOT PRESENT\r\n");
    return 1;
  }

  uint8_t *const relocated_assigned_port_number = &relocated2(&assigned_port_number);
  serial_get_available_ports(relocated_assigned_port_number);
  *relocated_assigned_port_number += 1;

  printf("SIO/2:           INSTALLED (COM%d)\r\n", *relocated_assigned_port_number);

  sio2_chip_init();

  return 0;
}
