;
; Jaguar Example Source Code
; Copyright (c)1994 Atari Corp.
; ALL RIGHTS RESERVED
;
; Program: joytest.cof	- Joystick reading example
;  Module: jt_loop.s   	- Main Program Loop
;
; Revision History:
; 9/2/94   - SDS: Created

		.include     	"jaguar.inc"
		.include     	"joytest.inc"

; Globals
		.globl		InitVars
		.globl		MainLoop

		.globl		cursor_data
		.globl		mypal
; Externals
		.extern		frame_cnt

		.extern		curs1_x
		.extern    	curs1_y
		.extern    	curs2_x
		.extern    	curs2_y
		
		.extern    	fire1_data
		.extern    	fire2_data

		.extern    	key1_data
		.extern    	key2_data
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: InitVars
;	      Initialize program variables
;

InitVars:
		move.l	d0,-(sp)

		move.w	#CURS_X,curs1_x
		move.w	#CURS_X+100,curs2_x
		move.w	#CURS_Y,curs1_y
		move.w	#CURS_Y,curs2_y

		move.l	#dash,d0
		move.l	d0,fire1_data
		move.l	d0,fire2_data
		move.l	d0,key1_data
		move.l	d0,key2_data

		move.l	(sp)+,d0
		rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: MainLoop
;	      Main program loop
;

MainLoop:
		jsr	ReadJoypads	; Read Joypad 1 and 2
		jsr	ParseInput	; Update Objects
		jsr	wait		; Small delay
		
		bra	MainLoop
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: ReadJoypads
;	      Read both joypads and update state variables.
;
; Store a bitmask of the current state of the joysticks in joy1cur
; and joy2cur. The variables joy1edge and joy2edge stores a state
; bitmap of new key 'down' events (never 'up' events) since the last time
; ReadJoypads was called.
;
; The code below may be altered by removing two AND instructions so that
; joy1edge and joy2edge contain a bitmap of keys that have changed (not
; pressed). If desired, this data could be compared to joy1cur and joy2cur
; to determine the actual button state.

ReadJoypads:
		movem.l	d0-d2/a0,-(sp)

		lea	JOYSTICK,a0

		move.l	#$f0fffffc,d1		; d1 = Joypad data mask
		moveq.l	#-1,d2		 	; d2 = Cumulative joypad reading

		move.w	#$81fe,(a0)
		move.l	(a0),d0		 	; Read joypad, pause button, A button
		or.l	d1,d0			; Mask off unused bits
		ror.l	#4,d0
		and.l	d0,d2			; d2 = xxAPxxxx RLDUxxxx xxxxxxxx xxxxxxxx
		move.w	#$81fd,(a0)
		move.l	(a0),d0			; Read *741 keys, B button
		or.l	d1,d0			; Mask off unused bits
		ror.l	#8,d0
		and.l	d0,d2			; d2 = xxAPxxBx RLDU741* xxxxxxxx xxxxxxxx
		move.w	#$81fb,(a0)
		move.l	(a0),d0			; Read 2580 keys, C button
		or.l	d1,d0			; Mask off unused bits
		rol.l	#6,d0
		rol.l	#6,d0
		and.l	d0,d2			; d2 = xxAPxxBx RLDU741* xxCxxxxx 2580xxxx
		move.w	#$81f7,(a0)
		move.l	(a0),d0			; Read 369# keys, Option button
		or.l	d1,d0			; Mask off unused bits
		rol.l	#8,d0
		and.l	d0,d2			; d2 = xxAPxxBx RLDU741* xxCxxxOx 2580369# <== inputs active low

		moveq.l	#-1,d1
		eor.l	d2,d1			; d1 = xxAPxxBx RLDU741* xxCxxxOx 2580369# <== now inputs active high

		move.l	joy1cur,d0		; old joycur needed for determining the new joyedge
		move.l	d1,joy1cur		; Current joypad reading stored into joycur
		eor.l	d1,d0

		and.l	d1,d0			; IF DESIRED (AS DOCUMENTED ABOVE)
						; REMOVE THIS AND
		
		move.l	d0,joy1edge		;joypad, buttons, keys that were just pressed

