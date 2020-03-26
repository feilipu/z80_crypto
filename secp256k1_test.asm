SECTION code_user

EXTERN      G0X
EXTERN      G255X
EXTERN      MOD1Q

EXTERN      ECGX
EXTERN      ECGY

EXTERN      MODADD
EXTERN      MODSUB
EXTERN      MODMUL
EXTERN      MODCAN
EXTERN      MODINV

EXTERN      MODQADD
EXTERN      MODSUBQ
EXTERN      MODQMUL
EXTERN      MODQCAN
EXTERN      MODQINV

EXTERN      ECMUL
EXTERN      ECGMUL

EXTERN      ECADD
EXTERN      ECDOUB


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
    ld      e,'.'                           ; print a progress comfort "."
    ld      c, condio
    call    bdos

    JP      TMODMUL     ; 32768
    JP      TMODINV     ; 32771
    JP      TECDOUB     ; 32774
    JP      TECADD      ; 32777
    JP      TECMUL      ; 32780
    JP      TMQMUL      ; 32783
    JP      TMQINV      ; 32786
    JP      TECGMUL     ; 32789
; Tests 256 bit modular multiplication
; In: XVALUE, YVALUE: little-endian 256 bit multiplicands, EXPECT: little-endian 256 bit expected product
; Out: B = 0 if test passed, length of erroneous prefix (LSB) otherwise
TMODMUL:
    LD      HL,LAM

    EXX
    PUSH    HL
    LD      HL,XVALUE
    LD      DE,YVALUE
TMMC:
    CALL    MODMUL
    LD      HL,LAM + 0x1F
    CALL    MODCAN
CHECKS:
    EXX
    POP     HL

    EXX
    LD      DE,EXPECT + 0x20
    LD      BC,0x2000
CHECK:
    DEC     DE
    DEC     HL
    LD      A,(DE)
    CP      (HL)
    RET     NZ
    DJNZ    CHECK
    RET

; Tests 256 bit modular multiplication
; In: XVALUE, ZVALUE: little-endian 256 bit multiplicands, EXPECT: little-endian 256 bit expected product
; Out: B = 0 if test passed, length of erroneous prefix (LSB) otherwise
TMQMUL:
    LD      HL,LAM

    EXX
    PUSH    HL
    LD      HL,XVALUE
    LD      DE,ZVALUE
TMQMC:
    CALL    MODQMUL
    LD      HL,LAM + 0x1F
    CALL    MODQCAN
    JR      CHECKS

; Tests 256 bit modular inverse
; In: XVALUE: value to invert
; Out: BC = 0 if test passed
TMQINV:
    LD      HL,XVALUE
    LD      DE,ECV
    CALL    MODQINV
    LD      HL,LAM

    EXX
    PUSH    HL
    LD      HL,XVALUE
    LD      DE,ECV
    JR      TMQMC

; Tests 256 bit modular inverse
; In: XVALUE: value to invert
; Out: BC = 0 if test passed
TMODINV:
    LD      HL,XVALUE
    LD      DE,ECV
    CALL    MODINV
    LD      HL,LAM

    EXX
    PUSH    HL
    LD      HL,XVALUE
    LD      DE,ECV
    JR      TMMC

; Tests doubling of generator point on EC
TECDOUB:
    EXX
    PUSH    HL
    LD      B,255
    LD      HL,G0X
TECDBL:
    PUSH    BC
    PUSH    HL
    CALL    ECDOUB
    POP     HL
    LD      DE,0x0040
    ADD     HL,DE
    PUSH    HL
    EX      DE,HL
    CALL    CHECKP
    POP     HL
    POP     BC
    JR      NZ,TECDBF
    DJNZ    TECDBL
    LD      C,B
TECDBF:
    POP     HL
    PUSH    BC

    EXX
    POP     BC
    RET

; Tests point addition
TECADD:
    EXX
    PUSH    HL
    LD      HL,ECGX
    LD      DE,ECG2X
    CALL    ECADD
    POP     HL

    EXX
    LD      DE,ECG3X
