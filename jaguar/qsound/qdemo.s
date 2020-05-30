
	.include	"jaguar.inc"
	.include	"vidstuff.inc"
	.text

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	.extern	qdemo

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Now set the proper Vmode...

	move.w	#$6C7,VMODE	; Set 16 bit RGB; 320 overscanned
	bsr	clearpic

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Draw the fractal, then just bail out to an illegal instruction...

	jsr	qdemo
	illegal
	rts			;; Never get here!


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Use the blitter to clear the bitmap for our fractal picture...
; Just set up enough Blitter stuff to do a block draw.  Set A1_FLAGS to:
;
;	Contiguous data
;	16 bit per pixel
;	width of 320 pixels
;	add increment
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

clearpic:
	move.l	#PITCH1|PIXEL16|WID320|XADDPIX,d0
	move.l	d0,A1_FLAGS

; Point A1BASE to the data

	move.l	#bitmap_addr,d0
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
	move.w	#(-BM_WIDTH),d0		; x
	move.l	d0,A1_STEP

	move.l	#0,A1_CLIP

; Set up Counters register to 256 in x write long to clear upper
; 256 in y, or in y as a word

	move.w	#BM_HEIGHT,d0		; y
	swap	d0
	move.w	#BM_WIDTH,d0			; x
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
		move.l  #O_DEPTH16|O_NOGAP,d1	; Bit Depth = 16-bit, Contiguous data

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

	.phrase
	.bss
	.dphrase

my_objlist:
	.ds.l	16

ol_update:
	.ds.l	2
