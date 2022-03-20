#include <system_vars.h>
#include <delay.h>
#include <string.h>
#include "print.h"
#include "work-area.h"
#include <stdbool.h>
#include "debuggin.h"

inline uint8_t min(const uint8_t a, const uint8_t b) {
  return a < b ? a : b;
}

__sfr __at 0x84 CH376_DATA_PORT;
__sfr __at 0x85 CH376_COMMAND_PORT;


#define CH_CMD_GET_IC_VER   0x01
#define CH_CMD_RESET_ALL    0x05
#define CH_CMD_CHECK_EXIST  0x06
#define CH_CMD_SET_RETRY    0x0B
#define CH_CMD_SET_USB_ADDR 0x13
#define CH_CMD_SET_USB_MODE 0x15
#define CH_CMD_GET_STATUS   0x22
#define CH_CMD_RD_USB_DATA0 0x27
#define CH_CMD_WR_HOST_DATA 0x2C
#define CH_CMD_CLR_STALL    0x41
#define CH_CMD_ISSUE_TKN_X  0x4E


#define CH_MODE_HOST_RESET  7
#define CH_MODE_HOST        6

// return codes
#define CH_ST_RET_SUCCESS         0x51
#define CH_ST_RET_ABORT           0x5F

// CH376 result codes
#define CH_USB_INT_SUCCESS        0x14
#define CH_USB_ERR_FOUND_NAME     0x43

#define USB_STALL 0x2e


typedef enum _ch376_pid {
  CH_PID_SETUP  = 0x0D,
  CH_PID_IN     = 0x09,
  CH_PID_OUT    = 0x01
} ch376_pid;

const void setCommand(const uint8_t command) __z88dk_fastcall {
  CH376_COMMAND_PORT = command;
  delay(1);
}

inline void ch376_reset() {
  delay(30);
  setCommand(CH_CMD_RESET_ALL);
  delay(30);
}


const uint8_t* ch_write_data(const uint8_t* buffer, uint8_t length) {
  setCommand(CH_CMD_WR_HOST_DATA);
  CH376_DATA_PORT = length;

  while(length-- > 0) {
    CH376_DATA_PORT = *buffer++;
  }
  return buffer;
}

// endpoint => e
// pid => B
// toggle => A (bit 7 for in, bit 6 for out)
void ch_issue_token(const uint8_t endpoint, const ch376_pid pid, const uint8_t toggle_bits) {
  setCommand(CH_CMD_ISSUE_TKN_X);
  CH376_DATA_PORT = toggle_bits;
  CH376_DATA_PORT = endpoint << 4 | pid;
}

uint8_t ch_wait_int_and_get_result() {
  uint8_t counter = 255;
  while ((CH376_DATA_PORT & 0x80) && --counter > 0)
    ;

  setCommand(CH_CMD_GET_STATUS);
  return CH376_DATA_PORT;
}

// buffer => hl
// C -> amount_received
// returned -> hl
uint8_t* ch_read_data(uint8_t* buffer, uint8_t* const amount_received) {
  setCommand(CH_CMD_RD_USB_DATA0);
  uint8_t count = CH376_DATA_PORT;
  *amount_received = count;

  while(count-- > 0)
    *buffer++ = CH376_DATA_PORT;

  return buffer;
}
// buffer -> hl
// data_length -> bc
// device_address -> a
// max_packet_size -> d
// endpoint -> e
// *toggle -> Cy
// *amount_received -> BC
uint8_t ch_data_in_transfer(uint8_t* buffer, uint16_t data_length, const uint8_t max_packet_size, const uint8_t endpoint, uint16_t* const amount_received, uint8_t * const toggle) {

  uint8_t count;
  uint8_t result;
  do {
    ch_issue_token(endpoint, CH_PID_IN, *toggle ? 0x80 : 0x00);
    *toggle = ~*toggle;

    if ((result = ch_wait_int_and_get_result()) != CH_USB_INT_SUCCESS)
      return result;

    buffer = ch_read_data(buffer, &count);
    data_length -= count;
    *amount_received += count;
  } while(data_length > 0 && count < max_packet_size);

  return CH_USB_INT_SUCCESS;
}

