;
; Jaguar C library run time startup code
;
; Copyright 1994 Atari Corporation.
; All rights reserved.
;
;
; Functions defined here:
; void abort(void):
;	does an illegal instruction so rdbjag gets control
;
; Functions called:
; main(int argc, char **argv, char **envp): obvious
; _init_alloc(void): initialize memory allocator
; VIDinit(void): initialize video
;
; Variables:
; OLPstore: storage for packed object list
; at most 80 phrases worth of objects are
; supported

	.include	"jaguar.inc"

	.extern	_VIDinit
	.extern	__init_alloc
	.extern	__init_JOY
	.extern	_main

	.text
start::
	move.l	#$00070007,G_END		;don't need to swap for GPU
	move.w	#$FFFF,VI			;temporarily disable video interrupts
	move.w	#$0100,JOYSTICK			;set bit 8 to cancel mute
	move.l	#$1ffff0,sp			;set stack to top of DRAM

	suba.l	a6,a6				; initialize frame pointer for debugger

	move.w	#$6C1,-(sp)			; assume 16 bit CRY mode
	jsr	_VIDinit			; initialize the video
	addq.w	#2,sp

	jsr	__init_alloc			; initialize the memory allocator
	jsr	__init_JOY			; initialize the joypad library

	move.l	#0,__timestamp
	move.l	#-1,PIT0			; initialize the timing library

	pea	envp
	pea	argv
	move.w	#1,-(sp)
	jsr	_main
	add.l	#10,sp

; end of program
	illegal

___main::
	rts

_abort::
	link	a6,#0
	illegal
	unlk	a6
	rts

	.bss
_OLPstore::
	ds.l	160
_OList::
	ds.l	1
__timestamp::
	ds.l	1

	.data
argv:
	dc.l	arg0
envp:
	dc.l	0
arg0:
	dc.b	'Jaguar', 0
	.even
