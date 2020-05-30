;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; MOU.INC - Constant file for Minimum Object List Update Examples

PPP		.equ	4		; Pixels per Phrase (16-bit CRY)
BMP_WIDTH	.equ	192		; Width in Pixels
BMP_PHRASES	.equ	(192/PPP)	; Width in Phrases
BMP_HEIGHT	.equ	67		; Height in Pixels
BMP_LINES	.equ	(BMP_HEIGHT*2)	; Height in Half Scanlines

BITMAP_OFF	.equ	(2*8)		; Two Phrases
LISTSIZE	.equ	5		; List length (in phrases)