CHECKP:
    LD      HL,ECX
    LD      BC,0x4000
CHECKD:
    LD      A,(DE)
    CP      (HL)
    RET     NZ
    INC     DE
    INC     HL
    DJNZ    CHECKD
    RET

; Tests point multiplication
TECMUL:
    EXX
    PUSH    HL
    LD      HL,ECGX
    LD      DE,PRIVK + 0x1F
    CALL    ECMUL
CHECKEC:
    POP     HL

    EXX
    LD      DE,ECGX
    LD      HL,ECB
    LD      BC,0x2001
    CALL    CHECKD
    LD      A,B
    OR      A
    RET     NZ
    CALL    MODADD
    LD      HL,ECB + 0x3F
    CALL    MODCAN
    LD      HL,ECB + 0x20
    LD      BC,0x2000
CHECKQ:
    LD      A,(HL)
    OR      A
    RET     NZ
    INC     HL
    DJNZ    CHECKQ
    RET

; Tests generator point multiplication
TECGMUL:
    EXX
    PUSH    HL
    LD      DE,PRIVK + 0x1F
    CALL    ECGMUL
    JR      CHECKEC

;------------------------------------------------------------------------------
;   Print message pointed to by (DE). It will end with a '$'.
;   modifies AF, DE, & HL

SECTION     code_user

prtmesg:
    ld      a,(de)      ; Get character from DE address
    cp      '$'
    ret     Z
    inc     de
    push    de          ;otherwise, bump pointer and print it.
    ld      e,a
    ld      c, condio
    call    bdos
    pop     de
    jr      prtmesg
        
;------------------------------------------------------------------------------

SECTION     data_user

PRINT_OK:
        defm "  SECP256K1 OK",lf,eos
PRINT_FAIL:
        defm " SECP256K1 FAIL",lf,eos

;------------------------------------------------------------------------------

SECTION     data_user

ALIGN       $100

PUBLIC      MODINVU
PUBLIC      MODINVV
PUBLIC      MODINVD
PUBLIC      MODINVA
PUBLIC      MODINVUV
PUBLIC      ECB

MODINVU:    DEFS    0x22
MODINVV:    DEFS    0x22
MODINVD:    DEFS    0x20
MODINVA:    DEFS    2
MODINVUV:   DEFS    2
ECB:        DEFS    0x40

ALIGN       $100

PUBLIC      ECX
PUBLIC      ECY
PUBLIC      ECV

ECX:        DEFS    0x20
ECY:        DEFS    0x20
ECV:        DEFS    0x20

ALIGN       $100

PUBLIC      LAM
PUBLIC      ECW

LAM:        DEFS    0x20
ECW:        DEFS    0x20

ALIGN       $100

XVALUE:
    DEFB    0x70, 0xA9, 0x21, 0xF6
    DEFB    0x1F, 0xA1, 0x8F, 0x38
    DEFB    0x33, 0xA8, 0x0A, 0x4D
    DEFB    0x91, 0x68, 0x2F, 0xFA
    DEFB    0x51, 0x11, 0x22, 0x1C
    DEFB    0xF8, 0xF7, 0x49, 0xBB
    DEFB    0xCA, 0x88, 0x47, 0x4D
    DEFB    0xEE, 0xB4, 0x75, 0x90

YVALUE:
    DEFB    0xA6, 0xA6, 0x67, 0x97
    DEFB    0xEC, 0xAE, 0xBE, 0x0F
    DEFB    0x34, 0x3D, 0xDC, 0x53
    DEFB    0x23, 0x60, 0x55, 0xC1
    DEFB    0x6A, 0xA4, 0xF0, 0xC5
    DEFB    0x11, 0x90, 0xE7, 0x4D
    DEFB    0x31, 0x4D, 0xD7, 0x4E
    DEFB    0x06, 0x1A, 0xE3, 0xB7

