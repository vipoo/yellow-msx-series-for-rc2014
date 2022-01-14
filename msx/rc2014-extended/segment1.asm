
fossil_initialise:
	ld	a, 1				; allocate a system page
	ld	b, 0				; main memory mapper
	CALL	MEMMAP_ALLOC

	jr	NC, allocation_ok

	; what do we do here?
	DI
	HALT

allocation_ok:
	LD	(RS_P1_SEG), a
	push_page_1

	EI

	ld	hl, segment1_start
	ld	de, $4000
	ld	bc, segment1_length
	ldir

	LD	HL, RS232_INIT_TABLE
	PUSH	HL
	POP	IX		; IX IS FOSSIL'S INIT TABLE IN PAGE 3
	CALL	CFG_RS232_SETTINGS
	CALL	SIO_INIT
	XOR	A
	LD	(RS_FLAGS), A

	; INSTALL INTERRUPT HOOK - IF NOT ALREADY DONE

	LD	DE, RS_OLDINT		; COPY HOOK FUNCTION FROM H_KEYI TO RS_OLDINT
	LD	A, (DE)
	OR	A
	JR	NZ, fossil_int_handler_installed

	LD	HL, H_KEYI
	LD	BC, 5
	LDIR				; COPY THE OLD INT HOOK

	; INSTALL INTERRUPT HOOK TO SIO_INT
	LD	A, $C3                  ; JUMP
	LD	DE, (WORK)
	LD	HL, @SIO_INT             ; SET TO JUMP TO SIO_INIT IN PAGE 3 RAM
	ADD	HL, DE
	DI
	LD	(H_KEYI), A             ; SET JMP INSTRUCTION
	LD	(H_KEYI+1), HL          ; SET NEW INTERRUPT ENTRY POINT

fossil_int_handler_installed:
	LD	HL, SIO_RCVBUF
	LD	C, SIO_BUFSZ
	LD	E, 4
	XOR	A
	LD	(RS_DATCNT), A
	LD	(RS_FLAGS), A

	LD	(RS_FCB), HL
	LD      A, C
	LD      (RS_IQLN),A

	LD	D, H		; FIRST 2 WORDS OF BUFFER AT THE HEAD AND TAIL PTRS
	LD	E, L		; THEY NEED TO BE INITIALISED TO START OF ACTUAL DATA BUFFER
	EX	DE, HL		; WHICH IS JUST AFTER THESE 4 BYTES
	INC	DE
	INC	DE
	INC	DE
	INC	DE
	LD	(HL), E		; LOAD FIRST 2 WORDS IN BUFFER TO POINT TO ADDRESS
	INC	HL		; AFTER FIRST 2 WORDS
	LD	(HL), D
	INC	HL
	LD	(HL), E
	INC	HL
	LD	(HL), D
	INC	HL

	EX	DE, HL
	LD	B, 0
	ADD	HL, BC
	LD	(RS_BUFEND), HL

	LD      HL, RS_FLAGS
	SET     3, (HL)			; SET RS232 OPEN FLAG
	SET	1, (HL)			; SET RTS ON FLAG
	SIO_CHIP_RTS	CMD_CH, SIO_RTSON

	pop_page_1
	EI
	RET

fossil_deinit:
	DI

	XOR	A				; MARK AS CLOSED AND RTS OFF
	LD	(RS_FLAGS), A
	SIO_CHIP_RTS	CMD_CH, SIO_RTSOFF

	LD	A, (RS_P1_SEG)
	LD	B, 0				; main memory mapper
	JP	MEMMAP_FREE

fossil_set_baud:
	push_page_1

	LD	A, L
	CP	H
	JR	NC, .SKIP1
	LD	A, H				; H IS LARGER, SO USE THAT AS BASIS

.SKIP1:
	CP	5
	JR	NC, .SKIP2			; LESS THAN 5
	LD	A, 5				; SET TO 5
.SKIP2:
	CP 	7
	JR	C, .SKIP3			; GREATER THAN 7
	LD	A, 7				; SET TO 7

.SKIP3:
	LD	HL, FS_RSC_RCV_BAUD
	CP	7
	JR	NZ, .SKIP4
	LD	HL, BAUD_HIGH
	JR	SET_BAUD_EXIT

.SKIP4:
	CP	6
	JR	NZ, SKIP5
	LD	HL, BAUD_MID
	JR	SET_BAUD_EXIT

SKIP5:
	LD	HL, BAUD_LOW

SET_BAUD_EXIT:
	LD	(FS_RSC_RCV_BAUD), HL
	LD	(FS_RSC_SND_BAUD), HL

	ld	c, a				; store the actual selected baud rates
	pop_page_1

	ld	l, c				; return the actual selected baud rates
	ld	h, c
	RET


