
SECTION     code_user

EXTERN      KECCAKI
EXTERN      KECCAK

PUBLIC      _main

ALIGN       $100

_main:
    EXX
    PUSH    HL
    CALL    KECCAKI
    CALL    KECCAK
    POP     HL
    EXX
    RET

