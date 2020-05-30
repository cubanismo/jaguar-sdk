; TABSIZE=8 (132 COLUMNS)
;
;		BPEG: Brainstorm's JPEG-Like Decoder
;
;			 (c)1994 Brainstorm
;
;		     Written by Raphael Lemoine
;
;       RGB/CRY Output, 2x2 Subsampling, 15/16/24 Bits/Pixel
;
;                       Version: 17-feb-1995
;
;  #[ Configuration EQUates:

		.68000
		.TEXT

TRUE		.equ	1
FALSE		.equ	0

CRY15		.equ	FALSE
CRY16		.equ	FALSE
RGB15		.equ	FALSE
RGB16		.equ	TRUE
RGB32		.equ	FALSE

 .IF !(CRY15|CRY16|RGB15|RGB16|RGB32)
  .PRINT "No Output Format Specified."
  .FAIL
 .ENDIF

 .IF (CRY15)&(CRY16|RGB15|RGB16|RGB32)
  .PRINT "Multiple Output Format Specified."
  .FAIL
 .ENDIF

 .IF (CRY16)&(CRY15|RGB15|RGB16|RGB32)
  .PRINT "Multiple Output Format Specified."
  .FAIL
 .ENDIF

 .IF (RGB15)&(CRY15|CRY16|RGB16|RGB32)
  .PRINT "Multiple Output Format Specified."
  .FAIL
 .ENDIF

 .IF (RGB16)&(CRY15|CRY16|RGB15|RGB32)
  .PRINT "Multiple Output Format Specified."
  .FAIL
 .ENDIF

 .IF (RGB32)&(CRY15|CRY16|RGB15|RGB16)
  .PRINT "Multiple Output Format Specified."
  .FAIL
 .ENDIF

 .IF CRY15
  .PRINT "BPEG Output Format: CRY15."
 .ENDIF

 .IF CRY16
  .PRINT "BPEG Output Format: CRY16."
 .ENDIF

 .IF RGB15
  .PRINT "BPEG Output Format: RGB15."
 .ENDIF

 .IF RGB16
  .PRINT "BPEG Output Format: RGB16."
 .ENDIF

 .IF RGB32
  .PRINT "BPEG Output Format: RGB32."
 .ENDIF

;  #] Configuration EQUates: 
;  #[ Global Symbols:

 .GLOBL BPEGInit,BPEGDecode,BPEGStatus

 .IF (CRY15|CRY16)
  .EXTERN CRYTable
 .ENDIF

;  #] Global Symbols: 
;  #[ EQUates:

G_FLAGS 	.equ	$f02100
G_END		.equ	$f0210c
G_PC		.equ	$f02110
G_CTRL		.equ	$f02114

BPEG_RAM	.equ	$f03000			; GPU Decoder Start Address

WORKING		.equ	-1
FINISHED	.equ	0
BADFORMAT	.equ	1
HUFFMANERROR	.equ	2

;  #] EQUates: 
;  #[ BPEG Init:

BPEGInit:
 movem.l d0/a0-a1,-(sp)
 moveq #0,d0
 move.l d0,G_FLAGS				; Set Default GPU Registers Bank
 lea GPUCode(pc),a0
 lea BPEGStartUp,a1
 move.w #((GPUEndCode-GPUCode)/4)-1,d0
.Loop:
 move.l (a0)+,(a1)+				; Copy GPU Code in GPU RAM
 dbf d0,.Loop
 movem.l (sp)+,d0/a0-a1
 rts

;  #] BPEG Init: 
;  #[ BPEG Decode:
;
; IN:
; A0 = BPEG Stream Pointer
; A1 = Output Buffer Pointer
; D0 = Output Buffer Width (Bytes)
; OUT:
; D0 = Return Code
BPEGDecode:
 movem.l d1-d2/a0-a5,-(sp)
 cmp.l #'BPEG',(a0)+
 bne .BadFormat
 lea BPEGStartUp,a5
 move.l a1,B_OUTPointer-BPEGStartUp(a5)		; Set Output Buffer Pointer in GPU
 move.l d0,B_OUTLineSize-BPEGStartUp(a5)	; Set Output Buffer Width in GPU
 move.l #WORKING,BPEGStatus			; Set Working Flag
 lsl.l #3,d0
 moveq #0,d1
 .IF (CRY15|CRY16|RGB15|RGB16)
 moveq #$10,d2
 .ENDIF
 .IF (RGB32)
 moveq #$20,d2
 .ENDIF
 move.l d1,4+LastDCY-BPEGStartUp(a5)		; Clear LastDCY in GPU
 move.l d1,4+LastDCCb-BPEGStartUp(a5)		; Clear LastDCCb in GPU
 move.l d1,4+LastDCCr-BPEGStartUp(a5)		; Clear LastDCCr in GPU
 move.l d0,CopyPointers+52-BPEGStartUp(a5)	; Set DU3 Offset in GPU
 add.l d2,d0
 move.l d0,CopyPointers+72-BPEGStartUp(a5)	; Set DU4 Offset in GPU
 move.w (a0)+,d1
 move.l d1,B_XCounter-BPEGStartUp(a5)		; Set MCUs Image Width in GPU
 move.l d1,B_SaveXCounter-BPEGStartUp(a5)
 move.w (a0)+,d1
 move.l d1,B_YCounter-BPEGStartUp(a5)		; Set MCUs Image Height in GPU
 lea $40(a0),a1
 lea ZZQTMatrix(pc),a2
 lea ZZQTLMatrix-BPEGStartUp(a5),a3
 lea ZZQTCMatrix-BPEGStartUp(a5),a4
 moveq #$3f,d2
.Loop:
 move.l (a2)+,d0				; Get ZigZag Value
 move.l d0,d1
 move.b (a0)+,d0				; Get Luminance Quantization Value
 move.b (a1)+,d1				; Get Chrominance Quantization Value
 swap d0
 swap d1
 move.l d0,(a3)+				; Copy Luminance Quantization Value in GPU
 move.l d1,(a4)+				; Copy Chrominance Quantization Value in GPU
 dbf d2,.Loop
 move.l a1,B_INPointer-BPEGStartUp(a5)		; Set Huffman Stream Address in GPU
 move.l #$00070007,G_END			; Set Big-Endian Order
 move.l a5,G_PC					; Set GPU PC
 neg.w d2
 move.l d2,G_CTRL				; Run GPU
 moveq #0,d0
.End:
 movem.l (sp)+,d1-d2/a0-a5
 rts

.BadFormat:
 moveq #BADFORMAT,d0
 bra.s .End

;  #] BPEG Decode: 
;  #[ MC68000 Tables:				; 2808 Bytes
;	 #[ DC Luma Table:			; 256 Bytes

	.LONG

DCLTable:
 .dc.b $02,$33,$13,$53,$02,$43,$23,$64,$02,$33,$13,$53,$02,$43,$23,$75
 .dc.b $02,$33,$13,$53,$02,$43,$23,$64,$02,$33,$13,$53,$02,$43,$23,$86
 .dc.b $02,$33,$13,$53,$02,$43,$23,$64,$02,$33,$13,$53,$02,$43,$23,$75
 .dc.b $02,$33,$13,$53,$02,$43,$23,$64,$02,$33,$13,$53,$02,$43,$23,$97
 .dc.b $02,$33,$13,$53,$02,$43,$23,$64,$02,$33,$13,$53,$02,$43,$23,$75
 .dc.b $02,$33,$13,$53,$02,$43,$23,$64,$02,$33,$13,$53,$02,$43,$23,$86
 .dc.b $02,$33,$13,$53,$02,$43,$23,$64,$02,$33,$13,$53,$02,$43,$23,$75
 .dc.b $02,$33,$13,$53,$02,$43,$23,$64,$02,$33,$13,$53,$02,$43,$23,$a8
 .dc.b $02,$33,$13,$53,$02,$43,$23,$64,$02,$33,$13,$53,$02,$43,$23,$75
 .dc.b $02,$33,$13,$53,$02,$43,$23,$64,$02,$33,$13,$53,$02,$43,$23,$86
 .dc.b $02,$33,$13,$53,$02,$43,$23,$64,$02,$33,$13,$53,$02,$43,$23,$75
 .dc.b $02,$33,$13,$53,$02,$43,$23,$64,$02,$33,$13,$53,$02,$43,$23,$97
 .dc.b $02,$33,$13,$53,$02,$43,$23,$64,$02,$33,$13,$53,$02,$43,$23,$75
 .dc.b $02,$33,$13,$53,$02,$43,$23,$64,$02,$33,$13,$53,$02,$43,$23,$86
 .dc.b $02,$33,$13,$53,$02,$43,$23,$64,$02,$33,$13,$53,$02,$43,$23,$75
 .dc.b $02,$33,$13,$53,$02,$43,$23,$64,$02,$33,$13,$53,$02,$43,$23,$b9

;	 #] DC Luma Table: 
;	 #[ AC Luma Tree:			; 2176 Bytes
;		#[ Level 1:

ACLTree:
 .dc.l Skip2Bits,$00000001			; xx00			2	0/1
 .dc.l Skip3Bits,$00000003			; x001			3	0/3
 .dc.l Skip2Bits,$00000002			; xx10			2	0/2
 .dc.l Skip4Bits,$00010001			; 0011			4	1/1
 .dc.l Skip2Bits,$00000001			; xx00			2	0/1
 .dc.l EndOfBlock,0				; 0101			4	0/0 (EOB)
 .dc.l Skip2Bits,$00000002			; xx10			2	0/2
 .dc.l NextLevel,Level_0111			; 0111
 .dc.l Skip2Bits,$00000001			; xx00			2	0/1
 .dc.l Skip3Bits,$00000003			; x001			3	0/3
 .dc.l Skip2Bits,$00000002			; xx10			2	0/2
 .dc.l NextLevel,Level_1011			; 1011
 .dc.l Skip2Bits,$00000001			; xx00			2	0/1
 .dc.l Skip4Bits,$00000004			; 1101			4	0/4
 .dc.l Skip2Bits,$00000002			; xx10			2	0/2
 .dc.l NextLevel,Level_1111			; 1111

