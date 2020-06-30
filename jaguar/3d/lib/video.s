	.include	"jaguar.inc"

	.extern	_OLPstore		; bss for object list: defined in jagrt.s
	.extern	_OList			; points to the user's copy of the object list
;
; interrupt and video stuff
;

;
; video initialization
;
_VIDinit::

	jsr	InitVideo		; Setup our video registers.
	jsr	InitLister		; Initialize Object Display List
	jsr	InitVBint		; Initialize our VBLANK routine

	move.l	#_OLPstore+16,d0	; use OLPstore+16 because the first two phrases are stop objects
	bsr	SetOLP			;
 	move.w	4(sp),VMODE		; configure video
	rts				; return

	; use the GPU to set up the object processor
SetOLP::
	swap	d0
	move.l	d0,tmpOLP
	move.l	#GPUSetOLP,G_PC
	move.l	#$11,G_CTRL
	rts
;
; GPU function for setting the object processor
; the GPU has to do this because the 68000 writes
; the long word in 2 halves, and if the object processor
; runs in between the writes then it will blow up
;
	.long
	.gpu
GPUSetOLP:
	nop
	movei	#tmpOLP,r0
	load	(r0),r0			; load the value the caller wants
	movei	#OLP,r1
	store	r0,(r1)			; store it into the OLP
	movei	#G_CTRL,r1
	moveq	#0,r0
	store	r0,(r1)			; now turn ourselves off
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop

	.long
	.68000

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

		move.w	#5,_VIDtick		; 1 frame is 1/60 second = 5/300 tick units
		move.w	#0,_VIDpal
		bra	calc_vals
palvals:
		move.w	#PAL_HMID,d2
		move.w	#PAL_WIDTH,d0

		move.w	#PAL_VMID,d6
		move.w	#PAL_HEIGHT,d4

		move.w	#6,_VIDtick		; 1 frame is 1/50 second = 6/300 tick units
		move.w	#1,_VIDpal
calc_vals:
		move.w	d0,_VIDwidth
		move.w	d4,_VIDheight

		move.w	d0,d1
		asr	#1,d1			; Width/2

		sub.w	d1,d2			; Mid - Width/2
		add.w	#4,d2			; (Mid - Width/2)+4

		sub.w	#1,d1			; Width/2 - 1
		ori.w	#$400,d1		; (Width/2 - 1)|$400
		
		move.w	d1,_VID_hde
		move.w	d1,HDE

		move.w	d2,_VID_hdb
		move.w	d2,HDB1
		move.w	d2,HDB2

		move.w	d6,d5
		sub.w	d4,d5
		move.w	d5,_VID_vdb

		add.w	d4,d6
		move.w	d6,_VID_vde

		move.w	_VID_vdb,VDB
		move.w	#$FFFF,VDE
			
		move.l	#0,BORD1		; Black border
		move.w	#0,BG			; Init line buffer to black
			
		movem.l	(sp)+,d0-d6
		rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; InitLister: Initialize Object List Processor List
;

InitLister:
	movem.l	d0-d7/a0-a6,-(sp)
;
; make some branch and stop objects to work around an object processor bug
; for the branch objects:
; [-------unused-------][--------link--------] [unused] cc[---ypos---]type
; xxxxxxxx xxxxxxxx xxxxxxxx xxxxxxxx xxxxxxxx xxxxxxxx xxxxxxxx xxxxxxxx
;
;link is the address of the stop object / 8
;cc is 2 for branch0, 1 for branch1
;type is 3 for both branch objects
;ypos is vde for branch0, vdb for branch1
;
	lea	_OLPstore,a0
	move.l	a0,d0
	lsr.l	#3,d0			; convert address to phrase
	move.l	d0,d3			; we'll need this link address twice
	move.l	#0,(a0)+
	move.l	#4,(a0)+		; stop object
	move.l	#0,(a0)+		;
	move.l	#4,(a0)+		; another one, for quad alignment
					; a0 is now _OLPstore+16
