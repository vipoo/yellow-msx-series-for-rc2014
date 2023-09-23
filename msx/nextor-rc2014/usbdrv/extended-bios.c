#include <stdbool.h>
#include <stdlib.h>

#include "print.h"

typedef struct {
  uint8_t  a;
  uint8_t  f;
  uint16_t bc;
  uint16_t de;
  uint16_t hl;
} registers;

// __z88dk_fastcall
uint8_t fn_enum() {
  print_string("fn_enum\r\n");
  return 1;
}