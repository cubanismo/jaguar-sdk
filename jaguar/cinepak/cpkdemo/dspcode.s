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
; Revision History:
; 04/25/94  17:18:20  jpe
; Initial revision.
; .
; .
; .
; 03/15/95  15:24:51  sds
; Handles multiple audio types (only tested m8u and s16u).
; Changed shutdown call to restart call.
; 
; 05/06/95  13:04:32  sds
; Compressed audio now does shlq #1 (was previously omitted)
;*****************************************************************************

		.68000
		.globl  DSP_S
		.globl  DSP_E
DSP_S:
		.dsp

		.nolist
		.include    "jaguar.inc"
		.list

		.globl  DSP_ARGS
		.globl  DSP_ENTR
		.globl  DSP_LOAD
		.globl  DSP_STOP
		.globl  AUDIO_DRIFT
		.globl	AUDIO_DESC
		.globl	soundmute

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   Register utilization:
;
;   r0-r2: Scratch
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

rBufPtr		.regequ		r4	; Pointer to Sample Buffer
rXOR		.regequ		r6	; $8000 for XOR (if necessary)
rBytesLeft	.regequ		r7	; # of samples remaining
rNumBytes	.regequ		r9	; # of bytes remaining
rLeftDAC	.regequ		r10	; Address of right DAC
rRightDAC	.regequ		r11	; Address of left DAC
rXORFlag	.regequ		r12	; XOR flag
rAudioDesc	.regequ		r14	; Audio Data Description
rMuteFlag	.regequ		r15	; Address of soundmute
rRestart	.regequ		r16	; Address of DSP shutdown
rMainLoop	.regequ		r17	; Address of main loop
rArgs		.regequ		r20	; Pointer to CPU arguments
rStoreDACs	.regequ		r21	; Pointer to StoreDACs
rHandlers	.regequ		r22	; Pointer to typetable (handlers)
rAudioDrift	.regequ		r23	; Audio Drift Rate (0.32 fraction)
rFraction	.regequ		r24	; Cumulative sample difference
rContinuePlay	.regequ		r25	; Address of Continue Play
rStopFlag	.regequ		r26	; STOP flag
rISR		.regequ		r27	; ISR Semaphore
rIStack		.regequ		r31	; Interrupt Stack (r28-r31 reserved)
;------------------------------------------------------------------------------

DSPI2SVect      .equ    D_RAM+$10       	; Interrupt 1: I2S
soundmute	.equ	D_RAM+$1FFC

		.org    DSPI2SVect

DSP_LOAD:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Here is the vector for the I2S interrupt.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		movei   #I2Sisr,r29 		; Address  of interrupt handler
		jump    (r29)       		; Jump to it
		nop
		nop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Here is the entry point and startup code.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DSP_ENTR:
		movei   #R_DAC,rRightDAC	; Right DAC location
		movei   #L_DAC,rLeftDAC     	; Left DAC location
		movei   #AUDIO_DRIFT,rAudioDrift
		movei   #AUDIO_DESC,rAudioDesc
		movei   #Restart,rRestart    	; Restart routine
		movei   #MainLoop,rMainLoop    	; Main program loop
		movei   #DSP_ARGS,rArgs       	; Arguments passed by CPU
		movei   #storedacs,rStoreDACs
		movei   #typetable,rHandlers
		movei   #$8000,rXOR    		; For XOR
		movei   #$80000000,rFraction  	; Half a sample
		movei   #ContinuePlay,rContinuePlay   	; Continue playing audio
		movei	#soundmute,rMuteFlag	; Mute sound
		movei   #DSP_STOP,rStopFlag   	; Stop flag (set by CPU)
		movei   #Stack,rIStack		; Initialize stack pointer

		moveq   #0,rISR       	   	; Clear semaphore register
		moveq   #0,rBytesLeft		; Clear counter register

		movei   #D_FLAGS,r2
		load    (r2),r0         	; Read DSP flags register
		bclr	#14,r0
		bset    #5,r0           	; Enable I2S interrupt
		store   r0,(r2)         	; Write to flag register
		nop
		nop

