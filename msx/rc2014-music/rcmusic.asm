; MUSIC.MAC

; MSX-MUSIC, FM-PAC version

; Source re-created by Z80DIS 2.2
; Z80DIS was written by Kenneth Gielow, Palo Alto, CA

; Code Copyrighted by ASCII and maybe others
; Source comments by Arjen Zeilemaker

; Sourcecode supplied for STUDY ONLY
; Recreation NOT permitted without authorisation of the copyrightholders

; YM2413 Register selector port
OPLREG		EQU	07CH

; YM2413 Data port
OPLDAT		EQU	07DH

; PPI-register A - Primary slot select register.
PPI_SLTREG	EQU	0A8H

; ==================================
; MSX SYSTEM VARIABLES

; disksystem bottom (lowest address used by the disksystem)
HIMSAV		EQU	0F349H

; F41C-F41D: line number of current BASIC line being executed, in direct modus this
; contains $FFFF (ini:$FFFF)
CURLIN		EQU	0F41CH

; F55E-F65F: used in direct modus to store the ASCII codes of the line, or simulary
; for INPUT or LINE INPUT BASIC statements
BUF		EQU	0F55EH
CODE_BUF	EQU	BUF+128

; F663: workarea for evaluation of expressions; contains type of last evaluated
; expression; the value of the expression is in DAC, possible values of VALTYP:
; 2: integer
; 3: string
; 4: normal real
; 8: double real
VALTYP		EQU	0F663H

; F6A5: switch indicating if a variable is allowed to be an array variable.
; This is e.g. not allowed for the loop variable of a FOR statement
; 0 = allowed, 1 = not allowed
SUBFLG		EQU	0F6A5H

; F6BE-F6BF: line number of last program break, reset at 0 at any program change
OLDLIN		EQU	0F6BEH

; F6C6-F6C7: address of first free byte not used for storage of code or variables
; (ini: $8003)
STREND		EQU	0F6C6H

; F7F6-F805: workarea when executing numeric operators; intermediate
; results are stored here; also used for parameter transfer when using
; the USR functions; VALTYPE then contains the type, and the value is
; stored like this:
; typename  type  where
; integer   2     F7F8-F7F9
; string    3     F7F8-F7F9 (address descriptor)
; single    4     F7F6-F7F9
; double    8     F7F6-F7FD
DAC		EQU	0F7F6H

; F806-F856: workarea when executing numeric operators
HOLD8		EQU	0F806H

; F85F: # of filedescriptors reserved minus 1
; this is also the maximum number of open files possible
MAXFIL		EQU	0F85FH

; F860-F861: start address of the file information table
FILTAB		EQU	0F860H

; F956-F957: start address of a jumptable for subcommands
; contained in a string variable, used for both PLAY and DRAW
; where this systemvar points to either the PLAY or the DRAW
; table
MCLTAB		EQU	0F956H

FREQ_FACTOR	EQU	0F97AH	; (120*4*int freq)/2

; slotid MSX-MUSIC
MUSCSLID	EQU	0F97CH

; Original Buffers for sound queues.  Repurposed by MSX-MUSIC
; VOICAQ		EQU	0F975H		; Voice A queue
; VOICBQ		EQU	0F9F5H		; Voice B queue
; VOICCQ		EQU	0FA75H		; Voice C queue
;
MUSCWRK		EQU	0F97DH

; b0 set if in drum mode
DRUM_MODE	EQU	0F98EH

; number of playvoices
PVOICE_CNT	EQU	0F991H

; number of OPLL playvoices
OPL_PVOICE_CNT	EQU	0F992H

; Music Que Pointer?
; pointer to  12 * 6 bytes
VOICE_CTRL_BUF	EQU	0F99BH

; duration PSG playvoice 0
PSGDUV0		EQU	0F9AFH

; duration PSG playvoice 1
PSGDUV1		EQU	0F9B1H

; duration PSG playvoice 2
PSGDUV2		EQU	0F9B3H

; old H.TIMI
O.TIMI		EQU	0F9BBH

; F9C0-#F9F8 : copy of YM2413 register values
OPRGSAV		EQU	0F9C0H

; programable instrument 63
I.F9F9		EQU	0F9F9H

; corrector for interrupt resolution for every playvoice
I_FA19		EQU	0FA19H

; ; request service
D.FA26		EQU	0FA26H

; 16 bytes ? for 9
I.FA27		EQU	0FA27H

I_FA87		EQU	0FA87H

D_FA89		EQU	0FA89H

; 5 bytes drums
I.FAB7		EQU	0FAB7H

; FB35: status about the parsing of a PLAY string
;  bit 7: only one time parsed; 1 = yes
;  bit 1-0: number of parsed strings (0-3)
PRSCNT		EQU	0FB35H

; FB36-FB37: storage of stack
SAVSP		EQU	0FB36H

; FB38: # of voice currently being parsed (0-2)
VOICEN		EQU	0FB38H

; FB39-FB3A: storage of volume of a muted voice
SAVVOL		EQU	0FB39H

; FB3B: size of string being parsed (also used by DRAW)
MCLLEN		EQU	0FB3BH

; FB3C-FB3D: address of string being parsed (also used by DRAW)
MCLPTR		EQU	0FB3CH

; FB3F: flag indicating which queues are active
; bit 2 = queue 2; 1 = active
; bit 1 = queue 1; 1 = active
; bit 0 = queue 0; 1 = active
MUSICF		EQU	0FB3FH

; FB40: count of the # of PLAY statements parsed, but not executed yet
PLYCNT		EQU	0FB40H

; FB41-FB65: Voice Control Block for voice A (queue 0)
VCBA		EQU	0FB41H
; FB66-FB8A: Voice Control Block for voice B (queue 1)
VCBB		EQU	0FB66H
; FB8B-FBAF: Voice Control Block for voice C (queue 2)
VCBC		EQU	0FB8BH

; FBB1: switch indicating if the current BASIC program is in a ROM
; 0 = no; 1 = yes
BASROM		EQU	0FBB1H

; FC4A-FC4B: highest address of the RAM memory that is not reserved by
; the OS; string area, filebuffers and stack are below this address
; initialized at startup and not changed normally
HIMEM		EQU	0FC4AH

; FC9B: STOP indication
; 0 = nothing; 3 = CTRL+STOP, 4 = STOP
INTFLG		EQU	0FC9BH

; FCC1-FCC4: Information for each primary slot. The most significant bit is
; set if the primary slot is found to be expanded.
EXPTBL		EQU	0FCC1H

; 2 bytes per slot per page work area for applications
SLTWRK		EQU	0FD09H

PROCNM		EQU	0FD89H


; ======================================
; MSX BASIC BIOS ROUTINES

; Function : Reads the value of an address in another slot
; Input    : A  - ExxxSSPP  Slot-ID
;            │        ││└┴─ Primary slot number (00-11)
;            │        └┴─── Secondary slot number (00-11)
;            └───────────── Expanded slot (0 = no, 1 = yes)
;            HL - Address to read
; Output   : A  - Contains the value of the read address
; Registers: AF, C, DE
; Remark   : This routine turns off the interupt, but won't turn it on again
RDSLT	EQU	0000CH		; Read memory from an optional slot

; Function : Executes inter-slot call.
; Input    : IY - High byte with slot ID, see RDSLT
;            IX - The address that will be called
; Remark   : Variables can never be given in alternative registers or IX and IY
CALSLT	EQU	0001CH

; Function : Switches indicated slot at indicated page on perpetually
; Input    : A - Slot ID, see RDSLT
;            H - Bit 6 and 7 must contain the page number (00-11)
ENASLT	EQU	0024H	; -C---

; Basic ROM version
; 7 6 5 4 3 2 1 0
; | | | | +-+-+-+-- Character set
; | | | |           0 = Japanese, 1 = International (ASCII), 2=Korean
; | +-+-+---------- Date format
; |                 0 = Y-M-D, 1 = M-D-Y, 2 = D-M-Y
; +---------------- Default interrupt frequency
;                   0 = 60Hz, 1 = 50Hz
IDBYT1		EQU	002BH

; Function:	displays the character
; Input:	A for the character code to be displayed
; Output:	none
CHPUT		EQU	00A2h

; MAINROM ---- convert to DAC to new type
MBCVRT		EQU	517AH

; Input:	 HL <-- Starting address of the expression in text
; Output:  HL <-- Next address of expression
; 	 A, E <-- Result of expression evaluation
; 		  (A and E contains the same value.)
; Purpose: Evaluate an expression and make 1-byte integer output. When the
; result is beyond the range of 1-byte integer type, an "Illegal function call"
; error occurs and the execution returns to BASIC command level.
MBGETBYT	EQU	0521CH	; Evaluate an expression in 1-byte integer type.


; This is the Interpreter error handler, all error generators transfer to here with an error code in register E.
HERRO		EQU	0406FH

; MAINROM ---- This routine frees any storage occupied by the string whose descriptor address is contained in DAC
FRESTR		EQU	067D0H

; MAINROM ---- This routine is used by the file I/O handlers to close every I/O buffer. Register pair BC is set to 6B24H, register A is loaded with the contents of MAXFIL and all buffers closed (6BE7H).
CLOSEIO		EQU	06C1CH

; MAINROM ----- Evaluate an expression un 2-byte integer type.
; Input:	 HL <-- Starting address of the expression in text
; Output:  HL <-- Address after the expression
; 	 DE <-- Result of evaluation of the expression
; Purpose: Evaluate an expression and make output in integer type (INT). When
; the result is beyond the range of 2-byte integer type, an "Ovwrflow" error
; occurs and the system returns to the BASIC command level.
FRMQNT 		EQU	0542FH

; MAINROM ---- Evaluate an expression in text
; Input:	 HL <-- Starting address of the expression in text
; Output:  HL <-- Address after the expression
; 	 [VALTYP (F663H)] <-- Value 2, 3, 4 or 8 according to the expression
; 	 [DAC (F7F6H)]	  <-- Result of the evaluation of the expression
; Purpose: Evaluate an expression and make output according to its type.
FRMEVL		EQU	04C64H

; MAINROM ---- Extract one character from text
; Input:	 HL <-- Address pointing to text
; Output:  HL <-- Address of the extracted character
; 	 A  <-- Extracted character
; 	 Z  flag <-- ON at the end of line (: or 00H)
; 	 CY flag <-- ON if 0 to 9
; Purpose: Extract one character from the text at (HL + 1). Spaces are skipped.
CHRGTR		EQU	04666H


; MAIN ROM .................. PSG initialization
; Input:	---
; Output: 	---
; Function:	initializes PSG registers and does the initial settings of
; 		the work area in which PLAY statement of BASIC is executed.
GICINI		EQU	00090H

; MAINROM ----- This routine is used by the Factor Evaluator to return the current value of a Variable.
; The Variable is first located 5EA4H.
; If it is a string Variable its address is placed in DAC to point to the descriptor.
; Otherwise the contents of the Variable are copied to DAC (2F08).
VARVAL		EQU	04E9BH


; MAINROM ---- This routine is used by the file I/O handlers to analyze a filespec such as "`A:FILENAME.BAS`".
; The filespec consists of three parts, the device, the filename and the type extension. On entry register
; pair HL points to the start of the filespec in the program text. On exit register D holds the device code,
; the filename is in positions zero to seven of [FILNAM] and the type extension in positions eight to ten.
; Any unused positions are filled with spaces.
; The filespec string is evaluated (4C64H) and its storage freed (67D0H), if the string is of zero length
; a "`Bad file name`" error is generated (6E6BH). The device name is parsed (6F15H) and successive
; characters taken from the filespec and placed in [FILNAM] until the string is exhausted, a "." character
; is found or [FILNAM] is full. A "`Bad file name`" error is generated (6E6BH) if the filespec contains any
; control characters, that is those whose value is smaller than 20H. If the filespec contains a type
; extension a "`Bad file name`" error is generated (6E6BH) if it is longer than three characters or if the
; filename is longer than eight characters. If no type extension is present the filename may be any length,
; extra characters are simply ignored.
FILESPEC	EQU	06A0EH

; MAINROM ---- Obtain the address for the storage of a variable
; 			  (see Figure 2.16).
; Input:	 HL <-- Starting address of the variable name in text
; 		[SUBFLG (F6A5H)] <-- 0: Simple variable,
; 				     other than 0: array variable
; Output:  HL <-- Address after the variable name
; 	 DE <-- Address where the contents of the objective variable
; 		is stored
; Purpose: Obtain the address for the storage of a variable (or an array
; variable). Allocation of the area is also done when the area for the
; objective variable has not been allocated. When the value of [SUBFLG] is set
; to other than 0, the starting address of the array is obtained, other than
; individual elements of the array.
PTRGET		EQU	05EA4h

; MAINROM ---- Execute a text
; Input:	 HL <-- Address of the text to be executed
; Output:  ----
; Purpose: Execute a text.
NEWSTT		EQU	04601H

; ========================================
; MACROS
;
; Enforce PC to AMNT alignment, error if PC is larger than requested
ALIGNCHK	MACRO	AMNT

		ASSERT $ <= AMNT, "Alignment failure"
		DEFS	AMNT-$

		ENDM


; Voice Buffer Structure
VCBUF		EQU	0
VCBUF_DURATION	EQU	0		; 2 byte duration counter
VCBUF_STRLEN	EQU	2		; 1 byte string length
VCBUF_STRADDR	EQU	3		; 2 byte string address
VCBUF_STCKDATA	EQU	5		; 2 byte stack ptr
VCBUF_PCKLEN	EQU	7		; 1 byte music packet length
VCBUF_PACKET	EQU	8		; 7 byte music packet
VCBUF_OCTAVE	EQU	15		; 1 byte octave
VCBUF_LENGTH	EQU	16		; 1 byte length
VCBUF_TEMPO	EQU	17		; 1 byte tempo
VCBUF_VOLUME	EQU	18		; 1 byte volume
VCBUF_ENVPERIOD	EQU	19		; 1 byte envelope period
VCBUF_STACKSTRT	EQU	20		; stack
VCBUF_STACKEND	EQU	36
VCBUF_UNKNOWN	EQU	38		; division??

	ORG	4000H
I.0001	EQU	0001H	; ----I
I.0009	EQU	0009H	; ----I
I.000B	EQU	000BH	; ----I
C.000C	EQU	000CH	; -C--I
C.0010	EQU	0010H	; -C--I
C.0020	EQU	0020H	; -C--I
I.0025	EQU	0025H	; ----I
I.0027	EQU	0027H	; ----I
I_003A	EQU	003AH	; ----I
I.003D	EQU	003DH	; ----I
I_0048	EQU	0048H	; ----I
I_008B	EQU	008BH	; ----I
I_00FF	EQU	00FFH	; ----I
I.01C8	EQU	01C8H	; ----I
I_0327	EQU	0327H	; ----I
I_0529	EQU	0529H	; ----I
I_0900	EQU	0900H	; ----I
C_2F8A	EQU	2F8AH	; -C---
I_381E	EQU	381EH	; ----I

I73E8	EQU	73E8H

I_8010	EQU	8010H	; ----I
I_A001	EQU	0A001H	; ----I
I_F404	EQU	0F404H	; ----I
D.F55F	EQU	0F55FH	; --SLI
D.F560	EQU	0F560H	; --S-I
D.F561	EQU	0F561H	; ---LI
D.F563	EQU	0F563H	; --SL-
D.F564	EQU	0F564H	; ---L-
D_F566	EQU	0F566H	; ---L-
D.F7F8	EQU	0F7F8H	; --S-I
D_F80B	EQU	0F80BH	; --S--
D_F813	EQU	0F813H	; --S--
D_F81B	EQU	0F81BH	; --S--
C.F975	EQU	0F975H	; -C--I
I_F976	EQU	0F976H	; ----I
D.F97F	EQU	0F97FH	; --SL-
D.F980	EQU	0F980H	; --S-I
D.F981	EQU	0F981H	; --S-I
D.F982	EQU	0F982H	; --SL-
D.F983	EQU	0F983H	; --SL-
D.F984	EQU	0F984H	; --SLI
I.F985	EQU	0F985H	; ----I
D.F98F	EQU	0F98FH	; --SL-
D.F993	EQU	0F993H	; --S-I
D.F994	EQU	0F994H	; --SLI
D.F995	EQU	0F995H	; --SL-
D.F997	EQU	0F997H	; --S-I
D.F998	EQU	0F998H	; --SL-
D.F999	EQU	0F999H	; --S-I
D.F99A	EQU	0F99AH	; --SL-
D.F99D	EQU	0F99DH	; ---L-
D.F99F	EQU	0F99FH	; ---L-
D.F9A1	EQU	0F9A1H	; ---L-
I_F9A3	EQU	0F9A3H	; ----I

H.TIMI	EQU	0FD9FH	; ----I
H.PHYD	EQU	0FFA7H	; ---L-
H.PLAY	EQU	0FFC5H	; ----I

I_FFE0	EQU	0FFE0H	; ----I
X.FFFF	EQU	0FFFFH	; JCS-I


D4000:	DEFB	"AB"
	DEFW	0
	DEFW	RCMUSIC_BASIC
	DEFW	0
	DEFW	0
	DEFS	6, 0

	DEFS	8, 0

I4018:	DEFB	"APRLOPLL"

	ALIGNCHK 04080H

RCMUSIC_BASIC:
	EI
	PUSH	HL
	LD	HL, PROCNM
	LD	DE, KEYWRD_MUSIC_VER
IS_VER:	LD	A, (DE)
	OR	A
	JR	Z, BASMUSICVER
	CP	(HL)
	INC	HL
	INC	DE
	JR	Z, IS_VER
	JP	ROM_STATEMENT2

BASMUSICVER:
	LD	DE, MUSIC_VERSION_STR
PRINT_VER:
	LD	A, (DE)
	OR	A
	JR	Z, PRINT_VER_DONE
	CALL	CHPUT
	EI
	INC	DE
	JR	PRINT_VER

PRINT_VER_DONE:
	POP	HL
	OR	A
	RET

	ALIGNCHK 040C0H

	DW	2
	DW	0

	ALIGNCHK 04100H

MUSIC_VERSION_STR:
	DEFB	"V2.0 2021 12 30", 0

	ALIGNCHK 04110H

	JP	WRTOPL		; WRTOPL
	JP	INIOPL		; INIOPL
	JP	MSTART		; MSTART
	JP	MSTOP		; MSTOP
	JP	RDATA		; RDDATA
	JP	OPLDRV		; OPLDRV
	JP	TSTBGM		; TSTBGM
Q4125:	RET
Q4126:	DEFW	I4726

I4128:	DEFB	0ABH, 0
	DEFB	0B5H, 0
	DEFB	0C0H, 0
	DEFB	0CCH, 0
	DEFB	0D8H, 0
	DEFB	0E5H, 0
	DEFB	0F2H, 0
	DEFB	001H, 1
	DEFB	010H, 1
	DEFB	020H, 1
	DEFB	031H, 1
	DEFB	043H, 1

;	  Subroutine WRTOPL
;	     Inputs  A = OPLL register, E = data
;	     Outputs ________________________
WRTOPL:	OUT	(OPLREG), A
	PUSH	AF
	LD	A, E
	OUT	(OPLDAT), A
	EX	(SP), HL
	EX	(SP), HL
	EX	(SP), HL
	EX	(SP), HL
	EX	(SP), HL
	EX	(SP), HL
	EX	(SP), HL
	EX	(SP), HL
	POP	AF
	RET

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C4150:	PUSH	IY
	PUSH	DE
	ADD	A, 00H
	LD	D, 00H
	LD	E, A
	ADD	IY, DE
	POP	DE
	OUT	(OPLREG), A
	PUSH	AF
	LD	A, E
	OUT	(OPLDAT), A
	LD	(IY), A
	EX	(SP), HL
	EX	(SP), HL
	EX	(SP), HL
	EX	(SP), HL
	POP	AF
	POP	IY
	RET

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C416C:	PUSH	HL
	PUSH	IY
	POP	HL
	ADD	A, 00H
	ADD	A, L
	LD	L, A
	LD	A, H
	ADC	A, 00H
	LD	H, A
	LD	A, (HL)
	POP	HL
	RET

;	  Subroutine INIOPL
;	     Inputs  HL = workarea
;	     Outputs ________________________

INIOPL:	DI
	LD	A, L
	AND	0FEH
	LD	L, A
	PUSH	HL
	LD	BC, 4000H
	CALL	MYSLTWRK
	POP	BC
	LD	A, (HL)
	AND	01H
	OR	C
	LD	(HL), A
	INC	HL
	LD	(HL), B
	PUSH	BC
	POP	IY
	CALL	C4230			; enable MSX-MUSIC hardware
	PUSH	IY
	POP	HL
	LD	DE, 0
	ADD	HL, DE
	LD	E, L
	LD	D, H
	INC	DE
	LD	BC, 161-1
	LD	(HL), 0
	LDIR
	LD	A, 00H
	CALL	C463B
	LD	A, 0EH	; 14
	LD	E, 00H
	CALL	C4150
	INC	A
	CALL	C4150
	LD	A, 10H	; 16
	LD	E, 20H	; " "
	LD	B, 9
J41BC:	CALL	C4150
	INC	A
	DJNZ	J41BC
	LD	A, 20H	; " "
	LD	E, 07H	; 7
	LD	B, 9
J41C8:	CALL	C4150
	INC	A
	DJNZ	J41C8
	LD	A, 30H	; "0"
	LD	E, 0B3H
	LD	B, 9
J41D4:	CALL	C4150
	INC	A
	DJNZ	J41D4
	EI
	RET

;	Subroutine get SLTWRK entry
;	  Inputs BC = address (for page)
;	  Outputs ________________________
MYSLTWRK:
	CALL	GETSLT
	AND	0FH
	LD	L, A
	RLCA
	RLCA
	RLCA
	RLCA
	AND	30H
	OR	L
	AND	3CH
	OR	01H
	RLCA
	LD	E, A
	LD	D, 00H
	LD	HL, SLTWRK
	ADD	HL, DE
	RET
;	-----------------

;	Subroutine get slotid
;	  Inputs  BC = adres (for page)
;	  Outputs ________________________

GETSLT:	PUSH	BC
	PUSH	DE
	PUSH	HL
	LD	A, B			; get A15/A14 page indicator of BC
	RLCA				; convert to 0-3 page number
	RLCA
	AND	3
	LD	B, A			; store page number in B
	IN	A, (PPI_SLTREG)		; read SLOT REGISTER (aka RSLREG)
	CALL	C4226			; move current slot id to bits 1 and 0
	AND	3			; mask out the other slots
	LD	E, A			; store current slot id in E
	LD	D, 0
	LD	HL, EXPTBL		; add current slot id to EXPTBL
	ADD	HL, DE
	LD	A, (HL)			; get extended slot bit
	AND	80H
	OR	E			; mask in current slot id
	JP	P, GETSLT2		; dont if not extended
	LD	E, A
	INC	HL			; increment HL to SLTTBL
	INC	HL
	INC	HL
	INC	HL
	LD	A, (HL)			; load SLTTBL
	RLCA
	RLCA
	CALL	C4226
	AND	12
	OR	E
GETSLT2:
	POP	HL
	POP	DE
	POP	BC
	RET

;	  Subroutine shift slot id for page B into lowest bits
;	     Inputs  A slot ids, B page number
;	     Outputs A rotated such that slot id is in lowest bits
C4226:	INC	B
	DEC	B
	RET	Z
	PUSH	BC
J422A:	RRCA
	RRCA
	DJNZ	J422A
	POP	BC
	RET


;	  Subroutine enable MSX-MUSIC hardware
;	     Inputs  IY = workarea
;	     Outputs ________________________

C4230:	LD	HL, I4243
	PUSH	IY
	POP	DE
	LD	BC, I_008B
	LDIR				; copy detect routine in workarea
	LD	BC, 4000H
	CALL	GETSLT			; slotid of this MSX-MUSIC
	JP	(IY)

I4243:	PUSH	AF			; save slotid of this MSX-MUSIC
	PUSH	IY
	POP	DE
	LD	HL, I4258-I4243
	ADD	HL, DE
	PUSH	HL			; continue here after search
	LD	HL, I42BE-I4243
	ADD	HL, DE			; search for internal MSX-MUSIC
	LD	IX, I427A-I4243
	ADD	IX, DE
	JP	(IX)			; search MSX-MUSIC

