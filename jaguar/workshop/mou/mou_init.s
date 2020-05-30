;
; Jaguar Example Source Code
; Jaguar Workshop Series #1
; Copyright (c)1994 Atari Corp.
; ALL RIGHTS RESERVED
;
; Program: mou.cof	- Minimum time object list update
;  Module: mou_init.s	- Program entry and initialization
;
; Revision History:
; 6/4/94   - SDS: Created
; 6/8/94   - SDS: Working 'black' screen (no bitmap yet)
; 6/13/94  - SDS: Bitmap working after zeroing the $@$%^@ VMODE variable
;                 Coalesced several .s files into this one
; 7/15/94  - SDS: Changed from RAM bitmap to ROM bitmap
;                 Changed move.w #$1F00,INT1 to move.w #$FFFF,VI
;                 Use UpdateFields instead of copying buffered list
; 9/28/94  - SDS: Slightly optimized some code - improved comments.
;----------------------------------------------------------------------------
; Program Description:
;
; This sample code demonstrates an efficient method for maintaining the
; a simple object list during the vertical blanking period.
;
; Steps are as follows:
; 1. Set GPU to Big-Endian mode
; 2. Set VI to $FFFF to disable video-refresh.
; 3. Initialize a stack pointer to high ram.
; 4. Initialize video registers.
; 5. Create an object list as follows:
;            BRANCH Object (Branches to stop object if past display area)
;            BRANCH Object (Branches to stop object if prior to display area)
;            BITMAP Object (Jaguar Logo)
;            STOP Object
; 6. Install interrupt handler, configure VI, enable video interrupts,
;    lower 68k IPL to allow interrupts.
; 7. Stuff OLP with pointer to object list.
; 8. Turn on video.
;----------------------------------------------------------------------------
		.include	"jaguar.inc"
		.include	"mou.inc"

; Globals
		.globl		a_vdb
		.globl		a_vde
		.globl		a_hdb
		.globl		a_hde
		.globl		width
		.globl		height
; Externals
		.extern		InitLister
		.extern		UpdateList

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Program Entry Point Follows...

		.text

		move.l	#$00070007,G_END	; big-endian mode
		move.w	#$FFFF,VI		; disable video interrupts

		move.l	#INITSTACK,a7		; Setup a stack
			
		jsr	InitVideo		; Setup our video registers.
		jsr	InitLister		; Initialize Object Display List
		jsr	InitVBint		; Initialize our VBLANK routine

		move.l	d0,OLP			; Value of D0 from InitLister
		move.w	#$6C1,VMODE		; Configure Video
		
		illegal				; Bye bye...

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: InitVBint 
; Install our vertical blank handler and enable interrupts
;

InitVBint:
		move.l	d0,-(sp)

		move.l	#UpdateList,LEVEL0	; Install 68K LEVEL0 handler

		move.w	a_vde,d0		; Must be ODD
		ori.w	#1,d0
		move.w	d0,VI

		move.w	INT1,d0			; Enable video interrupts
		ori.w	#1,d0
		move.w	d0,INT1

		move.w	sr,d0
		and.w	#$F8FF,d0		; Lower 68k IPL to allow
		move.w	d0,sr			; interrupts

		move.l	(sp)+,d0
		rts
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
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

;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Uninitialized Data!!!
;;;;;;;;;;;;;;;;;;;;;;;;;;

		.bss

a_hdb:		.ds.w	1
a_hde:		.ds.w	1
a_vdb:		.ds.w	1
a_vde:		.ds.w	1
width:		.ds.w	1
height:		.ds.w	1

		.end

