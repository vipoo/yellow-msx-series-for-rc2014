#ifndef __ARGUMENTS
#define __ARGUMENTS

#include <stdbool.h>
#include <stdio.h>

extern const char *p_file_name;
extern uint8_t     receive_file;
extern uint8_t     send_file;
extern uint8_t     port_number;

extern void process_cli_arguments(const uint16_t argc, char **const argv);

#endif
