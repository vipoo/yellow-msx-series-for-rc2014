	include "msxdos.inc"

; extern uint16_t msxdosReadFile(const uint8_t file_handle, const void *buf, uint16_t nbytes)  __sdcccall(1);
	PUBLIC	_msxdosReadFile

_msxdosReadFile:
	PUSH	IX
	LD	IX, 0
	ADD	IX, SP

	LD	B, (IX+4) 	; file_handle
	LD	E, (IX+5)  	; buff
	LD	D, (IX+6)
	LD	L, (IX+7)  	; nbytes
	LD	H, (IX+8)

	ld	c, $48
	CALL	BDOS
				; a error code is ignored
	POP	IX
	RET