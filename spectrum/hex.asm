;------------------------------------------------------------------------------
; Encode hexadecimal digit
; In: A binary digit in the 0..F range
; Out: A ascii digit, capitalized
; Pollutes: F

SECTION     code_user

PUBLIC      HEXD

HEXD:
    AND	    0xF
	ADD	    A,0x90
	DAA
	ADC	    A,0x40
	DAA
	SCF
	RET

;------------------------------------------------------------------------------
; Decode hexadecimal digit
; In: A ascii digit
; Out: A binary digit, CF set, if no error

SECTION     code_user

PUBLIC      HEXDD

HEXDD:
    SUB	    '0'
	CCF
	RET	    NC
	CP	    0x0A
	RET	    C
	SUB	    'A' - '0'
	CCF
	RET	    NC
	AND	    0xDF
	ADD	    0x0A
	CP	    0x10
	RET

