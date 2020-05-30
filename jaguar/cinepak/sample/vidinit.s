
.include	'jaguar.inc'
	.globl	VideoIni
	.globl	a_vde
	.globl	a_vdb
; The size of the horizontal and vertical active areas
; are based on a given center position and then built
; as offsets of half the size off of these.
; In the horizontal direction this needs to take into
; account the variable resolution that is possible.
; THESE ARE THE NTSC DEFINITIONS
ntsc_width	equ	1409
ntsc_hmid	equ	823
ntsc_height	equ	241
ntsc_vmid	equ	266
; THESE ARE THE PAL DEFINITIONS
pal_width	equ	1381
pal_hmid	equ	843
pal_height	equ	287
pal_vmid	equ	322
VideoIni:
; Check if NTSC or PAL
; For now assume NTSC
	movem.l	a0/d0-d6,-(sp)
	move.w	CONFIG,d0
	and.w	#$10,d0
	beq.s	ispal
	move.w	#ntsc_hmid,d2
	move.w	#ntsc_width,d0
	move.w	#ntsc_vmid,d6
	move.w	#ntsc_height,d4
	bra.s	do_it
ispal:
	move.w	#pal_hmid,d2
	move.w	#pal_width,d0
	move.w	#pal_vmid,d6
	move.w	#pal_height,d4
do_it:
	lea	width,a0
	move.w	d0,(a0)
	lea	height,a0
	move.w	d4,(a0)
	move.w	d0,d1
	asr	#1,d1			; Max width/2
	sub.w	d1,d2			; middle-width/2
	add.w	#4,d2			; (middle-width/2)+4

	sub.w	#1,d1			; Width/2-1
	or.w	#$400,d1		; (Width/2-1)|$400
	lea	a_hde,a0	
	move.w	d1,(a0)
	move.w	d1,HDE
	lea	a_hdb,a0
	move.w	d2,(a0)
	move.w	d2,HDB1
	move.w	d2,HDB2
	move.w	d6,d5
	sub.w	d4,d5			; already in half lines
	lea	a_vdb,a0
	move.w	d5,(a0)
	add.w	d4,d6
	lea	a_vde,a0
	move.w	d6,(a0)
	move.w	a_vdb,VDB
	move.w	#$FFFF,VDE
; Also lets set up some default colors
	move.w	#$0000,BG
	move.l	#$0000ff00,BORD1
	movem.l	(sp)+,a0/d0-d6
	rts

height:
	dc.w	0
a_vdb:
	dc.w	0
a_vde:
	dc.w	0
width:
	dc.w	0
a_hdb:
	dc.w	0
a_hde:
	dc.w	0

