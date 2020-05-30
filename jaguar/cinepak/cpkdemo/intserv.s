
;******************************************************************************
; (C) Copyright 1992-1994, SuperMac Technology, Inc.
; All rights reserved.
;
; This source code and any compilation or derivative thereof is the sole
; property of SuperMac Technology, Inc. and is provided pursuant to a
; Software License Agreement.  This code is the proprietary information
; of SuperMac Technology and is confidential in nature.  Its use and
; dissemination by any party other than SuperMac Technology are strictly
; limited by the confidential information provisions of the Agreement
; referenced above.
;
; Revision History:
; 04/08/94  14:01:05  jpe
; Initial revision.
;******************************************************************************

		.include	'jaguar.inc'
		.include	'memory.inc'
		.include	'player.inc'

		.globl		IntInit
		.globl		runframes

		.extern		a_vde
		.extern		Lister
		.extern 	time
		.extern		timeIncr
		.extern		semaphore

		.extern		scrbuf
		.extern		data_off
		.extern		bmp_highl
		.extern		bmp_lowl
		.extern		movilist
		.extern		listcopy
		.extern		x_pos
		.extern		y_pos
		.extern		h_scale
		.extern 	v_scale

		.extern		GCHANGEOLP
		.extern		ticks

IntInit:
		clr.l	data_off		; Some initialization
		move.l	#(SCREEN_BASE+$8),scrbuf

		clr.l	runframes
wait4blank:
		move.l	ticks,d1		; Delay until VBLANK
		cmp.l	ticks,d1
		beq	wait4blank

		move.w	#2,INT1	       		; Enable GPU	
		move.l	#IntSvce,USER0 		; Set up the vector

		move.l	#movilist,d0		; Store OLP to set
		swap	d0
		move.l	d0,GCHANGEOLP		
		move.l	#RISCGO|FORCEINT0,G_CTRL	; Go!

		rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: IntSvce
;            Service 68k Video/GPU Interrupts
;

IntSvce:
		move.l	a0,-(sp)

; GPU interrupt: Set semaphore to wake up main program.

		lea	semaphore,a0
		move.w	#$ffff,(a0)    		; Set semaphore

		move.w	#$202,INT1
		move.w	#$0,INT2

		move.l	(sp)+,a0
		rte

		.bss
		.long

runframes:	.ds.l	1			; # of frames since start

	        .end
