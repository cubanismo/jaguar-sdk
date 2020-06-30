;***********************************************************
; Texture mapping module: gouraud shaded version
; In order add gouraud shading to textures, we do
; 3 blits. The first one sets up the shading; the
; second adds the texture color; and the third blits
; the final, Z buffered image to the screen. We can't
; combine the second and third blits because of blitter
; bugs. Fortunately, the third blit can be done in
; phrase mode, which speeds it up quite a bit; and
; the first two can be done into the color look up
; table if we know that no polygon scan line can be
; more than 256 pixels long. (We can't do gouraud
; shading into GPU RAM because of a combination of
; blitter bugs and GPU RAM peculiarities).
;***********************************************************
;
;
; DATABUF defines where our temporary buffer is. This must
; either be in DRAM or the Colour Lookup Table, since
; GPU RAM can only be read/written on longword boundaries.
;
.if 1
DATABUF = CLUT
.else
; pick some place in DRAM big enough to hold a line of pixels.
DATABUF = $1ef000
.endif

; blitter flags for first blit (setting up gouraud shading)
FIRSTBCMD	=	(PATDSEL|GOURD|DSTA2)

; blitter flags for middle blit (adding texture to shading)
MIDBCMD	=	(SRCEN|DSTEN|ADDDSEL|DSTA2)

; blitter command flags for the last blit
LASTBCMD	=	(SRCEN|LFU_S|DSTEN|DSTENZ|DSTWRZ|ZMODEGT|ZBUFF|BKGWREN|DCOMPEN)

srcpix		.equr	b_color			; next value for A1_PIXEL
srcfpix		.equr	atemp2			; next value for A1_FPIXEL

z0		.equr	srcpix			; first Z value for phrase mode blit
z1		.equr	srcfpix			; second Z value for phrase mode blit
z2		.equr	b_uinc			; third Z value
z3		.equr	b_vinc			; fourth Z value

altbcount	.equr	temp0		; adjusted count (for GPU RAM, count must be even)
countaddr	.equr	temp1		; address of B_COUNT
bi3addr		.equr	temp2		; address of B_I3

;
; SET-UP ROUTINE FOR TEXTURE MAPPED POLYGONS
; called in regbank 1
;
;	.REGBANK1

	.globl	texpoly
texpoly:
;
; make sure the blitter is off
;
	movefa	bcmd_ptr,temp0
.bwait:
	load	(temp0),temp1
	btst	#0,temp1
	jr	EQ,.bwait
	nop

;
; set up the destination registers
;
	movefa	a2_ptr,temp2
	movei	#DATABUF,temp1
	subqt	#(A2_PIXEL-A2_BASE),temp2
	store	temp1,(temp2)		; set A2_BASE

	movefa	srcflags,temp0
	movei	#XADDINC,temp1
	or	temp1,temp0
	jump	(return)
	moveta	temp0,srcflags


;**********************************************
; Render a texture mapped trapezoid
;**********************************************

	.globl	textrap
textrap:
	.REGBANK0				; we are entered in register bank 0

	movei	#B_COUNT,atemp0
	movei	#B_I3,atemp1
	moveta	atemp0,countaddr
	moveta	atemp1,bi3addr

	subq	#1,anumlines
	movei	#texdone,atemp0
	jump	MI,(atemp0)
	nop

	.globl	texline1
texline1:


	move	leftx,atemp0
	move	rightx,bcount
	shrq	#16,atemp0
	shrq	#16,bcount
	sub	atemp0,bcount
	or	atemp0,ay

	cmpq	#1,bcount
	movei	#texzerocount,atemp0
	jump	MI,(atemp0)		; if the line is empty, don't actually do a blit
	nop
;
; calculate 1/bcount
;
	move	bcount,atemp0
	moveq	#1,atemp1
	shlq	#16,atemp0
	shlq	#14,atemp1
	div	atemp0,atemp1		; atemp1 will be a 14 bit signed fraction

	bset	#16,bcount
;
; set up srcpix and srcfpix while the
; divide is happening
;
	move	leftv,atemp0
	move	leftu,srcpix			; srcpix is integer parts of pixel values
	shrq	#16,atemp0
	shrq	#16,srcpix			; low word of srcpix has integer part of leftu in it
	shlq	#16,atemp0			; high word of atemp0 has integer part of leftv in it
	move	leftu,srcfpix
	or	atemp0,srcpix
	shlq	#16,srcfpix			; now srcfpix has fractional part of leftu in high word
	move	leftv,atemp0
	shrq	#16,srcfpix
	shlq	#16,atemp0
	or	atemp0,srcfpix

;
; calculate b_uinc and b_vinc
;
	move	rightv,b_vinc
	move	rightu,b_uinc
	sub	leftv,b_vinc		; find delta V
	sub	leftu,b_uinc		; find delta U
	sharq	#10,b_vinc		; convert to 16 bit (assumes U,V are less than 512)
	sharq	#10,b_uinc
	imult	atemp1,b_vinc		; multiply by 1/linelen
	imult	atemp1,b_uinc
	sharq	#(14-10),b_vinc
	sharq	#(14-10),b_uinc
