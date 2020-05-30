	.include	"vidstuff.inc"
	.text

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

testrgb::
	move.l	#%11111,d5		; red
	move.l	#%111111,d6		; green
	move.l	#%11111,d7		; blue
	clr.l	d3			; Set subtraction mode.
	bsr	.shiftcolor

;;;;;;;;

	lea	bitmap_addr,a0
	move.l	#BM_HEIGHT-1,d2
.yloop:
	move.l	#BM_WIDTH-1,d1
.xloop:
	move.w	d0,(a0)+
	dbra	d1,.xloop

;;;;;;;;

	tst	d3
	bne	.addition

.subtract:
	sub.w	#1,d5
	bpl.s	.setcolor
	clr.l	d5

.try_blue:
	sub.w	#1,d7
	bpl.s	.setcolor
	clr.l	d7

.try_green:
	sub.w	#2,d6
	bpl.s	.setcolor

;;;;;;;;

.set_addition:
	moveq	#-1,d3
	clr.l	d5
	clr.l	d6
	clr.l	d7
	bra	.setcolor

;;;;;;;;

.addition:
	cmpi.w	#$1f,d5
	beq.s	.try_blue2
	add.w	#1,d5
	bra.s	.setcolor

.try_blue2:
	cmpi.w	#$1f,d7
	beq.s	.try_green2
	add.w	#1,d7
	bra.s	.setcolor

.try_green2:
	cmpi.w	#$3f,d6
	bge.s	.clear_addition
	add.w	#2,d6
	cmpi.w	#$3f,d6
	blt.s	.setcolor
	move.w	#%111111,d6
	bra.s	.setcolor

.clear_addition:
	move.l	#%11111,d5		; red
	move.l	#%111111,d6		; green
	move.l	#%11111,d7		; blue
	clr.l	d3			; Clear addition mode

;;;;;;;;

.setcolor:
	bsr	.shiftcolor
.next_y:
	dbra	d2,.yloop

	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.shiftcolor:
	move.w	d5,d0	; d0 = red, now have [0]-[0]-[0]-[red]
	asl	#5,d0	; shift red up, now have [0]-[0]-[red]-[0]
	or.w	d7,d0	; add in blue, now have [0]-[0]-[red]-[blue]
	asl	#6,d0	; shift red & blue up, now have [0]-[red]-[blue]-[0]
	or.w	d6,d0	; add in green, now have [0]-[red]-[blue]-[green]
	rts

