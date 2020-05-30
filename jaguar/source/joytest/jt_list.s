;
; Jaguar Example Source Code
; Copyright (c)1994 Atari Corp.
; ALL RIGHTS RESERVED
;
; Program: joytest.cof		- Joystick reading example
;  Module: jt_list.s   	- Object List Refresh and Initialization
;
; Revision History:
; 9/2/94   - SDS: Created

		.include      	"jaguar.inc"
		.include      	"joytest.inc"

		.globl        	InitLister
		.globl		UpdateList

		.globl		curs1_x
		.globl		curs1_y
		.globl		curs2_x
		.globl		curs2_y
		
		.globl		fire1_data
		.globl		fire2_data

		.globl		key1_data
		.globl		key2_data

		.globl		frame_cnt
		
		.extern       	a_vde
		.extern       	a_vdb
		.extern       	a_hdb
		.extern       	a_hde
		.extern		width
		.extern		height

		.extern		cursor_data

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
		movem.l d1-d5/a0,-(sp)		; Save registers
			
		lea	main_obj_list,a0
		move.l	a0,d2			; Copy

		add.l   #(LISTSIZE-1)*8,d2	; Address of STOP object

; Write first BRANCH object (branch if YPOS > a_vde )

		clr.l   d1
		move.l  #(BRANCHOBJ|O_BRLT),d0	; $4000 = VC < YPOS
		jsr     format_link             ; Stuff in our LINK address
						
		move.w  a_vde,d3                ; for YPOS
		lsl.w   #3,d3                   ; Make it bits 13-3
		or.w    d3,d0

		move.l  d1,(a0)+                                
		move.l  d0,(a0)+                ; First OBJ is done.

; Write second branch object (branch if YPOS < a_vdb)   
; Note: LINK address is the same so preserve it

		andi.l  #$FF000007,d0           ; Mask off CC and YPOS
		ori.l   #O_BRGT,d0		; $8000 = VC > YPOS
		move.w  a_vdb,d3                ; for YPOS
		lsl.w   #3,d3                   ; Make it bits 13-3
		or.w   	d3,d0

		move.l 	d1,(a0)+                ; Second OBJ is done
		move.l 	d0,(a0)+        

; Write first object (CURSOR for JOYPAD 1)
		clr.l  	d1
		clr.l  	d0                      ; Type = BITOBJ
		
		move.l	a0,d2			; Link to next bitmap
		add.l	#16,d2
		jsr    	format_link

		move.l	#CURS_HEIGHT,d5         ; Height of image
		lsl.l   #8,d5                   
		lsl.l   #6,d5
		or.l    d5,d0

		move.w	curs1_y,d3
		andi.w  #$FFFE,d3               ; Must be even

		lsl.w   #3,d3
		or.w    d3,d0                   ; Stuff YPOS in low phrase

		move.l  #cursor_data,d3
		andi.l  #$FFFFF0,d3
		lsl.l   #8,d3                   ; Shift bitmap_addr into position
		or.l    d3,d1
     
		move.l  d1,(a0)+
		move.l	d1,curs1_highl
		move.l  d0,(a0)+
		move.l	d0,curs1_lowl

		clr.l	d1
		move.l  #O_DEPTH8|O_NOGAP,d0   ; Bit Depth = 16-bit, Contiguous data

		or.w	curs1_x,d0		; XPOS

		move.l  #CURS_PHRASES,d4 
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

; Write object (CURSOR for JOYPAD 2)
		clr.l  	d1
		clr.l  	d0                      ; Type = BITOBJ
			
		move.l	a0,d2			; Link to next bitmap
		add.l	#16,d2
		jsr    	format_link

		move.l	#CURS_HEIGHT,d5         ; Height of image
		lsl.l   #8,d5                   
		lsl.l   #6,d5
		or.l    d5,d0

		move.w	curs2_y,d3
		andi.w  #$FFFE,d3               ; Must be even

		lsl.w   #3,d3
		or.w    d3,d0                   ; Stuff YPOS in low phrase

		move.l  #cursor_data,d3
		andi.l  #$FFFFF0,d3
		lsl.l   #8,d3                   ; Shift bitmap_addr into position
		or.l    d3,d1
     
		move.l  d1,(a0)+
		move.l	d1,curs2_highl
		move.l  d0,(a0)+
		move.l	d0,curs2_lowl

		clr.l	d1
		move.l  #O_DEPTH8|O_NOGAP,d0   ; Bit Depth = 16-bit, Contiguous data

		or.w	curs2_x,d0		; XPOS

		move.l  #CURS_PHRASES,d4 
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

