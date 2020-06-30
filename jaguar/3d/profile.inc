;
; Timing profile stuff
;

	.extern	_proftime		; array of longs to hold timing info
PROFILING	=	1

	.macro	INITTIME
	movei	#PIT0,r0
	load	(r0),r1
	rorq	#16,r1
	neg	r1
	movei	#_proftime,r0
	store	r1,(r0)
	addqt	#4,r0
	moveq	#0,r1
	moveq	#16,r2			; clear 16 long words
.tinit:
	store	r1,(r0)			; clear a word
	addqt	#4,r0
	subq	#1,r2
	jr	NE,.tinit
	nop
	.endm

	.macro	ADDTIME	which
	movei	#PIT0,r0
	load	(r0),r1
	movei	#_proftime,r0
	rorq	#16,r1
	neg	r1			; r1 has current time stamp
	load	(r0),r2			; r2 has last time stamp
	or	r2,r2			; wait for load
	store	r1,(r0)			; update time stamp
	sub	r2,r1			; now r1 has delta time
	addqt	#\which,r0
	load	(r0),r2
	add	r1,r2
	store	r2,(r0)
	.endm

;
; legal values for ADDTIME
;
BLITWAIT	=	4		; waiting for the blitter
OUTRLP		=	8		; outer loop, backface culling
DATALD		=	12		; data loading for points
TRANSFORM	=	16		; point transformations
CLIPPING	=	20		; clipping to viewing pyramid
PERSPECTIVE	=	24		; perspective transformation
POLYSETUP	=	28		; polygon set up
SCANLINES	=	32		; scan line walking
