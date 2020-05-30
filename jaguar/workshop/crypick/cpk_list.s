;
; Jaguar Example Source Code
; Copyright (c)1994 Atari Corp.
; ALL RIGHTS RESERVED
;
; Program: crypick.cof  - Easy CRY Color Picker
;  Module: cpk_list.s   - Object List Refresh and Initialization
;
; Revision History:
; 8/17/94   - SDS: Created


		.include        "jaguar.inc"
		.include        "crypick.inc"

		.globl          InitLister
		.globl          UpdateList

		.extern         a_vde
		.extern         a_vdb
		.extern         a_hdb
		.extern         a_hde
		.extern         width
		.extern         height

		.extern         slider_pos
		.extern         crval

		.text

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; InitLister: Initialize Object List Processor List
;
;    Returns: Pre-word-swapped address of current object list in d0.l
;
;  Registers: d1.l/d0.l - Phrase being built
;             d2.l      - Address of STOP object in destination buffer
;             d3.l      - Calculation register
;             d4.l      - Width of image in phrases
;             d5.l      - Height of image in scanlines
;             a0.l      - Roving object list pointer
		
InitLister:
		movem.l d1-d5/a0,-(sp)          ; Save registers
			
		lea     main_obj_list,a0
		move.l  a0,d2                   ; Copy

		add.l   #(LISTSIZE-1)*8,d2      ; Address of STOP object

; Write first BRANCH object (branch if a_vde < VC)

		clr.l   d1
		move.l  #(BRANCHOBJ|O_BRLT),d0  ; YPOS < VC
		jsr     format_link             ; Stuff in our LINK address
						
		move.w  a_vde,d3                ; for YPOS
		lsl.w   #3,d3                   ; Make it bits 13-3
		or.w    d3,d0

		move.l  d1,(a0)+                                
		move.l  d0,(a0)+                ; First OBJ is done.

; Write second branch object (branch if a_vdb > a_vdb)   
; Note: LINK address is the same so preserve it

		andi.l  #$FF000007,d0           ; Mask off CC and YPOS
		ori.l   #O_BRGT,d0              ; $8000 = YPOS < VC
		move.w  a_vdb,d3                ; for YPOS
		lsl.w   #3,d3                   ; Make it bits 13-3
		or.w    d3,d0

		move.l  d1,(a0)+                ; Second OBJ is done
		move.l  d0,(a0)+        

; Write a BITMAP object for the CR Map portion of the screen

		clr.l   d1
		clr.l   d0                      ; Type = BITOBJ
			
		move.l  a0,d2
		add.l   #2*8,d2

		jsr     format_link

		move.l  #CRMAP_HEIGHT,d5        ; Height of image
		move.w  d5,crmap_height         ; Store for later update

		lsl.l   #8,d5                   ; HEIGHT
		lsl.l   #6,d5
		or.l    d5,d0

		move.w  height,d3               ; Center bitmap vertically
		sub.w   #CRMAP_HEIGHT,d3
		sub.w   #YMAP_HEIGHT,d3
		sub.w   #PNTR_HEIGHT,d3
		add.w   a_vdb,d3
		andi.w  #$FFFE,d3               ; Must be even

		move.w  d3,crmap_tedge

		lsl.w   #3,d3
		or.w    d3,d0                   ; Stuff YPOS in low phrase

		move.l  #CRMAP_ADDR,d3
		andi.l  #$FFFFF0,d3
		lsl.l   #8,d3                   ; Shift bitmap_addr into position
		or.l    d3,d1
     
		move.l  d1,(a0)+
		move.l  d1,crmap_highl
		move.l  d0,(a0)+
		move.l  d0,crmap_lowl

		clr.l   d1                      ; Now phrase 2
		move.l  #O_DEPTH16|O_NOGAP,d0   ; Bit Depth = 16-bit, Contiguous data

		clr.l   d3
		move.w  width,d3
		divu    #3,d3
		ext.l   d3
		sub.w   #CRMAP_WIDTH,d3
		lsr.w   #1,d3
		
		move.w  d3,crmap_ledge  

		or.w    d3,d0

		move.l  #CRMAP_PHRASES,d4 
		move.l  d4,d3                   ; Copy for below

		lsl.l   #8,d4                   ; DWIDTH
		lsl.l   #8,d4
		lsl.l   #2,d4
		or.l    d4,d0

		lsl.l   #8,d4                   ; IWIDTH Bits 28-31
		lsl.l   #2,d4
		or.l    d4,d0

		lsr.l   #4,d3                   ; IWIDTH Bits 37-32
		or.l    d3,d1

		move.l  d1,(a0)+                ; Write second PHRASE of BITOBJ
		move.l  d0,(a0)+

