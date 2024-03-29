#include "class_ufi.h"

void log_ufi_format_capacities_response(const ufi_format_capacities_response const *response) __sdcccall(1) {

  printf("Length: %d\r\n", response->capacity_list_length);

  const uint8_t count = response->capacity_list_length / 8;

  for (uint8_t i = 0; i < count; i++) {
    const uint8_t  code        = response->descriptors[i].descriptor_code;
    const uint32_t sector_size = (uint32_t)response->descriptors[i].block_size[0] << 16 |
                                 (uint16_t)response->descriptors[i].block_size[1] << 8 | response->descriptors[i].block_size[2];

    printf("  CODE: %02X, SEC_SIZ: %ld, NUM_OF_SEC: %ld\r\n", code, sector_size,
           convert_from_msb_first(response->descriptors[i].number_of_blocks));
  }
}
