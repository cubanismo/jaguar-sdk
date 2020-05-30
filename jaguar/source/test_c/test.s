;GCC for Atari Jaguar GPU/DSP (Jun 12 1995) (C)1994-95 Brainstorm
	MACRO	_RTS
	load	(ST),TMP
	jump	T,(TMP)
	addqt	#4,ST	;rts
	ENDM
_test_start::
	.GPU
	.ORG	$F03000
ST	.REGEQU	r18
FP	.REGEQU	r17
TMP	.REGEQU	r16
GT	.CCDEF	$15
gcc2_compiled_for_madmac:
	;(.TEXT)
	.EVEN
_foo::
	subqt	#4,ST
	store	FP,(ST)
	move	ST,FP	;link
	cmp	r1,r0	;cmpsi	r1,r0
	jr	MI,L2
	nop		;jlt	L2
	move	r0,r1	;movsi	r0->r1
	addqt	#32,r1	;iaddqtsi3	#32+r1->r1
	addqt	#2,r1	;iaddqtsi3	#2+r1->r1
L2:
	movei	#_y,r0	;movsi	#_y->r0
	store	r1,(r0)	;movsi	r1->(r0)
	move	FP,ST
	load	(ST),FP
	addqt	#4,ST	;unlk
	_RTS
	.EVEN
_foo1::
	subqt	#4,ST
	store	FP,(ST)
	move	ST,FP	;link
	moveq	#29,r0	;movsi	#29->r0
	move	FP,ST
	load	(ST),FP
	addqt	#4,ST	;unlk
	_RTS
_y::	.DCB.B	8,0
	.LONG
	.68000
_test_end::
_test_size	.EQU	*-_test_start
	.GLOBL	_test_size
	.IF	_test_size>$1000
	.PRINT	"Code size (",/l/x _test_size,") is over $1000"
	.FAIL
	.ENDIF
