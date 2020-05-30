;*======================================================================*
;*                TITLE:                  JOYPAD.S                      *
;*                Function:               RAPIER joypad input           *
;*                                                                      *
;*                Project #:              RAPIER                        *
;*                Programmer:             Rob Zdybel                    *
;*                                                                      *
;* COPYRIGHT 1993 Atari Computer Corporation                            *
;* UNAUTHORIZED REPRODUCTION, ADAPTATION, DISTRIBUTION,                 *
;* PERFORMANCE OR DISPLAY OF THIS COMPUTER PROGRAM OR                   *
;* THE ASSOCIATED AUDIOVISUAL WORK IS STRICTLY PROHIBITED.              *
;* ALL RIGHTS RESERVED.                                                 *
;*                                                                      *
;*======================================================================*

	.include	'jaguar.inc'

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	PUBLIC SYMBOLS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.globl	readpad
	.globl	pad_now
	.globl	pad_shot

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;	READPAD   Read the JAGUAR Joypad
;
;	Given:
;		Control
;
;	Returns:
;		PAD_NOW = Current reading of joypad (Asserted High)
;		PAD_SHOT = Edge-triggered One Shot of joypad
;
;	Register Usage:
;		All Registers Restored
;
;	Externals:
;		None
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.text
readpad:
	movem.l	d0-d2,-(sp)

	move.l	#$f0fffffc,d1		; d1 = Joypad data mask
	moveq.l	#-1,d2			; d2 = Cumulative joypad reading

	move.w	#$810e,JOYSTICK
	move.l	JOYSTICK,d0		; Read Stick and Pause/A
	
	or.l	d1,d0			; Mask off unused bits
	ror.l	#4,d0
	and.l	d0,d2			; d2 = xxApxxxx RLDUxxxx xxxxxxxx xxxxxxxx

	move.w	#$810d,JOYSTICK
	move.l	JOYSTICK,d0		; Read *741 and B


	or.l	d1,d0			; Mask off unused bits
	ror.l	#8,d0
	and.l	d0,d2			; d2 = xxApxxBx RLDU741* xxxxxxxx xxxxxxxx
	move.w	#$810b,JOYSTICK
	move.l	JOYSTICK,d0		; Read 2580 and C

	or.l	d1,d0			; Mask off unused bits
	rol.l	#6,d0
	rol.l	#6,d0
	and.l	d0,d2			; d2 = xxApxxBx RLDU741* xxCxxxxx 2580xxxx

	move.w	#$8107,JOYSTICK
	move.l	JOYSTICK,d0		; Read 369# and Option

	or.l	d1,d0			; Mask off unused bits
	rol.l	#8,d0
	and.l	d0,d2			; d2 = xxApxxBx RLDU741* xxCxxxox 2580369#

	moveq.l	#-1,d1
	eor.l	d2,d1			; d1 = Inputs active high

	move.l	pad_now,d0
	move.l	d1,pad_now		; PAD_NOW = Current joypad reading
	eor.l	d1,d0
	and.l	d1,d0
	move.l	d0,pad_shot		; PAD_SHOT = Oneshot joypad

	movem.l	(sp)+,d0-d2
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	VARIABLE STORAGE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.bss
	.phrase

pad_now:		; Current Joypad reading
	.ds.l	1	; xxApxxBx RLDU741* xxCxxxox 2580369#

pad_shot:		; OneShot Joypad reading
	.ds.l	1	; xxApxxBx RLDU741* xxCxxxox 2580369#
