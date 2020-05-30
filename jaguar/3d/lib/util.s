
;
; gcc support
; stuff taken from the MiNT library
;
	.text
	.even
	.globl	__mulsi3, ___mulsi3

__mulsi3:
___mulsi3:
	move.l	d2, a0
	move.l	d3, a1
	movem.w	4(sp), d0-d3
	move.w	d0, -(sp)
	bpl	.LT1
	neg.w	d1
	negx.w	d0
.LT1:	tst.w	d2
	bpl	.LT2
	neg.w	d3
	negx.w	d2
	not.w	(sp)
.LT2:
	ext.l	d0
	beq	.LT3
	mulu	d3, d0
.LT3:	tst.w	d2
	beq	.LT4
	mulu	d1, d2
	add.w	d2, d0
.LT4:	swap	d0
	clr.w	d0
	mulu	d3, d1
	add.l	d1, d0
	move.l	a1, d3
	move.l	a0, d2
	tst.w	(sp)+
	bpl	.LT5
	neg.l	d0
.LT5:	rts

	.globl	__divsi3, ___divsi3
	.globl	__modsi3, ___modsi3

__divsi3:
___divsi3:
	move.l	d2, a0
	move.l	d3, a1
	clr.w	-(sp)
	clr.l	d0
	move.l	10(sp), d2
	beq	.LT1
	bpl	.LT2
	neg.l	d2
	not.w	(sp)
.LT2:	move.l	6(sp), d1
	bpl	.LT3
	neg.l	d1
	not.w	(sp)
.LT3:

	cmp.l	d2, d1
	bcs	.LT4

	tst.w	10(sp)
	bne	.LT5
	move.w	d1, d3
	clr.w	d1
	swap	d1
	beq	.LT6
	divu	d2, d1
.LT6:	move.w	d1, d0
	swap	d0
	move.w	d3, d1
	divu	d2, d1
	move.w	d1, d0
	clr.w	d1
	swap	d1
	bra	.LT4

.LT5:
	moveq	#31, d3
.LT7:
	add.l	d1, d1
	addx.l	d0, d0
	cmp.l	d2, d0
	bcs	.LT8
	sub.l	d2, d0
	addq.w	#1, d1
.LT8:
	dbra	d3, .LT7
	exg	d0, d1
.LT4:
	tst.w	6(sp)
	bpl	.LT9
	neg.l	d1


.LT9:	tst.w	(sp)+
	bpl	.LT10
	neg.l	d0
.LT10:
	move.l	a1, d3
	move.l	a0, d2
	rts
.LT1:
	divu	d2, d1
	bra	.LT4


__modsi3:
___modsi3:
	move.l	8(sp), -(sp)
	move.l	8(sp), -(sp)
	bsr	__divsi3
	addq.l	#8, sp
	move.l	d1, d0
	rts

	.globl	__udivsi3,___udivsi3
	.globl	__umodsi3,___umodsi3

__udivsi3:
___udivsi3:
	move.l	d2,a0		; save registers
	move.l	d3,a1
	moveq.l	#0,d0		; prepare result
	move.l	8(sp),d2	; get divisor
	beq	.L9		; divisor = 0 causes a division trap
	move.l	4(sp),d1	; get dividend
;== case 1) divident < divisor
	cmp.l	d2,d1		; is divident smaller then divisor ?
	bcs	.L8		; yes, return immediately
;== case 2) divisor has <= 16 significant bits
	tst.w	8(sp)
	bne	.L2		; divisor has only 16 bits
	move.w	d1,d3		; save dividend
	clr.w	d1		; divide dvd.h by dvs
	swap	d1
	beq	.L0		; (no division necessary if dividend zero)
	divu	d2,d1
.L0:	move.w	d1,d0		; save quotient.h
	swap	d0
	move.w	d3,d1		; (d1.h = remainder of prev divu)
	divu	d2,d1		; divide dvd.l by dvs
	move.w	d1,d0		; save quotient.l
	clr.w	d1		; get remainder
	swap	d1
	bra	.L8		; and return
;== case 3) divisor > 16 bits (corollary is dividend > 16 bits, see case 1)
.L2:
	moveq	#31,d3		; loop count
.L3:
	add.l	d1,d1		; shift divident ...
	addx.l	d0,d0		;  ... into d0
	cmp.l	d2,d0		; compare with divisor
	bcs	.L0b
	sub.l	d2,d0		; big enough, subtract
	add.w	#1,d1		; and note bit in result
.L0b:
	dbra	d3,.L3
	exg	d0,d1		; put quotient and remainder in their registers
.L8:
	move.l	a1,d3
	move.l	a0,d2
	rts
.L9:
	divu	d2,d1		; cause division trap
	bra	.L8		; back to user


__umodsi3:
___umodsi3:
	move.l	8(sp),-(sp)	; push divisor
	move.l	8(sp),-(sp)	; push dividend
	bsr	__udivsi3
	addq.l	#8,sp
	move.l	d1,d0		; return the remainder in d0
	rts

	.phrase
	.end
