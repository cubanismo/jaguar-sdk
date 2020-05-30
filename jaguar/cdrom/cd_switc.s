;**************************************************************************
; (C)1993 ATARI CORP.       SECRET & CONFIDENTIAL       ALL RIGHTS RESERVED
;
;
;                                cd_switch.s
;
;	This code shows how to run the Jaguar CD subsystem to play audio thru Jerry
;
;       A call to show how to use CD_switch has been added
;       1. Plays a short piece of an Audio CD, then switches background
;          color to light green
;       2. Then stops the CD switches to black background as the CD waits
;          for the user to switch CDs
;       3. After the lid is closed spins up again bagground swithces to white
;          and the circle starts over with step 1
;
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

        move.l  #$14,SMODE      ; 

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

        move.l  #$80000200,d0   ; Start play from 00:02:00

        jsr     CD_read         ;

        jsr     CD_ack          ; This is needed so that the response
                                ; is not mistaken for the response from
                                ; the next call

; Now that the disc is playing we want to return when the CD lid has opened
; and then closed!

; First waste some time, so that we can hear the first some seconds of the
; stuff we play

kil_time:
	move.w	#60,d1
odelay:                         ; outer delay loop
	move.w	#$ffff,d0
delay:                          ; delay loop
	dbra	d0,delay
	dbra	d1,odelay

        move.w  #$1234,BG       ; set funky background color

        move.w  #1,d0
        jsr     CD_stop         ; and stop cd to indicate to switch
        move.w  #0,BG           ; set background to black to show we
                                ; did stop

        jsr     CD_switch       ; call BIOS and wait for switch
                                ; if you dont have a lid on your CD
                                ; this will hang ! (When did you
                                ; upgrade you dev system last time ?)

        move.w  #-1,BG          ; set background to white

        jmp     Play_it         ; start over playing next CD

        illegal