// buffer => HL
// buffer_length => BC
// max_packet_size => D
// endpoint => E
// *toggle => Cy
uint8_t ch_data_out_transfer(const uint8_t* buffer, uint16_t buffer_length, const uint8_t max_packet_size, const uint8_t endpoint, uint8_t* const toggle) {
  uint8_t result;

  while (buffer_length > 0) {
    uint8_t size = min(max_packet_size, buffer_length);
    buffer = ch_write_data(buffer, size);
    buffer_length -= size;

    ch_issue_token(endpoint, CH_PID_OUT, *toggle ? 0x40 : 0x00);
    if ((result = ch_wait_int_and_get_result()) != CH_USB_INT_SUCCESS)
      return result;

    *toggle = ~*toggle;
  }

  return CH_USB_INT_SUCCESS;
}
// setupPacket -> HL
// buffer -> DE
// device_address -> a
// max_packet_size -> b
// *amount_transferred -> bc
uint8_t hw_control_transfer(const usb_descriptor_block * const cmd_packet, uint8_t* const buffer, const uint8_t device_address, const uint8_t max_packet_size, uint16_t* const amount_transferred) {
  uint8_t result;
  uint8_t toggle;

retry:
  toggle = 1;
  setCommand(CH_CMD_SET_USB_ADDR);
  CH376_DATA_PORT = device_address;

  ch_write_data((const uint8_t*)cmd_packet, sizeof(usb_descriptor_block));

  ch_issue_token(0, CH_PID_SETUP, 0);

  if ((result = ch_wait_int_and_get_result()) != CH_USB_INT_SUCCESS) {
    printf("\r\nErr1 (%d)\r\n", result);
    return result;
  }

  const uint8_t transferIn = (cmd_packet->code & 0x80);

  if (transferIn && buffer == 0) {
    printf("Err5\r\n");
    return 99;
  }

  result = transferIn ?
    ch_data_in_transfer(buffer, cmd_packet->length, max_packet_size, 0, amount_transferred, &toggle) :
    ch_data_out_transfer(buffer, cmd_packet->length, max_packet_size, 0, &toggle);

  if ((result & 0x2f) == USB_STALL) {
    printf("Stall");
    setCommand(CH_CMD_CLR_STALL);
    delay(60/4);
    CH376_DATA_PORT = cmd_packet->code & 0x80;

    result = ch_wait_int_and_get_result();
    if (result == CH_USB_INT_SUCCESS)
      goto retry;
  }

  if (result != CH_USB_INT_SUCCESS) {
    printf("\r\nErr 2 (%d)\r\n", result);
    return result;
  }

  if (transferIn)
    ch_issue_token(0, CH_PID_OUT, 0x40);
  else
    ch_issue_token(0, CH_PID_IN, 0x80);

  result = ch_wait_int_and_get_result();

  if (transferIn)
    return CH_USB_INT_SUCCESS;

  setCommand(CH_CMD_RD_USB_DATA0);
  result = CH376_DATA_PORT;
  if (result == 0)
    return CH_USB_INT_SUCCESS;

  return result;
}

uint8_t ch_get_device_descriptor(const work_area * const work_area, device_descriptor * const buffer, const uint8_t device_address, uint16_t* const amount_transferred) {
  *amount_transferred = 0;
  return hw_control_transfer(
    &work_area->ch376.usb_descriptor_blocks.cmd_get_device_descriptor,
    (uint8_t*)buffer,
    device_address,
    8,
    amount_transferred
  );
}

// buffer => hl
// configuration index starting with 0 to DEVICE_DESCRIPTOR.bNumConfigurations => A
// max_packet_size => B
// buffer_size => C
// device_address => D
uint8_t ch_get_config_descriptor(work_area* const work_area, config_descriptor* const buffer, const uint8_t config_index, const uint8_t max_packet_size, const uint8_t buffer_size, const uint8_t device_address, uint16_t* const amount_transferred) {
  *amount_transferred = 0;
  work_area->ch376.usb_descriptor_blocks.cmd_get_config_descriptor.dat2 = config_index;
  work_area->ch376.usb_descriptor_blocks.cmd_get_config_descriptor.length = (uint16_t)buffer_size;

  return hw_control_transfer(
    &work_area->ch376.usb_descriptor_blocks.cmd_get_config_descriptor,
    (uint8_t*)buffer,
    device_address,
    max_packet_size,
    amount_transferred
  );
}

// config_id => A
// max_packet_size => B
// device_address => D
uint8_t ch_set_configuration(work_area * const work_area, const uint8_t config_id, const uint8_t max_packet_size, const uint8_t device_address, uint16_t* const amount_transferred) {
  *amount_transferred = 0;
  work_area->ch376.usb_descriptor_blocks.cmd_set_configuration.dat2 = config_id;

  return hw_control_transfer(
    &work_area->ch376.usb_descriptor_blocks.cmd_set_configuration,
    (uint8_t*)0,
    device_address,
    max_packet_size,
    amount_transferred
  );
}