;scan for player 2
		move.l	#$0ffffff3,d1		; d1 = Joypad data mask
		moveq.l	#-1,d2			; d2 = Cumulative joypad reading

		move.w	#$817f,(a0)
		move.l	(a0),d0			; Read joypad, pause button, A button
		or.l	d1,d0			; Mask off unused bits
		rol.b	#2,d0			; note the size of rol
		ror.l	#8,d0
		and.l	d0,d2			; d2 = xxAPxxxx RLDUxxxx xxxxxxxx xxxxxxxx
		move.w	#$81bf,(a0)
		move.l	(a0),d0			; Read *741 keys, B button
		or.l	d1,d0			; Mask off unused bits
		rol.b	#2,d0			; note the size of rol
		ror.l	#8,d0
		ror.l	#4,d0
		and.l	d0,d2			; d2 = xxAPxxBx RLDU741* xxxxxxxx xxxxxxxx
		move.w	#$81df,(a0)
		move.l	(a0),d0			; Read 2580 keys, C button
		or.l	d1,d0			; Mask off unused bits
		rol.b	#2,d0			; note the size of rol
		rol.l	#8,d0
		and.l	d0,d2			; d2 = xxAPxxBx RLDU741* xxCxxxxx 2580xxxx
		move.w	#$81ef,(a0)
		move.l	(a0),d0			; Read 369# keys, Option button
		or.l	d1,d0			; Mask off unused bits
		rol.b	#2,d0			; note the size of rol
		rol.l	#4,d0
		and.l	d0,d2			; d2 = xxAPxxBx RLDU741* xxCxxxOx 2580369# <== inputs active low

		moveq.l	#-1,d1
		eor.l	d2,d1			; d1 = xxAPxxBx RLDU741* xxCxxxOx 2580369# <== now inputs active high

		move.l	joy2cur,d0		; old joycur needed for determining the new joyedge
		move.l	d1,joy2cur		; Current joypad reading stored into joycur
		eor.l	d1,d0

		and.l	d1,d0			; IF DESIRED (AS DOCUMENTED ABOVE)
						; REMOVE THIS AND

		move.l	d0,joy2edge		;joypad, buttons, keys that were just pressed

		movem.l	(sp)+,d0-d2/a0
		rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: ParseInput
;	      Use joystick inputs to update objects
;

ParseInput:
		movem.l	d0-d1/a0-a1,-(sp)

		lea	curs1_x,a1
		move.l	joy1edge,d0
ck_up:
		btst.l	#JOY_UP,d0
		beq.b	ck_down
		sub.w	#16,2(a1)		; move cursor UP 1 pixel
		bra.b	ck_left
ck_down:
		btst.l	#JOY_DOWN,d0
		beq.b	ck_left
		add.w	#16,2(a1)		; move cursor DOWN 1 pixel
ck_left:
		btst.l	#JOY_LEFT,d0
		beq.b	ck_right
		sub.w	#9,(a1)			; move cursor LEFT 1 pixel
		bra	ck_firebuts
ck_right:
		btst.l	#JOY_RIGHT,d0
		beq.b	ck_joy_2player
		add.w	#9,(a1)			; move cursor RIGHT 1 pixel

ck_joy_2player:
		lea	curs2_x,a0		; did we just do 2 or 1?
		cmpa.l	a0,a1
		beq.b	ck_firebuts

		lea	curs2_x,a1
		move.l	joy2edge,d0		; necessary to perform following modulo 32 BTST
		bra	ck_up

;  Evaluate each fire button status and execute code

ck_firebuts:
		lea	fire1_data,a1
		move.l	joy1cur,d0
ck_fireA:
		btst.l	#FIRE_A,d0
		beq.b	ck_fireB
		move.l	#numA,(a1)	; display the letter 'A'
ck_fireB:
		btst.l	#FIRE_B,d0
		beq.b	ck_fireC
		move.l	#numB,(a1)	; display the letter 'B'
ck_fireC:
		btst.l	#FIRE_C,d0
		beq.b	ck_Option
		move.l	#numC,(a1)	; display the letter 'C'
ck_Option:
		btst.l	#OPTION,d0
		beq.b	ck_Pause
		move.l	#Option,(a1)	; display the letter 'O'
ck_Pause:
		btst.l	#PAUSE,d0
		beq.b	fire_done
		move.l	#Pause,(a1)	; display the letter 'P'
fire_done:
		and.l	#ANY_FIRE,d0
		bne	ck_fire_2player

