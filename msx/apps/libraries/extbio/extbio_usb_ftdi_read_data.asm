	SECTION	CODE
	include	"msx.inc"

;
; extern usb_error ftdi_read_data(device_config_ftdi *const ftdi, uint8_t *buf, uint16_t *const size) __sdcccall(1);
;
	PUBLIC	_ftdi_read_data
	; TODO THGIS IS BORKEN
_ftdi_read_data:
	PUSH	IX
	LD	DE, EXTBIO_RC2014 << 8 | EXTBIO_RC2014_USB_FTDI_FN
	LD	C, EXTBIO_RC2014_USB_FTDI_READ_DATA_SUB_FN
	LD	HL, 4
	ADD	HL, SP						; ARGS @ HL
	CALL	EXTBIO						; RETURN HL
	POP	IX
	LD HL, -1
	RET
