;
; Jaguar Sample Code
; Copyright (c)1994 Atari Corp.
; All Rights Reserved 
;
; Project: cpkdemo.cof - Cinepak Scaling/Motion Demo
;  Module: sclvars.s   - Read Joypad/Update scaling variables
;
; History: 11/09/94 - Created (SDS)
;

		.include "memory.inc"
		.include "player.inc"
		.include "jaguar.inc"

		.68000
		.text

;;; Globals
		.globl		UpdateScale
		.globl		InitVars
		.globl		UpdateVars
		.globl		ModifyOlist
;;; Externals
		.extern		x_pos
		.extern		y_pos
		.extern		h_scale
		.extern		v_scale
		.extern		cx_pos
		.extern		cy_pos
		.extern		cx_min
		.extern		cx_max
		.extern		cy_min
		.extern		cy_max

		.extern		data_off
		.extern		blitScreen
		.extern		obj_height

		.extern		reflect
		.extern		soundmute

		.extern		a_vdb
		.extern		width
		.extern		height
		.extern		movilist
		.extern		listcopy		
		.extern		blitAngle
		.extern		scrbuf

		.extern		GetNextTrack
		.extern		GetPrevTrack

SMOTION		.equ		1
MOTION		.equ		4
soundmute	.equ		D_RAM+$1FFC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: InitVars
;            One time initialization of scaling variables.
;

InitVars:	
		move.l	d0,-(sp)

		move.l	#0,newtrack	; Track # accumulator
		move.w	#0,reflect    	; Reflection off
		move.l	#0,blitAngle	; Initial blit Angle
		move.l	#0,soundmute

		clr.l	data_off
		move.w	#NLINES-1,obj_height

		move.w	#$20,h_scale   	; Initial horizontal scaling
		move.w	#$20,v_scale   	; Initial vertical scaling
		
		move.w	width,d0      	; Width of screen in clocks
		lsr.w	#3,d0	      	; /4 Pixel Divisor + /2
		move.w	d0,cx_pos     	; Middle horizontal pixel

		move.w	height,d0     	; Find middle vertical pixel		
		lsr.w	#1,d0
		move.w	d0,cy_pos

		move.w	#0,cx_min
		move.w	width,d0
		lsr.w	#2,d0
		move.w	d0,cx_max

		move.w	#0,cy_min
		move.w	height,cy_max

		move.l	(sp)+,d0
		rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: UpdateScale
;            Update Joypad State -> Update Scaling/Motion Variables
;
;   Returns: d0 - Track Change State
;                 0 = No change
;                -1 = Program Reset
;             Other = New Track # (from initial offset - 1 based)

UpdateScale:
		movem.l	d1-d7,-(sp)

		move.l	#0,d7		; Default no track change
		bsr	ReadJoypad

		move.l	joyedge,d0	; New button presses
		move.l	joycur,d1	; Joypad state
		move.w	h_scale,d2
		move.w	v_scale,d3
		move.w	cx_pos,d4
		move.w	cy_pos,d5
		
		btst.l	#FIRE_A,d1
		bne	testskip

		tst.l	newtrack
		beq	nohold

		jsr	TrackSelect
		tst.l	d7
		bne	skip
nohold:
		tst.l	joycur
		beq	skip

		btst.l	#FIRE_B,d1	; Scaling?
		beq	noscale		; No scaling

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Read joypad for scaling adjustments

		btst.l	#JOY_RIGHT,d1	; Increasing Horizontal Scale?
		beq	testsleft

		add.w	#SMOTION,d2

		cmpi.w	#$40,d2		; At limit?
		ble	testsdown

		move.w	#$40,d2		; High limit.
testsleft:
		btst.l	#JOY_LEFT,d1	; Decreasing Horizontal Scale?
		beq	testsdown

		sub.w	#SMOTION,d2	; Less than zero? (wasn't that a movie)
		bpl	testsdown

		clr.w	d2		; Force to 0
		bra	testsdown
testsdown:	
		btst.l	#JOY_DOWN,d1	; Increasing Vertical Scale?
		beq	testsup

		add.w	#SMOTION,d3

		cmpi.w	#$40,d3		; At limit?
		ble	testother

		move.w	#$40,d3
		bra	testother
testsup:
		btst.l	#JOY_UP,d1
		beq	testother

		sub.w	#SMOTION,d3
		bpl	testother

		clr.w	d3
		bra	testother

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Read joypad for movement
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

noscale:
		btst.l	#JOY_LEFT,d1	; Moving left?
		beq	testright

		sub.w	#MOTION,d4

		cmp.w	cx_min,d4	; At limit?
		bge	testup

		move.w	cx_min,d4
		bra	testup		; No need to test right, right? :)
testright:
		btst.l	#JOY_RIGHT,d1	; Moving Right?
		beq	testup

		add.w	#MOTION,d4

		cmp.w	cx_max,d4	; At limit?
		ble	testup
		
		move.w	cx_max,d4  	; Add to cx_pos
