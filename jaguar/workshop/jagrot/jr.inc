;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; JR.INC - Constant file for Blitter Bitmap Rotation

PPP		.equ	4		; Pixels per Phrase (16-bit CRY)
BMP_WIDTH	.equ	320		; Width in Pixels
BMP_PHRASES	.equ	(BMP_WIDTH/PPP)	; Width in Phrases
BMP_HEIGHT	.equ	240		; Height in Pixels
BMP_LINES	.equ	(BMP_HEIGHT*2)	; Height in Half Scanlines
BMP_ADDR	.equ	$10000

LISTSIZE	.equ	5		; List length (in phrases)
BITMAP_OFF	.equ	(2*8)		; Offset in bytes to bitmap from start
					; of object list.

G_PARM1     	.equ	(G_ENDRAM-40)
G_PARM2     	.equ	(G_ENDRAM-36)
G_PARM3     	.equ	(G_ENDRAM-32)
G_PARM4     	.equ	(G_ENDRAM-28)
G_PARM5     	.equ	(G_ENDRAM-24)
G_PARM6     	.equ	(G_ENDRAM-20)
G_PARM7     	.equ	(G_ENDRAM-16)
G_PARM8     	.equ	(G_ENDRAM-12)
G_PARM9     	.equ	(G_ENDRAM-8)
G_PARM10	.equ	(G_ENDRAM-4)

NUMPLANES	.equ	G_PARM1
ANGLEVAL	.equ	G_PARM2
SRCADDR     	.equ	G_PARM3
SRCWIDTH	.equ	G_PARM4
SRCHEIGHT	.equ	G_PARM5
SRCWIDFLD	.equ	G_PARM6
DESTADDR	.equ	G_PARM7
DESTXCNTR	.equ	G_PARM8
DESTYCNTR	.equ	G_PARM9
DESTWIDFLD	.equ	G_PARM10

GPU_PROGSTART	.equ	(G_RAM+$100)