segment1_start:
	PHASE	$4000

segment1_rs_in:
	LD	D, SIO_BUFSZ/4		; D IS QRT MARK OF BUFFER SIZE
	LD	HL, SIO_RCVBUF
	DI				; AVOID COLLISION WITH INT HANDLER
	LD	A, (RS_DATCNT)		; GET COUNT
	DEC	A			; DECREMENT COUNT
	LD	(RS_DATCNT), A		; SAVE UPDATED COUNT
	CP	D			; BUFFER LOW THRESHOLD
	JR	NZ, SIO_IN1		; IF NOT, BYPASS SETTING RTS

	SIO_CHIP_RTS	CMD_CH, SIO_RTSON
	LD	A, (RS_FLAGS)
	SET	1, A
	LD	(RS_FLAGS), A

SIO_IN1:
	INC	HL
	INC	HL			; HL NOW HAS ADR OF TAIL PTR
	PUSH	HL			; SAVE ADR OF TAIL PTR
	LD	A, (HL)			; DEREFERENCE HL
	INC	HL
	LD	H, (HL)
	LD	L, A			; HL IS NOW ACTUAL TAIL PTR
	LD	C, (HL)			; C := CHAR TO BE RETURNED
	INC	HL			; BUMP TAIL PTR
	POP	DE			; RECOVER ADR OF TAIL PTR
	LD	A, (RS_BUFEND)		; GET BUFEND PTR LOW BYTE
	CP	L			; ARE WE AT BUFF END?
	JR	NZ, SIO_IN2		; IF NOT, BYPASS
	LD	H, D			; SET HL TO
	LD	L, E			; ... TAIL PTR ADR
	INC	HL			; BUMP PAST TAIL PTR
	INC	HL			; ... SO HL NOW HAS ADR OF ACTUAL BUFFER START
SIO_IN2:
	EX	DE, HL			; DE := TAIL PTR VAL, HL := ADR OF TAIL PTR
	LD	(HL), E			; SAVE UPDATED TAIL PTR
	INC	HL
	LD	(HL), D
	EI				; INTERRUPTS OK AGAIN
	RET				; char returned in C

segment1_rs_out:
	LD	B, A				; SAVE CHAR TO BE TRANSMITTED
segment1_rs_out_wait:
	XOR	A				; SELECT READ REGISTER 0
	DI
	OUT	(CMD_CH), A
	IN	A, (CMD_CH)			; GET REGISTER 0 VALUE
	EI
	AND	RS_TRANSMIT_PENDING_MASK	; IS TRANSMIT PENDING?
	JR	Z, segment1_rs_out_wait		; YES, THEN WAIT UNTIL TRANSMIT COMPLETED
	LD	A, B
	SIO_OUT_A				; LOAD BYTE TO TRANSMIT
	OR	$FF				; RETURN NZ TO INDICATE NO TIMEOUT
	RET


segment1_sio_interrupt:
	LD	A, (RS_IQLN)
	EXX
	LD	C, A			; BUFFER FULL COUNT IN C
	LD	HL, RS_DATCNT
	SUB	5			; 5 FROM BUF SIZE IS HIGH WATER MARK
	JR 	Z, SIO_ZERO_HI_MARK
	JR 	NC, SIO_5_MINUS_HI_MARK
SIO_ZERO_HI_MARK:
	LD	A, 1
SIO_5_MINUS_HI_MARK:
	LD	D, A
	EXX

	LD	HL, RS_FLAGS		; IS OPENED?
	BIT	3, (HL)			; FLAG PORT OPEN?
	JR	Z, SIO_INT_ABORT

	LD	A, (RS_BUFEND)		; GET BUFEND PTR LOW BYTE
	LD	C, A

	LD	HL, (RS_FCB)
	LD	D, H			; SAVE ADR OF HEAD PTR
	LD	E, L
	LD	A, (HL)			; DEREFERENCE HL
	INC	HL
	LD	H, (HL)
	LD	L, A			; HL IS NOW ACTUAL HEAD PTR

	; HL IS HEAD - ADDR OF NEXT BYTE TO BE WRITTEN IN BUFFER
	; DE IS &HEAD - ADDR STORE FOR HEAD PTR

	; RECEIVE CHARACTER INTO BUFFER
SIO_INTRCV1:
	IN	A, (DAT_CH)		; READ PORT
	LD	B, A			; SAVE BYTE READ

	EXX
	LD	A, (HL)			; GET COUNT
	CP	C			; COMPARE TO BUFFER SIZE
	JR	Z, SIO_INTRCV4		; BAIL OUT IF BUFFER FULL, RCV BYTE DISCARDED

	INC	A			; INCREMENT THE COUNT
	LD	(HL), A			; AND SAVE IT
	CP	D			; HIT HIGH WATER MARK?
	EXX
	JR	NZ, SIO_INTRCV2		; IF NOT, BYPASS CLEARING RTS

	SIO_CHIP_RTS	CMD_CH, SIO_RTSOFF
	LD	A, (RS_FLAGS)		; SET BIT FLAG FOR RTS OFF
	RES	1, A
	LD	(RS_FLAGS), A

