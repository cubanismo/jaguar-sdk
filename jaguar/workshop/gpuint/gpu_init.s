;
; Jaguar Example Source Code
; Jaguar Workshop Series #6
; Copyright (c)1994 Atari Corp.
; ALL RIGHTS RESERVED
;
; Program: gpuint.cof   - GPU Interrupt Object Example
;  Module: gpu_init.s   - Program entry and initialization
;
; Revision History:
; 7/26/94  - SDS: Modified from mou.cof sources
;----------------------------------------------------------------------------
; This Jaguar sample program demonstrates the use of a GPU Interrupt object
; by changing the background color of the line buffer every scanline.
; The program initializes the jaguar console and video and then builds a list
; as follows:
;	       - Branch Object (branches to last STOP object if below
;                               displayable area)
;              - Branch Object (branches to last STOP object if above
;                               displayable area)
;              - Bitmap Object (jaguar logo)
;              - Branch Object (branches to GPU Interrupt object when it
;                               it should be called)
;              - STOP Object
;              - GPU Interrupt Object
;              - STOP Object
;
; The GPU is then loaded with three segments of code as follows:
;
; 1. Stub code that is called when the interrupt occurs at
;    $F03000 + (3 * $10) and passes control to the actual handler.
; 2. The interrupt handler itself is loaded at $F03080
; 3. A section of code to keep the GPU running while it's not processing
;    interrupts. It checks a flag (which will never be set) to determine
;    when to shut down. Note that the GPU must be running for interrupts
;    to occur and checking a flag is the best way. Tight infinite GPU
;    loops are not recommended.
;
; The third section of GPU code is then started and GPU Object Processor
; interrupts are enabled.
;
; Lastly, the code installs vertical blank handlers and starts video
; processing.
;

		.include        "jaguar.inc"
		.include        "gpuint.inc"

; Globals
		.globl          a_vdb
		.globl          a_vde
		.globl          a_hdb
		.globl          a_hde
		.globl          width
		.globl          height
; Externals
		.extern         InitLister
		.extern         UpdateList
		.extern         InitGPU

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Program Entry Point Follows...

		.text

		move.l  #$00070007,G_END        ; big-endian mode
		move.w  #$FFFF,VI               ; disable video frame ints

		move.l  #INITSTACK,a7           ; Setup a stack
			
		jsr     InitVideo               ; Setup our video registers.
		jsr     InitLister              ; Initialize Object Display List
		jsr     InitGPU                 ; Load GPU Interrupt Code
						; and start the gpu code
		jsr     InitVBint

		move.l  d0,OLP                  ; Value of d0 from InitLister
		move.w  #$6C1,VMODE             ; Configure Video
		
		illegal                         ; Bye bye...

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: InitVBint 
; Install our vertical blank handler and enable interrupts
;
;

InitVBint:
		move.l  d0,-(sp)

		move.l  #UpdateList,LEVEL0      ; Install our Auto-Vector 0 handler

		move.w  a_vde,d0
		ori.w   #1,d0                   ; Must be ODD
		move.w  d0,VI

		move.w  INT1,d0			; Enable video interrupts
		ori.w   #1,d0
		move.w  d0,INT1

		move.w  sr,d0
		and.w   #$F8FF,d0               ; Lower the 68k IPL to allow interrupts
		move.w  d0,sr

		move.l  (sp)+,d0
		rts
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Procedure: InitVideo (same as in vidinit.s)
;            Build values for hdb, hde, vdb, and vde and store them.
;
						
InitVideo:
		movem.l  d0-d6,-(sp)             
	
		move.w  CONFIG,d0               ; Also is joystick register
		andi.w  #VIDTYPE,d0             ; 0 = PAL, 1 = NTSC
		beq     palvals

		move.w  #NTSC_HMID,d2
		move.w  #NTSC_WIDTH,d0

		move.w  #NTSC_VMID,d6
		move.w  #NTSC_HEIGHT,d4

		bra     calc_vals
palvals:
		move.w  #PAL_HMID,d2
		move.w  #PAL_WIDTH,d0

		move.w  #PAL_VMID,d6
		move.w  #PAL_HEIGHT,d4

calc_vals:
		move.w  d0,width
		move.w  d4,height

		move.w  d0,d1
		asr     #1,d1                   ; Width/2

		sub.w   d1,d2                   ; Mid - Width/2
		add.w   #4,d2                   ; (Mid - Width/2)+4

		sub.w   #1,d1                   ; Width/2 - 1
		ori.w   #$400,d1                ; (Width/2 - 1)|$400
		
		move.w  d1,a_hde
		move.w  d1,HDE

		move.w  d2,a_hdb
		move.w  d2,HDB1
		move.w  d2,HDB2

		move.w  d6,d5
		sub.w   d4,d5
		move.w  d5,a_vdb

		add.w   d4,d6
		move.w  d6,a_vde

		move.w  a_vdb,VDB
		move.w  #$FFFF,VDE
			
		move.l  #0,BORD1                ; Black border
		move.w  #0,BG                   ; Init line buffer to black
			
		movem.l  (sp)+,d0-d6
		rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;; Uninitialized Data!!!

		.bss

a_hdb:          .ds.w   1
a_hde:          .ds.w   1
a_vdb:          .ds.w   1
a_vde:          .ds.w   1
width:          .ds.w   1
height:	 	.ds.w   1

		.end

