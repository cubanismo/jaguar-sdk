	.include 'jaguar.inc'

	.globl	_memcpy

_bcopy::
	move.l	4(sp),a1		;source
	move.l	8(sp),a0		;destination
	move.l	12(sp),d1		;length
	bra	docopy

__memcpy::
_memcpy::
	move.l	4(sp),a0		; destination
	move.l	8(sp),a1		; source
	move.l	12(sp),d1		; length
docopy:
	cmp.l	#128,d1			; copying only a small area?
	bmi	.oldway			; yes, just go do it
	move.l	a0,d0
	and.w	#7,d0			; is the destination phrase aligned?
	bne	.oldway			; nope == do it the old way
	move.l	a1,d0
	and.w	#7,d0			; is the source phrase aligned?
	bne.w	.oldway			; nope == do it the old way

;
; now, set up the blitter to copy big blocks (up to 16K at a time)
;
.blitloop:
	move.l	d1,d0
	cmp.l	#$4000,d0
	bmi.b	.smallenuf
		move.l	#$4000,d0
.smallenuf:
	sub.l	d0,d1
	move.l	a0,A1_BASE
	add.l	d0,a0
	move.l	a1,A2_BASE
	add.l	d0,a1
	move.l	#0,A1_PIXEL
	move.l	#0,A1_FPIXEL
	move.l	#0,A2_PIXEL
	move.l	#PIXEL8|WID8|XADDPHR,A1_FLAGS
	move.l	#PIXEL8|WID8|XADDPHR,A2_FLAGS

	swap	d0
	move.w	#1,d0			; outer loop counter = 1
	swap	d0
	move.l	d0,B_COUNT
	move.l	#SRCEN|LFU_A|LFU_AN,B_CMD

	cmp.l	#0,d1
	bne	.blitloop

	bra	.return
;
; the old, slow way to copy arbitrarily aligned memory
;
.oldway:
	tst.l	d1			; check for 0 bytes to copy
	beq.b	.return
.oloop:
	move.b	(a1)+,(a0)+
	subq.l	#1,d1
	bne	.oloop
.return:
	rts


