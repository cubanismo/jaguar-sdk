;
; Jaguar Example Source Code
; Jaguar Workshop Series #3
; Copyright (c)1994 Atari Corp.
; ALL RIGHTS RESERVED
;
; Program: clip.cof	- Clipped object example
;  Module: clp_init.s	- Program entry and initialization
;
; Revision History:
; 6/16/94   - SDS: Copied from mov_init.s sources
; 8/03/94   - SDS: Update video initialization routine
;----------------------------------------------------------------------------
; Detailed Program Description:
;
; CLIP.COF follows a basic initialization procedure as follows:
;
; 1. Set Big-Endian Mode
; 2. Disable Video Interrupts
; 3. Define a stack pointer
; 4. Initialize the video display
; 5. Define local program variables
; 6. Create a basic object list
; 7. Define an interrupt handler to update the object list
; 8. Enable Video Interrupts
; 9. Return to the debugger with an illegal exception error
;
; All of the code in this example is done in the 68k for simplicity, not
; speed.
;
; The vertical blank handler periodically updates a bitmap object's fields
; from a static array to acheive horizontal phrase-wise clipping.
 
		.include	"jaguar.inc"
		.include	"clip.inc"

; Globals
		.globl		a_vdb
		.globl		a_vde
		.globl		a_hdb
		.globl		a_hde
		.globl		width
		.globl		height

; Externals

		.extern		InitLister
		.extern		InitClipVars
		.extern		UpdateList
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Program Entry Point Follows...

		.text

		move.l	#$00070007,G_END	; big-endian mode
		move.w	#$FFFF,VI		; disable video frame interrupts

		move.l	#INITSTACK,a7

		jsr	InitVideo		; Setup our video registers.
		jsr	InitClipVars		; Setup Variables
		jsr	InitLister		; Initialize Object Display List
						; List address is returned in d0
		jsr	InitVBint		; Initialize our VBLANK routine

		move.l	d0,OLP			; Value of d0 from InitLister
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
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: InitVideo (same as in vidinit.s)
;            Build values for hdb, hde, vdb, and vde and store them.
;
 						
InitVideo:
		movem.l	d0-d6,-(sp)
	
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
			
		movem.l	(sp)+,d0-d6
		rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Uninitialized Data!
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
		.bss

a_hdb:		.ds.w	1
a_hde:		.ds.w	1
a_vdb:		.ds.w	1
a_vde:		.ds.w	1
width:		.ds.w	1
height:		.ds.w	1

		.end
	
