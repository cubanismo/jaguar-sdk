;PIC GPU Unsigned Integer 32.32->32 Multiplication Code (8-jun-1994)
;In: r0=operand 0 r1=operand 1
;Out: r0=r0*r1
	.INCLUDE	"libinc.s"
___aumulsi3::
	move	r1,r3
	move	r0,r2
	rorq	#16,r3
	mult	r1,r0
	mult	r2,r3
	rorq	#16,r2
	shlq	#16,r3
	mult	r1,r2
	add	r3,r0
	shlq	#16,r2
	add	r2,r0
	_RTS
