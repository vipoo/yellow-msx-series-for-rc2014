#include "arguments.h"
#include "print.h"
#include <delay.h>
#include <extbio.h>
#include <fossil.h>
#include <msxdos.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <system_vars.h>

#define ONE_SECOND (VDP_FREQUENCY * 1.1)

bool fossil_rs_read_line(unsigned char *pBuffer, const uint8_t maxLength) {

  uint8_t      length = 0;
  unsigned int timeout = 65000;

  while (length < maxLength && timeout != 0) {
    if (fossil_rs_in_stat() != 0) {
      timeout = 65000;
      const unsigned char t = fossil_rs_in();
      if (t >= 32 && t < 128) {
        *pBuffer++ = t;
        length++;
      }

      if (t == '\n')
        break;
    } else
      timeout--;
  }

  *pBuffer = 0;

  return timeout == 0;
}

#define MAX_TIME_STRING_LEN 50
unsigned char timeString[MAX_TIME_STRING_LEN + 1];

/*
1. Establish fossil serial connection
2. Issue +++ to enter command mode
3. Issue command
4. Write out response

*/
void main(const int argc, const unsigned char **argv) {
  (void)argc;
  (void)argv;
  if (!fossil_link()) {
    extbio_fossil_install();

    if (!fossil_link()) {
      print_str("Fossil driver not found\r\n");
      exit(1);
    }
  }

  process_cli_arguments(argv, argc);

  uint16_t actual_baud_rate = fossil_set_baud(7); // 19200
  fossil_set_protocol(7);                         // 8N1
  fossil_init();

  if (subCommand == SUB_COMMAND_HANGUP) {
    delay(ONE_SECOND);
    fossil_rs_string("+++");
    delay(ONE_SECOND);
    fossil_rs_string("\r\nATH\r\n"); // hang up
    goto done;
  }

  fossil_rs_string("\r\nATE0\r\n"); // echo off

  if (subCommand == SUB_COMMAND_TIME_SYNC) {
    fossil_rs_flush();
    fossil_rs_string("\r\nAT+time?\r\n");
    if (fossil_rs_read_line(timeString, MAX_TIME_STRING_LEN)) {
      print_str("Error getting time\r\n");
      goto done;
    }

    if (strlen(timeString) != 24) {
      print_str("Invalid time string received ");
      print_str(timeString);
      print_str("\r\n");
      goto done;
    }

    const int year = atoi(timeString);
    const int month = atoi(timeString + 5);
    const int day = atoi(timeString + 8);
    const int hour = atoi(timeString + 11);
    const int min = atoi(timeString + 14);
    const int sec = atoi(timeString + 17);

    uint8_t currentHour;
    uint8_t currentMinute;
    uint8_t currentSecond;
    msxdosGetTime(&currentHour, &currentMinute, &currentSecond);

    msxdosSetDate(year, month, day);
    msxdosSetTime(hour, min, sec, 0);

    int32_t t1 = (((int32_t)currentHour) * 60 * 60) + (int32_t)currentMinute * 60 + (int32_t)currentSecond;
    int32_t t2 = ((int32_t)hour * 60 * 60) + (int32_t)min * 60 + (int32_t)sec;

    printf("Time: %04d:%02d:%02d %02d:%02d:%02d\r\n", year, month, day, hour, min, sec);
    printf("Second drift: %d\r\n", (int)(t2 - t1));
  }

done:
  fossil_deinit();
}
