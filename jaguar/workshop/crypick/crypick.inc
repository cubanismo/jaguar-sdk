;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; CRYPICK.INC - Constant file for CRY Picker

PPP		.equ	4			; Pixels per Phrase (16-bit CRY)

CRMAP_ADDR	.equ	$10000
CRMAP_WIDTH	.equ	320			; Width in Pixels
CRMAP_PHRASES	.equ	(CRMAP_WIDTH/PPP)	; Width in Phrases
CRMAP_HEIGHT	.equ	160			; Height in Pixels
CRMAP_LINES	.equ	CRMAP_HEIGHT*2		; Height in Half Scanlines

YMAP_ADDR	.equ	$30000
YMAP_WIDTH	.equ	256			; Width in Pixels
YMAP_PHRASES	.equ	(YMAP_WIDTH/PPP)	; Width in Phrases
YMAP_HEIGHT	.equ	8			; Height in Pixels
YMAP_LINES	.equ	YMAP_HEIGHT*2		; Height in Half Scanlines

PNTR_WIDTH	.equ	8			; Width in Pixels
PNTR_PHRASES	.equ	(PNTR_WIDTH/PPP)	; Width in Phrases
PNTR_HEIGHT	.equ	8			; Height in Pixels
PNTR_LINES	.equ	PNTR_HEIGHT*2	 	; Height in Half Scanlines

RBOX_WIDTH	.equ	20			; Width in Pixels
RBOX_PHRASES	.equ	(RBOX_WIDTH/PPP)	; Width in Phrases
RBOX_HEIGHT	.equ	10			; Height in Pixels
RBOX_LINES	.equ	RBOX_HEIGHT*2	 	; Height in Half Scanlines

TEXT_ADDR	.equ	$50000
TEXT_WIDTH	.equ	256			; Width in Pixels
TEXT_PHRASES	.equ	(TEXT_WIDTH/64)		; Width in Phrases
TEXT_HEIGHT	.equ	8			; Height in Pixels
TEXT_LINES	.equ	TEXT_HEIGHT*2	 	; Height in Half Scanlines

CRMAP_OFF	.equ	(2*8)			; Two Phrases
YMAP_OFF	.equ	(4*8)			; Four Phrases
PNTR_OFF	.equ	(6*8)			; Six Phrases
RBOX_OFF	.equ	(8*8)
TEXT_OFF	.equ	(10*8)

LISTSIZE	.equ	13			; List length (in phrases)

