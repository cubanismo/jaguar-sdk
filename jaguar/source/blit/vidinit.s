	.include	'jaguar.inc'

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.globl	VideoIni
	.globl	a_vde
	.globl	a_vdb

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; The size of the horizontal and vertical active areas
; are based on a given center position and then built
; as offsets of half the size off of these.

; In the horizontal direction this needs to take into
; account the variable resolution that is possible.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

VideoIni:
	movem.l	d0-d6,-(sp)

; Check if NTSC or PAL
; For now assume NTSC

	move.w	CONFIG,d0
	and.w	#$10,d0
	beq	ispal

	move.w	#NTSC_HMID,d2
	move.w	#NTSC_WIDTH,d0

	move.w	#NTSC_VMID,d6
	move.w	#NTSC_HEIGHT,d4

	bra	doit

ispal:
	move.w	#PAL_HMID,d2
	move.w	#PAL_WIDTH,d0

	move.w	#PAL_VMID,d6
	move.w	#PAL_HEIGHT,d4

doit:
	move.w	d0,width
	move.w	d4,height

	move.w	d0,d1
	asr	#1,d1			; Max width/2

	sub.w	d1,d2			; middle-width/2
	add.w	#4,d2			; (middle-width/2)+4
	
	sub.w	#1,d1			; Width/2-1
	or.w	#$400,d1		; (Width/2-1)|$400

	move.w	d1,a_hde
	move.w	d1,HDE

	move.w	d2,a_hdb
	move.w	d2,HDB1
	move.w	d2,HDB2

	move.w	d6,d5
	sub.w	d4,d5			; already in half lines
	move.w	d5,a_vdb

	add.w	d4,d6
	move.w	d6,a_vde

	move.w	a_vdb,VDB
	move.w	#$FFFF,VDE

; Also let's set up some default colors

	move.w	#$f0ff,BG
	move.l	#$ffffffff,BORD1

	movem.l	(sp)+,d0-d6
	rts

	.phrase	; Force object code size alignment

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.bss

height:
	ds.w	1
a_vdb:
	ds.w	1
a_vde:
	ds.w	1


width:
	ds.w	1
a_hdb:
	ds.w	1
a_hde:
	ds.w	1