I4258:	CP	0FFH			; internal MSX-MUSIC found ?
	JR	NZ, J4272		; yep, restore MSX-MUSIC in page 1 and quit
	PUSH	IY
	POP	DE
	LD	HL, I426A-I4243
	ADD	HL, DE
	PUSH	HL			; continue here after search
	LD	HL, I42C6-I4243
	ADD	HL, DE			; search for external MSX-MUSIC
	JP	(IX)			; search MSX-MUSIC

I426A:	LD	A, (D7FF6)
	OR	01H
	LD	(D7FF6), A		; enable fmpac hardware
J4272:	POP	AF
	LD	HL, 4000H
	CALL	ENASLT			; restore MSX-MUSIC in page 1 and quit
	RET

I427A:	EX	DE, HL
	LD	HL, EXPTBL
	LD	C, 0
	LD	B, 4
J4282:	PUSH	BC
	PUSH	HL
	LD	A, (HL)
	AND	80H
	OR	C
	LD	C, A
	LD	B, 1
	RLCA
	JR	NC, J4290
	LD	B, 4
J4290:	PUSH	BC
	PUSH	DE
	LD	A, C
	LD	H, 40H
	CALL	ENASLT
	POP	DE
	PUSH	DE
	LD	HL, I4018
	LD	B, 8
J429F:	LD	A, (DE)
	INC	DE
	CP	(HL)
	INC	HL
	JR	NZ, J42A7
	DJNZ	J429F
J42A7:	POP	DE
	POP	BC
	JR	Z, J42BA
	LD	A, C
	ADD	A, 4
	LD	C, A
	DJNZ	J4290
	POP	HL
	POP	BC
	INC	HL
	INC	C
	DJNZ	J4282
	LD	A, 0FFH
	RET

J42BA:	LD	A, C
	POP	HL
	POP	BC
	RET

I42BE:	DEFB	"APRLOPLL"

I42C6:	DEFB	"APRLOPLL"

;	  Subroutine MSTART
;	     Inputs  ________________________
;	     Outputs ________________________

MSTART:	DI
	PUSH	HL
	PUSH	AF
	LD	BC, 4000H		; page 1
	CALL	MYSLTWRK		; get SLTWRK entry
	LD	A, (HL)
	INC	HL
	LD	H, (HL)			; de-reference
	AND	0FEH			; mask out bit 0
	LD	L, A
	PUSH	HL
	POP	IY
	LD	DE, I.003D
	ADD	HL, DE
	PUSH	HL
	POP	IX
	POP	AF
	OR	A
	JR	NZ, J42EC
	DEC	A
J42EC:	LD	(IY+58), A
	POP	HL
	LD	A, (HL)
	CP	12H	; 18
	JP	NZ, J4306
	LD	A, 0EH	; 14
	LD	E, 00H
	CALL	C4150
	LD	B, 09H	; 9
	LD	(IY+57), 00H
I4303:	JP	J430C

J4306:	LD	B, 07H	; 7
	LD	(IY+57), 0FFH
J430C:	LD	(IY+59), 00H
	PUSH	HL
J4311:	LD	E, (HL)
	INC	HL
	LD	D, (HL)
	INC	HL
	LD	A, D
	OR	E
	JP	NZ, J4325
	LD	(IX), 00H
	LD	(IX+1), 00H
	JP	J4337

J4325:	EX	(SP), HL
	EX	DE, HL
	ADD	HL, DE
	LD	(IX), L
	LD	(IX+1), H
	LD	(IX+10), 01H	; 1
	EX	DE, HL
	EX	(SP), HL
	INC	(IY+59)
J4337:	LD	DE, 11
	ADD	IX, DE
	DJNZ	J4311
	POP	HL
	CALL	C4344
	EI
	RET

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C4344:	PUSH	IY
	POP	IX
	LD	DE, I.003D
	ADD	IX, DE
	LD	B, 9
	LD	A, (IY+57)
	OR	A
	JP	Z, J4374
	LD	L, (IX)
	LD	H, (IX+1)
	LD	(IX+2), L
	LD	(IX+3), H
	LD	(IX+4), 01H	; 1
	LD	(IX+5), 00H
	CALL	C43B5
	LD	DE, 11
	ADD	IX, DE
	LD	B, 6
J4374:	LD	L, (IX)
	LD	H, (IX+1)
	LD	(IX+2), L
	LD	(IX+3), H
	LD	(IX+4), 01H	; 1
	LD	(IX+5), 00H
	LD	(IX+6), 00H
	LD	(IX+7), 00H
J438D	EQU	$-3
	LD	(IX+9), 00H
	LD	(IX+8), 08H	; 8
	LD	A, 1FH
	ADD	A, B
	CALL	C416C
	AND	0CFH
	LD	E, A
	LD	A, 1FH
	ADD	A, B
	CALL	C4150
	LD	DE, 11
	ADD	IX, DE
	DJNZ	J4374
	LD	A, (IY+59)
	LD	(IY+60), A
	RET

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C43B5:	LD	HL, I43C5
J43B8:	LD	A, (HL)
	CP	0FFH
	RET	Z
	INC	HL
	LD	E, (HL)
	INC	HL
	CALL	C4150
	JP	J43B8

I43C5:	DEFB 00EH, 020H			; enable rhythm
	DEFB 016H, 020H			; channel 6, f-number lsb
	DEFB 017H, 050H			; channel 7, f-number lsb
	DEFB 018H, 0C0H			; channel 8, f-number lsb
	DEFB 026H, 005H			; channel 6, sustain off, key off, octave 2, b8 f-number=1
	DEFB 027H, 005H			; channel 7, sustain off, key off, octave 2, b8 f-number=1
	DEFB 028H, 001H			; channel 8, sustain off, key off, octave 0, b8 f-number=1
	DEFB 036H, 003H			; channel 6, instrument 0, volume 3
	DEFB 037H, 033H			; channel 7, instrument 3, volume 3
	DEFB 038H, 033H			; channel 8, instrument 3, volume 3
	DEFB 0FFH

;	  Subroutine MSTOP
;	     Inputs  ________________________
;	     Outputs ________________________

MSTOP:	DI
	LD	BC, 4000H
	CALL	MYSLTWRK
	LD	A, (HL)
	INC	HL
	LD	H, (HL)
	AND	0FEH
	LD	L, A
	PUSH	HL
	POP	IY
	LD	DE, I.003D
	ADD	HL, DE
	PUSH	HL
	POP	IX
	LD	B, 9
	LD	A, (IY+57)
	OR	A
	JP	Z, J4410
	LD	A, 0EH	; 14
	LD	E, 20H	; " "
	CALL	C4150
	LD	(IX+2), 00H
	LD	(IX+3), 00H
	LD	DE, 11
J440C:	ADD	IX, DE
	LD	B, 6
J4410:	LD	(IX+2), 00H
	LD	(IX+3), 00H
	LD	A, 1FH
	ADD	A, B
	CALL	C416C
	AND	0EFH
	LD	E, A
	LD	A, 1FH
	ADD	A, B
	CALL	C4150
	LD	DE, 11
	ADD	IX, DE
	DJNZ	J4410
	EI
	RET

;	  Subroutine RDDATA
;	     Inputs  ________________________
;	     Outputs ________________________

RDATA:	PUSH	BC
	PUSH	DE
	PUSH	HL
	EX	DE, HL
	LD	L, A
	LD	H, 0
	ADD	HL, HL
	ADD	HL, HL
	ADD	HL, HL
	LD	BC, INSTRUMENT_PROFILES
	ADD	HL, BC
	LD	BC, 8
	LDIR
	POP	HL
	POP	DE
	POP	BC
	RET

;	  Subroutine OPLDRV
;	     Inputs  ________________________
;	     Outputs ________________________

OPLDRV:	PUSH	AF
	PUSH	BC
	PUSH	DE
	PUSH	HL
	PUSH	IX
	PUSH	IY
	LD	BC, 4000H
	CALL	MYSLTWRK
	LD	A, (HL)
	INC	HL
	LD	H, (HL)
	AND	0FEH
	LD	L, A
	PUSH	HL
	POP	IY
	LD	DE, I.003D
	ADD	HL, DE
	PUSH	HL
	POP	IX
J4465:	LD	B, 9
	LD	A, (IY+57)
	OR	A
	JP	Z, J4492
	LD	L, (IX+2)
	LD	H, (IX+3)
	LD	A, L
	OR	H
	JP	Z, J448B
	LD	E, (IX+4)
	LD	D, (IX+5)
	DEC	DE
	LD	A, E
	OR	D
	CALL	Z, C4681
	LD	(IX+4), E
	LD	(IX+5), D
J448B:	LD	DE, 11
	ADD	IX, DE
	LD	B, 6
J4492:	LD	E, (IX+6)
	LD	D, (IX+7)
	LD	A, E
	OR	D
	JP	Z, J44A9
	DEC	DE
	LD	A, E
	OR	D
	LD	(IX+6), E
	LD	(IX+7), D
	CALL	Z, C44D6
J44A9:	LD	L, (IX+2)
	LD	H, (IX+3)
	LD	A, L
	OR	H
	JP	Z, J44C6
	LD	E, (IX+4)
	LD	D, (IX+5)
	DEC	DE
	LD	A, E
	OR	D
	CALL	Z, C44EA
	LD	(IX+4), E
	LD	(IX+5), D
J44C6:	LD	DE, I.000B
	ADD	IX, DE
	DJNZ	J4492
	POP	IY
	POP	IX
	POP	HL
	POP	DE
	POP	BC
	POP	AF
	RET

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C44D6:	LD	A, (IX+9)
	OR	A
	RET	NZ
	LD	A, 1FH
	ADD	A, B
	CALL	C416C
	AND	0EFH
	LD	E, A
	LD	A, 1FH
	ADD	A, B
	JP	C4150

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C44EA:	LD	A, (HL)
	INC	HL
	CP	0FFH
	JP	Z, J4524
	CP	60H	; "`"
	JP	C, J4554
	CP	70H	; "p"
	JP	C, J45DD
	CP	80H
	JP	C, J45F3
	JP	Z, J460D
	CP	81H
	JP	Z, J461F
	CP	82H
	JP	Z, J4631
	CP	83H
	JP	Z, J4654
	CP	84H
	JP	Z, J467A
	CP	85H
	JP	Z, J4673
	CP	86H
	JP	Z, J466B
	JP	C44EA
;	-----------------
J4524:	LD	(IX+2), 00H
	LD	(IX+3), 00H
	LD	A, (IX+10)
	OR	A
	RET	Z
	DEC	(IY+60)
	RET	NZ
	LD	A, (IY+58)
	CP	0FFH
	JP	Z, J4544
	OR	A
	RET	Z
	DEC	A
	LD	(IY+58), A
	RET	Z
J4544:	POP	HL
	CALL	C4344
	PUSH	IY
	POP	IX
	LD	DE, I.003D
	ADD	IX, DE
	JP	J4465
;	-----------------
J4554:	LD	C, A
	CALL	C4712
	LD	(IX+2), L
	LD	(IX+3), H
	LD	A, C
	OR	A
	RET	Z
	PUSH	DE
	LD	A, (IX+8)
	AND	07H	; 7
	JP	NZ, J456F
	LD	H, E
	LD	L, D
	JP	J458C
;	-----------------
J456F:	RRCA
	RRCA
	RRCA
	PUSH	BC
	LD	HL, 0
	LD	B, 08H	; 8
J4578:	ADD	HL, HL
	RLA
	JP	NC, J4580
	ADD	HL, DE
	ADC	A, 00H
J4580:	DJNZ	J4578
	POP	BC
	LD	L, A
	OR	H
	JP	NZ, J458C
	LD	H, 01H	; 1
	LD	L, 00H
J458C:	LD	(IX+6), H
	LD	(IX+7), L
	DEC	C
	LD	L, C
	LD	H, 00H
	LD	A, 0CH	; 12
	CALL	C45C4
	LD	C, L
	SLA	C
	LD	A, H
	ADD	A, A
	LD	E, A
	LD	D, 00H
	LD	HL, I4128
	ADD	HL, DE
	LD	A, 0FH	; 15
	ADD	A, B
	LD	E, (HL)
	INC	HL
	CALL	C4150
	LD	A, 1FH
	ADD	A, B
	CALL	C416C
	AND	20H	; " "
	OR	(HL)
	OR	C
	OR	10H	; 16
	LD	E, A
	LD	A, 1FH
	ADD	A, B
	CALL	C4150
	POP	DE
	RET

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C45C4:	PUSH	BC
	LD	B, 08H	; 8
	OR	A
	LD	C, A
J45C9:	ADC	HL, HL
	LD	A, H
	JP	C, J45D3
	CP	C
	JP	C, J45D6
J45D3:	SUB	C
	LD	H, A
	OR	A
J45D6:	CCF
	DJNZ	J45C9
	RL	L
	POP	BC
	RET
;	-----------------
J45DD:	AND	0FH	; 15
	LD	C, A
	LD	A, 2FH	; "/"
	ADD	A, B
	CALL	C416C
	AND	0F0H
	OR	C
	LD	E, A
	LD	A, 2FH	; "/"
	ADD	A, B
	CALL	C4150
	JP	C44EA
;	-----------------
J45F3:	AND	0FH	; 15
	RLCA
	RLCA
	RLCA
	RLCA
	LD	C, A
	LD	A, 2FH	; "/"
	ADD	A, B
	CALL	C416C
	AND	0FH	; 15
	OR	C
	LD	E, A
	LD	A, 2FH	; "/"
	ADD	A, B
	CALL	C4150
	JP	C44EA
;	-----------------
J460D:	LD	A, 1FH
	ADD	A, B
	CALL	C416C
	OR	20H	; " "
	LD	E, A
	LD	A, 1FH
	ADD	A, B
	CALL	C4150
	JP	C44EA
;	-----------------
J461F:	LD	A, 1FH
	ADD	A, B
	CALL	C416C
	AND	0DFH
	LD	E, A
	LD	A, 1FH
	ADD	A, B
	CALL	C4150
	JP	C44EA
;	-----------------
J4631:	LD	A, (HL)
	INC	HL
	AND	7FH
	CALL	C463B
	JP	C44EA
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C463B:	INC	A
	PUSH	HL
	LD	L, A
	LD	H, 00H
	ADD	HL, HL
	ADD	HL, HL
	ADD	HL, HL
	LD	DE, INSTRUMENT_PROFILES
	ADD	HL, DE
	LD	A, 07H	; 7
J4649:	DEC	HL
	LD	E, (HL)
	CALL	C4150
	DEC	A
	JP	P, J4649
	POP	HL
	RET
;	-----------------
J4654:	LD	E, (HL)
	INC	HL
	LD	D, (HL)
	INC	HL
	PUSH	HL
	EX	DE, HL
	LD	C, 08H	; 8
	XOR	A
J465D:	LD	E, (HL)
	INC	HL
	CALL	C4150
	INC	A
	DEC	C
	JP	NZ, J465D
	POP	HL
	JP	C44EA
;	-----------------
J466B:	LD	A, (HL)
	INC	HL
	LD	(IX+8), A
	JP	C44EA
;	-----------------
J4673:	LD	(IX+9), 0FFH
	JP	C44EA
;	-----------------
J467A:	LD	(IX+9), 00H
	JP	C44EA
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C4681:	LD	A, (HL)
	INC	HL
	CP	0FFH
	JP	Z, J4524
	OR	A
	JP	P, J46EC
	LD	D, A
	LD	A, (HL)
	INC	HL
	AND	0FH	; 15
	LD	C, A
	RLA
	RLA
	RLA
	RLA
	LD	B, A
	RR	D
	JR	NC, J46A9
	LD	A, 37H	; "7"
	CALL	C416C
	AND	0FH	; 15
	OR	B
	LD	E, A
	LD	A, 37H	; "7"
	CALL	C4150
J46A9:	RR	D
	JR	NC, J46BB
	LD	A, 38H	; "8"
	CALL	C416C
	AND	0F0H
	OR	C
	LD	E, A
	LD	A, 38H	; "8"
	CALL	C4150
J46BB:	RR	D
	JR	NC, J46CD
	LD	A, 38H	; "8"
	CALL	C416C
	AND	0FH	; 15
	OR	B
	LD	E, A
	LD	A, 38H	; "8"
	CALL	C4150
J46CD:	RR	D
	JR	NC, J46DF
	LD	A, 37H	; "7"
	CALL	C416C
	AND	0F0H
	OR	C
	LD	E, A
	LD	A, 37H	; "7"
	CALL	C4150
J46DF:	RR	D
	JR	NC, J46E9
	LD	A, 36H	; "6"
	LD	E, C
	CALL	C4150
J46E9:	JP	C4681
;	-----------------
J46EC:	LD	C, A
	XOR	1FH
	LD	E, A
	LD	A, 0EH	; 14
	CALL	C416C
	AND	E
	LD	E, A
	LD	A, 0EH	; 14
	CALL	C4150
	CALL	C416C
	LD	E, A
	LD	A, C
	OR	E
	LD	E, A
	LD	A, 0EH	; 14
	CALL	C4150
	CALL	C4712
	LD	(IX+2), L
	LD	(IX+3), H
	RET
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C4712:	LD	DE, 0
J4715:	LD	A, (HL)
	INC	HL
	CP	0FFH
	JR	NZ, J471F
	INC	D
	DEC	DE
	JR	J4715
;	-----------------
J471F:	ADD	A, E
	LD	E, A
	LD	A, D
	ADC	A, 00H
	LD	D, A
	RET

I4726:	OR	A
	JP	Z, MSTOP			; MSTOP
	DEC	A
	ADD	A, A
	LD	D, 00H
	LD	E, A
	LD	HL, I_8010
	ADD	HL, DE
	LD	A, (HL)
	INC	HL
	LD	H, (HL)
	LD	L, A
	LD	A, B
	JP	MSTART			; MSTART

;	  Subroutine TSTBGM
;	     Inputs  ________________________
;	     Outputs ________________________

TSTBGM:	PUSH	BC
	PUSH	HL
	LD	BC, 4000H
	CALL	MYSLTWRK
	LD	A, (HL)
	INC	HL
	LD	H, (HL)
	AND	0FEH
	LD	L, A
	LD	BC, I_003A
	ADD	HL, BC
	LD	A, (HL)
	POP	HL
	POP	BC
	RET

	DEFS	04C00H-$, 0


; Table with 64 software instruments
; each entry has 8 bytes, these are the register values for OPLL register 7 - 0
; so register 7 is first stored and then downwards

INSTRUMENT_PROFILES:
	DEFB	11H, 11H, 20H, 20H, 0FFH, 0B2H, 0F4H, 0F4H
	DEFB	30H, 10H, 20H, 20H, 0FBH, 0B2H, 0F3H, 0F3H
	DEFB	61H, 61H, 20H, 20H, 0B4H, 56H, 17H, 17H
	DEFB	31H, 31H, 20H, 20H, 43H, 43H, 26H, 26H
	DEFB	0A2H, 30H, 20H, 20H, 88H, 54H, 06H, 06H
	DEFB	31H, 34H, 20H, 20H, 72H, 56H, 1CH, 1CH
	DEFB	71H, 71H, 20H, 20H, 53H, 52H, 24H, 24H
	DEFB	34H, 30H, 20H, 20H, 50H, 30H, 06H, 06H
	DEFB	0FFH, 52H, 20H, 20H, 0D9H, 0D9H, 24H, 24H
	DEFB	63H, 63H, 20H, 20H, 0FCH, 0F8H, 29H, 29H
	DEFB	41H, 41H, 20H, 20H, 0A3H, 0A3H, 05H, 05H
	DEFB	53H, 53H, 20H, 20H, 0F5H, 0F5H, 03H, 03H
	DEFB	23H, 43H, 29H, 20H, 0BFH, 0BFH, 05H, 05H
	DEFB	03H, 09H, 20H, 20H, 0D2H, 0B4H, 0F5H, 0F5H
	DEFB	01H, 00H, 20H, 20H, 0A3H, 0E2H, 0F4H, 0F4H
	DEFB	01H, 01H, 20H, 20H, 0C0H, 0B4H, 0F6H, 0F6H
	DEFB	0F1H, 0F1H, 20H, 20H, 0D1H, 0D1H, 0F2H, 0F2H
	DEFB	11H, 11H, 20H, 20H, 0FCH, 0D2H, 83H, 83H
	DEFB	01H, 10H, 20H, 20H, 0CAH, 0E6H, 24H, 24H
	DEFB	0E0H, 0F4H, 20H, 20H, 0F1H, 0F0H, 08H, 08H
	DEFB	0FFH, 70H, 20H, 20H, 1FH, 1FH, 01H, 01H
	DEFB	11H, 11H, 20H, 20H, 0FAH, 0F2H, 0F4H, 0F4H
	DEFB	0A6H, 42H, 20H, 20H, 0B9H, 0B9H, 02H, 02H
	DEFB	31H, 31H, 20H, 20H, 0F9H, 0F9H, 04H, 04H
	DEFB	42H, 44H, 20H, 20H, 94H, 0B0H, 0F6H, 0F6H
	DEFB	03H, 03H, 20H, 20H, 0D9H, 0D9H, 06H, 06H
	DEFB	40H, 00H, 20H, 20H, 0D9H, 0D9H, 04H, 04H
	DEFB	03H, 03H, 20H, 20H, 0FFH, 0FFH, 06H, 06H
	DEFB	18H, 11H, 20H, 20H, 0F5H, 0F5H, 26H, 26H
	DEFB	0BH, 04H, 20H, 20H, 0F5H, 0F5H, 27H, 27H
	DEFB	40H, 40H, 20H, 20H, 0D0H, 0D6H, 27H, 27H
	DEFB	00H, 01H, 20H, 20H, 0E3H, 0E3H, 25H, 25H
	DEFB	11H, 11H, 08H, 20H, 0FAH, 0B2H, 0F4H, 0F4H
	DEFB	11H, 11H, 0BDH, 20H, 0C0H, 0B2H, 0F4H, 0F4H
	DEFB	19H, 53H, 0FFH, 20H, 0E7H, 95H, 03H, 03H
	DEFB	30H, 70H, 0FFH, 20H, 42H, 62H, 24H, 24H
	DEFB	62H, 71H, 25H, 20H, 64H, 43H, 26H, 26H
	DEFB	21H, 03H, 2BH, 20H, 90H, 0D4H, 0F5H, 0F5H
	DEFB	01H, 03H, 0AH, 20H, 90H, 0A4H, 0F5H, 0F5H
	DEFB	43H, 53H, 0EH, 20H, 0B5H, 0E9H, 84H, 04H
	DEFB	34H, 30H, 20H, 20H, 50H, 30H, 06H, 06H
	DEFB	33H, 33H, 20H, 20H, 0F5H, 0F5H, 15H, 15H
	DEFB	13H, 13H, 34H, 20H, 0F5H, 0F5H, 03H, 03H
	DEFB	61H, 21H, 20H, 20H, 76H, 54H, 06H, 06H
	DEFB	63H, 70H, 20H, 20H, 4BH, 4BH, 15H, 15H
	DEFB	0A1H, 0A1H, 20H, 20H, 76H, 54H, 07H, 07H
	DEFB	61H, 78H, 20H, 20H, 85H, 0F2H, 03H, 03H
	DEFB	31H, 71H, 35H, 20H, 0B6H, 0F9H, 26H, 26H
	DEFB	61H, 71H, 0ADH, 20H, 75H, 0F2H, 03H, 03H
	DEFB	03H, 0CH, 14H, 20H, 0A7H, 0FCH, 15H, 15H
	DEFB	13H, 32H, 20H, 20H, 20H, 85H, 0AFH, 0AFH
	DEFB	0F1H, 31H, 0FFH, 20H, 23H, 40H, 09H, 09H
	DEFB	0F0H, 74H, 0B7H, 20H, 5AH, 43H, 0FCH, 0FCH
	DEFB	20H, 71H, 20H, 20H, 0D5H, 0D5H, 06H, 06H
	DEFB	30H, 32H, 20H, 20H, 40H, 40H, 74H, 74H
	DEFB	30H, 32H, 20H, 20H, 40H, 40H, 74H, 74H
	DEFB	01H, 08H, 20H, 20H, 78H, 0F8H, 0F9H, 0F9H
	DEFB	0C8H, 0C0H, 20H, 20H, 0F7H, 0F7H, 0F9H, 0F9H
	DEFB	49H, 40H, 29H, 20H, 0F9H, 0F9H, 05H, 05H
	DEFB	0CDH, 42H, 20H, 20H, 0A2H, 0F0H, 01H, 01H
	DEFB	51H, 42H, 20H, 20H, 13H, 10H, 01H, 01H
	DEFB	51H, 42H, 20H, 20H, 13H, 10H, 01H, 01H
	DEFB	30H, 34H, 20H, 20H, 23H, 70H, 02H, 02H
	DEFB	00H, 00H, 20H, 20H, 00H, 00H, 0FFH, 0FFH

	DEFS	05000H-$, 0