; No firebuttons were pressed

		move.l	#dash,(a1)	; display a '-'

ck_fire_2player:
		lea	fire2_data,a0	; did we just do Pad 1 or 2?
		cmpa.l	a0,a1
		beq.b	ck_keypad

		lea	fire2_data,a1
		move.l	joy2cur,d0	; necessary to perform following modulo 32 BTST
		bra	ck_fireA

;  Evaluate each 12-key button from the keypad and execute
;  code independent to each button.
ck_keypad:
		lea	key1_data,a1
		move.l	joy1cur,d0		; necessary to perform following modulo 32 BTST
ck_key1:
		btst.l	#KEY_1, d0
		beq.b	ck_key2
		move.l	#num1,(a1)	; display the number '1'
ck_key2:
		btst.l	#KEY_2,d0
		beq.b	ck_key3
		move.l	#num2,(a1)	; display the number '2'
ck_key3:
		btst.l	#KEY_3,d0
		beq.b	ck_key4
		move.l	#num3,(a1)	; display the number '3'
ck_key4:
		btst.l	#KEY_4,d0
		beq.b	ck_key5
		move.l	#num4,(a1)	; display the number '4'
ck_key5:
		btst.l	#KEY_5,d0
		beq.b	ck_key6
		move.l	#num5,(a1)	; display the number '5'
ck_key6:
		btst.l	#KEY_6,d0
		beq.b	ck_key7
		move.l	#num6,(a1)	; display the number '6'
ck_key7:
		btst.l	#KEY_7,d0
		beq.b	ck_key8
		move.l	#num7,(a1)	; display the number '7'
ck_key8:
		btst.l	#KEY_8,d0
		beq.b	ck_key9
		move.l	#num8,(a1)	; display the number '8'
ck_key9:
		btst.l	#KEY_9,d0
		beq.b	ck_keyS
		move.l	#num9,(a1)	; display the number '9'
ck_keyS:
		btst.l	#KEY_STAR,d0
		beq.b	ck_key0
		move.l	#numS,(a1)	; display a '*'
ck_key0:
		btst.l	#KEY_0,d0
		beq.b	ck_keyH
		move.l	#num0,(a1)	; display the number '0'
ck_keyH:
		btst.l	#KEY_HASH,d0
		beq.b	keypad_done
		move.l	#numH,(a1)	; display a '#'
keypad_done:
		and.l	#ANY_KEY,d0
		bne	ck_key_2player
;----------------------------------------
; No buttons on the keypad were pressed
		move.l	#dash,(a1)	; display a '-'

ck_key_2player:
		lea	key2_data,a0	; did we just do pad 1 or 2?
		cmpa.l	a0,a1
		beq.b	hi_end

		lea	key2_data,a1
		move.l	joy2cur,d0	; necessary to perform following modulo 32 BTST
		bra	ck_key1
hi_end:				; handle input end
		movem.l	(sp)+,d0-d1/a0-a1
		rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: wait
;	      Wait until 8 frames have passed
;

wait:
		move.l	d0,-(sp)
.loop:
		move.w	frame_cnt,d0
		andi.w	#$7,d0
		bne	.loop

		move.l	(sp)+,d0
		rts


;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Uninitialized Data!!!
;;;;;;;;;;;;;;;;;;;;;;;;;;

		.bss

joy1edge:	.ds.l		1
joy1cur:	.ds.l		1
joy2edge:	.ds.l		1
joy2cur:	.ds.l		1

;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Preinitialized Data!!!
;;;;;;;;;;;;;;;;;;;;;;;;;;

	.data
	.phrase

; Palette Data

