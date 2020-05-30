; This is a simple sample program to play a tune on the synth code.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.include	'jaguar.inc'

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.extern		DSPSTART
	.extern		DSPEND
	.extern		DSP_START

	.extern		SHUTDOWN
	.extern		TMR1_ISR

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	HIBIT		equ		$80000000

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	move.l	#$00070007,D_END	; Set GOOD mode
	move.l	#$1ffffc,sp		; Set 68000 stack pointer to end of DRAM.

; At this point we assume that the DSP is turned off!
; First we copy the Jerry code into Jerry
; for bigger blocks you would use the Blitter, for it is SO MUCH faster
; than this copy loop (but for blitting you have to make sure that the
; transfered block will be at a phrase boundary)

	move.l	#D_RAM,a1
	move.l	#DSPSTART,a0
	move.l	a0,d0
	move.l	#DSPEND,d1
	sub.l	d0,d1
	asr.l	#2,d1
translop:
	move.l	(a0)+,(a1)+
	dbra	d1,translop

; Make sure the DACs are silent!

	move.l	#0,R_DAC
	move.l	#0,L_DAC

; Set up the I2S mode and clock
	move.l	#19,SCLK
	move.l	#$15,SMODE

; Enable sound (mute bit)

	move.w	#$100,JOYSTICK

; Now it should be safe to turn on the DSP

	move.l	#DSP_START,D_PC	; Set up D_PC

	move.l	#$1,D_CTRL	; LET 'R RIP

	illegal

; THIS IS NEW MAGIC TO CAUSE THE DSP TO STOP
; AT THE NEXT SAMPLE INTERRUPT

	move.l	#SHUTDOWN,d0
	and.l	#$ffff,d0
	or.l	#$981d0000,d0
	move.l	d0,$f1b010

	illegal

; ************************ END OF MAIN CODE ***********************

