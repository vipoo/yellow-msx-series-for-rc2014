
REQUIRE_EXTBIO	EQU	1
REQUIRE_TIMI	EQU	2

	SECTION	TSR_HEADER

	DB	"sio/2   "
	DB 	REQUIRE_EXTBIO | REQUIRE_TIMI
	DB	0

	SECTION	CODE
	SECTION	code_crt_init
	SECTION code_compiler
	SECTION	bss_compiler
	SECTION IGNORE
