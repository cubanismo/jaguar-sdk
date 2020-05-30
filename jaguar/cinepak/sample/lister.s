
	.include	'memory.inc'
	.include	'jaguar.inc'
	.include	'cinepak.inc'
	.globl		Lister
	.extern		listbuf
	.extern		a_vde
	.extern		a_vdb
	.extern		RefreshData
; At this point I will attempt to set up an object list
; This list will contain a single Scaled Bit map object
; and a Stop object.  This object is 256 pixels wide
Lister:
	lea	listbuf,a0
	move.l	a0,d0			; Space alloted for Object List
	and.l	#$ffffffe0,d0		; Assure alignment
	move.l	d0,d5			; save address for later
	move.l	d0,a0			; a0 has the ACTUAL OL start

	lea	RefreshData,a1		; Save values for VI refresh
	move.l	d0,(a1)+		; Save start address
; At this point we add two branch object to keep the hardware happy!
; the first one branches to stop if greater than n_vde
; the nextone branches to stop if less than n_vdb
; The First phrase has is link address in phrases shifted down by eight bits
	add.l	#32,d0			; address of stop object
	lsr.l	#3,d0			; address in phrases
	move.l	d0,d2			; save for later use
	lsr.l	#8,d0
	move.l	d0,(a0)+
	move.l	d2,d0
	moveq	#24,d1
	lsl.l	d1,d0
	or.l	#3,d0			; make it a branch object
	move.w	a_vde,d3
	ext.l	d3
	lsl.l	#3,d3
	or.l	d3,d0
	or.l	#2<<14,d0		; branch greater than
	move.l	d0,(a0)+		; One down one to go!
	move.l	d2,d0			; save for later use
	lsr.l	#8,d0
	move.l	d0,(a0)+
	move.l	d2,d0
	moveq	#24,d1
	lsl.l	d1,d0
	ori.l	#3,d0			; make it a branch object
	move.w	a_vdb,d3
	ext.l	d3
	lsl.l	#3,d3
	or.l	d3,d0
	or.l	#1<<14,d0		; branch less than
	move.l	d0,(a0)+		; all done
 	move.l	#SCREEN_BASE,d0		; get data address
	moveq	#8,d1
	lsl.l	d1,d0			; shift into position
	and.l	#$fffff800,d0		; mask off junk
	move.l	d0,(a0)			; store
; This places the partial result in the correct spot in memory
; Then, in the next part, it 'or's the rest of the data in.
; Doing it all in registers would be faster, but I want to see the results
	move.l	d5,d0			; This points to the start of the OL
	add.l	#36,d0			; Point to the soon to be stop object
	move.l	d0,d2			; Save pointer for bottom half
	moveq	#11,d1
	lsr.l	d1,d0			; shift for top part
	or.l	d0,(a0)			; or in the new data
	move.l	(a0)+,(a1)+		; Save value for VI refresh
; do the bottom half in the next long word
	moveq	#21,d1
	lsl.l	d1,d2			; shift for bottom part
	and.l	#$ff000000,d2		; mask off junk
	move.l	d2,(a0)			; store (prematurely)
; Same comment here about doing this in registers instead of memory
	move.w	#NLINES,d0		; this is the height (fixed @NLINES)
	moveq	#14,d1
	lsl.l	d1,d0			; shift it again
	or.l	d0,(a0)			; or in the new data
	move.w	a_vdb,d0
	ext.l	d0
	add.l	#30,d0			; put the YPOS @ a_vdb+30
; This really should be different for NTSC and PAL
	lsl.l	#3,d0
	or.l	d0,(a0)			; or in the new data
	or.l	#0,(a0)			; or in the object type
	move.l	(a0)+,(a1)		; Save value for VI refresh
; That completes another long word, First phrase done
	move.l	#$00000005,d0		; This sets the transparent flag ONLY
	move.l	d0,(a0)+		; Set for 32 phrases
					; 
; That completes another long word
	moveq	#0,d0			; Make Room For Data
; The next block of stuff builds the next long word
; It or's in the data and then shifts until everything is
; in place.  Note that the moveq # lsl pattern can be
; replaced by lsl # for all cases where the shift is less
; than 9.  This is not done here for consistency.  The
; speed hit this way IS noticable
; 32 phrases has NO low order bits
;	ori.l	#$f,d0			; This is for 320, not 256
	ori.l	#0,d0
; Insert dwidth
	moveq	#10,d1			; make room for dwidth
	lsl.l	d1,d0
;	ori.l	#40,d0			; This is for 320, not 256
	ori.l	#80,d0
; Insert pitch
	moveq	#3,d1			; make room for pitch
	lsl.l	d1,d0
	ori.l	#$1,d0
; Insert depth
	moveq	#3,d1			; make room for depth
	lsl.l	d1,d0
	ori.l	#$4,d0
; Insert xpos
	moveq	#12,d1			; make room for xpos
	lsl.l	d1,d0
	ori.l	#$c,d0

; Finally store the data
	move.l	d0,(a0)+
; That completes another long word. And the second phrase
; And the bitmapped object
	move.l	a0,d4
	swap	d4			; Swapped address of STOP object in d4
	move.l	#$0,d0			; This one is always 0
	move.l	d0,(a0)+		; That sure was easy
; That completes another long word
	move.l	#$c,d0
	move.l	d0,(a0)
; That was a stop object with all zeros for data
	rts

	dcb.l	32,0			; Pad for alignment
listbuf:
	dcb.l	64,0

