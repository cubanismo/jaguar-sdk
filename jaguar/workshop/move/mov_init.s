;
; Jaguar Example Source Code
; Jaguar Workshop Series #2
; Copyright (c)1994 Atari Corp.
; ALL RIGHTS RESERVED
;
; Program: move.cof	- Moving bitmap object example
;  Module: mov_init.s	- Program entry and initialization
;
; Revision History:
; 6/15/94   - SDS: Copied from mou_init.s sources
; 7/26/94   - SDS: Updated from new mov_init.s sources
;----------------------------------------------------------------------------
; This Jaguar sample program initializes the jaguar hardware and video
; registers, builds an object list with one bitmap object (aside from the
; required two branch and one stop object) that contains the Jaguar logo.
;
; Vertical blank interrupts are then enabled and the bitmap is moved every
; certain number of frames given by the constant UPDATE_FREQ. The bitmap
; is bounded by the horizontal and vertical extents of the screen and will
; reverse direction when those extents are reached.
;
		.include	"jaguar.inc"
		.include	"move.inc"

; Globals
		.globl		a_vdb
		.globl		a_vde
		.globl		a_hdb
		.globl		a_hde
		.globl		width
		.globl		height
		.globl		copy_phrases
; Externals

		.extern		InitLister
		.extern		InitMoveVars
		.extern		UpdateList
		.extern		jagbits

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Program Entry Point Follows...

		.text

		move.l	#$00070007,G_END	; Big-endian mode
		move.w	#$FFFF,VI		; Disable video interrupts

		move.l	#INITSTACK,a7		; Point stack at end of RAM

		jsr	InitVideo		; Setup our video registers.
		jsr	InitMoveVars		; Setup Movement Variables
		jsr	InitLister		; Initialize Object Display List
		jsr	InitVBint		; Initialize our VBLANK routine

		move.l	d0,OLP			; Value of D0 from InitLister
		move.w	#$6C1,VMODE		; Configure Video

		illegal				; Bye bye...

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: InitVBint 
; Install our vertical blank handler and enable interrupts
;
;

InitVBint:
		move.l	d0,-(sp)

		move.l	#UpdateList,LEVEL0	; Install our Auto-Vector 0 handler

		move.w	a_vde,d0
		ori.w	#1,d0			; Must be ODD
		move.w	d0,VI

		move.w	INT1,d0
		ori.w	#1,d0
		move.w	d0,INT1

		move.w	sr,d0
		and.w	#$F8FF,d0		; Lower the 68k IPL to allow interrupts
		move.w	d0,sr

		move.l	(sp)+,d0
		rts
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Procedure: InitVideo (same as in vidinit.s)
;            Build values for hdb, hde, vdb, and vde and store them.
;
 						
InitVideo:
		move.l	d0,-(sp)		; Save the one register we use
	
		move.w	CONFIG,d0		; Also is joystick register
		andi.w	#VIDTYPE,d0		; 0 = PAL, 1 = NTSC
		beq	palvals

		move.w	#NTSC_HMID,d2
		move.w	#NTSC_WIDTH,d0

		move.w	#NTSC_VMID,d6
		move.w	#NTSC_HEIGHT,d4

		bra	calc_vals
palvals:
		move.w	#PAL_HMID,d2
		move.w	#PAL_WIDTH,d0

		move.w	#PAL_VMID,d6
		move.w	#PAL_HEIGHT,d4

calc_vals:
		move.w	d0,width
		move.w	d4,height

		move.w	d0,d1
		asr	#1,d1			; Width/2

		sub.w	d1,d2			; Mid - Width/2
		add.w	#4,d2			; (Mid - Width/2)+4

		sub.w	#1,d1			; Width/2 - 1
		ori.w	#$400,d1		; (Width/2 - 1)|$400
		
		move.w	d1,a_hde
		move.w	d1,HDE

		move.w	d2,a_hdb
		move.w	d2,HDB1
		move.w	d2,HDB2

		move.w	d6,d5
		sub.w	d4,d5
		move.w	d5,a_vdb

		add.w	d4,d6
		move.w	d6,a_vde

		move.w	a_vdb,VDB
		move.w	#$FFFF,VDE
			
		move.l	#0,BORD1		; Black border
		move.w	#0,BG			; Init line buffer to black
			
		move.l	(sp)+,d0
		rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Uninitialized Data!!!
			
		.bss

a_hdb:		.ds.w	1
a_hde:		.ds.w	1
a_vdb:		.ds.w	1
a_vde:		.ds.w	1
width:		.ds.w	1
height:		.ds.w	1

		.end
	
