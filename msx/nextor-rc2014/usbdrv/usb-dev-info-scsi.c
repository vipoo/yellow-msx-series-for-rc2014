#include "usb-dev-info-scsi.h"
#include "class_scsi.h"
#include "nextor.h"
#include "usb-dev-info.h"
#include "work-area.h"
#include <stdlib.h>
#include <string.h>

uint8_t usb_dev_info_scsi(device_config *const dev, const dev_info_request request_info, uint8_t *const buffer) {
  scsi_inquiry_result response;

  if (request_info == BASIC_INFORMATION)
    return usb_dev_info_basic_information(buffer);

  memset(&response, 0, sizeof(scsi_inquiry_result));
  const usb_error result = scsi_inquiry(dev, &response);

  if (result != USB_ERR_OK)
    return 2;

  memset(buffer, ' ', 64);

  void   *src;
  uint8_t size;

  switch (request_info) {
  case MANUFACTURER_NAME:
    src  = response.vendor_information;
    size = 8;
    break;

  case DEVICE_NAME:
    src  = response.product_id;
    size = 16;
    break;

  case SERIAL_NUMBER:
    src  = response.product_revision;
    size = 4;
    break;

  default:
    return 1;
  }

  memcpy(buffer, src, size);
  return 0;
}
