	.include	'jaguar.inc'

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.extern VideoIni
	.extern	IntInit
	.extern Lister
	.extern DoBlit
	.extern	Clear
	.extern	VDB

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PATTERN		equ	$20000

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.text

; Run the GPU/BLIT interface in CORRECT mode ALWAYS

	move.l	#$00070007,G_END

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; At this point we don't know what state the video is in.
; It may be active or not and may be using an interrupt or not.
;
; Since we may not turn video off we use the following procedure:
;
; 1) Disable VI by setting to a VERY large number.  The existing
;    screen will fail to be refreshed so all bit maps vanish.
; 2) Clear the bitmap object's memory
; 3) Set up the desired object list
; 4) Set up an interrupt and start
; 5) Set up the size of borders
; 6) Point the Object Processor at the real object list
; 7) Set VMODE to the desired resolution and color model
;
; NOTE: To blank the screen point the object processor at a stop object
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	move.w	#$FFFF,VI

	move.l	#INITSTACK,a7		; Put the stack at the top of DRAM

	jsr	Clear
	jsr	Lister
	jsr	IntInit
	jsr	VideoIni

	move.l	d5,OLP			; Object List pointer.  Setup by Lister

	move.w	#$6C1,VMODE		; Set 16 bit CRY; 320 pixel-wide overscanned

; Now a cleared bar is being displayed

	jsr	DoBlit

	illegal

	.phrase	; Force object code size alignment

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.bss
	.dphrase

listbuf::
	ds.l	16

	.phrase
stopobj:
	ds.l	2


		