;
; a0 now points at branch0
;
	moveq.l	#0,d1
	moveq.l	#0,d2
	move.w	_VID_vde,d1
	move.w	_VID_vdb,d2
	move.l	#_OLPstore,d0				;get the address of the stop object
	lsr.l	#3,d0					;reduce address to phrases
	move.l	d0,d3					;need to use low byte later

	lsr.l	#8,d0					;lowest 8 bits go in next long, so remove them
	move.l	d0,(a0)					;set high bytes of link pointer
	lsl.l	#3,d1					;shift vde left 3 to make room for object type
	or.w	#$8003,d1				;set cc to 2, type to 3
	lsl.l	#8,d3					;shift past 8 unused bits
	swap	d3					;move low 8 bits of link pointer and unused 8 bits to high word
	move.w	d1,d3					;combine cc, ypos, type with low 8 bits of link pointer and unused 8 bits
	move.l	d3,4(a0)				;save 2nd long in the phrase
	move.l	(a0),8(a0)				;high bytes of link pointer are the same as branch0
	lsl.l	#3,d2					;shift vdb left 3 to make room for object type
	or.w	#$4003,d2				;set cc to 1, type to 3
	move.w	d2,d3					;combine cc, ypos, type with low 8 bits of link pointer and unused 8 bits
	move.l	d3,12(a0)				;save 2nd long in the phrase
;
; finally, add another stop object (for now)
;
	lea	16(a0),a0		; a0 is now _OLPstore+32
	move.l	#0,(a0)
	move.l	#4,4(a0)
	move.l	a0,_OList

	movem.l	(sp)+,d0-d7/a0-a6
	rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: InitVBint 
; Install our vertical blank handler and enable interrupts
;

InitVBint:
		move.l	d0,-(sp)

		move.l	#0,__timestamp
		move.l	#VBI,LEVEL0		; Install our Auto-Vector 0 handler

		move.w	_VID_vde,d0		; Must be ODD
		ori.w	#1,d0
		move.w	d0,VI

		move.w	#$303,INT1		; Enable video and GPU interrupts

		move.w	sr,d0
		and.w	#$F8FF,d0		; Lower the 68k IPL to allow interrupts
		move.w	d0,sr

		move.l	(sp)+,d0
		rts
		
;
; vertical blank interrupt code
;
	.extern	__timestamp
VBI::
	movem.l	d0-d7/a0-a6,-(sp)

	move.w	INT1,d0

	move.w	d0,d1
	lsl.w	#8,d1
	or.w	#$3,d1
	move.w	d1,INT1			; mark interrupts as serviced, and re-enable them

	btst	#1,d0			; GPU interrupt?
	beq.b	.nogpu
	move.w	#1,_GPUdone	
.nogpu:
	btst	#0,d0
	beq.b	.novbi

	moveq.l	#0,d0
	move.w	_VIDtick,d0
	add.l	d0,__timestamp

	bsr	copy_olist

.novbi:
	move.w	#0,INT2
	movem.l	(sp)+,d0-d7/a0-a6
	rte

;
; copy_olist: copy object list from OList to OLPstore
;
copy_olist:
	move.l	_OList,a0
	lea	_OLPstore+32,a1		; first 4 phrases are reserved for stop and branch objects
.10:
	move.l	(a0)+,(a1)+		; copy first long of phrase
	move.l	(a0)+,d0
	move.l	d0,(a1)+
	cmpi.l	#4,d0			; see if we have reached the stop object
	bne.b	.10
	rts

;
; _VIDon(int mode): 
; a no-op, now: _VIDinit does this. Left in for compatibility with
; old code
;
_VIDon::
	bsr	copy_olist
	bsr	_VIDsync
	move.w	4(sp),d1		;get VMODE parameter
	move.w	d1,VMODE		;set video mode to that parameter
	rts

;
; _VIDsync(void): wait for a VBI
;
_VIDsync::
	move.l	__timestamp,d0
.10:
	cmp.l	__timestamp,d0
	beq.b	.10
	rts



	.bss
;
; global variables
;
_GPUdone::	.ds.w	1	; flag for GPU finished
_VIDpal::	.ds.w	1	; flag: 0 = NTSC, 1 = PAL
_VIDtick::	.ds.w	1	; ticks (i.e. 300ths of a second) per frame 

_VID_hdb::	.ds.w	1	; Horizontal display begin
_VID_hde::	.ds.w	1	; Horizontal display end
_VID_vdb::	.ds.w	1	; Vertical display begin
_VID_vde::	.ds.w	1	; Vertical display end
_VIDwidth::	.ds.w	1	; Width of display (in pixel clocks)
_VIDheight::	.ds.w	1	; Height of display (in pixel clocks)
;
; local variables
;
		.long
tmpOLP:		.ds.l	1	; OLP value to be loaded by the GPU
