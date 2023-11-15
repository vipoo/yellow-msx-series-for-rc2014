	include	"msx.inc"

	PUBLIC	_extbio
	PUBLIC	_extbio_next

	EXTERN	_ftdi_read_data
	EXTERN	_ftdi_set_baudrate
	EXTERN	_ftdi_set_line_property2
	EXTERN	_ftdi_purge_rx_buffer
	EXTERN	_ftdi_purge_tx_buffer

	EXTERN	_serial_get_driver_name
	EXTERN	_serial_set_baudrate
	EXTERN	_serial_set_protocol
	EXTERN	_serial_purge_buffers
	EXTERN	_serial_read
	EXTERN	_serial_demand_read
	EXTERN	_serial_write
	EXTERN	_serial_set_flowctrl
	EXTERN	_serial_set_dtr_rts

	SECTION	CODE

_extbio:
	PUSH	AF
	LD	A, D

	CP	EXTBIO_RC2014
	JR	Z, handle_extbio

	POP	AF

EXBIO_EXIT:
	DB	$C3	; JP opcode
_extbio_next:
	DW	0

handle_extbio:
	EI
	POP	AF
	LD	A, E
	CP	EXTBIO_RC2014_USB_FTDI_FN
	JP	Z, EXTBIO_RC2014_USB_FTDI

	CP	EXTBIO_RC2014_SERIAL_FN
	JR	NZ, EXBIO_EXIT

EXTBIO_RC2014_SERIAL:
	LD	A, C
	CP	EXTBIO_RC2014_SERIAL_GET_AVAILABLE_PORTS_FN
	JR	Z, EXTBIO_RC2014_SERIAL_GET_AVAILABLE_PORTS

	CP	EXTBIO_RC2014_SERIAL_GET_DRIVER_NAME_SUB_FN
	JR	Z, EXTBIO_RC2014_SERIAL_GET_DRIVER_NAME_SUB

	CP	EXTBIO_RC2014_SERIAL_SET_BAUDRATE_SUB_FN
	JR	Z, EXTBIO_RC2014_SERIAL_SET_BAUDRATE_SUB

	CP	EXTBIO_RC2014_SERIAL_SET_PROTOCOL_SUB_FN
	JR	Z, EXTBIO_RC2014_SERIAL_SET_PROTOCOL_SUB

	CP	EXTBIO_RC2014_SERIAL_READ_SUB_FN
	JR	Z, EXTBIO_RC2014_SERIAL_READ_SUB

	CP	EXTBIO_RC2014_SERIAL_DEMAND_READ_SUB_FN
	JR	Z, EXTBIO_RC2014_SERIAL_DEMAND_READ_SUB

	CP	EXTBIO_RC2014_SERIAL_WRITE_SUB_FN
	JR	Z, EXTBIO_RC2014_SERIAL_SEND_SUB

	CP	EXTBIO_RC2014_SERIAL_PURGE_BUFFERS_SUB_FN
	JP	Z, EXTBIO_RC2014_SERIAL_PURGE_BUFFERS_SUB

	CP	EXTBIO_RC2014_SERIAL_SET_FLOWCTRL_SUB_FN
	JP	Z, EXTBIO_RC2014_SERIAL_SET_FLOWCTRL_SUB

	CP	EXTBIO_RC2014_SERIAL_SET_DTR_RTS_SUB_FN
	JP	Z, EXTBIO_RC2014_SERIAL_SET_DTR_RTS_SUB

	JP	EXTBIO_UNKNOWN_SUB

EXTBIO_RC2014_SERIAL_GET_AVAILABLE_PORTS:
	INC	(HL)
	LD	HL, 0
	RET


EXTBIO_RC2014_SERIAL_GET_DRIVER_NAME_SUB:
	MARSHAL 3, _serial_get_driver_name

EXTBIO_RC2014_SERIAL_RET_OR_NEXT:
	LD	A, L			; MATCHED OUR DRIVER NUMBER?
	OR	A
	RET	Z			; THEN RETURN
	JR	EXBIO_EXIT		; OTHERWISE CONTINUE WITH NEXT EXBIO HANDLER