;------------------------------------------------------------------------------
;   Plays a chunk of sound data, with parameters specified as follows:
;
;   DSP_ARGS:   Sample count
;   DSP_ARGS+4: Base address of sound buffer
;   DSP_ARGS+8: Audio Data Description (or 0 if none)
;
;   When the number of samples specified by the sample count have been played,
;   locations DSP_ARGS and DSP_ARGS+4 are read again. If the new sample count
;   is non-zero, playing is continued without interruption. Otherwise, zeros
;   are written to the DACs.
;------------------------------------------------------------------------------

MainLoop:
		or  	rISR,rISR       	; Test semaphore register
		jr  	EQ,MainLoop     	; Wait for an interrupt
		nop

		moveq   #0,rISR         	; Clear semaphore

		load    (rStopFlag),r0		; Get stop flag
		or  	r0,r0           	; Is it set?
		jump    NE,(rRestart)		; Yes, shut ourselves down
		nop

		cmpq	#0,rBytesLeft		; Is sample count set?
		jump    NE,(rContinuePlay)	; Yes, continue playing
		nop

		load    (rArgs),r0      	; Read block sample count
		or  	r0,r0           	; Is it non-zero?
		jr  	NE,StartPlay    	; Yes, begin playing
		nop

		store   r0,(rRightDAC) 		; Write a zero to right DAC
		store   r0,(rLeftDAC)   	; Write a zero to left DAC
		jump    (rMainLoop)     	; Loop again
		nop
StartPlay:
		movei	#AUDIO_DRIFT,r0
		movei	#AUDIO_DESC,r1
		load    (r0),rAudioDrift       	; Audio drift rate
		load	(r1),rAudioDesc		; Audio Data Description

		move	rAudioDesc,rXORFlag
		shlq    #2,rAudioDesc		; Make it a longword offset

		load    (rArgs),rBytesLeft	; Get sample count for block
		addq    #4,rArgs          	; Increment argument pointer

		load    (rArgs),rBufPtr        	; Get pointer to audio data

		moveq   #0,r0
		subq    #4,rArgs          	; Back up argument pointer
		store   r0,(rArgs)        	; Zero out sample count

ContinuePlay:       
		load    (rAudioDesc+rHandlers),r0    	; Get jump point
		jump    (r0)            	; jump to handler
		nop
m8u:
		loadb   (rBufPtr),r2  		; Read audio byte from buffer
		addq    #1,rBufPtr           	; Next sample pointer
		
		moveq	#1,rNumBytes

		subq    #1,rBytesLeft        	; Decrement sample count
		shlq    #8,r2           	; 16-bit 2's complement
		jump    (rStoreDACs)           	; Go to store
		move    r2,r0           	; Done on purpose
s8u:
		loadb   (rBufPtr),r0    	; Read audio byte from buffer
		addq    #1,rBufPtr           	; Next sample pointer
		loadb   (rBufPtr),r2         	; Read audio byte from buffer
		shlq    #8,r0           	; 16-bit 2's complement
		
		moveq	#2,rNumBytes

		addq    #1,rBufPtr		; Next sample pointer
		shlq    #8,r2          		; 16-bit 2's complement
		jump    (rStoreDACs)           	; Go to store
		subq    #2,rBytesLeft        	; Decrement sample count
m16u:
		loadw   (rBufPtr),r0         	; Read audio byte from buffer
		addq    #2,rBufPtr           	; Next sample pointer
		
		moveq	#2,rNumBytes

		subq    #2,rBytesLeft        	; Decrement sample count
		jump    (rStoreDACs)           	; Go to store
		move    r0,r2           	; Done on purpose
s16u:
		loadw   (rBufPtr),r0         	; Read audio byte from buffer
		addq    #2,rBufPtr          	; Next sample pointer
		loadw   (rBufPtr),r2         	; Read audio byte from buffer
		addq    #2,rBufPtr           	; Next sample pointer
		
		moveq	#4,rNumBytes

		jump    (rStoreDACs)           	; Go to store
		subq    #4,rBytesLeft		; Decrement sample count
m16c:
		loadb   (rBufPtr),r0         	; Read audio byte from buffer
		addq    #1,rBufPtr           	; Next sample pointer
		
		moveq	#1,rNumBytes
		
		move    r0,r1           	; Store a copy
		bclr    #7,r0           	; Remove sign bit
		btst    #7,r1           	; Test copys' sign bit
		jr  	EQ,.noneg       	; Skip neg if clear
		mult    r0,r0           	; Always do this!!!

		neg 	r0          		; Negate result