;	Jumptable, some sort of BIOS ?
;
;	+0	statement handler
;	+3	interrupt handler
;	+6	stop background music
;	+9	enable and reset OPLL

I5000:	JP	ROM_STATEMENT
J5003:	JP	KEYINT
X5006:	JP	J5078
C5009:	LD	HL, C.F975
	LD	DE, I_F976
	LD	BC, 0147H-1
	LD	(HL), 0
	LDIR
	LD	B, 4
J5018:	PUSH	BC
	LD	A, 4
	SUB	B
	LD	C, A
	LD	HL, EXPTBL
	CALL	C5486
	LD	A, (HL)
	ADD	A, A
	JR	NC, J5043
	LD	B, 04H	; 4
J5029:	PUSH	BC
	LD	A, 24H	; "$"
	SUB	B
	RLCA
	RLCA
	OR	C
	CALL	C5054
	POP	BC
	JR	Z, J5049
	DJNZ	J5029
J5038:	POP	BC
	DJNZ	J5018
	LD	HL, D7FF6
	SET	0, (HL)			; enable fmpac hardware
J5040:	JP	C6D61
;	-----------------
J5043:	LD	A, C
	CALL	C5054
	JR	NZ, J5038
J5049:	POP	BC
	JR	J5040

I504C:	DEFB	"APRLOPLL"

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C5054:	PUSH	BC
	LD	HL, I4018
	LD	DE, I504C
	LD	B, 8
J505D:	PUSH	AF
	PUSH	BC
	PUSH	DE
	CALL	RDSLT
	EI
	POP	DE
	POP	BC
	LD	C, A
	LD	A, (DE)
	CP	C
	JR	NZ, J5073
	POP	AF
	INC	DE
	INC	HL
	DJNZ	J505D
	POP	BC
	XOR	A
	RET

J5073:	POP	AF
	POP	BC
	XOR	A
	INC	A
	RET

J5078:	CALL	GET_MSX_INIT
	RET	Z
	JP	C658D
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C507F:	DI
	CALL	GET_MSX_INIT
	RET	NZ
	CALL	SET_MSX_INIT
	LD	HL, H.TIMI
	LD	DE, O.TIMI
	PUSH	HL
	CALL	LDIR5
	LD	HL, JMPKEYINT
	POP	DE				; DE = H.TIMI
	CALL	LDIR5
	CALL	C554C
	LD	(MUSCSLID), A
	LD	(H.TIMI+1), A
	LD	HL, JMPPLAY
	LD	DE, H.PLAY
	CALL	LDIR5
	LD	(H.PLAY+1), A
	RET

;	  Subroutine Copy 5 bytes from HL to DE
;	     Inputs  HL Source, DE Destination
LDIR5:	LD	BC, 5
	LDIR
	RET

; Copied to H.PLAY - PLAY statement handler hook
JMPPLAY:
	RST	30H				; interslot call
	DEFB	0				; replace with MSX-MUSIC's slot it
	DEFW	C57A1
	RET

;	Copied to H.TIMI - KEYINT handler hook
JMPKEYINT:
	RST	30H				; interslot call
	DEFB	0				; replace with MSX-MUSIC's slot it
	DEFW	J.KEYINT
	RET


;	Set MSX MUSIC initialised bit flag

SET_MSX_INIT:
	PUSH	HL
	CALL	GETSLTWRK
	SET	0, (HL)
	POP	HL
	RET
;	-----------------

;	  Get MSX MUSIC initialised bit flag
;	    Outputs: (NZ -> is initialised, Z -> is not initialised)

GET_MSX_INIT:
	PUSH	HL
	CALL	GETSLTWRK
	BIT	0, (HL)
	POP	HL
	RET

;	Get my SLTWRK entry
;	  Outputs: (HL => slot work area address)

GETSLTWRK:
	PUSH	AF
	PUSH	DE
	CALL	C554C
	AND	0FH	; 15
	LD	L, A
	RLCA
	RLCA
	RLCA
	RLCA
	AND	30H	; "0"
	OR	L
	AND	3CH	; "<"
	INC	A
	ADD	A, A
	LD	E, A
	LD	D, 00H
	LD	HL, SLTWRK
	ADD	HL, DE
	POP	DE
	POP	AF
	RET

ROM_STATEMENT:
J50EB:	EI
	PUSH	HL
ROM_STATEMENT2:
	LD	HL, PROCNM
	CALL	C525A
	POP	HL
	RET	C
	PUSH	HL
	LD	HL, BASMUSIC
	OR	A
	SBC	HL, DE
	POP	HL
	JR	Z, J5104
	CALL	GET_MSX_INIT
	SCF
	RET	Z
J5104:	CALL	MEMCHK
	CALL	CALL_DE
	EI
	OR	A
	RET
;	-----------------

;	  CALL (DE)

CALL_DE:
	PUSH	DE
	RET
;	-----------------

;	Check if sufficient memory available
;	Throws OUT_OF_MEMORY is not
;	HL & DE protected

MEMCHK:	PUSH	HL
	PUSH	DE
	LD	HL, -768
	ADD	HL, SP
	JP	NC, ERROUTOFMEMORY
	LD	DE, (STREND)
	OR	A
	SBC	HL, DE
	JP	C, ERROUTOFMEMORY
	POP	DE
	POP	HL
	RET

;	-----------------

BASICCMDSIDX:
	DEFB	BASICMDS_A-BASICMDS
	DEFB	BASICMDS_B-BASICMDS
	DEFB	BASICMDS_C-BASICMDS
	DEFB	BASICMDS_D-BASICMDS
	DEFB	BASICMDS_E-BASICMDS
	DEFB	BASICMDS_F-BASICMDS
	DEFB	BASICMDS_G-BASICMDS
	DEFB	BASICMDS_H-BASICMDS
	DEFB	BASICMDS_I-BASICMDS
	DEFB	BASICMDS_J-BASICMDS
	DEFB	BASICMDS_K-BASICMDS
	DEFB	BASICMDS_L-BASICMDS
	DEFB	BASICMDS_M-BASICMDS
	DEFB	BASICMDS_N-BASICMDS
	DEFB	BASICMDS_O-BASICMDS
	DEFB	BASICMDS_P-BASICMDS
	DEFB	BASICMDS_Q-BASICMDS
	DEFB	BASICMDS_R-BASICMDS
	DEFB	BASICMDS_S-BASICMDS
	DEFB	BASICMDS_T-BASICMDS
	DEFB	BASICMDS_U-BASICMDS
	DEFB	BASICMDS_V-BASICMDS

BASICMDS:
BASICMDS_A:
	; AUDREG
	DEFB	"UDRE", "G"+128
	DEFW	BASAUDREG
	DEFB	0FFh

BASICMDS_B:
	;BGM
	DEFB	"G", "M" + 128
	DEFW	BASBGM

BASICMDS_C:
BASICMDS_D:
BASICMDS_E:
BASICMDS_F:
BASICMDS_G:
BASICMDS_H:
BASICMDS_I:
BASICMDS_J:
BASICMDS_K:
BASICMDS_L:
	DEFB	0FFh
BASICMDS_M:
	;MUSIC
	DEFB	"USI", "C"+128
	DEFW	BASMUSIC

BASICMDS_N:
BASICMDS_O:
BASICMDS_R:
	DEFB	0FFh

BASICMDS_S:
	; STOPM
	DEFB	"TOP", "M" + 128
	DEFW	BASSTOPM
	DEFB	0FFh

BASICMDS_T:
        ;TRANSPOSE
	DEFB	"RANSPOS", "E" + 128
	DEFW	BASTRANSPOSE

        ; TEMPER
	DEFB	"EMPE", "R"+128
	DEFW	BASTEMPER
	DEFB	0FFh
BASICMDS_V:
        ; VOICE
	DEFB	"OIC", "E"+128
	DEFW	BASVOICE

        ; VOICE COPY
	DEFB	"OICE", $FF, "COP", "Y"+128
	DEFW	BASVOICECOPY
BASICMDS_Q:
BASICMDS_U:
	DEFB	0FFh
BASICMDS_P:
	; PLAY
	DEFB	"LA", "Y" + 128
	DEFW	BASPLAY

	; PITCH
	DEFB	"ITC", "H" + 128
	DEFW	BASPITCH
	DEFB	0FFh

KEYWRD_MUSIC_VER:
	DEFB	"MUSIC VER", 0

	ALIGNCHK	0525AH

;	  Subroutine __________________________
;	     Inputs  	________________________
;	     Outputs ________________________

C525A:	LD	A, (HL)
	SUB	41H	; "A"
	RET	C
	CP	16H
	CCF
	RET	C
	INC	HL
	PUSH	HL
	LD	HL, BASICCMDSIDX
	CALL	C5486
	LD	A, (HL)
	LD	HL, BASICMDS
	CALL	C5486
	EX	DE, HL
	POP	HL
J5273:	PUSH	HL
	LD	A, (DE)
	INC	A
	JR	Z, J5283
	CALL	C5286
	POP	HL
	JR	NZ, J5273
	EX	DE, HL
	LD	E, (HL)
	INC	HL
	LD	D, (HL)
	RET
;	-----------------
J5283:	SCF
	POP	HL
	RET
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C5286:	LD	A, (DE)
	LD	B, A
	AND	7FH
	CP	(HL)
	INC	DE
	INC	HL
	JR	NZ, J5297
	LD	A, B
	OR	A
	JP	P, C5286
	LD	A, (HL)
	OR	A
	RET	Z
J5297:	INC	B
	JR	NZ, J52A4
	DEC	HL
J529B:	LD	A, (HL)
	CP	20H	; " "
	INC	HL
	JR	Z, J529B
	DEC	HL
	JR	C5286
;	-----------------
J52A4:	DEC	DE
J52A5:	LD	A, (DE)
	INC	DE
	INC	A
	JR	Z, J52A5
	DEC	A
	JP	P, J52A5
	INC	DE
	INC	DE
	RET
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________


	ALIGNCHK 052B4H

C52B4:	CALL	C55E4
	JP	BRMMBGETBYT
;	-----------------

Q52BA:	CALL	C54E7
	JP	NZ, J676D
	RET
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C52C1:	PUSH	BC
	CALL	C52B4
	JR	J52DA
;	-----------------
Q52C7:	PUSH	BC
	CALL	C55E4
	JR	J52D7
;	-----------------
Q52CD:	CALL	C55E4
	CALL	BRMFRMQNT
	PUSH	DE
	CALL	C55DF
J52D7:	CALL	BRMFRMQNT
J52DA:	CALL	C55E9
	POP	BC
	LD	A, E
	RET
;	-----------------
I52E0:	DEFB	3
	DEFB	1
	DEFB	0
	DEFB	1, 1, 1, 0, 0, 0, 0, 0, 0

;	  Subroutine CALL MUSIC
;	     Inputs  ________________________
;	     Outputs ________________________


BASMUSIC:
	PUSH	HL
	CALL	GET_MSX_INIT
	CALL	Z, C5009
	LD	HL, I52E0
	LD	DE, BUF
	LD	BC, C.000C
	LDIR
	POP	HL
	CALL	C54E7
	JR	Z, J536F
	PUSH	HL
	LD	HL, BUF
	LD	DE, D.F55F
	LD	BC, I.000B
	LD	(HL), 00H
	LDIR
	POP	HL
	CALL	C55E4
	CP	","
	JR	Z, J532A
	CALL	BRMMBGETBYT
	CP	02H	; 2
	JP	NC, ERRILLEGALFNCALL
	LD	(D.F55F), A
	LD	A, (HL)
	CP	")"
	JR	Z, J5369
J532A:	CALL	C55DF
	CP	","
	JR	Z, J533F
	CALL	BRMMBGETBYT
	OR	A
	JR	NZ, J5355
	LD	(D.F560), A
	LD	A, (HL)
	CP	")"
	JR	Z, J5369
J533F:	LD	B, 09H	; 9
	PUSH	HL
	LD	HL, D.F561
	EX	(SP), HL
	LD	C, 00H
J5348:	CALL	C55DF
	PUSH	BC
	CALL	BRMMBGETBYT
	POP	BC
	OR	A
	JR	Z, J5355
	CP	9+1
J5355:	JP	NC, ERRILLEGALFNCALL
	EX	(SP), HL
	LD	(HL), A
	INC	HL
	INC	C
	EX	(SP), HL
	LD	A, (HL)
	CP	29H	; ")"
	JR	Z, J5364
	DJNZ	J5348
J5364:	LD	A, C
	LD	(BUF), A
	POP	BC
J5369:	CALL	C55E9
	JP	NZ, J676D
J536F:	PUSH	HL
	LD	HL, D.F55F
	LD	A, (HL)
	AND	01H	; 1
	LD	D, A
	ADD	A, A
	ADD	A, D
	INC	HL
	ADD	A, (HL)
	INC	HL
	LD	D, A
	LD	A, (BUF)
	LD	B, A
	OR	A
	JR	Z, J5389
	XOR	A
J5385:	ADD	A, (HL)
	INC	HL
	DJNZ	J5385
J5389:	ADD	A, D
	CP	0AH	; 10
	JR	NC, J5355
	CALL	BRMCLOSEIO
	LD	HL, (HIMEM)
	CALL	GET_MSX_INIT
	JR	NZ, J53AF
	LD	DE, I_0327
	AND	A
	SBC	HL, DE
	LD	(HIMEM), HL
	LD	(MUSCWRK), HL
	LD	A, (H.PHYD)
	CP	0C9H
	JR	Z, J53AF
	LD	(HIMSAV), HL
J53AF:	POP	DE
	LD	SP, HL
	PUSH	DE
	CALL	C5407
	LD	HL, (CURLIN)
	LD	(OLDLIN), HL
	LD	HL, BASINITSCPT
	LD	DE, HOLD8
	LD	BC, BASINITLN
	LDIR
	LD	A, (MAXFIL)
	LD	(D_F80B), A
	POP	HL
	LD	A, L
	LD	(D_F813), A
	LD	A, H
	LD	(D_F81B), A
	XOR	A
	LD	(MAXFIL), A
	LD	HL, BUF
	LD	(FILTAB), HL
	LD	HL, D.F560
	LD	(BUF), HL
	LD	(HL), A
	LD	HL, HOLD8
	JP	BRMNEWSTT
;	-----------------

BASINITSCPT:
	DEFB	03AH, 0CDH, 0B7H, 0EFH, 00FH, 000H			; :MAXFILES=0
	DEFB	03AH, 098H, 00CH, 0C0H, 0F6H, 02CH, 00FH, 000H		; :POKE OLDTXT, 0
	DEFB	03AH, 098H, 00CH, 0C1H, 0F6H, 02CH, 00FH, 000H		; :POKE OLDTXT+1, 0
	DEFB	03AH, 099H, 000H, 000H, 000H				; :CONT
BASINITLN	EQU	$-BASINITSCPT

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C5407:	DI
	LD	HL, BUF
	LD	A, (HL)
	LD	(D.F984), A
	INC	HL
	PUSH	HL
	INC	HL
	INC	HL
	LD	DE, I.F985
	LD	BC, I.0009
	LDIR
	POP	HL
	LD	B, (HL)
	INC	HL
	LD	A, (HL)
	LD	HL, 0
	OR	A
J5423:	JR	Z, J542D
	SCF
	RR	H
	RR	L
	DEC	A
	JR	J5423
;	-----------------
J542D:	ADD	HL, HL
	RL	A
	LD	L, H
	LD	H, A
	LD	A, B
	LD	(DRUM_MODE), A
	AND	01H	; 1
	JR	Z, J5446
	SRL	H
	RR	L
	SRL	H
	RR	L
	SRL	H
	RR	L
J5446:	EX	DE, HL
	PUSH	DE
	CALL	C6489
	CALL	C64EE
	CALL	C507F
	POP	DE
	CALL	C5584
	JP	C6556
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

BASBGM:	CALL	C52C1
	CP	02H	; 2
	JP	NC, ERRILLEGALFNCALL
	DEC	A
	LD	(D.F998), A
	RET
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C5465:	CALL	C55E4
	CALL	BRMFRMQNT
	LD	A, (HL)
	CP	29H	; ")"
	PUSH	DE
	JR	Z, J5477
	CALL	C55DF
	CALL	BRMFRMQNT
J5477:	CALL	C55E9
	POP	BC
	LD	A, E
	RET
;	-----------------
Q547D:	LD	A, D
	AND	A
	SCF
	RET	NZ
	LD	A, E
	CP	40H	; "@"
	CCF
	RET
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C5486:	ADD	A, L
	LD	L, A
	RET	NC
	INC	H
	RET
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

BASSTOPM:
	CALL	C54E7
	JP	NZ, J676D
	PUSH	HL
	CALL	C658D
	POP	HL
	OR	A
	RET

;	  Subroutine BASIC HANDLER FOR AUDREG
;	     Inputs  ________________________
;	     Outputs ________________________

BASAUDREG:
	CALL	C55E4
	CALL	BRMMBGETBYT
	PUSH	DE
	CALL	C55DF
	CALL	BRMMBGETBYT
	PUSH	DE
	LD	A, (HL)
	CP	29H	; ")"
	LD	E, 00H
	JR	Z, J54B3
	CALL	C55DF
	CALL	BRMMBGETBYT
J54B3:	CALL	C55E9
	LD	A, E
	OR	A
	JP	NZ, ERRILLEGALFNCALL
	POP	DE
	POP	BC
	LD	B, E
	CALL	C6DB5
	JP	C, ERRILLEGALFNCALL
	RET
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C54C5:	LD	A, 01H	; 1
	LD	(SUBFLG), A
	CALL	BRMPTRGET
	JP	NZ, ERRILLEGALFNCALL
	LD	(SUBFLG), A
	LD	A, (VALTYP)
	CP	03H	; 3
	JP	Z, ERRILLEGALFNCALL
	EX	DE, HL
	ADD	HL, BC
	DEC	HL
	EX	DE, HL
	LD	A, (BC)
	SCF
	RLA
	ADD	A, C
	LD	C, A
	RET	NC
	INC	B
	RET
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C54E7:	DEC	HL
	JP	BRMCHRGTR

;	-----------------

J54EB:	CALL	C54F3
	POP	HL
	CALL	C55E9
	RET
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C54F3:	LD	(DAC+2), HL
	LD	HL, VALTYP
	LD	A, (HL)
	CP	02H	; 2
	JR	Z, J551F
	CP	04H	; 4
	JR	Z, J5511
	CP	08H	; 8
	JP	NZ, J6773
	LD	(HL), 02H	; 2
	PUSH	DE
	CALL	BRMMBCVRT
	LD	C, 08H	; 8
	JR	J5519
;	-----------------
J5511:	LD	(HL), 02H	; 2
	PUSH	DE
	CALL	BRMMBCVRT
	LD	C, 04H	; 4
J5519:	POP	DE
	LD	HL, DAC
	JR	J5524
;	-----------------
J551F:	LD	HL, D.F7F8
	LD	C, 02H	; 2
J5524:	LD	B, 00H
	LDIR
	RET

;	-----------------
;	PITCH STATEMENT
BASPITCH:
	CALL	C5465
	PUSH	HL
	CALL	C6B50
	POP	HL
	JP	C, ERRILLEGALFNCALL
	RET

;	-----------------
BASTRANSPOSE:
	CALL	C5465
	PUSH	HL
	CALL	C6BDA
	POP	HL
	JP	C, ERRILLEGALFNCALL
	RET
;	-----------------
BASTEMPER:
	CALL	C52C1
	LD	C, A
	CALL	C6C9F
	JP	C, ERRILLEGALFNCALL
	RET
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C554C:	PUSH	BC
	PUSH	DE
	PUSH	HL
	LD	B, 01H	; 1
	CALL	C5558
	POP	HL
	POP	DE
	POP	BC
	RET
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C5558:	IN	A, (PPI_SLTREG)
	CALL	C557A
	AND	03H	; 3
	LD	E, A
	LD	D, 00H
	LD	HL, EXPTBL
	ADD	HL, DE
	LD	A, (HL)
	AND	80H
	OR	E
	RET	P
	LD	E, A
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	LD	A, (HL)
	RLCA
	RLCA
	CALL	C557A
	AND	0CH	; 12
	OR	E
	RET
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C557A:	INC	B
	DEC	B
	RET	Z
	PUSH	BC
J557E:	RRCA
	RRCA
	DJNZ	J557E
	POP	BC
	RET
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C5584:	CALL	C6D61
	LD	IX, I.FA27
	LD	BC, I_0900
J558E:	LD	A, C
	ADD	A, 10H	; 16
	LD	(IX), A
	LD	(IX+1), 04H	; 4
	LD	(IX+2), 00H
	LD	(IX+3), 00H
	LD	(IX+4), 00H
	LD	(IX+5), 00H
	LD	(IX+6), 00H
	LD	DE, C.0010
	ADD	IX, DE
	INC	C
J55B2:	DJNZ	J558E
	LD	A, (DRUM_MODE)
	AND	01H	; 1
	CALL	NZ, C6D86
	LD	C, 09H	; 9
	CALL	C6C9F
	LD	IX, I.FA27
	LD	A, (DRUM_MODE)
	AND	01H	; 1
	LD	B, 09H	; 9
	JR	Z, J55D0
	LD	B, 06H	; 6
J55D0:	PUSH	BC
	LD	C, 00H
	CALL	C68E1
	POP	BC
	LD	DE, C.0010
	ADD	IX, DE
	DJNZ	J55D0
	RET
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C55DF:	CALL	C67A7
	INC	L
	RET
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C55E4:	CALL	C67A7
	JR	Z, J55B2

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C55E9:	CALL	C67A7
	ADD	HL, HL
	RET
;	-----------------
BASVOICE:
	CALL	C67A7
	JR	Z, J5604
	LD	E, (HL)
	PUSH	AF
	LD	B, 09H	; 9
J55F7:	LD	A, (HL)
	CP	2CH	; ","
	JR	Z, J561B
	PUSH	BC
	LD	A, 09H	; 9
	SUB	B
	LD	(DE), A
	INC	DE
	PUSH	DE
	LD	A, (HL)
J5604:	CALL	C56C5
	LD	A, 00H
	JR	C, J560C
	CPL
J560C:	EX	(SP), HL
	LD	(HL), A
	INC	HL
	LD	(HL), E
	INC	HL
	LD	(HL), D
	INC	HL
	EX	(SP), HL
	POP	DE
	POP	BC
	LD	A, (HL)
	CP	29H	; ")"
	JR	Z, J5621
J561B:	CALL	C67A7
	INC	L
	DJNZ	J55F7
J5621:	CALL	C67A7
	ADD	HL, HL
	JP	NZ, J676D
	LD	A, 0FFH
	LD	(DE), A
	CALL	C5632
	JP	C, ERRILLEGALFNCALL
	RET
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C5632:	PUSH	HL
	LD	HL, BUF
J5636:	LD	A, (HL)
	CP	0FFH
	JR	Z, J5662
	INC	HL
	CALL	C566D
	LD	A, (HL)
	INC	HL
	OR	A
	JR	Z, J5650
	LD	C, (HL)
	INC	HL
	LD	B, (HL)
	PUSH	HL
	CALL	C68DA
	CALL	C5665
	JR	J565E
;	-----------------
J5650:	LD	C, (HL)
	LD	A, C
	CP	40H	; "@"
	CCF
	RET	C
	INC	HL
	PUSH	HL
	CALL	C68E1
	CALL	C5665
J565E:	POP	HL
	INC	HL
	JR	J5636
;	-----------------
J5662:	POP	HL
	OR	A
	RET
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C5665:	PUSH	BC
	LD	BC, C.0010
	ADD	IX, BC
	POP	BC
	RET
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C566D:	LD	IX, I.FA27
	OR	A
	RET	Z
	PUSH	BC
	LD	BC, C.0010
J5677:	ADD	IX, BC
	DEC	A
	JR	NZ, J5677
	POP	BC
	RET
;	-----------------
BASVOICECOPY:
	CALL	C67A7
	JR	Z, J5650
	PUSH	BC
	LD	D, (HL)
	CCF
	SBC	A, A
	LD	(BUF), A
	LD	(D.F55F), DE
	LD	(D.F561), BC
	CALL	C67A7
	INC	L
	CALL	C56C5
	CCF
	SBC	A, A
	LD	(D.F563), A
	LD	(D.F564), DE
	LD	(D_F566), BC
	JR	NZ, J56AD
	LD	A, E
	CP	20H	; " "
	JR	C, J56DE
