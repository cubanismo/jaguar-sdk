MINPHR	=	8
;
; gour: draw a Gouraud shaded triangle in phrase mode
;
;
; we can re-use some registers, namely
; leftu,rightu,leftv,rightv,srcaddr,srcflags, b_uinc, b_vinc

bzinc_ptr	.equr	b_uinc
biinc_ptr	.equr	b_vinc

bcount_ptr	.equr	srcaddr			; address of B_COUNT
bi3_ptr		.equr	srcflags		; address of B_I3
i0		.equr	leftu			; first I value for a phrase
i1		.equr	rightu			; second I value for a phrase


z0		.equr	leftv			; first Z value for a phrase
z1		.equr	rightv

i2		.equr	atemp2
z2		.equr	b_color

;
; Z and I values left over in current bank
;
i3		.equr	atemp1
z3		.equr	atemp0

;
; spill registers from alternate bank
;
spill0		.equr	temp0
spill1		.equr	temp1

;
; SET-UP ROUTINE FOR GOURAUD SHADED POLYGONS
; called in regbank 1
;
;	.REGBANK1

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

	addqt	#4,temp0		; now temp0 = address of B_COUNT
	moveta	temp0,bcount_ptr

	movei	#B_I3,temp0

	movei	#PATDSEL|GOURD|ZBUFF|ZMODEGT|DSTENZ|DSTWRZ|DSTEN|BKGWREN,temp1

	moveta	temp0,bi3_ptr
	moveta	temp1,bcmdval

	movefa	b_color,temp0
	movei	#B_PATD,temp1
	store	temp0,(temp1)
	addqt	#4,temp1
	store	temp0,(temp1)

;
; set up the destination registers
;
	movei	#B_ZINC,temp2
	movefa	b_zinc,temp1
	movefa	b_iinc,temp0
	shlq	#2,temp1			; multiply Z increment by 4
	; make sure intensity increment*4 fits in 24 bits
	abs	temp0
	jr	CC,.posiinc
	shlq	#3,temp0			; multiply by 8
		sat24	temp0
		shrq	#1,temp0
		neg	temp0
		shlq	#8,temp0
		jr	.storiinc
		shrq	#8,temp0
.posiinc:
	sat24	temp0
	shrq	#1,temp0
.storiinc:
	store	temp1,(temp2)
	subqt	#(B_ZINC-B_IINC),temp2
	store	temp0,(temp2)

	movefa	a1_ptr,temp2
	movefa	destaddr,temp1
	subqt	#(A1_PIXEL-A1_BASE),temp2
	store	temp1,(temp2)		; set A1_BASE
	addqt	#4,temp2
	movefa	destflags,temp1		; leave it in phrase mode
	jump	(return)
	store	temp1,(temp2)		; set A1_FLAGS

;
; per-trapezoid routine for gouraud shading
; called in regbank 0
;
	.globl	gourtrap
gourtrap:
	.REGBANK0

.if (^^defined PROFILING)
	ADDTIME	POLYSETUP
.endif

	movei	#B_ZINC,bzinc_ptr
	movei	#B_IINC,biinc_ptr

	shrq	#16,ay				; strip fractional part of ay
	shlq	#16,ay
	subq	#1,anumlines
	movei	#gourdone,atemp0
	jump	MI,(atemp0)
	nop

gourline: 
	move	leftx,atemp0
	move	rightx,bcount
	shrq	#16,atemp0
	shrq	#16,bcount
	or	atemp0,ay			; ay = destination pixel (Y|X)
	sub	atemp0,bcount			; bcount = # of pixels to write

	cmpq	#1,bcount
	movei	#.zerocount,atemp1
	jump	MI,(atemp1)
	nop

;
; set up b_uinc and b_vinc
;
	move	bcount,atemp1
	moveq	#1,atemp2
	shlq	#16,atemp1
	shlq	#14,atemp2
	div	atemp1,atemp2		; atemp2 will be a 14 bit signed fraction

	bset	#16,bcount

	move	righti,b_iinc
	move	rightz,b_zinc
	sub	lefti,b_iinc
	sub	leftz,b_zinc
	sharq	#9,b_iinc
	sharq	#14,b_zinc
	imult	atemp2,b_iinc
	imult	atemp2,b_zinc
	sharq	#(14-9),b_iinc
