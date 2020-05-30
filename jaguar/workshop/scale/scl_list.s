;
; Jaguar Example Source Code
; Jaguar Workshop Series #4
; Copyright (c)1994 Atari Corp.
; ALL RIGHTS RESERVED
;
; Program: scale.cof	- Object Scaling Example
;  Module: scl_list.s	- Object List Refresh and Initialization
;
; Revision History:
; 6/20/94  - SDS: Copied from clp_list.s

		.include	"jaguar.inc"
		.include	"scale.inc"

; Globals
		.globl		InitLister
		.globl		main_obj_list
		.globl		UpdateList
; Externals
		.extern		a_vde
		.extern	 	a_vdb
		.extern		a_hdb
		.extern		a_hde
		.extern		width
		.extern		height
		.extern		jagbits
		.extern		x_pos
		.extern		y_pos
		.extern		h_scale
		.extern		v_scale

		.extern		ScaleBitmap

		.text

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; InitLister: Initialize Object List Processor List
;
;    Returns: Pre-word-swapped address of current object list in d0.l
;
;  Registers: d1.l/d0.l - Phrase being built
;             d2.l	 - Address of STOP object in destination buffer
;	      d3.l      - Calculation register
;	      d4.l      - Width of image in phrases
;	      d5.l      - Height of image in scanlines
;             a0.l      - Roving object list pointer
;             a1.l      - Bitmap pointer
		
InitLister:
		movem.l	d1-d5/a0-a1,-(sp)	; Save registers
			
		lea	main_obj_list,a0
		move.l	a0,d2

; Write first BRANCH object (branch if YPOS > a_vde )

		add.l	#(LISTSIZE-1)*8,d2	; Address of STOP object

		clr.l	d1
		move.l	#(BRANCHOBJ|O_BRLT),d0	; $4000 = VC < YPOS
		jsr	format_link		; Stuff in our LINK address
						
		move.w	a_vde,d3		; for YPOS
		lsl.w	#3,d3			; Make it bits 13-3
		or.w	d3,d0

		move.l	d1,(a0)+				
		move.l	d0,(a0)+		; First OBJ is done.

; Write second branch object (branch if YPOS < a_vdb)	
; Note: LINK address is the same so preserve it

		andi.l	#$FF000007,d0		; Mask off CC and YPOS
		ori.l	#O_BRGT,d0		; $8000 = VC > YPOS
		move.w	a_vdb,d3		; for YPOS
		lsl.w	#3,d3			; Make it bits 13-3
		or.w	d3,d0

		move.l	d1,(a0)+		; Second OBJ is done
		move.l	d0,(a0)+	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Write a SCALABLE BITMAP object

		clr.l	d1
		move.l	#SCBITOBJ,d0		; Type = SCALED BITMAP
			
		jsr	format_link

		move.l	#BMP_HEIGHT-1,d5	; Height of image
						; Must -1 for SCALED!

		lsl.l	#8,d5			; HEIGHT
		lsl.l	#6,d5
		or.l	d5,d0

		move.w	height,d3		; Center bitmap vertically
		sub.w	#BMP_HEIGHT,d3		; Scaled bitmaps must be -1
		add.w	a_vdb,d3
		andi.w	#$FFFE,d3		; Must be even

		lsl.w	#3,d3
		or.w	d3,d0			; Stuff YPOS in low phrase

		move.l	#jagbits,d3
		andi.l	#$FFFFF0,d3
		lsl.l	#8,d3			; Shift bitmap_addr into position
		or.l	d3,d1
     
		move.l	d1,(a0)+
		move.l	d1,bmp_highl
		move.l	d0,(a0)+
		move.l	d0,bmp_lowl

		move.l	#O_TRANS,d1		; PHRASE 2 of SCBITOBJ (TRANSPARENT)
		move.l	#O_DEPTH16|O_NOGAP,d0	; Bit Depth = 16-bit, Contiguous data

		move.w	width,d3		; Width of screen in clocks
		lsr.w	#2,d3			; /4 Pixel Divisor
		sub.w	#BMP_WIDTH,d3
		lsr.w	#1,d3
		or.w	d3,d0

		move.l	#BMP_PHRASES,d4	
		move.l	d4,d3			; Copy for below

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
		move.l	#$00002020,(a0)+	; HSCALE = 1.0, VSCALE = 1.0
		move.l	#$00002020,scl_lowl

; Write a STOP object at end of list
		clr.l	d1
		move.l	#(STOPOBJ|O_STOPINTS),d0

		move.l	d1,(a0)+		
		move.l	d0,(a0)+

; Now do an initial copy to store our list
		move.l	#main_obj_list,d0
		swap	d0			

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; UpdateList: Do the minimum amount of work necessary to update our object list.
;
;  Registers:	d1.l/d0.l - Phrase storage area
;              a0.l      - Pointer into object list
;

UpdateList:
		movem.l	d0-d1/a0,-(sp)

		jsr	ScaleBitmap

		move.l	#main_obj_list+BITMAP_OFF,a0
		
		move.l	bmp_highl,(a0)		; Store old high long because no fields changed
		move.l	bmp_lowl,d0		; Grab low longword of phrase to change YPOS

		andi.l	#$FFFFC007,d0		; Strip old YPOS

		move.w	y_pos,d1		; Update YPOS from internal var
		lsl.w	#3,d1			; Shift into bits 13-3
		or.w	d1,d0

		move.l	d0,4(a0)		; Store low longword of phrase 1

		move.l	12(a0),d0		; Low Phrase 2 -> d0.l
		andi.l	#$FFFFF000,d0		; Mask away old XPOS

		or.w	x_pos,d0		; Grab XPOS and store it.

		move.l	d0,12(a0)		; d0.l -> Low Phrase 2

		move.l	scl_lowl,d0		; Low Long of Phrase 3 containing H/VSCALE
						; This comes from buffer because REMAINDER was changed
						; by the OP.

		andi.l	#$FFFF0000,d0		; Strip away old
		or.w	h_scale,d0
		move.w	v_scale,d1
		lsl.w	#8,d1
		or.w	d1,d0
		
		move.l	d0,20(a0)
		 
		move.w	#$101,INT1
		move.w	#$0,INT2

		movem.l	(sp)+,d0-d1/a0
		rte

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Storage space for our object lists

		.bss
		.dphrase
			
main_obj_list:
		.ds.l		LISTSIZE*2
bmp_highl:
		.ds.l		1
bmp_lowl:
		.ds.l		1
scl_lowl:
		.ds.l		1

		.end
