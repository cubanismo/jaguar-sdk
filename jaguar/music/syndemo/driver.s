;----------------------------------------------------------------------------
; This is a simple sample program to play a tune on the synth code.
;
; MODULE: MUSIC DRIVER - DOES NOT HAVE TO BE EDITED!
;	  VERSION 1.1
;
;	COPYRIGHT 1992,1993,1994 Atari U.S. Corporation           	
;									
;       UNAUTHORIZED REPRODUCTION, ADAPTATION, DISTRIBUTION,
;       PERFORMANCE OR DISPLAY OF THIS COMPUTER PROGRAM OR
;       THE ASSOCIATED AUDIOVISUAL WORK IS STRICTLY PROHIBITED.
;       ALL RIGHTS RESERVED.                        			
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
; 	INCLUDE FILES
;----------------------------------------------------------------------------
	.include	'jaguar.inc'
	.include	'fulsyn.inc'
	.include	'synth.cnf'

;----------------------------------------------------------------------------
; 	EXTERNALS
;----------------------------------------------------------------------------

	.extern		SYN_COPY	; start of the synth
	.extern		TABS_COPY	; start of tables
	.extern		DSPORG		; start oF DSP RAM
	.extern		VOLUME		; MIDI volume
	.extern		UEBERVOLUME	; global volume
	.extern		patches		; Patch Data
	.extern		SCORE_ADD	; ptr to the music data
	.extern		PATCHLOC	; ptr to the patches
	.extern		scoretab	; Here's the music data
	.extern		SHUTDOWN
	.extern		TMR1_ISR

;----------------------------------------------------------------------------
; 	CODE SECTION
;----------------------------------------------------------------------------
	.text

_start::
	move.l	#$00070007,D_END	; Set GOOD mode

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; First we copy the Jerry code into Jerry

	move.l	#SYN_COPY,a0
	move.l	(a0)+,a1		; Get load address
	move.l	(a0)+,d1		; and length
	asr.l	#2,d1
	subq.l	#1,d1
.1:
	move.l	(a0)+,(a1)+
	dbra	d1,.1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Now we copy the tables into Jerry

	move.l	#TABS_COPY,a0
	move.l	(a0)+,a1		; Get load address
	move.l	(a0)+,d1		; and length
	asr.l	#2,d1
	subq.l	#1,d1
.2:
	move.l	(a0)+,(a1)+		; initialize voice table
	dbra	d1,.2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Turn off score timer
	
	move.w	#0,JPIT1
	move.w	#0,JPIT1+2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Setup S clock

	move.l	#SCLKVALUE,SCLK
	move.l	#$15,SMODE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Set the volume

	move.l	#MIDIVOLUME,VOLUME		; set global volume
	move.l	#GLOBALVOLUME,UEBERVOLUME	; set global volume

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Now we copy the score to the score location

	move.l	#scoretab,a0	
	move.l	#$50000,a1		; here's where we put the music data

scorelop:
	move.l	(a0)+,d0		; copy it
	move.l	d0,(a1)+
	cmp.l	#$7fffffff,d0
	bne	scorelop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Tell the music driver where the music score is located.

	move.l	#$50000,SCORE_ADD

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Now let's set up a patch table	

	move.l	#patches,a0		; First word is the number of patch tables
	move.w	(a0)+,d0
	mulu.w	#20,d0			; a table contains 20 longs
	move.l	#PATCHTAB,a1

patchlop:
	move.l	(a0)+,(a1)+		; now we copy the patches
	dbra	d0,patchlop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Tell the synth where the patches are located

	move.l	#PATCHTAB, PATCHLOC	; set the ptr to the patches

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Set up JPIT1 (timer)

	move.w	#$56,JPIT1+2
	move.w	#$114,JPIT1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Enable sound (mute bit)

	move.w	#$100,JOYSTICK

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Now it should be safe to turn on the DSP

	move.l	#DSPORG,D_PC		; Set up D_PC
	move.l	#$1,D_CTRL		; LET 'R RIP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Now our music should be playing...

.inf:
	nop
	bra .inf			; We have nothing else to do, so loop.

; *****************************************************************
; ************************ END OF MAIN CODE ***********************
; *****************************************************************

; *****************************************************************
; *		    SAMPLE CODE FOR SYNTH SHUTDOWN		  *
; *****************************************************************

synth_off:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Turn off score timer

	move.w	#0,JPIT1
	move.w	#0,JPIT1+2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; The next several lines may seem weird, so let's explain...
;
; This is MAGIC to make the DSP turn itself off at the next sample interrupt.
; We are going to change the 'movei' instruction at the start of the DSP's
; IS2 interrupt handler so that it points to a routine that will shut down
; the DSP (this routine is part of the SYNTH source in this particular
; example).  This 'movei' instruction has the format:
;
;   0x98d1  <low word of address>  <high word of address>
;
; Because all DSP RAM address have the same high word, we only have to change
; the low word.  However, since we can only reliably access LONG's in DSP RAM,
; we have to create the instruction itself also.  Here are the steps involved:
;
; 1) Save current address of interrupt handler so we can restore it later.
;
; 2) Get address of the DSP's "turn myself off" routine.
;
; 3) Clear the high word of the address to make room for the 'MOVEI' code.
;
; 4) 'OR' in the 'movei' code.
;
; 5) Store the new 'movei' instruction into the DSP interrupt handler area.
;    Now the the DSP will jump to the SHUTDOWN routine on the next sample
;    interrupt it gets.
;
; 6) Restore the original 'movei' instruction and interrupt handler address
;    [See synth_on]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     
	move.l	$f1b010, orglong	; Step 1
	move.l	#SHUTDOWN,d0		; Step 2
	and.l	#$ffff,d0		; Step 3
	or.l	#$981d0000,d0		; Step 4
	move.l	d0,$f1b010		; Step 5
					; Step 6 - See synth_on
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	SAMPLE CODE FOR TURNING THE SYNTH ON AGAIN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

synth_on:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; 6) Restore the original 'movei' instruction and interrupt handler address

	move.l	orglong,$f1b010		; Step 7 (theoretically we should wait for a semaphore...)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Tell the music driver where the music score is located.

	move.l	#$50000,SCORE_ADD


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Tell the synth where the patches are located

	move.l	#PATCHTAB, PATCHLOC	; set the ptr to the patches

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Set up JPIT1 (timer)

	move.w	#$56,JPIT1+2
	move.w	#$114,JPIT1

	rts


;---------------------------------------------------------------------------
;	B S S
;---------------------------------------------------------------------------
	.bss
orglong:
	ds.l	1

;____________________________________EOF____________________________________