;
; calculate initial I and Z value
;
	moveq	#3,atemp0
	and	ay,atemp0		; a0 = offset of blit in phrase, in pixels
	move	b_zinc,atemp1		; atemp1 = fractional part of zinc
	move	b_iinc,atemp2		; atemp2 = fractional part of iinc
	mult	atemp0,atemp1		; multiply by offset in phrase
	mult	atemp0,atemp2
	move	b_zinc,z0			; z0 = integer part of zinc
	move	b_iinc,i0			; i0 = integer part of zinc
	sharq	#16,z0
	sharq	#16,i0
	imult	atemp0,z0		; multiply by offset in phrase
	imult	atemp0,i0
	shlq	#16,z0			; convert back to integer
	shlq	#16,i0
	add	atemp1,z0
	add	atemp2,i0
	neg	z0
	neg	i0
	add	leftz,z0
	add	lefti,i0
	move	z0,z1
	move	i0,i1
	add	b_zinc,z1
	add	b_iinc,i1
	move	z1,z2
	move	i1,i2
	add	b_zinc,z2
	add	b_iinc,i2
	move	z2,z3			; NOTE: atemp0 = z3, atemp1 = i3
	move	i2,i3
	add	b_zinc,z3		; atemp0 = z3
	add	b_iinc,i3		; atemp1 = i3
	sat24	i0
	sat24	i1
	sat24	i2
	sat24	i3

	addqt	#12,bi3_ptr
	addqt	#12,bz3_ptr

.if (^^defined PROFILING)
	ADDTIME	SCANLINES
.endif

	moveta	atemp0,spill0		; temporarily save z3

	shlq	#2,b_zinc		; multiply Z increment by 4 for phrase mode

	; make sure intensity increment*4 fits in 24 bits
	abs	b_iinc
	jr	CC,.posiinc
	shlq	#3,b_iinc			; multiply by 8
		sat24	b_iinc
		shrq	#1,b_iinc
		neg	b_iinc
		shlq	#8,b_iinc
		jr	.storiinc
		shrq	#8,b_iinc
.posiinc:
	sat24	b_iinc
	shrq	#1,b_iinc
.storiinc:


.bwait:
	load	(bcmd_ptr),atemp0
	btst	#0,atemp0
	jr	EQ,.bwait
	nop

	movefa	spill0,atemp0

.if (^^defined PROFILING)
	ADDTIME	BLITWAIT
.endif

;
; set Y to Y|X (i.e. A1_PIXEL value)
; and set bcount to the (16 bit) count value
;
	store	i0, (bi3_ptr)
	subqt	#4,bi3_ptr
	store	z0, (bz3_ptr)
	subqt	#4,bz3_ptr
	store	i1, (bi3_ptr)
	subqt	#4,bi3_ptr
	store	z1, (bz3_ptr)
	subqt	#4,bz3_ptr
	store	i2,(bi3_ptr)
	subqt	#4,bi3_ptr
	store	z2,(bz3_ptr)
	subqt	#4,bz3_ptr
	store	i3,(bi3_ptr)
	store	z3,(bz3_ptr)

	store	b_iinc,(biinc_ptr)
	store	b_zinc,(bzinc_ptr)
	store	ay,(a1_ptr)		; set A1_PIXEL
	store	bcount,(bcount_ptr)
	store	bcmdval,(bcmd_ptr)	; starts the blit

.zerocount:
	movefa	leftistep,atemp1
	movefa	leftzstep,atemp0
	add	atemp1,lefti
	add	atemp0,leftz
	sat24	lefti
	movefa	rightistep,atemp1
	movefa	rightzstep,atemp0
	add	atemp1,righti
	add	atemp0,rightz
	sat24	righti


	shrq	#16,ay
	add	leftxstep,leftx
	addqt	#1,ay
	add	rightxstep,rightx
	shlq	#16,ay
	subq	#1,anumlines
	movei	#gourline,atemp0
	jump	PL,(atemp0)
	nop

gourdone:

.if (^^defined PROFILING)
	ADDTIME	SCANLINES
.endif


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

	.equrundef	z0
	.equrundef	z1
	.equrundef	z2
	.equrundef	z3

	.equrundef	i0
	.equrundef	i1
	.equrundef	i2
	.equrundef	i3

	.equrundef	spill0
	.equrundef	spill1
