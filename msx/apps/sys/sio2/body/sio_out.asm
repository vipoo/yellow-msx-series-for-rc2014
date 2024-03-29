	include	"msx.inc"
	INCLUDE	"../sio.inc"

	SECTION	CODE
	EXTERN	RS_SIO_B_CMD
	PUBLIC	_sio_out

_sio_out:
	LD	BC, RC_SIOB_DAT << 8 | RC_SIOB_CMD			; C => CMD, B => DAT PORTS
	XOR	A				; SELECT READ REGISTER 0
	DI
	OUT	(C), A

segment1_rs_out_wait:
	IN	A, (C)				; GET REGISTER 0 VALUE
	AND	RS_TRANSMIT_PENDING_MASK	; IS TRANSMIT PENDING?
	JR	Z, segment1_rs_out_wait		; YES, THEN WAIT UNTIL TRANSMIT COMPLETED
	LD	C, B				; LOAD DAT PORT INTO C
	OUT	(C), L				; TRANSMIT BYTE
	EI
	RET

