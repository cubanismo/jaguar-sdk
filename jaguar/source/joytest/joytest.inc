;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; JOYTEST.INC - Constant file for Joystick Reading Example

PPP8		.equ	8		; Pixels per Phrase (8-bit palette)

CURS_X		.equ	40
CURS_Y		.equ	130

FIRE_X		.equ	40
FIRE_Y		.equ	90

KEY_X		.equ	56
KEY_Y		.equ	90

CURS_WIDTH	.equ	16
CURS_PHRASES	.equ	(CURS_WIDTH/PPP8)
CURS_HEIGHT	.equ	10
CURS_LINES	.equ	(CURS_HEIGHT*2)

CHAR_WIDTH	.equ	8
CHAR_PHRASES	.equ	(CHAR_WIDTH/PPP8)
CHAR_HEIGHT	.equ	7
CHAR_LINES	.equ	(CHAR_HEIGHT*2)

BITMAP_OFF	.equ	8*2		; Offset to first bitmap
LISTSIZE	.equ	15		; List length (in phrases)