mypal:
	dc.w	$0000,$01FF,$02FF,$03FF,$04FF,$05FF,$06FF,$07FF,$08FF,$09FF,$0AFF,$0BFF,$0CFF,$0DFF,$0EFF,$0FFF
	dc.w	$10FF,$11FF,$12FF,$13FF,$14FF,$15FF,$16FF,$17FF,$18FF,$19FF,$1AFF,$1BFF,$1CFF,$1DFF,$1EFF,$1FFF
	dc.w	$20FF,$21FF,$22FF,$23FF,$24FF,$25FF,$26FF,$27FF,$28FF,$29FF,$2AFF,$2BFF,$2CFF,$2DFF,$2EFF,$2FFF
	dc.w	$30FF,$31FF,$32FF,$33FF,$34FF,$35FF,$36FF,$37FF,$38FF,$39FF,$3AFF,$3BFF,$3CFF,$3DFF,$3EFF,$3FFF
	dc.w	$40FF,$41FF,$42FF,$43FF,$44FF,$45FF,$46FF,$47FF,$48FF,$49FF,$4AFF,$4BFF,$4CFF,$4DFF,$4EFF,$4FFF
	dc.w	$50FF,$51FF,$52FF,$53FF,$54FF,$55FF,$56FF,$57FF,$58FF,$59FF,$5AFF,$5BFF,$5CFF,$5DFF,$5EFF,$5FFF
	dc.w	$60FF,$61FF,$62FF,$63FF,$64FF,$65FF,$66FF,$67FF,$68FF,$69FF,$6AFF,$6BFF,$6CFF,$6DFF,$6EFF,$6FFF
	dc.w	$70FF,$71FF,$72FF,$73FF,$74FF,$75FF,$76FF,$77FF,$78FF,$79FF,$7AFF,$7BFF,$7CFF,$7DFF,$7EFF,$7FFF
	dc.w	$80FF,$81FF,$82FF,$83FF,$84FF,$85FF,$86FF,$87FF,$88FF,$89FF,$8AFF,$8BFF,$8CFF,$8DFF,$8EFF,$8FFF
	dc.w	$90FF,$91FF,$92FF,$93FF,$94FF,$95FF,$96FF,$97FF,$98FF,$99FF,$9AFF,$9BFF,$9CFF,$9DFF,$9EFF,$9FFF
	dc.w	$A0FF,$A1FF,$A2FF,$A3FF,$A4FF,$A5FF,$A6FF,$A7FF,$A8FF,$A9FF,$AAFF,$ABFF,$ACFF,$ADFF,$AEFF,$AFFF
	dc.w	$B0FF,$B1FF,$B2FF,$B3FF,$B4FF,$B5FF,$B6FF,$B7FF,$B8FF,$B9FF,$BAFF,$BBFF,$BCFF,$BDFF,$BEFF,$BFFF
	dc.w	$C0FF,$C1FF,$C2FF,$C3FF,$C4FF,$C5FF,$C6FF,$C7FF,$C8FF,$C9FF,$CAFF,$CBFF,$CCFF,$CDFF,$CEFF,$CFFF
	dc.w	$D0FF,$D1FF,$D2FF,$D3FF,$D4FF,$D5FF,$D6FF,$D7FF,$D8FF,$D9FF,$DAFF,$DBFF,$DCFF,$DDFF,$DEFF,$DFFF
	dc.w	$E0FF,$E1FF,$E2FF,$E3FF,$E4FF,$E5FF,$E6FF,$E7FF,$E8FF,$E9FF,$EAFF,$EBFF,$ECFF,$EDFF,$EEFF,$EFFF
	dc.w	$F0FF,$F1FF,$F2FF,$F3FF,$F4FF,$F5FF,$F6FF,$F7FF,$F8FF,$F9FF,$FAFF,$FBFF,$FCFF,$FDFF,$FEFF,$FFFF

	.data
	.phrase

;  Cursor and Font graphic data

cursor_data:
	dc.b	$78,$78,$78,$78,$78,$78,$78,$78,$78,$78,$78,$78,$78,$78,$78,$78
	dc.b	$78,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$78
	dc.b	$78,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$78
	dc.b	$78,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$78
	dc.b	$78,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$78
	dc.b	$78,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$78
	dc.b	$78,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$78
	dc.b	$78,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$78
	dc.b	$78,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$78
	dc.b	$78,$78,$78,$78,$78,$78,$78,$78,$78,$78,$78,$78,$78,$78,$78,$78

	.phrase
num0:
	dc.b	$00,$00,$78,$78,$78,$00,$00,$00
	dc.b	$00,$78,$00,$00,$00,$78,$00,$00
	dc.b	$78,$00,$00,$00,$00,$00,$78,$00
	dc.b	$78,$00,$00,$00,$00,$00,$78,$00
	dc.b	$78,$00,$00,$00,$00,$00,$78,$00
	dc.b	$00,$78,$00,$00,$00,$78,$00,$00
	dc.b	$00,$00,$78,$78,$78,$00,$00,$00

	.phrase
