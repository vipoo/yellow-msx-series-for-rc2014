
	include	embinc.asm

	STRUCT ST_WRKAREA
RD_CNT		DS	1	; COUNT OF SECTORS TO BE READ
INDX_LW		DS	1	; SECTOR TO BE READ
INDX_HI		DS	1	; SECTOR TO BE READ 	; MUST BE LESS THAN 65536
DEST_LW		DS	1	; SECTOR DESTINATION ADDRESS (LOW)
DEST_HI		DS	1	; (HIGH)
RD_CND_RQ	DS	1	; NUMBER OF SECTORS REQUESTED
PRESENT		DS	1	; BIT FIELD FOR DETECTED DEVICES (BIT 0 -> COMPACTFLASH/IDE, BIT 1-> MSX-MUSIC NOR FLASH)
USB		DS	0	; _size_of_usb_state

	ENDS

DRIVER_ASM_END			EQU		$4D00
_usb_host_init:			EQU		DRIVER_ASM_END	; entry point within cextens section
_usb_dev_info:			EQU  	        DRIVER_ASM_END+3
_usb_lun_info:			EQU		DRIVER_ASM_END+6
_usb_dev_status:		EQU		DRIVER_ASM_END+9
_usb_dev_read:			EQU		DRIVER_ASM_END+12
_usb_dev_write:			EQU		DRIVER_ASM_END+15
_fn_enum:			EQU		DRIVER_ASM_END+18
; _drv_direct4:			EQU		DRIVER_ASM_END+21
_device_mapping:		EQU		DRIVER_ASM_END+24
_convert_and_print_disk_size:	EQU		DRIVER_ASM_END+27
extbio_rc2014:			EQU		DRIVER_ASM_END+30
_drv_direct1:			EQU		DRIVER_ASM_END+33
_drv_timi:			EQU		DRIVER_ASM_END+36