; Write a BITMAP object for the YMap portion of the screen

		clr.l   d1
		clr.l   d0                      ; Type = BITOBJ
			
		move.l  a0,d2
		add.l   #2*8,d2

		jsr     format_link

		move.l  #YMAP_HEIGHT,d5         ; Height of image
		move.w  d5,ymap_height          ; Store for later update

		lsl.l   #8,d5                   ; HEIGHT
		lsl.l   #6,d5
		or.l    d5,d0

		move.w  height,d3               ; Center bitmap vertically
		sub.w   #YMAP_HEIGHT,d3
		sub.w   #PNTR_HEIGHT,d3
		add.w   a_vdb,d3
		add.w   #CRMAP_HEIGHT,d3
		add.w   #8,d3                   ; A little gap between
		andi.w  #$FFFE,d3               ; Must be even

		lsl.w   #3,d3
		or.w    d3,d0                   ; Stuff YPOS in low phrase

		move.l  #YMAP_ADDR,d3
		andi.l  #$FFFFF0,d3
		lsl.l   #8,d3                   ; Shift bitmap_addr into position
		or.l    d3,d1
     
		move.l  d1,(a0)+
		move.l  d1,ymap_highl
		move.l  d0,(a0)+
		move.l  d0,ymap_lowl

		clr.l   d1                      ; Now phrase 2
		move.l  #O_DEPTH16|O_NOGAP,d0   ; Bit Depth = 16-bit, Contiguous data

		clr.l   d3
		move.w  width,d3
		divu.w  #3,d3                   ; /4 Pixel Divisor
		ext.l   d3
		sub.w   #YMAP_WIDTH,d3
		lsr.w   #1,d3
		move.w  d3,ymap_ledge
		or.w    d3,d0

		move.l  #YMAP_PHRASES,d4 
		move.l  d4,d3                   ; Copy for below

		lsl.l   #8,d4                   ; DWIDTH
		lsl.l   #8,d4
		lsl.l   #2,d4
		or.l    d4,d0

		lsl.l   #8,d4                   ; IWIDTH Bits 28-31
		lsl.l   #2,d4
		or.l    d4,d0

		lsr.l   #4,d3                   ; IWIDTH Bits 37-32
		or.l    d3,d1

		move.l  d1,(a0)+                ; Write second PHRASE of BITOBJ
		move.l  d0,(a0)+

