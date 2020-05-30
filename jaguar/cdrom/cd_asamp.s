;**************************************************************************
; (C)1993 ATARI CORP.       SECRET & CONFIDENTIAL       ALL RIGHTS RESERVED
;
;
;                                cd_asamp.s
;
;	This code shows how to run the Jaguar CD subsystem to play audio thru Jerry

;                                REVISION HISTORY
;
; REV.  DATE       BY            DESCRIPTION OF EDIT
; """"  """"       ""            """""""""""""""""""
; 1.00  20 Apr 94  LJT		 First release
;****************************************************************************

        .include 'jaguar.inc'
	.include 'cd.inc'	; CD-related equates

	.extern	DSPSTART
	.extern	DSPEND

	.extern	JERI_B
	.extern	VOLUME

	move.l	#$70007,D_END

	jsr	CD_setup
Do_mode:
	move.w	#0,d0		; Go to single speed, Audio mode
	jsr	CD_mode

Do_DSP:
	move.l	#DSPSTART,a0
	move.l	#DSPEND,a1
	move.l	a0,d1
	move.l	a1,d0
	sub.l	d1,d0		; Size in bytes
	asr.l	#2,d0
	move.l	#D_RAM,a1
xferloop:
	move.l	(a0)+,(a1)+
        dbra    d0,xferloop

DSP_init:
	move.l	#JERI_B,D_PC	; Set DSP PC to start of SRAM
	move.l	#1,D_CTRL	; Set DSP GO bit to start running

; Set up external clock I2S mode
	move.l	#$14,SMODE

; Set up volume
	move.l	#$7fff,VOLUME

Jeri_on:
	move.w	#1,d0
	jsr	CD_jeri

; Set up 4x oversampling (See CD_osamp documentation)

	move.w	#2,d0
	jsr	CD_osamp

; Turn off mute
	move.w	#$100,JOYSTICK

; DSP's running.  Now PLAY!

Play_it:			

; This starts the disk but does not send data to RAM
; Play from 0 minutes; 2 seconds; 0 frames
; The data comes in via Jerry

	move.l	#$80000200,d0	;Start play from 00:02:00

	jsr	CD_read

	illegal