SIO_INTRCV2:
	LD	(HL), B			; SAVE CHARACTER RECEIVED IN BUFFER AT HEAD
	INC	HL			; BUMP HEAD POINTER

	LD	A, C			; GET BUFEND PTR LOW BYTE
	CP	L			; ARE WE AT BUFF END?
	JR	NZ, SIO_INTRCV3		; IF NOT, BYPASS
	LD	H, D			; SET HL TO
	LD	L, E			; ... HEAD PTR ADR
	INC	HL			; BUMP PAST HEAD PTR
	INC	HL
	INC	HL
	INC	HL			; ... SO HL NOW HAS ADR OF ACTUAL BUFFER START

SIO_INTRCV3:
	; CHECK FOR MORE PENDING...
	XOR	A
	OUT	(CMD_CH), A		; READ REGISTER 0
	IN	A, (CMD_CH)		;
	RRA				; READY BIT TO CF
	JR	C, SIO_INTRCV1		; IF SET, DO SOME MORE

	LD	A, (RS_FLAGS)
	BIT	1, A
	JR	Z, SIO_UPDATE_HEAD_PTR		; ABORT NOW IF RTS IS OFF

	; TEST FOR NEW BYTES FOR A SHORT PERIOD OF TIME
	LD	B, 80
SIO_MORE:
	IN	A, (CMD_CH)		;
	RRA				; READY BIT TO CF
	JR	C, SIO_INTRCV1		; IF SET, DO SOME MORE
	DJNZ	SIO_MORE

COMMAND_0	EQU	0
COMMAND_1	EQU	0x08
COMMAND_2	EQU	0x10
COMMAND_3	EQU	0x18
COMMAND_4	EQU	0x20
COMMAND_5	EQU	0x28
COMMAND_6	EQU	0x30
COMMAND_7	EQU	0x38

SIO_UPDATE_HEAD_PTR:
	EX	DE, HL			; DE := HEAD PTR VAL, HL := ADR OF HEAD PTR
	LD	(HL), E			; SAVE UPDATED HEAD PTR
	INC	HL
	LD	(HL), D

SIO_INTRCV4:
	; NOT SURE WHY NEED TO RESET CHANNEL A
	; SOMETHING NOT QUITE RIGHT
	LD	A, 0
	OUT	(SIO0A_CMD), A
	LD	A, COMMAND_3
	OUT	(SIO0A_CMD), A
	RET

SIO_INT_ABORT:
	IN	A, (DAT_CH)
	; PORT NOT OPENED, SO IGNORE BYTE, RESET RTS AND EXIT
	SIO_CHIP_RTS	CMD_CH, SIO_RTSOFF
	RES	1, (HL)			; SET BIT FLAG FOR RTS OFF
	JR	SIO_INTRCV4


RS232_INIT_TABLE:
FS_RSC_CHAR_LEN:	DB	'8'		; Character length '5'-'8'
FS_RSC_PARITY:		DB	'N'		; Parity 'E','O','I','N'
FS_RSC_STOP_BITS:	DB	'1'		; Stop bits '1','2','3'
FS_RSC_XON_XOFF:	DB	'N'		; XON/XOFF controll 'X','N'
FS_RSC_CTR_RTS:		DB	'H'		; CTR-RTS hand shake 'H','N'
FS_RSC_AUTO_RCV_LF:	DB	'N'		; Auto LF for receive 'A','N'
FS_RSC_AUTO_SND_LF:	DB	'N'		; Auto LF for send 'A','N'
FS_RSC_SI_SO_CTRL:	DB	'N'		; SI/SO control 'S','N'
FS_RSC_RCV_BAUD:	DW	19200		; Receiver baud rate  50-19200 ; MARK MAKE BAUD RATE CONFIG
FS_RSC_SND_BAUD:	DW	19200		; Transmitter baud rate 50-19200 ; MARK MAKE BAUD RATE CONFIG
FS_RSC_TIMEOUT_CNT:	DB	0		; Time out counter 0-255

SIO_RCVBUF:
SIO_HD:			DW	SIO_BUF		; BUFFER HEAD POINTER
SIO_TL:			DW	SIO_BUF		; BUFFER TAIL POINTER
SIO_BUF:		DS	SIO_BUFSZ, $00	; RECEIVE RING BUFFER

	DEPHASE
segment1_end:

segment1_length		EQU	segment1_end-segment1_start