;
; calculate b_zinc and b_iinc
;
	move	righti,b_iinc
	move	rightz,b_zinc
	sub	lefti,b_iinc
	sub	leftz,b_zinc
	sharq	#9,b_iinc
	sharq	#14,b_zinc
	imult	atemp1,b_iinc
	imult	atemp1,b_zinc
;
; normally, we would adjust b_iinc (which was shifted right by 9 above) by doing
;		sharq	#(14-9),b_iinc
; but since we want to strip the upper 8 bits of b_iinc anyways, instead we can
; do the next 2 instructions: (14-9) = 5, and 8-5 = 3
	shlq	#3,b_iinc
	shrq	#8,b_iinc

;
; now set up b_uinc so it is the integer part of A1_INC, b_vinc so it is the fractional part
;
	move	b_vinc,atemp0
	move	b_uinc,atemp1
	shrq	#16,atemp0			; strip fractional part of VINC
	shrq	#16,b_uinc			; get integer part of UINC into low word
	shlq	#16,atemp0
	or	atemp0,b_uinc			; integer part of VINC goes into high word of b_uinc

	shlq	#16,atemp1			; atemp1 has UINC; strip high word (integer part)
	shlq	#16,b_vinc
	shrq	#16,atemp1
	or	atemp1,b_vinc

	movei	#FIRSTBCMD,bcmdval
;
; set up to blit to pixel N, where N=the same offset into
; the phrase as in the destination
;
	moveq	#3,atemp0
	and	ay,atemp0
.bwait:
	load	(bcmd_ptr),atemp1
	btst	#0,atemp1
	jr	EQ,.bwait
	nop

	store	srcpix, (a1_ptr)		; set A1_PIXEL
	addqt	#(A1_FPIXEL-A1_PIXEL),a1_ptr	; move to A1_FPIXEL
	store	atemp0,(a2_ptr)					; set A2_PIXEL to initial pixel to blit
	subqt	#(A2_PIXEL-A2_FLAGS),a2_ptr
	store	srcfpix, (a1_ptr)
	subqt	#(A1_FPIXEL-A1_BASE),a1_ptr	; move to A1_BASE
	movei	#(PIXEL16|WID320|PITCH1|XADDPIX),atemp0		; initial A2_FLAGS
	store	atemp0,(a2_ptr)				; set A2_FLAGS
	addqt	#(A2_PIXEL-A2_FLAGS),a2_ptr
	store	srcaddr,(a1_ptr)
	addqt	#4,a1_ptr			; move to A1_FLAGS
	movefa	countaddr,atemp1
	store	bcount,(atemp1)			; set B_COUNT

;
; set the pattern data register to 0 for gouraud shade
;
	movei	#B_PATD,atemp1
	moveq	#0,atemp0
	store	atemp0,(atemp1)
	addqt	#4,atemp1
	store	atemp0,(atemp1)

	store	srcflags,(a1_ptr)
	addqt	#(A1_INC-A1_FLAGS),a1_ptr
	store	b_uinc,(a1_ptr)
	addqt	#(A1_FINC-A1_INC),a1_ptr
	store	b_vinc,(a1_ptr)
	movefa	bi3addr,atemp0
	subqt	#(A1_FINC-A1_PIXEL),a1_ptr
	store	lefti,(atemp0)			; set up intensity

	movei	#B_IINC,atemp1
	store	b_iinc,(atemp1)
	store	bcmdval,(bcmd_ptr)		; start the first blit

;
; get ready for the middle blit (to add texture)
;
	movei	#MIDBCMD,bcmdval

	moveq	#3,atemp0
	and	ay,atemp0
.bwaitmid:
	load	(bcmd_ptr),atemp1
	btst	#0,atemp1
	jr	EQ,.bwaitmid
	nop

	store	srcpix, (a1_ptr)		; set A1_PIXEL
	addqt	#(A1_FPIXEL-A1_PIXEL),a1_ptr	; move to A1_FPIXEL
	store	atemp0,(a2_ptr)					; set A2_PIXEL to initial pixel to blit
	store	srcfpix, (a1_ptr)
	subqt	#(A1_FPIXEL-A1_PIXEL),a1_ptr
;
; set the pattern data register to $FFFFFFFF for future use
;
	movei	#B_PATD,atemp1
	movei	#$FFFFFFFF,atemp0
	store	atemp0,(atemp1)
	addqt	#4,atemp1
	store	atemp0,(atemp1)

	movefa	countaddr,atemp0
	store	bcount,(atemp0)			; set B_COUNT

	store	bcmdval,(bcmd_ptr)		; start the middle blit

;
; set up for the last blit
;
	movei	#LASTBCMD,bcmdval

;
; set up Z values for phrase mode blit
;
	moveq	#3,atemp0
	move	leftz,z0		; initialize z0 to leftz
	and	ay,atemp0		; now atemp0 has the phrase offset (in pixels)