uint8_t scsi_max_luns(work_area * const work_area, uint16_t* const amount_transferred) {
  * amount_transferred = 0;
  work_area->ch376.usb_descriptor_blocks.cmd_get_max_luns.dat4 = work_area->ch376.storage_device_info.interface_id;
  return hw_control_transfer(
    &work_area->ch376.usb_descriptor_blocks.cmd_get_max_luns,
    (uint8_t*)&work_area->ch376.scsi_device_info.max_luns,
    work_area->ch376.storage_device_info.device_address,
    work_area->ch376.storage_device_info.max_packet_size,
    amount_transferred
  );
}



// usb_address => A
// packet_size => B
uint8_t ch_set_address(work_area* const work_area, const uint8_t usb_address, const uint8_t packet_size) {
  uint16_t amount_transferred = 0;

  work_area->ch376.usb_descriptor_blocks.cmd_set_address.dat2 = usb_address;
  return hw_control_transfer(
    &work_area->ch376.usb_descriptor_blocks.cmd_set_address,
    (uint8_t*)0,
    0,
    packet_size,
    &amount_transferred
  );
}


uint8_t hw_get_descriptors(work_area * const work_area, uint8_t* buffer, uint8_t device_address) {
  uint8_t result;
  uint16_t amount_transferred = 0;
  device_descriptor* const device = (device_descriptor*)buffer;
  uint8_t r = ch_get_device_descriptor(work_area, device, device_address, &amount_transferred);

  if (r != CH_USB_INT_SUCCESS)
    return r;   //todo try on low speed for device_address 1

  if(device_address == 0) {
    if ((result = ch_set_address(work_area, work_area->ch376.max_device_address, device->bMaxPacketSize0)) != CH_USB_INT_SUCCESS)
      return result;
  }

  buffer += sizeof(device_descriptor);

  for(uint8_t config_index = 0; config_index < device->bNumConfigurations; config_index++) {
    if(device_address == 0) {
      device_address = work_area->ch376.max_device_address;
    }

    config_descriptor* const config = (config_descriptor *)buffer;
    if ((result = ch_get_config_descriptor(work_area, config, config_index, device->bMaxPacketSize0, sizeof(config_descriptor), device_address, &amount_transferred)) != CH_USB_INT_SUCCESS)
      return result;


    const uint8_t total_length = config->wTotalLength;

    if ((result = ch_get_config_descriptor(work_area, config, config_index, device->bMaxPacketSize0, total_length, device_address, &amount_transferred)) != CH_USB_INT_SUCCESS) {
      printf("Err3 (%d,%d)", result, amount_transferred);
      return result;
    }

    buffer += total_length;
  }

  return CH_USB_INT_SUCCESS;
}

void check_device_descriptor(work_area* const work_area, const device_descriptor* const buffer) {
  work_area->ch376.search_device_info.num_configs = buffer->bNumConfigurations;
  work_area->ch376.usb_device_info.max_packet_size = buffer->bMaxPacketSize0;
}

void check_config_descriptor(work_area* work_area, const config_descriptor* buffer) {
  work_area->ch376.search_device_info.num_interfaces = buffer->bNumInterfaces;
  work_area->ch376.usb_device_info.config_id = buffer->bConfigurationvalue;

  work_area->ch376.search_device_info.num_configs--;
}

void check_interface_descriptor(work_area* work_area, const interface_descriptor* buffer) {
  work_area->ch376.search_device_info.num_endpoints = buffer->bNumEndpoints;

  if (work_area->ch376.search_device_info.wanted_class == buffer->bInterfaceClass) {
    uint8_t wanted_sub_class = work_area->ch376.search_device_info.wanted_sub_class;

    if ( wanted_sub_class == 0xff || wanted_sub_class == buffer->bInterfaceSubClass ) {
      uint8_t wanted_protocol = work_area->ch376.search_device_info.wanted_protocol;

      if (wanted_protocol == 0xff || wanted_protocol == buffer->bInterfaceProtocol) {
        work_area->ch376.usb_device_info.interface_id = buffer->bInterfaceNumber;
      }
    }
  }

  work_area->ch376.search_device_info.num_interfaces--;
}

