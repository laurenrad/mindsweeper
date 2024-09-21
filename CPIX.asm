* Graphics routines for GxC hi-res graphics modes.
* CPIX V4 (Relocatable)
* Standard param block:
*   + 0 VRAM START
*   + 2 MODE WIDTH
*   + 3 COLOR
*   + 4 X1
*   + 5 Y1
*   + 6 X2
*   + 7 Y2
* Entry points
RECT    BRA     RECT0   ; DRAW RECTANGLE
BLIT    BRA     SBLIT   ; SPRITE BLIT
* BLIT: Render a sprite to the screen.
* This isn't a proper masking blit, because of memory limitations.
* Instead, a pixel color value of 9 is transparency.
*       +0 VRAM START
*       +2 MODE WIDTH
*       +3 (NOT USED)
*       +4 X
*       +5 Y
*       +6 WIDTH
*       +7 HEIGHT
*       +8 SPRITE DATA
SBLIT   JSR     INTCNV          ; GET PARAMS
        TFR     D,U
SBLT00  LDA     +4,U
        LDB     +5,U
        STA     TMPX,PCR        ; SAVE ORIGINAL X AND Y
        STB     TMPY,PCR
        LDX     +8,U            ; SPRITE DATA ADDR IN X
SBLT01  LDA     ,X+             ; NEXT COLOR VALUE
        CMPA    #9
        BEQ     SBLT02          ; NO OVERWRITE ON 9 (ALPHA)
        STA     +3,U            ; STORE COLOR VALUE FOR PSET
        BSR     PSET
SBLT02  INC     +4,U            ; INCREMENT X VALUE
        LDB     +4,U
        SUBB    TMPX,PCR
        CMPB    +6,U            ; IF W > (X2-X1) THEN LOOP
        BNE     SBLT01          ; LOOP IF NOT FINISHED WITH ROW
        LDA     TMPX,PCR
        STA     +4,U            ; RESET WORKING X VALUE
        INC     +5,U            ; INCREMENT Y VALUE
        LDB     +5,U
        SUBB    TMPY,PCR
        CMPB    +7,U            ; IF W > (Y2-Y1) THEN LOOP
        BNE     SBLT01          ; LOOP IF NOT FINISHED
        LDA     TMPX,PCR
        LDB     TMPY,PCR
        STA     +4,U            ; RESTORE ORIGINAL X AND Y
        STB     +5,U
        RTS
* PSET: Set a pixel at X,Y with color C.
* ENTRY: U contains param block address.
* EXIT: Registers preserved.
* PARAM BLOCK:
*       +0 VRAM START
*       +2 MODE WIDTH
*       +3 COLOR
*       +4 X
*       +5 Y
PSET    PSHS    CC,A,B,X,Y,U    ; PRESERVE REGS
        BSR     PIXADR  	; CALCULATE PIXEL ADDR
        BSR     PIXELM  	; CALCULATE PIXEL INDEX
        PSHS    A       	; SAVE BIT EXPONENT
        LDB     +3,U    	; COLOR
        MUL             	; PIXEL=POW*COLOR
        PULS    A       	; RESTORE BIT EXPONENT
        PSHS    B       	; SAVE PIXEL BYTE
        LDB     #3
        MUL             	; MASK=POW*3
        COMB
        ANDB    ,Y      	; OLD AND NOT MASK
        ORB     ,S      	; OR WITH PIXEL BYTE
        STB     ,Y      	; STORE NEW VAL IN VRAM
        PULS    A       	; REMOVE PIXEL BYTE FROM STACK
        PULS    U,Y,X,B,A,CC    ; RESTORE REST OF STACK
        RTS
* RECT: Draw a filled rectangle.
* Entry: Param points to a param block address.
* Exit: In param block X1=X2 and Y1=Y2.
RECT0   JSR     INTCNV   	; GET PARAMS
        TFR     D,U
        LDA     +4,U
        STA     TMPX,PCR	; SAVE ORIGINAL X1
        LDB     +5,U
RECT01  BSR     PSET
        LDA     +4,U
        LDB     +5,U
        INCA
        STA     +4,U    	; UPDATE X1
        CMPA    +6,U
        BLE     RECT01  	; X < X2?
        LDA     TMPX,PCR    	; RESET TO ORIG X1
        INCB            	; INCREMENT Y
        CMPB    +7,U
        BHI     RECT02  	; DONE IF Y1>Y2 AND X1>X2
        STA     +4,U    	; STORE VALUES FOR PSET
        STB     +5,U
        BRA     RECT01
RECT02  RTS
* PIXADDR: Calculate the address of the byte containing a given pixel.
* On entry: Param block addr in U
* On exit: Address of pixel in Y; other regs preserved.
PIXADR  PSHS    CC,A,B,X,U
        LDA     +2,U    	; WIDTH
        LDB     +5,U    	; Y
        MUL
        TFR     D,X
        LDB     +4,U    	; X
        LSRB
        LSRB            	; X/4
        ABX             	; OFFSET=(X/4)+(Y*W)
        TFR     X,D
        ADDD    ,U      	; BYTE=VRAM+OFFSET
        TFR     D,Y
        PULS    U,X,B,A,CC
        RTS
* PIXELM: Calculate the element number (0-3) of the pixel within its byte.
* This only works for some video modes (GxC, etc)
* Entry: Param block address in U
* Exit: Bit exponent in A, Element number in B; other regs preserved.
PIXELM  PSHS    CC,X,Y,U
        LDA     #$FC
        ANDA    +4,U    	; MASK OFF LOWER 2 BITS OF X
        PSHS    A
        LDB     +4,U
        SUBB    ,S      	; RESULT IS X%4
        COMB
        ANDB    #3      	; REVERSE ELEMENT INDEX
        LEAX    POW,PCR
        ABX
        PULS    A       	; RESTORE STACK
        LDA     ,X
        PULS    U,Y,X,CC
        RTS
TMPX    FCB     1       	; WORKING X VALUE
TMPY    FCB     1       	; WORKING Y VALUE
POW     FCB     1      		;EXPONENT TABLE
        FCB     4
        FCB     16
        FCB     64
INTCNV  EQU     $B3ED
        END
