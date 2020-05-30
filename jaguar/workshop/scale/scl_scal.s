;
; Jaguar Example Source Code
; Jaguar Workshop Series #4
; Copyright (c)1994 Atari Corp.
; ALL RIGHTS RESERVED
;
; Program: scale.cof    - Object Scaling Example
;  Module: scl_scal.s   - Routine and variables to scale bitmap
;
; Revision History:
; 6/16/94   - SDS: Created
; 8/03/94   - SDS: Removed dynamic updating of object list. Moved it to UpdateList

		.include "scale.inc"
; Globals
		.globl  ScaleBitmap
		.globl  InitScaleVars
		.globl	h_scale
		.globl	v_scale
		.globl	x_pos
		.globl	y_pos
; Externals
		.extern height
		.extern width
		.extern a_vdb
		.extern a_vde
		.extern a_hdb
		.extern a_hde

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: InitScaleVars
;            Initialize variables for our bitmap to be scaled
;
; Registers: None
;

InitScaleVars:
		clr.w	frame_count		; 0 frames so far

		move.w	#$20,h_scale		; %001 00000 = 1.0
		move.w	#$20,v_scale
		move.w	#1,h_off
		move.w	#1,v_off

		rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: ScaleBitmap
;            Updating scaling variables
;

ScaleBitmap:
		movem.l	d0-d2,-(sp)

		move.w	frame_count,d0
		add.w	#1,d0
		cmp.w	#UPDATE_FREQ,d0		; Enough frames?
		beq	do_scale		; Do scale update

		move.w	d0,frame_count		; Update counter
		bra	scale_done		; outta here

do_scale:
		move.w	v_scale,d0		; Old scaling value
		add.w	v_off,d0		; Add offset
		move.w	d0,v_scale		; Re-store

		bne	.test_high		; >0

		move.w	#1,v_off		; Else reverse scaling
		bra	do_vscale
.test_high:
		cmp.w	#SCALE_LIMIT,d0		; Too high
		blt	do_vscale

		move.w	#-1,v_off		; ...then reverse
do_vscale:

; Now we have to determine the adjusted height of the bitmap so we
; can adjust YPOS to center the bitmap.

		move.l	#BMP_HEIGHT,d1		; Original height
		mulu.w	d0,d1			; Multiply
		lsr.l	#5,d1			; Normalize d1

		move.w	height,d2		; YPOS = (height -
		sub.w	d1,d2			;         bmp_height +
		add.w	a_vdb,d2		;         a_vde)
		andi.w	#$7FE,d2		; Range check.

		move.w	d2,y_pos

; Now do H_SCALE and WIDTH
		move.w	h_scale,d0		; Current scale factor
		add.w	h_off,d0		; Add offset
		move.w	d0,h_scale		; Re-store
		bne	.test_high

		move.w	#1,h_off		; Reverse increment
		bra	do_hscale
.test_high:
		cmp.w	#SCALE_LIMIT,d0
		blt	do_hscale

		move.w	#-1,h_off		; Now downward
do_hscale:

; Now adjust the bitmap XPOS for its new width

		move.l	#BMP_WIDTH,d1		; Fixed width
		mulu.w	d0,d1			; Multiply to scale
		lsr.l	#5,d1			; Normalize d1

		clr.l	d2			; Calculate screen width
		move.w	width,d2
		lsr.w	#2,d2			; /4 Pixel Divisor
  		sub.w	d1,d2
		lsr.w	#1,d2
		andi.w	#$0FFF,d2		; Range check

		move.w	d2,x_pos

		clr.w	frame_count		; Wait til next frame interval
scale_done:
		movem.l	(sp)+,d0-d2
		rts

		.bss

frame_count:	.ds.w	1
h_scale:	.ds.w	1
v_scale:	.ds.w	1
x_pos:		.ds.w	1
y_pos:		.ds.w	1
h_off:		.ds.w	1
v_off:		.ds.w	1

		.end