.noneg:
		shlq	#1,r0
		subq    #1,rBytesLeft		; Decrement sample count
		jump    (rStoreDACs)           	; Go to store
		move    r0,r2           	; Done on purpose
s16c:  
		loadb   (rBufPtr),r0         	; Read audio byte from buffer
		addq    #1,rBufPtr           	; Next sample pointer
		loadb   (rBufPtr),r2         	; Read audio byte from buffer
		addq    #1,rBufPtr           	; Next sample pointer
		
		moveq	#2,rNumBytes

		move    r0,r1           	; Store a copy
		bclr    #7,r0           	; Clear the sign bit
		btst    #7,r1           	; Test the copys' sign bit
		jr  	EQ,.noneg1
		mult    r0,r0
		neg 	r0
.noneg1:
		move    r2,r1           	; Make a copy of right channel
		bclr    #7,r2           	; Clear the sign bit
		btst    #7,r1           	; Test copys' bit
		jr  	EQ,.noneg2      	; Skip neg if sign clear
		mult    r2,r2           	; Always do!!!
		neg 	r2
.noneg2:
		shlq	#1,r0
		shlq	#1,r2

		jump    (rStoreDACs)           	; Go to store
		subq    #2,rBytesLeft       	; Decrement sample count
storedacs:
		load	(rMuteFlag),r1
		cmpq	#0,r1
		jr	NE,skipstore
		nop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Drum roll please.....
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		btst	#31,rXORFlag
		jr	EQ,juststore
		nop

		xor     rXOR,r0
		xor     rXOR,r2
juststore:
		store   r0,(rRightDAC)        	; Store data in right DAC
		store   r2,(rLeftDAC)        	; Store data in left DAC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Add drift rate to accumulated sample difference. When a carry is
;;; generated, we're off by more than one, and we drop an input sample.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
skipstore:
		add 	rAudioDrift,rFraction	; Add difference to accumulated
		jump    CC,(rMainLoop)	        ; If nc, still within one sample
		nop

		add	rNumBytes,rBufPtr
		sub	rNumBytes,rBytesLeft
		jump    PL,(r17)        	; Continue unless negative
		nop

		load    (rArgs),rBytesLeft   	; Get sample count for block
		addq    #4,rArgs          	; Increment argument pointer

		load    (rArgs),rBufPtr        	; Get pointer to audio data

		moveq   #0,r0
		subq    #4,rArgs          	; Back up argument pointer
		store   r0,(rArgs)        	; Zero out sample count

		jump    (rMainLoop)           	; Loop
		nop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   Sample rate interrupt service routine.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

I2Sisr:
		movei   #D_FLAGS,r30
		load    (r30),r29       	; Read flags register

		moveq   #1,rISR          	; Set register semaphore

		bclr    #3,r29          	; Clear IMASK
		load    (rIStack),r28		; Get return address
		bset    #10,r29         	; Clear I2S interrupt
		addq    #2,r28          	; Fix up return address
		addq    #4,rIStack      	; Balance stack
		jump    (r28)           	; Return
		store   r29,(r30)       	; Restore flags
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   Restart routine.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Restart:
		moveq	#0,r0
		store   r0,(rRightDAC) 		; Write a zero to right DAC
		store   r0,(rLeftDAC)   	; Write a zero to left DAC

		movei	#DSP_ENTR,r0
		jump	(r0)
		nop

		.long

DSP_ARGS:   	.dc.l   0,0	        	; Argument list
DSP_STOP:   	.dc.l   0           		; Stop flag (set by CPU)
AUDIO_DRIFT:    .dc.l   0           		; Audio drift rate
AUDIO_DESC:	.dc.l	0			; Audio Data Description

typetable:  	.dc.l   m8u         		; Mono, 8-bit, Uncompressed
		.dc.l   s8u
		.dc.l   m16u
		.dc.l   s16u
		.dc.l   0           		; Not supported
		.dc.l   0           		; Not supported
		.dc.l   m16c
		.dc.l   s16c


		.dc.l   0,0         		; Reserve 2 longs for stack
Stack:
		.68000
DSP_E:
		.end