; Write a BITMAP object for the Intensity Pointer 

		clr.l   d1
		clr.l   d0                      ; Type = BITOBJ
			
		move.l  a0,d2
		add.l   #2*8,d2

		jsr     format_link

		move.l  #PNTR_HEIGHT,d5         ; Height of image
		move.w  d5,pntr_height          ; Store for later update

		lsl.l   #8,d5                   ; HEIGHT
		lsl.l   #6,d5
		or.l    d5,d0

		move.w  height,d3               ; Center bitmap vertically
		sub.w   #PNTR_HEIGHT,d3
		add.w   a_vdb,d3
		add.w   #CRMAP_HEIGHT,d3
		add.w   #8,d3                   ; A little gap
		add.w   #YMAP_HEIGHT,d3
		andi.w  #$FFFE,d3               ; Must be even

		lsl.w   #3,d3
		or.w    d3,d0                   ; Stuff YPOS in low phrase

		move.l  #PNTR_ADDR,d3
		andi.l  #$FFFFF0,d3
		lsl.l   #8,d3                   ; Shift bitmap_addr into position
		or.l    d3,d1
     
		move.l  d1,(a0)+
		move.l  d1,pntr_highl
		move.l  d0,(a0)+
		move.l  d0,pntr_lowl

		clr.l   d1                      ; Now phrase 2
		move.l  #O_DEPTH16|O_NOGAP,d0   ; Bit Depth = 16-bit, Contiguous data

		move.w  ymap_ledge,d3
		add.w   #128-4,d3
		or.w    d3,d0                   ; 128+4 is initial XPOS

		move.l  #PNTR_PHRASES,d4 
		move.l  d4,d3                   ; Copy for below

		lsl.l   #8,d4                   ; DWIDTH
		lsl.l   #8,d4
		lsl.l   #2,d4
		or.l    d4,d0

		lsl.l   #8,d4                   ; IWIDTH Bits 28-31
		lsl.l   #2,d4
		or.l    d4,d0

		lsr.l   #4,d3                   ; IWIDTH Bits 37-32
		or.l    d3,d1

		move.l  d1,(a0)+                ; Write second PHRASE of BITOBJ
		move.l  d0,(a0)+

; Write a BITMAP object for the Roving Box 

		clr.l   d1
		clr.l   d0                      ; Type = BITOBJ
			
		move.l  a0,d2
		add.l   #2*8,d2

		jsr     format_link

		move.l  #RBOX_HEIGHT,d5         ; Height of image
		move.w  d5,rbox_height          ; Store for later update

		lsl.l   #8,d5                   ; HEIGHT
		lsl.l   #6,d5
		or.l    d5,d0

		move.w  crmap_tedge,d3
		lsl.w   #3,d3
		or.w    d3,d0                   ; Stuff YPOS in low phrase

		move.l  #RBOX_ADDR,d3
		andi.l  #$FFFFF0,d3
		lsl.l   #8,d3                   ; Shift bitmap_addr into position
		or.l    d3,d1
     
		move.l  d1,(a0)+
		move.l  d1,rbox_highl
		move.l  d0,(a0)+
		move.l  d0,rbox_lowl

		move.l  #O_TRANS,d1             ; Now phrase 2
		move.l  #O_DEPTH16|O_NOGAP,d0   ; Bit Depth = 16-bit, Contiguous data

		or.w    crmap_ledge,d0

		move.l  #RBOX_PHRASES,d4 
		move.l  d4,d3                   ; Copy for below

		lsl.l   #8,d4                   ; DWIDTH
		lsl.l   #8,d4
		lsl.l   #2,d4
		or.l    d4,d0

		lsl.l   #8,d4                   ; IWIDTH Bits 28-31
		lsl.l   #2,d4
		or.l    d4,d0

		lsr.l   #4,d3                   ; IWIDTH Bits 37-32
		or.l    d3,d1

		move.l  d1,(a0)+                ; Write second PHRASE of BITOBJ
		move.l  d0,(a0)+

