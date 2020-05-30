;
; Jaguar Example Source Code
; Copyright (c)1994 Atari Corp.
; ALL RIGHTS RESERVED
;
; Program: crypick.cof  - Blitter Bitmap Rotation
;  Module: cpk_blit.s   - Various Blitter Routines
;
; Revision History:
;  7/27/94 - SDS: Modified from Eric S's code in JAGROT
;  8/24/94 - SDS: Added all Blitter routines to this global module.
;

		.include        "jaguar.inc"

		.globl          BlitFill
		.globl          BlitMask
		.globl          BlitShade


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: BlitFill
;            Use the Blitter to quickly copy a value into a block of memory.
;
; Inputs:
;
; a0.l  = Bitmap Pointer
; d2.w = X Offset (Must be phrase bit-aligned)
; d3.w = Y Offset
; d4.w = CRY Color
; d5.w = Width
; d6.w = Width Code
; d7.w = Height

BlitFill:
		move.l  d0,-(sp)
.wait:
		move.l  B_CMD,d0        ; Ensure the blitter is idle
		andi.l  #1,d0
		beq     .wait

; Blit a contiguous (PITCH1) block of 16-bit CRY (PIXEL16) data
; in phrase mode (XADDPHR)

		move.l  #PITCH1|PIXEL16|XADDPHR,d0

		or.w    d6,d0           ; OR Width code parameter
		move.l  d0,A1_FLAGS

		move.l  a0,A1_BASE      ; Address of bitmap

		move.w  d3,d0           ; Y Pixel Offset                        
		swap    d0
		move.w  d2,d0           ; X Pixel Offset                
		move.l  d0,A1_PIXEL

		move.w  #0,d0           ; Step 0 Y Pixels (Inner Loop)                  
		swap    d0
		move.w  #4,d0           ; Step 4 X Pixels (Phrase)      
		move.l  d0,A1_INC

; For each new scanline, decrement X by scanline width and increase Y by 1.

		move.w  #1,d0           ; Y = 1
		swap    d0
		move.w  d5,d0           ; Scanline X width
		neg     d0              ; make negative
		move.l  d0,A1_STEP

		move.l  #0,A1_CLIP

; Set pixel size for rectangle.

		move.w  d7,d0           ; Y Pixel Height                     
		swap    d0
		move.w  d5,d0           ; X Pixel Width         
		move.l  d0,B_COUNT

; Define a solid color value in the pattern registers so that the boundaries
; of our next blit will be visible.

		move.w  d4,d0           ; Duplicate parameter
		swap    d0              ; in both words
		move.w  d4,d0

		move.l  d0,B_PATD       ; Place in both LONGs of PHRASE wide
		move.l  d0,B_PATD+4     ; register

; Pattern Data as Source/Update A1 each outer loop

		move.l  #PATDSEL|UPDA1,d0
; Engage...
		move.l  d0,B_CMD        ; Start the blitter

		move.l  (sp)+,d0
		rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: BlitShade
;             Modify of a block of CRY 16-bit data with the ADDER
;
; Inputs:
; a0.l  = Bitmap Pointer
; d0.l = Intensity Increment
; d2.w = Width
; d3.w = Width Code
; d4.w = Height

BlitShade:
		move.l  d7,-(sp)
.wait:
		move.l  B_CMD,d7        ; Wait for the blitter to be idle
		andi.l  #1,d7
		beq     .wait

; Blit a block of contiguous data (PITCH1) in 16-bit CRY (PIXEL16)
; phrase mode (XADDPHR).

		move.l  #PITCH1|PIXEL16|XADDPHR,d7

		or.w    d3,d7           ; OR Blitter width field
		move.l  d7,A1_FLAGS

		move.l  a0,A1_BASE      ; Address of bitmap

		move.l  #0,A1_PIXEL     ; X = 0, Y = 0 

		move.l  #$00000004,A1_INC       ; Step 0 Y pixels, 4 X pixels

; For each new scanline, decrement X by scanline width and increase Y by 1.

		move.w  #1,d7                   ; Y = 1
		swap    d7
		move.w  d2,d7                   ; X = -(width in pixels) 
		neg     d7
		move.l  d7,A1_STEP

		move.l  #0,A1_CLIP

; Set pixel size for rectangle.

		move.w  d4,d7           ; Y size in pixels                   
		swap    d7
		move.w  d2,d7           ; X size in pixels      
		move.l  d7,B_COUNT

; Value to be added is placed in Source Data Register. Each field C, R, and Y
; is a signed value added to the destination.
		move.l  d0,B_SRCD
		move.l  d0,B_SRCD+4     
	      
; Enable Destination Reads/Enable Adder/Update A1 each outer loop iteration
		move.l  #DSTEN|ADDDSEL|UPDA1,d7
; Engage...
		move.l  d7,B_CMD        ; Start the blitter

		move.l  (sp)+,d7
		rts

		.end
