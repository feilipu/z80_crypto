;------------------------------------------------------------------------------
; Check and set ERC55 capitalization of Ethereum addresses
; In: DE address of ASCII address
; Out: BC = 0, if no error
; Pollutes: AF, AF', BC', DE, DE', HL, HL'

SECTION     code_user

EXTERN      KECCAKI
EXTERN      KECCAKU
EXTERN      KECCAKR
EXTERN      KECCAK

EXTERN      KECCAKS

PUBLIC      ERC55

ERC55:
    PUSH	DE
	CALL	KECCAKI
	POP	    DE
	PUSH	DE
	LD	    B,0x28
ERC55L1:
    PUSH	BC
	PUSH	DE
	LD	    A,(DE)
	CP	    "0"
	JR	    C,ERC55E2
	CP	    '9' + 1
	JR	    C,ERC55H
	OR	    0x20
	CP	    'a'
	JR	    C,ERC55E2
	CP	    'f' + 1
	JR	    NC,ERC55E2
ERC55H:
    CALL	KECCAKU
	POP	    DE
	INC	    DE
	POP	    BC
	DJNZ	ERC55L1
	CALL	KECCAK
	POP	    DE
	LD	    HL,KECCAKS
	LD	    BC,0x1400
ERC55L2:
    LD	    A,(DE)
	RL	    (HL)
	BIT	    5,A
	JR	    Z,ERC55U1
	CCF
ERC55U1:
    JR	    C,ERC55N1
	CP	    'A'
	JR	    C,ERC55N1
	INC	    C
	XOR	    0x20
	LD	    (DE),A
ERC55N1:
    INC	    DE
	LD	    A,(DE)
	RL	    (HL)
	RL	    (HL)
	RL	    (HL)
	RL	    (HL)
	BIT	    5,A
	JR	    Z,ERC55U2
	CCF
ERC55U2:
    JR	    C,ERC55N2
	CP	    'A'
	JR	    C,ERC55N2
	INC	    C
	XOR	    0x20
	LD	    (DE),A
ERC55N2:
    INC	    DE
	INC	    HL
	DJNZ	ERC55L2
	RET
	
ERC55E2:
    POP	    HL
	POP	    HL
	LD	    C,0
	RET
