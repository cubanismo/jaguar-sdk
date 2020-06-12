
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
; Revision 1.0	04/25/94  17:18:20  jpe
; Initial revision.
;*****************************************************************************

	.68000
	.globl DSP_S
	.globl DSP_E
DSP_S:
	.dsp
	nolist
	include "jaguar.inc"
	list

	.extern	    DSP_ARGS
	.extern	    DSP_ENTR
	.extern	    DSP_LOAD
	.extern	    DSP_STOP
	.extern	    AUDIO_DRIFT

;------------------------------------------------------------------------------
;   Register utilization:
;
;	r0:	Scratch
;	r2:	Scratch
;	r4:	Pointer to sample buffer
;	r7:	Samples remaining in buffer
;	r10:	Address of right DAC
;	r11:	Address of left DAC
;	r16:	Address of Shutdown routine
;	r17:	Address of main loop
;	r20:	Pointer to CPU arguments
;	r23:	Audio drift rate (Q32)
;	r24:	Cumulative sample difference (fractional part)
;	r25:	Address of ContinuePlay
;	r26:	Address of STOP_FLAG
;	r27:	ISR semaphore
;	r28/31: Interrupt service
;------------------------------------------------------------------------------

	
	stckptr	regequ	    r31 		; Stack pointer

	DSPI2SVect  equ     D_RAM+$10		; Interrupt 1: I2S

	org	DSPI2SVect

z	ccdef	%00010
nc	ccdef	%00100
nn	ccdef	%10100

DSP_LOAD:

;==============================================================================
;	Here is the vector for the I2S interrupt.
;==============================================================================

	movei	#I2Sisr,r29		; Address  of interrupt handler
	jump	(r29)			; Jump to it
	nop
	nop

;==============================================================================
;	Here is the entry point and startup code.
;==============================================================================

DSP_ENTR:
	movei	#AUDIO_DRIFT,r0
	load	(r0),r23		; Audio drift rate

	movei	#R_DAC,r10		; Right DAC location
	movei	#L_DAC,r11		; Left DAC location
	movei	#Shutdown,r16		; Shutdown routine
	movei	#MainLoop,r17		; Main program loop
	movei	#DSP_ARGS,r20		; Arguments passed by CPU
	movei	#$80000000,r24		; Half a sample
	movei	#ContinuePlay,r25	; Continue playing audio
	movei	#DSP_STOP,r26		; Stop flag (set by CPU)
	movei	#Stack,stckptr		; Initialize stack pointer

	moveq	#0,r27			; Clear semaphore register
	moveq	#0,r7			; Clear counter register

	movei	#D_FLAGS,r2
	load	(r2),r0 		; Read DSP flags register
	bset	#5,r0			; Enable I2S interrupt
	store	r0,(r2) 		; Write to flag register

;------------------------------------------------------------------------------
;   Plays a chunk of sound data, with parameters specified as follows:
;
;	DSP_ARGS:   Sample count
;	DSP_ARGS+4: Base address of sound buffer
;
;   When the number of samples specified by the sample count have been played,
;   locations DSP_ARGS and DSP_ARGS+4 are read again. If the new sample count
;   is non-zero, playing is continued without interruption. Otherwise, zeros
;   are written to the DACs.
;------------------------------------------------------------------------------

MainLoop:
	or	r27,r27 		; Test semaphore register
	jr	z,MainLoop		; Wait for an interrupt
	nop

	xor	r27,r27 		; Clear semaphore

	load	(r26),r0		; Get stop flag
	or	r0,r0			; Is it set?
	jump	nz,(r16)		; Yes, shut ourselves down
	nop

	or	r7,r7			; Is sample count set?
	jump	nz,(r25)		; Yes, continue playing
	nop

	load	(r20),r0		; Read block sample count
	or	r0,r0			; Is it non-zero?
	jr	nz,StartPlay		; Yes, begin playing
	nop

	store	r0,(r10)		; Write a zero to right DAC
	store	r0,(r11)		; Write a zero to left DAC
	jump	(r17)			; Loop again
	nop

StartPlay:
	load	(r20),r7		; Get sample count for block
	addq	#4,r20			; Increment argument pointer
	load	(r20),r4		; Get pointer to audio data
	moveq	#0,r0
	subq	#4,r20			; Back up argument pointer
	store	r0,(r20)		; Zero out sample count

ContinuePlay:	    
	loadb	(r4),r0 		; Read audio byte from buffer
	shlq	#8,r0			; 16-bit 2's complement
	store	r0,(r10)		; Store data in right DAC
	store	r0,(r11)		; Store data in left DAC

	addq	#1,r4			; Point to next sample
	subq	#1,r7			; Decrement sample counter

;   Add drift rate to accumulated sample difference. When a carry is generated,
;   we're off by more than one, and we drop an input sample.

	add	r23,r24 		; Add difference to accumulated
	jump	nc,(r17)		; If nc, still within one sample
	nop

	addq	#1,r4			; Skip a sample
	subq	#1,r7			; Adjust counter
	jump	nn,(r17)		; Continue unless negative
	nop

	load	(r20),r7		; Get sample count for block
	addq	#4,r20			; Increment argument pointer
	load	(r20),r4		; Get pointer to audio data
	moveq	#0,r0
	subq	#4,r20			; Back up argument pointer
	store	r0,(r20)		; Zero out sample count

	jump	(r17)			; Loop
	nop

;==============================================================================
;	Sample rate interrupt service routine.
;==============================================================================

I2Sisr:
	movei	#D_FLAGS,r30
	load	(r30),r29		; Read flags register

	moveq	#1,r27			; Set register semaphore

	bclr	#3,r29			; Clear IMASK
	load	(stckptr),r28		; Get return address
	bset	#10,r29			; Clear I2S interrupt
	addq	#2,r28			; Fix up return address
	addq	#4,stckptr			; Balance stack
	jump	(r28)			; Return
	store	r29,(r30)		; Restore flags
    
;==============================================================================
;	Shutdown routine.
;==============================================================================

Shutdown:
	movei	#D_CTRL,r0		; DSP control register
	moveq	#0,r1			; Disable interrupts, halt
	store	r1,(r0) 		; Stop the DSP
	nop
	nop
	nop
	nop

	.long

DSP_ARGS:	.dc.l	0,0		; Argument list
DSP_STOP:	.dc.l	0		; Stop flag (set by CPU)
AUDIO_DRIFT:	.dc.l	0		; Audio drift rate

		.dc.l	0,0		; Reserve 2 longs for stack
Stack:
	.68000
DSP_E:
	.end
