;**************************************************************************
; (C)1994 ATARI CORP.       SECRET & CONFIDENTIAL       ALL RIGHTS RESERVED
;
;			Code to read CD data in thru Jerry
;				A counter is stored at
;				$F1B000 to show capacity
;
;			This code will keep up with a 8x oversample rate
;
;**************************************************************************

		include		"jaguar.inc"

					; addresses of...


STACKPOS	equ	$F1CF00		; stack in DSP SRAM

		XDEF	JERI_B
		XDEF	VOLUME

ORG	$F1B000				; put this program at start of DSP SRAM

DSPORG:
	movei	JERI_B,r0		; (interrupt 0  - DSP Control)
	jump	(r0)
	nop
	nop
	nop
	nop
I2S_VEC:
	movei	#i2s_isr,r28		; (interrupt 1 - I2S)
	jump	(r28)
	nop
	nop
	nop
	nop

JERI_B:
	movei	#STACKPOS,r31	; Set up a stack

	movei	#D_FLAGS,r1	; load dsp flags
	load	(r1),r0
	bset	5,r0		; enable I2S interrupt
	store	r0,(r1) 	; save dsp flags

	movei	L_I2S,r18	; address of i2s input port

	movei	#VOLUME,r8

	movei	#$f1b000,r3	; This is where the counter goes

	movei	D_FLAGS,r29	; get flags ptr

mloop:
	moveq	#0,r23
	move	r23,r0		; reset counter to 0
	move	r23,r2		; clear flag

delay:
	cmp	r23,r2		; check flag
	jr	z,delay
	addqt	#1,r0

	jr	mloop
	store	r0,(r3)	
                 
i2s_isr:                        ; Sample pair-rate ISR
	load	(r29),r30	; load flags

	load	(r18),r13	; data from right channel in r13

	load	(r8),r10	; Load current volume setting
	imult	r10,r13		; Volume adjust
	sharq	#15,r13

	moveq	#1,r2		; tell the main routine we got here

	store	r13,(r18)

	addq	#4,r18
	load	(r18),r12

	imult	r10,r12		; Volume adjust
	sharq	#15,r12

	store	r12,(r18)
	subq	#4,r18


clean_up:			; do the housekeeping, per THE BOOK
	bclr	3,r30		; clear IMASK
	bset	10,r30		; set I2S interrupt clear bit
	load	(r31),r28	; get last instruction address
	addq	2,r28		; point at next to be executed
	addq	4,r31		; update the stack pointer
	jump	(r28)		; and return
	store	r30,(r29)	; restore flags

halt_DSP:			; do this to stop the damn thing
	movei	$DEADC0DE,r9	; breadcrumb

	moveq	#0,r1

	movei	#D_FLAGS,r0	; make sure it doesn't start 
	store	r1,(r0)		; with interrupts on

	movei	#D_CTRL,r0	; and halt it
	store	r1,(r0)

	nop
	nop
	end                                        

	ALIGN long

VOLUME:
	dc.l	0

