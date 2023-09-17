#include "printer.h"
#include "hw.h"
#include <string.h>

const setup_packet cmd_get_port_status = {0xA1, 1, {0, 0}, {0, 0}, 1};

usb_error prt_get_port_status(const device_config *const dev, uint8_t *buffer) {
  usb_error    result;
  setup_packet cmd;
  cmd = cmd_get_port_status;

  printf("prt_get_port_status %d, %d\r\n", dev->address, dev->max_packet_size);

  result = hw_control_transfer(&cmd, (uint8_t *)buffer, dev->address, dev->max_packet_size);

  CHECK(result);

  return result;
}

const setup_packet cmd_get_device_id = {0xA1, 0, {0, 0}, {0, 0}, 4};

usb_error prt_get_device_id(const device_config *const dev, uint8_t *buffer) {
  usb_error    result;
  setup_packet cmd;
  cmd = cmd_get_device_id;

  printf("prt_get_device_id %d, %d\r\n", dev->address, dev->max_packet_size);

  result = hw_control_transfer(&cmd, (uint8_t *)buffer, dev->address, dev->max_packet_size);

  CHECK(result);

  return result;
}

const setup_packet cmd_soft_reset = {0x21, 2, {0, 0}, {0, 0}, 0};

usb_error prt_soft_reset(const device_config *const dev) {
  usb_error    result;
  setup_packet cmd;
  cmd = cmd_soft_reset;

  printf("cmd_soft_reset %d, %d\r\n", dev->address, dev->max_packet_size);

  result = hw_control_transfer(&cmd, 0, dev->address, dev->max_packet_size);

  CHECK(result);

  return result;
}

usb_error prt_send_text(printer_device_config *const dev, const char *text) {
  usb_error result;

  dev->endpoint.toggle = 0;

  CHECK(hw_data_out_transfer((const uint8_t *)text, strlen(text), dev->config.address, &dev->endpoint));

  return result;
}