
	.include "jaguar.inc"

	.text

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.extern	Mandle		; Do mandelbrot picture...
	.extern	start_mandGPU
	.extern	end_mandGPU
	.extern	mandGPU

	.extern	olp2set		; objectlist pointer...
	.extern	gSetOLP		; routine for setting OLP
	.extern	ticks		; video stuff...
	.extern	a_vdb
	.extern	a_vde
	.extern	a_hdb
	.extern	a_hde
	.extern	width
	.extern	height

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

bitmap_addr		.equ	$20000	; Buffer in main memory
BM_WIDTH		.equ	256	; Bitmap width in pixels
BM_HEIGHT		.equ	200	; Bitmap height in pixels
BM_DEPTH		.equ	8	; 8 bits per pixel
BM_PHRASES		.equ	((BM_WIDTH*BM_DEPTH)/64)	; phrase = 64 bits
BM_OFFSET	  	.equ    (2*8)	; Two Phrases = offset to bitmap object

MY_LISTSIZE	.equ	5	; List size in phrases:		
							; branch (1)
							; branch (1)
							; bitmap (2)
							; stop (1)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This is where we get control after the startup code...

_start::
	move.l	ticks,d0	; get the VB counter
.2:
	move.l	ticks,d1
	sub.l	d0,d1
	cmp.l	#300,d1		; Wait for 5-6 seconds (300 vb ticks)
	ble	.2

; Go make a new object list for our pictures...

	bsr	make_list

;;; Borrow Scott's Sneaky trick to cause display to popup at first VB
;;; (Change the bitmap to a STOP object, until the VB kicks in and updates it)

	move.l	#$0,my_objlist+BM_OFFSET
	move.l	#$C,my_objlist+BM_OFFSET+4

; OK, now we stick in our new object list pointer.

	move.l  d0,olp2set      	; D0 is swapped OLP from InitLister
	move.l  #gSetOLP,G_PC   	; Set GPU PC
	move.l  #RISCGO,G_CTRL  	; Go!
.1:
	move.l  G_CTRL,d0   		; Wait for write.
	andi.l  #$1,d0
	bne 	.1

; Now we stick in our new VB routine.  This 
; is OK because the move.l is atomic.

	move.l  #my_UpdateList,LEVEL0	; Install 68K LEVEL0 handler

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Copy over the GPU program

	move.l	#mandGPU,a0		; Get the address of the GPU code
	move.l	#start_mandGPU,a1	; Get destination address
	move.l	#end_mandGPU,d0		; and calculate length of GPU code
	sub.l	#start_mandGPU,d0
	asr.l	#2,d0			; divide by 4 since we're copying longs
.loop:
	move.l	(a0)+,(a1)+	; actually copy the code...
	dbra	d0,.loop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Copy the palette into the chip

	move.l	#256,d0
	move.l	#CLUT,a0
	move.l	#cry_data,a1

.cloop:
	move.w	(a1)+,(a0)+
	dbra	d0,.cloop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Now set the proper Vmode...

	move.w	#$6C1,VMODE	; Set 16 bit CRY; 320 overscanned

	bsr	clearpic

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Draw the fractal, then just bail out to an illegal instruction...

	jsr	Mandle
	illegal
	rts			;; Never get here!



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Use the blitter to clear the bitmap for our fractal picture...
; Just set up enough Blitter stuff to do a block draw.  Set A1_FLAGS to:
;
;	Contiguous data
;	16 bit per pixel
;	width of 56 pixels
;	add increment
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

clearpic:
	move.l	#PITCH1|PIXEL8|WID256|XADDPIX,d0
	move.l	d0,A1_FLAGS

; Point A1BASE to the data

	move.l	#$20000,d0
	move.l	d0,A1_BASE

; Set the pixel point to 0,0

	move.w	#0,d0			; y
	swap	d0
	move.w	#0,d0			; x
	move.l	d0,A1_PIXEL

; Set up the step size to -256 in x, 1 in y
; The x step requires that the pixel pointer by 

	move.w	#1,d0			; y
	swap	d0
	move.w	#(-256),d0		; x
	move.l	d0,A1_STEP

	move.l	#0,A1_CLIP

; Set up Counters register to 256 in x write long to clear upper
; 256 in y, or in y as a word

	move.w	#200,d0			; y
	swap	d0
	move.w	#256,d0			; x
	move.l	d0,B_COUNT

; Put some data in the blitter for it to write.

	move.l	#0,d0
	move.l	d0,B_PATD	
	move.l	#0,d0
	move.l	d0,B_PATD+4