;		#] Level 1: 
;		#[ Level 2:

Level_0111:
 .dc.l Skip1Bit,$00020001			; xxx0 0111		5	2/1
 .dc.l Skip2Bits,$00030001			; xx01 0111		6	3/1
 .dc.l Skip1Bit,$00020001			; xxx0 0111		5	2/1
 .dc.l Skip2Bits,$00040001			; xx11 0111		6	4/1
 .dc.l Skip1Bit,$00020001			; xxx0 0111		5	2/1
 .dc.l Skip2Bits,$00030001			; xx01 0111		6	3/1
 .dc.l Skip1Bit,$00020001			; xxx0 0111		5	2/1
 .dc.l Skip2Bits,$00040001			; xx11 0111		6	4/1
 .dc.l Skip1Bit,$00020001			; xxx0 0111		5	2/1
 .dc.l Skip2Bits,$00030001			; xx01 0111		6	3/1
 .dc.l Skip1Bit,$00020001			; xxx0 0111		5	2/1
 .dc.l Skip2Bits,$00040001			; xx11 0111		6	4/1
 .dc.l Skip1Bit,$00020001			; xxx0 0111		5	2/1
 .dc.l Skip2Bits,$00030001			; xx01 0111		6	3/1
 .dc.l Skip1Bit,$00020001			; xxx0 0111		5	2/1
 .dc.l Skip2Bits,$00040001			; xx11 0111		6	4/1

Level_1011:
 .dc.l Skip1Bit,$00000005			; xxx0 1011		5	0/5
 .dc.l Skip1Bit,$00010002			; xxx1 1011		5	1/2
 .dc.l Skip1Bit,$00000005			; xxx0 1011		5	0/5
 .dc.l Skip1Bit,$00010002			; xxx1 1011		5	1/2
 .dc.l Skip1Bit,$00000005			; xxx0 1011		5	0/5
 .dc.l Skip1Bit,$00010002			; xxx1 1011		5	1/2
 .dc.l Skip1Bit,$00000005			; xxx0 1011		5	0/5
 .dc.l Skip1Bit,$00010002			; xxx1 1011		5	1/2
 .dc.l Skip1Bit,$00000005			; xxx0 1011		5	0/5
 .dc.l Skip1Bit,$00010002			; xxx1 1011		5	1/2
 .dc.l Skip1Bit,$00000005			; xxx0 1011		5	0/5
 .dc.l Skip1Bit,$00010002			; xxx1 1011		5	1/2
 .dc.l Skip1Bit,$00000005			; xxx0 1011		5	0/5
 .dc.l Skip1Bit,$00010002			; xxx1 1011		5	1/2
 .dc.l Skip1Bit,$00000005			; xxx0 1011		5	0/5
 .dc.l Skip1Bit,$00010002			; xxx1 1011		5	1/2

Level_1111:
 .dc.l Skip3Bits,$00000006			; x000 1111		7	0/6
 .dc.l Skip4Bits,$00000007			; 0001 1111		8	0/7
 .dc.l Skip3Bits,$00050001			; x010 1111		7	5/1
 .dc.l NextLevel,Level_0011_1111 		; 0011
 .dc.l Skip3Bits,$00010003			; x100 1111		7	1/3
 .dc.l Skip4Bits,$00070001			; 0101 1111		8	7/1
 .dc.l Skip3Bits,$00060001			; x110 1111		7	6/1
 .dc.l NextLevel,Level_0111_1111 		; 0111
 .dc.l Skip3Bits,$00000006			; x000 1111		7	0/6
 .dc.l Skip4Bits,$00020002			; 1001 1111		8	2/2
 .dc.l Skip3Bits,$00050001			; x010 1111		7	5/1
 .dc.l NextLevel,Level_1011_1111 		; 1011
 .dc.l Skip3Bits,$00010003			; x100 1111		7	1/3
 .dc.l NextLevel,Level_1101_1111 		; 1101
 .dc.l Skip3Bits,$00060001			; x110 1111		7	6/1
 .dc.l NextLevel,Level_1111_1111 		; 1111

;		#] Level 2: 
;		#[ Level 3:

Level_0011_1111:
 .dc.l Skip1Bit,$00080001			; xxx0 0011 1111	9	8/1
 .dc.l Skip1Bit,$00090001			; xxx1 0011 1111	9	9/1
 .dc.l Skip1Bit,$00080001			; xxx0 0011 1111	9	8/1
 .dc.l Skip1Bit,$00090001			; xxx1 0011 1111	9	9/1
 .dc.l Skip1Bit,$00080001			; xxx0 0011 1111	9	8/1
 .dc.l Skip1Bit,$00090001			; xxx1 0011 1111	9	9/1
 .dc.l Skip1Bit,$00080001			; xxx0 0011 1111	9	8/1
 .dc.l Skip1Bit,$00090001			; xxx1 0011 1111	9	9/1
 .dc.l Skip1Bit,$00080001			; xxx0 0011 1111	9	8/1
 .dc.l Skip1Bit,$00090001			; xxx1 0011 1111	9	9/1
 .dc.l Skip1Bit,$00080001			; xxx0 0011 1111	9	8/1
 .dc.l Skip1Bit,$00090001			; xxx1 0011 1111	9	9/1
 .dc.l Skip1Bit,$00080001			; xxx0 0011 1111	9	8/1
 .dc.l Skip1Bit,$00090001			; xxx1 0011 1111	9	9/1
 .dc.l Skip1Bit,$00080001			; xxx0 0011 1111	9	8/1
 .dc.l Skip1Bit,$00090001			; xxx1 0011 1111	9	9/1

Level_0111_1111:
 .dc.l Skip2Bits,$00040002			; xx00 0111 1111	10	4/2
 .dc.l Skip2Bits,$000c0001			; xx01 0111 1111	10	c/1
 .dc.l Skip2Bits,$000b0001			; xx10 0111 1111	10	b/1
 .dc.l Skip3Bits,$00010005			; x011 0111 1111	11	1/5
 .dc.l Skip2Bits,$00040002			; xx00 0111 1111	10	4/2
 .dc.l Skip2Bits,$000c0001			; xx01 0111 1111	10	c/1
 .dc.l Skip2Bits,$000b0001			; xx10 0111 1111	10	b/1
 .dc.l Skip3Bits,$00050002			; x111 0111 1111	11	5/2
 .dc.l Skip2Bits,$00040002			; xx00 0111 1111	10	4/2
 .dc.l Skip2Bits,$000c0001			; xx01 0111 1111	10	c/1
 .dc.l Skip2Bits,$000b0001			; xx10 0111 1111	10	b/1
 .dc.l Skip3Bits,$00010005			; x011 0111 1111	11	1/5
 .dc.l Skip2Bits,$00040002			; xx00 0111 1111	10	4/2
 .dc.l Skip2Bits,$000c0001			; xx01 0111 1111	10	c/1
 .dc.l Skip2Bits,$000b0001			; xx10 0111 1111	10	b/1
 .dc.l Skip3Bits,$00050002			; x111 0111 1111	11	5/2

Level_1011_1111:
 .dc.l Skip1Bit,$000a0001			; xxx0 1011 1111	9	a/1
 .dc.l Skip2Bits,$00000008			; xx01 1011 1111	10	0/8
 .dc.l Skip1Bit,$000a0001			; xxx0 1011 1111	9	a/1
 .dc.l Skip2Bits,$00020003			; xx11 1011 1111	10	2/3
 .dc.l Skip1Bit,$000a0001			; xxx0 1011 1111	9	a/1
 .dc.l Skip2Bits,$00000008			; xx01 1011 1111	10	0/8
 .dc.l Skip1Bit,$000a0001			; xxx0 1011 1111	9	a/1
 .dc.l Skip2Bits,$00020003			; xx11 1011 1111	10	2/3
 .dc.l Skip1Bit,$000a0001			; xxx0 1011 1111	9	a/1
 .dc.l Skip2Bits,$00000008			; xx01 1011 1111	10	0/8
 .dc.l Skip1Bit,$000a0001			; xxx0 1011 1111	9	a/1
 .dc.l Skip2Bits,$00020003			; xx11 1011 1111	10	2/3
 .dc.l Skip1Bit,$000a0001			; xxx0 1011 1111	9	a/1
 .dc.l Skip2Bits,$00000008			; xx01 1011 1111	10	0/8
 .dc.l Skip1Bit,$000a0001			; xxx0 1011 1111	9	a/1
 .dc.l Skip2Bits,$00020003			; xx11 1011 1111	10	2/3

Level_1101_1111:
 .dc.l Skip1Bit,$00010004			; xxx0 1101 1111	9	1/4
 .dc.l Skip1Bit,$00030002			; xxx1 1101 1111	9	3/2
 .dc.l Skip1Bit,$00010004			; xxx0 1101 1111	9	1/4
 .dc.l Skip1Bit,$00030002			; xxx1 1101 1111	9	3/2
 .dc.l Skip1Bit,$00010004			; xxx0 1101 1111	9	1/4
 .dc.l Skip1Bit,$00030002			; xxx1 1101 1111	9	3/2
 .dc.l Skip1Bit,$00010004			; xxx0 1101 1111	9	1/4
 .dc.l Skip1Bit,$00030002			; xxx1 1101 1111	9	3/2
 .dc.l Skip1Bit,$00010004			; xxx0 1101 1111	9	1/4
 .dc.l Skip1Bit,$00030002			; xxx1 1101 1111	9	3/2
 .dc.l Skip1Bit,$00010004			; xxx0 1101 1111	9	1/4
 .dc.l Skip1Bit,$00030002			; xxx1 1101 1111	9	3/2
 .dc.l Skip1Bit,$00010004			; xxx0 1101 1111	9	1/4
 .dc.l Skip1Bit,$00030002			; xxx1 1101 1111	9	3/2
 .dc.l Skip1Bit,$00010004			; xxx0 1101 1111	9	1/4
 .dc.l Skip1Bit,$00030002			; xxx1 1101 1111	9	3/2