; Write a BITMAP object for the Text Line 

		clr.l   d1
		clr.l   d0                      ; Type = BITOBJ
			
		move.l  a0,d2
		add.l   #2*8,d2

		jsr     format_link

		move.l  #TEXT_HEIGHT,d5         ; Height of image
		move.w  d5,text_height          ; Store for later update

		lsl.l   #8,d5                   ; HEIGHT
		lsl.l   #6,d5
		or.l    d5,d0

		move.w  height,d3               ; Center bitmap vertically
		sub.w   #TEXT_HEIGHT,d3
		add.w   a_vdb,d3
		add.w   #CRMAP_HEIGHT,d3
		add.w   #8,d3                   ; A gap constant
		add.w   #YMAP_HEIGHT,d3
		add.w   #PNTR_HEIGHT*2,d3
		andi.w  #$FFFE,d3               ; Must be even

		lsl.w   #3,d3
		or.w    d3,d0                   ; Stuff YPOS in low phrase

		move.l  #TEXT_ADDR,d3
		andi.l  #$FFFFF0,d3
		lsl.l   #8,d3                   ; Shift bitmap_addr into position
		or.l    d3,d1
     
		move.l  d1,(a0)+
		move.l  d1,text_highl
		move.l  d0,(a0)+
		move.l  d0,text_lowl

		clr.l   d1                      ; Now phrase 2
		move.l  #O_DEPTH1|O_NOGAP,d0    ; Bit Depth = 1-bit, Contiguous data

		clr.l   d3
		move.w  width,d3
		divu.w  #3,d3                   ; Pixel Divisor
		ext.l   d3
		sub.w   #TEXT_WIDTH,d3
		lsr.w   #1,d3
		or.w    d3,d0

		move.l  #TEXT_PHRASES,d4 
		move.l  d4,d3                   ; Copy for below

		lsl.l   #8,d4                   ; DWIDTH
		lsl.l   #8,d4
		lsl.l   #2,d4
		or.l    d4,d0

		lsl.l   #8,d4                   ; IWIDTH Bits 28-31
		lsl.l   #2,d4
		or.l    d4,d0

		lsr.l   #4,d3                   ; IWIDTH Bits 37-32
		or.l    d3,d1

		move.l  d1,(a0)+                ; Write second PHRASE of BITOBJ
		move.l  d0,(a0)+

; Write a STOP object at end of list
		clr.l   d1
		move.l  #(STOPOBJ|O_STOPINTS),d0

		move.l  d1,(a0)+                
		move.l  d0,(a0)+

; Now return swapped list pointer in D0                      

		move.l  #main_obj_list,d0  
		swap    d0

		movem.l (sp)+,d1-d5/a0
		rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: format_link
;
;    Inputs: d1.l/d0.l is a 64-bit phrase
;            d2.l contains the LINK address to put into bits 42-24 of phrase
;
;   Returns: Updated phrase in d1.l/d0.l

format_link:
		movem.l d2-d3,-(sp)

		andi.l  #$3FFFF8,d2             ; Ensure alignment/valid address
		move.l  d2,d3                   ; Make a copy

		swap    d2                      ; This section places bits 10-3
		clr.w   d2                      ; in bits 31-24. It saves cycles
		lsl.l   #5,d2                   ; over using three shifts.
		or.l    d2,d0

		lsr.l   #8,d3                   ; Put bits 21-11 in bits 42-32
		lsr.l   #3,d3
		or.l    d3,d1

		movem.l (sp)+,d2-d3             ; Restore regs
		rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; UpdateList: Update list fields destroyed by the object processor.
;
;  Registers:   a0.l      - General Purpose Pointer

UpdateList:
		movem.l a0/d0-d1,-(sp)

		movea.l #main_obj_list+CRMAP_OFF,a0     ; Color Cube

		move.l  crmap_highl,(a0)+               
		move.l  crmap_lowl,(a0)

		movea.l #main_obj_list+YMAP_OFF,a0      ; Intensity Slider

		move.l  ymap_highl,(a0)+                
		move.l  ymap_lowl,(a0)

		movea.l #main_obj_list+PNTR_OFF,a0      ; Intensity Pointer

		move.l  pntr_highl,(a0)+                
		move.l  pntr_lowl,(a0)+

		andi.w  #$F000,6(a0)                    ; Clear old XPOS
		move.w  ymap_ledge,d0                   ; Left edge of slider
		add.w   slider_pos,d0                   ; + slider offset
		sub.w   #3,d0                           ; - 1/2 slider size
		or.w    d0,6(a0)                        ; Now stuff it back.

		movea.l #main_obj_list+RBOX_OFF,a0      ; Roving Color Selector
		move.l  rbox_highl,(a0)+
		move.l  rbox_lowl,d0

		andi.w  #$C007,d0                       ; Extract YPOS

		move.w  crval,d1                        ; Get Cyan Component
		lsr.w   #4,d1                           
		mulu    #10,d1                          ; Multiply x10 (Height)
		lsl.w   #1,d1                           ; x2 for half-lines
		add.w   crmap_tedge,d1                  ; + top edge of cube

		lsl.w   #3,d1                           ; shift into place
		or.w    d1,d0                           ; and store it
		move.l  d0,(a0)+

		andi.w  #$F000,6(a0)                    ; Extract XPOS
		move.w  crval,d0                        ; Get Red Component
		andi.w  #$F,d0
		mulu    #20,d0                          ; Multiply x20 (Width)
		add.w   crmap_ledge,d0                  ; + left edge of cube
		or.w    d0,6(a0)                        ; ...and store it

		movea.l #main_obj_list+TEXT_OFF,a0      ; Text Information Object
		move.l  text_highl,(a0)+
		move.l  text_lowl,(a0)

		move.w  #$101,INT1                      ; Signal we're done.
		move.w  #$0,INT2

		movem.l (sp)+,a0/d0-d1
		rte

		.data
		.phrase

