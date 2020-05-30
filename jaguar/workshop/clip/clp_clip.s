;
; Jaguar Example Source Code
; Jaguar Workshop Series #3
; Copyright (c)1994 Atari Corp.
; ALL RIGHTS RESERVED
;
; Program: clip.cof     - Clipped object example
;  Module: clp_clip.s   - Routine and variables to clip bitmap
;
; Revision History:
; 6/16/94   - SDS: Created

		.include "clip.inc"
; Globals
		.globl  ClipBitmap
		.globl  InitClipVars

		.globl	x_pos
		.globl	i_width
		.globl	data_ptr
; Externals
		.extern main_obj_list

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: InitClipVars
;            Initialize variables for our bitmap to be clipped
;
; Registers: None
;

InitClipVars:
		clr.w	frame_count		; 0 frames so far
		clr.w	cycle_count		; Out of data
		move.l	#clip_cycle,rov_arr_ptr	; Point to start

		rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: ClipBitmap
;            Cycle through our clip state array and update bitmap
;
; Registers: d0.w - Cycle/Frame counter registers
;            d1.l - DATA ptr offset per cycle
;            d2.w - IWIDTH offset per cycle
;            d3.w - XPOS offset per cycle
;            d4.w - Temporary register
;            a0.l - Pointer into clip effects list
;

ClipBitmap:
		movem.l	d0-d4/a0,-(sp)

		move.w	frame_count,d0
		add.w	#1,d0
		cmp.w	#UPDATE_FREQ,d0		; Enough frames?
		beq	cycle			; Do a new cycle

		move.w	d0,frame_count		; Update counter
		bra	clip_done		; outta here
cycle:
		move.w	cycle_count,d0		; Are we in the middle of an effect?
		beq	start_new		; No
	
		move.l	cur_data_off,d1		; Get pre-stored values
		move.w	cur_iwidth_off,d2
		move.w	cur_xpos_off,d3  
		bra	format_update
start_new:
		move.l	rov_arr_ptr,a0
get_effect:
		move.w	(a0)+,d0		; Cycle count
		bpl	do_effect		; Not < 0

		lea	clip_cycle,a0		; Go back to start of array
		bra	get_effect
do_effect:
		move.l	(a0)+,d1		; DATA offset
		move.l	d1,cur_data_off		; Store for later use
		move.w	(a0)+,d2		; IWIDTH offset
		move.w	d2,cur_iwidth_off
		move.w	(a0)+,d3		; XPOS offset
		move.w	d3,cur_xpos_off

		move.l	a0,rov_arr_ptr		; Store updated ptr
format_update:
		move.l	data_ptr,d4		; Get old DATA field.
		add.l	d1,d4			; Now add our offset
		move.l	d4,data_ptr

		move.w	i_width,d4
		add.w	d2,d4			; Add IWIDTH offset
		move.w	d4,i_width

		move.w	x_pos,d4
		add.w	d3,d4			; Add XPOS offset
		move.w	d4,x_pos

		sub.w	#1,d0			; Subtract from effect counter
		move.w	d0,cycle_count
		clr.w	frame_count		; Wait til next frame interval
clip_done:
		movem.l	(sp)+,d0-d4/a0
		rts

		.data

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Clip-cycle Array  in 'C':
;
; typedef struct
; {
;     short num_reps;		// Value of -1 here starts over
;     long data_offset;	// Value to add (or subtract) to DATA
;     short iwidth_offset;	// ""           ""            to IWIDTH
;     short xpos_offset;	// ""           ""            to XPOS
; } CLIP_EFFECTS[]
;

clip_cycle:
		dc.w	BMP_PHRASES-1		; Wipe out from left
		dc.l	0
		dc.w	-1
		dc.w	0

		dc.w	BMP_PHRASES-1		; Wipe in from left
		dc.l	0
		dc.w	1
		dc.w	0

		dc.w	BMP_PHRASES-1		; Wipe out to right
		dc.l	$8
		dc.w	-1
		dc.w	PPP

		dc.w	BMP_PHRASES-1		; Wipe in from right
		dc.l	-$8
		dc.w	1
		dc.w	-(PPP)

		dc.w	(BMP_PHRASES-1)/2	; Close from center
		dc.l	$8
		dc.w	-2
		dc.w	PPP

		dc.w	(BMP_PHRASES-1)/2	; Open from center
		dc.l	-$8
		dc.w	2
		dc.w	-(PPP)

		dc.w	-1
		dc.l	0
		dc.w	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;; UNINITIALIZED DATA!!!
	
		.bss

frame_count:   	.ds.w    1
rov_arr_ptr:	.ds.l	1
cycle_count:	.ds.w	1
cur_data_off:	.ds.l	1
cur_iwidth_off:	.ds.w	1
cur_xpos_off:	.ds.w	1
x_pos:		.ds.w	1
i_width:	.ds.w	1
data_ptr:	.ds.l	1

		.end