J56AD:	CALL	C67A7
	ADD	HL, HL
	JP	NZ, J676D
	PUSH	HL
	LD	HL, BUF
	LD	A, (D.F563)
	AND	(HL)
	JR	NZ, J56DE
	CALL	C56F9
	JR	C, J56DE
	POP	HL
	RET
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C56C5:	CP	40H	; "@"
	JR	Z, J56D5
	CP	0F3H
	JR	NZ, J56E1
	CALL	BRMCHRGTR
	LD	DE, I_00FF
	SCF
	RET
;	-----------------
J56D5:	CALL	BRMCHRGTR
	CALL	BRMMBGETBYT
	CP	40H	; "@"
	RET	C
J56DE:	JP	ERRILLEGALFNCALL
;	-----------------
J56E1:	CALL	C56EF
	LD	A, E
	AND	0E0H
	OR	D
	JR	Z, J56DE
	PUSH	DE
	LD	E, C
	LD	D, B
	POP	BC
	RET
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C56EF:	CALL	C54C5
	EX	DE, HL
	OR	A
	SBC	HL, BC
	INC	HL
	EX	DE, HL
	RET
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C56F9:	LD	A, (D.F563)
	LD	HL, (D.F564)
	OR	A
	JR	NZ, J570D
	LD	A, L
	INC	A
	SCF
	RET	Z
	CP	40H	; "@"
	SCF
	RET	NZ
	LD	HL, I.F9F9
J570D:	PUSH	HL
	LD	A, (BUF)
	LD	HL, (D.F55F)
	OR	A
	JR	NZ, J5725
	LD	A, L
	CP	0FFH
	JR	Z, J572F
	LD	C, A
	CALL	C690F
	JR	Z, J572F
	CALL	C5732
J5725:	POP	DE
	LD	BC, C.0020
	DI
	LDIR
	OR	A
	EI
	RET
;	-----------------
J572F:	POP	HL
	SCF
	RET
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C5732:	LD	A, L
	CP	3FH	; "?"
	LD	HL, I.F9F9
	RET	Z
	LD	L, A
	LD	H, 00H
	ADD	HL, HL
	ADD	HL, HL
	ADD	HL, HL
	ADD	HL, HL
	ADD	HL, HL
	LD	DE, I6E0C
	ADD	HL, DE
	RET
;	-----------------
BASPLAY:
	CALL	C52B4
	LD	A, (PVOICE_CNT)
	CP	E
	JP	C, ERRILLEGALFNCALL
	LD	A, E
	PUSH	HL
	CALL	C5760
	EX	(SP), HL
	CALL	C55DF
	CALL	BRMPTRGET
	EX	(SP), HL
	JP	J54EB
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C5760:	LD	HL, (D.F995)
	OR	A
	JR	NZ, J5771
	LD	A, H
	AND	1FH
	OR	L
	JR	Z, J576E
	LD	A, 0FFH
J576E:	LD	L, A
J576F:	LD	H, A
	RET
;	-----------------
J5771:	SRL	H
	RR	L
	DEC	A
	JR	NZ, J5771
	SBC	A, A
	JR	J576E
;	-----------------

; convert dac to integer routine
; copied to CODEBUF for execution

I577B:	LD	A, (MUSCSLID)
	PUSH	AF
	PUSH	BC
	PUSH	DE
	PUSH	HL
	LD	A, (EXPTBL)
	LD	H, 40H	; "@"
	CALL	ENASLT
	POP	HL
	POP	DE
	POP	BC
	CALL	C_2F8A
	POP	AF
	PUSH	AF
	PUSH	BC
	PUSH	DE
	PUSH	HL
	LD	H, 40H	; "@"
	CALL	ENASLT
	POP	HL
	POP	DE
	POP	BC
	POP	AF
	EI
	RET
;	-----------------
I57A0:	DEFB	" "

;	  Subroutine H.PLAY handler
;	     Inputs  ________________________
;	     Outputs ________________________


C57A1:	CALL	MEMCHK
	CALL	C57D9
	PUSH	HL
	LD	A, (MUSCSLID)
	DI
	ADD	A, A
	LD	HL, 8
	JR	NC, J57B4
	LD	L, 8+8
J57B4:	ADD	HL, SP
	PUSH	HL
	LD	E, (HL)
	INC	HL
	LD	D, (HL)
	LD	HL, I73E8
	OR	A
	SBC	HL, DE
	JP	NZ, J6764
	POP	HL
	DEC	HL			; stack filled by CALLF
	LD	D, H
	LD	E, L
	INC	DE
	INC	DE
	LD	A, (MUSCSLID)
	ADD	A, A
	LD	BC, 8
	JR	NC, J57D3
	LD	C, 8+8
J57D3:	LDDR				; move 1 word up
	EI
	POP	HL			; discharged returnadres
	POP	HL			; restore basicpointer
	RET


;	Handle PLAY statement
;	  Inputs:  ________________________
;	  Outputs: ________________________

C57D9:	CP	"#"			; play device specified ?
	JR	NZ, J57F8		; nope, use PSG
	CALL	BRMCHRGTR		; read "#" char
	CALL	BRMMBGETBYT		; evaluate byte operand
	PUSH	AF
	CALL	C55DF			; check for ","
	POP	AF
	OR	A			; PLAY #0 ?
	JR	Z, J57F8			; yep, PSG
	DEC	A
	JR	Z, J57F2			; 1, for MIDI
	SUB	3
	JR	C, J582B			; 2-3, for OPLL/PSG
J57F2:	JP	ERRILLEGALFNCALL

	; DEAD CODE - NO MIDI SUPPORT
	INC	A			; set PLAY MIDI flag (NOT IMPLEMENTED)
	JR	J582C

J57F8:	XOR	A
	LD	(D.F97F), A		; reset PLAY MIDI flag????
	PUSH	HL
	LD	A, (OPL_PVOICE_CNT)
	OR	A			; no OPLL playvoices initialized ?
	JR	Z, J5821			; yep, skip
	LD	B, A
J5804:	PUSH	BC
	LD	A, B
	DEC	A
	CALL	GET_CURVC_STRLEN	; get pointer to stringlength in voicebuffer
	LD	DE, I57A0
	LD	(HL), 1			; stringlength=1
	INC	HL
	LD	(HL), E
	INC	HL
	LD	(HL), D			; pointer to special nothing string
	INC	HL
	LD	D, H
	LD	E, L			; stack data
	LD	BC, 28
	ADD	HL, BC
	EX	DE, HL
	LD	(HL), E
	INC	HL
	LD	(HL), D
	POP	BC
	DJNZ	J5804			; next OPLL playvoice
J5821:	POP	HL
	XOR	A
	LD	(PRSCNT), A		; no strings are completed
	LD	A, (OPL_PVOICE_CNT)	; start with the first PSG playvoice
	JR	J5833

;	-----------------
J582B:	XOR	A			; reset PLAY MIDI flag?
J582C:	LD	(D.F97F), A
	XOR	A
	LD	(PRSCNT), A		; no strings are completed
					; start with playvoice 0
J5833:	PUSH	HL
	LD	HL, -10
	ADD	HL, SP
	LD	(SAVSP), HL
	POP	HL
	PUSH	AF
J583D:	PUSH	HL
	LD	HL, I577B
	LD	DE, CODE_BUF
	LD	BC, I57A0-I577B
	LDIR				; install convert DAC to integer routine in BUF
	POP	HL
	CALL	BRMFRMEVL		; evaluate expression
	EX	(SP), HL		; save basicpointer, get playvoice
	PUSH	HL
	CALL	BRMFRESTR		; free temporary string
	CALL	C6834
	LD	A, E
	OR	A
	JR	NZ, J585E
	LD	DE, I_A001
	LD	C, 57H	; "W"
J585E:	POP	AF
	PUSH	AF
	CALL	C5F02
	XOR	A
	LD	(IX), A			; nothing to correct
	POP	AF			; playvoice
	PUSH	AF
	CALL	GET_CURVC_STRLEN	; get pointer to stringlength in voicebuffer
	LD	(HL), E
	INC	HL
	LD	(HL), D
	INC	HL
	LD	(HL), C			; pointer to string
	INC	HL
	LD	D, H
	LD	E, L			; stack data
	LD	BC, 28
	ADD	HL, BC
	EX	DE, HL
	LD	(HL), E
	INC	HL
	LD	(HL), D
	POP	BC			; playvoice
	POP	HL			; basicpointer
	INC	B			; next playvoice
	LD	A, (PVOICE_CNT)		; number of playvoices
	DEC	A
	CP	B
	JR	C, J58A8
	DEC	HL
	CALL	BRMCHRGTR
	JR	Z, J5892
	PUSH	BC
	CALL	C55DF
	JR	J583D

;	-----------------
J5892:	LD	A, B
	LD	(VOICEN), A		; current playvoice
	PUSH	BC
	PUSH	HL
	CALL	C59AF			; update output device status
	POP	HL
	POP	BC
	CALL	C5995			; put end byte in queue
	INC	B			; next playvoice
	LD	A, (PVOICE_CNT)		; number of playvoices
	DEC	A
	CP	B			; any playvoices left ?
	JR	NC, J5892		; yep,

J58A8:	DEC	HL
	CALL	BRMCHRGTR		; end of statement ?
	JP	NZ, J676D		; nope, error

	PUSH	HL
J58B0:	XOR	A			; start with playvoice 0
J58B1:	PUSH	AF
	LD	(VOICEN), A		; current playvoice
	LD	C, A
	LD	A, (PVOICE_CNT)		; number of playvoices
	SUB	C
	SUB	4
	LD	HL, MCL_FOR_PSG		; jump table for Macro Language parser PSG
	JR	C, J58D0
	LD	HL, MCL_FOR_OPLL	; jump table for Macro Language parser OPLL
	JR	NZ, J58D0
	LD	A, (DRUM_MODE)
	AND	01H			; in drum mode ?
	JR	Z, J58D0			; nope, FM playvoice
	LD	HL, MCL_FOR_DRUMS	; yep, drum playvoice, use MCL for drums
J58D0:	LD	(MCLTAB), HL
	LD	A, C
	LD	B, A
	CALL	VQC_IS_AT_CAPACITIY	; less then 8 bytes free in voice queue ?
	JP	C, J5957			; yep, skip to the next voice
	LD	A, B
	CALL	GET_CURVC_STRLEN	; get pointer to stringlength in voicebuffer
	LD	A, (HL)
	OR	A			; playstring length 0 ?
	JP	Z, J5957			; yep, skip to the next voice
	LD	(MCLLEN), A		; length of playstring
	INC	HL
	LD	E, (HL)
	INC	HL
	LD	D, (HL)
	INC	HL
	LD	(MCLPTR), DE		; pointer to playstring
	LD	E, (HL)
	INC	HL
	LD	D, (HL)			; stack data address
	INC	HL
	PUSH	HL
	LD	L, VCBUF_STACKEND
	CALL	GET_CURVC_BUFADDR	; get pointer in current voicebuffer
	PUSH	HL			; top of voicebuffer stack
	LD	HL, (SAVSP)
	DEC	HL
	POP	BC
	DI
	CALL	C6827
	POP	DE
	LD	H, B
	LD	L, C
	LD	SP, HL
	EI
	CALL	C59AF			; update output device status
	JP	J65C6			; start MCL parser
;	-----------------
J590F:	LD	A, (MCLLEN)
	OR	A			; parsed the whole playstring ?
	JR	NZ, J5918		; nope, skip the end byte
J5915:	CALL	C5995			; put end byte in queue
J5918:	LD	A, (VOICEN)		; current playvoice
	CALL	GET_CURVC_STRLEN	; get pointer to stringlength in voicebuffer
	LD	A, (MCLLEN)
	LD	(HL), A
	INC	HL
	LD	DE, (MCLPTR)
	LD	(HL), E
	INC	HL
	LD	(HL), D			; update playstring
	LD	HL, 0
	ADD	HL, SP
	EX	DE, HL
	LD	HL, (SAVSP)
	DI
	LD	SP, HL			; restore stackpointer
	POP	BC
	POP	BC
	POP	BC
	PUSH	HL
	OR	A
	SBC	HL, DE			; stack clear ?
	JR	Z, J5955			; yep,
	LD	A, 0F0H
	AND	L
	OR	H
	JP	NZ, ERRILLEGALFNCALL	; illegal function call
	LD	L, VCBUF_STACKEND
	CALL	GET_CURVC_BUFADDR	; get pointer in current voicebuffer
	POP	BC
	DEC	BC
	CALL	C6827			; copy
	POP	HL
	DEC	HL
	LD	(HL), B
	DEC	HL
	LD	(HL), C
	JR	J5957
;	-----------------
J5955:	POP	BC
	POP	BC
J5957:	EI
	POP	AF
	INC	A
	LD	HL, PVOICE_CNT
	CP	(HL)			; number of playvoices
	JP	C, J58B1			; next playvoice
	DI
	CALL	C63B1			; check if CTRL-STOP
	JR	Z, J598F			; yep,
	LD	A, (PRSCNT)
	RLCA				; b7 set ?
	JR	C, J5978			; yep, music dequeing already started
	LD	HL, D.F997
	INC	(HL)
	LD	A, (HL)
	LD	(PLYCNT), A		; increase PLYCNT
	CALL	C683D			; start music dequeuing
J5978:	EI
	LD	HL, PRSCNT
	SET	7, (HL)			; b7 set
	LD	A, (HL)
	LD	HL, D.F993
	CP	(HL)			; last playvoice ?
	JP	NZ, J58B0		; nope, start again
	LD	A, (D.F998)
	OR	A			; background music ?
	CALL	NZ, C639D		; nope, wait until played
	JR	NC, J5993		; not CTRL-STOP, quit
J598F:	CALL	C658D			; stop background music
	EI
J5993:	POP	HL
	RET

;	Put end byte in queue (EI)
;	  Inputs:  ________________________
;	  Outputs: ________________________

C5995:	LD	A, (PRSCNT)
	INC	A
	LD	(PRSCNT), A		; an other string is completed
	LD	E, 0FFH			; end of data byte

;	Put byte in queue.
;	  Inputs:  (E = byte)
;	  Outputs: (________________________)

C599E:	PUSH	HL
	PUSH	BC
J59A0:	PUSH	DE
	LD	A, (VOICEN)		; current playvoice
	DI
	CALL	C66F9			; put in voice queue
	EI
	POP	DE
	JR	Z, J59A0			; queue full, wait
J59AC:	POP	BC
	POP	HL
	RET
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C59AF:	LD	HL, VOICEN
	LD	A, (OPL_PVOICE_CNT)	; number of OPLL playvoices
	DEC	A
	CP	(HL)			; current playvoice = last OPLL playvoice ?
	RET	NZ			; nope, quit
	LD	A, (D.F97F)
	LD	HL, D.F980
	CP	(HL)			; last PLAY statement to the same device as current ?
	RET	Z			; yep, quit
	LD	(HL), A			; new status
	LD	A, 88H
	OR	(HL)
	LD	E, A			; 88H for MUSIC/PSG, 89H for MIDI

;	  Put byte in queue (DI)
;	     Inputs  E = byte
;	     Outputs ________________________

C59C5:	PUSH	HL
	PUSH	BC
J59C7:	PUSH	DE
	LD	A, (VOICEN)
	DI
	CALL	C66F9
	POP	DE
	JR	NZ, J59AC
	EI
	JR	J59C7
;	-----------------

;	Current voice's queue has less then 8 bytes free
;	  Inputs  ________________________
;	  Outputs (Flag C is SET if true)

VQC_IS_AT_CAPACITIY:
	LD	A, (VOICEN)		; current playvoice
	PUSH	BC
	DI
	CALL	VQ_GET_FREE		; get free space voice queue
	EI
	POP	BC
	CP	8
	RET

;	-----------------
MCL_FOR_PSG:
	DEFB	"A"
	DEFW	C5B1D
	DEFB	"M"+128
	DEFW	C5A54
	DEFB	"V"+128
	DEFW	C5A3D
	DEFB	"S"+128
	DEFW	C5A76
	DEFB	"N"+128
	DEFW	C5ADA
	DEFB	"O"+128
	DEFW	C5AA6
	DEFB	"R"+128
	DEFW	J5AB5
	DEFB	"T"+128
	DEFW	C5A99
	DEFB	"L"+128
	DEFW	C5A80
	DEFB	"X"
	DEFW	C66DB
	DEFB	">"
	DEFW	C5DAB
	DEFB	"<"
	DEFW	C5DB8
	DEFB	"Y"+128
	DEFW	C5C04
	DEFB	"Q"+128
	DEFW	C5C1A
	DEFB	"@"
	DEFW	C5C29
	DEFB	"&"
	DEFW	C5C03
	DEFB	"Z"+128
	DEFW	J5C25
	DEFB	00

I5A16:
	DEFB	010h, 012h, 014h, 016h, 000h, 000h, 002h, 004h, 006h, 008h, 00Ah, 00Ah, 00Ch, 00Eh, 010h

I5A25:
	DEFB	05Dh, 00Dh, 09Ch, 00Ch, 0E7h, 00Bh, 03Ch, 00Bh, 09Bh, 00Ah, 002h, 00Ah, 073h, 009h
	DEFB	0EBh, 008h, 06Bh, 008h, 0F2h, 007h, 080h, 007h, 014h, 007h

	ALIGNCHK	05A3DH

C5A3D:
	JR	C, J5A41
	LD	E, 08H	; 8
J5A41:	LD	A, 0FH	; 15
	CP	E
	JR	C, J5A96
J5A46:	CALL	C5C41
	LD	L, VCBUF_VOLUME
	CALL	GET_CURVC_BUFADDR
	LD	A, 40H	; "@"
	AND	(HL)
	OR	E
	LD	(HL), A
	RET
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C5A54:	LD	A, E
	JR	C, J5A5A
	CPL
	INC	A
	LD	E, A
J5A5A:	OR	D
	JR	Z, J5A96
	LD	L, VCBUF_ENVPERIOD
	CALL	GET_CURVC_BUFADDR
	PUSH	HL
	LD	A, (HL)
	INC	HL
	LD	H, (HL)
	LD	L, A
	CALL	C68D4
	POP	HL
	RET	Z
	LD	(HL), E
	INC	HL
	LD	(HL), D
	DEC	HL
	DEC	HL
	LD	A, 40H	; "@"
	OR	(HL)
	LD	(HL), A
	RET
;	-----------------
C5A76:	LD	A, E
	CP	10H	; 16
	JR	NC, J5A96
	OR	10H	; 16
	LD	E, A
	JR	J5A46
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C5A80:	JR	C, J5A84
	LD	E, 04H	; 4
J5A84:	LD	A, E
	CP	41H	; "A"
	JR	NC, J5A96
	LD	L, VCBUF_LENGTH
J5A8B:	CALL	GET_CURVC_BUFADDR
	CALL	C5C41
	OR	E
	JR	Z, J5A96
	LD	(HL), A
	RET
;	-----------------
J5A96:	JP	ERRILLEGALFNCALL
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C5A99:	JR	C, J5A9D
	LD	E, 78H	; "x"
J5A9D:	LD	A, E
	CP	20H	; " "
	JR	C, J5A96
	LD	L, 11H	; 17
	JR	J5A8B
;	-----------------
C5AA6:	JR	C, J5AAA
	LD	E, 04H	; 4
J5AAA:	LD	A, E
	CP	09H	; 9
	JR	NC, J5A96
	LD	L, 0FH	; 15
	JR	J5A8B
;	-----------------
J5AB3:	XOR	A
	LD	D, A
J5AB5:	JR	C, J5AB9
	LD	E, 04H	; 4
J5AB9:	XOR	A
	OR	D
	JR	NZ, J5A96
	OR	E
	JR	Z, J5A96
	CP	41H	; "A"
	JR	NC, J5A96
J5AC4:	LD	HL, 0
	PUSH	HL
	LD	L, VCBUF_LENGTH
	CALL	GET_CURVC_BUFADDR
	PUSH	HL
	INC	HL
	INC	HL
	LD	A, (HL)
	LD	(SAVVOL), A
	LD	(HL), 80H
	DEC	HL
	DEC	HL
	JR	J5B58
;	-----------------
C5ADA:	JR	NC, J5A96
	CALL	C5C41
	OR	E
	JR	Z, J5AC4
	CP	61H	; "a"
	JR	NC, J5A96
	LD	A, E
	LD	B, 00H
	LD	E, B
J5AEA:	SUB	0CH	; 12
	INC	E
	JR	NC, J5AEA
	ADD	A, 0CH	; 12
	ADD	A, A
	LD	C, A
	JP	J5B2D
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C5AF6:	LD	B, C
	LD	A, C
	SUB	40H	; "@"
	ADD	A, A
	LD	C, A
	CALL	C661A
	JR	Z, J5B1B
	CP	23H	; "#"
	RET	Z
	CP	2BH	; "+"
	RET	Z
	CP	2DH	; "-"
	JR	Z, J5B10
	CALL	C6640
	JR	J5B1B
;	-----------------
J5B10:	DEC	C
	LD	A, B
	CP	43H	; "C"
	JR	Z, J5B1A
	CP	46H	; "F"
	JR	NZ, J5B1B
J5B1A:	DEC	C
J5B1B:	DEC	C
	RET

;	  Subroutine PSG MCL "ABCDEFG"
;	     Inputs  ________________________
;	     Outputs ________________________


C5B1D:	CALL	C5AF6			; get notenumber
	LD	L, VCBUF_OCTAVE
	CALL	GET_CURVC_BUFADDR	; get pointer in current voicebuffer
	LD	E, (HL)			; octave
	LD	B, 00H
	LD	HL, I5A16
	ADD	HL, BC
	LD	C, (HL)			; offset
J5B2D:	LD	HL, I5A25
	ADD	HL, BC
	LD	A, E			; octave
	LD	E, (HL)
	INC	HL
	LD	D, (HL)			; tone divider
J5B35:	DEC	A
	JR	Z, J5B41
	SRL	D
	RR	E
	JR	J5B35
;	-----------------
J5B3E:	CALL	ERRILLEGALFNCALL
J5B41:	ADC	A, E
	LD	E, A
	ADC	A, D
	SUB	E
	LD	D, A
	PUSH	DE
	LD	L, VCBUF_LENGTH
	CALL	GET_CURVC_BUFADDR	; get pointer in current voicebuffer
	LD	C, (HL)			; length
	PUSH	HL
	CALL	C661A			; get MCL char
	JR	Z, J5B64			; end of string, use default length
	PUSH	BC
	CALL	C6651			; evaluate number in MCL
	POP	BC
J5B58:	LD	A, 40H	; "@"
	CP	E			; length specified 0-64
	JR	C, J5B3E			; nope, illegal function call
	CALL	C5C41			; check for byte value
	OR	E			; yep, use default length
	JR	Z, J5B64
	LD	C, E
J5B64:	POP	HL
	INC	HL			; points to tempo
	PUSH	HL
	CALL	C5EB0			; get duration
	EX	DE, HL
	LD	BC, -9
	POP	HL
	PUSH	HL
	ADD	HL, BC			; points to music packet
	LD	(HL), D
	INC	HL
	LD	(HL), E
	INC	HL
	LD	C, 02H	; 2
	EX	(SP), HL
	INC	HL
	LD	E, (HL)			; volume
	LD	A, E
	AND	0BFH			; clear envelope flag
	LD	(HL), A
	EX	(SP), HL
	LD	A, 80H
	OR	E
	LD	(HL), A			; amplitude block
	INC	HL
	INC	C
	EX	(SP), HL
	LD	A, E
	AND	40H			; envelope changed ?
	JR	Z, J5B97			; nope,
	INC	HL
	LD	E, (HL)
	INC	HL
	LD	D, (HL)			; envelope
	POP	HL
	LD	(HL), D
	INC	HL
	LD	(HL), E
	INC	HL
	INC	C
	INC	C
	CP	0E1H
J5B97	EQU	$-1			; POP HL
	POP	DE
	LD	A, D
	OR	E			; rest ?
	JR	Z, J5BA2			; yep, skip frequency block
	LD	(HL), D
	INC	HL
	LD	(HL), E
	INC	C
	INC	C
J5BA2:	LD	L, VCBUF_PCKLEN
	CALL	GET_CURVC_BUFADDR	; get pointer in current voicebuffer
	LD	(HL), C			; size of music packet
	LD	A, C
	SUB	02H
	RRCA
	RRCA
	RRCA
	INC	HL
	OR	(HL)
	LD	(HL), A
	DEC	HL
	LD	A, D
	OR	E			; rest ?
	JR	NZ, J5BC2		; nope,
	PUSH	HL
	LD	A, (SAVVOL)
	OR	80H
	LD	BC, I.000B
	ADD	HL, BC
	LD	(HL), A
	POP	HL
