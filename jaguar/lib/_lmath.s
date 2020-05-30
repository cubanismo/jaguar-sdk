;   32bit Division/Modulo fuer 68000

* Functions:
*  long           __divu(register long d0, register long d1)
*  long           __divs(register long d0, register long d1)
*  long           __modu(register long d0, register long d1)
*  long           __mods(register long d0, register long d1)
*  __ldivs etc. erwarten Parameter auf dem Stack


	code

	xdef	__divu
	xdef	__divs
	xdef	__modu
	xdef	__mods
	xdef	__ldivs
	xdef	__ldivu
	xdef	__lmods
	xdef	__lmodu


__lmods
	movem.l	4(sp),d0/d1
__mods:
	tst.l	d1
	bmi	1$
	tst.l	d0
	bmi	2$
	bsr	__divu
	move.l	d1,d0
	rts
1$:	neg.l	d1
	tst.l	d0
	bmi	3$
	bsr	__divu
	neg.l	d1
	move.l	d1,d0
	rts
2$:	neg.l	d0
	bsr	__divu
	neg.l	d1
	move.l	d1,d0
	rts
3$:	neg.l	d0
	bsr	__divu
	move.l	d1,d0
	rts


__lmodu
	movem.l	4(sp),d0/d1
__modu:
	bsr	__divu
	move.l	d1,d0
	rts


__ldivs
	movem.l	4(sp),d0/d1
__divs:
	tst.l	d0
	bpl	2$
	neg.l	d0
	tst.l	d1
	bpl	1$
	neg.l	d1
	bsr	__divu
	neg.l	d1
	rts
1$:	bsr	__divu
	neg.l	d0
	neg.l	d1
	rts
2$:	tst.l	d1
	bpl	__divu
	neg.l	d1
	bsr	__divu
	neg.l	d0
	rts


__ldivu
	movem.l	4(sp),d0/d1
__divu:
	move.l	d2,-(sp)
	swap	d1
	move.w	d1,d2
	bne	2$
	swap	d0
	swap	d1
	swap	d2
	move.w	d0,d2
	beq	1$
	divu	d1,d2
	move.w	d2,d0
1$:	swap	d0
	move.w	d0,d2
	divu	d1,d2
	move.w	d2,d0
	swap	d2
	move.w	d2,d1
	move.l	(sp)+,d2
	rts
2$:	move.l	d3,-(sp)
	moveq	#16,d3
	cmp.w	#$80,d1
	bhs	3$
	rol.l	#8,d1
	subq.w	#8,d3
3$:	cmp.w	#$800,d1
	bhs	4$
	rol.l	#4,d1
	subq.w	#4,d3
4$:	cmp.w	#$2000,d1
	bhs	5$
	rol.l	#2,d1
	subq.w	#2,d3
5$:	tst.w	d1
	bmi	6$
	rol.l	#1,d1
	subq.w	#1,d3
6$:	move.w	d0,d2
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
	bhs	8$
	subq.w	#1,d3
	add.l	d1,d0
7$:	bhs.s	7$
8$:	moveq	#0,d1
	move.w	d3,d1
	swap	d3
	rol.l	d3,d0
	swap	d0
	exg	d0,d1
	move.l	(sp)+,d3
	move.l	(sp)+,d2
	rts

	
	end
