
;-----------------------------------------------------------------------
;
;       ALLOC ALLOCATES SPECIFIED AMOUNT OF MEMORY DOWNWARD FROM CURRENT
;       HIMEM
;
; INPUTS:
;       HL = MEMORY SIZE TO ALLOCATE
; OUTPUTS:
;       IF SUCCESSFUL, CARRY FLAG RESET, HL POINTS TO THE BEGINNING OF ALLOCATED AREA
;       OTHERWISE, CARRY FLAG SET, ALLOCATION NOT DONE.
;

ALLOC:
	LD	A, L		;IS REQUESTED SIZE 0?
	OR	H
	RET	Z		;YES, ALLOCATION ALWAYS SUCCEEDS
	EX	DE, HL		;CALCULATE -SIZE
	LD	HL, 0
	SBC	HL, DE
	LD	C, L		;REMEMBER SPECIFIED SIZE
	LD	B, H
	ADD	HL, SP		;[HL] = [SP] - SIZE
	CCF
	RET	C		;SIZE TOO BIG

	LD	A, H
	CP	0C2H        	;HIGH(BOOTAD)
	RET	C		;NO ROOM LEFT

	LD	DE, (BOTTOM)	;GET CURRENT RAM BOTTOM
	SBC	HL, DE		;GET MEMORY SPACE LEFT AFTER ALLOCATION
	RET	C		;NO SPACE LEFT
	LD	A, H		;DO WE STILL HAVE BREATHING ROOM?
	CP	2              	;HIGH(512)
	RET	C		;NO,  NOT ENOUGH SPACE LEFT
;
;       NOW,  REQUESTED SIZE IS LEGAL,  BEGIN ALLOCATION
;
	PUSH	BC		;SAVE -SIZE
	LD	HL, 0
	ADD	HL, SP		;GET CURRENT STACK POINTER TO [HL]
	LD	E, L		;MOVE SOURCE ADDRESS TO [DE]
	LD	D, H
	ADD	HL, BC
	PUSH	HL		;SAVE DESTINATION
	LD	HL, (STKTOP)
	OR	A
	SBC	HL, DE
	LD	C, L		;MOVE BYTE COUNT TO MOVE TO [BC]
	LD	B, H
	INC	BC
	POP	HL		;RESTORE DESTINATION
	LD	SP, HL		;DESTINATION BECOMES THE NEW SP
	EX	DE, HL
	LDIR			;MOVE STACK CONTENTS
	POP	BC		;RESTORE -SIZE
	LD	HL, (HIMEM)
	ADD	HL, BC
	LD	(HIMEM), HL
	LD	DE, -2*(2+9+256)
	ADD	HL, DE
	LD	(FILTAB), HL	;POINTER TO FIRST FCB
	EX	DE, HL
	LD	HL, (MEMSIZ)	;UPDATE MEMSIZ
	ADD	HL, BC
	LD	(MEMSIZ), HL
	LD	HL, (NULBUF)	;UPDATE NULBUF
	ADD	HL, BC
	LD	(NULBUF), HL
	LD	HL, (STKTOP)	;UPDATE STKTOP
	ADD	HL, BC
;
;       RE-BUILD BASIC'S FILE STRUCTURES
;
	LD	(STKTOP), HL
	DEC	HL		;AND SAVSTK
	DEC	HL
	LD	(SAVSTK), HL
	LD	L, E		;GET FILTAB IN [HL]
	LD	H, D
	INC	HL		;POINT TO FIRST FCB
	INC	HL
	INC	HL
	INC	HL
	LD	A, 2
DSKFLL:
	EX	DE, HL
	LD	(HL), E		;SET ADDRESS IN FILTAB
	INC	HL
	LD	(HL), D
	INC	HL
	EX	DE, HL
	LD	BC, 7
	LD	(HL), B		;MAKE IT LOOK CLOSED
	ADD	HL, BC
	LD	(HL), B		;CLEAR FLAG BYTE
	LD	BC, 9+256-7
	ADD	HL, BC		;POINT TO NEXT FCB
	DEC	A
	JR	NZ, DSKFLL
	RET


; call_bios:   ld     iy,(EXPTBL-1)       ;BIOS slot in iyh
;              jp   CALSLT              ;interslot call
