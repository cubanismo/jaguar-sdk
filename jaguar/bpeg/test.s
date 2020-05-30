
	.include "jaguar.inc"

	.text

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.extern	BPEGInit	; Copy over GPU code into GPU RAM
	.extern	BPEGDecode	; Execute decode routines
	.extern	BPEGStatus	; semaphore for "finished decoding" status

	.extern	fish_jpg	; picture #1
	.extern	pat_jpg		; picture #2

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
BM_WIDTH		.equ	320	; Bitmap width in pixels
BM_HEIGHT		.equ	199	; Bitmap height in pixels (was 199)
BM_DEPTH		.equ	16	; 16 bits per pixel
BM_PHRASES		.equ	((BM_WIDTH*BM_DEPTH)/64)	; phrase = 64 bits
BM_OFFSET	  	.equ    (2*8)	; Two Phrases

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

test_jagpeg::
	bsr	BPEGInit		; copy over GPU code

.show_fish:
	lea	fish_jpg,a0		; Address of compressed picture data
	lea	bitmap_addr,a1		; Get destination address
	move.l	#((BM_WIDTH*BM_DEPTH)/8),d0	; Width of destination bitmap, in bytes
	bsr	BPEGDecode		; Decode image

.wait_fish:
	tst.l	BPEGStatus		; Wait for decompression to finish
	bmi.s	.wait_fish		; before continuing...

	lea	pat_jpg,a0		; Address of compressed picture data
	lea	bitmap_addr,a1		; Get destination address
	move.l	#((BM_WIDTH*BM_DEPTH)/8),d0	; Width of destination bitmap, in bytes
	bsr	BPEGDecode		; Decode image

.wait_patrick:
	tst.l	BPEGStatus		; Wait for decompression to finish
	bmi.s	.wait_patrick		; before continuing...

	bra	.show_fish		; Switch back and forth
	rts				; til reset or powerdown.



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
		move.l  #O_DEPTH16|O_NOGAP,d1   ; Bit Depth = 16-bit, Contiguous data

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
