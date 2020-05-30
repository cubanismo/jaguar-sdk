	.include	'jaguar.inc'

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.globl	DoBlit
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DoBlit:
	move.w	#50,ypos
dummy:
	jsr	ShadeLine
	move.w	ypos,d0
	sub	#1,d0
	move.w	d0,ypos
	bpl	dummy
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; OK lets just set up enough Blitter stuff to do a line draw
; This means set A1_FLAGS to:
;	PITCH1 --- Contiguous data
;	PIXEL16 -- 16 bit per pixel
;	WID56 ---- Width of 56 pixels
;	XADDINC -- Add increment

ShadeLine:
	move.l	#PITCH1|PIXEL16|WID56|XADDINC,d0
	move.l	d0,A1_FLAGS

; Point A1BASE to the data
	move.l	#$20000,d0
	move.l	d0,A1_BASE

; Set the pixel point to 0,0
	move.w	ypos,d0			; y
	swap	d0
	move.w	#0,d0			; x
	move.l	d0,A1_PIXEL

; Set fractional pixel pointer
	move.w	#0,d0			; y
	swap	d0
	move.w	#0,d0			; x
	move.l	d0,A1_FPIXEL
	
; Set up the increment register to
; 1 in x and 1 in y
	move.w	#1,d0			; y
	swap	d0
	move.w	#1,d0			; x
	move.l	d0,A1_INC

; Set up the fractional increment register to
; 0 in x and 0 in y
	move.w	#0,d0			; y
	swap	d0
	move.w	#0,d0			; x
	move.l	d0,A1_FINC

	move.l	#0,A1_CLIP
; Set up Counters register to 50 in x write long to clear upper
; 20 in y, or in y as a word

	move.w	#1,d0			; y
	swap	d0
	move.w	#50,d0			; x 
	move.l	d0,B_COUNT

; Put some data in the blitter for it to write

	move.l	#$FF80FF82,d0
	move.l	d0,B_PATD	
	move.l	#$FF84FF86,d0
	move.l	d0,B_PATD+4

;Put in some Intensity Increment

	move.l	#$20000,d0
	move.l	d0,B_IINC

; Now Turn IT ON !!!!!!!!!!!!!

; NO SOURCE DATA
; NO OUTER LOOP
; Turn on pattern data

	move.l	#PATDSEL|GOURD,d0
	move.l	d0,B_CMD

	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.phrase
	.bss
ypos:
	ds.w	1