ZVALUE:
    DEFB    0xA0, 0x67, 0x54, 0x4C
    DEFB    0x66, 0x06, 0xDA, 0xA9
    DEFB    0x72, 0xCA, 0x85, 0xCD
    DEFB    0xD0, 0xC7, 0x7D, 0x23
    DEFB    0x6E, 0x8C, 0xA2, 0xDD
    DEFB    0xAC, 0xAC, 0xA7, 0x45
    DEFB    0x41, 0x81, 0xC7, 0xCC
    DEFB    0x90, 0x0A, 0x6E, 0xE5

EXPECT:
    DEFB    0x01, 0x00, 0x00, 0x00
    DEFB    0x00, 0x00, 0x00, 0x00
    DEFB    0x00, 0x00, 0x00, 0x00
    DEFB    0x00, 0x00, 0x00, 0x00
    DEFB    0x00, 0x00, 0x00, 0x00
    DEFB    0x00, 0x00, 0x00, 0x00
    DEFB    0x00, 0x00, 0x00, 0x00
    DEFB    0x00, 0x00, 0x00, 0x00

ECG2X:
    DEFB    0xE5, 0x9E, 0x70, 0x5C
    DEFB    0xB9, 0x09, 0xAC, 0xAB
    DEFB    0xA7, 0x3C, 0xEF, 0x8C
    DEFB    0x4B, 0x8E, 0x77, 0x5C
    DEFB    0xD8, 0x7C, 0xC0, 0x95
    DEFB    0x6E, 0x40, 0x45, 0x30
    DEFB    0x6D, 0x7D, 0xED, 0x41
    DEFB    0x94, 0x7F, 0x04, 0xC6
ECG2Y:
    DEFB    0x2A, 0xE5, 0xCF, 0x50
    DEFB    0xA9, 0x31, 0x64, 0x23
    DEFB    0xE1, 0xD0, 0x66, 0x32
    DEFB    0x65, 0x32, 0xF6, 0xF7
    DEFB    0xEE, 0xEA, 0x6C, 0x46
    DEFB    0x19, 0x84, 0xC5, 0xA3
    DEFB    0x39, 0xC3, 0x3D, 0xA6
    DEFB    0xFE, 0x68, 0xE1, 0x1A

ECG3X:
    DEFB    0xF9, 0x36, 0xE0, 0xBC
    DEFB    0x13, 0xF1, 0x01, 0x86
    DEFB    0xB0, 0x99, 0x6F, 0x83
    DEFB    0x45, 0xC8, 0x31, 0xB5
    DEFB    0x29, 0x52, 0x9D, 0xF8
    DEFB    0x85, 0x4F, 0x34, 0x49
    DEFB    0x10, 0xC3, 0x58, 0x92
    DEFB    0x01, 0x8A, 0x30, 0xF9
ECG3Y:
    DEFB    0x72, 0xE6, 0xB8, 0x84
    DEFB    0x75, 0xFD, 0xB9, 0x6C
    DEFB    0x1B, 0x23, 0xC2, 0x34
    DEFB    0x99, 0xA9, 0x00, 0x65
    DEFB    0x56, 0xF3, 0x37, 0x2A
    DEFB    0xE6, 0x37, 0xE3, 0x0F
    DEFB    0x14, 0xE8, 0x2D, 0x63
    DEFB    0x0F, 0x7B, 0x8F, 0x38

; Order of (Gx,-Gy)
PRIVK:
    DEFB    0x40, 0x41, 0x36, 0xD0
    DEFB    0x8C, 0x5E, 0xD2, 0xBF
    DEFB    0x3B, 0xA0, 0x48, 0xAF
    DEFB    0xE6, 0xDC, 0xAE, 0xBA
    DEFB    0xFE, 0xFF, 0xFF, 0xFF
    DEFB    0xFF, 0xFF, 0xFF, 0xFF
    DEFB    0xFF, 0xFF, 0xFF, 0xFF
    DEFB    0xFF, 0xFF, 0xFF, 0xFF