void check_endpoint_descriptor(work_area* const work_area, const endpoint_descriptor* const buffer) {
  if ((buffer->bmAttributes & 0b00000011) == 0b00000010) {
    uint8_t endpointAddress = buffer->bEndpointAddress;
    if (endpointAddress & 0b10000000) {
      work_area->ch376.usb_device_info.data_bulk_in_endpoint_id = endpointAddress & 0b01111111;
    } else {
      work_area->ch376.usb_device_info.data_bulk_out_endpoint_id = endpointAddress & 0b01111111;
    }
  }

  work_area->ch376.search_device_info.num_endpoints--;
}

void parse_usb_descriptors(work_area* const work_area) {
  uint8_t length;
  uint8_t type;
  uint8_t* buffer = work_area->ch376.usb_descriptor;

loop:
  length = buffer[0];
  type = buffer[1];
  switch(type) {
    case 0:
    __asm
  di
  halt
    __endasm;
    case 1:
      check_device_descriptor(work_area, (device_descriptor*)buffer);
      break;

    case 2:
      check_config_descriptor(work_area, (config_descriptor*)buffer);
      break;

    case 4:
      check_interface_descriptor(work_area, (interface_descriptor*)buffer);
      break;

    case 5:
      check_endpoint_descriptor(work_area, (endpoint_descriptor*)buffer);
      break;
  }

  if (work_area->ch376.search_device_info.num_configs != 0) {
    buffer += length;
    goto loop;
  }

  if (work_area->ch376.search_device_info.num_interfaces != 0) {
    buffer += length;
    goto loop;
  }

  if (work_area->ch376.search_device_info.num_endpoints != 0) {
    buffer += length;
    goto loop;
  }
}

bool check_descriptor_mass_storage(work_area* const work_area) {
  work_area->ch376.usb_device_info.interface_id = 0xff;
  work_area->ch376.usb_device_info.config_id = 0xff;
  work_area->ch376.search_device_info.wanted_class = 0x8;
  work_area->ch376.search_device_info.wanted_sub_class = 0x6;
  work_area->ch376.search_device_info.wanted_protocol = 0x50;
  parse_usb_descriptors(work_area);
  return work_area->ch376.usb_device_info.interface_id != 0xff;
}

uint8_t init_storage(work_area * const work_area) {
  uint16_t amount_transferred;
  work_area->ch376.usb_device_info.device_address = work_area->ch376.max_device_address;
  work_area->ch376.storage_device_info = work_area->ch376.usb_device_info;

  return ch_set_configuration(
    work_area,
    work_area->ch376.storage_device_info.config_id,
    work_area->ch376.storage_device_info.max_packet_size,
    work_area->ch376.storage_device_info.device_address,
    &amount_transferred);
}

bool fn_connect(work_area * const work_area) {
  const uint8_t max_device_address = work_area->ch376.max_device_address;
  if (max_device_address != 0)
    return max_device_address;

  work_area->ch376.max_device_address = 1;

  memset(work_area->ch376.usb_descriptor, 0, sizeof(work_area->ch376.usb_descriptor));

//found usb things?
  if (hw_get_descriptors(work_area, work_area->ch376.usb_descriptor, 0) != CH_USB_INT_SUCCESS) {
    printf("USB:             NOT PRESENT\r\n");
    return false;
  }

//found usb storage
  uint8_t result = check_descriptor_mass_storage(work_area);
  printf("USB-STORAGE:     ");

  work_area->ch376.initialised = true;

  if (result) {
    if ((result = init_storage(work_area)) != CH_USB_INT_SUCCESS) {
      printf("Err4 %d\r\n", result);
      result = false;
    } else {
      result = true;
    }
  }

  printf(result ? "PRESENT\r\n" : "NOT PRESENT\r\n");

  return result;
}

/* =============================================================================

  Check if the USB host controller hardware is operational

  Returns:
    1 is operation, 0 if not

============================================================================= */
inline uint8_t ch376_test() {
  setCommand(CH_CMD_CHECK_EXIST);
  CH376_DATA_PORT = (uint8_t)~0x34;
  if (CH376_DATA_PORT != 0x34)
    return false;

  setCommand(CH_CMD_CHECK_EXIST);
  CH376_DATA_PORT = (uint8_t)~0x89;
  return CH376_DATA_PORT == 0x89;
}

uint8_t ch376_probe() {
  for(uint8_t i = 8; i > 0; i--) {
    if (ch376_test())
      return true;

    delay(5);
  }

  return false;
}


