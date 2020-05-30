;
; Jaguar Example Source Code
; Jaguar Workshop Series #2
; Copyright (c)1994 Atari Corp.
; ALL RIGHTS RESERVED
;
; Program: move.cof     - Moving bitmap object example
;  Module: mov_move.s   - Routine and variables to move bitmap
;
; Revision History:
; 6/15/94   - SDS: Created
;
; 7/26/94   - SDS: Removed update of double-buffered list.
;                  Update is now done at VBLANK time.
;
		.include "move.inc"

; Globals
		.globl  MoveBitmap
		.globl  InitMoveVars
		.globl  x_pos
		.globl  y_pos
; Externals
		.extern main_obj_list
		.extern a_vdb
		.extern a_vde
		.extern a_hde
		.extern a_hdb
		.extern width
		.extern height

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: InitMoveVars
;            Initialize variables for our moving bitmap
;            Note: x_pos and y_pos are initialized in mov_list.s
;
; Registers: None
;

InitMoveVars:
		move.l  d0,-(sp)

		move.w  #X_MOTION,x_motion	; Motion for each iteration
		move.w  #Y_MOTION,y_motion
		clr.w   frame_count		; Current elapsed frames
	
		clr.w   x_min			; Min X = 0		
		clr.l	d0
		move.w  width,d0		; Max X = Scr Width - Bmap Width
		lsr.w	#2,d0
		sub.w	#BMP_WIDTH,d0
		sub.w   #1,d0
		move.w  d0,x_max

		move.w  a_vdb,d0		; Min Y = a_vdb
		andi.w  #$FFFE,d0
		move.w  d0,y_min

		move.w  a_vde,d0		; Max Y = a_vde - lines of bmap
		sub.w	#BMP_LINES,d0
		andi.w  #$FFFE,d0
		sub.w   #2,d0
		move.w  d0,y_max
	
		move.l  (sp)+,d0
		rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: MoveBitmap
;            Range check and add motion constants to our bitmap
;
; Registers: d0 - X position
;            d1 - Y position
;            a0 - Address of bitmap object to change
;

MoveBitmap:
		movem.l d0-d1,-(sp)

		move.w  frame_count,d0
		add.w   #1,d0
		cmp.w   #UPDATE_FREQ,frame_count
		beq     do_move

		move.w  d0,frame_count
		bra     move_done
do_move:                
		clr.w   frame_count             ; Clear frame counter

		move.w  x_pos,d0                ; Verify X range
		cmp.w   x_min,d0
		ble     change_x                ; if 0

		cmp.w   x_max,d0
		blt     add_xmot                ; if not at right edge
change_x:
		neg.w   x_motion                ; reverse direction
add_xmot:
		add.w   x_motion,d0             ; new pos in d0

		move.w  y_pos,d1                ; Verify Y
		cmp.w   y_min,d1
		ble     change_y

		cmp.w   y_max,d1
		blt     add_ymot                ; not past bottom of screen
change_y:
		neg.w   y_motion                ; reverse direction
add_ymot:
		add.w   y_motion,d1             ; new Y pos in d1

		move.w  d0,x_pos                ; Store new values
		move.w  d1,y_pos
move_done:
		movem.l (sp)+,d0-d1
		rts

		.bss

frame_count:    ds.w    1
x_motion:       ds.w    1
y_motion:       ds.w    1
x_pos:          ds.w    1
y_pos:          ds.w    1
x_min:          ds.w    1
x_max:          ds.w    1
y_min:          ds.w    1
y_max:          ds.w    1

		.end
