#ifndef __USB_ENUMERATE_HUB
#define __USB_ENUMERATE_HUB

#include "usb-enumerate.h"
#include "work-area.h"

extern void      parse_endpoint_hub(const endpoint_descriptor const *pEndpoint) __z88dk_fastcall;
extern usb_error configure_usb_hub(_working *const working) __z88dk_fastcall;

#endif
