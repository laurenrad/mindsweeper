* Clear video memory for GXC V2
* V1.0
* Takes an argument with an address to a parameter block containing:
* +0 Start Addr
* +2 End Addr
CVRAM       JSR     INTCNV      ; get arg
            TFR     D,U
            LDX     ,U
CVR001      CLR     ,X+
            CMPX    2,U
            BNE     CVR001
            RTS
INTCNV      EQU     $B3ED
            END
