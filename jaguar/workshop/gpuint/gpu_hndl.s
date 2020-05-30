;
; Jaguar Example Source Code
; Jaguar Workshop Series #6
; Copyright (c)1994 Atari Corp.
; ALL RIGHTS RESERVED
;
; Program: gpuint.cof   - GPU Interrupt Object Example
;  Module: gpu_hndl.s   - GPU Interrupt Handler and Code Mover
;

		.include        "jaguar.inc"
		.include        "gpuint.inc"

		.extern         InitGPU

		.text

InitGPU:
		movem.l a0-a2,-(sp)

		lea     gpu_code1,a0            ; Interrupt Dispatch Routine
		lea     _end_code1,a1
		move.l  #OP_INT,a2              ; Dest Address (GPU Int Object Handler)
		jsr     copy_block
		
		lea     gpu_code2,a0            ; GPU Interrupt Object Handler Code
		lea     _end_code2,a1
		move.l  #OP_HNDLR_ADDR,a2
		jsr     copy_block 

		lea     gpu_code3,a0            ; Set's up GPU and loops endlessly
		lea     _end_code3,a1
		move.l  #GPU_LOOP_ADDR,a2
		jsr     copy_block

		move.l  #G_OPENA,G_FLAGS        ; Enable GPU Interrupts from OP
		move.l  #GPU_LOOP_ADDR,G_PC     ; Address of GPU setup code
		move.l  #GPUGO,G_CTRL           ; Start GPU

		movem.l (sp)+,a0-a2
		rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: copy_block
;	      Copies a block of memory in LONGwords (max 65536 bytes)
;
;         Inputs: 	a0.l	- Block Start
;			a1.l	- Block End
;
; Register Usage:	d0.w	- DBRA counter
;
; Stupid copy routine (use Blitter for large blocks of GPU code)

copy_block:
		move.l  d0,-(sp)
			
		move.l  a1,d0           ; End of block
		sub.l   a0,d0           ; Start of block

		lsr.l   #2,d0           ; # of LONGs
.copy_loop:
		move.l  (a0)+,(a2)+
		dbra    d0,.copy_loop

		move.l  (sp)+,d0
		rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Interrupt Dispatcher for Object Processor (GPU Interrupt Object) Interrupts

gpu_code1:
		.gpu
		.org    G_RAM+$30

		movei   #OP_HNDLR_ADDR,r0
		jump    T,(r0)
		nop


		.68000
_end_code1:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Interrupt Handler
; Increments the background color register every time interrupt occurs.

gpu_code2:
		.gpu
		.org    G_RAM+$80

		movei   #G_FLAGS,r30    ; Enable other ints
		load    (r30),r29
		bclr    #3,r29          ; Clear IMASK
		bset    #12,r29         ; Clear pending interrupt
		load    (r31),r28       ; Address of last instruction
		addq    #2,r28          ; +2 to point to next
		addq    #4,r31          ; Correct stack

		movei   #0,r0
		movei   #OBF,r1         ; Write any value to OBF
		storew  r0,(r1)         ; to restart Object Processor

		movei   #bg,r0          ; Previous value for BG
		movei   #BG,r1          ; Background Color Register
		load    (r0),r2         ; Load current 16-bit CRY
		addq    #1,r2

		store   r2,(r0)         ; Store it back
		storew  r2,(r1)

		jump    (r28)           ; Return to GPU
		store   r29,(r30)       ; Update GPU_FLAGS


bg:             dc.l    0

		.68000
_end_code2:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GPU Program Code (Setup and Loop)
;
; Originally, the following code was a simple infinite loop. The following
; method has been proven to be better for interrupt performance, however.
; In this case, the GPU watches a semaphore and loops while it's 0. In this
; example, it will always be 0.

gpu_code3:
		.gpu

		.org    G_RAM+$200

		movei   #ISTACK,r31     ; Initialize Interrupt Stack
gpu_loop:              
		movei   #semaphore,r10  ; Address of semaphore
		loadw   (r10),r11       ; Load value
		cmpq    #1,r11          ; Loop while not equal to 1

		jr      T,gpu_loop
		nop

		movei   #G_CTRL,r10     ; Shut off GPU; Note, in this
		load    (r10),r11       ; code, this should never happen.
		bclr    #0,r11
		store   r11,(r10)

semaphore:      .dc.l   0

		.68000
_end_code3:

		.end
