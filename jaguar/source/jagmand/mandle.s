	.include	"jaguar.inc"

	.text

	.globl	Mandle

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	INBUF		equ	$00f03810
	SEMAPHORE	equ	$0000bff0

	WIDTH		equ	256
	HEIGHT		equ	200

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; The X numbers are shifted right by 13 before use
; These numbers are in units of 1/8192

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; The upper commented out numbers do this SciAm cover (almost)
;	XSTART		equ	$fffffa86
;	XINC		equ	1

;	XSTART		equ	((-1)<<13)
;	XINC		equ	(1<<9)

;	XSTART		equ	0
;	XINC		equ	(1<<7)

	XSTART		equ	((-2)<<13)
	XINC		equ	((10<<11)/WIDTH)


; The Y numbers are shifted right by 13 before use
; These numbers are in units of 1/8192

; The upper commented out numbers do this SciAm cover
;	YSTART		equ	$ffffde9a	
;	YINC		equ	1

;	YSTART		equ	((-1)<<13)
;	YINC		equ	(1<<9)

;	YSTART		equ	((-2)<<13)
;	YINC		equ	(1<<7)

	YSTART		equ	((-19)<<9)
	YINC		equ	((6<<12)/WIDTH)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Mandle:
	move.l	#0,jx
	move.l	#0,jy

	movea.l	#$20000,a1

	move.l	#YSTART,ypos	; Initialize y position

	move.l	#HEIGHT-1,d2

	movea.l	#INBUF+8,a0

	move.l	jx,d0
	move.l	d0,(a0)+

	move.l	jy,d0
	move.l	d0,(a0)

outer:
	movea.l	#INBUF+4,a0

	move.l	ypos,d0
	move.l	d0,(a0)

	move.l	#WIDTH-1,d1
	move.l	#XSTART,xpos	; Initialize x position

inner:
	movea.l	#INBUF,a0

	move.l	xpos,d0
	move.l	d0,(a0)

	movea.l	#SEMAPHORE,a0
	move.l	#0,d0
	move.l	d0,(a0)

	move.l	#G_RAM,G_PC		; GPU Program counter gets $00f03000

	move.l	#$1,G_CTRL		; Set the GPU going

wait:
	move.l	(a0),d0
	beq	wait
	
	move.b	d0,(a1)+
	add.l	#XINC,xpos
	dbra	d1,inner

	add.l	#YINC,ypos
	dbra	d2,outer

	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.bss

	.even

xpos:	ds.l	1
ypos:	ds.l	1
jx:	ds.l	1
jy:	ds.l	1

