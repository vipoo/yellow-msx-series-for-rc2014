
REQUIRE_EXTBIO	EQU	1
REQUIRE_TIMI	EQU	2
REQUIRE_KEYI	EQU	4

	SECTION	TSR_HEADER

	PUBLIC	_timi_next
	PUBLIC	_timi

defc	_timi_next = 0
defc	_timi = 0

	DB	"sio/2   "
	DS 	8

	SECTION	CODE
	SECTION	code_crt_init
	SECTION code_compiler
	SECTION	bss_compiler
	SECTION IGNORE
