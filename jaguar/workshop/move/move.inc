;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; MOVE.INC - Constant file for Moving bitmap object example

PPP		.equ	4		; Pixel per phrase (16-bit CRY)
BMP_WIDTH	.equ	192		; Width in Pixels
BMP_PHRASES	.equ	(192/PPP)	; Width in Phrases
BMP_HEIGHT	.equ	67		; Height in Pixels
BMP_LINES	.equ	(BMP_HEIGHT*2)	; Height in Half Scanlines

LISTSIZE	.equ	5		; List Size (in phrases)

X_MOTION	.equ	2
Y_MOTION	.equ	4		; Should be even
UPDATE_FREQ	.equ	1		; Update every frame

BITMAP_OFF	.equ	(8*2)		; two phrases