J5BC2:	POP	DE
	LD	B, (HL)			; size
	INC	HL
J5BC5:	LD	E, (HL)			; data
	INC	HL
	CALL	C599E			; put byte in queue (EI)
	DJNZ	J5BC5			; next byte
	CALL	VQC_IS_AT_CAPACITIY	; less then 8 bytes free in voice queue ?
	JP	C, J590F			; yep, stop parsing
	JP	J65C6			; start MCL parser
;	-----------------

;	  Subroutine divide
;	     Inputs  DE = param, HL = divider
;	     Outputs HL = remainer, DE = result

	ALIGNCHK	05BD5H
DIV_DE_BY_HL:
	LD	B, H
	LD	C, L
	XOR	A
	LD	H, A
	LD	L, A
	PUSH	HL
	SBC	HL, BC
	EX	DE, HL			; DE = -param1
	ADD	HL, HL
	LD	A, H
	LD	C, L
	POP	HL			; HL = 0
	LD	B, 10H
DIV_DE_BY_HL_1:
	ADC	HL, HL
	ADD	HL, DE
	JR	C, DIV_DE_BY_HL_2
	SBC	HL, DE
DIV_DE_BY_HL_2:
	RL	C
	RLA
	DJNZ	DIV_DE_BY_HL_1
	LD	D, A
	LD	E, C
	RET
;	-----------------

;	  Subroutine multiply
;	     Inputs  BC and A________________________
;	     Outputs HL = BC * A

MUL_BC_BY_A:
	LD	E, 8
	LD	HL, 0

MUL_BC_BY_A_1:
	ADD	HL, HL
	RLA
	JR	NC, MUL_BC_BY_A_2
	ADD	HL, BC
	ADC	A, 0

MUL_BC_BY_A_2:
	DEC	E
	JP	NZ, MUL_BC_BY_A_1
C5C03:
	RET

;	-----------------
C5C04:	JR	NC, J5C44
	LD	A, E
	CP	0C9H
	JR	NC, J5C44
	CALL	C5C41
	CALL	C661A
	CP	2CH	; ","
	JR	NZ, J5C44
	CALL	C664E
	JR	C5C41
;	-----------------
C5C1A:	JR	C, J5C1E
	LD	E, 08H	; 8
J5C1E:	LD	A, E
	CP	09H	; 9
	JR	NC, J5C44
	JR	C5C41
;	-----------------
J5C25:	JR	NC, J5C44
	JR	C5C41
;	-----------------
C5C29:	CALL	C6614
	CP	56H	; "V"
	JR	Z, J5C47
	CP	57H	; "W"
	JR	Z, J5C5A
	CALL	C5D27
	JR	C, J5C44
	CALL	C6651
	LD	A, E
	CP	40H	; "@"
	JR	NC, J5C44

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C5C41:	LD	A, D
	OR	A
	RET	Z
J5C44:	JP	ERRILLEGALFNCALL
;	-----------------
J5C47:	CALL	C661A
	RET	Z
	CALL	C5D27
	JR	C, J5C44
	CALL	C6651
	LD	A, E
	CP	80H
	JR	NC, J5C44
	JR	C5C41
;	-----------------
J5C5A:	CALL	C661A
	JR	Z, J5C6D
	CALL	C5D27
	JR	C, J5C6A
	CALL	C6651
	JP	J5AB9
;	-----------------
J5C6A:	CALL	C6640
J5C6D:	JP	J5AB3
;	-----------------

MCL_FOR_OPLL:
	DEFB	"A"
	DEFW	C5DED
        DEFB	"&"
	DEFW	C5F11
        DEFB	"{"
	DEFW	C5F1A
        DEFB	"}"+128
	DEFW	C5F96
        DEFB	"Y"+128
	DEFW	C5D37
        DEFB	"L"+128
	DEFW	C5A80
        DEFB	"Q"+128
	DEFW	C5D9D
        DEFB	"V"+128
	DEFW	C5D64
        DEFB	"O"+128
	DEFW	C5AA6
        DEFB	">"
	DEFW	C5DAB
        DEFB	"<"
	DEFW	C5DB8
        DEFB	"Z"+128
	DEFW	J5D61
        DEFB	"X"
	DEFW	C66DB
        DEFB	"R"+128
	DEFW	J5DC3
        DEFB	"N"+128
	DEFW	C5DE0
        DEFB	"T"+128
	DEFW	C5A99
        DEFB	"@"
	DEFW	C5CAA
        DEFB	"M"+128
	DEFW	C5D8E
        DEFB	"S"+128
	DEFW	C5D95
	DEFB	00

	ALIGNCHK 05CAAH
C5CAA:	CALL	C6614
	CP	56H	; "V"
	JR	Z, J5CDD
	CP	57H	; "W"
	JR	Z, J5CFD
	CALL	C5D27
	JR	C, J5D06
	CALL	C6651
	CALL	C5C41
	LD	A, E
	CP	40H	; "@"
	JR	NC, J5D06
	LD	C, A
	LD	A, (VOICEN)
	CALL	C619F
	JR	NC, J5CD3
	LD	A, C
	CP	10H	; 16
	JR	NC, J5D06
J5CD3:	LD	E, 84H
	CALL	C59C5
	LD	E, C
	POP	BC
	JP	J5E75
;	-----------------
J5CDD:	CALL	C6614
	CALL	C5D27
	JR	C, J5D06
	CALL	C6651
	LD	A, 7FH
	SUB	E
	JP	M, J5D06
	RRA
	LD	C, A
	CALL	C5C41
	LD	E, 85H
	CALL	C59C5
	LD	E, C
	POP	BC
	JP	J5E75
;	-----------------
J5CFD:	POP	DE
	CALL	C5D09
	LD	E, 83H
	JP	J5E6D
;	-----------------
J5D06:	JP	ERRILLEGALFNCALL
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C5D09:	CALL	C5E82
	PUSH	HL
	CALL	C661A
	JR	Z, J5D23
	PUSH	BC
	CALL	C6651
	POP	BC
	LD	A, 40H	; "@"
	CP	E
	JR	C, J5D06
	CALL	C5C41
	OR	E
	JR	Z, J5D06
	LD	C, E
J5D23:	POP	HL
	JP	J5EAF
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C5D27:	CP	2BH	; "+"
	RET	Z
	CP	2DH	; "-"
	RET	Z
	CP	3DH	; "="
	RET	Z
	CP	30H	; "0"
	RET	C
	CP	3AH	; ":"
	CCF
	RET
;	-----------------
C5D37:	JR	NC, J5D61
	LD	A, E
	CALL	C6DF3
	JR	C, J5D61
	CALL	C5C41
	PUSH	DE
	CALL	C6614
	CP	2CH	; ","
	JR	NZ, J5D61
	CALL	C664E
	CALL	C5C41
	PUSH	DE
	LD	E, 82H
	CALL	C59C5
	POP	HL
	EX	(SP), HL
	LD	E, L
	CALL	C59C5
	POP	DE
	POP	BC
	JP	J5E75
;	-----------------
J5D61:	JP	ERRILLEGALFNCALL
;	-----------------
C5D64:	JR	C, J5D68
	LD	E, 08H	; 8
J5D68:	CALL	C5C41
	LD	A, E
	CP	10H	; 16
	JR	NC, J5D92
J5D70:	LD	C, A
	LD	E, 81H
	CALL	C59C5
	LD	E, C
	POP	BC
	JP	J5E75
;	-----------------
C5D7B:	JR	C, J5D7F
	LD	E, 08H	; 8
J5D7F:	CALL	C5C41
	LD	A, E
	CP	10H	; 16
	JR	NC, J5D92
	LD	A, 0FH	; 15
	SUB	E
	ADD	A, A
	LD	E, A
	JR	J5D70
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C5D8E:	RET	NC
	LD	A, E
	OR	D
	RET	NZ
J5D92:	JP	ERRILLEGALFNCALL
;	-----------------
C5D95:	LD	A, E
	CP	10H	; 16
	JR	NC, J5D92
	JP	C5C41
;	-----------------
C5D9D:	JR	C, J5DA1
	LD	E, 08H	; 8
J5DA1:	LD	A, E
	CP	09H	; 9
	JR	NC, J5D92
	LD	L, 26H	; "&"
	JP	J5A8B
;	-----------------
C5DAB:	LD	L, VCBUF_OCTAVE
	CALL	GET_CURVC_BUFADDR
	LD	A, (HL)
	INC	A
	CP	09H	; 9
	JR	NC, J5D92
	LD	(HL), A
	RET
;	-----------------
C5DB8:	LD	L, VCBUF_OCTAVE
	CALL	GET_CURVC_BUFADDR
	LD	A, (HL)
	DEC	A
	JR	Z, J5D92
	LD	(HL), A
	RET
;	-----------------
J5DC3:	JR	C, J5DC7
	LD	E, 04H	; 4
J5DC7:	CALL	C5C41
	OR	E
	JR	Z, J5D92
	CP	41H	; "A"
	JR	NC, J5D92
	XOR	A
	PUSH	AF
	LD	HL, I5E11
	PUSH	HL
	LD	L, VCBUF_LENGTH
	CALL	GET_CURVC_BUFADDR
	PUSH	HL
	JP	J5EA2
;	-----------------
C5DE0:	JR	NC, J5D92
	CALL	C5C41
	LD	A, E
	CP	61H	; "a"
	JR	C, J5E07
	JP	ERRILLEGALFNCALL
;	-----------------
C5DED:	CALL	C5AF6
	LD	L, VCBUF_OCTAVE
	CALL	GET_CURVC_BUFADDR
	LD	D, 0CH	; 12
	LD	B, (HL)
	LD	A, 0F4H
J5DFA:	ADD	A, D
	DJNZ	J5DFA
	LD	D, A
	LD	B, 00H
	LD	HL, I5A16
	ADD	HL, BC
	LD	A, (HL)
	RRCA
	ADD	A, D
J5E07:	ADD	A, 0CH	; 12
	LD	D, A
	CALL	C6C82
	PUSH	DE
	CALL	C5E94
I5E11:	PUSH	HL
	CALL	C661A
	JR	Z, J5E20
	CP	26H	; "&"
	PUSH	AF
	CALL	C6640
	POP	AF
	JR	Z, J5E61
J5E20:	LD	L, VCBUF_UNKNOWN
	CALL	GET_CURVC_BUFADDR
	LD	A, (HL)
	CP	08H	; 8
	JR	Z, J5E61
	POP	DE
	PUSH	DE
	LD	B, A
	LD	HL, 0
J5E30:	ADD	HL, DE
	DJNZ	J5E30
	SRL	H
	RR	L
	SRL	H
	RR	L
	SRL	H
	RR	L
	POP	DE
	EX	DE, HL
	OR	A
	SBC	HL, DE
	EX	DE, HL
	JR	Z, J5E62
	POP	BC
	POP	AF
	PUSH	DE
	LD	E, B
	CALL	C59C5
	LD	A, B
	OR	A
	LD	E, C
	CALL	NZ, C59C5
	LD	E, L
	CALL	C59C5
	LD	E, H
	CALL	C59C5
	POP	HL
	LD	E, 00H
	JR	J5E6D
;	-----------------
J5E61:	POP	HL
J5E62:	POP	BC
	POP	DE
	LD	E, B
	CALL	C59C5
	LD	A, B
	OR	A
	JR	Z, J5E70
	LD	E, C
J5E6D:	CALL	C59C5
J5E70:	LD	E, L
	CALL	C59C5
	LD	E, H
J5E75:	CALL	C59C5
	CALL	VQC_IS_AT_CAPACITIY
	EI
	JP	C, J590F
	JP	J65C6
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C5E82:	LD	L, VCBUF_PACKET+1
	CALL	GET_CURVC_BUFADDR
	LD	C, (HL)
	LD	A, C
	OR	A
	PUSH	AF
	LD	L, VCBUF_LENGTH
	CALL	GET_CURVC_BUFADDR
	POP	AF
	RET	NZ
	LD	C, (HL)
	RET
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C5E94:	CALL	C5E82
	PUSH	HL
	CALL	C661A
	JR	Z, J5EAE
	PUSH	BC
	CALL	C6651
	POP	BC
J5EA2:	LD	A, 40H	; "@"
	CP	E
	JR	C, J5F17
	CALL	C5C41
	OR	E
	JR	Z, J5EAE
	LD	C, E
J5EAE:	POP	HL
J5EAF:	INC	HL

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C5EB0:	LD	A, (HL)
	LD	B, 00H
	CALL	MUL_BC_BY_A
	PUSH	HL
	LD	DE, (FREQ_FACTOR)
	CALL	DIV_DE_BY_HL
	EX	DE, HL
	EX	(SP), HL
	LD	B, 05H	; 5
J5EC2:	SRL	H
	RR	L
	DJNZ	J5EC2
	CALL	DIV_DE_BY_HL
	CALL	C5F02
	LD	L, (IX)
	LD	H, 00H
	ADD	HL, DE
	LD	(IX), L
	LD	DE, I_FFE0
	ADD	HL, DE
	JR	NC, J5EE3
	LD	(IX), L
	POP	HL
	INC	HL
	PUSH	HL
J5EE3:	POP	DE
	LD	H, D
	LD	L, E
J5EE6:	CALL	C661A
	JR	Z, J5F01
	CP	2EH	; "."
	JR	NZ, J5EFE
	SRL	D
	RR	E
	ADC	HL, DE
	LD	A, 0E0H
	AND	H
	JR	Z, J5EE6
	XOR	H
	LD	H, A
	JR	J5F01
;	-----------------
J5EFE:	CALL	C6640
J5F01:	RET
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C5F02:	PUSH	BC
	LD	A, (VOICEN)
	LD	C, A
	LD	B, 00H
	LD	IX, I_FA19
	ADD	IX, BC
	POP	BC
	RET
;	-----------------
C5F11:	LD	E, 87H
	POP	BC
	JP	J5E75
;	-----------------
J5F17:	JP	ERRILLEGALFNCALL
;	-----------------
C5F1A:	LD	L, VCBUF_PACKET+1
	CALL	GET_CURVC_BUFADDR
	LD	A, (HL)
	JR	NZ, J5F17
	LD	C, 00H
	LD	HL, (MCLPTR)
	PUSH	HL
	LD	A, (MCLLEN)
	PUSH	AF
J5F2C:	CALL	C6614
J5F2F:	CP	4EH	; "N"
	JR	Z, J5F3F
	CP	52H	; "R"
	JR	Z, J5F3F
	CP	41H	; "A"
	JR	C, J5F42
	CP	48H	; "H"
	JR	NC, J5F42
J5F3F:	INC	C
	JR	J5F2C
;	-----------------
J5F42:	CP	7DH	; "}"
	JR	Z, J5F55
	CP	7BH	; "{"
	JR	Z, J5F17
	CP	3DH	; "="
	JR	NZ, J5F2C
	PUSH	BC
	CALL	C66A4
	POP	BC
	JR	J5F2F
;	-----------------
J5F55:	LD	L, VCBUF_LENGTH
	CALL	GET_CURVC_BUFADDR
	LD	E, (HL)
	LD	D, 00H
	CALL	C661A
	JR	Z, J5F6F
	CALL	C6640
	CALL	C5D27
	JR	C, J5F6F
	PUSH	BC
	CALL	C664E
	POP	BC
J5F6F:	LD	A, 40H	; "@"
	CP	E
	JR	C, J5F17
	CALL	C5C41
	LD	A, C
	LD	B, D
	LD	C, E
	CALL	MUL_BC_BY_A
	OR	H
	JR	NZ, J5F17
	LD	A, L
	CP	41H	; "A"
	JR	NC, J5F17
	PUSH	AF
	LD	L, VCBUF_PACKET+1
	CALL	GET_CURVC_BUFADDR
	POP	AF
	LD	(HL), A
	POP	AF
	LD	(MCLLEN), A
	POP	HL
	LD	(MCLPTR), HL
	RET
;	-----------------
C5F96:	LD	L, VCBUF_PACKET+1
	CALL	GET_CURVC_BUFADDR
	LD	A, (HL)
	OR	A
	JR	Z, J5FCE
	LD	(HL), 00H
	RET
;	-----------------

MCL_FOR_DRUMS:
	DEFB	"B"
	DEFW	J5FD1
	DEFB	"S"
	DEFW	J5FD1
	DEFB	"M"
	DEFW	J5FD1
	DEFB	"C"
	DEFW	J5FD1
	DEFB	"H"
	DEFW	J5FD1
	DEFB	"R"+128
	DEFW	J5DC3
	DEFB	"@"
	DEFW	C602A
	DEFB	"T"+128
	DEFW	C5A99
	DEFB	"Y"+128
	DEFW	C5D37
	DEFB	"V"+128
	DEFW	C5D7B
	DEFB	"X"
	DEFW	C66DB
	DEFB	00

I5FC4:
	DEFB	"B","S","M","C","H"
	DEFB	010H, 008H, 004H, 002H, 001H

J5FCE:	JP	06770H

J5FD1:	LD	BC, 0
	CALL	C6640
J5FD7:	CALL	C6614
	CALL	C5D27
	JR	NC, J6003
	PUSH	BC
	LD	HL, I5FC4
	LD	BC, 5
	CPIR
	JR	NZ, J5FCE
	LD	C, 04H	; 4
	ADD	HL, BC
	LD	D, (HL)
	POP	BC
	CALL	C6614
	CP	21H	; "!"
	PUSH	AF
	CALL	NZ, C6640
	POP	AF
	JR	NZ, J5FFE
	LD	A, D
	OR	B
	LD	B, A
J5FFE:	LD	A, D
	OR	C
	LD	C, A
	JR	J5FD7
;	-----------------
J6003:	INC	C
	DEC	C
	JR	Z, J5FCE
	LD	A, 0C0H
	OR	C
	PUSH	AF
	PUSH	BC
	LD	HL, I601F
	PUSH	HL
	LD	L, VCBUF_LENGTH
	CALL	GET_CURVC_BUFADDR

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C6015:	PUSH	HL
	CALL	C6640
	CALL	C664E
	JP	J5EA2
;	-----------------
I601F:	POP	BC
	POP	AF
	POP	DE
	LD	E, A
	CALL	C59C5
	LD	E, B
	JP	J5E6D
;	-----------------
C602A:	CALL	C6614
	CP	56H	; "V"
	JP	Z, J5CDD
	CP	41H	; "A"
	JR	NZ, J5FCE
	CALL	C6614
	CALL	C5D27
	JR	C, J6058
	CALL	C6651
	CALL	C5C41
	LD	A, E
	CP	10H	; 16
	JR	NC, J6058
	LD	A, 0FH	; 15
	SUB	E
	ADD	A, A
	LD	C, A
	LD	E, 86H
	CALL	C59C5
	LD	E, C
	POP	BC
	JP	J5E75
;	-----------------
J6058:	JP	ERRILLEGALFNCALL
;	-----------------

KEYINT:	PUSH	AF
	DI
	LD	HL, D.F999
	LD	A, (D.F983)
	OR	A
	JR	NZ, J6082
J6066:	CPL
	LD	(D.F983), A
	PUSH	HL
J606B:	XOR	A
	LD	(D.FA26), A
	CALL	C6087
	LD	A, (D.FA26)
	OR	A
	JR	NZ, J606B
	POP	HL
	DI
	XOR	A
	LD	(D.F983), A
	DEC	(HL)
	JP	P, J6066
J6082:	INC	(HL)
	POP	AF
	JP	O.TIMI


;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________


C6087:	LD	A, (MUSICF)
	OR	A
	JR	Z, J6097
	CALL	C63B1
	JR	NZ, J60A4
	LD	A, (MUSICF)
	AND	7FH
J6097:	LD	HL, (D.F995)
	OR	L
	OR	H
	LD	HL, D.F997
	OR	(HL)
	CALL	NZ, C658D
	RET
;	-----------------
J60A4:	LD	BC, (D.F995)
	LD	A, B
	OR	C
	JR	Z, J60CA
	LD	L, C
	LD	H, B
	LD	A, (PVOICE_CNT)
	LD	B, A
	LD	A, 10H	; 16
	SUB	B
	LD	B, A
J60B6:	ADD	HL, HL
	DJNZ	J60B6
	LD	A, (PVOICE_CNT)
J60BC:	DEC	A
	JP	M, J60CA
	ADD	HL, HL
	PUSH	AF
	PUSH	HL
	CALL	C, C60CB
	POP	HL
	POP	AF
	JR	J60BC
;	-----------------
J60CA:	RET
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C60CB:	LD	(D.F99A), A
	DI
	LD	L, VCBUF_DURATION
	CALL	GET_VC_BUFADDR
	LD	E, (HL)
	INC	HL
	LD	D, (HL)
	LD	A, D
	OR	E
	JR	Z, J60E3
	DEC	DE
	LD	(HL), D
	DEC	HL
	LD	(HL), E
	LD	A, D
	OR	E
	RET	NZ
	INC	HL
J60E3:	LD	A, (OPL_PVOICE_CNT)
	LD	B, A
	LD	A, (D.F99A)
	CP	B
	JP	NC, J63FC
J60EE:	CALL	C6388
	RET	Z
J60F2:	INC	A
	JP	Z, J6208
	DEC	A
	JP	M, J6235
	PUSH	HL
	LD	D, A
	LD	E, A
	JR	Z, J6103
	CALL	C6388
	LD	E, A
J6103:	LD	L, 0DH	; 13
	CALL	C6396
	LD	(HL), E
	INC	HL
	LD	(HL), D
	POP	HL
	CALL	C6388
	LD	C, A
	CALL	C6388
	LD	(HL), A
	DEC	HL
	LD	(HL), C
	LD	A, D
	OR	A
	JP	Z, C6177
	CALL	C61DA
	LD	L, 12H	; 18
	CALL	C6396
	LD	C, (HL)
	CALL	C613F
	JP	NZ, J63BD
	CALL	C619C
	JP	C, J6172
J6130:	PUSH	BC
	PUSH	DE
	CALL	C6A4A
	LD	BC, C.0010
	ADD	IX, BC
	POP	DE
	POP	BC
	DJNZ	J6130
	RET
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C613F:	PUSH	HL
	LD	HL, D.F981
	BIT	0, (HL)
	POP	HL
	RET
;	-----------------
C6147:	CALL	C6388
	RET	Z
	OR	A
	JP	M, J60F2
	JR	Z, J60F2
	LD	D, A
	CALL	C6388
	LD	E, A
	PUSH	HL
	LD	L, 0DH	; 13
	CALL	C6396
	LD	A, E
	CP	(HL)
	JR	NZ, J6163
	INC	HL
	LD	A, D
	CP	(HL)
J6163:	JP	NZ, J6103
	POP	HL
	CALL	C6388
	LD	C, A
	CALL	C6388
	LD	(HL), A
	DEC	HL
	LD	(HL), C
	RET
;	-----------------
J6172:	LD	A, (D.F982)
	RET
;	-----------------
J6176:	RET
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C6177:	CALL	C619C
	JR	NC, J6186
	RET	NZ
	CALL	C613F
	JP	NZ, J63C8
	JP	J6176
;	-----------------
J6186:	CALL	C613F
	JP	NZ, J63C8
	CALL	C61DA
J618F:	PUSH	BC
	CALL	C6C58
	LD	BC, C.0010
	ADD	IX, BC
	POP	BC
	DJNZ	J618F
	RET
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C619C:	LD	A, (D.F99A)

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C619F:	LD	HL, D.F984
	CP	(HL)
	CCF
	RET	NC
	PUSH	AF
	LD	A, (DRUM_MODE)
	DEC	A
	JR	Z, J61AE
	POP	AF
	RET
;	-----------------
J61AE:	POP	AF
	ADC	A, A
	RRA
	RET
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C61B2:	CALL	C613F
	JP	NZ, J63CC
	CALL	C619C
	JR	NC, J61C2
	LD	A, C
	LD	(D.F982), A
	RET
;	-----------------
J61C2:	PUSH	BC
	CALL	C61DA
	POP	DE
	LD	C, E
J61C8:	PUSH	BC
	CALL	C6A47
	POP	BC
	PUSH	BC
	CALL	C68E1
	LD	BC, C.0010
	ADD	IX, BC
	POP	BC
	DJNZ	J61C8
	RET
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C61DA:	LD	A, (D.F99A)
	CALL	C619F
	JR	NC, J61EB
	JR	Z, J61EB
	LD	IX, I_FA87
	LD	B, 03H	; 3
	RET
