#include "usb-enumerate.h"
#include "hw.h"
#include "usb-enumerate-floppy.h"
#include "usb-enumerate-hub.h"
#include <string.h>

#include "debuggin.h"
#include "print.h"

usb_error op_identify_class_driver(_working *const working) __z88dk_fastcall;
usb_error op_parse_endpoint(_working *const working) __z88dk_fastcall;

usb_device_type identify_class_driver(const interface_descriptor *const p) {

  if (p->bInterfaceClass == 8 && (p->bInterfaceSubClass == 6 || p->bInterfaceSubClass == 5) && p->bInterfaceProtocol == 80) {
    return USB_IS_MASS_STORAGE;
  }

  if (p->bInterfaceClass == 8 && p->bInterfaceSubClass == 4 && p->bInterfaceProtocol == 0) {
    return USB_IS_FLOPPY;
  }

  if (p->bInterfaceClass == 9 && p->bInterfaceSubClass == 0 && p->bInterfaceProtocol == 0) {
    return USB_IS_HUB;
  }

  return 0;
}

usb_error get_config_descriptor(const device_descriptor *const desc,
                                const uint8_t                  config_index,
                                const uint8_t                  device_address,
                                uint8_t *const                 buffer) {
  usb_error result;

  // printf("Config %d, %d: ", config_index, device_address);
  CHECK(hw_get_config_descriptor(
      (config_descriptor *)buffer, config_index, desc->bMaxPacketSize0, sizeof(config_descriptor), device_address));
  // logConfig((config_descriptor *)buffer);

  CHECK(hw_get_config_descriptor((config_descriptor *)buffer,
                                 config_index,
                                 desc->bMaxPacketSize0,
                                 ((config_descriptor *)buffer)->wTotalLength,
                                 device_address));
  // logConfig((config_descriptor *)buffer);

  return USB_ERR_OK;
}

usb_error op_interface_next(_working *const working) __z88dk_fastcall {
  if (--working->interface_count == 0)
    return USB_ERR_OK;

  return op_identify_class_driver(working);
}

usb_error op_endpoint_next(_working *const working) __z88dk_fastcall {
  if (--working->endpoint_count > 0) {
    working->ptr = ((endpoint_descriptor *)working->ptr) + 1;
    return op_parse_endpoint(working);
  }

  return op_interface_next(working);
}

usb_error op_parse_endpoint(_working *const working) __z88dk_fastcall {
  _usb_state *const work_area = get_usb_work_area();

  const endpoint_descriptor *endpoint = (endpoint_descriptor *)working->ptr;

  // printf("EndP: ");
  // logEndPointDescription(endpoint);
  storage_device_config *const storage_dev = &work_area->storage_device[working->state->next_storage_device_index];

  switch (working->usb_device) {
  case USB_IS_FLOPPY:
  case USB_IS_MASS_STORAGE:
    parse_endpoint_floppy(storage_dev, endpoint);
    break;

  case USB_IS_HUB:
    parse_endpoint_hub(endpoint);
  }

  return op_endpoint_next(working);
}

usb_error op_capture_driver_interface(_working *const working) __z88dk_fastcall {
  usb_error                   result;
  _usb_state *const           work_area = get_usb_work_area();
  const interface_descriptor *interface = (interface_descriptor *)working->ptr;

  // printf("Intf ");
  // logInterface(interface);

  working->ptr            = interface + 1;
  working->endpoint_count = interface->bNumEndpoints;

  switch (working->usb_device) {
  case USB_IS_FLOPPY:
  case USB_IS_MASS_STORAGE: {
    working->state->next_storage_device_index++;
    storage_device_config *const storage_dev = &work_area->storage_device[working->state->next_storage_device_index];
    device_config *const         dev_cfg     = &storage_dev->config;

    dev_cfg->max_packet_size  = working->desc.bMaxPacketSize0;
    dev_cfg->value            = working->config.desc.bConfigurationvalue;
    dev_cfg->address          = working->state->next_device_address++;
    dev_cfg->interface_number = interface->bInterfaceNumber;
    storage_dev->type         = working->usb_device;
    CHECK(hw_set_configuration(dev_cfg), x_printf("err %d\r\n", result));
    break;
  }

  case USB_IS_HUB:
    work_area->hub_config.interface_number = interface->bInterfaceNumber;
    work_area->hub_config.max_packet_size  = working->desc.bMaxPacketSize0;
    work_area->hub_config.value            = working->config.desc.bConfigurationvalue;
    work_area->hub_config.address          = working->state->next_device_address++;
    CHECK(configure_usb_hub(working));
    break;
  }

  return op_parse_endpoint(working);
}

usb_error op_identify_class_driver(_working *const working) __z88dk_fastcall {
  working->usb_device = identify_class_driver((interface_descriptor *)working->ptr);
  return op_capture_driver_interface(working);
}

usb_error op_get_config_descriptor(_working *const working) __z88dk_fastcall {
  usb_error result;

  CHECK(get_config_descriptor(
      &working->desc, working->config_index, working->state->next_device_address, working->config.buffer));

  working->ptr             = (working->config.buffer + sizeof(config_descriptor));
  working->interface_count = working->config.desc.bNumInterfaces;

  return op_identify_class_driver(working);
}

usb_error read_all_configs(enumeration_state *const state) {
  uint8_t           result;
  _usb_state *const work_area = get_usb_work_area();

  _working working;
  memset(&working, 0, sizeof(_working));
  working.state = state;

  CHECK(hw_get_description_short(&working.desc), x_printf("ErrX %02x\r\n", result));

  const uint8_t dev_address = state->next_device_address;

  CHECK(hw_set_address(dev_address, working.desc.bMaxPacketSize0))

  CHECK(hw_get_description(dev_address, working.desc.bMaxPacketSize0, &working.desc), x_printf("ErrX %02x\r\n", result));

  // printf("Desc: ", sizeof(device_descriptor));
  // logDevice(&working.desc);

  for (uint8_t config_index = 0; config_index < working.desc.bNumConfigurations; config_index++) {
    working.config_index = config_index;

    CHECK(op_get_config_descriptor(&working));
  }

  return USB_ERR_OK;
}

usb_error enumerate_all_devices() {
  enumeration_state state;
  state.next_storage_device_index = (uint8_t)-1;
  state.next_device_address       = 20;

  return read_all_configs(&state);
}

/*
  enumerate_all_devices
    -> read_all_configs
      -> parse_config
        -> op_get_config_descriptor
          -> op_identify_class_driver
            -> op_capture_driver_interface (increment index)
              -> op_parse_endpoint
                -> parse_endpoint_floppy
                -> parse_endpoint_hub
                -> op_endpoint_next
                  -> op_parse_endpoint -^ (install driver endpoint)
                  -> op_interface_next
                    -> return
                    -> op_identify_class_driver -^


*/