/* =============================================================================

  Retrieve the CH376 chip version

  Returns:
    The chip version
============================================================================= */
inline uint8_t ch376_get_firmware_version() {
  setCommand(CH_CMD_GET_IC_VER);
  return CH376_DATA_PORT & 0x1f;
}

/* =============================================================================

  Set the CH376 USB MODE

  Returns:
    0 -> OK, 1 -> ERROR
============================================================================= */
uint8_t ch376_set_usb_mode(const uint8_t mode) __z88dk_fastcall {
  setCommand(CH_CMD_SET_USB_MODE);
  CH376_DATA_PORT = mode;

  uint8_t count = 255;
  while( CH376_DATA_PORT != CH_ST_RET_SUCCESS && --count != 0)
    ;

  return count != 0;
}

inline void hw_configure_nak_retry() {
  setCommand(CH_CMD_SET_RETRY);
  CH376_DATA_PORT = 0x25;
  CH376_DATA_PORT = 0x8F;   // Retry NAKs indefinitely (default)
}

inline uint8_t usb_host_bus_reset() {
  ch376_set_usb_mode(CH_MODE_HOST);
  delay(60/4);

  ch376_set_usb_mode(CH_MODE_HOST_RESET);
  delay(60/2);

  ch376_set_usb_mode(CH_MODE_HOST);
  delay(60/4);

  hw_configure_nak_retry();

  return true;
}

#define target_device_address 0
#define configuration_id 0
#define string_id 0
#define config_descriptor_size (sizeof(config_descriptor))
#define alternate_setting 0
#define packet_filter 0
#define control_interface_id 0

#define report_id 0
#define duration 0x80
#define interface_id 0
#define protocol_id 0

#define hub_descriptor_size 0
#define feature_selector 0
#define port 0
#define value 0

#define storage_interface_id 0

const _usb_descriptor_blocks usb_descriptor_blocks_templates = {
  .cmd_get_device_descriptor   = {0x80, 6, 0, 1, 0, 0, 18},
  .cmd_set_address             = {0x00, 0x05, target_device_address, 0, 0, 0, 0},
  .cmd_set_configuration       = {0x00, 0x09, configuration_id, 0, 0, 0, 0},
  .cmd_get_string              = {0x80, 6, string_id, 3, 0, 0, 255},
  .cmd_get_config_descriptor   = {0x80, 6, configuration_id, 2, 0, 0, config_descriptor_size},
  .cmd_set_interface           = {0x01, 11, alternate_setting, 0, interface_id, 0, 0},
  .cmd_set_packet_filter       = {0b00100001, 0x43, packet_filter, 0, control_interface_id, 0, 0},
  .cmd_set_idle                = {0x21, 0x0a, report_id, duration, interface_id, 0, 0},
  .cmd_set_protocol            = {0x21, 0x0b, protocol_id, 0, interface_id, 0, 0},
  .reserved                    = {{0}},
  .cmd_get_hub_descriptor      = {0b10100000, 6, 0, 0x29, 0, 0, hub_descriptor_size},
  .cmd_set_hub_port_feature    = {0b00100011, 3, feature_selector, 0, port, value, 0},
  .cmd_get_hub_port_status     = {0b10100011, 0, 0, 0, port, 0, 4, 0},
  .cmd_get_max_luns            = {0b10100001, 0b11111110, 0, 0, storage_interface_id, 0, 1},
  .cmd_mass_storage_reset      = {0b00100001, 0b11111111, 0, 0, storage_interface_id, 0, 0}
};

void initialise_work_area(work_area * const p) {
  p->ch376.max_device_address = 0;
  memcpy(&p->ch376.usb_descriptor_blocks, &usb_descriptor_blocks_templates, sizeof(usb_descriptor_blocks_templates));
}

uint8_t usb_host_init() {
  work_area * const p = get_work_area();
  printf("usb_host_init %p\r\n", p);

  initialise_work_area(p);

  ch376_reset();

  if (!ch376_probe()) {
    printf("CH376:           NOT PRESENT\r\n");
    return false;
  }

  p->ch376.present = true;
  const uint8_t ver = ch376_get_firmware_version();
  printf("CH376:           PRESENT (VER %d)\r\n", ver);

  usb_host_bus_reset();
  delay(10);

  if (!fn_connect(p))
    return false;

  uint16_t amount_transferred;
  uint8_t result;
  if ((result = scsi_max_luns(p, &amount_transferred)) != CH_USB_INT_SUCCESS) {
    printf("Err-scsi_max_luns %d\r\n", result);
    return false;
  }

  return true;
}