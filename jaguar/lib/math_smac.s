;   32bit Division/Modulo for 68000/68010

; Functions:
;  long           __divu(register long d0, register long d1)
;  long           __divs(register long d0, register long d1)
;  long           __modu(register long d0, register long d1)
;  long           __mods(register long d0, register long d1)
;  __ldivs etc. expect parameters on the stack

	.extern  __divu
	.extern	__divs
	.extern	__modu
	.extern	__mods
	.extern	__ldivs
	.extern	__ldivu
	.extern	__lmods
	.extern	__lmodu


	.68000
	.text
__lmods:
	movem.l	4(sp),d0/d1
__mods:
	tst.l	d1
	bmi	z1
	tst.l	d0
	bmi	z2
	bsr	__divu
	move.l	d1,d0
	rts
z1:	neg.l	d1
	tst.l	d0
	bmi	z3
	bsr	__divu
	move.l	d1,d0
	rts
z2:	neg.l	d0
	bsr	__divu
	neg.l	d1
	move.l	d1,d0
	rts
z3:	neg.l	d0
	bsr	__divu
	neg.l	d1
	move.l	d1,d0
	rts


__lmodu:
	movem.l	4(sp),d0/d1
__modu:
	bsr	__divu
	move.l	d1,d0
	rts


__ldivs:
	movem.l	4(sp),d0/d1
__divs:
	tst.l	d0
	bpl	y2
	neg.l	d0
	tst.l	d1
	bpl	y1
	neg.l	d1
	bsr	__divu
	neg.l	d1
	rts
y1:	bsr	__divu
	neg.l	d0
	neg.l	d1
	rts
y2:	tst.l	d1
	bpl	__divu
	neg.l	d1
	bsr	__divu
	neg.l	d0
	rts


__ldivu:
	movem.l	4(sp),d0/d1
__divu:
	move.l	d2,-(sp)
	swap	d1
	move.w	d1,d2
	bne	x2b
	swap	d0
	swap	d1
	swap	d2
	move.w	d0,d2
	beq	x1b
	divu	d1,d2
	move.w	d2,d0
x1b:	swap	d0
	move.w	d0,d2
	divu	d1,d2
	move.w	d2,d0
	swap	d2
	move.w	d2,d1
	move.l	(sp)+,d2
	rts
x2b:	move.l	d3,-(sp)
	moveq	#16,d3
	cmp.w	#80,d1
	bhs	x3b
	rol.l	#8,d1
	subq.w	#8,d3
x3b:	cmp.w	#800,d1
	bhs	x4b
	rol.l	#4,d1
	subq.w	#4,d3
x4b:	cmp.w	#2000,d1
	bhs	x5b
	rol.l	#2,d1
	subq.w	#2,d3
x5b:	tst.w	d1
	bmi	x6b
	rol.l	#1,d1
	subq.w	#1,d3
x6b:	move.w	d0,d2
	lsr.l	d3,d0
	swap	d2
	clr.w	d2
	lsr.l	d3,d2
	swap	d3
	divu	d1,d0
	move.w	d0,d3
	move.w	d2,d0
	move.w	d3,d2
	swap	d1
	mulu	d1,d2
	sub.l	d2,d0
	bhs	x8b
	subq.w	#1,d3
	add.l	d1,d0
x7b:	bhs.s	x7b
x8b:	moveq	#0,d1
	move.w	d3,d1
	swap	d3
	rol.l	d3,d0
	swap	d0
	exg	d0,d1
	move.l	(sp)+,d3
	move.l	(sp)+,d2
	rts

	
	.end
