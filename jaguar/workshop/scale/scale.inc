;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; SCALE.INC - Constant file for object scaling example

PPP		.equ	4		; Pixel per phrase (16-bit CRY)
BMP_WIDTH	.equ	192		; Width in Pixels
BMP_PHRASES	.equ	(192/PPP)	; Width in Phrases
BMP_HEIGHT	.equ	67		; Height in Pixels
BMP_LINES	.equ	(BMP_HEIGHT*2)	; Height in Half Scanlines

UPDATE_FREQ	.equ	2		; Update every second
SCALE_LIMIT	.equ	$40

LISTSIZE	.equ	6
BITMAP_OFF	.equ	(8*2)		; two phrases

