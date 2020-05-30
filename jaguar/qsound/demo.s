; This is a simple sample program to play two channels of
; mono sound through the QSound module on Atari

	.include	'jaguar.inc'
	.include	'vidstuff.inc'
	.include	'qsound.inc'

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.extern	pad_now
	.extern	readpad

; Labels in QPanner

	.extern	QSWrapper
	.extern	start_QSWrapper
	.extern	end_QSWrapper

	.extern	SHUTDOWN
	.extern	TMR1_ISR

	.extern	helicopter_start
	.extern	helicopter_end
	.extern	helicopter_pan
	.extern	gunshot_start
	.extern	gunshot_end
	.extern	gunshot_pan
	.extern	explosion_start

; Labels defined for files included by linker

	.extern	startofpic
	.extern helicopter_snd
	.extern helicopter_sndx
	.extern gunshot_snd
	.extern gunshot_sndx
	.extern explosion_snd
	.extern explosion_sndx

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	HIBIT	equ	$80000000

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.text

qdemo::

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; First move the picture into DRAM using the blitter...
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Same flags used for both source and destination...

	move.l	#PITCH1|PIXEL16|WID320|XADDPIX,d0
	move.l	d0,A1_FLAGS
	move.l	d0,A2_FLAGS

; Point A1_BASE at the destination, A2_BASE at the source

	move.l	#bitmap_addr,A1_BASE	; Destination
	move.l	#startofpic,A2_BASE	; Source

; Set the pixel point to 0,0

	move.l	#0,A1_PIXEL
	move.l	#0,A2_PIXEL

; y = 1, x = -320

	move.l	#$0001fec0,A1_STEP
	move.l	#$0001fec0,A2_STEP

; y = 0, x = 0

	move.l	#0,A1_FSTEP		; Set up the fractional step size to (0,0)
	move.l	#0,A1_FPIXEL		; Set fractional pixel pointer to (0,0)
	move.l	#0,A1_CLIP		; Set the clipping to (0,0)

; Set loop counters...

	move.l	#$00c80140,B_COUNT	; y = 200, x = 320

; Do it!!!  Enable source data reads, updates for A1 & A2, write mode = %1100 ($c << 21)

	move.l	#SRCEN|UPDA1|UPDA2|($c<<21),B_CMD

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Copy the QPanner wrapper routine into the DSP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	move.l	#D_RAM,a1		; destination address in DSP RAM
	move.l	#start_QSWrapper,a0	; Source address in ROM
	move.l	a0,d0			; Get start
	move.l	#end_QSWrapper,d1	; Get end
	sub.l	d0,d1			; end - start = length
	asr.l	#2,d1			; convert into # of longs
.1:
	move.l	(a0)+,(a1)+		; Copy them over to DSP RAM
	dbra	d1,.1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; OK, now A1 points at DSP RAM following QPanner routine.  This is where
; we will put the QSound module, so we need to save the entry point
; so that we will be able to call it later.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	move.l	a1,QSound_Entry

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; copy QSound module to DSP RAM (after the wrapper)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	move.l	#QSbegin,a0		; Source address in ROM
	move.l	a0,d0			; Get start
	move.l	#QSend,d1		; Get end
	sub.l	d0,d1			; end - start = length
	asr.l	#2,d1			; convert into # of longs
	add.l	#1,d1			; just in case
.2:
	move.l	(a0)+,(a1)+		; copy over to DSP RAM
	dbra	d1,.2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Tell the QSound module running in the DSP where the sample is!
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	move.l	#helicopter_snd,d0
	and.l	#$fffffffc,d0		; Assure alignment
	move.l	d0,helicopter_start

	move.l	#helicopter_sndx,d0
	and.l	#$fffffffc,d0		; Assure alignment
	move.l	d0,helicopter_end

	move.l	#0,helicopter_pan	; original pan
	move.l	#0,gunshot_pan		; original second sample pan

; Tell the DSP where the sample is

	move.l	#gunshot_snd,d0
	and.l	#$fffffffc,d0		; Assure alignment
	move.l	d0,gunshot_start

	move.l	#explosion_sndx,d0
	and.l	#$fffffffc,d0		; Assure alignment
	move.l	d0,gunshot_end

	move.l	#explosion_snd,d0	; store start of explosion
	and.l	#$fffffffc,d0
	move.l	d0,explosion_start


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; OK, now start 'er up and let 'er rip!
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Make sure the DACs are silent!

	move.l	#0,R_DAC
	move.l	#0,L_DAC

; Set up the I2S mode and clock

	move.l	#19,SCLK
	move.l	#$15,SMODE

; Enable sound (mute bit)

	move.w	#$100,JOYSTICK

; Now it should be safe to turn on the DSP

	move.l	#QSWrapper,D_PC	; Set up D_PC
	move.l	#$1,D_CTRL	; LET 'R RIP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Main loop, read joystick, interpret it and do whatever, and then loop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	moveq.l	#0,d0
	move.l	d0,pad_now	; Clear the joypad

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Slow down, don't run through the loop too fast...

.moveloop:
	move.l	#$4000,d0
	move.l	#1,d1
.3:
	sub.l	d1,d0
	bne	.3

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; OK, now read joypad and do whatever it says

	jsr	readpad		; Read the Joypad
	jsr 	interpad	; Interprete the Joypad
	bra	.moveloop

	illegal



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Interpret Joypad results and act accordingly
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

interpad:
 	movem.l	d0-d1/a0-a1,-(sp)
	move.l	pad_now,d0	; Get current joypad information
	move.l	#helicopter_pan,a0	; Get current pan position
	move.l	(a0),d1
	btst.l	#JOY_LEFT,d0	; If joypad indicates LEFT
	beq	.nolft

	subq	#1,d1		; then subtract 1 from pan position!
	bge	.nolft		; Skip ahead if we didn't go too far!
	addq	#1,d1		; Whoops!  Too far, so go back!

.nolft:
	btst.l	#JOY_RIGHT,d0	; Did joypad say RIGHT?
	beq	.norit

	addq	#1,d1		; Yes, so go right
	cmpi	#32,d1		; Make sure we didn't go too far!
	ble	.norit
	subq	#1,d1		; Whoops!  too far, so go back!

.norit:
	btst.l	#FIRE_B,d0	; Was FIRE BUTTON B pressed?
	beq	.nofir

	move.l	#gunshot_snd,d0	; Yes, so we need to play a new sound
	and.l	#$fffffffc,d0	; Assure alignment
	move.l	#gunshot_start,a1
	move.l	d0,(a1)

	move.l	#helicopter_pan,a1	; get current heli pan
	move.l	(a1),d0

	move.l	#gunshot_pan,a1
;	cmpi	#16,d0
;	ble	.rightpan

;	move.l	#0,d0
;	bra	.updatefirepan
;.rightpan:
;	move.l	#32,d0
;.updatefirepan:	
	move.l	d0,(a1)		; Set start pointer
.nofir:
	move.l	d1,(a0)		; Set pan position

; Now exit!

	movem.l	(sp)+,d0-d1/a0-a1
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.bss

QSound_Entry::
	ds.l	1	; Qsound entry point function pointer


