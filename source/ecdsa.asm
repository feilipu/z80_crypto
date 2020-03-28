;------------------------------------------------------------------------------
; ECDSA signature
; In: KECCAKS hash state, PRIVK private key
; Out: ECX r, ECV s, A v

SECTION     code_user

EXTERN      MODQADD
EXTERN      MODQMUL

EXTERN      ECGMUL

EXTERN      KECCAKI
EXTERN      KECCAKU
EXTERN      KECCAKR
EXTERN      KECCAK

EXTERN      KECCAKS

EXTERN      ECDSAZ

PUBLIC      ECDSAS

ECDSAS:
    CALL	KECCAK
	LD	    DE,KECCAKS
	LD	    HL,ECDSAZ + 0x20
	LD	    B,0x20
ECDSAL1:
    LD	    A,(DE)	    ; Save Z
	INC	    E
	DEC	    L
	LD	    (HL),A
	DJNZ	ECDSAL1
	LD	    HL,PRIVK
	LD	    C,0x20
	LDIR			    ; Concatenate Z and Pk
	LD	    L,E
	LD	    H,D
	LD	    (KECCAKP),HL
	INC	    E
	LD	    (HL),C
	LD	    BC,0x87
	LDIR
	CALL	KECCAK		; Deterministic K
	LD	    HL,KECCAKS
	LD	    DE,ECDSAK
	CALL	MODQINV
	LD	    DE,KECCAKS + 0x1F
	CALL	ECGMUL
	LD	    HL,ECDSAM
	PUSH	HL

	EXX
	LD	    HL,PRIVK
	LD	    DE,ECX
	CALL	MODQMUL
	POP     DE
	PUSH	DE
	LD	    HL,ECDSAZ
	CALL	MODQADD
	POP	    HL

	EXX
	LD	    HL,ECDSAZ
	LD	    DE,ECDSAK
	CALL	MODQMUL
	LD	    A,(ECY)
	AND	    1
	ADD	    0x1B
	RET