; Now Turn IT ON !!!!!!!!!!!!!

; NO SOURCE DATA, NO OUTER LOOP, Turn on pattern data, Allow outer loop update

	move.l	#PATDSEL|UPDA1,d0
	move.l	d0,B_CMD
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; make_list: Create my Object List Processor List
;
;    Returns: Pre-word-swapped address of current object list in d0.l
;
;  Registers: d0.l/d1.l - Phrase being built
;             d2.l/d3.l - Link address overlays
;             d4.l      - Work register
;             a0.l      - Roving object list pointer
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

make_list:
		movem.l d1-d4/a0,-(sp)		; Save registers
			
		lea     my_objlist,a0
		move.l  a0,d2           	; Copy

		add.l   #(MY_LISTSIZE-1)*8,d2  	; Address of STOP object
		move.l	d2,d3			; Copy for low half

		lsr.l	#8,d2			; Shift high half into place
		lsr.l	#3,d2
		
		swap	d3			; Place low half correctly
		clr.w	d3
		lsl.l	#5,d3

; Write first BRANCH object (branch if YPOS > a_vde )

		clr.l   d0
		move.l  #(BRANCHOBJ|O_BRLT),d1  ; $4000 = VC < YPOS
		or.l	d2,d0			; Do LINK overlay
		or.l	d3,d1
								
		move.w  a_vde,d4                ; for YPOS
		lsl.w   #3,d4                   ; Make it bits 13-3
		or.w    d4,d1

		move.l	d0,(a0)+
		move.l	d1,(a0)+

; Write second branch object (branch if YPOS < a_vdb)   
; Note: LINK address is the same so preserve it

		andi.l  #$FF000007,d1           ; Mask off CC and YPOS
		ori.l   #O_BRGT,d1      	; $8000 = VC > YPOS
		move.w  a_vdb,d4                ; for YPOS
		lsl.w   #3,d4                   ; Make it bits 13-3
		or.w    d4,d1

		move.l	d0,(a0)+
		move.l	d1,(a0)+

; Write a standard BITMAP object

		move.l	d2,d0
		move.l	d3,d1

		ori.l  #BM_HEIGHT<<14,d1       ; Height of image

		move.w  height,d4           	; Center bitmap vertically
		sub.w   #BM_HEIGHT,d4
		add.w   a_vdb,d4
		andi.w  #$FFFE,d4               ; Must be even
		lsl.w   #3,d4
		or.w    d4,d1                   ; Stuff YPOS in low phrase

		move.l	#bitmap_addr,d4
		lsl.l	#8,d4
		or.l	d4,d0
	 
		move.l	d0,(a0)+
		move.l	d1,(a0)+
		movem.l	d0-d1,ol_update

; Second Phrase of Bitmap

		move.l	#BM_PHRASES>>4,d0	; Only part of top LONG is IWIDTH
		move.l  #O_DEPTH8|O_NOGAP,d1	; Bit Depth = 8-bit, Contiguous data

		move.w  width,d4            	; Get width in clocks
		lsr.w   #2,d4               	; /4 Pixel Divisor
		sub.w   #BM_WIDTH,d4
		lsr.w   #1,d4
		or.w    d4,d1

		ori.l	#(BM_PHRASES<<18)|(BM_PHRASES<<28),d1	; DWIDTH|IWIDTH

		move.l	d0,(a0)+
		move.l	d1,(a0)+

; Write a STOP object at end of list

		clr.l   (a0)+
		move.l  #(STOPOBJ|O_STOPINTS),(a0)+

; Now return swapped list pointer in D0                      

		move.l  #my_objlist,d0
		swap    d0

		movem.l (sp)+,d1-d4/a0
		rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: my_UpdateList
;        Handle Video Interrupt and update object list fields
;        destroyed by the object processor.

my_UpdateList:
		move.l  a0,-(sp)

		move.l  #my_objlist+BM_OFFSET,a0

		move.l  ol_update,(a0)      	; Phrase = d1.l/d0.l
		move.l  ol_update+4,4(a0)

		add.l	#1,ticks		; Increment ticks semaphore

		move.w  #$101,INT1      	; Signal we're done
		move.w  #$0,INT2

		move.l  (sp)+,a0
		rte

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.data

; This file has a label cry_data that has, in 68k format the top level
; of cry for 8 bits
        
	.include "cry.pal"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.phrase
	.bss
	.dphrase

my_objlist:
	.ds.l	16

ol_update:
	.ds.l	2
