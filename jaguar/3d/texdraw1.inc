;***********************************************************
; Texture mapping module: advanced version
; In order to substantially accelerate Z-buffered texture
; mapping, we do 2 blits; once from the source texture
; to GPU RAM, and then from GPU RAM to the screen. The
; second blit is the Z-buffered one, and can be done in
; phrase mode (hence the nearly 2x improvement in raw
; blitting speed). As a bonus, we can work around the
; Z-buffer+SRCSHADE bug, since the first blit isn't
; Z-buffered.
; As a further bonus, gouraud shading is (relatively)
; cheap (it adds another blit, into GPU RAM)
;***********************************************************
;
; the ZBUFF flag needs to be present for SRCSHADE to work

FIRSTBCMD	=	(SRCEN|LFU_S|DSTA2|SRCSHADE|ZBUFF)
;;;FIRSTBCMD	=	(SRCEN|LFU_S|DSTA2)

; blitter command flags for the last blit
LASTBCMD	=	(SRCEN|LFU_S|DSTEN|DSTENZ|DSTWRZ|ZMODEGT|ZBUFF|BKGWREN|DCOMPEN)

srcpix		.equr	righti			; next value for A1_PIXEL
srcfpix		.equr	b_color			; next value for A1_FPIXEL
adjusti		.equr	atemp2			; adjusted intensity value

z0		.equr	srcpix			; first Z value for phrase mode blit
z1		.equr	srcfpix			; second Z value for phrase mode blit
z2		.equr	b_uinc			; third Z value
z3		.equr	b_vinc			; fourth Z value

gpuflags	.equr	b_iinc			; flags for the GPU buffer


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
	movei	#_gpubuf,temp1
	subqt	#(A2_PIXEL-A2_BASE),temp2
	store	temp1,(temp2)		; set A2_BASE

;
; set the pattern data register to -1 for comparison with
; end of line
;
	moveq	#1,atemp0
	movei	#B_PATD,atemp1
	neg	atemp0
	store	atemp0,(atemp1)
	addqt	#4,atemp1
	store	atemp0,(atemp1)

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
	movei	#B_IINC,atemp1
	moveta	atemp0,countaddr
	moveta	atemp1,bi3addr

	movei	#(PIXEL16|WID320|PITCH1|XADDPIX),gpuflags	; initial A2_FLAGS

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
; calculate b_zinc
;
	move	rightz,b_zinc		; find delta Z
	sub	leftz,b_zinc
	move	b_zinc,atemp0		; atemp0 will hold the fractional part of delta Z
	sharq	#16,b_zinc		; put integer part of delta Z in low word
	imult	atemp1,atemp0		; multiply fractional part by reciprocal of line length (a 14 bit number)
	imult	atemp1,b_zinc		; multiply integer part by reciprocal of line length	(a 14 bit number)
	sharq	#14,atemp0		; normalize fractional product
	shlq	#2,b_zinc		; normalize integer product
	add	atemp0,b_zinc
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
	moveta	bcount,altbcount

;
; Kludge: thanks to the way GPU RAM works, the last word we write
; must be on an even boundary. So if (ay+bcount) is odd, we need
; to increase bcount by 1
;
	move	ay,atemp0
	add	bcount,atemp0
	btst	#0,atemp0
	jr	EQ,.even
	nop
		addqt	#1,bcount
.even:

	movei	#$007fffff,atemp0		; adjusti = offset from lefti to $7fffff
	move	lefti,adjusti
	sub	atemp0,adjusti
	shlq	#8,adjusti			; and strip the high byte
	shrq	#8,adjusti			;

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
	store	gpuflags,(a2_ptr)				; set A2_FLAGS
	addqt	#(A2_PIXEL-A2_FLAGS),a2_ptr
	store	srcaddr,(a1_ptr)
	addqt	#4,a1_ptr			; move to A1_FLAGS
	movefa	countaddr,atemp1
	store	bcount,(atemp1)			; set B_COUNT
	store	srcflags,(a1_ptr)
	addqt	#(A1_INC-A1_FLAGS),a1_ptr
	store	b_uinc,(a1_ptr)
	addqt	#(A1_FINC-A1_INC),a1_ptr
	store	b_vinc,(a1_ptr)
	subqt	#(A1_FINC-A1_PIXEL),a1_ptr

	movefa	bi3addr,atemp0
	store	adjusti,(atemp0)		; set up intensity
	store	bcmdval,(bcmd_ptr)		; start the first blit

;
; set up for the last blit
;
	movei	#LASTBCMD,bcmdval
	movefa	altbcount,bcount

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
	add	atemp0,rightz

	move	bz3_ptr,atemp2
	bclr	#16,gpuflags		; convert XADDPIX to XADDPHR
	addqt	#4,atemp2		; make atemp2 point at bz3_ptr+4

;
; set A2_PIXEL to match the phrase offset of the
; destination
;
	moveq	#3,atemp0
	and	ay,atemp0

;
; if the blit started on an odd boundary, then we have to wait
; for the blitter to finish, and then clear out the
; first word of the line
;
	btst	#0,ay
	movei	#texline2,atemp1
	jump	EQ,(atemp1)
	nop

	subqt	#1,atemp0
	movei	#_gpubuf,atemp1		;   make atemp1 point to the first word we'll blit
	addqt	#1,bcount		; write 1 extra word (we're starting on an even rather than odd boundary
	add	atemp0,atemp1		;   add offset to atemp1
	subq	#1,ay			; back up 1 pixel
	add	atemp0,atemp1		;   add offset to atemp1 again (since it's a word offset)

; wait for the blitter to finish
.bwaitodd:
	load	(bcmd_ptr),atemp0
	btst	#0,atemp0
	jr	EQ,.bwaitodd
	nop

	load	(atemp1),atemp0		; load the first 2 words of the blit
	shlq	#15,atemp0		; then fill the first word with $FFFF
	bset	#31,atemp0		; by setting a bit and sign extending it
	sharq	#15,atemp0
	store	atemp0,(atemp1)		; store back the first 2 words
	moveq	#3,atemp0		; now re-calculate atemp0 as the
	jr	dosecondblit
	and	ay,atemp0		; phrase mode offset of the blit

texline2:

.bwait2:
	load	(bcmd_ptr),atemp1
	btst	#0,atemp1
	jr	EQ,.bwait2
	nop

dosecondblit:
	store	z3,(bz3_ptr)			; set Z values
	addqt	#8,bz3_ptr
	store	z2,(atemp2)			; atemp2 contains bz3_ptr + 4
	addqt	#8,atemp2
	store	z1,(bz3_ptr)
	subqt	#8,bz3_ptr
	store	z0,(atemp2)

	shlq	#2,b_zinc
	movei	#B_ZINC,atemp2
	store	b_zinc,(atemp2)

	store	ay,(a1_ptr)			; set A1_PIXEL
	subqt	#(A1_PIXEL-A1_BASE),a1_ptr
	store	atemp0,(a2_ptr)			; set A2_PIXEL
	subqt	#(A2_PIXEL-A2_FLAGS),a2_ptr
	store	destaddr,(a1_ptr)		; set A1_BASE
	addqt	#(A1_FLAGS-A1_BASE),a1_ptr	; move to A1_FLAGS
	store	gpuflags,(a2_ptr)		; set A2_FLAGS
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
	bset	#16,gpuflags			; convert XADDPHR->XADDPIX in A2_FLAGS

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
	add	atemp0,rightz
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

	.equrundef	gpuflags
	.equrundef	altbcount
	.equrundef	countaddr
	.equrundef	bi3addr
	.equrundef	adjusti
