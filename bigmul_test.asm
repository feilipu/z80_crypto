; Tests all 16 x 16 bit = 32 bit integer multiplications
; Out: HL = 0, if correct, prefix error length otherwise

SECTION code_user

EXTERN MUL8
EXTERN BIGMUL

PUBLIC _main

defc bdos       = 05h                       ; bdos vector
defc conout     = 2                         ; console output bdos call
defc condio     = 6                         ; console direct I/O call
defc prints     = 9                         ; print string bdos call
defc cr         = 13                        ; carriage return
defc lf         = 10                        ; line feed
defc esc        = 27                        ; escape
defc eos        = '$'                       ; end of string marker


_main:
        EXX
        PUSH    HL
        EXX

LOOP:
        ld      e,'.'                       ; print a progress comfort "."
        ld      c, condio
        call    bdos

        LD    A,(XVALUE)
        LD    B,A
        LD    A,(YVALUE)
        LD    C,A
        CALL    MUL8
        LD    (EXPECT),HL
        LD    A,(XVALUE+1)
        LD    B,A
        LD    A,(YVALUE+1)
        LD    C,A
        CALL    MUL8
        LD    (EXPECT+2),HL
        LD    A,(XVALUE)
        LD    B,A
        LD    A,(YVALUE+1)
        LD    C,A
        CALL    MUL8
        CALL    ADDMID
        LD    A,(XVALUE+1)
        LD    B,A
        LD    A,(YVALUE)
        LD    C,A
        CALL    MUL8
        CALL    ADDMID
        LD    HL,PRODUCT

        EXX
        LD    HL,XVALUE
        LD    DE,YVALUE
        LD    B,2
        CALL    BIGMUL

        EXX
        LD    DE,PRODUCT
        LD    B,4
L2:
        DEC    HL
        DEC    DE
        LD    A,(DE)
        CP    (HL)
        JR    NZ,ERROR
        DJNZ    L2

        LD    HL,(XVALUE)
        INC    HL
        LD    (XVALUE),HL
        LD    A,L
        OR    H
        JR    NZ,LOOP

        LD    HL,(YVALUE)
        INC    HL
        LD    (YVALUE),HL
        LD    A,L
        OR    H
        JR    NZ,LOOP


        POP    HL

        EXX
        LD    DE,PRINT_OK
        CALL  prtmesg
        RET

ERROR:
        POP    HL
        LD    A,B

        EXX
        ld      e,a
        ld      c, condio
        call    bdos
        LD    DE,PRINT_FAIL
        CALL  prtmesg
        RET

ADDMID:
        LD    A,(EXPECT+1)
        ADD    A,L
        LD    (EXPECT+1),A
        LD    A,(EXPECT+2)
        ADC    A,H
        LD    (EXPECT+2),A
        RET    NC

        LD    A,(EXPECT+3)
        INC    A
        LD    (EXPECT+3),A
        RET

;------------------------------------------------------------------------------
;   Print message pointed to by (DE). It will end with a '$'.
;   modifies AF, DE, & HL

prtmesg:
        ld      a,(de)      ; Get character from DE address
        cp      '$'
        ret     Z
        inc     de
        push    de        ;otherwise, bump pointer and print it.
        ld      e,a
        ld      c, condio
        call    bdos
        pop     de
        jr      prtmesg
        
;------------------------------------------------------------------------------

SECTION  data_user

PRINT_OK:
        defm "  BIGMUL OK",lf,eos
PRINT_FAIL:
        defm " BIGMUL FAIL",lf,eos

ALIGN   $100

XVALUE: DEFS    2

ALIGN   $100
    
YVALUE: DEFS    2

ALIGN   $100

EXPECT: DEFS    4

PRODUCT:

