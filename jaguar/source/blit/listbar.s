;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Please read this while referring to the document 'Object list format'
; 
; This is a routine setting up the object list every time it is called
; from the interrupt service routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.include	'jaguar.inc'

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.globl		Lister		

	.extern		listbuf
	.extern		a_vde
	.extern		a_vdb

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PATTERN		equ	$20000

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; At this point I will attempt to set up an object list
;
; This list will contain a single bitmap object and a stop object.  
; The two branch objects at the beginning are neccesary to keep the
; hardware happy.
;
; The bitmap object width will be 56 pixels wide (14 phrases).
; The height will be 200 pixels, the depth is 4 bit (16 colors).
 
Lister:
	move.l	#listbuf,d0		; Space allocated for Object List
	and.l	#$ffffffe0,d0		; Assure 32 byte alignment
	move.l	d0,d5			; save address for later
	move.l	d0,a0			; a0 has the ACTUAL OL start 

; At this point we must add two branch objects to keep the hardware happy!
; the first one branches if greater than n_vde
; the next one branches if less than n_vdb
; first phrase has its link address (in phrases) shifted down by eight bits

	add.l	#32,d0			; will be the address of the stop object

	lsr.l	#3,d0			; in phrase notation

	move.l	d0,d2			; save stopobj address for later use
	lsr.l	#8,d0			; shift down link address by 8 bits
	move.l	d0,(a0)+		; write high longword
	move.l	d2,d0			; get stopobj address (in phrases) 
	moveq	#24,d1			; bit position of LINK field
	lsl.l	d1,d0			; shift into position of field LINK 
	or.l	#3,d0			; or in type bits for branch object
	move.w	a_vde,d3		; get y_pos for branch 
	ext.l	d3			;
	lsl.l	#3,d3			; move to the correct bit position			
	or.l	d3,d0			; or in ypos 
	or.l	#2<<14,d0		; bit 15,14 = 1,0: branch greater than
	move.l	d0,(a0)+		; wirte low longword

	move.l	d2,d0			; again get stopobj address
	lsr.l	#8,d0			; shift down link address by 8  
	move.l	d0,(a0)+		; shift into position of field LINK
	move.l	d2,d0			; get stopobj address (in phrases) 
	moveq	#24,d1			; bit position of LINK field
	lsl.l	d1,d0			; or in type bits for branch object
	ori.l	#3,d0			; make it a branch object
	move.w	a_vdb,d3		; get y_pos for branch
	ext.l	d3			;
	lsl.l	#3,d3			; move to correct bit position 
	or.l	d3,d0			; or in ypos
	or.l	#1<<14,d0		; bit 15,14 = 1,0: branch less than
	move.l	d0,(a0)+		; write low long
					; branch objects done

; then we setup high longword of phrase 1 of the bitmap object

 	move.l	#PATTERN,d0		; get data address
	moveq	#8,d1			; shift constant 8
	lsl.l	d1,d0			; shift to position
	and.l	#$fffff800,d0		; mask off junk
	move.l	d0,(a0)			; high longword: store data pointer 

; This places the partial result in the correct spot in memory
; Then, in the next part, it 'or's the rest of the data in.
; Doing it all in registers would be faster, 
; but I want to see the results

	move.l	d5,d0			; This points to the start of the OL
	add.l	#36,d0			; Point to the next object
	move.l	d0,d2			; Save linkpointer for bottom half
	moveq	#11,d1			; shift constant: cut off low bits 
	lsr.l	d1,d0			; shift: take top 11 bits 
	or.l	d0,(a0)+		; or in new data, high longword ready
					

; do the bottom half in the next long word

	moveq	#21,d1			; shift constant for low bits
	lsl.l	d1,d2			; shift for linkpointer bottom part
	and.l	#$ff000000,d2		; mask off junk
	move.l	d2,(a0)			; store (prematurely)

; Same comment here about doing this in registers instead of memory

	move.w	#200,d0			; this is the height (fixed @200)
	moveq	#14,d1			; shift constant for field height
	lsl.l	d1,d0			; shift it 
	or.l	d0,(a0)			; or in the height data
	move.w	a_vdb,d0		; get a_vdb from global data
	ext.l	d0
	add.l	#40,d0			; set the YPOS @ a_vdb+40
	lsl.l	#3,d0			; shift to position of field YPOS
	or.l	d0,(a0)			; or in the new data
	or.l	#0,(a0)+		; or in the object type (this case 0)

; That completes another long word, first phrase done

	moveq.l	#0,d0			; all zero

; if you don't want to be restricted to width 14 phrases you will have
; to setup the top 6 bits of iwidth in this longword.
; Note that we also don't use any other field here


	move.l	d0,(a0)+		; high longword second phrase

; That completes another long word

	moveq	#0,d0			; make room for data

; The next block of stuff builds the next long word. It or's in the data and
; then shifts until everything is in place. 
; Note that the moveq # lsl pattern can be replaced by lsl # for 
; all cases where the shift is less than 9. This is not done here 
; for consistency. The speed hit this way IS noticable


	ori.l	#14,d0			; set iwidth 14 
					; this is a 10 bit field
; Insert dwidth
	moveq	#10,d1			; make room for dwidth
	lsl.l	d1,d0			; now 20 bits are used
	ori.l	#14,d0			; number of phrases 

; Insert pitch
	moveq	#3,d1			; make room for pitch
	lsl.l	d1,d0			; now 23 bits are used
	ori.l	#$1,d0

; Insert depth
	moveq	#3,d1			; make room for depth
	lsl.l	d1,d0			; now 26 bits are used

	ori.l	#$4,d0			; set depth to 4  

; Insert xpos
	moveq	#12,d1			; make room for xpos
	lsl.l	d1,d0			; now 38 bits are used

; 6 top bits of iwidth get lost by this shift, but as our number of 
; phrases is 14 it still fits into the remaining 4 bits. So we are fine.

	ori.l	#$20,d0			; or in xpos

; Finally store the data

	move.l	d0,(a0)+

; That completes another long word. 
; And the second phrase.
; And the bitmapped object.

; This will generate a stop object

	move.l	a0,d4
	swap	d4			; Swapped address of STOP object in d4

	move.l	#$0,d0			; This one is always 0
	move.l	d0,(a0)+		; That high longword sure was easy

; That completes another long word

	move.l	#$c,d0			; set the type field for stop obj 
	move.l	d0,(a0)			; and the data field to 1

; That was a stop object with bit 0 set in the data field

; Well all should be set up now

	swap	d5

; Now the correct value to place into OLP is in d5

	rts

	.phrase	; Force object code size alignment

