; 8 x 8 to 16 bit multiplication
; In: B, C multiplicands
; Out: HL product
; Pollutes: AF, F', BC, DE

INCLUDE "config_rc2014_private.inc"

SECTION code_user

PUBLIC MUL8

MUL8:
        ld l,c                      ; 4
        ld c,__IO_LUT_OPERAND_LATCH ; 7  operand latch address
        out (c),l                   ; 12 operand X from L
        in l,(c)                    ; 12 result Z LSB to L
        inc c                       ; 4  result MSB address
        in h,(c)                    ; 12 result Z MSB to H
	    ret                         ; 10
