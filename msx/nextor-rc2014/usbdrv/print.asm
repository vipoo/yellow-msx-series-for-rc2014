
	include	"msx.inc"
;-----------------------------------------------------------------------------
;
; Print a zero-terminated string on screen
; Input: HL = String address
; Protects AF
	PUBLIC	_print_string

_print_string:
	push	af
_print_more:
	ld	a, (hl)
	and	a
	jr	z, _print_done
	call	CHPUT
	inc	hl
	jr	_print_more
_print_done:
	pop	af
	ret

	PUBLIC	_x_print_string
_x_print_string:
	push	af

_x_print_more:
	ld	a, (hl)
	and	a
	jr	z, _x_print_done
	call	print_char_vdp
	inc	hl
	jr	_x_print_more

_x_print_done:
	pop	af
	ret

	PUBLIC	_print_char_vdp

_print_char_vdp:
	ld	a, l

print_char_vdp:
	; print to VDP (auto increments)
	out	($98), a
	ret

	PUBLIC	_print_init_screen0
_print_init_screen0:
    ; set pointer to 77,0 for screen 0
	xor	a
	call	set_vdp_for_write
	ret
;
; Set VDP address counter to write from address AHL (17-bit)
; Enables the interrupts
;
set_vdp_for_write:
        rlc     h
        rla
        rlc     h
        rla
        srl     h
        srl     h
        di
        out     ($99), a
        ld      a, 14 + 128
        out     ($99), a
        ld      a,l
        nop
        out     ($99), a
        ld      a, h
        or      64
        ei
        out     ($99), a
        ret

	PUBLIC	_print_hex
; extern void print_hex(const char c) __z88dk_fastcall;

_print_hex:
        call    byte_to_ascii_hex
        ld      a, d
        call    CHPUT
        ld      a, e
        jp      CHPUT

byte_to_ascii_hex:
        ld      a, l
        call    top_nibble
        ld      d, a
        ld	a, l
        call	bottom_nibble
        ld      e, a
        ret

top_nibble:
        rra
        rra
        rra
        rra

bottom_nibble:
        or      $F0
        daa
        add     a, $A0
        adc     a, $40
	ret

	PUBLIC	_print_uint16

	; HL = unsigned 16 bit number to write out
	; call CHPUT to write a single ascii character (in A)
_print_uint16:
	ld	e, 0
	ld	bc, -10000
	call	num1
	ld	bc, -1000
	call	num1
	ld	bc, -100
	call	num1
	ld	c, -10
	call	num1
	ld	c, b

num1:	ld	a, '0'-1
num2:	inc	a
	add	hl, bc
	jr	c, num2
	sbc	hl, bc

	cp	'0'
	jr	nz, num3

	ld	a, e
	cp	1
	ret	nz
	ld	a, '0'

num3:
	ld	e, 1
	jp	CHPUT