testup:	
		btst.l	#JOY_UP,d1	; Moving Up?
		beq	testdown

		sub.w	#MOTION,d5

		cmp.w	cy_min,d5  	; At limit?
		bge	testother

		move.w	cy_min,d5   	; Move center point upwards
		bra	rangecheck
testdown:
		btst.l	#JOY_DOWN,d1	; Moving down?
		beq	testother

		add.w	#MOTION,d5

		cmp.w	cy_max,d5
		ble	testother

		move.w	cy_max,d5  	; Move down
		bra	rangecheck
testother:
		btst.l	#OPTION,d0
		beq	testrotcc

		bchg.b	#0,reflect
		bra	rangecheck
testrotcc:
		btst.l	#KEY_4,d1
		beq	testrotc

		add.l	#16,blitAngle
		andi.l	#$7FF,blitAngle
		bra	rangecheck
testrotc:
		btst.l	#KEY_6,d1
		beq	testrotfix

		sub.l	#16,blitAngle
		andi.l	#$7FF,blitAngle
		bra	rangecheck
testrotfix:
		btst.l	#KEY_5,d0
		beq	testskip

		clr.l	blitAngle
		bra	rangecheck
testskip:
		btst.l	#FIRE_A,d1
		beq	testsound
		
		jsr	TrackSelect	; Will return new track in D7
		bra	rangecheck
testsound:
		btst.l	#KEY_0,d0
		beq	testfullscr

		move.l	soundmute,d6
		bchg.l	#0,d6
		move.l	d6,soundmute
		bra	rangecheck
testfullscr:
		btst.l	#FIRE_C,d0
		beq	testaspect

		jsr	InitVars
		bra	skip
testaspect:
		btst.l	#KEY_1,d0
		beq	testreset

		cmp.l	d2,d3
		bgt	.other

		move.l	d2,d3
		bra	testreset
.other:
		move.l	d3,d2
testreset:
		btst.l	#KEY_STAR,d1
		beq	rangecheck

		btst.l	#KEY_HASH,d1
		beq	rangecheck

		move.l	#-1,d7		; Return RESET!!!
		bra	skip
rangecheck:
		move.w	d2,h_scale
		move.w	d3,v_scale
		move.w	d4,cx_pos
		move.w	d5,cy_pos

		jsr	UpdateVars	; Range Check Variables
		jsr	ModifyOlist	; Modify Object List Copy
skip:
		move.l	d7,d0		; Move new? track to return loc

		movem.l	(sp)+,d1-d7
		rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: UpdateVars
;            Range Check Variables/Update Related Ones
;

UpdateVars:
		movem.l	d0-d4,-(sp)

		clr.l	d4		; Initial DATA offset

		move.l	#NPIXELS,d0	; Bitmap Width
		move.w	h_scale,d1

		mulu	d1,d0
		lsr.l	#6,d0		; D0 now contains true pixel width/2

		clr.l	d1
		move.w	cx_pos,d1	; Find real x_pos (+|-)
		sub.l	d0,d1

		btst.b	#0,reflect
		beq	noxadd

		lsl.l	#1,d0
		add.l	d0,d1		; Yes, add adjusted movie XPOS
noxadd:
		andi.w	#$FFF,d1	; Make legal XPOS
		move.w	d1,x_pos

		move.l	#NLINES-1,d0
		move.l	d0,d3		; Copy this for obj_height
		move.w	v_scale,d1

		mulu	d1,d0
		lsr.l	#6,d0		; d0 now contains true pixel height/2

		clr.l	d1
		move.w	cy_pos,d1
		sub.l	d0,d1
		bpl	pos_y

		neg.l	d1		; Get positive value

		lsl.l	#5,d1
		divu	v_scale,d1
		andi.l	#$FFFF,d1

		sub.l	d1,d3		; Calc new height

		move.l	#ROWBYTES*3,d2

		mulu	d1,d2		; # of bytes to skip
		add.l	d2,d4		; New DATA offset

		clr.w	d1		; Flush top YPOS	
pos_y:
		lsl.w	#1,d1
		add.w	a_vdb,d1

		move.w	d1,y_pos
		move.w	d3,obj_height

		move.l	d4,data_off

		movem.l	(sp)+,d0-d4
		rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: ModifyOlist
;            Hard modify the contents of the object list and bmp_highl
;

ModifyOlist:
		movem.l	d0-d1/a0,-(sp)

		lea	listcopy,a0
		
		move.l	8(a0),d0   		; Set reflection bit
		andi.l	#$FFFFDFFF,d0		; Mask REFLECT

		btst.b	#0,reflect
		beq	noreflect

		ori.l	#O_REFLECT,d0
