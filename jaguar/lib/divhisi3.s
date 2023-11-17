;PIC GPU Signed 16.16->32 Divide (8-jun-1994)
;In: r0=operand 0 r1=operand 1
;Out: r0=r0/r1
	.INCLUDE	"libinc.s"
___adivhisi3::
	abs	r0
	moveq	#0,r2
	jr	CC,.l0
	abs	r1
	subqt	#1,r2
.l0:	jr	CC,.l1
	shlq	#16,r0
	not	r2
.l1:	shlq	#16,r1
	shrq	#16,r0
	shrq	#16,r1
	div	r1,r0
	xor	r2,r0
	_RTS
