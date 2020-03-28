EMPTY_STRING:    EQU    $3533
V_TEST_FN:      EQU    $28E3
STACK_NUM:    EQU    $33B4
RESTACK:    EQU    $3297
K_CUR:        EQU    $5C5B
CHAN_FLAG:    EQU    $1615
ONE_SPACE:    EQU    $1652
REPORT_2:    EQU    $1C2E
REPORT_A:    EQU    $34E7

OCTA:
    CALL    QUAD
QUAD:
    CALL    DOUBLE
DOUBLE:
    EX    AF,AF
    RL    B
    RL    C
    RL    D
    RL    E
    RLA
    EX    AF,AF
    AND    A        ; clear CF
    RET

FIND_NUMV:
    PUSH    HL        ; dummy placeholder
    CALL    V_TEST_FN    ; one more dummy placeholder and jump

FPDEC:
    LD    C,"a"
    CALL    FIND_NUMV    ; find numeric variable a
    JP    C,REPORT_2    ; 2 Variable not found
    INC    HL
    CALL    STACK_NUM
    RST    $28
    DEFB    $38        ; end_calc
    CALL    RESTACK
    XOR    A
    EX    AF,AF         ; clear A' and CF'
    CALL    STK_FETCH
    SUB    $81
    JR    C,EMPTY
    INC    A
    SET    7,E
    RRA
    CALL    C,DOUBLE
    RRA
    CALL    C,QUAD
    RRA
    CALL    C,OCTA
    PUSH    AF
    EX    AF,AF
    CALL    STK_STO
    LD    BC,1
    RST    $30
    LD    (K_CUR),HL
    POP    AF
    EX    AF,AF
    PUSH    HL
    LD    HL,(CURCHL)
    PUSH    HL
    LD    A,$FF
    CALL    CHAN_OPEN
    CALL    STK_FETCH
    RST    $10
    EX    AF,AF
    OR    A
    JR    Z,FPEND
    PUSH    AF
    LD    A,E
    RST    $10
    POP    AF
    DEC    A
    JR    Z,FPEND
    PUSH    AF
    LD    A,D
    RST    $10
    POP    AF
    DEC    A
    JR    Z,FPEND
    PUSH    AF
    LD    A,C
    RST    $10
    POP    AF
    DEC    A
    JR    Z,FPEND
    PUSH    AF
    LD    A,B
    RST    $10
    POP    AF
    DEC    A
    JR    Z,FPEND
    LD    B,A
FPTAIL:
    XOR    A
    RST    $10
    DJNZ    FPTAIL

FPEND:
    POP    HL
    CALL    CHAN_FLAG
    POP    DE
    LD    HL,(K_CUR)
    AND    A
    SBC    HL,DE
    LD    B,H
    LD    C,L
    JR    RET_STR

EMPTY:
    LD    BC,0
RET_STR:
    CALL    STK_STO
    EX    DE,HL        ; STKEND to DE
    POP    HL        ; discard STACK_BC from USR
    POP    HL        ; return to RE_ENTRY
    POP    BC        ; placeholder (discarded)
    POP    BC        ; USR stuff (discarded)
    POP    AF        ; marker
    POP    BC        ; STR$ priority and offset
    PUSH    AF        ; marker
    PUSH    BC        ; STR$ priority and offset
    PUSH    DE        ; placeholder
    JP    (HL)        ; return to RE_ENTRY

STRDEC:
    LD    BC,1
    RST    $30
    LD    (K_CUR),HL
    PUSH    HL
    LD    HL,(CURCHL)
    PUSH    HL
    LD    A,$FF
    CALL    CHAN_OPEN
    CALL    VAR_FETCH
    OR    C
    JR    Z,FPEND        ; empty input -- empty output
    LD    A,(DE)
    CP    "0"
    JR    NZ,DECDEC
    DEC    BC
    INC    DE
    LD    A,B
    OR    C
    JR    Z,FPEND        ; just zero
    LD    A,(DE)
    CP    "x"
    JR    NZ,DECDEC
    DEC    BC
    INC    DE

HEXDEC:
    XOR    A
    BIT    0,C
    JR    NZ,HEXDEC1
HEXDECL:
    LD    A,B
    OR    C
    JR    Z,FPEND
    LD    A,(DE)
    DEC    BC
    CALL    HEXDD

ERROR_A:
JP    NC,REPORT_A
    ADD    A,A
    ADD    A,A
    ADD    A,A
    ADD    A,A
    INC    DE
HEXDEC1:
    PUSH    AF
    LD    A,(DE)
    DEC    BC
    CALL    HEXDD
    JR    NC,ERROR_A
    POP    HL
    OR    H
    INC    DE
    RST    $10
    JR    HEXDECL

DECDEC:
    SUB    "0"
    JP    C,REPORT_A
    CP    $0A
    JR    NC,ERROR_A
    PUSH    BC
    PUSH    DE
    LD    HL,6
    ADD    HL,SP
    LD    E,(HL)
    INC    HL
    LD    D,(HL)
    LD    HL,(K_CUR)
    SBC    HL,DE
    JR    NZ,DECMORE
    RST    $10
DECON:
    POP    DE
    POP    BC
    INC    DE
    DEC    BC
    LD    A,B
    OR    C
    LD    A,(DE)
    JR    NZ,DECDEC
    JP    FPEND

DECEND:
    EX    AF,AF
    JR    Z,DECON
    PUSH    AF
    LD    HL,8
    ADD    HL,SP
    LD    E,(HL)
    INC    HL
    LD    D,(HL)
    EX    DE,HL
    CALL    ONE_SPACE
    POP    AF
    LD    (DE),A
    JR    DECON

DECMORE:
    EX    DE,HL
    ADD    HL,DE
    PUSH    DE
; HL = end pointer, A = carry, remaining length on stack
DEC10L:
    DEC    HL
    PUSH    HL
    PUSH    AF
    LD    C,(HL)
    LD    B,$0A
    CALL    MUL8
    POP    AF    ; A = carry
    POP    DE    ; DE = end pointer
    POP    BC    ; BC = remaining length
    ADD    A,L
    LD    (DE),A
    LD    A,0
    ADC    A,H
    EX    AF,AF    ; A' = carry
    DEC    BC
    LD    A,B
    OR    C
    JR    Z,DECEND
    EX    AF,AF      ; A = carry
    PUSH    BC
    EX    DE,HL
    JR    DEC10L
