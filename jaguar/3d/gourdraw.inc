;
; gour: draw a Gouraud shaded triangle
;
; It is assumed that the caller has initialized
; B_PATD
;
;
; we can re-use some registers, namely
; leftu,leftustep,leftv,leftvstep,srcaddr,srcflags
; b_zinc

bcount_ptr	.equr	srcaddr			; address of B_COUNT
bi3_ptr		.equr	srcflags		; address of B_I3

;
; SET-UP ROUTINE FOR GOURAUD SHADED POLYGONS
; called in regbank 1
;
	.REGBANK1

	.globl	gourpoly
gourpoly:
;
; make sure the blitter is off
;
	movefa	bcmd_ptr,temp0
.bwait:
	load	(temp0),temp1
	btst	#0,temp1
	jr	EQ,.bwait
	nop

	movefa	b_color,temp0
	movei	#B_PATD,temp1
	store	temp0,(temp1)
	addqt	#4,temp1
	store	temp0,(temp1)

;
; set up the destination registers
;
	movei	#B_ZINC,temp2
	movefa	b_iinc,temp0
	movefa	b_zinc,temp1
	shlq	#8,temp0			; strip color byte from IINC
	store	temp1,(temp2)
	shrq	#8,temp0
	subqt	#(B_ZINC-B_IINC),temp2
	store	temp0,(temp2)

	movefa	a1_ptr,temp2
	movefa	destaddr,temp1
	subqt	#(A1_PIXEL-A1_BASE),temp2
	store	temp1,(temp2)		; set A1_BASE
	addqt	#4,temp2
	movefa	destflags,temp1
	movei	#XADDPIX,temp0
	or	temp1,temp0
	store	temp0,(temp2)		; set A1_FLAGS

	movei	#B_I3,temp0
	movei	#PATDSEL|GOURD|ZBUFF|ZMODEGT|DSTENZ|DSTWRZ|DSTEN|BKGWREN,temp1

	moveta	temp0,bi3_ptr
	moveta	temp1,bcmdval
	movei	#B_COUNT,temp0
	jump	(return)
	moveta	temp0,bcount_ptr

;
; per-trapezoid routine for gouraud shading
; called in regbank 0
;
	.globl	gourtrap
gourtrap:
	.REGBANK0
	movei	#gourdone,trapdone

	shrq	#16,ay				; strip fractional part of ay
	move	PC,traploop
	shlq	#16,ay
	addqt	#6,traploop

gourline: 
	subq	#1,anumlines
	jump	MI,(trapdone)
	move	leftx,atemp0			; branch optimization

	move	rightx,bcount
	shrq	#16,atemp0
	shrq	#16,bcount
	or	atemp0,ay
	sub	atemp0,bcount

	cmpq	#1,bcount
	jr	MI,.zerocount		; if the line is empty, don't actually do a blit
	bset	#16,bcount

.bwait:
	load	(bcmd_ptr),atemp0
	btst	#0,atemp0
	jr	EQ,.bwait
	nop

;
; set Y to Y|X (i.e. A1_PIXEL value)
; and set bcount to the (16 bit) count value
;
	store	lefti, (bi3_ptr)
	store	leftz, (bz3_ptr)
	store	ay,(a1_ptr)		; set A1_PIXEL
	store	bcount,(bcount_ptr)
	store	bcmdval,(bcmd_ptr)	; starts the blit

.zerocount:
	add	rightxstep,rightx
	add	leftistep,lefti
	add	leftxstep,leftx
	sat24	lefti
	shrq	#16,ay
	add	leftzstep,leftz
	addqt	#1,ay

	jump	(traploop)
	shlq	#16,ay


gourdone:

	movei	#G_FLAGS,atemp1			; switch back to bank 1
	load	(atemp1),atemp0
	movefa	return,atemp2
	bset	#14,atemp0
	jump	(atemp2)
	store	atemp0,(atemp1)			; the jump will flush the prefetch queue
;	nop					; and take 3 cycles, giving time for the new flags
;	nop					; to take effect
	.REGBANK1

	.equrundef	bi3_ptr
	.equrundef	bcount_ptr
