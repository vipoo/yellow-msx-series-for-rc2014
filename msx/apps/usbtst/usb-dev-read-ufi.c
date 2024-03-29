#include "usb-dev-read-ufi.h"
#include "nextor.h"
#include <class_ufi.h>

uint8_t usb_dev_read_ufi(device_config *const dev,
                         const uint8_t        lun,
                         const uint8_t        number_sectors_to_read,
                         const uint32_t       sector_number,
                         uint8_t *const       buffer,
                         uint8_t *const       number_of_sectors_read) {
  if (lun != 1)
    return NEXTOR_ERR_IDEVL;

  if (wait_for_device_ready(dev, 2500) != 0)
    return NEXTOR_ERR_NRDY;

  if (ufi_read_write_sector(dev, false, sector_number, number_sectors_to_read, buffer, NULL) != USB_ERR_OK)
    return NEXTOR_ERR_DISK;

  *number_of_sectors_read = number_sectors_to_read;

  return NEXTOR_ERR_OK;
}
