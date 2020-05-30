	.include	'jaguar.inc'

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.globl	DoBlit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; OK lets just set up enough Blitter stuff to do a line draw
; This means set A1_FLAGS to:
;	PITCH1 --- Contiguous data
;	PIXEL16 -- 16 bit per pixel
;	WID56 ---- Width of 56 pixels
;	XADDPIX -- Add pixel size

DoBlit:
	move.l	#PITCH1|PIXEL16|WID56|XADDPIX,d0
	move.l	d0,A1_FLAGS

; Point A1BASE to the data
	move.l	#$20000,d0
	move.l	d0,A1_BASE

; Set the pixel point to 0,0
	move.w	#0,d0			; move y
	swap	d0
	move.w	#0,d0			; move x
	move.l	d0,A1_PIXEL

; Clear fractional pixel pointer
	move.w	#0,d0			; move y
	swap	d0
	move.w	#0,d0			; move x
	move.l	d0,A1_FPIXEL
	
	move.l	#0,A1_CLIP
; Set up Counters register to 20 in x write long to clear upper
; 1 in y, or in y as a word

	move.w	#20,d0			; y
	swap	d0
	move.w	#1,d0			; x
	move.l	d0,B_COUNT

; Put some data in the blitter for it to write
; This is a cheat I am using all f so there is 
; no need to word swap

	move.l	#$FFFFFFFF,d0
	move.l	d0,B_PATD	
	move.l	d0,B_PATD+4

; Now Turn IT ON !!!!!!!!!!!!!

; NO SOURCE DATA
; NO OUTER LOOP
; Turn on pattern data

	move.l	#PATDSEL,d0
	move.l	d0,B_CMD

	rts

	.phrase	; Force object code size alignment

