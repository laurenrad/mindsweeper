1 REM* MINDSWEEPER 1.0 Lauren Rad 2024
2 'SEE NOTES.TXT
3 PCLEAR 2'@TARGETS=EXTBAS
4 CLEAR 700,12199'HIMEM @TARGETS=BAS
4 CLEAR 700,15270'HIMEM @TARGETS=EXTBAS
5 ?"START:";(PEEK(25)*256+PEEK(26))'@DEBUG
6 ?"END:";(PEEK(27)*256+PEEK(28))'@DEBUG
7 ?"ARRAY START: ";PEEK(29)*256+PEEK(30)'@DEBUG
8 ?"ARRAY END: ";(PEEK(31)*256+PEEK(32))+1'@DEBUG
9 ?"STRING START: ";PEEK(33)*256+PEEK(34)'@DEBUG
10 ?"HIMEM: ";(PEEK(35)*256+PEEK(36))+1:INPUT Q'@DEBUG
12 DIM OB(13,9)'ORIGINAL BOARD
13 DIM PB(13,9)'PLAYER BOARD
14 POKE 280,PEEK(275)'RANDOM SEED
15 'VAR PRIORITIES
16 CX=0:CY=0:A=0:I=0:J=0:X1=0:Y1=0:X1=0:Y2=0:X=0:Y=0:C1=0:SP=0:CD=0:TL=0:BD=0:SA=0:AA=0:TM=0
20 GOSUB 12200'SETUP MEMORY
25 MC=15'MINE COUNT
55 ?"LOADING..."
60 GOSUB 12500:GOSUB 12600'LOAD ASM AND SPRITES
70 GOSUB 5000'TITLE
75 REM* NEWGAME
77 TL=(140)-MC'TILES LEFT TO CLEAR
80 GOSUB 9200'CVRAM
85 CX=1:CY=1'CURSORPOS
90 CLS:?"GENERATING BOARD...";
100 GOSUB 1000'CREATE BOARD
110 POKE 275,51:POKE 276,160'STACK.SINIT @TARGETS=BAS
120 A=USR(12399)'SET STACK TOP @TARGETS=BAS
120 A=USR3(15470)'SET STACK TOP @TARGETS=EXTBAS
200 GOSUB 12000'ENTER GFX
205 POKE 341,255:POKE 342,255:POKE 343,255:POKE 344,255:POKE 345,255:POKE 349,255:POKE 340,255'CLR ROLLOVER
215 GOSUB 11200:GOSUB 11300
300 REM* LOOP
310 TM=TM+1
330 IF (PEEK(341)=247 OR PEEK(345)=251) AND CY>0 THEN CD=0:GOSUB 11300'UP/W
335 IF (PEEK(343)=247 OR PEEK(339)=254) AND CX>0 THEN CD=1:GOSUB 11300'LEFT/A
340 IF (PEEK(342)=247 OR PEEK(341)=251) AND CY<9 THEN CD=2:GOSUB 11300'DOWN/S
345 IF (PEEK(344)=247 OR PEEK(342)=254) AND CX<13 THEN CD=3:GOSUB 11300'RIGHT/D
350 IF PEEK(344)=254 THEN GOSUB 900'F
355 IF PEEK(345)=247 THEN GOSUB 800'SPACE
360 IF PEEK(339)=251 THEN GOTO 1300'Q @DEBUG
365 IF PEEK(340)=254 THEN SOUND 200,1:A=0:GOSUB 400'B @DEBUG
367 IF PEEK(338)=251 THEN A=1:GOSUB 400'P @DEBUG
370 POKE 341,255:POKE 342,255:POKE 343,255:POKE 344,255:POKE 345,255:POKE 339,255:POKE 340,255'CLR ROLLOVER
390 GOTO 300
395 END
400 REM*' SUB: DEBUG
410 GOSUB 12100
411 EXEC 44539'@TARGETS=BAS,EXTBAS
413 ?"CX=";CX;"CY=";CY
414 B$=""
415 FOR I=0 TO 9
420 FOR J=0 TO 13
425 IF A=0 THEN GOTO 430
427 B$=B$+STR$(PB(J,I))
428 GOTO 434
430 IF OB(J,I)=-1 THEN B$=B$+" *" ELSE B$=B$+STR$(OB(J,I))
434 NEXT J
435 ?B$:B$=""
440 NEXT I
445 PRINT "TL=";TL;"TM=";TM
450 EXEC 44539'@TARGETS=BAS,EXTBAS
455 GOSUB 12000
460 RETURN
800 REM*' SUB: REVEAL
803 GOSUB 12100'@DEBUG
805 IF PB(CX,CY)=-3 THEN SOUND 10,2:GOTO 890'FLAGGED
810 IF OB(CX,CY)=-1 THEN GOTO 1300'HIT MINE: GAME OVER
820 GOSUB 1500
840 IF TL=0 THEN 1400'WIN
860 GOSUB 12000'@DEBUG
890 RETURN
900 REM*'SUB: FLAG
910 IF PB(CX,CY)<>-3 AND PB(CX,CY)<>-4 THEN SOUND 10,2:GOTO 990'INVALID
920 IF PB(CX,CY)=-4 THEN GOTO 930 ELSE GOTO 950
925 GOTO 990
930 PB(CX,CY)=-3'FLAG
935 X1=(CX*9)+1:Y1=(CY*9)+1:SP=SA+64:SZ=8
940 GOSUB 11800
945 GOTO 990
950 PB(CX,CY)=-4'UNFLAG
955 X1=(CX*9)+1:Y1=(CY*9)+1:X2=(CX*9)+8:Y2=(CY*9)+8:C1=0:GOSUB 11500
990 RETURN
1000 REM*' SUB: CREATE BOARDS
1005 FOR X=0 TO 13:FOR Y=0 TO 9
1010 OB(X,Y)=0'DEFAULT STATE FOR OB
1013 PB(X,Y)=-4'MARK UNVISITED
1015 NEXT Y,X
1017 'GOTO 1210'@DEBUG GENERATE BLANK BOARD
1020 A=MC'NUM OF MINES LEFT TO PLACE
1025 X=RND(12)+1:Y=RND(9)
1030 IF OB(X,Y)=-1 THEN GOTO 1025
1040 OB(X,Y)=-1
1050 FOR I=-1 TO 1:FOR J=-1 TO 1
1055 IF Y+J<0 OR Y+J>9 THEN 1080
1060 IF X+I<0 OR X+I>13 THEN 1090
1070 IF OB(X+I,Y+J)<>-1 THEN OB(X+I,Y+J)=OB(X+I,Y+J)+1
1073 IF OB(X+I,Y+J)>5 THEN 1010'REROLL
1075 ?".";
1080 NEXT J
1090 NEXT I
1100 A=A-1
1110 IF A>0 THEN 1025
1210 RETURN
1300 REM* GAME OVER
1305 GOSUB 11700'DRAW MINES
1315 FOR I=1 TO 5
1316 EXEC 42961:EXEC 42963
1317 NEXT I
1320 GOSUB 12100'ENTER TEXT
1330 T$="GAME OVER "
1340 CLS:GOTO 12400
1400 REM* WIN
1410 GOSUB 12100'ENTER TEXT
1415 T$="YOU  WON! "
1420 CLS
1425 PRINT@298,"TIME:  ";TM;
1430 GOTO 12400
1500 REM' SUB: CLEAR ADJ EMPTY CNTRD ON CX,CY
1502 IF OB(CX,CY)=-5 THEN GOTO 1655'ALREADY CLEARED
1505 CA=CX:CB=CY'SAVE ORIGINAL CURSOR POS
1510 PB(CX,CY)=OB(CX,CY)'COPY AND DECREASE TILE COUNT
1520 TX=CX:TY=CY:GOSUB 11600'DRAW
1525 IF PB(CX,CY)<>0 THEN TL=TL-1:OB(CX,CY)=-5:GOTO 1650'MARK AND RETURN
1530 FOR I=-1 TO 1'CLEAR 8 ADJACENT TILES
1535 IF (CX+I)<0 OR (CX+I)>13 THEN 1575
1540 FOR J=-1 TO 1
1545 IF (CY+J)<0 OR (CY+J)>9 THEN 1570
1550 IF OB(CX+I,CY+J)=-5 THEN 1570'SKIP ALREADY VISITED
1555 TL=TL-1
1557 ?"X=";(CX+I);"Y=";(CY+J);"TL=";TL'@DEBUG
1560 PB(CX+I,CY+J)=OB(CX+I,CY+J):OB(CX+I,CY+J)=-5
1562 TX=CX+I:TY=CY+J:GOSUB 11600'DRAW
1563 POKE 275,51:POKE 276,162'STACK.PUSH @TARGETS=BAS
1565 IF PB(CX+I,CY+J)=0 THEN A=USR(CX+I):A=USR(CY+J)'PUSH ON STACK IF ZERO FOUND @TARGETS=BAS
1565 IF PB(CX+I,CY+J)=0 THEN A=USR4(CX+I):A=USR4(CY+J)'@TARGETS=EXTBAS
1570 NEXT J
1575 NEXT I
1580 POKE 275,51:POKE 276,166'STACK.SSIZE @TARGETS=BAS
1585 A=USR(0)'@TARGETS=BAS
1585 A=USR6(0)'@TARGETS=EXTBAS
1587 ?"AT END OF PASS, STACK SIZE=";A'@DEBUG
1590 IF A=0 THEN GOTO 1650'RETURN IF NOTHING ELSE TO PROCESS
1600 POKE 275,51:POKE 276,164'STACK.SPOP @TARGETS=BAS
1605 CY=USR(0):CX=USR(0)'@TARGETS=BAS
1605 CY=USR5(0):CX=USR5(0)'@TARGETS=EXTBAS
1610 GOTO 1530'PROCESS ANOTHER TILE
1650 CX=CA:CY=CB'RESTORE ORIGINAL CURSOR POS BEFORE RETURNING
1655 RETURN
5000 REM* SUB: TITLESCREEN
5010 CLS
5020 PRINT@102,"M I N D S W E E P E R":PRINT@359,"(C)2024 LAUREN RAD":PRINT@394,"PRESS ANY KEY"
5025 IF RND(100)<50 THEN A$="*" ELSE A$=" "
5030 PRINT@RND(510),A$;
5040 IF INKEY$="" THEN GOTO 5020
5080 RETURN
9200 REM* SUB: CLEAR VRAM
9210 POKE 275,50:POKE 276,192'CVRAM @TARGETS=BAS
9220 POKE BD,52:POKE BD+1,0:POKE BD+2,64:POKE BD+3,0'@TARGETS=BAS
9220 POKE BD,6:POKE BD+1,0:POKE BD+2,18:POKE BD+3,0'@TARGETS=EXTBAS
9230 A=USR(BD)'@TARGETS=BAS
9230 A=USR0(BD)'@TARGETS=EXTBAS
9240 RETURN
11200 REM* DRAW GAME GRID
11210 POKE 275,50:POKE 276,207'CPIX.RECT @TARGETS=BAS
11215 POKE BD+3,1'PARAMS
11225 FOR I=0 TO 90 STEP 9'HORIZ
11230 POKE BD+4,0:POKE BD+5,I:POKE BD+6,126:POKE BD+7,I
11235 A=USR(BD)'@TARGETS=BAS
11235 A=USR1(BD)'@TARGETS=EXTBAS
11240 NEXT I
11255 FOR I=0 TO 126 STEP 9'VERT
11260 POKE BD+4,I:POKE BD+5,0:POKE BD+6,I:POKE BD+7,90
11265 A=USR(BD)'@TARGETS=BAS
11265 A=USR1(BD)'@TARGETS=EXTBAS
11270 NEXT I
11295 RETURN
11300 REM* SUB: MOVE CURSOR
11305 C1=1
11310 X1=(CX*9):Y1=(CY*9):X2=(CX*9)+8:Y2=Y1:GOSUB 11500
11311 X1=(CX*9)+9:Y1=(CY*9):X2=X1:Y2=(CY*9)+9:GOSUB 11500
11312 X1=(CX*9):Y1=(CY*9)+9:X2=(CX*9)+9:Y2=Y1:GOSUB 11500
11313 X1=(CX*9):Y1=(CY*9)+1:X2=X1:Y2=(CY*9)+8:GOSUB 11500
11325 IF CD=0 THEN CY=CY-1 ELSE IF CD=1 THEN CX=CX-1 ELSE IF CD=2 THEN CY=CY+1 ELSE CX=CX+1
11370 X1=(CX*9):Y1=(CY*9):SP=SA+448:SZ=10:GOSUB 11800
11385 RETURN
11500 REM* SUB: DRAW RECT FROM X1,Y1 TO X2,Y2 COLOR C1
11505 POKE 275,50:POKE 276,207'CPIX.RECT @TARGETS=BAS
11510 POKE BD+3,C1:POKE BD+4,X1:POKE BD+5,Y1:POKE BD+6,X2:POKE BD+7,Y2
11525 A=USR(BD)'@TARGETS=BAS
11525 A=USR1(BD)'@TARGETS=EXTBAS
11530 RETURN
11600 REM* SUB: PUT USER BOARD TILE AT TX,TY ON SCREEN
11603 X1=(TX*9)+1:Y1=(TY*9)+1:A=PB(TX,TY)
11610 IF A=0 THEN X2=X1+7:Y2=Y1+7:C1=2:GOSUB 11500:GOTO 11695
11615 IF A>0 THEN SP=SA+64+(64*A):SZ=8:GOSUB 11800
11695 RETURN
11700 REM* SUB: DRAW MINES
11710 FOR I=0 TO 13
11720 FOR J=0 TO 9
11725 IF OB(I,J)=-1 THEN X1=(I*9)+1:Y1=(J*9)+1:SP=SA:SZ=8:GOSUB 11800
11730 NEXT J,I
11735 RETURN
11800 REM* DRAW SPRITE SP AT X1,Y1 SIZE SZ
11810 POKE 275,50:POKE 276,209'CPIX.BLIT @TARGETS=BAS
11815 POKE BD+4,X1:POKE BD+5,Y1:POKE BD+6,SZ:POKE BD+7,SZ
11820 POKE BD+8,INT(SP/256):POKE BD+9,(SP AND 255)
11825 A=USR(BD)'@TARGETS=BAS
11825 A=USR2(BD)'@TARGETS=EXTBAS
11890 RETURN
12000 REM* SUB: ENTER GRAPHICS MODE G3C
12005 POKE 65478,0:POKE 65481,0:POKE 65482,0:POKE 65485,0:POKE 65487,0:POKE 65488,0:POKE 65490,0'PAGE SEL @TARGETS=BAS
12005 POKE 65479,0:POKE 65481,0:POKE 65482,0:POKE 65484,0:POKE 65486,0:POKE 65488,0:POKE 65490,0'PAGE SEL @TARGETS=EXTBAS
12015 POKE 65472,0:POKE 65474,0:POKE 65477,0'VDG REG
12050 POKE 65314,192 OR (PEEK(65314) AND 7)'CTRL REG
12055 POKE BD+2,32:POKE BD+3,0'COMMON BLOCK PARAMS
12090 RETURN
12100 REM *SUB: ENTER TEXT MODE
12105 POKE 65478,0:POKE 65481,0:POKE 65482,0:POKE 65484,0:POKE 65486,0:POKE 65488,0:POKE 65490,0'PAGE SEL
12115 POKE 65472,0:POKE 65474,0:POKE 65476,0'VDG REG
12120 POKE 65314,0 OR (PEEK(65314) AND 7)'CTRL REG
12160 RETURN
12200 REM *SUB: SETUP MEMORY ADDRESSES
12250 BD=12976'BLOCK DATA ADDRESS @TARGETS=BAS
12250 BD=16048'@TARGETS=EXTBAS
12255 SA=12400'SPRITE ADDRESS @TARGETS=BAS
12255 SA=15472'@TARGETS=EXTBAS
12270 AA=12992'ASM ROUTINE BASE ADDR @TARGETS=BAS
12270 AA=16064'@TARGETS=EXTBAS
12275 'SET UP DEFUSR
12280 DEFUSR0=AA'CVRAM @TARGETS=EXTBAS
12285 DEFUSR1=AA+15'CPIX.RECT @TARGETS=EXTBAS
12290 DEFUSR2=AA+17'CPIX.BLIT @TARGETS=EXTBAS
12295 DEFUSR3=AA+224'STACK.SINIT @TARGETS=EXTBAS
12300 DEFUSR4=AA+226'STACK.SPUSH @TARGETS=EXTBAS
12305 DEFUSR5=AA+228'STACK.SPOP @TARGETS=EXTBAS
12310 DEFUSR6=AA+230'STACK.SSIZE @TARGETS=EXTBAS
12390 RETURN
12400 REM *'DRAW STRING WITH MARQUEE TEXT EFFECT
12410 FOR I=1 TO 22:SET(20+I,7,0):NEXT I
12420 FOR I=1 TO 22:SET(20+I,10,0):NEXT I
12430 SET(21,8,0):SET(21,9,0):SET(42,8,0):SET(42,9,0)
12440 T$=RIGHT$(T$,1)+LEFT$(T$,LEN(T$)-1)
12450 PRINT@139,T$;
12455 PRINT@391,"PLAY AGAIN?  (Y/N)";
12460 EXEC 42963'BRIEF DELAY @TARGETS=BAS,EXTBAS
12470 A$=INKEY$
12480 IF A$="Y" THEN GOTO 75
12490 IF A$="N" THEN END
12495 GOTO 12440
12500 REM* SUB: LOAD ASM ROUTINES
12510 FOR I=0 TO 13:READ A:POKE AA+I,A:NEXT I'CVRAM
12511 DATA 189,179,237,31,3,174,196,111,128,172,66,38,250,57
12520 FOR I=0 TO 198:READ A:POKE AA+15+I,A:NEXT I'CPIX
12521 DATA 32,102,32,0,189,179,237,31,3,166,68,230,69,167,141
12522 DATA 0,176,231,141,0,173,174,72,166,128,129,9,39,4,167
12523 DATA 67,141,41,108,68,230,68,224,141,0,152,225,70,38,234
12524 DATA 166,141,0,144,167,68,108,69,230,69,224,141,0,135,225
12525 DATA 71,38,216,166,140,127,230,140,125,167,68,231,69,57,52
12526 DATA 119,141,66,141,87,52,2,230,67,61,53,2,52,4,198
12527 DATA 3,61,83,228,164,234,228,231,164,53,2,53,119,57,189
12528 DATA 179,237,31,3,166,68,167,140,79,230,69,141,212,166,68
12529 DATA 230,69,76,167,68,161,70,47,243,166,140,61,92,225,71
12530 DATA 34,6,167,68,231,69,32,229,57,52,87,166,66,230,69
12531 DATA 61,31,1,230,68,84,84,58,31,16,227,196,31,2,53
12532 DATA 87,57,52,113,134,252,164,68,52,2,230,68,224,228,83
12533 DATA 196,3,48,140,10,58,53,2,166,132,53,113,57,1,1,1,4,16,64
12540 FOR I=0 TO 83:READ A:POKE AA+224+I,A:NEXT I'STACK
12541 DATA 32,6,32,14,32,42,32,63,189,179,237,237,140,68,237
12542 DATA 140,63,57,189,179,237,238,140,58,48,201,255,106,172,140
12543 DATA 51,38,5,204,255,255,32,7,54,4,79,95,239,140,37
12544 DATA 126,180,244,238,140,31,17,163,140,25,38,5,204,255,255
12545 DATA 32,6,55,4,29,239,140,14,126,180,244,236,140,6,163
12546 DATA 140,5,126,180,244,0,0,0,0
12550 RETURN
12600 REM* SUB: LOAD SPRITES
12611 FOR I=0 TO 63:READ A:POKE SA+I,A:NEXT I'MINE
12612 DATA 3,0,0,0,0,0,0,3,0,3,0,3,3,0,3,0,0,0,3,3,3,3,0,0,0,3,3,1,3,3,3,0,0,3,3,3,3,3,3,0,0,0,3,3,3,3,0,0,0,3,0,3,3,0,3,0,3,0,0,0,0,0,0,3
12621 FOR I=0 TO 63:READ A:POKE SA+64+I,A:NEXT I'FLAG
12622 DATA 9,2,9,9,9,9,9,9,9,2,3,9,9,9,9,9,9,2,3,3,9,9,9,9,9,2,3,3,3,3,9,9,9,2,3,3,3,3,3,9,9,2,9,9,9,9,9,9,9,2,9,9,9,9,9,9,9,2,9,9,9,9,9,9
12631 FOR I=0 TO 63:READ A:POKE SA+128+I,A:NEXT I'NUM1
12632 DATA 2,2,2,2,9,2,2,2,2,2,2,9,9,2,2,2,2,2,9,2,9,2,2,2,2,2,2,2,9,2,2,2,2,2,2,2,9,2,2,2,2,2,2,2,9,2,2,2,2,2,2,2,9,2,2,2,2,2,9,9,9,9,2,2
12641 FOR I=0 TO 63:READ A:POKE SA+192+I,A:NEXT I'NUM9
12642 DATA 2,2,9,9,9,9,2,2,2,9,2,2,2,2,9,2,2,2,2,2,2,2,9,2,2,2,2,2,2,2,9,2,2,2,2,2,9,9,2,2,2,2,9,9,2,2,2,2,2,9,9,2,2,2,2,2,2,9,9,9,9,9,9,2
12651 FOR I=0 TO 63:READ A:POKE SA+256+I,A:NEXT I'NUM3
12652 DATA 2,2,9,9,9,9,2,2,2,9,2,2,2,2,9,2,2,2,2,2,2,2,9,2,2,2,9,9,9,9,2,2,2,2,2,2,2,2,9,2,2,2,2,2,2,2,9,2,2,9,2,2,2,2,9,2,2,2,9,9,9,9,2,2
12661 FOR I=0 TO 63:READ A:POKE SA+320+I,A:NEXT I'NUM4
12662 DATA 2,2,2,2,2,9,2,2,2,2,2,2,9,9,2,2,2,2,2,9,2,9,2,2,2,2,9,2,2,9,2,2,2,9,9,9,9,9,2,2,2,2,2,2,2,9,2,2,2,2,2,2,2,9,2,2,2,2,2,2,2,9,2,2
12671 FOR I=0 TO 63:READ A:POKE SA+384+I,A:NEXT I'NUM5
12672 DATA 2,9,9,9,9,9,9,2,2,9,2,2,2,2,2,2,2,9,2,2,2,2,2,2,2,9,9,9,9,9,2,2,2,2,2,2,2,2,9,2,2,2,2,2,2,2,9,2,2,2,2,2,2,2,9,2,2,9,9,9,9,9,2,2
12681 FOR I=0 TO 99:READ A:POKE SA+448+I,A:NEXT I'CURSOR
12682 DATA 3,3,3,3,3,3,3,3,3,3,3,9,9,9,9,9,9,9,9,3,3,9,9,9,9,9,9,9,9,3,3,9,9,9,9,9,9,9,9,3,3,9,9,9,9,9,9,9,9,3,3,9,9,9,9,9,9,9,9,3
12683 DATA 3,9,9,9,9,9,9,9,9,3,3,9,9,9,9,9,9,9,9,3,3,9,9,9,9,9,9,9,9,3,3,3,3,3,3,3,3,3,3,3
12690 RETURN