num1:
	dc.b	$00,$00,$00,$78,$00,$00,$00,$00
	dc.b	$00,$00,$78,$78,$00,$00,$00,$00
	dc.b	$00,$00,$00,$78,$00,$00,$00,$00
	dc.b	$00,$00,$00,$78,$00,$00,$00,$00
	dc.b	$00,$00,$00,$78,$00,$00,$00,$00
	dc.b	$00,$00,$00,$78,$00,$00,$00,$00
	dc.b	$00,$00,$78,$78,$78,$00,$00,$00

	.phrase
num2:
	dc.b	$00,$78,$78,$78,$78,$78,$00,$00
	dc.b	$78,$00,$00,$00,$00,$00,$78,$00
	dc.b	$00,$00,$00,$00,$00,$00,$78,$00
	dc.b	$00,$00,$78,$78,$78,$78,$00,$00
	dc.b	$00,$78,$00,$00,$00,$00,$00,$00
	dc.b	$78,$00,$00,$00,$00,$00,$00,$00
	dc.b	$78,$78,$78,$78,$78,$78,$78,$00

	.phrase
num3:
	dc.b	$00,$78,$78,$78,$78,$78,$00,$00
	dc.b	$78,$00,$00,$00,$00,$00,$78,$00
	dc.b	$00,$00,$00,$00,$00,$00,$78,$00
	dc.b	$00,$00,$00,$78,$78,$78,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$78,$00
	dc.b	$78,$00,$00,$00,$00,$00,$78,$00
	dc.b	$00,$78,$78,$78,$78,$78,$00,$00

	.phrase
num4:
	dc.b	$78,$00,$00,$00,$00,$00,$78,$00
	dc.b	$78,$00,$00,$00,$00,$00,$78,$00
	dc.b	$78,$00,$00,$00,$00,$00,$78,$00
	dc.b	$78,$78,$78,$78,$78,$78,$78,$00
	dc.b	$00,$00,$00,$00,$00,$00,$78,$00
	dc.b	$00,$00,$00,$00,$00,$00,$78,$00
	dc.b	$00,$00,$00,$00,$00,$00,$78,$00

	.phrase
num5:
	dc.b	$78,$78,$78,$78,$78,$78,$78,$00
	dc.b	$78,$00,$00,$00,$00,$00,$00,$00
	dc.b	$78,$00,$00,$00,$00,$00,$00,$00
	dc.b	$78,$78,$78,$78,$78,$78,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$78,$00
	dc.b	$00,$00,$00,$00,$00,$00,$78,$00
	dc.b	$78,$78,$78,$78,$78,$78,$00,$00

	.phrase
num6:
	dc.b	$00,$78,$78,$78,$78,$78,$00,$00
	dc.b	$78,$00,$00,$00,$00,$00,$00,$00
	dc.b	$78,$00,$00,$00,$00,$00,$00,$00
	dc.b	$78,$78,$78,$78,$78,$78,$00,$00
	dc.b	$78,$00,$00,$00,$00,$00,$78,$00
	dc.b	$78,$00,$00,$00,$00,$00,$78,$00
	dc.b	$00,$78,$78,$78,$78,$78,$00,$00

	.phrase
num7:
	dc.b	$78,$78,$78,$78,$78,$78,$78,$00
	dc.b	$00,$00,$00,$00,$00,$00,$78,$00
	dc.b	$00,$00,$00,$00,$00,$78,$00,$00
	dc.b	$00,$00,$00,$00,$78,$00,$00,$00
	dc.b	$00,$00,$00,$78,$00,$00,$00,$00
	dc.b	$00,$00,$78,$00,$00,$00,$00,$00
	dc.b	$00,$78,$00,$00,$00,$00,$00,$00

	.phrase
num8:
	dc.b	$00,$78,$78,$78,$78,$78,$00,$00
	dc.b	$78,$00,$00,$00,$00,$00,$78,$00
	dc.b	$78,$00,$00,$00,$00,$00,$78,$00
	dc.b	$00,$78,$78,$78,$78,$78,$00,$00
	dc.b	$78,$00,$00,$00,$00,$00,$78,$00
	dc.b	$78,$00,$00,$00,$00,$00,$78,$00
	dc.b	$00,$78,$78,$78,$78,$78,$00,$00

	.phrase