;
; now we must subtract b_zinc * the phrase offset from z0
;
.z0loop:
	subq	#1,atemp0
	jr	MI,.donez0
	nop
		sub	b_zinc,z0
		jr	.z0loop
		nop
.donez0:

	move	z0,z1
	add	b_zinc,z1
	move	z1,z2
	add	b_zinc,z2
	move	z2,z3
	add	b_zinc,z3

	movefa	leftistep,atemp1
	movefa	leftzstep,atemp0
	add	atemp1,lefti
	add	atemp0,leftz
	sat24	lefti
	add	rightxstep,rightx
	add	leftxstep,leftx
	movefa	leftvstep,atemp0
	movefa	leftustep,atemp1
	add	atemp0,leftv
	add	atemp1,leftu

	movefa	rightvstep,atemp0
	movefa	rightustep,atemp1
	add	atemp0,rightv
	add	atemp1,rightu
	movefa	rightzstep,atemp0
	movefa	rightistep,atemp1
	add	atemp0,rightz
	add	atemp1,righti

;
; set A2_PIXEL to match the phrase offset of the
; destination
;
	moveq	#3,atemp0
	and	ay,atemp0

texline2:

.bwait2:
	load	(bcmd_ptr),atemp1
	btst	#0,atemp1
	jr	EQ,.bwait2
	nop

	store	z3,(bz3_ptr)			; set Z values
	addqt	#4,bz3_ptr
	store	z2,(bz3_ptr)
	addqt	#4,bz3_ptr
	store	z1,(bz3_ptr)
	addqt	#4,bz3_ptr
	store	z0,(bz3_ptr)
	subqt	#12,bz3_ptr

	shlq	#2,b_zinc
	movei	#B_ZINC,atemp2
	store	b_zinc,(atemp2)

	store	ay,(a1_ptr)			; set A1_PIXEL
	subqt	#(A1_PIXEL-A1_BASE),a1_ptr
	store	atemp0,(a2_ptr)			; set A2_PIXEL
	subqt	#(A2_PIXEL-A2_FLAGS),a2_ptr
	store	destaddr,(a1_ptr)		; set A1_BASE
	addqt	#(A1_FLAGS-A1_BASE),a1_ptr	; move to A1_FLAGS
	movei	#(PIXEL16|WID320|PITCH1|XADDPHR),atemp0		; final A2_FLAGS
	store	atemp0,(a2_ptr)		; set A2_FLAGS
	addqt	#(A2_PIXEL-A2_FLAGS),a2_ptr
	store	destflags,(a1_ptr)
	addqt	#(A1_PIXEL-A1_FLAGS),a1_ptr	; set A1_FLAGS
	movefa	countaddr,atemp0
	store	bcount,(atemp0)
	store	bcmdval,(bcmd_ptr)		; start the blit


;
; now set up for the next blit, which will be the source->GPU RAM
; blit
;

	movei	#texline1,atemp1
	shrq	#16,ay				; isolate just the Y value
	subq	#1,anumlines
	addqt	#1,ay				; increment it
	jump	PL,(atemp1)
	shlq	#16,ay				; put Y back in high word

	movei	#texdone,atemp1
	jump	(atemp1)
	nop

;
; if a zero length line was encountered, we must re-do the whole thing
;
texzerocount:
	movefa	leftistep,atemp1
	movefa	leftzstep,atemp0
	add	atemp1,lefti
	add	atemp0,leftz
	add	rightxstep,rightx
	add	leftxstep,leftx
	movefa	leftvstep,atemp0
	movefa	leftustep,atemp1
	add	atemp0,leftv
	add	atemp1,leftu
	movefa	rightvstep,atemp0
	movefa	rightustep,atemp1
	add	atemp0,rightv
	add	atemp1,rightu
	movefa	rightzstep,atemp0
	movefa	rightistep,atemp1
	add	atemp0,rightz
	add	atemp1,righti
	movei	#texline1,atemp1
	shrq	#16,ay				; isolate just the Y value
	subq	#1,anumlines
	addqt	#1,ay				; increment it
	jump	PL,(atemp1)
	shlq	#16,ay				; put Y back in high word

texdone:

;
; we have to wait here for the blitter to finish, because
; mmult loses if there's a blit going on out of
; GPU RAM
;
.bwait:
	load	(bcmd_ptr),atemp0
	btst	#0,atemp0
	jr	EQ,.bwait
	nop

	movei	#G_FLAGS,atemp1			; switch back to bank 1
	load	(atemp1),atemp0
	movefa	return,atemp2
	bset	#14,atemp0
	jump	(atemp2)
	store	atemp0,(atemp1)			; the jump will flush the prefetch queue
;	nop					; and take 3 cycles, giving time for the new flags
;	nop					; to take effect
	.REGBANK1


	.equrundef	z0
	.equrundef	z1
	.equrundef	z2
	.equrundef	z3
	.equrundef	srcpix
	.equrundef	srcfpix

	.equrundef	altbcount
	.equrundef	countaddr
	.equrundef	bi3addr
