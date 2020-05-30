;
; Jaguar Example Source Code
; Copyright (c)1994 Atari Corp.
; ALL RIGHTS RESERVED
;
; Program: crypick.cof  - Easy CRY Color Picker
;  Module: cpk_init.s   - Program entry and initialization
;
; Revision History:
; 8/17/94   - SDS: Created
;----------------------------------------------------------------------------
; This program initializes the Jaguar console and creates an object list with
; five bitmap objects (besides the two branch and one stop object) as follows:
;
; 1. A 320x168 bitmap that will contain a 16x16 grid with the 256 possible
;    CRY colors (one intensity)
; 2. A 256x16 bitmap that will be used as an intensity 'Y' slider.
; 3. A 16x16 bitmap used as a pointer into the above slider
; 4. A 20x10 bitmap used to indicate the currently chosen color.
; 5. A 256x8 bitmap used to hold text to indicate the chosen CRY hex and RGB
;    percentages.
;
; The 68k will be placed into a loop which polls the joystick and updates the
; following:
;
; 1. The CR 'color slice' is redrawn in the current intensity.
; 2. The Y intensity slider is redrawn in the current color.
; 3. The color pointer and intensity slider object positions are updated
;    and will be changed during the next vertical blank.
; 4. The RGB percentages are calculated and both CRY and RGB values are
;    converted to ASCII and written into the text buffer.
;

		.include        "jaguar.inc"
		.include        "crypick.inc"

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
		.extern         BlitFill
		.extern         InitColorBars
		.extern         InitVars 
		.extern         InitSlider
		.extern         MainLoop

		.extern         RBOX_ADDR

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Program Entry Point Follows...

		.text

		move.l  #$00070007,G_END        ; big-endian mode
		move.w  #$FFFF,VI               ; disable video interrupts

		move.l  #INITSTACK,a7           ; Setup a 4k stack
			
		jsr     InitVideo               ; Setup our video registers.
		jsr     InitLister              ; Initialize Object Display List
		jsr     InitVBint               ; Initialize our VBLANK routine

		jsr     InitVars                ; Initialize Program Variables
		jsr     InitColorBars           ; Draw Color Cube
		jsr     InitSlider              ; Draw Intensity Slider
		
		move.l  d0,OLP                  ; Value in d0 from InitLister
		move.w  #$4C1,VMODE             ; Configure Video
		
loop:
		jsr     MainLoop
		bra     loop                    ; Loop forever

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

		move.w  INT1,d0                 ; Enable Video Interrupts
		ori.w   #1,d0
		move.w  d0,INT1

		move.w  sr,d0
		and.w   #$F8FF,d0               ; Lower the 68k IPL to allow interrupts
		move.w  d0,sr

		move.l  (sp)+,d0
		rts
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Procedure: InitVideo (same as in vidinit.s)
;            Build values for hdb, hde, vdb, and vde and store them.
;
						
InitVideo:
		movem.l d0-d6,-(sp)             
	
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
			
		movem.l (sp)+,d0-d6
		rts

;;;;;;;;;;;;;;;;;;;;;;;
;; Uninitialized Data
;;;;;;;;;;;;;;;;;;;;;;;

		.bss

a_hdb:          .ds.w   1
a_hde:          .ds.w   1
a_vdb:          .ds.w   1
a_vde:          .ds.w   1
width:          .ds.w   1
height: .ds.w   1

		.end

