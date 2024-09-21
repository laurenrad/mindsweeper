* 8BIT STACK OPERATIONS FOR COLOR BASIC USE V1
* RELOCATABLE VERSION
* ENTRY POINTS
SINIT       BRA     INIT        ; INITIALIZE STACK
SPUSH       BRA     PUSH        ; PUSH VALUE ON STACK
SPOP        BRA     POP         ; POP VALUE FROM STACK
SSIZE       BRA     SIZE        ; RETURN STACK SIZE
* Routines
INIT        JSR     INTCNV
            STD     STKT,PCR    ; SET STACK TOP
            STD     STKB,PCR    ; SET STACK BOTTOM
            RTS
* PUSH: PUSH A VALUE ON TOP OF THE STACK.
* IF STACK IS FULL, WILL RETURN $FFFF. OTHERWISE RETURNS 0.
PUSH        JSR     INTCNV
            LDU     STKT,PCR
            LEAX    -MAXSZE,U
            CMPX    STKT,PCR
            BNE     PUSH2
            LDD     #$FFFF
            BRA     PUSH3
PUSH2       PSHU    B
            CLRA
            CLRB
            STU     STKT,PCR    ; SAVE STACK TOP
PUSH3       JMP     GIVABF      ; RETURN 0 ON SUCCESS, 1 IF STACK IS FULL
* POP: REMOVES AND RETURNS TOP VALUE OF STACK, SIGN EXTNDED
POP         LDU     STKT,PCR
            CMPU    STKB,PCR    ; CHECK IF STACK EMPTY
            BNE     POP2
            LDD     #$FFFF
            BRA     POP3
POP2        PULU    B
            SEX
            STU     STKT,PCR    ; SAVE STACK TOP
POP3        JMP     GIVABF
* SIZE: RETURN CURRENT STACK SIZE
SIZE        LDD     STKB,PCR
            SUBD    STKT,PCR
            JMP     GIVABF
GIVABF      EQU     $B4F4       ; RETURN VALUE
INTCNV      EQU     $B3ED       ; GET PARAM
MAXSZE      EQU     150         ; MAXIMUM STACK SIZE
STKB        FDB     $0000       ; HOLDS STACK BASE ADDR
STKT        FDB     $0000       ; HOLDS STACK TOP ADDR
            END
