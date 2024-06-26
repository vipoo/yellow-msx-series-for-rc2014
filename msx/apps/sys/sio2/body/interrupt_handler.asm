	include "msx.inc"
	include "../sio.inc"

	PUBLIC	_keyi
	PUBLIC	_keyi_next

	EXTERN	_sio_data_count
	EXTERN	_sio_buf_head
	EXTERN	_sio_buf
	EXTERN	_sio_flags

_keyi:
sio_interrupt:
	DI
	LD	C, RC_SIOB_CMD
	XOR	A			; READ REGISTER 0
	OUT	(C), A
	IN	A, (C)
	RRA				; ISOLATE RECEIVE READY BIT
	JR	NC, SIO_INT_NEXT	; NOTHING AVAILABLE ON CURRENT CHANNEL

	EXX
	LD	HL, _sio_data_count
	LD	D, 48			; BUFFER HIGH MARK
	EXX

	LD	DE, RC_SIOB_DAT << 8 | RC_SIOB_CMD		; E => CMD, D => DAT

	LD	HL, (_sio_buf_head)	; HL IS HEAD - ADDR OF NEXT BYTE TO BE WRITTEN IN BUFFER

	; RECEIVE CHARACTER INTO BUFFER
SIO_INTRCV1:
	LD	C, D			; DAT PORT
	IN	B, (C)			; READ PORT

	EXX
	LD	A, (HL)			; GET COUNT
	INC	A			; INCREMENT THE COUNT
	CP	SIO_BUFSZ
	JR	Z, SIO_INTRCV4		; BAIL OUT IF BUFFER FULL, RCV BYTE DISCARDED

	LD	(HL), A			; AND SAVE IT
	CP	D			; HIT HIGH WATER MARK?
	EXX
	JR	NZ, SIO_INTRCV2		; IF NOT, BYPASS CLEARING RTS

	LD	C, E			; CMD PORT
	SIO_CHIP_RTS_C	SIO_RTSOFF
	LD	A, (_sio_flags)		; SET BIT FLAG FOR RTS OFF
	AND	11111101B		; RES	1, A
	LD	(_sio_flags), A

SIO_INTRCV2:
	LD	(HL), B			; SAVE CHARACTER RECEIVED IN BUFFER AT HEAD
	INC	L			; BUMP HEAD POINTER
	LD	A, SIO_BUFSZ-1		; MASK TO BUF SIZE -1
	AND	L
	OR	_sio_buf & (256-SIO_BUFSZ)
	LD	L, A

SIO_INTRCV3:
	; CHECK FOR MORE PENDING...
	XOR	A
	LD	C, E			; CMD PORT
	OUT	(C), A			; READ REGISTER 0
	IN	A, (C)
	RRA				; READY BIT TO CF
	JP	C, SIO_INTRCV1		; IF SET, DO SOME MORE

	LD	A, (_sio_flags)
	AND	00000010B		; BIT 1, A
	JR	Z, SIO_UPDATE_HEAD_PTR	; ABORT NOW IF RTS IS OFF

	; TEST FOR NEW BYTES FOR A SHORT PERIOD OF TIME
	LD	B, 95
SIO_MORE:
	IN	A, (C)			; C IS CMD PORT
	RRA				; READY BIT TO CF
	JR	C, SIO_INTRCV1		; IF SET, DO SOME MORE
	DJNZ	SIO_MORE

COMMAND_RETURN_FROM_INT	EQU	0x38

SIO_UPDATE_HEAD_PTR:
	LD	(_sio_buf_head), HL

SIO_INTRCV4:
	; LATCH OFF SIO/2 INTERRUPT STATE
	LD	C, RC_SIOA_CMD
	XOR	A
	OUT	(C), A
	LD	A, COMMAND_RETURN_FROM_INT
	OUT	(C), A

	RET

SIO_INT_NEXT:
	DB	$C3	; JP opcode
_keyi_next:
	DW	0