Level_1111_1111:
 .dc.l Skip3Bits,$000d0001			; x000 1111 1111	11	d/1
 .dc.l NextLevel,Level_0001_1111_1111		; 0001
 .dc.l Skip4Bits,$00020004			; 0010 1111 1111	12	2/4
 .dc.l NextLevel,Level_0011_1111_1111		; 0011
 .dc.l ZeroRunLength,$00000040			; x100 1111 1111	11	f/0 (ZRL)
 .dc.l NextLevel,Level_0101_1111_1111		; 0101
 .dc.l Skip4Bits,$00060002			; 0110 1111 1111	12	6/2
 .dc.l NextLevel,Level_0111_1111_1111		; 0111
 .dc.l Skip3Bits,$000d0001			; x000 1111 1111	11	d/1
 .dc.l NextLevel,Level_1001_1111_1111		; 1001
 .dc.l Skip4Bits,$00030003			; 1010 1111 1111	12	3/3
 .dc.l NextLevel,Level_1011_1111_1111		; 1011
 .dc.l ZeroRunLength,$00000040			; x100 1111 1111	11	f/0 (ZRL)
 .dc.l NextLevel,Level_1101_1111_1111		; 1101
 .dc.l Skip4Bits,$00070002			; 1110 1111 1111	12	7/2
 .dc.l NextLevel,Level_1111_1111_1111		; 1111

;		#] Level 3: 
;		#[ Level 4:

Level_0001_1111_1111:
 .dc.l Skip3Bits,$00080002			; x000 0001 1111 1111	15	8/2
 .dc.l Skip4Bits,$0001000a			; 0001 0001 1111 1111	16	1/a
 .dc.l Skip4Bits,$00010006			; 0010 0001 1111 1111	16	1/6
 .dc.l Skip4Bits,$00020008			; 0011 0001 1111 1111	16	2/8
 .dc.l Skip4Bits,$00000009			; 0100 0001 1111 1111	16	0/9
 .dc.l Skip4Bits,$00020006			; 0101 0001 1111 1111	16	2/6
 .dc.l Skip4Bits,$00010008			; 0110 0001 1111 1111	16	1/8
 .dc.l Skip4Bits,$0002000a			; 0111 0001 1111 1111	16	2/a
 .dc.l Skip3Bits,$00080002			; x000 0001 1111 1111	15	8/2
 .dc.l Skip4Bits,$00020005			; 1001 0001 1111 1111	16	2/5
 .dc.l Skip4Bits,$00010007			; 1010 0001 1111 1111	16	1/7
 .dc.l Skip4Bits,$00020009			; 1011 0001 1111 1111	16	2/9
 .dc.l Skip4Bits,$0000000a			; 1100 0001 1111 1111	16	0/a
 .dc.l Skip4Bits,$00020007			; 1101 0001 1111 1111	16	2/7
 .dc.l Skip4Bits,$00010009			; 1110 0001 1111 1111	16	1/9
 .dc.l Skip4Bits,$00030004			; 1111 0001 1111 1111	16	3/4

Level_0011_1111_1111:
 .dc.l Skip4Bits,$00090004			; 0000 0011 1111 1111	16	9/4
 .dc.l Skip4Bits,$000a0003			; 0001 0011 1111 1111	16	a/3
 .dc.l Skip4Bits,$00090008			; 0010 0011 1111 1111	16	9/8
 .dc.l Skip4Bits,$000a0007			; 0011 0011 1111 1111	16	a/7
 .dc.l Skip4Bits,$00090006			; 0100 0011 1111 1111	16	9/6
 .dc.l Skip4Bits,$000a0005			; 0101 0011 1111 1111	16	a/5
 .dc.l Skip4Bits,$0009000a			; 0110 0011 1111 1111	16	9/a
 .dc.l Skip4Bits,$000a0009			; 0111 0011 1111 1111	16	a/9
 .dc.l Skip4Bits,$00090005			; 1000 0011 1111 1111	16	9/5
 .dc.l Skip4Bits,$000a0004			; 1001 0011 1111 1111	16	a/4
 .dc.l Skip4Bits,$00090009			; 1010 0011 1111 1111	16	9/9
 .dc.l Skip4Bits,$000a0008			; 1011 0011 1111 1111	16	a/8
 .dc.l Skip4Bits,$00090007			; 1100 0011 1111 1111	16	9/7
 .dc.l Skip4Bits,$000a0006			; 1101 0011 1111 1111	16	a/6
 .dc.l Skip4Bits,$000a0002			; 1110 0011 1111 1111	16	a/2
 .dc.l Skip4Bits,$000a000a			; 1111 0011 1111 1111	16	a/a

Level_0101_1111_1111:
 .dc.l Skip4Bits,$00050005			; 0000 0101 1111 1111	16	5/5
 .dc.l Skip4Bits,$00060005			; 0001 0101 1111 1111	16	6/5
 .dc.l Skip4Bits,$00050009			; 0010 0101 1111 1111	16	5/9
 .dc.l Skip4Bits,$00060009			; 0011 0101 1111 1111	16	6/9
 .dc.l Skip4Bits,$00050007			; 0100 0101 1111 1111	16	5/7
 .dc.l Skip4Bits,$00060007			; 0101 0101 1111 1111	16	6/7
 .dc.l Skip4Bits,$00060003			; 0110 0101 1111 1111	16	6/3
 .dc.l Skip4Bits,$00070003			; 0111 0101 1111 1111	16	7/3
 .dc.l Skip4Bits,$00050006			; 1000 0101 1111 1111	16	5/6
 .dc.l Skip4Bits,$00060006			; 1001 0101 1111 1111	16	6/6
 .dc.l Skip4Bits,$0005000a			; 1010 0101 1111 1111	16	5/a
 .dc.l Skip4Bits,$0006000a			; 1011 0101 1111 1111	16	6/a
 .dc.l Skip4Bits,$00050008			; 1100 0101 1111 1111	16	5/8
 .dc.l Skip4Bits,$00060008			; 1101 0101 1111 1111	16	6/8
 .dc.l Skip4Bits,$00060004			; 1110 0101 1111 1111	16	6/4
 .dc.l Skip4Bits,$00070004			; 1111 0101 1111 1111	16	7/4

Level_0111_1111_1111:
 .dc.l Skip4Bits,$000c0009			; 0000 0111 1111 1111	16	c/9
 .dc.l Skip4Bits,$000d0008			; 0001 0111 1111 1111	16	d/8
 .dc.l Skip4Bits,$000d0004			; 0010 0111 1111 1111	16	d/4
 .dc.l Skip4Bits,$000e0002			; 0011 0111 1111 1111	16	e/2
 .dc.l Skip4Bits,$000d0002			; 0100 0111 1111 1111	16	d/2
 .dc.l Skip4Bits,$000d000a			; 0101 0111 1111 1111	16	d/a
 .dc.l Skip4Bits,$000d0006			; 0110 0111 1111 1111	16	d/6
 .dc.l Skip4Bits,$000e0004			; 0111 0111 1111 1111	16	e/4
 .dc.l Skip4Bits,$000c000a			; 1000 0111 1111 1111	16	c/a
 .dc.l Skip4Bits,$000d0009			; 1001 0111 1111 1111	16	d/9
 .dc.l Skip4Bits,$000d0005			; 1010 0111 1111 1111	16	d/5
 .dc.l Skip4Bits,$000e0003			; 1011 0111 1111 1111	16	e/3
 .dc.l Skip4Bits,$000d0003			; 1100 0111 1111 1111	16	d/3
 .dc.l Skip4Bits,$000e0001			; 1101 0111 1111 1111	16	e/1
 .dc.l Skip4Bits,$000d0007			; 1110 0111 1111 1111	16	d/7
 .dc.l Skip4Bits,$000e0005			; 1111 0111 1111 1111	16	e/5

Level_1001_1111_1111:
 .dc.l Skip4Bits,$00030005			; 0000 1001 1111 1111	16	3/5
 .dc.l Skip4Bits,$00040005			; 0001 1001 1111 1111	16	4/5
 .dc.l Skip4Bits,$00030009			; 0010 1001 1111 1111	16	3/9
 .dc.l Skip4Bits,$00040009			; 0011 1001 1111 1111	16	4/9
 .dc.l Skip4Bits,$00030007			; 0100 1001 1111 1111	16	3/7
 .dc.l Skip4Bits,$00040007			; 0101 1001 1111 1111	16	4/7
 .dc.l Skip4Bits,$00040003			; 0110 1001 1111 1111	16	4/3
 .dc.l Skip4Bits,$00050003			; 0111 1001 1111 1111	16	5/3
 .dc.l Skip4Bits,$00030006			; 1000 1001 1111 1111	16	3/6
 .dc.l Skip4Bits,$00040006			; 1001 1001 1111 1111	16	4/6
 .dc.l Skip4Bits,$0003000a			; 1010 1001 1111 1111	16	3/a
 .dc.l Skip4Bits,$0004000a			; 1011 1001 1111 1111	16	4/a
 .dc.l Skip4Bits,$00030008			; 1100 1001 1111 1111	16	3/8
 .dc.l Skip4Bits,$00040008			; 1101 1001 1111 1111	16	4/8
 .dc.l Skip4Bits,$00040004			; 1110 1001 1111 1111	16	4/4
 .dc.l Skip4Bits,$00050004			; 1111 1001 1111 1111	16	5/4

Level_1011_1111_1111:
 .dc.l Skip4Bits,$000b0002			; 0000 1011 1111 1111	16	b/2
 .dc.l Skip4Bits,$000b000a			; 0001 1011 1111 1111	16	b/a
 .dc.l Skip4Bits,$000b0006			; 0010 1011 1111 1111	16	b/6
 .dc.l Skip4Bits,$000c0005			; 0011 1011 1111 1111	16	c/5
 .dc.l Skip4Bits,$000b0004			; 0100 1011 1111 1111	16	b/4
 .dc.l Skip4Bits,$000c0003			; 0101 1011 1111 1111	16	c/3
 .dc.l Skip4Bits,$000b0008			; 0110 1011 1111 1111	16	b/8
 .dc.l Skip4Bits,$000c0007			; 0111 1011 1111 1111	16	c/7
 .dc.l Skip4Bits,$000b0003			; 1000 1011 1111 1111	16	b/3
 .dc.l Skip4Bits,$000c0002			; 1001 1011 1111 1111	16	c/2
 .dc.l Skip4Bits,$000b0007			; 1010 1011 1111 1111	16	b/7
 .dc.l Skip4Bits,$000c0006			; 1011 1011 1111 1111	16	c/6
 .dc.l Skip4Bits,$000b0005			; 1100 1011 1111 1111	16	b/5
 .dc.l Skip4Bits,$000c0004			; 1101 1011 1111 1111	16	c/4
 .dc.l Skip4Bits,$000b0009			; 1110 1011 1111 1111	16	b/9
 .dc.l Skip4Bits,$000c0008			; 1111 1011 1111 1111	16	c/8

