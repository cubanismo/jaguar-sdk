;PIC GPU Signed Integer 32.32->32 Multiplication Code (8-jun-1994)
;In: r0=operand 0 r1=operand 1
;Out: r0=r0*r1
	.INCLUDE	"libinc.s"
___amulsi3::
	abs	r1
	moveq	#0,r4
	jr	CC,.l0
	abs	r0
	subqt	#1,r4
.l0:	jr	CC,.l1
	move	r1,r3
	not	r4
.l1:	move	r0,r2
	rorq	#16,r3
	mult	r1,r0
	mult	r2,r3
	rorq	#16,r2
	shlq	#16,r3
	mult	r1,r2
	add	r3,r0
	shlq	#16,r2
	add	r2,r0
	xor	r4,r0
	_RTS