; Write object (FIRE TEXT for JOYPAD 1)
		clr.l  	d1
		clr.l  	d0                      ; Type = BITOBJ
			
		move.l	a0,d2			; Link to next bitmap
		add.l	#16,d2
		jsr    	format_link

		move.l	#CHAR_HEIGHT,d5         ; Height of image
		lsl.l   #8,d5                   
		lsl.l   #6,d5
		or.l    d5,d0

		move.w	#FIRE_Y,d3
		andi.w  #$FFFE,d3               ; Must be even

		lsl.w   #3,d3
		or.w    d3,d0                   ; Stuff YPOS in low phrase

		move.l  fire1_data,d3
		andi.l  #$FFFFF0,d3
		lsl.l   #8,d3                   ; Shift bitmap_addr into position
		or.l    d3,d1
     
		move.l  d1,(a0)+
		move.l	d1,fire1_highl
		move.l  d0,(a0)+
		move.l	d0,fire1_lowl

		clr.l	d1
		move.l  #O_DEPTH8|O_NOGAP,d0   ; Bit Depth = 16-bit, Contiguous data

		or.w	#FIRE_X,d0		; XPOS

		move.l  #CHAR_PHRASES,d4 
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

; Write object (FIRE TEXT for JOYPAD 2)
		clr.l  	d1
		clr.l  	d0                      ; Type = BITOBJ
			
		move.l	a0,d2			; Link to next bitmap
		add.l	#16,d2
		jsr    	format_link

		move.l	#CHAR_HEIGHT,d5         ; Height of image
		lsl.l   #8,d5                   
		lsl.l   #6,d5
		or.l    d5,d0

		move.w	#FIRE_Y,d3
		andi.w  #$FFFE,d3               ; Must be even

		lsl.w   #3,d3
		or.w    d3,d0                   ; Stuff YPOS in low phrase

		move.l  fire2_data,d3
		andi.l  #$FFFFF0,d3
		lsl.l   #8,d3                   ; Shift bitmap_addr into position
		or.l    d3,d1
     
		move.l  d1,(a0)+
		move.l	d1,fire2_highl
		move.l  d0,(a0)+
		move.l	d0,fire2_lowl

		clr.l	d1
		move.l  #O_DEPTH8|O_NOGAP,d0   ; Bit Depth = 16-bit, Contiguous data

		or.w	#FIRE_X+100,d0		; XPOS

		move.l  #CHAR_PHRASES,d4 
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

; Write object (KEYPAD TEXT for JOYPAD 1)
		clr.l  	d1
		clr.l  	d0                      ; Type = BITOBJ
			
		move.l	a0,d2			; Link to next bitmap
		add.l	#16,d2
		jsr    	format_link

		move.l	#CHAR_HEIGHT,d5         ; Height of image
		lsl.l   #8,d5                   
		lsl.l   #6,d5
		or.l    d5,d0

		move.w	#KEY_Y,d3
		andi.w  #$FFFE,d3               ; Must be even

		lsl.w   #3,d3
		or.w    d3,d0                   ; Stuff YPOS in low phrase

		move.l  key1_data,d3
		andi.l  #$FFFFF0,d3
		lsl.l   #8,d3                   ; Shift bitmap_addr into position
		or.l    d3,d1
     
		move.l  d1,(a0)+
		move.l	d1,key1_highl
		move.l  d0,(a0)+
		move.l	d0,key1_lowl

		clr.l	d1
		move.l  #O_DEPTH8|O_NOGAP,d0   ; Bit Depth = 16-bit, Contiguous data

		or.w	#KEY_X,d0		; XPOS

		move.l  #CHAR_PHRASES,d4 
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

; Write object (KEYPAD TEXT for JOYPAD 2)
		clr.l  	d1
		clr.l  	d0                      ; Type = BITOBJ
			
		move.l	a0,d2			; Link to next bitmap
		add.l	#16,d2
		jsr    	format_link

		move.l	#CHAR_HEIGHT,d5         ; Height of image
		lsl.l   #8,d5                   
		lsl.l   #6,d5
		or.l    d5,d0

		move.w	#KEY_Y,d3
		andi.w  #$FFFE,d3               ; Must be even

		lsl.w   #3,d3
		or.w    d3,d0                   ; Stuff YPOS in low phrase

		move.l  key2_data,d3
		andi.l  #$FFFFF0,d3
		lsl.l   #8,d3                   ; Shift bitmap_addr into position
		or.l    d3,d1
     
		move.l  d1,(a0)+
		move.l	d1,key2_highl
		move.l  d0,(a0)+
		move.l	d0,key2_lowl

		clr.l	d1
		move.l  #O_DEPTH8|O_NOGAP,d0   ; Bit Depth = 16-bit, Contiguous data

		or.w	#KEY_X+100,d0		; XPOS

		move.l  #CHAR_PHRASES,d4 
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

		move.l	#main_obj_list,d0  
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

		swap	d2                   	; Put bits 10-3 in bits 31-24
		clr.w	d2
		lsl.l   #5,d2
		or.l    d2,d0

		lsr.l   #8,d3                   ; Put bits 21-11 in bits 42-32
		lsr.l   #3,d3
		or.l    d3,d1

		movem.l (sp)+,d2-d3             ; Restore regs
		rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; UpdateList: Update list fields destroyed by the object processor.