Level_1101_1111_1111:
 .dc.l Skip4Bits,$00070005			; 0000 1101 1111 1111	16	7/5
 .dc.l Skip4Bits,$00080005			; 0001 1101 1111 1111	16	8/5
 .dc.l Skip4Bits,$00070009			; 0010 1101 1111 1111	16	7/9
 .dc.l Skip4Bits,$00080009			; 0011 1101 1111 1111	16	8/9
 .dc.l Skip4Bits,$00070007			; 0100 1101 1111 1111	16	7/7
 .dc.l Skip4Bits,$00080007			; 0101 1101 1111 1111	16	8/7
 .dc.l Skip4Bits,$00080003			; 0110 1101 1111 1111	16	8/3
 .dc.l Skip4Bits,$00090002			; 0111 1101 1111 1111	16	9/2
 .dc.l Skip4Bits,$00070006			; 1000 1101 1111 1111	16	7/6
 .dc.l Skip4Bits,$00080006			; 1001 1101 1111 1111	16	8/6
 .dc.l Skip4Bits,$0007000a			; 1010 1101 1111 1111	16	7/a
 .dc.l Skip4Bits,$0008000a			; 1011 1101 1111 1111	16	8/a
 .dc.l Skip4Bits,$00070008			; 1100 1101 1111 1111	16	7/8
 .dc.l Skip4Bits,$00080008			; 1101 1101 1111 1111	16	8/8
 .dc.l Skip4Bits,$00080004			; 1110 1101 1111 1111	16	8/4
 .dc.l Skip4Bits,$00090003			; 1111 1101 1111 1111	16	9/3

Level_1111_1111_1111:
 .dc.l Skip4Bits,$000e0006			; 0000 1111 1111 1111	16	e/6
 .dc.l Skip4Bits,$000f0004			; 0001 1111 1111 1111	16	f/4
 .dc.l Skip4Bits,$000e000a			; 0010 1111 1111 1111	16	e/a
 .dc.l Skip4Bits,$000f0008			; 0011 1111 1111 1111	16	f/8
 .dc.l Skip4Bits,$000e0008			; 0100 1111 1111 1111	16	e/8
 .dc.l Skip4Bits,$000f0006			; 0101 1111 1111 1111	16	f/6
 .dc.l Skip4Bits,$000f0002			; 0110 1111 1111 1111	16	f/2
 .dc.l Skip4Bits,$000f000a			; 0111 1111 1111 1111	16	f/a
 .dc.l Skip4Bits,$000e0007			; 1000 1111 1111 1111	16	e/7
 .dc.l Skip4Bits,$000f0005			; 1001 1111 1111 1111	16	f/5
 .dc.l Skip4Bits,$000f0001			; 1010 1111 1111 1111	16	f/1
 .dc.l Skip4Bits,$000f0009			; 1011 1111 1111 1111	16	f/9
 .dc.l Skip4Bits,$000e0009			; 1100 1111 1111 1111	16	e/9
 .dc.l Skip4Bits,$000f0007			; 1101 1111 1111 1111	16	f/7
 .dc.l Skip4Bits,$000f0003			; 1110 1111 1111 1111	16	f/3
 .dc.l HuffmanError,0				; 1111 1111 1111 1111	16	(Error)

;		#] Level 4: 
;	 #] AC Luma Tree: 
;	 #[ ZigZag & Quantization Matrix:	; 256 Bytes

ZZQTMatrix:
 .dc.l $00010000,$00030400,$00052000,$00114000
 .dc.l $00092400,$00010800,$00030c00,$00052800
 .dc.l $00214400,$00416000,$01018000,$00816400
 .dc.l $00114800,$00092c00,$00011000,$00031400
 .dc.l $00053000,$00214c00,$00416800,$02018400
 .dc.l $0401a000,$1001c000,$0801a400,$01018800
 .dc.l $00816c00,$00115000,$00093400,$00011800
 .dc.l $00031c00,$00053800,$00215400,$00417000
 .dc.l $02018c00,$0401a800,$2001c400,$4001e000
 .dc.l $8001e400,$1001c800,$0801ac00,$01019000
 .dc.l $00817400,$00115800,$00093c00,$00215c00
 .dc.l $00417800,$02019400,$0401b000,$2001cc00
 .dc.l $4001e800,$8001ec00,$1001d000,$0801b400
 .dc.l $01019800,$00817c00,$02019c00,$0401b800
 .dc.l $2001d400,$4001f000,$8001f400,$1001d800
 .dc.l $0801bc00,$2001dc00,$4001f800,$8001fc00

;	 #] ZigZag & Quantization Matrix: 
;	 #[ Bank 0 Table:			; 52 bytes

Bank0Table:
 .dc.l ACCoefLoop
 .dc.l Fetch32Bits
 .dc.l DCLTable
 .dc.l DataMaskTable-4				; First Coef. Unused
 .dc.l StoreDC
 .dc.l ACLTree
 .dc.l FastDCT
 .dc.l ConvertLoop
 .dc.l 359
 .dc.l -88
 .dc.l -183
 .dc.l 454
 .dc.l 255

;	 #] Bank 0 Table: 
;	 #[ Bank 1 Table:			; 68 Bytes

Bank1Table:
 .dc.l DCTLoop
 .dc.l MCUTmpBuffer
 .dc.l EndDCTPass
 .dc.l DUEndLoop
 .dc.l DCTPointers
 .dc.l NormTable+24
 .dc.l MCUPointers
 .dc.l 23170
 .dc.l 12540
 .dc.l 30274
 .dc.l 8035
 .dc.l 1598
 .dc.l 4551
 .dc.l 6811
 .dc.l 128
 .dc.l 4096
 .dc.l $ff7f

;	 #] Bank 1 Table: 
;  #] MC68000 Tables: 
;  #[ GPU Declarations:

		.LONG
GPUCode:
		.GPU

;
; Huffman & Color Space Conversion Stuff (Bank0)
;
;			r0: Temporary Register
_CurrentBits	.equr	r1,0
;			r2: Temporary Register
;			r3: Temporary Register
_Prefetch0	.equr	r4,0
_Prefetch1	.equr	r5,0
_BitsCounter	.equr	r6,0
_BitsMissing	.equr	r7,0
_StreamPtr	.equr	r8,0
_ZZQTMatrix	.equr	r9,0
_MCUBuffer	.equr	r10,0
_DCLTable	.equr	r11,0			; MC68000 Table Pointer (Unchanged)
_DataMaskTable	.equr	r12,0			; GPU Table pointer (Unchanged)
_StoreDC	.equr	r13,0			; Routine Pointer (Unchanged)
;			r14: Temporary Register
;			r15: Temporary Register
_Fetch32Bits	.equr	r16,0			; Routine Pointer (Unchanged)
_ACCoefLoop	.equr	r17,0			; Routine Pointer (Unchanged)
_DULoopTable	.equr	r18,0
_0xff		.equr	r19,0			; Huffman Constant (Unchanged)
_ACLTree	.equr	r20,0			; MC68000 Table Pointer (Unchanged)
_DCTMask	.equr	r21,0
_FastDCT	.equr	r22,0			; Routine Pointer (Unchanged)
_SP		.equr	r23,0
_OUTLineSize	.equr	r24,0			; Output Buffer Line Size (Unchanged)
;			r25: Temporary Register
_ConvertLoop	.equr	r26,0			; Routine Pointer (Unchanged)
_RedCoef1	.equr	r27,0			; Color Conversion Constant (Unchanged)
_GreenCoef1	.equr	r28,0			; Color Conversion Constant (Unchanged)
_GreenCoef2	.equr	r29,0			; Color Conversion Constant (Unchanged)
_BlueCoef1	.equr	r30,0			; Color Conversion Constant (Unchanged)

;
; Inverse DCT Stuff (Bank1)
;
;			r0: Temporary Register
;			r1: Temporary Register
;			r2: Temporary Register
;			r3: Temporary Register
;			r4: Temporary Register
;			r5: Temporary Register
;			r6: Temporary Register
;			r7: Temporary Register
;			r8: Temporary Register
;			r9: Temporary Register
_DCTLoopCounter .equr	r10,1			; Constant (Changed & Restored)
_NormConstant	.equr	r11,1
_MCUPointers	.equr	r12,1			; Table Pointer (Unchanged)
_cos1_4 	.equr	r13,1			; Inv. DCT Constant (Unchanged)
_SrcPointer	.equr	r14,1
_DstPointer	.equr	r15,1
_sin1_8 	.equr	r16,1			; Inv. DCT Constant (Unchanged)
_cos1_8 	.equr	r17,1			; Inv. DCT Constant (Unchanged)
_cos1_16	.equr	r18,1			; Inv. DCT Constant (Unchanged)
_sin1_16	.equr	r19,1			; Inv. DCT Constant (Unchanged)
_cos5_16	.equr	r20,1			; Inv. DCT Constant (Unchanged)
_sin5_16	.equr	r21,1			; Inv. DCT Constant (Unchanged)
_0x1000 	.equr	r22,1			; Inv. DCT Constant (Unchanged)
_DCTSwitch	.equr	r23,1
_0x80		.equr	r24,1			; Inv. DCT Constant (Unchanged)
_DCTLoop	.equr	r25,1			; Routine Pointer (Unchanged)
_DCTTmpBuffer	.equr	r26,1			; Buffer Pointer (Unchanged)
_EndDCTPass	.equr	r27,1			; Routine Pointer (Unchanged)
_DUEndLoop	.equr	r28,1			; Routine Pointer (Unchanged)
_NormTable	.equr	r29,1
_DCTPointers	.equr	r30,1			; Table Pointer (Unchanged)

