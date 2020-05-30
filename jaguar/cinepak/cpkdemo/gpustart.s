;
; Program: cpkdemo.cof	- Cinepak Player Demo
;  Module: gpustart.s	- GPU Startup Stub/Interrupts
;
; Revision History:
; 12/09/94  - SDS: Created

		.include "jaguar.inc"
		.include "memory.inc"
		.include "player.inc"
		 
		.globl	gpustartup
		.globl	gpustartupx
		.globl	GSTUBSTART
		.globl	GCHANGEOLP

		.extern	GPU_CPUINT
		.extern	GPU_OPINT

		.extern	movilist
		.extern listcopy
		.extern data_off
		.extern scrbuf
		.extern y_pos
		.extern obj_height
		.extern a_vde
		.extern runframes

		.extern	time
		.extern timeIncr

ISRSTACK	.equ	G_RAM+4096

		.68000
		.text
gpustartup:
		.gpu
		.org	G_RAM

;;;;;;;;;;;;;;;;;
;;; CPU Interrupt
;;;;;;;;;;;;;;;;;
		movei	#GPU_CPUINT,r0
		jump	(r0)
		nop
		nop
GCHANGEOLP:
		.dc.l	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; DSP Interrupt (reserved for CD-BIOS)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop

;;;;;;;;;;;;;;;;;
;;; PIT Interrupt
;;;;;;;;;;;;;;;;;
		movei	#GPU_PITINT,r0
		jump	(r0)
		nop
		nop
		nop
		nop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Object Processor Interrupt
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		movei	#GPU_OPINT,r0
		jump	(r0)
		nop
		nop

GOPDEBUG:	.dc.l	0

;;;;;;;;;;;;;;;;;;;;;
;;; Blitter Interrupt
;;;;;;;;;;;;;;;;;;;;;
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Procedure: GPU Startup Stub
;;;	       Set the ISR, enable interrupts, set register bank #1,
;;;            enter Cinepak code.
		
GSTUBSTART:
		movei	#ISRSTACK,r31		; Initialize interrupt stack

		movei	#G_FLAGS,r0
		movei	#G_CPUENA|G_PITENA|G_OPENA|REGPAGE,r2

		load	(r0),r1
		or	r2,r1			; Set CTRL flags
		store	r1,(r0)

		nop				; Allow time to take effect
		nop

		movei	#PIT0,r0		; Setup PIT to 600 Hz
		moveq	#1,r1
		storew	r1,(r0)

		addq	#2,r0
		movei	#$568E,r1
		storew	r1,(r0)
			
		movei	#G_RAM+GPU_OFFSET,r0	; Jump to Cinepak Code
		jump	(r0)
		nop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Interrupt: GPU Object Processor
;;;	       Increment runframes, update object list.
		
GPU_OPINT:
		movei	#G_FLAGS,r30		; Interrupt START 
		load	(r30),r29

		movei	#OBF,r0			; Store any value here
		storew	r1,(r0)			; to restart OP

		movei	#runframes,r2		; Increment Frame Counter
		load	(r2),r0
		addq	#1,r0
		store	r0,(r2)

		movei	#listcopy+8,r4		; Second/Third Phrase of copy
		movei	#movilist+BITMAP_OFF,r5	; Destination Buffer
		movei	#scrbuf,r6		; Screen to show
		movei	#data_off,r7		; Offset into screen buffer
		movei	#obj_height,r8		; Object Height
		movei	#y_pos,r9		; Object YPOS

		movei	#$7FF,r10		; Masks
		movei	#$FF000007,r11

		load	(r5),r2			; Get first longword of bitmap
		and	r10,r2			; Mask off LINK

		load	(r6),r0			; Get screen address
		load	(r7),r1			; Get offset address

		add	r0,r1			; Add screen+offset
		shlq	#8,r1			; Shift into place
		or	r1,r2			; Store new DATA

		store	r2,(r5)			; Store first longword
		addq	#4,r5			; Advance to next

		load	(r5),r2			; Second longword
		and	r11,r2			; Mask YPOS/TYPE
		
		loadw	(r8),r0			; Load object height
		shlq	#14,r0			; Shift into place
		or	r0,r2			; OR HEIGHT field

		loadw	(r9),r0			; Load y_pos	
		shlq	#3,r0			; Shift into place
		or	r0,r2			; OR YPOS field

		store	r2,(r5)			; Store it
		
		load	(r4),r0			; Straight Copy Four Longwords
		addq	#4,r5
		addq	#4,r4
		store	r0,(r5)

		load	(r4),r1
		addq	#4,r5
		addq	#4,r4
		store	r1,(r5)

		load	(r4),r0			
		addq	#4,r5
		addq	#4,r4
		store	r0,(r5)

		load	(r4),r1
		addq	#4,r5
		addq	#4,r4
		store	r1,(r5)
		
		bclr	#3,r29			; Standard Interrupt Exit
		bset	#12,r29
		load	(r31),r28
		addq	#2,r28
		addq	#4,r31
		jump	(r28)		
		store	r29,(r30)
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Interrupt: GPU Programmable Interrupt Timer
;;;	       Add timeIncr to time.

GPU_PITINT:
		movei	#G_FLAGS,r30		; Interrupt START 
		load	(r30),r29

		movei	#time+2,r4		; This means time+2 must
		movei	#timeIncr,r5		; be long aligned.

		load	(r4),r0			; Load time+2
		load	(r5),r1			; Load timeIncr

		add	r1,r0			; Add the two
		store	r0,(r4)			; Store the result

		jr	CC,nocarry		; If no carry, exit
		nop

		subq	#2,r4			; Step back to time

		loadw	(r4),r0			; Load high 16 bits
		addq	#1,r0			; Add carry
		storew	r0,(r4)			; Store
nocarry:
		bclr	#3,r29			; Standard Interrupt Exit
		bset	#11,r29
		load	(r31),r28
		addq	#2,r28
		addq	#4,r31
		jump	(r28)		
		store	r29,(r30)
		
		.68000
gpustartupx:
		.end

		