;	-----------------
J61EB:	LD	HL, I.F985
	OR	A
	JR	Z, J61F7
	LD	B, A
	XOR	A
J61F3:	ADD	A, (HL)
	INC	HL
	DJNZ	J61F3
J61F7:	LD	IX, I.FA27
	OR	A
	JR	Z, J6206
	LD	BC, C.0010
J6201:	ADD	IX, BC
	DEC	A
	JR	NZ, J6201
J6206:	LD	B, (HL)
	RET
;	-----------------
J6208:	CALL	C6177
	LD	L, 0DH	; 13
	CALL	C6396
	LD	(HL), 00H
	INC	HL
	LD	(HL), 00H
J6215:	LD	A, (D.F99A)
	LD	HL, I.0001
	LD	B, A
	OR	A
	JR	Z, J6222
J621F:	ADD	HL, HL
	DJNZ	J621F
J6222:	EX	DE, HL
	DI
	LD	HL, (D.F995)
	LD	A, E
	AND	L
	XOR	L
	LD	L, A
	LD	A, D
	AND	H
	XOR	H
	LD	H, A
	LD	(D.F995), HL
	JP	C683D
;	-----------------
J6235:	LD	E, A
	AND	0C0H
	CP	0C0H
	JP	Z, J6341
	LD	A, E
	ADD	A, A
	EX	DE, HL
	ADD	A, LOW I624E
	LD	L, A
	LD	A, 00H
	ADC	A, HIGH I624E
	LD	H, A
	LD	C, (HL)
	INC	HL
	LD	B, (HL)
	EX	DE, HL
	PUSH	BC
	RET
;	-----------------

I624E:
	DEFW	C626E			; 080H
	DEFW	C6271			; 081H, volume
	DEFW	C629E			; 082H, register
	DEFW	C62AC			; 083H, duration
	DEFW	C62B7			; 084H, voice
	DEFW	C62C1			; 085H, volume
	DEFW	C6318			; 086H, rhythm
	DEFW	C6147			; 087H, "&"
	DEFW	C6264			; 088H, use MUSIC/PSG
	DEFW	C6266
	DEFW	C63F4

C6264:
	XOR	A
	DEFB	1			; LD BC, 0013EH

C6266:
	LD	A, 1
	LD	(D.F981), A
	JP	J60EE

;	-----------------
C626E:	JP	C6177
;	-----------------
C6271:	PUSH	HL
	CALL	C619C
	POP	HL
	JR	NC, J627D
	JP	NZ, J6300
	JR	J628B
;	-----------------
J627D:	PUSH	HL
	LD	L, 12H	; 18
	CALL	C6396
	CALL	C6388
	LD	(HL), A
J6287:	POP	HL
	JP	J60EE
;	-----------------
J628B:	PUSH	HL
	LD	L, 12H	; 18
	CALL	C6396
	CALL	C6388
	LD	(HL), A
	ADD	A, A
	ADD	A, A
	ADD	A, 03H	; 3
	CALL	C62F9
	JR	J6287

;	Packet 082H
;	  Inputs:  ________________________
;	  Outputs: ________________________

C629E:	PUSH	HL
	CALL	C6388			; get from voice queue serviced
	LD	C, A			; register
	CALL	C6388			; get from voice queue serviced
	LD	B, A			; data
	CALL	C6DB5			; write OPLL register with validation
	JR	J6287			; get next music packet
;	-----------------
C62AC:	CALL	C6388
	LD	C, A
	CALL	C6388
	LD	(HL), A
	DEC	HL
	LD	(HL), C
	RET
;	-----------------
C62B7:	PUSH	HL
	CALL	C6388
	LD	C, A
	CALL	C61B2
J62BF:	JR	J6287
;	-----------------
C62C1:	CALL	C613F
	JP	NZ, J63D1
	PUSH	HL
	CALL	C619C
	JR	NC, J62D6
	JR	Z, J62ED
	CALL	C61DA
	LD	B, 01H	; 1
	JR	J62D9
;	-----------------
J62D6:	CALL	C61DA
J62D9:	CALL	C6388
	LD	E, A
J62DD:	PUSH	BC
	PUSH	DE
	CALL	C69CC
	LD	BC, C.0010
	ADD	IX, BC
	POP	DE
	POP	BC
	DJNZ	J62DD
	JR	J6287
;	-----------------
J62ED:	CALL	C6388
	LD	E, A
	LD	A, 3FH	; "?"
	SUB	E
	CALL	C62F9
	POP	HL
	RET
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C62F9:	LD	C, A
	LD	B, 00H
	LD	E, A
	LD	D, 00H
	RET
;	-----------------
J6300:	PUSH	HL
	LD	L, 0AH	; 10
	CALL	C6396
	CALL	C6388
	LD	(HL), A
	LD	E, A
	LD	L, 08H	; 8
	CALL	C6396
	LD	A, (HL)
	CPL
	CALL	C632F
	JP	J6287
;	-----------------
C6318:	PUSH	HL
	LD	L, 0CH	; 12
	CALL	C6396
	CALL	C6388
	LD	(HL), A
	LD	E, A
	LD	L, 08H	; 8
	CALL	C6396
	LD	A, (HL)
	CALL	C632F
	JP	J6287
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C632F:	AND	1FH
	RET	Z
	CALL	C613F
	JP	NZ, J63E4
	PUSH	BC
	PUSH	DE
	LD	C, A
	CALL	C69DB
	POP	DE
	POP	BC
	RET
;	-----------------
J6341:	CALL	C6388
	LD	D, A
	CALL	C6388
	LD	C, A
	CALL	C6388
	LD	(HL), A
	DEC	HL
	LD	(HL), C
	PUSH	HL
	LD	L, 08H	; 8
	CALL	C6396
	LD	A, D
	XOR	(HL)
	JR	Z, J6379
	LD	(HL), D
	PUSH	DE
	PUSH	AF
	AND	D
	PUSH	AF
	LD	L, 0CH	; 12
	CALL	C6396
	LD	E, (HL)
	POP	AF
	CALL	C632F
	LD	A, D
	CPL
	LD	D, A
	POP	AF
	AND	D
	PUSH	AF
	LD	L, 0AH	; 10
	CALL	C6396
	LD	E, (HL)
	POP	AF
	CALL	C632F
	POP	DE
J6379:	POP	HL
	LD	A, E
	AND	3FH	; "?"
	LD	C, A
	CALL	C613F
	JP	NZ, J63EF
	CALL	C6C68
	RET
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C6388:	PUSH	HL
	PUSH	DE
	PUSH	BC
	LD	A, (D.F99A)
	DI
	CALL	C6714
	POP	BC
	POP	DE
	POP	HL
	RET
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C6396:	LD	A, (D.F99A)
	DI
	JP	GET_VC_BUFADDR
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C639D:	EI
	CALL	C63B1
	SCF
	RET	Z
	DI
	LD	HL, (D.F995)
	LD	A, L
	OR	H
	LD	HL, D.F997
	OR	(HL)
	JR	NZ, C639D
	EI
	RET
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C63B1:	LD	A, (BASROM)
	OR	A
	RET	NZ
	LD	A, (INTFLG)
	SUB	03H	; 3
	OR	A
	RET
;	-----------------
J63BD:	LD	B, 00H

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C63BF:	LD	A, (D.F99A)
	PUSH	HL
	CALL	C.F975
	POP	HL
	RET
;	-----------------
J63C8:	LD	B, 01H	; 1
	JR	C63BF
;	-----------------
J63CC:	LD	B, 02H	; 2
	LD	D, C
	JR	C63BF
;	-----------------
J63D1:	CALL	C6388
	LD	D, A
	PUSH	HL
	CALL	C619C
	POP	HL
	LD	B, 03H	; 3
	JR	NC, C63BF
	JR	Z, C63BF
	LD	B, 04H	; 4
	JR	C63BF
;	-----------------
J63E4:	PUSH	BC
	PUSH	DE
	LD	D, A
	LD	B, 05H	; 5
	CALL	C63BF
	POP	DE
	POP	BC
	RET
;	-----------------
J63EF:	LD	B, 06H	; 6
	LD	D, C
	JR	C63BF
;	-----------------
C63F4:	CALL	C6388
	LD	D, A
	LD	B, 07H	; 7
	JR	C63BF
;	-----------------
J63FC:	LD	A, (OPL_PVOICE_CNT)
	LD	B, A
	LD	A, (D.F99A)
	SUB	B
	LD	B, A
	CALL	C6388
	RET	Z
	CP	0FFH
	JR	Z, J6468
	LD	D, A
	AND	0E0H
I640F	EQU	$-1
	RLCA
	RLCA
	RLCA
	LD	C, A
	LD	A, D
	AND	1FH
	LD	(HL), A
	CALL	C6388
	DEC	HL
	LD	(HL), A
	INC	C
J641E:	DEC	C
	RET	Z
	CALL	C6388
	LD	D, A
	AND	0C0H
	JR	NZ, J6439
	CALL	C6388
	LD	E, A
	LD	A, B
	RLCA
	CALL	C6480
	INC	A
	LD	E, D
	CALL	C6480
	DEC	C
	JR	J641E
;	-----------------
J6439:	LD	H, A
	AND	80H
	JR	Z, J644D
	LD	E, D
	LD	A, B
	ADD	A, 08H	; 8
	CALL	C6480
	LD	A, E
	AND	10H	; 16
	LD	A, 0DH	; 13
	CALL	NZ, C6480
J644D:	LD	A, H
	AND	40H	; "@"
	JR	Z, J641E
	CALL	C6388
	LD	D, A
	CALL	C6388
	LD	E, A
	LD	A, 0BH	; 11
	CALL	C6480
	INC	A
	LD	E, D
	CALL	C6480
	DEC	C
	DEC	C
	JR	J641E
;	-----------------
J6468:	LD	A, B
	ADD	A, 08H	; 8
	LD	E, 00H
	CALL	C6480
	INC	B
	DI
	LD	HL, MUSICF
	XOR	A
	SCF
J6477:	RLA
	DJNZ	J6477
	AND	(HL)
	XOR	(HL)
	LD	(HL), A
	JP	J6215
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C6480:	DI
	OUT	(0A0H), A
	PUSH	AF
	LD	A, E
	OUT	(0A1H), A
	POP	AF
	RET
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C6489:	XOR	A
	LD	(D.F998), A
	LD	A, (D.F984)
	LD	HL, DRUM_MODE
	BIT	0, (HL)
	JR	Z, J6498
	INC	A
J6498:	BIT	1, (HL)
	JR	Z, J649D
	INC	A
J649D:	LD	(OPL_PVOICE_CNT), A
	ADD	A, 03H	; 3
	LD	(PVOICE_CNT), A
	LD	B, A
	OR	80H
	LD	(D.F993), A
	LD	HL, 0
J64AE:	SCF
	ADC	HL, HL
	DJNZ	J64AE
	LD	(D.F98F), HL
	LD	A, (OPL_PVOICE_CNT)
	LD	HL, QUE_LENGTH_TABLE
	CALL	C5486
	LD	A, (HL)
	LD	(D.F994), A
	LD	HL, (MUSCWRK)
	LD	DE, 0
	ADD	HL, DE
	LD	(VOICE_CTRL_BUF), HL
	LD	A, (EXPTBL)
	LD	HL, IDBYT1
	CALL	RDSLT
	AND	80H
	LD	HL, 14400 		; LOAD FOR 60HZ SYSTEMS (120*4*60)/2
	JR	Z, J64E0
	LD	HL, 12000		; LOAD FOR 50HZ SYSTEMS (120*4*50)/2
J64E0:	LD	(FREQ_FACTOR), HL
	RET

QUE_LENGTH_TABLE:
	DEFB	127			; 0 OPLL playvoices, use 128 bytes queues
        DEFB	63, 63, 63		; 1-3 OPLL playvoices, use 64 bytes queues
        DEFB	31, 31, 31, 31, 31, 31	; 4-9 OPLL playvoices, use 32 bytes queues

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C64EE:	CALL	BRMGICINI

	DI
	XOR	A
	LD	(D.F999), A
	LD	(D.F997), A
	LD	(D.F983), A
	LD	(D.F97F), A
	LD	(D.F980), A
	LD	(D.F981), A
	LD	(D.F982), A
	LD	L, A
	LD	H, A
	LD	(D.F995), HL
	LD	A, (PVOICE_CNT)
	LD	B, A
	LD	HL, (MUSCWRK)
	LD	DE, I_0048
	ADD	HL, DE
	EX	DE, HL
J6519:	PUSH	BC
	PUSH	DE
	LD	A, (PVOICE_CNT)
	SUB	B
	LD	(D.F99A), A
	LD	HL, D.F994
	LD	B, (HL)
	CALL	C6730
	POP	DE
	POP	BC
	LD	A, (D.F994)
	INC	A
	LD	L, A
	LD	H, 00H
	ADD	HL, DE
	EX	DE, HL
	DJNZ	J6519
	LD	A, (OPL_PVOICE_CNT)
	OR	A
	JR	Z, J6551
	LD	B, A
J653D:	PUSH	BC
	LD	A, B
	DEC	A
	LD	L, VCBUF
	CALL	GET_VC_BUFADDR
	EX	DE, HL
	LD	HL, I6566
	LD	BC, I.0027
	LDIR
	POP	BC
	DJNZ	J653D
J6551:	XOR	A
	LD	(MUSICF), A
	RET
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C6556:	LD	A, (DRUM_MODE)
	AND	01H				; in drum mode ?
	RET	Z				; nope, quit
	LD	A, (I6566+10)
	LD	E, A
	LD	A, 1FH
	CALL	C632F
	RET
;	-----------------
I6566:
	DEFW	0				; +0 , duration counter
	DEFB	0				; +2 , stringlength
	DEFW	0				; +3 , stringadres
	DEFW	0				; +5 , stackdata
	DEFB	0				; +7 , music packet length
	DEFB	0, 0, 14, 0, 0, 0, 0			; +8 , music packet
	DEFB	4				; +15, octave
	DEFB	4				; +16, length
	DEFB	120				; +17, tempo
	DEFB	8				; +18, volume
	DEFW	0				; +19, envelope period
	DEFB	0, 0, 0				; +20, stack
	DEFB	0, 0, 0, 0, 0, 0, 0, 0			; +23
	DEFB	0, 0, 0, 0, 0, 0, 8			; +31

;	 Stop background music
;	   Inputs:  ________________________
;	   Outputs: ________________________

C658D:	CALL	C64EE
	CALL	C6556
	LD	A, (OPL_PVOICE_CNT)		; number of OPLL playvoices
	CALL	C659A
	RET
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C659A:	DEC	A
	RET	M
	LD	(D.F99A), A
	PUSH	AF
	CALL	C6177
	POP	AF
	JR	C659A
;	-----------------
J65A6:	CALL	BRMFRESTR
	CALL	C6834
	LD	B, C
	LD	C, D
	LD	D, E
	LD	A, B
	OR	C
	JR	Z, J65B9
	LD	A, D
	OR	A
	JR	Z, J65B9
	PUSH	BC
	PUSH	DE
J65B9:	POP	AF
	LD	(MCLLEN), A
	POP	HL
	LD	A, H
	OR	L
	JP	Z, J5915
	LD	(MCLPTR), HL
J65C6:	CALL	C661A
	JR	Z, J65B9
	LD	HL, (MCLTAB)
	CP	41H	; "A"
	JR	C, J65D6
	CP	48H	; "H"
	JR	C, J65E6
J65D6:	ADD	A, A
	LD	C, A
J65D8:	LD	A, (HL)
	ADD	A, A
J65DA:	CALL	Z, ERRILLEGALFNCALL
	CP	C
	JR	Z, J65E5
	INC	HL
	INC	HL
	INC	HL
	JR	J65D8
;	-----------------
J65E5:	LD	A, (HL)
J65E6:	LD	BC, J65C6
	PUSH	BC
	LD	C, A
	ADD	A, A
	JR	NC, J660E
	OR	A
	RRA
	LD	C, A
	PUSH	BC
	PUSH	HL
	CALL	C661A
	LD	DE, I.0001
	JP	Z, J660B
	CALL	C68AE
	JP	NC, J6608
	CALL	C6651
	SCF
	JR	J660C
;	-----------------
J6608:	CALL	C6640
J660B:	OR	A
J660C:	POP	HL
	POP	BC
J660E:	INC	HL
	LD	A, (HL)
	INC	HL
	LD	H, (HL)
	LD	L, A
	JP	(HL)
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C6614:	CALL	C661A
	JR	Z, J65DA
	RET
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C661A:	PUSH	HL
J661B:	LD	HL, MCLLEN
	LD	A, (HL)
	OR	A
	JR	Z, J664C
	DEC	(HL)
	LD	HL, (MCLPTR)
	LD	A, (HL)
	INC	HL
	LD	(MCLPTR), HL
	CP	20H	; " "
	JR	Z, J661B
	POP	HL
	CALL	C6637
	SCF
	ADC	A, A
	RRA
	RET
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C6637:	CP	61H	; "a"
	RET	C
	CP	7BH	; "{"
	RET	NC
	SUB	20H	; " "
	RET
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C6640:	PUSH	HL
	LD	HL, MCLLEN
	INC	(HL)
	LD	HL, (MCLPTR)
	DEC	HL
	LD	(MCLPTR), HL
J664C:	POP	HL
	RET
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C664E:	CALL	C6614

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C6651:	CP	3DH	; "="
	JP	Z, J66D3
	CP	2BH	; "+"
	JR	Z, C664E
	CP	2DH	; "-"
	JR	NZ, J6664
	LD	DE, I66F2
	PUSH	DE
	JR	C664E
;	-----------------
J6664:	LD	DE, 0
J6667:	CP	2CH	; ","
	JR	Z, C6640
	CP	3BH	; ";"
	RET	Z
	CP	3AH	; ":"
	JR	NC, C6640
	CP	30H	; "0"
	JR	C, C6640
	LD	HL, 0
	LD	B, 0AH	; 10
J667B:	ADD	HL, DE
	JR	C, J66CC
	DJNZ	J667B
	SUB	30H	; "0"
	LD	E, A
	LD	D, 00H
	ADD	HL, DE
	JR	C, J66CC
	EX	DE, HL
	CALL	C661A
	JR	NZ, J6667
	RET
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C668F:	CP	41H	; "A"
	RET	C
	CP	5BH	; "["
	CCF
	RET
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C6696:	CP	25H	; "%"
	RET	Z
	CP	21H	; "!"
	RET	Z
	CP	23H	; "#"
	RET	Z
	CP	24H	; "$"
	RET	Z
	SCF
	RET
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C66A4:	CALL	C6614
	LD	DE, BUF
	PUSH	DE
	LD	B, 28H	; "("
	CALL	C668F
	JR	C, J66CC
J66B2:	LD	(DE), A
	INC	DE
	CALL	C6696
	JR	C, J66C3
	CALL	C6614
	CP	3BH	; ";"
	JR	NZ, J66CA
	LD	(DE), A
	JR	J66CF
;	-----------------
J66C3:	CP	3BH	; ";"
	JR	Z, J66CF
	CALL	C6614
J66CA:	DJNZ	J66B2
J66CC:	CALL	ERRILLEGALFNCALL
J66CF:	POP	HL
	JP	BRMVARVAL
;	-----------------
J66D3:	CALL	C66A4
	CALL	CODE_BUF
	EX	DE, HL
	RET
;	-----------------
C66DB:	CALL	C66A4
	LD	A, (MCLLEN)
	OR	A
	JP	NZ, ERRILLEGALFNCALL
	LD	HL, (MCLPTR)
	EX	(SP), HL
	PUSH	AF
	LD	C, 02H	; 2
	CALL	C6894
	JP	J65A6
;	-----------------
I66F2:	XOR	A
	SUB	E
	LD	E, A
	SBC	A, D
	SUB	E
	LD	D, A
	RET
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C66F9:	CALL	VQ_GET_CTRL_POS
	LD	A, B
	INC	A
	INC	HL
	AND	(HL)
	CP	C
	RET	Z
	DEC	HL
	DEC	HL
	DEC	HL
	LD	(HL), A
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	LD	C, A
	LD	A, (HL)
	INC	HL
	LD	H, (HL)
	LD	L, A
	LD	B, 00H
	ADD	HL, BC
	LD	(HL), E
	RET
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C6714:	CALL	VQ_GET_CTRL_POS
	LD	A, C
	CP	B
	RET	Z
	INC	HL
	INC	A
	AND	(HL)
	DEC	HL
	DEC	HL
	LD	(HL), A
	INC	HL
	INC	HL
	INC	HL
	LD	C, A
	LD	A, (HL)
	INC	HL
	LD	H, (HL)
	LD	L, A
	LD	B, 00H
	ADD	HL, BC
	LD	A, (HL)
	SCF
	ADC	A, A
	RRA
	RET
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C6730:	PUSH	BC
	CALL	VQ_GET_CTRL_ADDR
	LD	(HL), B
	INC	HL
	LD	(HL), B
	INC	HL
	LD	(HL), B
	INC	HL
	POP	AF
	LD	(HL), A
	INC	HL
	LD	(HL), E
	INC	HL
	LD	(HL), D
	RET

;	Get free space voice queue
;	  Inputs:  (A = playvoice)
;	  Outputs: (A = count of free bytes, HL = count of free bytes)

VQ_GET_FREE:
	CALL	VQ_GET_CTRL_POS			; get voice queue control and put/get pos
	LD	A, B
	INC	A			; put pos +1
	INC	HL
	AND	(HL)			; warp around
	LD	B, A
	LD	A, C
	SUB	B
	AND	(HL)
	LD	L, A
	LD	H, 0
	RET

;	Get voice queue control and put/get pos
;	 Inputs:  (A = playvoice)
;	 Outputs ________________________

VQ_GET_CTRL_POS:
	CALL	VQ_GET_CTRL_ADDR			; get voice queue control
	LD	B, (HL)
	INC	HL
	LD	C, (HL)
	INC	HL
	RET
;	-----------------

;	Get voice queue control
;	  Inputs:  (A = playvoice)
;	  Outputs: (HL = voice queue control address)

VQ_GET_CTRL_ADDR:
	LD	HL, (VOICE_CTRL_BUF)
	ADD	A, A		; HL = HL * A * 6
	LD	B, A
	ADD	A, A
	ADD	A, B
	LD	C, A
	LD	B, 0
	ADD	HL, BC
	RET

; 	-----------------
ERRINTERNAL:
J6764:	LD	E, 33H			; INTERNAL ERROR
	JR	HANDLE_ERROR

ERRSYNTAX:
J676D:	LD	E, 02H			; SYNTAX ERROR
	JR	HANDLE_ERROR

ERRILLEGALFNCALL:
	LD	E, 05H			; ILLEGAL FUNCTION CALL
	JR	HANDLE_ERROR

ERRTYPEMISMATCH:
J6773:	LD	E, 0DH			; TYPE MISMATCH
	JR	HANDLE_ERROR

ERROUTOFMEMORY:
	LD	E, 07H			;OUT OF MEMORY

HANDLE_ERROR:
	CALL	GET_MSX_INIT
	PUSH	DE
	CALL	NZ, C658D
	POP	DE
	LD	IX, HERRO
	JR	CALMAINRM

	ALIGNCHK	06789H

;	  PSG initialization
BRMGICINI:
	LD	IX, GICINI
	JR	CALMAINRM

;	Return the current value of a basic variable.
BRMVARVAL:
	LD	IX, VARVAL
	JR	CALMAINRM

;	-----------------
Q6795:	LD	IX, FILESPEC
	JR	CALMAINRM

;	Obtain the address for the storage of a basic variable
;	  Inputs:
;		(HL = address of variable name, SUBFLG = variable type)
;	  Outputs: (HL = Address after variable name, DE = Address of contents of variable)
BRMPTRGET:
	LD	IX, PTRGET
	JR	CALMAINRM


;	Convert to DAC to new type

BRMMBCVRT:
	LD	IX, MBCVRT
	JR	CALMAINRM

;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C67A7:	LD	A, (HL)
	EX	(SP), HL
	CP	(HL)
	JP	NZ, J676D
	INC	HL
	EX	(SP), HL

;	Extract one character from the text at (HL + 1). Spaces are skipped.
;	  Inputs: (HL = Address pointing to text)
;	  Outputs: (HL = Address of the extracted char, A = Extracted char, Z flag ON if at the end of line, CY flag ON if digit)

BRMCHRGTR:
	LD	IX, CHRGTR
	JR	CALMAINRM