;
; Common Stuff (Bank0 & Bank1)
;
_G_Flags	.equr	r31

		.ORG	BPEG_RAM		; BPEG GPU Code
		.NOJPAD 			; Real programmers don't use Padding:-)
		.REGBANK0			; Start GPU Code in Bank0

;  #] GPU Declarations: 
;  #[ GPU Start Up:

BPEGStartUp:	movei	#G_FLAGS,_G_Flags
		moveta	_G_Flags,_G_Flags
		movei	#Bank0Table,r14
		load	(r14),_ACCoefLoop
		load	(r14+1),_Fetch32Bits
		load	(r14+2),_DCLTable
		load	(r14+3),_DataMaskTable
		load	(r14+4),_StoreDC
		load	(r14+5),_ACLTree
		load	(r14+6),_FastDCT
		load	(r14+7),_ConvertLoop
		load	(r14+8),_RedCoef1
		load	(r14+9),_GreenCoef1
		load	(r14+10),_GreenCoef2
		load	(r14+11),_BlueCoef1
		load	(r14+12),_0xff
		movei	#B_OUTLineSize,r0
		moveq	#0,_BitsCounter
		load	(r0),_OUTLineSize
		movei	#B_INPointer,r0
		moveq	#0,_BitsMissing
		load	(r0),_StreamPtr
		load	(_StreamPtr),_Prefetch1
		addqt	#4,_StreamPtr
		load	(_G_Flags),r0
		bset	#$e,r0
		store	r0,(_G_Flags)
		.REGBANK1
		nop
		nop
		movei	#Bank1Table,r14
		load	(r14),_DCTLoop
		load	(r14+1),_DCTTmpBuffer
		load	(r14+2),_EndDCTPass
		load	(r14+3),_DUEndLoop
		load	(r14+4),_DCTPointers
		load	(r14+5),_NormTable
		load	(r14+6),_MCUPointers
		load	(r14+7),_cos1_4
		load	(r14+8),_sin1_8
		load	(r14+9),_cos1_8
		load	(r14+10),_cos1_16
		load	(r14+11),_sin1_16
		load	(r14+12),_cos5_16
		load	(r14+13),_sin5_16
		load	(r14+14),_0x80
		load	(r14+15),_0x1000
		load	(r14+16),_DCTLoopCounter
		load	(_G_Flags),r0
		bclr	#$e,r0
		store	r0,(_G_Flags)
		.REGBANK0
		nop
		nop

;  #] GPU Start Up: 
;  #[ Fill MCU Buffer:

FillMCUBuffer:	moveq	#0,r0
		movefa	_MCUPointers,_DULoopTable
		moveq	#$10,r3
		load	(_DULoopTable),r2
		shlq	#2,r3			; $40
		move	r2,_MCUBuffer
		movefa	_NormTable,r14
		addqt	#4,_DULoopTable
		subqt	#24,r14
.Loop:		store	r0,(r2)
		addqt	#4,r2
		store	r0,(r2)
		addqt	#4,r2
		store	r0,(r2)
		addqt	#4,r2
		store	r0,(r2)
		addqt	#4,r2
		store	r0,(r2)
		addqt	#4,r2
		subq	#1,r3
		store	r0,(r2)
		jr	NE,.Loop
		addqt	#4,r2
		moveta	r14,_NormTable

;  #] Fill MCU Buffer: 
;  #[ Decode DUs (Huffman, Inv. DCT):
;	 #[ Decode DU:

DULoop:		cmpq	#8,_BitsCounter
		move	_0xff,r14
		jr	PL,DCHeader
		moveq	#0,_DCTMask
		move	PC,_SP
		jump	(_Fetch32Bits)
		sub	_BitsCounter,_BitsMissing
DCHeader:	and	_CurrentBits,r14	; Get 8 Bits
		load	(_DULoopTable),r15	; Get Last DC Pointer
		add	_DCLTable,r14
		loadb	(r14),r3		; Get Datas Size | Header Size
		moveq	#$f,r14
		addqt	#4,_DULoopTable
		and	r3,r14			; Get Header Size
		load	(r15),_ZZQTMatrix
		sub	r14,_BitsCounter 	; Substract Header Size
		shrq	#4,r3			; Get Datas Size
		addqt	#4,r15
		jump	EQ,(_StoreDC)		; Test Datas Size (If Jump, R3 Null)
		sh	r14,_CurrentBits 	; Remove Header Bits
		cmp	r3,_BitsCounter
		move	r3,r2			; Copy Datas Size
		jr	PL,DCDatas		; Test Datas Size &
		shlq	#2,r2
		move	PC,_SP
		jump	(_Fetch32Bits)
		sub	_BitsCounter,_BitsMissing
DCDatas:	add	_DataMaskTable,r2
		sub	r3,_BitsCounter		; Substract Datas Size
		load	(r2),r14
		move	_CurrentBits,r0
		move	r14,r2
		and	r14,r0			; Mask Datas Bits
		shrq	#1,r2
		sh	r3,_CurrentBits		; Remove Datas Bits
		sub	r0,r2			; Get Datas Sign
		load	(_ZZQTMatrix),r3	; Get Quantization Value
		jr	MI,PosDC		; Test Datas Sign &
		shrq	#16,r3
		sub	r14,r0			; Convert Negative Datas
PosDC:		imult	r0,r3			; DC*QT[0]
StoreDC:	load	(r15),r2		; Get Last DC Coef.
		addqt	#4,_ZZQTMatrix		; Increment ZigZag & Quantization Table Pointer
		add	r3,r2			; Add to Last DC Coef.
		store	r2,(_MCUBuffer) 	; Store DC Coef.
		store	r2,(r15)		; And Last DC Value
ACCoefLoop:	cmpq	#4,_BitsCounter 	; Test if Enough Bits Available
		move	_ACLTree,r2		; Get Luma AC Tree Pointer
ACNibbleLoop:	jr	PL,ScanACTree
		moveq	#$f,r14
		move	PC,_SP
		jump	(_Fetch32Bits)
		sub	_BitsCounter,_BitsMissing
ScanACTree:	and	_CurrentBits,r14	; Get 4 Bits
		shlq	#3,r14			; * 8
		add	r2,r14
		load	(r14),r0		; Get AC Manager Address
		addqt	#4,r14
		jump	(r0)			; Jump to Next AC Manager &
		load	(r14),r2		; Get Run/Size Values / New Tree Address
NextLevel:	shrq	#4,_CurrentBits
		cmpq	#8,_BitsCounter
		jr	ACNibbleLoop
		subqt	#4,_BitsCounter
ZeroRunLength:	shrq	#3,_CurrentBits
		subqt	#3,_BitsCounter
		jump	(_ACCoefLoop)
		add	r2,_ZZQTMatrix
Skip4Bits:	subqt	#4,_BitsCounter
		jr	HandleACCoef
		shrq	#4,_CurrentBits
Skip3Bits:	subqt	#3,_BitsCounter
		jr	HandleACCoef
		shrq	#3,_CurrentBits
Skip2Bits:	subqt	#2,_BitsCounter
		jr	HandleACCoef
		shrq	#2,_CurrentBits
Skip1Bit:	subqt	#1,_BitsCounter
		shrq	#1,_CurrentBits
HandleACCoef:	move	_0xff,r14
		and	r2,r14
		shrq	#14,r2
		cmp	r14,_BitsCounter
		move	r14,r3
		jr	PL,ACDatas
		shlq	#2,r14
		move	PC,_SP
		jump	(_Fetch32Bits)
		sub	_BitsCounter,_BitsMissing
ACDatas:	add	_DataMaskTable,r14
		add	r2,_ZZQTMatrix
		load	(r14),r14		; Get Datas Mask
		move	_CurrentBits,r0
		move	r14,r2
		sub	r3,_BitsCounter
		shrq	#1,r2			; Get Sign Mask
		and	r14,r0
		sh	r3,_CurrentBits		; Remove Datas Bits
		sub	r0,r2			; Get Datas Sign
		load	(_ZZQTMatrix),r15	; Get Quantization Value
		jr	MI,PosAC		; Test Datas Sign &
		move	_0xff,r3
		sub	r14,r0			; Convert Negative Datas
PosAC:		or	r15,_DCTMask		; Add AC Coef. to DCT Mask
		shrq	#16,r15
		addqt	#4,_ZZQTMatrix		; Increment ZigZag & Quantization Matrix
		and	r15,r3
		shrq	#8,r15	 		; Get ZigZag position
		imult	r3,r0
		add	_MCUBuffer,r15
		jump	(_ACCoefLoop) 		; Loop &
		store	r0,(r15)		; Store AC Coef.

EndOfBlock:	load	(_G_Flags),r0
		shrq	#4,_CurrentBits		; Remove EOB Code
		bset	#$e,r0
		shlq	#16,_DCTMask
		subqt	#4,_BitsCounter		; Substract EOB Size
		jump	EQ,(_FastDCT)
		store	r0,(_G_Flags)
		.REGBANK1

;	 #] Decode DU: 
;	 #[ Inverse DCT DU:
;		#[ DCT StartUp:

InvDCTDU:	nop
		nop
		movefa	_DCTMask,_DCTSwitch
		moveq	#8,_NormConstant
		shrq	#14,_DCTSwitch
		shlq	#12,_NormConstant	; $8000 (1st Pass Rounding Constant)
		movefa	_MCUBuffer,_SrcPointer
		move	_DCTTmpBuffer,_DstPointer
DCTLoop:	moveq	#$c,r1
		load	(_SrcPointer),r0	; Preload Input[0] (FullPass, EvenPass, FastPass)
		and	_DCTSwitch,r1
		load	(_SrcPointer+2),r2	; Preload Input[2] (FullPass, EvenPass)
		add	_DCTPointers,r1
		load	(r1),r1
		jump	(r1)			; Switch To Best DCT Handler
		load	(_SrcPointer+4),r4	; Preload Input[4] (FullPass, EvenPass)

;		#] DCT StartUp: 
;		#[ Full Pass:

FullPass:	move	r0,r8
		add	r4,r0
		sub	r4,r8
		imult	_cos1_4,r0
		imult	_cos1_4,r8
		load	(_SrcPointer+6),r6
		move	r2,r9
		imult	_sin1_8,r2
		imult	_cos1_8,r9
		load	(_SrcPointer+3),r3
		move	r6,r4
		imult	_sin1_8,r6
		imult	_cos1_8,r4
		add	r6,r9
		sub	r4,r2
		load	(_SrcPointer+5),r5
		move	r8,r4
		add	r2,r8
		sub	r2,r4
		load	(_SrcPointer+1),r1
		move	r0,r6
		sub	r9,r0
		add	r9,r6
		load	(_SrcPointer+7),r7
		move	r3,r2
		add	r5,r3
		sub	r5,r2
		imult	_cos1_4,r3
		imult	_cos1_4,r2
		add	_0x1000,r3
		add	_0x1000,r2
		sharq	#$d,r3
		sharq	#$d,r2
		shlq	#2,r1
		shlq	#2,r7
		move	r1,r5
		add	r3,r1
		sub	r3,r5
		move	r7,r3
		add	r2,r7
		sub	r2,r3
		imultn	_cos1_16,r1
		imacn	_sin1_16,r7
		resmac	r9
		imultn	_cos5_16,r5
		imacn	_sin5_16,r3
		resmac	r2
		imult	_sin1_16,r1
		imult	_cos1_16,r7
		imult	_sin5_16,r5
		imult	_cos5_16,r3
		sub	r7,r1
		sub	r3,r5
		move	r6,r3
		add	r9,r6
		sub	r9,r3
		move	r8,r7
		add	r5,r8
		sub	r5,r7
		move	r4,r5
		add	r2,r4
		sub	r2,r5
		move	r0,r2
		add	r1,r0
		sub	r1,r2
		add	_NormConstant,r6
		add	_NormConstant,r8
		sharq	#$10,r6
		sharq	#$10,r8
		store	r6,(_DstPointer)
		add	_NormConstant,r4
		add	_NormConstant,r0
		store	r8,(_DstPointer+8)
		sharq	#$10,r4
		sharq	#$10,r0
		store	r4,(_DstPointer+$10)
		add	_NormConstant,r2
		add	_NormConstant,r5
		store	r0,(_DstPointer+$18)
		sharq	#$10,r2
		add	_0x80,_DstPointer
		sharq	#$10,r5
		store	r2,(_DstPointer)
		add	_NormConstant,r7
		add	_NormConstant,r3
		store	r5,(_DstPointer+8)
		sharq	#$10,r7
		sharq	#$10,r3
		store	r7,(_DstPointer+$10)
		store	r3,(_DstPointer+$18)

;		#] Full Pass: 
;		#[ End DCT Pass:

EndDCTPass:	shrq	#2,_DCTSwitch
		addqt	#$20,_SrcPointer	; Increment Source Pointer
		rorq	#1,_DCTLoopCounter	; Test X Counter
		addqt	#4,_DstPointer		; Increment Destination Pointer
		jump	CS,(_DCTLoop)
		sub	_0x80,_DstPointer
		move	_DCTTmpBuffer,_SrcPointer
		movefa	_MCUBuffer,_DstPointer
		rorq	#1,_DCTLoopCounter	; Test Y Counter
		load	(_NormTable),_NormConstant
		jump	CS,(_DCTLoop)
		subc	_DCTSwitch,_DCTSwitch	; Perform Full 2nd Pass
		load	(_G_Flags),r0
		jump	(_DUEndLoop)
		rorq	#14,_DCTLoopCounter	; Restore X/Y Counter

;		#] End DCT Pass: 
;		#[ Even Pass:

EvenPass:	move	r0,r8
		add	r4,r0
		sub	r4,r8
		imult	_cos1_4,r0
		imult	_cos1_4,r8
		load	(_SrcPointer+6),r6
		move	r2,r9
		imult	_sin1_8,r2
		imult	_cos1_8,r9
		move	r6,r4
		imult	_sin1_8,r6
		imult	_cos1_8,r4
		add	r6,r9
		sub	r4,r2
		move	r0,r6
		sub	r9,r0
		add	r9,r6
		move	r8,r4
		add	r2,r8
		sub	r2,r4
		add	_NormConstant,r6
		add	_NormConstant,r8
		sharq	#$10,r6
		sharq	#$10,r8
		store	r6,(_DstPointer)
		add	_NormConstant,r4
		store	r8,(_DstPointer+8)
		sharq	#$10,r4
		add	_NormConstant,r0
		store	r4,(_DstPointer+$10)
		sharq	#$10,r0
		store	r0,(_DstPointer+$18)
		add	_0x80,_DstPointer
		store	r0,(_DstPointer)
		store	r4,(_DstPointer+8)
		store	r8,(_DstPointer+$10)
		jump	(_EndDCTPass)
		store	r6,(_DstPointer+$18)

;		#] Even Pass: 
;		#[ Odd Pass:

OddPass:	load	(_SrcPointer+3),r3
		load	(_SrcPointer+5),r5
		move	r3,r2
		add	r5,r3
		sub	r5,r2
		load	(_SrcPointer+1),r1
		imult	_cos1_4,r3
		imult	_cos1_4,r2
		add	_0x1000,r3
		load	(_SrcPointer+7),r7
		add	_0x1000,r2
		sharq	#$d,r3
		sharq	#$d,r2
		shlq	#2,r1
		shlq	#2,r7
		move	r1,r5
		add	r3,r1
		sub	r3,r5
		move	r7,r3
		add	r2,r7
		sub	r2,r3
		imultn	_cos1_16,r1
		imacn	_sin1_16,r7
		resmac	r9
		imultn	_cos5_16,r5
		imacn	_sin5_16,r3
		resmac	r2
		imult	_sin1_16,r1
		imult	_cos1_16,r7
		imult	_sin5_16,r5
		imult	_cos5_16,r3
		sub	r7,r1
		sub	r3,r5
		add	_NormConstant,r9
		add	_NormConstant,r5
		sharq	#$10,r9
		sharq	#$10,r5
		store	r9,(_DstPointer)
		add	_NormConstant,r2
		add	_NormConstant,r1
		store	r5,(_DstPointer+8)
		sharq	#$10,r2
		sharq	#$10,r1
		store	r2,(_DstPointer+$10)
		neg	r9
		store	r1,(_DstPointer+$18)
		add	_0x80,_DstPointer
		neg	r5
		store	r9,(_DstPointer+$18)
		neg	r2
		store	r5,(_DstPointer+$10)
		neg	r1
		store	r2,(_DstPointer+8)
		jump	(_EndDCTPass)
		store	r1,(_DstPointer)

;		#] Odd Pass: 
;		#[ Fast Pass:

FastPass:	store	r0,(_DstPointer)
		store	r0,(_DstPointer+8)
		store	r0,(_DstPointer+$10)
		store	r0,(_DstPointer+$18)
		add	_0x80,_DstPointer
		store	r0,(_DstPointer)
		store	r0,(_DstPointer+8)
		store	r0,(_DstPointer+$10)
		jump	(_EndDCTPass)
		store	r0,(_DstPointer+$18)

;		#] Fast Pass: 
;		#[ Fast DCT:

FastDCT:	nop
		nop
		movefa	_MCUBuffer,r1
		load	(r1),r0
		load	(_NormTable),_NormConstant
		shlq	#13,r0
		add	_NormConstant,r0
		moveq	#$10,r5
		sharq	#16,r0
.Loop:		store	r0,(r1)
		addqt	#4,r1
		store	r0,(r1)
		addqt	#4,r1
		store	r0,(r1)
		addqt	#4,r1
		subq	#1,r5
		store	r0,(r1)
		jr	NE,.Loop
		addqt	#4,r1
		load	(_G_Flags),r0

;		#] Fast DCT: 
;	 #] Inverse DCT DU: 
;	 #[ DU End Loop:

DUEndLoop:	addqt	#4,_NormTable
		bclr	#$e,r0
		store	r0,(_G_Flags)
		.REGBANK0
		nop
		nop
		load	(_DULoopTable),r2
		addqt	#1,_MCUBuffer
		addqt	#4,_DULoopTable
		jump	(r2)
		add	_0xff,_MCUBuffer	; Next MCUBuffer 

;	 #] DU End Loop: 
;  #] Decode DUs (Huffman, Inv. DCT): 
;  #[ Convert MCU:
;	 #[ Convert CRY15/CRY16 MCU:

		.IF	(CRY15|CRY16)
ConvertMCU:	movei	#CopyPointers,r2
		moveta	r4,r4
		movei	#B_OUTPointer,r0
		moveta	r5,r5
		load	(r0),r0
		moveta	r6,r6
		moveta	r7,r7
		moveta	r8,r8
		moveta	r11,r2
		moveta	r12,r3
		moveta	r13,r9
		moveta	r2,r0
		moveta	r0,r1
		movei	#RGBToCRY,r11
		movei	#CRYTable,r12
BlockLoop:	movefa	r0,r15
		load	(r15),r14		; Y Pointer
		load	(r15+1),r9		; Cb Pointer
		load	(r15+2),r25		; Cr Pointer
		movefa	r1,r0
		load	(r15+3),r15		; Output Offset
		movei	#$3def7,r5
		add	r0,r15
