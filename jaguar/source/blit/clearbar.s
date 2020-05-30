	.include	'jaguar.inc'

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.globl	Clear

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Clear:

; OK lets just set up enough Blitter stuff to do a block draw
; This means set A1_FLAGS to:
;	PITCH1 --- Contiguous data
;	PIXEL16 -- 16 bit per pixel
;	WID56 ---- Width of 56 pixels
;	XADDINC -- Add increment

	move.l	#PITCH1|PIXEL16|WID56|XADDINC,d0
	move.l	d0,A1_FLAGS

; Point A1BASE to the data
	move.l	#$20000,d0
	move.l	d0,A1_BASE

; Set the pixel point to 0,0
	move.w	#0,d0			; y
	swap	d0
	move.w	#0,d0			; x
	move.l	d0,A1_PIXEL

; Set fractional pixel pointer
	move.w	#0,d0			; y
	swap	d0
	move.w	#0,d0			; x
	move.l	d0,A1_FPIXEL
	
; Set up the increment register to
; 1 in x and 0 in y
	move.w	#0,d0			; y
	swap	d0
	move.w	#1,d0			; x
	move.l	d0,A1_INC

; Set up the fractional increment register to
; 0 in x and 0 in y

	move.w	#0,d0			; y
	swap	d0
	move.w	#0,d0			; x
	move.l	d0,A1_FINC

; Set up the step size to -56 in x
; 1 in y
; The x step requires that the pixel pointer by 
	move.w	#1,d0			; y
	swap	d0
	move.w	#(-56),d0		; x
	move.l	d0,A1_STEP

; Set up the fractional step size to 0 in x
; 0 in y

	move.w	#0,d0			; y
	swap	d0
	move.w	#0,d0			; x
	move.l	d0,A1_FSTEP

; Set up Counters register to 56 in x write long to clear upper
; 201 in y, or in y as a word

	move.w	#201,d0			; y
	swap	d0
	move.w	#56,d0			; x
	move.l	d0,B_COUNT

; Put some data in the blitter for it to write
; This is a cheat I am using all f so there is 
; no need to word swap

	move.l	#$0,d0
	move.l	d0,B_PATD	
	move.l	#0,d0
	move.l	d0,B_PATD+4

; Now Turn IT ON !!!!!!!!!!!!!

; NO SOURCE DATA
; NO OUTER LOOP
; Turn on pattern data
; Allow outer loop update

	move.l	#PATDSEL|UPDA1,d0
	move.l	d0,B_CMD

	rts

	.phrase	; Force object code size alignment