;	Evaluate expression and convert output according to its type.
;	  Inputs: (HL = address of expression in text)
;	  Outputs: (HL = address after expression, VALTYP = value type, DAC = evaluated result)

BRMFRMEVL:
	LD	IX, FRMEVL
	JR	CALMAINRM

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

;	Evaluate expression and convert to 16 bit int
;	  Inputs: (HL = address of expression in text)
;	  Outputs: (HL = address after expression, DE = evaluted result)
;	  If value is beyond range throw an "Overflow" error

BRMFRMQNT:
	LD	IX, FRMQNT
	JR	CALMAINRM

;	Evaluate expression and convert to 8 bit int
;	  Inputs: (HL = address of expression in text)
;	  Outputs: (HL = address after expression, A & E = evaluted result)
;	  If value is beyond range throw an "Overflow" error

BRMMBGETBYT:
	LD	IX, MBGETBYT
	JR	CALMAINRM

; 	Execute a a basic script text
;	  Inputs: (HL = address of the text to be executed)

BRMNEWSTT:
	LD	IX, NEWSTT
	JR	CALMAINRM

;	Close all IO buffers

BRMCLOSEIO:
	LD	IX, CLOSEIO
	JR	CALMAINRM

;	Free any storage occupied by the string
;	  Inputs: (DAC = descriptor address)

BRMFRESTR:
	LD	IX, FRESTR
CALMAINRM:
	LD	IY, (EXPTBL-1)		; LD IYH, (EXPTBL)
	CALL	CALSLT
	EI
	RET

;	Get pointer to stringlength in voicebuffer
;	  Inputs  ________________________
;	  Outputs: (HL = address of string length value)

GET_CURVC_STRLEN:
	LD	L, VCBUF_STRLEN
	JR	GET_VC_BUFADDR

;	Get pointer in current voicebuffer
;	  Inputs: (L = offset)
;	  Outputs (HL = address within voice buffer+offset)

GET_CURVC_BUFADDR:
	LD	A, (VOICEN)

;	Get pointer in voicebuffer
;	  Inputs: (A = voicebuffer, L = offset)
;	  Outputs: (HL = address within voice buffer)

GET_VC_BUFADDR:
	LD	H, 00H
	PUSH	DE
	LD	E, A
	LD	A, (PVOICE_CNT)
	SUB	E
	SUB	04H	; 4
	JR	C, J6805
	LD	A, E
	LD	DE, I.01C8
	ADD	HL, DE
	LD	DE, (MUSCWRK)
	ADD	HL, DE
	OR	A
	JR	Z, J6825
	LD	DE, I.0027
	JR	J6821
;	-----------------
J6805:	CPL
	EX	AF, AF'
	LD	A, L
	OR	A
	JR	NZ, J6816
	EX	AF, AF'
	LD	HL, PSGDUV0
	ADD	A, A
	CALL	C5486
	POP	DE
	XOR	A
	RET
;	-----------------
J6816:	EX	AF, AF'
	LD	DE, VCBA
	ADD	HL, DE
	OR	A
	JR	Z, J6825
	LD	DE, I.0025
J6821:	ADD	HL, DE
	DEC	A
	JR	NZ, J6821
J6825:	POP	DE
	RET
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C6827:	PUSH	BC
	EX	(SP), HL
	POP	BC
J682A:	CALL	C68D4
	LD	A, (HL)
	LD	(BC), A
	RET	Z
	DEC	BC
	DEC	HL
	JR	J682A
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C6834:	LD	E, (HL)
	INC	HL
	LD	D, (HL)
	INC	HL
	LD	C, (HL)
	INC	HL
	LD	B, (HL)
	INC	HL
	RET
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C683D:	DI
	LD	HL, (D.F995)
	LD	A, L
	OR	H
	RET	NZ
	LD	HL, PLYCNT
	OR	(HL)
	JR	Z, J6867
	DEC	(HL)
	LD	HL, X.FFFF
	LD	(VCBA), HL
	LD	(VCBB), HL
	LD	(VCBC), HL
	INC	HL
	INC	HL
	LD	(PSGDUV0), HL
	LD	(PSGDUV1), HL
	LD	(PSGDUV2), HL
	LD	A, 87H
	LD	(MUSICF), A
J6867:	LD	HL, D.F997
	LD	A, (HL)
	OR	A
	RET	Z
	DEC	(HL)
	LD	A, (OPL_PVOICE_CNT)
	OR	A
	JR	Z, J6888
	LD	B, A
	LD	HL, (MUSCWRK)
	LD	DE, I.01C8
	ADD	HL, DE
	LD	DE, I.0027
J687F:	LD	(HL), 01H	; 1
	INC	HL
	LD	(HL), 00H
	DEC	HL
	ADD	HL, DE
	DJNZ	J687F
J6888:	LD	HL, (D.F98F)
	LD	(D.F995), HL
	LD	A, 0FFH
	LD	(D.FA26), A
	RET
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C6894:	PUSH	HL
	LD	HL, (STREND)
	LD	B, 00H
	ADD	HL, BC
	ADD	HL, BC
	LD	A, 0E5H
	LD	A, 88H
	SUB	L
	LD	L, A
	LD	A, 0FFH
	SBC	A, H
	LD	H, A
	JR	C, J68AB
	ADD	HL, SP
	POP	HL
	RET	C
J68AB:	JP	ERROUTOFMEMORY
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C68AE:	CP	7BH	; "{"
	RET	Z
	CP	7DH	; "}"
	RET	Z
	CP	3EH	; ">"
	RET	Z
	CP	3CH	; "<"
	RET	Z
	CP	26H	; "&"
	RET	Z
	CP	40H	; "@"
	RET	C
	CP	5BH	; "["
	CCF
	RET
;	-----------------
Q68C4:	LD	A, (VALTYP)
	CP	08H	; 8
	JR	NC, J68D0
	SUB	03H	; 3
	OR	A
	SCF
	RET
;	-----------------
J68D0:	SUB	03H	; 3
	OR	A
	RET
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C68D4:	LD	A, H
	SUB	D
	RET	NZ
	LD	A, L
	SUB	E
	RET
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C68DA:	LD	L, C
	LD	H, B
	CALL	C6942
	JR	J68F3
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C68E1:	LD	A, C
	CP	40H	; "@"
	RET	NC
	CALL	C690F
	LD	(IX+7), 00H
	LD	(IX+8), 00H
	CALL	NZ, C6938
J68F3:	PUSH	BC
	LD	A, (IX)
	ADD	A, 20H	; " "
	LD	C, A
	CALL	C6DE0
	AND	0FH	; 15
	LD	B, A
	POP	DE
	LD	A, E
	ADD	A, A
	ADD	A, A
	ADD	A, A
	ADD	A, A
	OR	B
	LD	B, A
	CALL	C6DB5
	CALL	C6A78
	RET
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C690F:	PUSH	BC
	PUSH	HL
	LD	HL, I6928
	LD	A, C
	LD	BC, C.0010
	CPIR
	JR	Z, J691F
	POP	HL
	POP	BC
	RET
;	-----------------
J691F:	LD	A, 10H	; 16
	SUB	C
	DEC	A
	POP	HL
	POP	BC
	LD	C, A
	XOR	A
	RET
;	-----------------

I6928:
	DEFB	0FFh, 002h, 00Ah, 000h, 003h, 004h, 005h, 006h
	DEFB	009h, 030h, 018h, 00Eh, 010h, 017h, 021h, 00CH


;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C6938:	PUSH	HL
	LD	L, C			; software instrument
	CALL	C5732			; get pointer to software instrument data
	CALL	C6942			; program OPLL instrument 0
	POP	HL
	RET

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C6942:	LD	DE, 8
	ADD	HL, DE
	LD	E, (HL)
	INC	HL
	LD	D, (HL)
	INC	HL
	LD	(IX+7), E
	LD	(IX+8), D
	PUSH	IX
	LD	IX, I.FA27
	LD	B, 9
J6958:	PUSH	BC
	LD	A, (IX)
	ADD	A, 20H
	LD	C, A
	CALL	C6DE0			; read OPLL register with validation
	RRCA
	RRCA
	RRCA
	RRCA
	AND	0FH			; sustain and key
	JR	NZ, J6970		; one of then on,
	LD	(IX+7), E
	LD	(IX+8), D
J6970:	LD	BC, 16
	ADD	IX, BC
	POP	BC
	DJNZ	J6958			; next channel
	POP	IX
	LD	A, (HL)
	LD	DE, 6
	ADD	HL, DE
	AND	0EH	; 14
	RRCA
	LD	D, A
	LD	B, (HL)
	LD	C, 0
	CALL	C6DB5			; write OPLL register with validation
	INC	HL
	LD	B, (HL)
	LD	C, 2
	CALL	C6DB5			; write OPLL register with validation
	INC	HL
	LD	B, (HL)
	LD	C, 4
	CALL	C6DB5			; write OPLL register with validation
	INC	HL
	LD	B, (HL)
	LD	C, 6
	CALL	C6DB5			; write OPLL register with validation
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	LD	B, (HL)
	LD	C, 1
	CALL	C6DB5			; write OPLL register with validation
	INC	HL
	LD	A, (HL)
	AND	0C0H
	OR	D
	LD	D, A
	LD	C, 3
	CALL	C6DE0			; read OPLL register with validation
	AND	18H
	OR	D
	LD	B, A
	CALL	C6DB5			; write OPLL register with validation
	INC	HL
	LD	B, (HL)
	LD	C, 5
	CALL	C6DB5			; write OPLL register with validation
	INC	HL
	LD	B, (HL)
	LD	C, 7
	CALL	C6DB5			; write OPLL register with validation
	LD	C, 0			; instrument 0 (programable)
	RET
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C69CC:	LD	A, E
	RRCA
	RRCA
	RRCA
	AND	07H	; 7
	LD	(IX+2), A
	PUSH	HL
	CALL	C69FC
	POP	HL
	RET
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C69DB:	LD	A, C
	AND	1FH
	RET	Z
	PUSH	HL
	PUSH	BC
	LD	HL, I.FAB7
	LD	D, A
	LD	A, E
	RRCA
	RRCA
	RRCA
	AND	07H	; 7
	LD	E, A
	LD	B, 05H	; 5
J69EE:	RR	D
	JR	NC, J69F3
	LD	(HL), E
J69F3:	INC	HL
	DJNZ	J69EE
	CALL	C69FC
	POP	BC
	POP	HL
	RET
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C69FC:	LD	HL, I.FAB7
	LD	A, (D_FA89)
	LD	D, A
	ADD	A, (HL)
	INC	HL
	RLCA
	RLCA
	RLCA
	RLCA
	LD	B, A
	LD	C, 37H	; "7"
	CALL	C6A36
I6A0E	EQU	$-1
	LD	A, D
	ADD	A, (HL)
	INC	HL
	LD	B, A
	LD	C, 38H	; "8"
	CALL	C6A40
	LD	A, D
	ADD	A, (HL)
	INC	HL
	RLCA
	RLCA
	RLCA
	RLCA
	LD	B, A
	CALL	C6A36
	LD	A, D
	ADD	A, (HL)
	INC	HL
	LD	B, A
	LD	C, 37H	; "7"
	CALL	C6A40
	LD	A, D
	ADD	A, (HL)
	INC	HL
	LD	B, A
	LD	C, 36H	; "6"
	CALL	C6A40
	RET
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C6A36:	CALL	C6DE0
	AND	0FH	; 15
J6A3B:	OR	B
	LD	B, A
	JP	C6DB5
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C6A40:	CALL	C6DE0
	AND	0F0H
	JR	J6A3B
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C6A47:	JP	C6C58
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C6A4A:	PUSH	BC
	PUSH	DE
	CALL	C6C58
	POP	DE
	POP	BC
	LD	A, 0FH	; 15
	SUB	C
	RRCA
	AND	07H	; 7
	LD	(IX+1), A
	RES	7, D
	LD	(IX+3), E
	LD	(IX+4), D
	CALL	C6A78
	CALL	C6C3A
	LD	A, (IX)
	ADD	A, 10H	; 16
	LD	C, A
	CALL	C6DE0
	OR	10H	; 16
	LD	B, A
	CALL	C6DB5
	RET
;	-----------------

;	  Subroutine set octave and F-number OPLL
;	     Inputs  IX = channel table
;	     Outputs ________________________

C6A78:	LD	L, (IX+5)
	LD	H, (IX+6)	; transpose/pitch
	LD	E, (IX+3)
	LD	D, (IX+4)
	ADD	HL, DE
	LD	E, (IX+7)
	LD	D, (IX+8)
	ADD	HL, DE
	LD	DE, I_0529
	ADD	HL, DE
	LD	A, H
	AND	A
	JP	P, J6AA5
	CP	0C4H
	JR	NC, J6AA0
J6A99:	SUB	0CH	; 12
	JP	M, J6A99
	JR	J6AA5
;	-----------------
J6AA0:	ADD	A, 0CH	; 12
	JP	M, J6AA0
J6AA5:	LD	H, A
	LD	C, L
	LD	L, 00H
	LD	DE, I_F404
	SUB	3CH	; "<"
	JR	C, J6AB3
	LD	H, A
	LD	L, 14H	; 20
J6AB3:	ADD	HL, DE
	JP	C, J6AB3
	SBC	HL, DE
	LD	B, L
	LD	A, H
	ADD	A, H
	ADD	A, H
	LD	HL, I6B2C
	CALL	C5486
	LD	A, B
	LD	E, (HL)
	INC	HL
	LD	D, (HL)
	INC	HL
	LD	H, (HL)
	LD	L, 00H
	LD	B, L
	ADD	HL, HL
	JR	NC, J6AD0
	ADD	HL, BC
J6AD0:	ADD	HL, HL
	JR	NC, J6AD4
	ADD	HL, BC
J6AD4:	ADD	HL, HL
	JR	NC, J6AD8
	ADD	HL, BC
J6AD8:	ADD	HL, HL
	JR	NC, J6ADC
	ADD	HL, BC
J6ADC:	ADD	HL, HL
	JR	NC, J6AE0
	ADD	HL, BC
J6AE0:	ADD	HL, HL
	JR	NC, J6AE4
	ADD	HL, BC
J6AE4:	ADD	HL, HL
	JR	NC, J6AE8
	ADD	HL, BC
J6AE8:	ADD	HL, HL
	JR	NC, J6AEC
	ADD	HL, BC
J6AEC:	LD	L, H
	LD	H, B
	ADD	HL, DE
	SRL	H
	RR	L
	SRL	H
	RR	L
	JR	NC, J6AFF
	INC	HL
	BIT	2, H
	JR	Z, J6AFF
	DEC	HL
J6AFF:	SUB	08H	; 8
	JR	NC, J6B0B
J6B03:	SRL	H
	RR	L
	ADD	A, 04H	; 4
	JR	NZ, J6B03
J6B0B:	CP	20H	; " "
	JR	C, J6B11
	LD	A, 1CH
J6B11:	OR	H
	RRA
	LD	H, A
	RR	L
	LD	C, (IX)			; F-number LSB register
	LD	B, L
	CALL	C6DB5			; write OPLL register with validation
	LD	A, C
	ADD	A, 10H
	LD	C, A
	CALL	C6DE0			; read OPLL register with validation
	AND	30H			; leave sustian, key alone
	OR	H			; set octave and F-number
	LD	B, A
	CALL	C6DB5			; write OPLL register with validation
	RET
;	-----------------

I6B2C:
	DB	000h, 008h, 079h, 079h, 008h, 081h, 0FAh, 008h, 089h, 083h, 009h, 091h, 014h, 00Ah, 099h, 0ADh
	DB	00Ah, 0A3h, 050h, 00Bh, 0ACh, 0FCh, 00Bh, 0B6h, 0B2h, 00Ch, 0C2h, 074h, 00Dh, 0CDh, 041h, 00Eh
	DB	0D9h, 01Ah, 00Fh

;	  Subroutine set pitch
;	     Inputs  ________________________
;	     Outputs ________________________

C6B50:	LD	D, B
	LD	E, C
	CALL	C6B62
	RET	C
	LD	(D.F99D), DE
	LD	HL, (D.F99F)
	ADD	HL, DE
	EX	DE, HL
	JP	J6BE9
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C6B62:	LD	HL, 0FE34H
	ADD	HL, DE
	RET	C
	LD	HL, 0FE66H
	ADD	HL, DE
	CCF
	RET	C
	ADD	HL, HL
	LD	DE, I6B76
	ADD	HL, DE
	LD	E, (HL)
	INC	HL
	LD	D, (HL)
	RET
;	-----------------
I6B76:	DEFW	0FEC7H
	DEFW	0FED2H
	DEFW	0FEDDH
	DEFW	0FEE7H
	DEFW	0FEF2H
	DEFW	0FEFDH
	DEFW	0FF07H
	DEFW	0FF12H
	DEFW	0FF1DH
	DEFW	0FF27H
	DEFW	0FF32H
	DEFW	0FF3CH
	DEFW	0FF47H
	DEFW	0FF51H
	DEFW	0FF5CH
	DEFW	0FF66H
	DEFW	0FF71H
	DEFW	0FF7BH
	DEFW	0FF85H
	DEFW	0FF90H
	DEFW	0FF9AH
	DEFW	0FFA4H
	DEFW	0FFAFH
	DEFW	0FFB9H
	DEFW	0FFC3H
	DEFW	0FFCDH
	DEFW	0FFD8H
	DEFW	0FFE2H
	DEFW	0FFECH
	DEFW	0FFF6H
	DEFW	0000H
	DEFW	000AH
	DEFW	0014H
	DEFW	001EH
	DEFW	0028H
	DEFW	0032H
	DEFW	003CH
	DEFW	0046H
	DEFW	0050H
	DEFW	005AH
	DEFW	0064H
	DEFW	006DH
	DEFW	0077H
	DEFW	0081H
	DEFW	008BH
	DEFW	0095H
	DEFW	009EH
	DEFW	00A8H
	DEFW	00B2H
	DEFW	00BBH

;	  Subroutine set transpose
;	     Inputs  ________________________
;	     Outputs ________________________

C6BDA:	LD	D, B
	LD	E, C
	CALL	C6C0F
	RET	C
	LD	(D.F99F), DE
	LD	HL, (D.F99D)
	ADD	HL, DE
	EX	DE, HL
J6BE9:	LD	IX, I.FA27
	LD	B, 09H	; 9
	LD	C, 0EH	; 14
	CALL	C6DE0
	AND	20H	; " "
	JR	Z, J6BFA
	LD	B, 06H	; 6
J6BFA:	PUSH	BC
	PUSH	DE
	LD	(IX+5), E
	LD	(IX+6), D
	CALL	C6A78
	LD	BC, C.0010
	ADD	IX, BC
	POP	DE
	POP	BC
	DJNZ	J6BFA
	RET
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C6C0F:	LD	A, D
	AND	A
	PUSH	AF
	CALL	M, C6C32
	LD	A, D
	LD	H, E
	LD	L, 00H
	LD	DE, I640F
	ADD	HL, HL
	RLA
	CP	D
	JR	C, J6C24
	POP	AF
	SCF
	RET
;	-----------------
J6C24:	ADD	HL, HL
	RLA
	CP	D
	JR	C, J6C2B
	SUB	D
	INC	L
J6C2B:	DEC	E
	JP	NZ, J6C24
	EX	DE, HL
	POP	AF
	RET	P

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C6C32:	XOR	A
	LD	H, A
	LD	L, A
	SBC	HL, DE
	EX	DE, HL
	AND	A
	RET
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C6C3A:	LD	A, (IX+2)
	ADD	A, (IX+1)
	CP	10H	; 16
	JR	C, J6C46
	LD	A, 0FH	; 15
J6C46:	LD	B, A
	LD	A, (IX)
	ADD	A, 20H	; " "
	LD	C, A
	CALL	C6DE0
	AND	0F0H
	OR	B
	LD	B, A
	CALL	C6DB5
	RET
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C6C58:	LD	A, (IX)
	ADD	A, 10H	; 16
	LD	C, A
	CALL	C6DE0
	AND	2FH	; "/"
	LD	B, A
	CALL	C6DB5
	RET
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C6C68:	PUSH	HL
	LD	A, C
	AND	1FH
	LD	D, A
	CPL
	LD	E, A
	LD	C, 0EH	; 14
	CALL	C6DE0
	LD	L, A
	AND	E
	LD	B, A
	CALL	C6DB5
	LD	A, L
	OR	D
	LD	B, A
	CALL	C6DB5
	POP	HL
	RET
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C6C82:	PUSH	HL
	LD	A, D
	SUB	3CH	; "<"
	LD	H, 0CH	; 12
	JR	C, J6C8E
J6C8A:	SUB	H
	JP	NC, J6C8A
J6C8E:	ADD	A, H
	JP	NC, J6C8E
	LD	HL, (D.F9A1)
	CALL	C5486
	LD	E, (HL)
	POP	HL
	BIT	7, E
	RET	Z
	DEC	D
	RET
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C6C9F:	LD	A, C
	CP	16H
	CCF
	RET	C
	PUSH	HL
	CP	0AH
	JR	C, J6CAD
	ADD	A, 6EH
	JR	J6CB2
;	-----------------
J6CAD:	ADD	A, A
	ADD	A, A
	LD	H, A
	ADD	A, A
	ADD	A, H
J6CB2:	LD	HL, I6CD2
	CALL	C5486
	LD	DE, I.0009
	ADD	HL, DE
	LD	C, (HL)
	SBC	HL, DE
	LD	DE, I_F9A3
	LD	(D.F9A1), DE
	LD	B, 0CH	; 12
J6CC8:	LD	A, (HL)
	SUB	C
	LD	(DE), A
	INC	HL
	INC	DE
	DJNZ	J6CC8
	POP	HL
	AND	A
	RET


I6CD2:	DEFB	0F1H, 014H, 0FBH, 0E2H, 005H, 0ECH, 00FH, 0F6H, 019H, 000H, 0E7H, 00AH
	DEFB	01AH, 0DDH, 009H, 035H, 0F7H, 023H, 0E6H, 012H, 0D4H, 000H, 02CH, 0EEH
	DEFB	01EH, 005H, 00AH, 00FH, 005H, 019H, 000H, 014H, 00AH, 000H, 014H, 00AH
	DEFB	01EH, 005H, 00AH, 00FH, 005H, 019H, 000H, 014H, 00AH, 000H, 014H, 0FBH
	DEFB	000H, 0F6H, 00AH, 000H, 0F6H, 00AH, 000H, 005H, 0ECH, 000H, 005H, 0FBH
	DEFB	01AH, 001H, 009H, 00BH, 0F7H, 015H, 001H, 012H, 006H, 000H, 010H, 0FCH
	DEFB	01AH, 001H, 009H, 00BH, 005H, 015H, 001H, 012H, 006H, 000H, 010H, 00AH
	DEFB	00FH, 000H, 005H, 00AH, 0FBH, 014H, 0FBH, 00AH, 005H, 000H, 00FH, 0F6H
	DEFB	01AH, 0F8H, 009H, 027H, 0F7H, 023H, 0F3H, 012H, 0FDH, 000H, 02CH, 0EEH
	DEFB	000H, 000H, 000H, 000H, 000H, 000H, 000H, 000H, 000H, 000H, 000H, 000H

	DEFB	029H, 0DCH, 033H, 052H, 005H, 024H, 0D7H, 02EH
	DEFB	0E1H, 000H, 056H, 00AH, 029H, 0DCH, 033H, 052H
	DEFB	005H, 024H, 0D7H, 02EH, 0E1H, 000H, 056H

;	  Subroutine reset OPLL
;	     Inputs  ________________________
;	     Outputs ________________________

C6D61:	XOR	A			; value
	LD	C, 00H
	LD	B, 08H
	CALL	C6D7B			; write OPLL register 0-7
J6D69:	LD	C, 0EH
	LD	B, 0BH
	CALL	C6D7B			; write OPLL register 14-24
	LD	C, 20H
	LD	B, 09H
	CALL	C6D7B			; write OPLL register 32-41
	LD	C, 30H	; "0"
	LD	B, 09H	; 9
					; write OPLL register 48-57

;	  Subroutine write OPLL register range
;	     Inputs  ________________________
;	     Outputs ________________________

C6D7B:	PUSH	BC
	LD	B, A
	CALL	C6DB5			; write OPLL register with validation
	EI
	POP	BC
	INC	C
	DJNZ	C6D7B
	RET
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C6D86:	LD	C, 0EH	; 14
	CALL	C6DE0
	OR	20H	; " "
	LD	B, A
	CALL	C6DB5
	LD	HL, I6DA3
	LD	B, 09H	; 9
