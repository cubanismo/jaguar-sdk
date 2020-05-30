
;******************************************************************************
; (C) Copyright 1995 Atari Corporation.
; All rights reserved.
;
; Revision 1.01 6/1/95 mf
; Removed include of 'blit.inc' (everything now in JAGUAR.INC)
;
; Revision 1.0	(unknown)
; Initial revision.
;******************************************************************************

	.include	'memory.inc'
	.include	'jaguar.inc'
	.include	'cinepak.inc'

	.globl		Clear

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; OK lets just set up enough Blitter stuff to do a block draw.
; This means set A1_FLAGS to:
; Contiguous data, 16 bit per pixel, width of 256 pixels, add increment
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Clear::
	move.l	#PITCH1|PIXEL16|WID256|XADDINC,d0
	move.l	d0,A1_FLAGS
; Point A1BASE to the data
	move.l	#$10000,d0
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
; Set up the step size to -256 in x
; 1 in y
; The x step requires that the pixel pointer by 
	move.w	#1,d0			; y
	swap	d0
	move.w	#(-256),d0		; x
	move.l	d0,A1_STEP
; Set up the fractional step size to 0 in x
; 0 in y
	move.w	#0,d0			; y
	swap	d0
	move.w	#0,d0			; x
	move.l	d0,A1_FSTEP
; Set up Counters register to 256 in x write long to clear upper
; 256 in y, or in y as a word
	move.w	#ROWBYTES*NLINES/512,d0	; y
	swap	d0
	move.w	#256,d0			; x
	move.l	d0,B_COUNT
; Put some data in the blitter for it to write
; This is a cheat I am using all f so there is 
; no need to word swap
	move.l	#0,d0
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