noreflect:
		move.l	d0,8(a0)		; Store REFLECT

		move.l	12(a0),d0  		; Low Phrase 2 -> d0.l
		andi.l	#$FFFFF000,d0		; Mask away old XPOS

		or.w	x_pos,d0		; Grab XPOS and store it.

		move.l	d0,12(a0)		; d0.l -> Low Phrase 2

		clr.l	d0
		move.w	h_scale,d0		; Format scaling
		move.w	v_scale,d1
		lsl.w	#8,d1
		or.w	d1,d0
		
		move.l	d0,20(a0)		; Store scaling

		movem.l	(sp)+,d0-d1/a0
		rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: ReadJoypad
;            Read Joypad 1 and place values in joycur and joyedge
;

ReadJoypad:
		movem.l d0-d2,-(sp)

		move.l  #$f0fffffc,d1     ; d1 = Joypad data mask
		moveq.l #-1,d2            ; d2 = Cumulative joypad reading
	
		move.w  #$81fe,JOYSTICK   
		move.l  JOYSTICK,d0       ; Read joypad, pause button, A button
		or.l    d1,d0             ; Mask off unused bits
		ror.l   #4,d0             
		and.l   d0,d2             ; d2 = xxAPxxxx RLDUxxxx xxxxxxxx xxxxxxxx
		move.w  #$81fd,JOYSTICK
		move.l  JOYSTICK,d0       ; Read *741 keys, B button
		or.l    d1,d0             ; Mask off unused bits
		ror.l   #8,d0
		and.l   d0,d2             ; d2 = xxAPxxBx RLDU741* xxxxxxxx xxxxxxxx
		move.w  #$81fb,JOYSTICK
		move.l  JOYSTICK,d0       ; Read 2580 keys, C button
		or.l    d1,d0             ; Mask off unused bits
		rol.l   #6,d0
		rol.l   #6,d0
		and.l   d0,d2             ; d2 = xxAPxxBx RLDU741* xxCxxxxx 2580xxxx
		move.w  #$81f7,JOYSTICK
		move.l  JOYSTICK,d0       ; Read 369# keys, Option button
		or.l    d1,d0             ; Mask off unused bits
		rol.l   #8,d0
		and.l   d0,d2             ; d2 = xxAPxxBx RLDU741* xxCxxxOx 2580369# <== inputs active low

		moveq.l #-1,d1
		eor.l   d2,d1             ; d1 = xxAPxxBx RLDU741* xxCxxxOx 2580369# <== now inputs active high

		move.l  joycur,d0         ; old joycur needed for determining the new joyedge
		move.l  d1,joycur         ; Current joypad reading stored into joycur
		eor.l   d1,d0
		and.l   d1,d0
		move.l  d0,joyedge        ; joypad, buttons, keys that were just pressed

		movem.l (sp)+,d0-d2
		rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: TrackSelect
;            Read joypad keys to select new track
;
;    Inputs: d0 - JOYEDGE
;            d1 - JOYCUR
;
;   Returns: d7 - New track # or 0

TrackSelect:
		movem.l	d2-d5/a0,-(sp)

		move.l	newtrack,d2
		move.l	#0,d7

		btst.l	#FIRE_A,d1	; Has 'A' been released?
		beq	calc
		
		btst.l	#JOY_RIGHT,d0
		beq	left

		movem.l	d0,-(sp)
		jsr	GetNextTrack
		move.l	d0,d7
		movem.l	(sp)+,d0

		bra	endts
left:
		btst.l	#JOY_LEFT,d0
		beq	keys

		movem.l	d0,-(sp)
		jsr	GetPrevTrack
		move.l	d0,d7
		movem.l	(sp)+,d0
		bra	endts
keys:
		lea	keytab,a0	; No, so check for new keys...
		move.w	#9,d5		; Loop counter
nextkey:
		move.l	(a0)+,d3	; Bit for Key
		move.l	(a0)+,d4	; Key value
		btst.l	d3,d0		; Newly depressed?
		beq	doloop		; Nope, next...

		lsl.l	#4,d2		; Shift BCD and add new key
		add.l	d4,d2

		andi.l	#$FF,d2
		move.l	d2,newtrack	; Store	it
		bra	endts
doloop:
		dbra	d5,nextkey	; Try next
		bra	endts		; No keys
calc:
		move.l	d2,d7		; 'A' released ... calc then return
		lsr.l	#4,d2
		mulu	#10,d2

		andi.l	#$F,d7
		add.l	d2,d7

		move.l	#0,newtrack
		bra	endts
endts:
		movem.l	(sp)+,d2-d5/a0
		rts

;;;;;;;;;;;;;;;;;;;;;;;
;;; Keypad Table
;;;;;;;;;;;;;;;;;;;;;;;

		.data
keytab:
		dc.l	KEY_0,0
		dc.l	KEY_1,1
		dc.l	KEY_2,2
		dc.l	KEY_3,3
		dc.l	KEY_4,4
		dc.l	KEY_5,5
		dc.l	KEY_6,6
		dc.l	KEY_7,7
		dc.l	KEY_8,8
		dc.l	KEY_9,9
	
joyedge:	.dc.l	1
joycur:		.dc.l	1
newtrack:	.dc.l	1

		.end