;;; Pixel Data for Roving Color Picker

RBOX_ADDR:
		.dc.w   $88FF,$88FF,$88FF,$88FF,$88FF,$88FF,$88FF,$88FF,$88FF,$88FF
		.dc.w   $88FF,$88FF,$88FF,$88FF,$88FF,$88FF,$88FF,$88FF,$88FF,$88FF
		.dc.w   $88FF,$0100,$0100,$0100,$0100,$0100,$0100,$0100,$0100,$0100
		.dc.w   $0100,$0100,$0100,$0100,$0100,$0100,$0100,$0100,$0100,$88FF
		.dc.w   $88FF,$0100,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
		.dc.w   $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0100,$88FF
		.dc.w   $88FF,$0100,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
		.dc.w   $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0100,$88FF
		.dc.w   $88FF,$0100,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
		.dc.w   $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0100,$88FF
		.dc.w   $88FF,$0100,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
		.dc.w   $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0100,$88FF
		.dc.w   $88FF,$0100,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
		.dc.w   $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0100,$88FF
		.dc.w   $88FF,$0100,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
		.dc.w   $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0100,$88FF
		.dc.w   $88FF,$0100,$0100,$0100,$0100,$0100,$0100,$0100,$0100,$0100
		.dc.w   $0100,$0100,$0100,$0100,$0100,$0100,$0100,$0100,$0100,$88FF
		.dc.w   $88FF,$88FF,$88FF,$88FF,$88FF,$88FF,$88FF,$88FF,$88FF,$88FF
		.dc.w   $88FF,$88FF,$88FF,$88FF,$88FF,$88FF,$88FF,$88FF,$88FF,$88FF

;;; Pixel Data for Intensity Pointer

PNTR_ADDR:
		.dc.w   $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
		.dc.w   $0000,$0000,$0000,$88FF,$0000,$0000,$0000,$0000
		.dc.w   $0000,$0000,$88FF,$88FF,$88FF,$0000,$0000,$0000
		.dc.w   $0000,$88FF,$88FF,$88FF,$88FF,$88FF,$0000,$0000
		.dc.w   $88FF,$88FF,$88FF,$88FF,$88FF,$88FF,$88FF,$0000
		.dc.w   $88FF,$88FF,$88FF,$88FF,$88FF,$88FF,$88FF,$0000
		.dc.w   $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
		.dc.w   $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
		
		.bss
		.dphrase                        

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Storage space for our object list

main_obj_list:
		.ds.l           LISTSIZE*2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; These values hold good object data for update during the vertical blank

crmap_height:   .ds.w           1
crmap_highl:    .ds.l           1
crmap_lowl:     .ds.l           1

ymap_height:    .ds.w           1
ymap_highl:     .ds.l           1
ymap_lowl:      .ds.l           1

pntr_height:    .ds.w           1
pntr_highl:     .ds.l           1
pntr_lowl:      .ds.l           1

rbox_height:    .ds.w           1
rbox_highl:     .ds.l           1
rbox_lowl:      .ds.l           1

text_height:    .ds.w           1
text_highl:     .ds.l           1
text_lowl:      .ds.l           1

ymap_ledge:     .ds.w           1
crmap_ledge:    .ds.w           1
crmap_tedge:    .ds.w           1


		.end