EXTBIO_RC2014_SERIAL_SET_BAUDRATE_SUB:
	MARSHAL 5, _serial_set_baudrate
	JR	EXTBIO_RC2014_SERIAL_RET_OR_NEXT:

EXTBIO_RC2014_SERIAL_SET_PROTOCOL_SUB:
	MARSHAL 3, _serial_set_protocol
	JR	EXTBIO_RC2014_SERIAL_RET_OR_NEXT:

EXTBIO_RC2014_SERIAL_READ_SUB:
	MARSHAL 5, _serial_read
	JR	EXTBIO_RC2014_SERIAL_RET_OR_NEXT:

EXTBIO_RC2014_SERIAL_DEMAND_READ_SUB:
	MARSHAL 7, _serial_demand_read
	JR	EXTBIO_RC2014_SERIAL_RET_OR_NEXT:

EXTBIO_RC2014_SERIAL_SEND_SUB:
	MARSHAL 5, _serial_write
	JR	EXTBIO_RC2014_SERIAL_RET_OR_NEXT:

EXTBIO_RC2014_SERIAL_PURGE_BUFFERS_SUB:
	CALL	_serial_purge_buffers
	JR	EXTBIO_RC2014_SERIAL_RET_OR_NEXT:

EXTBIO_RC2014_SERIAL_SET_FLOWCTRL_SUB:
	MARSHAL 2, _serial_set_flowctrl
	JR	EXTBIO_RC2014_SERIAL_RET_OR_NEXT:

EXTBIO_RC2014_SERIAL_SET_DTR_RTS_SUB:
	MARSHAL 4, _serial_set_dtr_rts
	JP	EXTBIO_RC2014_SERIAL_RET_OR_NEXT:

EXTBIO_RC2014_USB_FTDI:
	LD	A, C
	CP	EXTBIO_RC2014_USB_FTDI_READ_DATA_SUB_FN
	JR	Z, EXTBIO_RC2014_USB_FTDI_READ_DATA_SUB

	CP	EXTBIO_RC2014_USB_FTDI_SET_BAUDRATE_SUB_FN
	JR	Z, EXTBIO_RC2014_USB_FTDI_SET_BAUDRATE_SUB

	CP	EXTBIO_RC2014_USB_FTDI_SET_LINE_PROPERTY2_SUB_FN
	JR	Z, EXTBIO_RC2014_USB_FTDI_SET_LINE_PROPERTY2_SUB

	CP	EXTBIO_RC2014_USB_FTDI_PURGE_RX_BUFFER_SUB_FN
	JR	Z, EXTBIO_RC2014_USB_FTDI_PURGE_RX_BUFFER_SUB

	CP	EXTBIO_RC2014_USB_FTDI_PURGE_TX_BUFFER_SUB_FN
	JR	Z, EXTBIO_RC2014_USB_FTDI_PURGE_TX_BUFFER_SUB

EXTBIO_UNKNOWN_SUB:
	LD	HL, -1	; UNKNOWN SUB FUNCTION
	RET

EXTBIO_RC2014_USB_FTDI_READ_DATA_SUB:
	MARSHAL 6, _ftdi_read_data
	RET

EXTBIO_RC2014_USB_FTDI_SET_BAUDRATE_SUB:
	MARSHAL 6, _ftdi_set_baudrate
	RET

EXTBIO_RC2014_USB_FTDI_SET_LINE_PROPERTY2_SUB:
	MARSHAL 4, _ftdi_set_line_property2
	RET

EXTBIO_RC2014_USB_FTDI_PURGE_RX_BUFFER_SUB:
	MARSHAL 2, _ftdi_purge_rx_buffer
	RET

EXTBIO_RC2014_USB_FTDI_PURGE_TX_BUFFER_SUB:
	MARSHAL 2, _ftdi_purge_tx_buffer
	RET


	SECTION	DATA

