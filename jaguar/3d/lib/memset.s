;
; memset: fill a block of memory with zeros, using the blitter
;
	.include	'jaguar.inc'


	.globl	_memset
_memset:
	move.l	4(sp),a0		; destination
	move.w	8(sp),d0		; value
	move.l	10(sp),d1		; length
	move.l	d2,-(sp)		; save d2, we'll be using it

	move.w	d0,d2
	asl.w	#8,d2
	or.w	d2,d0
	move.w	d0,d2
	swap	d0	
	move.w	d2,d0

	cmp.l	#128,d1			; zeroing only a small area?
	bmi	.oldway			; yes, just go do it


	move.l	a0,d2			; test for alignment
	btst	#0,d2			; odd?
	beq.b	.areeven
	move.b	d0,(a0)+		; set one byte, now we are even
	subq.l	#1,d1
	move.l	a0,d2
.areeven:
	btst	#1,d2			; on a long boundary?
	beq.b	.arelong
	move.w	d0,(a0)+		; set 2 bytes, now we're long aligned
	subq.l	#2,d1
	move.l	a0,d2
.arelong:
	btst	#2,d2			; on a phrase boundary?
	beq.b	.arephrase		; yes -- go do it
	move.l	d0,(a0)+
	subq.l	#4,d1
.arephrase:

.blitloop:
	move.l	d1,d2
	cmp.l	#$4000,d2
	bmi.b	.smallenuf
		move.l	#$4000,d2
.smallenuf:
	sub.l	d2,d1
	move.l	a0,A1_BASE
	add.l	d2,a0
	move.l	#0,A1_PIXEL
	move.l	#0,A1_FPIXEL
	move.l	#PIXEL8|WID8|XADDPHR,A1_FLAGS

	move.l	d0,B_PATD
	move.l	d0,B_PATD+4
	swap	d2
	move.w	#1,d2			; outer loop counter = 1
	swap	d2
	move.l	d2,B_COUNT
	move.l	#PATDSEL,B_CMD

	cmp.l	#0,d1
	bne	.blitloop
	bra	.return
;
; the old, slow way to fill arbitrarily aligned memory
;
.oldway:
	move.b	d0,(a0)+
	subq.l	#1,d1
	bne	.oldway
.return:

	move.l	(sp)+,d2		; restore d2
	rts