;
;  Registers:	a0.l      - General Purpose Pointer
;		d1.l/d0.l - Phrase working registers
UpdateList:
		movem.l	a0/d0-d2,-(sp)

		add.w	#1,frame_cnt

		move.l	#main_obj_list+BITMAP_OFF,a0
; First Cursor
		move.l	curs1_highl,(a0)+		
		move.l	curs1_lowl,d0

		andi.l	#$FFFFC007,d0		; Strip YPOS
		move.w	curs1_y,d2
		lsl.w	#3,d2
		or.w	d2,d0			; New YPOS
		move.l	d0,(a0)+		; Store it

		tst.l	(a0)+			; Skip next long
		move.l	(a0),d0
		andi.l	#$FFFFF000,d0		; Strip XPOS
		or.w	curs1_x,d0
		move.l	d0,(a0)+

; Second Cursor
		move.l	curs2_highl,(a0)+		
		move.l	curs2_lowl,d0

		andi.l	#$FFFFC007,d0		; Strip YPOS
		move.w	curs2_y,d2
		lsl.w	#3,d2
		or.w	d2,d0			; New YPOS
		move.l	d0,(a0)+		; Store it

		tst.l	(a0)+			; Skip next long
		move.l	(a0),d0
		andi.l	#$FFFFF000,d0		; Strip XPOS
		or.w	curs2_x,d0
		move.l	d0,(a0)+
; Fire TEXT 1
		move.l	fire1_highl,d1
		andi.l	#$7FF,d1		; Strip DATA
		move.l	fire1_data,d2
		andi.l	#$FFFFF8,d2
		lsl.l	#8,d2
		or.l	d2,d1

		move.l	d1,(a0)+		; Store recomputed
		move.l	fire1_lowl,(a0)+	; No change

		add.l	#8,a0			; Skip a phrase
; Fire TEXT 2
		move.l	fire2_highl,d1
		andi.l	#$7FF,d1		; Strip DATA
		move.l	fire2_data,d2
		andi.l	#$FFFFF8,d2
		lsl.l	#8,d2
		or.l	d2,d1

		move.l	d1,(a0)+		; Store recomputed
		move.l	fire2_lowl,(a0)+	; No change

		add.l	#8,a0			; Skip a phrase
; Keypad TEXT 1
		move.l	key1_highl,d1
		andi.l	#$7FF,d1		; Strip DATA
		move.l	key1_data,d2
		andi.l	#$FFFFF8,d2
		lsl.l	#8,d2
		or.l	d2,d1

		move.l	d1,(a0)+		; Store recomputed
		move.l	key1_lowl,(a0)+		; No change

		add.l	#8,a0			; Skip a phrase
; Keypad TEXT 2
		move.l	key2_highl,d1
		andi.l	#$7FF,d1		; Strip DATA
		move.l	key2_data,d2
		andi.l	#$FFFFF8,d2
		lsl.l	#8,d2
		or.l	d2,d1

		move.l	d1,(a0)+		; Store recomputed
		move.l	key2_lowl,(a0)+		; No change

		add.l	#8,a0			; Skip a phrase
; Exit interrupt
		move.w	#$101,INT1		; Signal we're done
		move.w	#$0,INT2

		movem.l	(sp)+,a0/d0-d2
		rte

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Storage space for our object lists

		.bss
		.dphrase			

main_obj_list:
		.ds.l           LISTSIZE*2

frame_cnt:	.ds.w		1

curs1_highl:	.ds.l		1
curs1_lowl: 	.ds.l		1
curs2_highl:	.ds.l		1
curs2_lowl: 	.ds.l		1
fire1_highl:	.ds.l		1
fire1_lowl:	.ds.l		1
fire2_highl:	.ds.l		1
fire2_lowl:	.ds.l		1
key1_highl:	.ds.l		1
key1_lowl:	.ds.l		1
key2_highl:	.ds.l		1
key2_lowl:	.ds.l		1

curs1_x:	.ds.w		1
curs1_y:	.ds.w		1
curs2_x:	.ds.w		1
curs2_y:	.ds.w		1

fire1_data:	.ds.l		1
fire2_data:	.ds.l		1

key1_data:	.ds.l		1
key2_data:	.ds.l		1

		.end
