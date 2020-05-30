;
; Jaguar Example Source Code
; Jaguar Workshop Series #12
; Copyright (c)1994 Atari Corp.
; ALL RIGHTS RESERVED
;
; Program: jr.cof       - Blitter Bitmap Rotation
;  Module: jr_clr.s     - Bitmap Initialization with the Blitter
;
; Revision History:
;  7/27/94 - SDS: Modified from Eric S's code in JAGROT
;  8/29/94 - SDS: Removed initialization of Blitter variables not used
;

		.include        "jaguar.inc"
		.include        "jr.inc"

		.globl          BlitClear

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Use the Blitter to quickly clear a block of memory.

BlitClear:
		move.l  d0,-(sp)

		move.l  B_CMD,d0
		andi.w  #$1,d0                  ; Ensure the blitter is idle
		beq     BlitClear

		move.l  #PITCH1|PIXEL16|WID320|XADDPHR,d0
		move.l  d0,A1_FLAGS

		move.l  #BMP_ADDR,d0            ; Point at the bitmap buffer
		move.l  d0,A1_BASE

		move.w  #0,d0                   ; Y = 0
		swap    d0
		move.w  #0,d0                   ; X = 0
		move.l  d0,A1_PIXEL

		move.w  #0,d0                   ; Y = 1
		swap    d0
		move.w  #4,d0                   ; X = 4 (Phrase Mode)
		move.l  d0,A1_INC

; For each new scanline, decrement X by scanline width and increase Y by 1.

		move.w  #1,d0                   ; Y = 1
		swap    d0
		move.w  #(-BMP_WIDTH),d0        ; X = -BMP_WIDTH
		move.l  d0,A1_STEP

		move.l	#0,A1_CLIP

; Set pixel size for rectangle.

		move.w  #BMP_HEIGHT,d0          ; Pixel Extents of block
		swap    d0
		move.w  #BMP_WIDTH,d0           
		move.l  d0,B_COUNT

; Define a solid color value in the pattern registers so that the boundaries
; of our next blit will be visible.

		move.l  #$20A020A0,d0
		move.l  d0,B_PATD       
		move.l  d0,B_PATD+4

; Turn on pattern data
; Allow outer loop update

		move.l  #PATDSEL|UPDA1,d0
; Engage...
		move.l  d0,B_CMD

		move.l  (sp)+,d0
		rts

		.end