ConvertLoop:	load	(r9),r2
		load	(r25),r3
		imultn	_GreenCoef1,r2
		imacn	_GreenCoef2,r3
		resmac	r0
		imult	_BlueCoef1,r2
		imult	_RedCoef1,r3
		sharq	#8,r2			; - Cb * 0.31414 - Cr * 0.71414
		sharq	#8,r3			; + Cb * 1.77200
		load	(r14),r6
		move	PC,_SP
		jump	(r11)
		sharq	#8,r0			; + Cr * 1.40200
		load	(r14+1),r6
		move	r7,r8
		move	PC,_SP
		jump	(r11)
		shlq	#16,r8
		or	r7,r8
		load	(r14+8),r6
		store	r8,(r15)		; CCCCRRRR YYYYYYY? CCCCRRRR YYYYYYY?
		move	PC,_SP
		jump	(r11)
		addq	#4,r9
		load	(r14+9),r6
		move	r7,r8
		move	PC,_SP
		jump	(r11)
		shlq	#16,r8
		addqt	#8,r14
		or	r7,r8
		shrq	#1,r5
		store	r8,(r15+_OUTLineSize)	; CCCCRRRR YYYYYYY? CCCCRRRR YYYYYYY?
		addqt	#4,r25
		jump	CS,(_ConvertLoop)
		addq	#4,r15
		add	_OUTLineSize,r15
		shrq	#1,r5
		subqt	#$10,r15
		addqt	#$20,r14
		addqt	#$10,r9
		addqt	#$10,r25
		jump	CS,(_ConvertLoop)
		add	_OUTLineSize,r15
		movefa	r0,r14
		load	(r14+4),r0
		addqt	#$14,r14
		jump	(r0)
		moveta	r14,r0
		.ENDIF

;	 #] Convert CRY15/CRY16 MCU: 
;	 #[ Convert RGB15/RGB16 MCU:

		.IF	(RGB15|RGB16)
ConvertMCU:	movei	#CopyPointers,r2
		moveta	r4,r4
		movei	#B_OUTPointer,r0
		moveta	r5,r5
		load	(r0),r0
		.IF	RGB15
		moveta	r7,r7
		.ENDIF
		moveta	r6,r6
		.IF	RGB15
		moveq	#1,r7
		.ENDIF
		moveta	r2,r0
		.IF	RGB15
		shlq	#16,r7
		.ENDIF
		moveta	r0,r1
		.IF	RGB15
		addqt	#1,r7
		.ENDIF
BlockLoop:	movefa	r0,r15
		load	(r15),r14		; Y Pointer
		load	(r15+1),r23		; Cb Pointer
		load	(r15+2),r25		; Cr Pointer
		movefa	r1,r0
		load	(r15+3),r15		; Output Offset
		movei	#$3def7,r5
		add	r0,r15
ConvertLoop:	load	(r23),r2
		load	(r25),r3
		imultn	_GreenCoef1,r2
		imacn	_GreenCoef2,r3
		resmac	r0
		imult	_BlueCoef1,r2
		imult	_RedCoef1,r3
		sharq	#8,r0			; - Cb * 0.31414 - Cr * 0.71414
		sharq	#8,r2			; + Cb * 1.77200
		sharq	#8,r3			; + Cr * 1.40200
		load	(r14),r6
		addq	#4,r23
		move	r6,r10
		move	r6,r4
		add	r3,r6			; Y + Cr * 1.40200
		add	r0,r10			; Y - Cb * 0.31414 - Cr * 0.71414
		add	r2,r4			; Y + Cb * 1.77200
		sat8	r10
		sat8	r6
		sat8	r4
		shrq	#2,r10
		shrq	#3,r6
		shrq	#3,r4
		shlq	#16,r10
		shlq	#27,r6
		shlq	#22,r4
		or	r10,r6
		load	(r14+1),r10
		or	r4,r6
		move	r10,r4
		.IF	RGB15
		or	r7,r6
		.ENDIF
		add	r0,r10			; Y - Cb * 0.31414 - Cr * 0.71414
		move	r4,r9
		add	r2,r4			; Y + Cb * 1.77200
		add	r3,r9			; Y + Cr * 1.40200
		sat8	r10
		sat8	r9
		sat8	r4
		shrq	#2,r10
		shrq	#3,r9
		shrq	#3,r4
		shlq	#11,r9
		shlq	#6,r4
		or	r10,r9
		load	(r14+8),r10
		or	r4,r9
		move	r10,r4
		or	r6,r9
		add	r0,r10			; Y - Cb * 0.31414 - Cr * 0.71414
		store	r9,(r15)		; RRRRRBBB BBGGGGG? RRRRRBBB BBGGGGG?
		move	r4,r6
		add	r2,r4			; Y + Cb * 1.77200
		add	r3,r6			; Y + Cr * 1.40200
		sat8	r10
		sat8	r6
		sat8	r4
		shrq	#2,r10
		shrq	#3,r6
		shrq	#3,r4
		shlq	#16,r10
		shlq	#27,r6
		shlq	#22,r4
		or	r10,r6
		load	(r14+9),r10
		or	r4,r6
		move	r10,r4
		.IF	RGB15
		or	r7,r6
		.ENDIF
		add	r0,r10			; Y - Cb * 0.31414 - Cr * 0.71414
		move	r4,r9
		add	r2,r4			; Y + Cb * 1.77200
		add	r3,r9			; Y + Cr * 1.40200
		sat8	r10
		sat8	r9
		sat8	r4
		shrq	#2,r10
		shrq	#3,r9
		shrq	#3,r4
		shlq	#11,r9
		shlq	#6,r4
		or	r10,r9
		or	r4,r9
		or	r6,r9
		store	r9,(r15+_OUTLineSize)	; RRRRRBBB BBGGGGG? RRRRRBBB BBGGGGG?
		shrq	#1,r5
		addqt	#4,r15
		addqt	#8,r14
		jump	CS,(_ConvertLoop)
		addq	#4,r25
		add	_OUTLineSize,r15
		shrq	#1,r5
		subqt	#$10,r15
		addqt	#$20,r14
		addqt	#$10,r23
		addqt	#$10,r25
		jump	CS,(_ConvertLoop)
		add	_OUTLineSize,r15
		movefa	r0,r14
		load	(r14+4),r0
		addqt	#$14,r14
		jump	(r0)
		moveta	r14,r0
		.ENDIF

;	 #] Convert RGB15/RGB16 MCU: 
;	 #[ Convert RGB32 MCU:

		.IF	RGB32
ConvertMCU:	movei	#CopyPointers,r2
		moveta	r4,r4
		movei	#B_OUTPointer,r0
		moveta	r5,r5
		load	(r0),r0
		moveta	r2,r0
		moveta	r0,r1
BlockLoop:	movefa	r0,r15
		load	(r15),r14		; Y Pointer
		load	(r15+1),r23		; Cb Pointer
		load	(r15+2),r25		; Cr Pointer
		movefa	r1,r0
		load	(r15+3),r15		; Output Offset
		movei	#$3def7,r5
		add	r0,r15
ConvertLoop:	load	(r23),r2
		load	(r25),r3
		imultn	_GreenCoef1,r2
		imacn	_GreenCoef2,r3
		resmac	r0
		imult	_BlueCoef1,r2
		imult	_RedCoef1,r3
		sharq	#8,r0			; - Cb * 0.31414 - Cr * 0.71414
		sharq	#8,r2			; + Cb * 1.77200
		sharq	#8,r3			; + Cr * 1.40200
		load	(r14),r9
		addq	#4,r23
		move	r9,r10
		move	r9,r4
		add	r3,r9			; Y + Cr * 1.40200
		add	r0,r10			; Y - Cb * 0.31414 - Cr * 0.71414
		add	r2,r4			; Y + Cb * 1.77200
		sat8	r9
		sat8	r10
		sat8	r4
		shlq	#16,r9
		shlq	#24,r10
		or	r10,r9
		load	(r14+8),r10
		or	r4,r9
		move	r10,r4
		add	r0,r10			; Y - Cb * 0.31414 - Cr * 0.71414
		store	r9,(r15)		; GGGGGGGG RRRRRRRR 00000000 BBBBBBBB
		move	r4,r9
		add	r2,r4			; Y + Cb * 1.77200
		add	r3,r9			; Y + Cr * 1.40200
		sat8	r10
		sat8	r9
		sat8	r4
		shlq	#16,r9
		shlq	#24,r10
		or	r10,r9
		load	(r14+1),r10
		or	r4,r9
		move	r10,r4
		add	r0,r10			; Y - Cb * 0.31414 - Cr * 0.71414
		store	r9,(r15+_OUTLineSize)	; GGGGGGGG RRRRRRRR 00000000 BBBBBBBB
		move	r4,r9
		add	r2,r4			; Y + Cb * 1.77200
		add	r3,r9			; Y + Cr * 1.40200
		sat8	r10
		sat8	r9
		sat8	r4
		addqt	#4,r15
		shlq	#16,r9
		shlq	#24,r10
		or	r10,r9
		load	(r14+9),r10
		or	r4,r9			; GGGGGGGG RRRRRRRR 00000000 BBBBBBBB
		move	r10,r4
		add	r0,r10			; Y - Cb * 0.31414 - Cr * 0.71414
		store	r9,(r15)
		move	r4,r9
		add	r2,r4			; Y + Cb * 1.77200
		add	r3,r9			; Y + Cr * 1.40200
		sat8	r10
		sat8	r9
		sat8	r4
		shlq	#16,r9
		shlq	#24,r10
		or	r10,r9
		or	r4,r9
		store	r9,(r15+_OUTLineSize)	; GGGGGGGG RRRRRRRR 00000000 BBBBBBBB
		shrq	#1,r5
		addqt	#4,r15
		addqt	#8,r14
		jump	CS,(_ConvertLoop)
		addq	#4,r25
		add	_OUTLineSize,r15
		shrq	#1,r5
		subqt	#$20,r15
		addqt	#$20,r14
		addqt	#$10,r23
		addqt	#$10,r25
		jump	CS,(_ConvertLoop)
		add	_OUTLineSize,r15
		movefa	r0,r14
		load	(r14+4),r0
		addqt	#$14,r14
		jump	(r0)
		moveta	r14,r0
		.ENDIF

;	 #] Convert RGB32 MCU: 
;  #] Convert MCU: 
;  #[ MCU Loop:

MCULoop:	movefa	r1,r0
		movei	#B_Struct,r14
		addqt	#$20,r0
		movefa	r4,r4
		.IF	RGB32
		addqt	#$20,r0
		.ENDIF
		movefa	r5,r5
		store	r0,(r14+3)
		load	(r14+1),r25		; Current XCounter
		load	(r14),r3		; Loop Pointer
		subq	#1,r25
		.IF	(CRY15|CRY16|RGB15|RGB16)
		movefa	r6,r6
		.ENDIF
		.IF	(CRY15|CRY16|RGB15)
		movefa	r7,r7
		.ENDIF
		.IF	(CRY15|CRY16)
		movefa	r8,r8
		movefa	r2,r11
		movefa	r3,r12
		movefa	r9,r13
		.ENDIF
		jump	NE,(r3)
		store	r25,(r14+1)
		load	(r14+4),r25		; XCounter Backup
		move	_OUTLineSize,r15
		load	(r14+2),r2		; Current YCounter
		or	r25,r25			; GPU Score-Board Bug...
		store	r25,(r14+1)		; Restore XCounter
		.IF	(CRY15|CRY16|RGB15|RGB16)
		shlq	#5,r25
		.ENDIF
		.IF	RGB32
		shlq	#6,r25
		.ENDIF
		shlq	#4,r15
		sub	r25,r0
		add	r15,r0
		subq	#1,r2
		store	r0,(r14+3)
		jump	NE,(r3)
		store	r2,(r14+2)
		moveq	#FINISHED,r0

;  #] MCU Loop: 
;  #[ GPU End:

BPEGEnd:	movei	#BPEGStatus,r1
		store	r0,(r1)
		moveq	#0,r0
		movei	#G_CTRL,r1
.Wait:		jr	.Wait
		store	r0,(r1)			; Stop the GPU

;  #] GPU End: 
;  #[ Huffman Error:

HuffmanError:	jr	BPEGEnd
		moveq	#HUFFMANERROR,r0

;  #] Huffman Error: 
;  #[ Fetch 32 Bits:

Fetch32Bits:	addqt	#6,_SP
		moveq	#0,_BitsCounter
		jr	MI,.SameLong
		addqt	#$20,_BitsCounter
		move	_Prefetch1,_Prefetch0
		load	(_StreamPtr),_Prefetch1
		addqt	#4,_StreamPtr
		jr	.NextLong
.SameLong:	move	_Prefetch0,_CurrentBits
		add	_BitsCounter,_BitsMissing
.NextLong:	move	_Prefetch1,r0
		sh	_BitsMissing,_CurrentBits
		sub	_BitsCounter,_BitsMissing
		sh	_BitsMissing,r0
		add	_BitsCounter,_BitsMissing
		jump	(_SP)
		or	r0,_CurrentBits

;  #] Fetch 32 Bits: 
;  #[ RGB To CRY:

		.IF (CRY15|CRY16)
RGBToCRY:	move	r6,r10
		move	r6,r4
		add	r3,r6			; Y + Cr * 1.40200
		add	r2,r4			; Y + Cb * 1.77200
		add	r0,r10			; Y - Cb * 0.31414 - Cr * 0.71414
		sat8	r6
		sat8	r10
		sat8	r4
		cmp	r10,r6
		move	r6,r7
		jr	PL,.1
		mult	_0xff,r6
		move	r10,r7
.1:		cmp	r4,r7
		addqt	#6,_SP
		jr	PL,.2
		mult	_0xff,r10
		move	r4,r7
.2:		mult	_0xff,r4
		cmpq	#0,r7
		move	_0xff,r13
		jr	NE,.3
		shlq	#8,r13
		jump	(_SP)
		nop
.3:		div	r7,r13
		mult	r13,r10
		mult	r13,r6
		mult	r13,r4
		shrq	#19,r10
		shrq	#19,r6
		shlq	#5,r10
		shlq	#10,r6
		shrq	#19,r4
		add	r10,r6
		add	r12,r4
		add	r6,r4
		.IF	CRY15
		bclr	#0,r7
		.ENDIF
		loadb	(r4),r6
		shlq	#8,r6
		jump	(_SP)
		or	r6,r7
		.ENDIF

;  #] RGB To CRY: 
;  #[ GPU Variables:				; 52 Bytes

		.LONG

B_Struct:	.dc.l	FillMCUBuffer		; MCU Loop Pointer
B_XCounter:	.dc.l	0			; Current X Counter
B_YCounter:	.dc.l	0			; Current Y Counter
B_OUTPointer:	.dc.l	0			; Current MCU Output Pointer
B_SaveXCounter:	.dc.l	0			; X Counter Backup
B_INPointer:	.dc.l	0			; BPEG Input Stream Pointer
B_OUTLineSize:	.dc.l	0			; BPEG Output Buffer Line Size (Bytes)

LastDCY:	.dc.l	ZZQTLMatrix,0		; Last Y DC Coef., Y Matrix Pointer
LastDCCb:	.dc.l	ZZQTCMatrix,0		; Last Cb DC Coef., Cb/Cr Matrix Pointer
LastDCCr:	.dc.l	ZZQTCMatrix,0		; Last Cr DC Coef., Cb/Cr Matrix Pointer

;  #] GPU Variables: 
;  #[ GPU Tables:				; 216 Bytes
;	 #[ MCU Pointers:			; 52 Bytes

MCUPointers:	.dc.l	MCUBuffer
		.dc.l	LastDCY,DULoop		; Last DC Coef. & Matrix Pointer, Loop Pointer
		.dc.l	LastDCY,DULoop
		.dc.l	LastDCY,DULoop
		.dc.l	LastDCY,DULoop
		.dc.l	LastDCCb,DULoop
		.dc.l	LastDCCr,ConvertMCU

;	 #] MCU Pointers: 
;	 #[ DCT Pointers:			; 16 Bytes

DCTPointers:	.dc.l	FastPass
		.dc.l	EvenPass
		.dc.l	OddPass
		.dc.l	FullPass

;	 #] DCT Pointers: 
;	 #[ Normalization Table:		; 24 Bytes

NormTable:	.dc.l	$808000			; Y (Output Range: $00 -> $ff)
		.dc.l	$808000			; Y (Output Range: $00 -> $ff)
		.dc.l	$808000			; Y (Output Range: $00 -> $ff)
		.dc.l	$808000			; Y (Output Range: $00 -> $ff)
		.dc.l	$008000			; Cb (Output Range: $80 -> $7f)
		.dc.l	$008000			; Cr (Output Range: $80 -> $7f)

;	 #] Normalization Table: 
;	 #[ Copy Pointers:			; 80 Bytes

		.IF	(CRY15|CRY16|RGB15|RGB16)
CopyPointers:	.dc.l	MCUBuffer,MCUBuffer+$400,MCUBuffer+$500,0,BlockLoop
		.dc.l	MCUBuffer+$100,MCUBuffer+$410,MCUBuffer+$510,$10,BlockLoop
		.dc.l	MCUBuffer+$200,MCUBuffer+$480,MCUBuffer+$580,0,BlockLoop
		.dc.l	MCUBuffer+$300,MCUBuffer+$490,MCUBuffer+$590,0,MCULoop
		.ENDIF

		.IF	RGB32
CopyPointers:	.dc.l	MCUBuffer,MCUBuffer+$400,MCUBuffer+$500,0,BlockLoop
		.dc.l	MCUBuffer+$100,MCUBuffer+$410,MCUBuffer+$510,$20,BlockLoop
		.dc.l	MCUBuffer+$200,MCUBuffer+$480,MCUBuffer+$580,0,BlockLoop
		.dc.l	MCUBuffer+$300,MCUBuffer+$490,MCUBuffer+$590,0,MCULoop
		.ENDIF

;	 #] Copy Pointers: 
;	 #[ Data Mask Table:			; 44 Bytes

DataMaskTable:	.dc.l	%00000000001,%00000000011,%00000000111,%00000001111
		.dc.l	%00000011111,%00000111111,%00001111111,%00011111111
		.dc.l	%00111111111,%01111111111,%11111111111

;	 #] Data Mask Table: 
;  #] GPU Tables: 
;  #[ MCU Buffers:				; 2304 Bytes

ZZQTLMatrix	.equ	*			; Luminance Quantization Matrix ($100 Bytes)

ZZQTCMatrix	.equ	*+$100			; Chrominance Quantization Matrix ($100 Bytes)

MCUBuffer	.equ	*+$200			; I/O MCU Buffer ($600 Bytes)

MCUTmpBuffer	.equ	*+$800			; Inv. DCT Temporary Buffer ($100 Bytes)

;  #] MCU Buffers: 
;  #[ GPU EQURs Undefinition:

		.equrundef	_CurrentBits,_Prefetch0,_Prefetch1,_BitsCounter
		.equrundef	_BitsMissing,_StreamPtr,_ZZQTMatrix,_MCUBuffer
		.equrundef	_DCLTable,_DataMaskTable,_StoreDC,_Fetch32Bits
		.equrundef	_ACCoefLoop,_DULoopTable,_0xff,_ACLTree,_DCTMask
		.equrundef	_FastDCT,_SP,_OUTLineSize,_ConvertLoop,_RedCoef1
		.equrundef	_GreenCoef1,_GreenCoef2,_BlueCoef1

		.equrundef	_DCTLoopCounter,_NormConstant,_MCUPointers,_cos1_4
		.equrundef	_SrcPointer,_DstPointer,_sin1_8,_cos1_8,_cos1_16
		.equrundef	_sin1_16,_cos5_16,_sin5_16,_0x1000,_DCTSwitch
		.equrundef	_0x80,_DCTLoop,_DCTTmpBuffer,_EndDCTPass,_DUEndLoop
		.equrundef	_NormTable,_DCTPointers

		.equrundef	_G_Flags

;  #] GPU EQURs Undefinition: 
;  #[ MC68000 Variables:

 .LONG
 .68000
GPUEndCode:

 .BSS

BPEGStatus:
 .ds.l 1

;  #] MC68000 Variables: 
;  #[ GPU RAM Check:

 .IF ((GPUEndCode-GPUCode)+2304)>4096
  .PRINT "G-RAM Overflow: ",/u/w ((GPUEndCode-GPUCode)+2304)-4096, " Bytes."
  .FAIL
 .ELSE
  .PRINT "G-RAM Used: ",/u/w (GPUEndCode-GPUCode), " Bytes (Code & Tables)."
  .PRINT "            ",/u/w 2304, " Bytes (Buffers)."
  .PRINT "            ",/u/w 4096-((GPUEndCode-GPUCode)+2304), " Bytes (Free)."
 .ENDIF
 .END

;  #] GPU RAM Check: 

