;**************************************************************************
; (C)1994 ATARI CORP.       SECRET & CONFIDENTIAL       ALL RIGHTS RESERVED
;
;	This code shows how to get data from the CD and put it into memory
;
;
;                                REVISION HISTORY
;
; REV.  DATE       BY            DESCRIPTION OF EDIT
; """"  """"       ""            """""""""""""""""""
; 1.00  20 Apr 94  LJT		 First Release
; 1.01  11 Aug 95  NBK           GPU may only be stopped by itself fixed
;****************************************************************************

; **********************************************************************
; Due to a failure of imagination this sample code simply reads some data
; from a bit inside of a test pattern on the CD.
; With any luck a new! better! more interesting! sample will be done soon
; The CD this code expects that looks like this
; frame #		Data description
;   0			   A Big block of ASCII A's with cr/lf
;  505			   A Block of THE PATTERN
; 1278			   A Big block of ASCII B's with cr/lf
; 1783			   A Block of THE PATTERN
; 2556			   A Big block of ASCII C's with cr/lf
; 3061			   A Block of THE PATTERN
; 3834			   A Big block of ASCII D's with cr/lf
; 4339			   A Block of THE PATTERN
; 5112			   A Big block of ASCII E's with cr/lf
; 5617			   A Block of THE PATTERN
; THE PATTERN consists of 5 longs
; $00000000
; $FFFFFFFF
; $00000000
; count
; ~count
; This repeats with count incremented. Count starts at 0
; The following code reads the first incarnation of THE PATTERN into memory
; at location BUFF_START and fills until BUFF_END.
;
; The frame numbers start at time code 00:00:00. The data follows the 2
; second pause. The beginning of THE PATTERN is at frame 505+150=655 or
; time code 00:08:55. To make sure that we are inside of the pattern the
; read starts one second later!!!
;
; The lables retry and one_more_time point to the appropriate entry points for
; retries and new reads
;

; Since nothing is actually done with the data I have no idea why I went
; into all this detail!. You can use this code to read ANY data off of
; any disc as long as the disc has a first session that is at least 1
; minute and 8 seconds long.

        .include 'jaguar.inc'
	.include 'cd.inc'	; CD-related equates

	.extern	end		; needed for GPU program load by DB
	.extern GPU_done
	.extern GPU_state
	.extern	SETUP
                                ; These define the main DRAM CD data buf area
	.extern	GPUSTART
	.extern	GPUEND

	.extern	SETUP
	.extern	CDREADER
	

BUFF_START	equ	$080000
BUFF_END	equ	$180000

	move.l	#$70007,G_END	;Data organisation register

	move.l	#$1ff000,A7	; set stack pointer up high

Start_CD:                       ; Beginning of CD_related code

;				*****************************************
;				*      Clear our own memory range	*
;				*****************************************
Clearmem:
 	move.l	#BUFF_START,a0	; our lowest DRAM address, see 'CD_inits.inc'
 	move.l	#$1fe000,d1	; our highest DRAM address
Clermem1:			; clear CD variables and data buffer area
	move.l	#0,(a0)+
	move.l	a0,d0	
	cmp.l	d0,d1
	bne	Clermem1

; BUG: The GPU may only be stoppped by itself, not by 68k
;	move.l	#0,G_CTRL	;Stop the GPU
	move.l	#0,$f02100	;GPU Flags register

	jsr	CD_setup
Do_mode:
	move.w	#3,d0		; Go to double speed, CDROM mode
	jsr	CD_mode

	move.w	#1,d0		; Wait till stop complete
	jsr	CD_stop

; Load, & initialize host GPU program

Do_GPU:
	move.l	#GPUSTART,a0
	move.l	#GPUEND,a1
	move.l	a0,d1
	move.l	a1,d0
	sub.l	d1,d0		; Size in bytes
	asr.l	#2,d0
	move.l	#G_RAM,a1
xferloop:
	move.l	(a0)+,(a1)+
        dbra    d0,xferloop

; Set up BIOS to read data

; This MUST be done after the GPU program is loaded so that the
; vectors installed by the BIOS are not overwritten!!

	move.l	#CDREADER,a0
	jsr	CD_init

GPU_init:
	move.l	#SETUP,G_PC		; Set GPU PC to start of code in SRAM

GPU_go:
	move.l	#1,G_CTRL	; start GPU

one_more_time:

; Seek to a good distance AWAY from where we want to go!!!!!
; Don't actually send data

	move.l	#$80010737,d0	;Start play from 01:07:55 => 01:07:37
	jsr	CD_read
	jsr	CD_ack
retry:
	jsr	CD_uread

; Start up the CD

go:
	move.l	#$00000937,d0	;Start play from 00:09:55 =>$000937
	move.l	#BUFF_START,a0
	move.l	#BUFF_END,a1
	jsr	CD_read

; Now we check to see if the loaded data has reached the top.
; The exact return from CD_ptr for the current location cannot
; be counted on. The data will go AT LEAST to the stop position
; For this reason leave some padding at the end of the buffer.

check:
	jsr	CD_ptr
	cmp.l	#BUFF_END,a0
	ble	check

	move.w	#1,d0		; Wait for stop
	jsr	CD_stop

; At this point a1 contains the error flag, if A1=0 => no error
; If A1 !=0 it is the APPROXIMATE location of the error

	illegal