J6D96:	PUSH	BC
	LD	C, (HL)
	INC	HL
	LD	B, (HL)
	INC	HL
	CALL	C6DB5
	EI
	POP	BC
	DJNZ	J6D96
	RET
;	-----------------
I6DA3:	LD	D, 20H	; " "
	RLA
	LD	D, B
	JR	J6D69
;	-----------------
Q6DA9:	LD	H, 05H	; 5
	DAA
	DEC	B
	JR	Z, J6DB0
	LD	(HL), 00H
J6DB0	EQU	$-1
	SCF
	NOP
	JR	C, C6DB5

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C6DB5:	PUSH	AF
	LD	A, C
	CALL	C6DF3
	JR	C, J6DDD
	PUSH	HL
	LD	HL, OPRGSAV
	ADD	A, L
	LD	L, A
	LD	A, 00H
	ADC	A, H
	LD	H, A
	DI
	LD	(HL), B
	LD	A, C
	OUT	(OPLREG), A
	EX	(SP), HL
	EX	(SP), HL
	LD	A, B
	OUT	(OPLDAT), A
	EX	(SP), HL
	EX	(SP), HL
	EX	(SP), HL
	EX	(SP), HL
	EX	(SP), HL
	EX	(SP), HL
	EX	(SP), HL
	EX	(SP), HL
	POP	HL
	POP	AF
	SCF
	CCF
	RET
;	-----------------
J6DDD:	POP	AF
	SCF
	RET
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C6DE0:	LD	A, C
	CALL	C6DF3
	RET	C
	PUSH	HL
	LD	HL, OPRGSAV
	LD	A, C
	ADD	A, L
	LD	L, A
	LD	A, 00H
	ADC	A, H
	LD	H, A
	LD	A, (HL)
	POP	HL
	RET
;	-----------------

;	  Subroutine __________________________
;	     Inputs  ________________________
;	     Outputs ________________________

C6DF3:	CP	08H	; 8
	CCF
	RET	NC
	CP	0EH	; 14
	RET	C
	CP	19H
	CCF
	RET	NC
	CP	20H	; " "
	RET	C
	CP	29H	; ")"
	CCF
	RET	NC
	CP	30H	; "0"
	RET	C
	CP	39H	; "9"
	CCF
	RET

I6E0C:	DEFM	'Piano 1 ', 00H
	DEFB	00H
	DEFB	0AH
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'1', 0EH
	DEFM	'Y'+80H
	DEFB	11H
	DEFM	'0', 00H
	DEFB	00H
	DEFB	00H
	DEFB	11H
	DEFB	00H
	DEFM	'2'+80H
	DEFM	't'+80H
	DEFM	'p', 00H
	DEFB	00H
	DEFB	00H
	DEFM	'Piano 2 ', 00H
	DEFB	0CH
	DEFB	08H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'0', 0FH
	DEFM	'Y'+80H
	DEFB	10H
	DEFM	'0', 00H
	DEFB	00H
	DEFB	00H
	DEFB	10H
	DEFB	00H
	DEFM	'2'+80H
	DEFM	's'+80H
	DEFM	'p', 00H
	DEFB	00H
	DEFB	00H
	DEFM	'Violin  '
	DEFB	00H
	DEFB	0CH
	DEFM	'n', 00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'a', 12H
	DEFM	'4'+80H
	DEFB	14H
	DEFB	10H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'a', 00H
	DEFM	'V', 17H
	DEFB	80H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'Flute   ', 00H
	DEFB	0CH
	DEFB	0EH
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'a l', 18H
	DEFM	'@', 00H
	DEFB	00H
	DEFB	00H
	DEFM	'1', 03H
	DEFM	'C&', 80H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'Clarinet', 00H
	DEFB	0CH
	DEFB	0EH
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'"'+80H
	DEFM	' '+80H
	DEFB	88H
	DEFB	14H
	DEFM	'@', 00H
	DEFB	00H
	DEFB	00H
	DEFM	'0', 00H
	DEFM	'T', 06H
	DEFB	80H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'Oboe    '
	DEFB	00H
	DEFB	00H
	DEFB	0AH
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'1 r', 0AH
	DEFM	'@', 00H
	DEFB	00H
	DEFB	00H
	DEFM	'4', 01H
	DEFM	'V', 1CH
	DEFB	80H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'Trumpet ', 00H
	DEFB	00H
	DEFM	'n', 00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'1', 16H
	DEFM	'Q&@', 00H
	DEFB	00H
	DEFB	00H
	DEFM	'q', 03H
	DEFM	'R$`', 00H
	DEFB	00H
	DEFB	00H
	DEFM	'PipeOrgn', 01H
	DEFB	00H
	DEFB	0CH
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'47Pv0', 00H
	DEFB	00H
	DEFB	00H
	DEFM	'0', 00H
	DEFM	'0', 06H
	DEFB	80H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'Xylophon'
	DEFB	00H
	DEFB	00H
	DEFB	0AH
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	17H
	DEFB	18H
	DEFB	88H
	DEFM	'f', 80H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'R', 00H
	DEFM	'Y'+80H
	DEFM	'$', 80H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'Organ   ', 00H
	DEFB	00H
	DEFM	'm'+80H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'a'+80H
	DEFB	0AH
	DEFM	'|'+80H
	DEFM	'(p', 00H
	DEFB	00H
	DEFB	00H
	DEFM	'c', 05H
	DEFM	'x'+80H
	DEFM	')p', 00H
	DEFB	00H
	DEFB	00H
	DEFM	'Guitar  ', 00H
	DEFB	00H
	DEFB	0AH
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	02H
	DEFB	15H
	DEFM	'#'+80H
	DEFM	'u ', 00H
	DEFB	00H
	DEFB	00H
	DEFM	'A', 00H
	DEFM	'#'+80H
	DEFB	05H
	DEFM	'`', 00H
	DEFB	00H
	DEFB	00H
	DEFM	'Santool '
	DEFB	00H
	DEFM	'y'+80H
	DEFB	0CH
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	19H
	DEFB	0CH
	DEFM	'G'+80H
	DEFB	11H
	DEFB	10H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'S', 03H
	DEFM	'u'+80H
	DEFB	03H
	DEFM	'`', 00H
	DEFB	00H
	DEFB	00H
	DEFM	'Elecpian', 00H
	DEFM	'm'+80H
	DEFB	0EH
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'#', 0FH
	DEFM	']'+80H
	DEFM	'J ', 00H
	DEFB	00H
	DEFB	00H
	DEFM	'C', 00H
	DEFM	'?'+80H
	DEFB	05H
	DEFM	'P', 00H
	DEFB	00H
	DEFB	00H
	DEFM	'Clavicod', 00H
	DEFM	'm'+80H
	DEFB	0CH
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	03H
	DEFB	11H
	DEFM	'R'+80H
	DEFM	't'+80H
	DEFM	' ', 00H
	DEFB	00H
	DEFB	00H
	DEFB	09H
	DEFB	08H
	DEFM	'4'+80H
	DEFM	'u'+80H
	DEFM	'`', 00H
	DEFB	00H
	DEFB	00H
	DEFM	'Harpsicd'
	DEFB	00H
	DEFB	0CH
	DEFB	0DH
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	01H
	DEFB	06H
	DEFM	'#'+80H
	DEFM	't'+80H
	DEFM	'@', 00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	19H
	DEFM	'b'+80H
	DEFM	't'+80H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'Harpscd2', 00H
	DEFB	00H
	DEFB	0CH
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	01H
	DEFB	11H
	DEFM	'@'+80H
	DEFB	01H
	DEFM	' ', 00H
	DEFB	00H
	DEFB	00H
	DEFB	01H
	DEFB	08H
	DEFM	'4'+80H
	DEFM	'v'+80H
	DEFB	80H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'Vibraphn', 00H
	DEFB	00H
	DEFM	'l'+80H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'y'+80H
	DEFM	'$', 95H
	DEFM	'e'+80H
	DEFB	80H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'q'+80H
	DEFB	00H
	DEFM	'Q'+80H
	DEFM	'r'+80H
	DEFM	'p', 00H
	DEFB	00H
	DEFB	00H
	DEFM	'Koto    '
	DEFB	00H
	DEFB	00H
	DEFB	0CH
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	13H
	DEFB	0CH
	DEFM	'|'+80H
	DEFM	'30', 00H
	DEFB	00H
	DEFB	00H
	DEFB	11H
	DEFB	00H
	DEFM	'R'+80H
	DEFB	83H
	DEFB	80H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'Taiko   ', 00H
	DEFM	't'+80H
	DEFB	0EH
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	01H
	DEFB	0EH
	DEFM	'J'+80H
	DEFM	'D ', 00H
	DEFB	00H
	DEFB	00H
	DEFB	10H
	DEFB	00H
	DEFM	'f'+80H
	DEFM	'$', 80H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'Engine  ', 00H
	DEFM	'h'+80H
	DEFM	'n', 00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'`'+80H
	DEFB	1BH
	DEFB	11H
	DEFB	04H
	DEFM	'@', 00H
	DEFB	00H
	DEFB	00H
	DEFM	't'+80H
	DEFB	80H
	DEFM	'p'+80H
	DEFB	08H
	DEFM	'P', 00H
	DEFB	00H
	DEFB	00H
	DEFM	'UFO     '
	DEFB	00H
	DEFB	0CH
	DEFM	'n'+80H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	0FFH
	DEFB	19H
	DEFM	'P', 05H
	DEFM	'`', 00H
	DEFB	00H
	DEFB	00H
	DEFM	'p', 00H
	DEFB	1FH
	DEFB	01H
	DEFM	'@', 00H
	DEFB	00H
	DEFB	00H
	DEFM	'SynBell ', 00H
	DEFB	00H
	DEFB	0EH
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	13H
	DEFB	11H
	DEFM	'z'+80H
	DEFM	'!0', 00H
	DEFB	00H
	DEFB	00H
	DEFB	11H
	DEFB	00H
	DEFM	'r'+80H
	DEFM	't'+80H
	DEFB	80H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'Chime   ', 00H
	DEFB	00H
	DEFM	'j'+80H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'&'+80H
	DEFB	10H
	DEFM	'{'+80H
	DEFB	11H
	DEFM	' ', 00H
	DEFB	00H
	DEFB	00H
	DEFM	'B', 0BH
	DEFM	'9'+80H
	DEFB	02H
	DEFM	'`', 00H
	DEFB	00H
	DEFB	00H
	DEFM	'SynBass '
	DEFM	'x'+80H
	DEFM	's'+80H
	DEFB	0CH
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'@', 89H
	DEFM	'G'+80H
	DEFB	14H
	DEFM	'@', 00H
	DEFB	00H
	DEFB	00H
	DEFM	'1', 00H
	DEFM	'y'+80H
	DEFB	04H
	DEFB	80H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'Synthsiz', 00H
	DEFM	'h'+80H
	DEFM	'l', 00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'B', 0BH
	DEFB	94H
	DEFM	'3', 00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'D', 05H
	DEFM	'0'+80H
	DEFM	'v'+80H
	DEFM	'P', 00H
	DEFB	00H
	DEFB	00H
	DEFM	'SynPercu', 00H
	DEFM	't'+80H
	DEFB	0EH
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	01H
	DEFB	0BH
	DEFM	':'+80H
	DEFM	'%`', 00H
	DEFB	00H
	DEFB	00H
	DEFB	03H
	DEFB	00H
	DEFM	'Y'+80H
	DEFB	06H
	DEFB	80H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'SynRhyth'
	DEFB	00H
	DEFB	0CH
	DEFB	0EH
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'@', 00H
	DEFM	'z'+80H
	DEFM	'7@', 00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'Y'+80H
	DEFB	04H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'HarmDrum', 00H
	DEFM	'a'+80H
	DEFB	0EH
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	02H
	DEFB	09H
	DEFM	'K'+80H
	DEFM	'9`', 00H
	DEFB	00H
	DEFB	00H
	DEFB	03H
	DEFB	00H
	DEFB	0FFH
	DEFB	06H
	DEFB	80H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'Cowbell ', 00H
	DEFM	't'+80H
	DEFB	0AH
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	18H
	DEFB	09H
	DEFM	'x'+80H
	DEFM	'& ', 00H
	DEFB	00H
	DEFB	00H
	DEFB	11H
	DEFB	00H
	DEFM	'u'+80H
	DEFM	'&`', 00H
	DEFB	00H
	DEFB	00H
	DEFM	'ClseHiht'
	DEFB	00H
	DEFB	18H
	DEFB	0EH
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	0BH
	DEFB	09H
	DEFM	'p'+80H
	DEFB	01H
	DEFB	80H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	04H
	DEFB	00H
	DEFM	'u'+80H
	DEFM	'''', 80H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'SnareDrm', 00H
	DEFB	00H
	DEFM	'n', 00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'@', 07H
	DEFM	'P'+80H
	DEFB	01H
	DEFB	80H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'@', 00H
	DEFM	'V'+80H
	DEFM	'''', 80H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'BassDrum', 00H
	DEFM	't'+80H
	DEFB	0CH
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	07H
	DEFM	'K'+80H
	DEFM	'6@', 00H
	DEFB	00H
	DEFB	00H
	DEFB	01H
	DEFB	00H
	DEFM	'c'+80H
	DEFM	'%', 80H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'Piano 3 '
	DEFB	00H
	DEFB	00H
	DEFB	08H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	11H
	DEFB	08H
	DEFM	'z'+80H
	DEFM	' 0', 00H
	DEFB	00H
	DEFB	00H
	DEFB	11H
	DEFB	00H
	DEFM	'2'+80H
	DEFM	't'+80H
	DEFM	'p', 00H
	DEFB	00H
	DEFB	00H
	DEFM	'Elecpia2', 00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	11H
	DEFB	11H
	DEFM	'@'+80H
	DEFB	01H
	DEFB	10H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	11H
	DEFB	00H
	DEFM	'2'+80H
	DEFM	't'+80H
	DEFB	80H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'Santool2', 00H
	DEFM	'm'+80H
	DEFB	0EH
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	19H
	DEFB	15H
	DEFM	'g'+80H
	DEFM	'!', 80H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'S', 03H
	DEFB	95H
	DEFB	03H
	DEFM	'`', 00H
	DEFB	00H
	DEFB	00H
	DEFM	'Brass   '
	DEFB	00H
	DEFB	00H
	DEFM	'n', 00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'0', 19H
	DEFM	'B&@', 00H
	DEFB	00H
	DEFB	00H
	DEFM	'p', 00H
	DEFM	'b$`', 00H
	DEFB	00H
	DEFB	00H
	DEFM	'Flute 2 ', 00H
	DEFB	0CH
	DEFB	0EH
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'b%d', 12H
	DEFM	'@', 00H
	DEFB	00H
	DEFB	00H
	DEFM	'q', 03H
	DEFM	'C&', 80H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'Clavicd2', 00H
	DEFB	0CH
	DEFB	0AH
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'!', 0BH
	DEFB	90H
	DEFB	02H
	DEFM	'P', 00H
	DEFB	00H
	DEFB	00H
	DEFB	03H
	DEFB	03H
	DEFM	'T'+80H
	DEFM	'u'+80H
	DEFM	'`', 00H
	DEFB	00H
	DEFB	00H
	DEFM	'Clavicd3'
	DEFB	00H
	DEFB	0CH
	DEFB	0AH
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	01H
	DEFB	0AH
	DEFB	90H
	DEFB	03H
	DEFM	'@', 00H
	DEFB	00H
	DEFB	00H
	DEFB	03H
	DEFB	03H
	DEFM	'$'+80H
	DEFM	'u'+80H
	DEFM	'`', 00H
	DEFB	00H
	DEFB	00H
	DEFM	'Koto 2  ', 00H
	DEFM	'm'+80H
	DEFB	0AH
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'C', 0EH
	DEFM	'5'+80H
	DEFB	84H
	DEFM	'P', 00H
	DEFB	00H
	DEFB	00H
	DEFM	'S', 81H
	DEFM	'i'+80H
	DEFB	04H
	DEFM	'`', 00H
	DEFB	00H
	DEFB	00H
	DEFM	'PipeOrg2', 00H
	DEFB	00H
	DEFB	0CH
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'4&Pv0', 00H
	DEFB	00H
	DEFB	00H
	DEFM	'0', 00H
	DEFM	'0', 06H
	DEFB	80H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'PohdsPLA'
	DEFB	00H
	DEFM	'm'+80H
	DEFB	0CH
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'sZ', 99H
	DEFB	14H
	DEFM	'`', 00H
	DEFB	00H
	DEFB	00H
	DEFM	'3', 00H
	DEFM	'u'+80H
	DEFB	15H
	DEFB	80H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'RohdsPRA', 00H
	DEFM	'm'+80H
	DEFB	0AH
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	's', 16H
	DEFM	'y'+80H
	DEFM	'3`', 00H
	DEFB	00H
	DEFB	00H
	DEFB	13H
	DEFB	00H
	DEFM	'u'+80H
	DEFB	03H
	DEFM	'P', 00H
	DEFB	00H
	DEFB	00H
	DEFM	'Orch L  ', 00H
	DEFB	0CH
	DEFB	0EH
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'a', 15H
	DEFM	'v#@', 00H
	DEFB	00H
	DEFB	00H
	DEFM	'!', 00H
	DEFM	'T', 06H
	DEFM	'p', 00H
	DEFB	00H
	DEFB	00H
	DEFM	'Orch R  '
	DEFB	00H
	DEFB	00H
	DEFB	0EH
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'c', 1BH
	DEFM	'uE`', 00H
	DEFB	00H
	DEFB	00H
	DEFM	'p', 00H
	DEFM	'K', 15H
	DEFM	'p', 00H
	DEFB	00H
	DEFB	00H
	DEFM	'SynViol ', 00H
	DEFB	0CH
	DEFB	0AH
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'a', 0AH
	DEFM	'v', 12H
	DEFM	'@', 00H
	DEFB	00H
	DEFB	00H
	DEFM	'!'+80H
	DEFB	02H
	DEFM	'T', 07H
	DEFB	80H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'SynOrgan', 00H
	DEFM	't'+80H
	DEFB	0AH
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'a', 0DH
	DEFB	85H
	DEFB	14H
	DEFM	'@', 00H
	DEFB	00H
	DEFB	00H
	DEFM	'x', 08H
	DEFM	'r'+80H
	DEFB	03H
	DEFM	'`', 00H
	DEFB	00H
	DEFB	00H
	DEFM	'SynBrass'
	DEFB	00H
	DEFM	't'+80H
	DEFB	0EH
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'1', 15H
	DEFM	'6'+80H
	DEFB	03H
	DEFM	'@', 00H
	DEFB	00H
	DEFB	00H
	DEFM	'q', 00H
	DEFM	'y'+80H
	DEFM	'&`', 00H
	DEFB	00H
	DEFB	00H
	DEFM	'Tube    ', 00H
	DEFM	't'+80H
	DEFB	0AH
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'a', 0DH
	DEFM	'u', 18H
	DEFM	'@', 00H
	DEFB	00H
	DEFB	00H
	DEFM	'q', 00H
	DEFM	'r'+80H
	DEFB	03H
	DEFM	'`', 00H
	DEFB	00H
	DEFB	00H
	DEFM	'Shamisen', 00H
	DEFM	'm'+80H
	DEFB	0CH
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	03H
	DEFB	14H
	DEFM	''''+80H
	DEFB	13H
	DEFM	'P', 00H
	DEFB	00H
	DEFB	00H
	DEFB	0CH
	DEFB	03H
	DEFM	'|'+80H
	DEFB	15H
	DEFM	'`', 00H
	DEFB	00H
	DEFB	00H
	DEFM	'Magical '
	DEFB	00H
	DEFM	't'+80H
	DEFB	06H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	13H
	DEFB	80H
	DEFM	' ', 03H
	DEFM	'`', 00H
	DEFB	00H
	DEFB	00H
	DEFM	'2', 00H
	DEFB	85H
	DEFM	'/'+80H
	DEFM	'@', 00H
	DEFB	00H
	DEFB	00H
	DEFM	'Huwawa  ', 00H
	DEFB	00H
	DEFB	0AH
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'q'+80H
	DEFB	17H
	DEFM	'#', 14H
	DEFM	' ', 00H
	DEFB	00H
	DEFB	00H
	DEFM	'1', 00H
	DEFM	'@', 09H
	DEFB	80H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'WnderFlt', 00H
	DEFB	00H
	DEFM	'n'+80H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'p'+80H
	DEFB	17H
	DEFM	'Z', 06H
	DEFM	'@', 00H
	DEFB	00H
	DEFB	00H
	DEFM	't@C', '|'+80H
	DEFB	80H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'Hardrock'
	DEFB	00H
	DEFB	00H
	DEFM	'l', 00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	' ', 0DH
	DEFM	'A'+80H
	DEFM	'V ', 00H
	DEFB	00H
	DEFB	00H
	DEFM	'q', 02H
	DEFM	'U'+80H
	DEFB	06H
	DEFM	'`', 00H
	DEFB	00H
	DEFB	00H
	DEFM	'Machine ', 00H
	DEFM	't'+80H
	DEFB	0CH
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'0', 06H
	DEFM	'@', 04H
	DEFB	80H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'2', 00H
	DEFM	'@t0', 00H
	DEFB	00H
	DEFB	00H
	DEFM	'MachineV', 00H
	DEFM	't'+80H
	DEFB	06H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'0', 03H
	DEFM	'@', 04H
	DEFB	80H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'2', 00H
	DEFM	'@t0', 00H
	DEFB	00H
	DEFB	00H
	DEFM	'Comic   '
	DEFB	00H
	DEFM	't'+80H
	DEFB	0EH
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	01H
	DEFB	0DH
	DEFM	'x', 7FH
	DEFM	'@', 00H
	DEFB	00H
	DEFB	00H
	DEFB	08H
	DEFB	00H
	DEFM	'x'+80H
	DEFM	'y'+80H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'SE_Comic', 00H
	DEFM	'h'+80H
	DEFM	'j', 00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'H'+80H
	DEFB	0BH
	DEFM	'v', 11H
	DEFM	'@', 00H
	DEFB	00H
	DEFB	00H
	DEFM	'@'+80H
	DEFB	00H
	DEFM	'w'+80H
	DEFM	'y'+80H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'SE_Laser', 00H
	DEFM	'0n', 00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'I', 0BH
	DEFM	'4'+80H
	DEFB	0FFH
	DEFM	' ', 00H
	DEFB	00H
	DEFB	00H
	DEFM	'@', 00H
	DEFM	'y'+80H
	DEFB	05H
	DEFM	'`', 00H
	DEFB	00H
	DEFB	00H
	DEFM	'SE_Noise'
	DEFB	00H
	DEFM	'$', ','+80H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'M'+80H
	DEFB	0CH
	DEFM	'"'+80H
	DEFB	00H
	DEFB	80H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'B', 00H
	DEFM	'p'+80H
	DEFB	01H
	DEFB	80H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'SE_Star ', 00H
	DEFB	00H
	DEFM	'n', 00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'Q', 13H
	DEFB	13H
	DEFM	'B@', 00H
	DEFB	00H
	DEFB	00H
	DEFM	'B', 00H
	DEFB	10H
	DEFB	01H
	DEFM	'P', 00H
	DEFB	00H
	DEFB	00H
	DEFM	'SE_Star2', 00H
	DEFM	'$n', 00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'Q', 13H
	DEFB	13H
	DEFM	'B@', 00H
	DEFB	00H
	DEFB	00H
	DEFM	'B', 00H
	DEFB	10H
	DEFB	01H
	DEFM	'P', 00H
	DEFB	00H
	DEFB	00H
	DEFM	'Engine 2'
	DEFB	00H
	DEFM	'h'+80H
	DEFB	0CH
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFM	'0', 12H
	DEFM	'#&@', 00H
	DEFB	00H
	DEFB	00H
	DEFM	'4', 07H
	DEFM	'p', 02H
	DEFM	'P', 00H
	DEFB	00H
	DEFB	00H
	DEFM	'Silence ', 00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	0FFH
	DEFB	00H
	DEFB	0FFH
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	0FFH
	DEFB	00H
	DEFB	0FFH
	DEFB	00H
	DEFB	00H
	DEFB	00H
	DEFB	00H

	DEFS	07FEDH-$, 0

J.KEYINT:
	JP	J5003

	DEFS	07FF6H-$, 0

D7FF6:	DEFB	0
D7FF7:	DEFB	0

	DEFS	08000H-$, 0

	END
