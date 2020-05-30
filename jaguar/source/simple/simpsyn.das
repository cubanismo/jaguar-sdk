;		A simple program to play a wave from ROM
;______________________________________________________________________________
		include "jaguar.inc"
;______________________________________________________________________________


	.globl	DSPSTART
	.globl	DSPEND

	.globl	DSP_START
	.globl	SHUTDOWN

; Do DSPSTART label before the ".dsp" and ".ORG" directives so that it gets
; an address in 68000-land, not DSP-land.  That way we can use it to copy the
; DSP program to the DSP RAM later.

DSPSTART::
	.dsp
	.ORG	D_RAM

	movei	#DSP_START,r0		; (interrupt 0	- DSP Control)
	jump	T,(r0)			
	nop
	nop
	nop
	nop

;______________________________________________________________________________
; We put the stack here so that we do not waste
; the first 16 bytes

STACKPOS:
	movei	#i2s_isr,r29			; (interrupt 1 - I2S)
	jump	T,(r29)
	nop
	nop

; Lets use this piece of RAM as a 

SEMAPHORE:
	nop
	nop

DSP_START::

; Set up the modulo adders to handle tables that are 128 longs in length
; This is the size of the internal ROM_TABLES

	movei	#D_MOD,r25		; MODPARM
	movei	#$FFFFFE00,r0
	store	r0,(r25)

	movei	#ROM_12W,r4		; Let's play back this wave
	
	movei	#R_DAC,r10		; Get the DAC location

	movei	#STACKPOS,r31		; Set up a stack

	movei	#D_FLAGS,r1		; load dsp flags to go to bank 1

	load	(r1),r0
	bset	#5,r0			; enable I2S interrupt
	store	r0,(r1) 		; save dsp flags

	moveq	#0,r0
	movei	#SEMAPHORE,r1
	store	r0,(r1)			; Clear the SEMAPHORE

; We have the following registers in use
; r0 = 0
; r1 = ADDRESS of SEMAPHORE
; r2  SCRATCH
; r3  SCRATCH
; r4 = ADDRESS of current sample
; r10 = ADDRESS of DAC

tlop:
	load	(r1),r2			; Get SEMAPHORE
lop:
	btst	#1,r2
	jr	EQ,lop
	load	(r1),r2			; Get SEMAPHORE

	load	(r4),r3
	store	r3,(r10)		; Store the data in the right DAC
	addq	#4,r10
	store	r3,(r10)		; Store the data in the leftt DAC
	subq	#4,r10			; Move pointer back to right

	addqmod	#4,r4			; This will wrap around the table

	jr	T,tlop			; DO IT AGAIN
	store	r0,(r1)			; clear the SEMAPHORE

;____________________start of I2S interrupt service routine__________________
;______________________________________________________________________________

; Sample Rate interrupt
; Registers used in this ISR
;	.	.	.	.
;	.	.	.	.
;	.	.	.	.
;	.	.	.	.
;	.	12	.	28
;	5	.	.	29
;	.	.	.	30
;	.	.	.	31

i2s_isr:

	movei	#D_FLAGS,r30			; get flags ptr

	load	(r30),r12
	bclr	#3,r12			; clear IMASK
	load	(r31),r28		; get last instruction address
	bset	#10,r12			; clear I2S interrupt
	addq	#2,r28			; point at next to be executed
	addq	#4,r31			; update the stack pointer

	moveq	#1,r5
	neg	r5
	store	r5,(r1)

	jump	T,(r28)			; and return
	store	r12,(r30)		; restore flags
	

SHUTDOWN:
	movei	#D_CTRL,r0
	moveq	#0,r1
	store	r1,(r0)
	nop
	nop
	nop
	nop

;______________________________________________________________________________

; Do DSPEND label after switching back to .68000 mode so that it gets an
; address in 68000-land, not DSP-land.  That way we can use it to copy the
; DSP program to the DSP RAM later.  (i.e. copy from DSPSTART to DSPEND)

	.68000

DSPEND::
