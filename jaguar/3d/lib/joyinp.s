	.include	'jaguar.inc'

	.extern	start

	.globl __PAD1
	.globl __PAD2

	.text

;***********************************************************************************************
__PAD1:
	move.l	d2,-(sp)

;must set bit 8 ($100) in JOYSTICK to cancel mute
	move.l	#$f0fffffc,d1		; d1 = Joypad data mask
	moveq.l	#-1,d2			; d2 = Cumulative joypad reading

	move.w	#$81fe,JOYSTICK
	move.l	JOYSTICK,d0			; Read joypad, pause button, A button
	or.l		d1,d0			; Mask off unused bits
	ror.l	#4,d0
	and.l	d0,d2			; d2 = xxApxxxx RLDUxxxx xxxxxxxx xxxxxxxx
	move.w	#$81fd,JOYSTICK
	move.l	JOYSTICK,d0			; Read *741 keys, B button
	or.l		d1,d0			; Mask off unused bits
	ror.l	#8,d0
	and.l	d0,d2			; d2 = xxApxxBx RLDU741* xxxxxxxx xxxxxxxx
	move.w	#$81fb,JOYSTICK
	move.l	JOYSTICK,d0			; Read 2580 keys, C button
	or.l		d1,d0			; Mask off unused bits
	rol.l	#6,d0
	rol.l	#6,d0
	and.l	d0,d2			; d2 = xxApxxBx RLDU741* xxCxxxxx 2580xxxx
	move.w	#$81f7,JOYSTICK
	move.l	JOYSTICK,d0			; Read 369# keys, Option button
	or.l		d1,d0			; Mask off unused bits
	rol.l	#8,d0
	and.l	d0,d2			; d2 = xxAPxxBx RLDU741* xxCxxxOx 2580369#

	moveq.l	#-1,d1
	eor.l	d2,d1			; d1 = Inputs active high

	move.l	(sp)+,d2
	move.l	d1,d0
	rts

__PAD2:
;must set bit 8 ($100) in JOYSTICK to cancel mute
;read player 2 controller
	move.l	d2,-(sp)
	move.l	#$0FFFFFF3,d1		; d1 = Joypad data mask
	moveq.l	#-1,d2			; d2 = Cumulative joypad reading

	move.w	#$817f,JOYSTICK
	move.l	JOYSTICK,d0			; Read joypad, pause button, A button
	or.l		d1,d0			; Mask off unused bits
	rol.b	#2,d0			; this is different than readpad
	ror.l	#8,d0
	and.l	d0,d2			; d2 = xxApxxxx RLDUxxxx xxxxxxxx xxxxxxxx
	move.w	#$81bf,JOYSTICK
	move.l	JOYSTICK,d0			; Read *741 keys, B button
	or.l		d1,d0			; Mask off unused bits
	rol.b	#2,d0			; this is different than readpad
	ror.l	#8,d0
	ror.l	#4,d0			; this is different than readpad
	and.l	d0,d2			; d2 = xxApxxBx RLDU741* xxxxxxxx xxxxxxxx
	move.w	#$81df,JOYSTICK
	move.l	JOYSTICK,d0			; Read 2580 keys, C button
	or.l		d1,d0			; Mask off unused bits
	rol.b	#2,d0			; this is different than readpad
	rol.l	#8,d0
	and.l	d0,d2			; d2 = xxApxxBx RLDU741* xxCxxxxx 2580xxxx
	move.w	#$81ef,JOYSTICK
	move.l	JOYSTICK,d0			; Read 369# keys, Option button
	or.l		d1,d0			; Mask off unused bits
	rol.b	#2,d0			; this is different than readpad
	rol.l	#4,d0
	and.l	d0,d2			; d2 = xxAPxxBx RLDU741* xxCxxxOx 2580369#

	moveq.l	#-1,d1
	eor.l	d2,d1			; d1 = Inputs active high

	move.l	(sp)+,d2
	move.l	d1,d0			; C return values must go here
	rts

