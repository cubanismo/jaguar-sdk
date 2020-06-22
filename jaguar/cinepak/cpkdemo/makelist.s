; Jaguar Development System Source Code
; Copyright (c)1995 Atari Corp.
; All Rights Reserved
;
; Program: cpkdemo.cof	- Cinepak Player Demo
;  Module: makelist.s	- Object List Creation
;
; Revision History:
; 11/08/94  - SDS: Copied from scl_list.s (SCALE.COF Workshop)

		.include	"jaguar.inc"
		.include	"memory.inc"
		.include	"player.inc"
; Globals
		.globl		InitMoviList
		.globl		movilist
		.globl		listcopy
		.globl		x_pos
		.globl		y_pos
		.globl		cx_pos
		.globl		cy_pos
		.globl		cx_min
		.globl		cy_min
		.globl		cx_max
		.globl		cy_max
		.globl		h_scale
		.globl		v_scale

		.globl		data_off
		.globl		obj_height
		.globl		reflect
; Externals
		.extern		a_vde
		.extern	 	a_vdb
		.extern		a_hdb
		.extern		a_hde
		.extern		width
		.extern		height

		.text

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; InitMoviList: Initialize Object List Processor List
;
;  Registers: d1.l/d0.l - Phrase being built
;             d2.l	 - Address of STOP object in destination buffer
;	      d3.l      - Calculation register
;	      d4.l      - Width of image in phrases
;	      d5.l      - Height of image in scanlines
;             a0.l      - Roving object list pointer
;             a1.l      - Bitmap pointer
		
InitMoviList:
		movem.l	d1-d5/a0-a1,-(sp)	; Save registers
			
		move.l	#movilist-(2*8),a0

;;;;;;;;;;;;;;;;;;;;;;
; GPU Interrupt Object

		clr.l	(a0)+	
		move.l	#2,(a0)+

;;;;;;;;;;;;;
; STOP object

		clr.l	(a0)+
		move.l	#4,(a0)+

;;;;;;;;;;;;;;;
; BRANCH object

		clr.l	d1
		move.l	#(BRANCHOBJ|O_BRLT),d0	; $4000 = YPOS > VC

		move.l	#movilist-8,d2
		jsr	format_link		; Stuff in our LINK address
						
		move.w	a_vde,d3
		lsl.w	#3,d3
		or.w	d3,d0	

		move.l	d1,(a0)+
		move.l	d0,(a0)+		; First OBJ is done.

;;;;;;;;;;;;;;;
; BRANCH object	

		andi.l	#$FF000007,d0		; Mask off CC and YPOS
		ori.l	#O_BRGT,d0		; $8000 = YPOS < VC

		move.w	a_vdb,d3		; for YPOS
		lsl.w	#3,d3			; Make it bits 13-3
		or.w	d3,d0

		move.l	d1,(a0)+
		move.l	d0,(a0)+

;;;;;;;;;;;;;;;
; BRANCH object

		clr.l	d1
		move.l	#(BRANCHOBJ|O_BREQ),d0	; YPOS = VC

		move.l	#movilist-(2*8),d2
		jsr	format_link

		move.w	a_vde,d3	      	; Update Point
		andi.w	#$FFFE,d3    		; Ensure it's odd
		lsl.w	#3,d3
		or.w	d3,d0

		move.l	d1,(a0)+		; Store it
		move.l	d0,(a0)+

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Write a SCALABLE BITMAP object

		clr.l	d1
		move.l	#SCBITOBJ,d0		; Type = SCALED BITMAP
			
		move.l	#movilist-8,d2
		jsr	format_link

		move.l	#NLINES-1,d5		; Height of image
						; Must -1 for SCALED!

		lsl.l	#8,d5			; HEIGHT
		lsl.l	#6,d5
		or.l	d5,d0

		move.w	a_vdb,d3
		lsl.w	#3,d3
		or.w	d3,d0			; Stuff YPOS in low phrase

		move.l	#SCREEN_BASE,d3
		andi.l	#$FFFFF0,d3
		lsl.l	#8,d3			; Shift bitmap_addr into position
		or.l	d3,d1
     
		move.l	d1,(a0)+
		move.l	d0,(a0)+

		move.l	#O_RELEASE,d1		; PHRASE 2 of SCBITOBJ
		move.l	#O_DEPTH16|O_2GAP,d0	; Bit Depth = 16-bit, Skip-Two

		or.l	#10,d0			; Temp XPOS

		move.l	#BMP_PHRASES*3,d4	; Account for three buffers	
		move.l	#BMP_PHRASES,d3

		lsl.l	#8,d4			; DWIDTH
		lsl.l	#8,d4
		lsl.l	#2,d4
		or.l	d4,d0

		lsl.l	#8,d4			; IWIDTH Bits 28-31
		lsl.l	#2,d4
		or.l	d4,d0

		lsr.l	#4,d3			; IWIDTH Bits 37-32
		or.l	d3,d1
			  
		move.l	d1,(a0)+		; Write second PHRASE of SCBITOBJ
		move.l	d0,(a0)+

; Write the third phrase containing SCALING presets
		clr.l	(a0)+

		clr.l	d0
		move.w	v_scale,d0	; for REMAINDER
		lsl.l	#8,d0
		or.w	v_scale,d0	; for VSCALE
		lsl.l	#8,d0
		or.w	h_scale,d0
		move.l	d0,(a0)+	; HSCALE = 1.0, VSCALE = 1.0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Now do an initial copy to store our list

		move.l	#movilist+BITMAP_OFF,a0
		lea	listcopy,a1

		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+

		movem.l	(sp)+,d1-d5/a0-a1
		rts
			
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: format_link
;
;    Inputs: d1.l/d0.l is a 64-bit phrase
;            d2.l contains the LINK address to put into bits 42-24 of phrase
;
;   Returns: Updated phrase in d1.l/d0.l

format_link:
		movem.l	d2-d3,-(sp)

		andi.l	#$3FFFF8,d2		; Ensure alignment/valid address
		move.l	d2,d3			; Make a copy

		swap	d2			; Put bits 10-3 in bits 31-24
		clr.w	d2
		lsl.l	#5,d2
		or.l	d2,d0

		lsr.l	#8,d3			; Put bits 21-11 in bits 42-32
		lsr.l	#3,d3
		or.l	d3,d1

		movem.l	(sp)+,d2-d3		; Restore regs
		rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Storage space for our object lists
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		.bss
		.qphrase

		.ds.l		(2*5)		; Buffer for two prior objects			
movilist:	.ds.l		(2*LISTSIZE)
listcopy:	.ds.l		(2*3)		; Room for scaled bitmap only

x_pos:		.ds.w		1
y_pos:		.ds.w		1
cx_pos:		.ds.w		1
cy_pos:		.ds.w		1
cx_min:		.ds.w		1
cx_max:		.ds.w		1
cy_min:		.ds.w		1
cy_max:		.ds.w		1
h_scale:	.ds.w		1
v_scale:	.ds.w		1

		.long

data_off:	.ds.l		1
obj_height:	.ds.w		1
reflect:	.ds.w		1

		.end
