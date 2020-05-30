;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	include 'jaguar.inc'
	include 'qsound.inc'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.globl	SHUTDOWN
	.globl  QSWrapper
	.globl	start_QSWrapper
	.globl	end_QSWrapper

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.extern	QSound_Entry
	.globl	toq

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Provide a ROM-based label so we can copy the code to the DSP RAM

	.68000
start_QSWrapper::

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.DSP
	ORG	D_RAM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; OK, here's our wrapper routine for the QSound module

DSP_ISR1::
	movei	#QSWrapper,r0		; (interrupt 0	- DSP Control)
	jump	T,(r0)
	nop
	nop
	nop
	nop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; We put the stack here so that we do not waste the first 16 bytes

DSP_ISR2::
STACKPOS:
	movei	#i2s_isr,r29			; (interrupt 1 - I2S)
	jump	T,(r29)
	nop
	nop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Lets use this piece of RAM (the end of the DSP ISR #2 area) as a

SEMAPHORE:
	nop
	nop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Set up the modulo adders to handle tables that are 128 longs in length
; This is the size of the internal ROM_TABLES

QSWrapper::
	movei	#STACKPOS,r31		; Set up a stack

	movei	#R_DAC,r3		; Get the DAC location
	movei	#D_FLAGS,r1		; load dsp flags to go to bank 1

	load	(r1),r0
	bset	#5,r0			; enable I2S interrupt
	store	r0,(r1) 		; save dsp flags

	moveq	#0,r0
	movei	#SEMAPHORE,r1
	store	r0,(r1)			; Clear the SEMAPHORE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; QWave routine:
;
; r4 -> beginning of wave sample
; r8 -> beginning of wave sample2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

QWave:
	movei	#helicopter_start,r0
	load	(r0),r4
	movei	#gunshot_start,r0
	load	(r0),r8
	
	movei	#helicopter_pan,r7
	movei	#gunshot_pan,r9
	movei	#0,r20
	movei	#0,r22
	store	r20,(r7)		; hard-pan left the heli
	store	r20,(r9)

	movei	#tlop,r6
tlop:
	load	(r1),r2			; Get SEMAPHORE
lop:
	btst	#1,r2
	jr	EQ,lop
	load	(r1),r2			; Get SEMAPHORE
					; ie., wait for interupt
; out to DAC's

	store	r22,(r3)		; output to right DAC
	addq	#4,r3			
	store	r20,(r3)		; output to left DAC
	subq	#4,r3

; load pointer to second sound

	movei	#gunshot_start,r0
	load	(r0),r8

; pan dynamic channel

	load	(r7),r22		; pan position

; copy samples to local space

	movei	#toq,r18
	loadw	(r4),r5
	movei	#$3fff,r17
	imult	r17,r5
	shrq	#16,r5
	store	r5,(r18)
	addq	#4,r18
	store	r22,(r18)		; pan  for helicopter
	load	(r9),r22
	addq	#4,r18
	loadw	(r8),r5
	imult	r17,r5
	shrq	#16,r5
	store	r5,(r18)
	addq	#4,r18
	store	r22,(r18)		; pan for phaser sound
	subq	#12,r18

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Make the call to QSound
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	movei	#After,r16		; return address for QSound

	movei	#QSound_Entry,r5	; Get entry point of QSound module
	load	(r5),r5			; from pointer
	movei	#2,r17			; Set number of voices
	jump	T,(r5)			; Call QSound
	nop
After:	
	shrq	#16,r20
	shrq	#16,r22

; loop the first sample

	addq	#2,r4			; This will wrap around the table
	movei	#helicopter_end,r0
	load	(r0),r5
	cmp	r4,r5
	jr	NE,cont
	nop
	movei	#helicopter_start,r0
	load	(r0),r4

cont:
	movei	#explosion_start,r0		; match the explosion?
	load	(r0),r5
	cmp	r8,r5
	movei	#helicopter_pan,r0		; get orig launch pan
	movei	#notatexplosion,r5
	jump	NE,(r5)
	load	(r0),r5
	movei	#gunshot_pan,r0
	cmpq	#15,r5
	jr	MI,exrightpan
	nop
	movei	#0,r5
	jr	T,exupdatepan
	nop
exrightpan:
	movei	#32,r5
exupdatepan:
	store	r5,(r0)
notatexplosion:
	movei	#gunshot_end,r0
	load	(r0),r5
	cmp	r8,r5
	jr	EQ,cont2
	nop
	addq	#2,r8			; This will wrap around the table
cont2:
	movei	#gunshot_start,r0
	store	r8,(r0)

	moveq	#0,r0
	jump	T,(r6)			; DO IT AGAIN
	store	r0,(r1)			; clear the SEMAPHORE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;; start of I2S interrupt service routine ;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Sample Rate interrupt.  Registers used in this ISR:
;	r1 -> semaphore
;	r29,r30,r31

i2s_isr:
	movei	#D_FLAGS,r30		; get flags ptr

	moveq	#1,r29
	neg	r29
	store	r29,(r1)

	load	(r30),r29
	bclr	#3,r29			; clear IMASK
	load	(r31),r28		; get last instruction address
	bset	#10,r29			; clear I2S interrupt
	addq	#2,r28			; point at next to be executed
	addq	#4,r31			; update the stack pointer

	jump	T,(r28)			; and return
	store	r29,(r30)		; restore flags
	

SHUTDOWN:
	movei	#D_CTRL,r0
	moveq	#0,r1
	store	r1,(r0)
	nop
	nop
	nop
	nop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.long

helicopter_start::
	dc.l	0

helicopter_end::
	dc.l	0

helicopter_pan::
	dc.l	0

gunshot_start::
	dc.l	0

gunshot_end::
	dc.l	0

gunshot_pan::
	dc.l	0

explosion_start::
	dc.l	0

toq:
	.dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.68000
end_QSWrapper::

	END

