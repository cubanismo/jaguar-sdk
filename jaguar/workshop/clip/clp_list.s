;
; Jaguar Example Source Code
; Jaguar Workshop Series #3
; Copyright (c)1994 Atari Corp.
; ALL RIGHTS RESERVED
;
; Program: clip.cof	- Clipped object example
;  Module: clp_list.s	- Object List Refresh and Initialization
;
; Revision History:
; 6/16/94  - SDS: Copied from mov_list.s
;		   Removed reference to x_pos and y_pos
; 8/04/94  - SDS: Modified UpdateList to do even less work.

		.include	"jaguar.inc"
		.include	"clip.inc"

; Globals
		.globl		InitLister
		.globl		UpdateList
		.globl		main_obj_list

; Externals
		.extern		a_vde
		.extern	 	a_vdb
		.extern		a_hdb
		.extern		a_hde
		.extern		width
		.extern		height
		.extern		jagbits

		.extern		x_pos
		.extern		i_width
		.extern		data_ptr

		.extern		ClipBitmap

TRANS		.equ		$8000

		.text

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; InitLister: Initialize Object List Processor List
;
;    Returns: Pre-word-swapped address of current object list in d0.l
;
;  Registers: d1.l/d0.l - Phrase being built
;             d2.l 	 - Address of STOP object in destination buffer
;	       d3.l      - Calculation register
;	       d4.l      - Width of image in phrases
;	       d5.l      - Height of image in scanlines
;             a0.l      - Roving object list pointer
		
InitLister:
		movem.l	d1-d5/a0,-(sp)		; Save registers
			
		lea	main_obj_list,a0
		move.l	a0,d2			; Destination of our list

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
		ori.l	#O_BRGT,d0		; $8000 = YPOS < VC
		move.w	a_vdb,d3		; for YPOS
		lsl.w	#3,d3			; Make it bits 13-3
		or.w	d3,d0

		move.l	d1,(a0)+		; Second OBJ is done
		move.l	d0,(a0)+	

; Write a standard BITMAP object
		clr.l	d1
		clr.l	d0			; Type = BITOBJ
			
		jsr	format_link

		move.l	#BMP_HEIGHT,d5		; Height of image

		lsl.l	#8,d5			; HEIGHT
		lsl.l	#6,d5
		or.l	d5,d0

		move.w	height,d3		; Center bitmap vertically
		sub.w	#BMP_HEIGHT,d3
		add.w	a_vdb,d3
		andi.w	#$FFFE,d3		; Must be even

		lsl.w	#3,d3
		or.w	d3,d0			; Stuff YPOS in low phrase

		move.l	#jagbits,d3
		andi.l	#$FFFFF0,d3
		move.l	d3,data_ptr		; Store for clip routine

		lsl.l	#8,d3			; Shift bitmap_addr into position
		or.l	d3,d1
     
		move.l	d1,(a0)+		; Write first phrase of BITOBJ
		move.l	d1,bmp_highl		; ...and copy for later update
		move.l	d0,(a0)+
		move.l	d0,bmp_lowl

		clr.l	d1
		move.l	#O_TRANS,d1		; PHRASE 2 of BITOBJ (TRANSPARENT)
		move.l	#O_DEPTH16|(1<<15),d0	; Bit Depth = 16-bit, Contiguous data

		clr.l	d3			; Center bitmap horizontally
		move.w	width,d3
		lsr.w	#2,d3			; /4 Pixel Divisor
		sub.w	#BMP_WIDTH,d3
		lsr.w	#1,d3
		move.w	d3,x_pos		; Copy XPOS for clip routine
		or.w	d3,d0			; Store XPOS

		move.l	#BMP_PHRASES,d4	
		move.w	d4,i_width		; Copy for clip routine
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

		move.l	d1,(a0)+		; Write second PHRASE of BITOBJ
		move.l	d0,(a0)+

; Write a STOP object at end of list
		clr.l	d1
		move.l	#(STOPOBJ|O_STOPINTS),d0

		move.l	d1,(a0)+		
		move.l	d0,(a0)+

		move.l	#main_obj_list,d0
		swap	d0

		movem.l	(sp)+,d1-d5/a0
		rts
			
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

		swap	d2			; This section places bits 10-3
		clr.w	d2			; in bits 31-24. It saves cycles
		lsl.l	#5,d2			; over using three shifts.
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
;		d2.l	  - Intermediate calculation register
;              d3.l      - Save register
;              d4.w      - Shift count register
;              a0.l      - Pointer into object list
;

UpdateList:
		movem.l	d0-d4/a0,-(sp)

		jsr	ClipBitmap		; Update Clipping Variables

		move.l	#main_obj_list+BITMAP_OFF,a0
		
		move.l	bmp_highl,d1
		andi.l	#$000007FF,d1		; Strip away DATA

		move.l	data_ptr,d2		; Grab new DATA field
		andi.l	#$FFFFF8,d2
		lsl.l	#8,d2			; Place it in position
		or.l	d2,d1			; Stuff value

		move.l	d1,(a0)+		; Write first phrase
		move.l	bmp_lowl,(a0)+

		move.l	(a0),d1			; Grab next phrase
		move.l	4(a0),d0

		andi.l	#$FFFFFFC0,d1		; Strip old IWIDTH/XPOS
		andi.l	#$0FFFF000,d0

		or.w	x_pos,d0		; Stuff new XPOS

		clr.l	d2
		move.w	i_width,d2
		move.l	d2,d3			; Make a copy

		move.w	#28,d4			; IWIDTH bits 28-31
		lsl.l	d4,d2
		or.l	d2,d0

		lsr.l	#4,d3			; IWIDTH bits 32-37
		or.l	d3,d1

		move.l	d1,(a0)+		; Store second phrase
		move.l	d0,(a0)+
	
		move.w	#$101,INT1
		move.w	#0,INT2

		movem.l	(sp)+,d0-d4/a0
		rte

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Storage space for our object lists

		.bss
		.dphrase
			
main_obj_list:	.ds.l		LISTSIZE*2    
bmp_highl:	.ds.l		1
bmp_lowl:	.ds.l		1
		
		.end