num9:
	dc.b	$00,$78,$78,$78,$78,$78,$00,$00
	dc.b	$78,$00,$00,$00,$00,$00,$78,$00
	dc.b	$78,$00,$00,$00,$00,$00,$78,$00
	dc.b	$00,$78,$78,$78,$78,$78,$78,$00
	dc.b	$00,$00,$00,$00,$00,$00,$78,$00
	dc.b	$00,$00,$00,$00,$00,$00,$78,$00
	dc.b	$00,$00,$78,$78,$78,$78,$00,$00

	.phrase
numA:
	dc.b	$00,$78,$78,$78,$78,$78,$00,$00
	dc.b	$78,$00,$00,$00,$00,$00,$78,$00
	dc.b	$78,$00,$00,$00,$00,$00,$78,$00
	dc.b	$78,$78,$78,$78,$78,$78,$78,$00
	dc.b	$78,$00,$00,$00,$00,$00,$78,$00
	dc.b	$78,$00,$00,$00,$00,$00,$78,$00
	dc.b	$78,$00,$00,$00,$00,$00,$78,$00

	.phrase
numB:
	dc.b	$78,$78,$78,$78,$78,$78,$00,$00
	dc.b	$78,$00,$00,$00,$00,$00,$78,$00
	dc.b	$78,$00,$00,$00,$00,$00,$78,$00
	dc.b	$78,$78,$78,$78,$78,$78,$00,$00
	dc.b	$78,$00,$00,$00,$00,$00,$78,$00
	dc.b	$78,$00,$00,$00,$00,$00,$78,$00
	dc.b	$78,$78,$78,$78,$78,$78,$00,$00

	.phrase
numC:
	dc.b	$00,$78,$78,$78,$78,$78,$78,$00
	dc.b	$78,$00,$00,$00,$00,$00,$00,$00
	dc.b	$78,$00,$00,$00,$00,$00,$00,$00
	dc.b	$78,$00,$00,$00,$00,$00,$00,$00
	dc.b	$78,$00,$00,$00,$00,$00,$00,$00
	dc.b	$78,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$78,$78,$78,$78,$78,$78,$00

	.phrase
Option:
	dc.b	$00,$78,$78,$78,$78,$78,$00,$00
	dc.b	$78,$00,$00,$00,$00,$00,$78,$00
	dc.b	$78,$00,$00,$00,$00,$00,$78,$00
	dc.b	$78,$00,$00,$00,$00,$00,$78,$00
	dc.b	$78,$00,$00,$00,$00,$00,$78,$00
	dc.b	$78,$00,$00,$00,$00,$00,$78,$00
	dc.b	$00,$78,$78,$78,$78,$78,$00,$00

	.phrase
Pause:
	dc.b	$78,$78,$78,$78,$78,$78,$00,$00
	dc.b	$78,$00,$00,$00,$00,$00,$78,$00
	dc.b	$78,$00,$00,$00,$00,$00,$78,$00
	dc.b	$78,$78,$78,$78,$78,$78,$00,$00
	dc.b	$78,$00,$00,$00,$00,$00,$00,$00
	dc.b	$78,$00,$00,$00,$00,$00,$00,$00
	dc.b	$78,$00,$00,$00,$00,$00,$00,$00

	.phrase
numS:
	dc.b	$78,$00,$00,$78,$00,$00,$78,$00
	dc.b	$00,$78,$00,$78,$00,$78,$00,$00
	dc.b	$00,$00,$78,$78,$78,$00,$00,$00
	dc.b	$78,$78,$78,$78,$78,$78,$78,$00
	dc.b	$00,$00,$78,$78,$78,$00,$00,$00
	dc.b	$00,$78,$00,$78,$00,$78,$00,$00
	dc.b	$78,$00,$00,$78,$00,$00,$78,$00

	.phrase
numH:
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$78,$00,$00,$78,$00,$00,$00
	dc.b	$78,$78,$78,$78,$78,$78,$00,$00
	dc.b	$00,$78,$00,$00,$78,$00,$00,$00
	dc.b	$78,$78,$78,$78,$78,$78,$00,$00
	dc.b	$00,$78,$00,$00,$78,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00

	.phrase
dash:
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$78,$78,$78,$78,$78,$78,$78,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00

	.end


