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
;
; TEXSHADE is set to either 1 (flat shading) or 2 (gouraud shading)
; in the main module
GSHADE = 2

; blitter command flags to write for the first of 3 blits
.if TEXSHADE = GSHADE

FIRSTBCMD	=	(PATDSEL|GOURD|DSTA2)
; blitter command flags for the 2nd (gouraud shade) blit
MIDBCMD		=	(SRCEN|DSTA2|DSTEN|ADDDSEL)

.else
FIRSTBCMD	=	(SRCEN|ADDDSEL|DSTA2)
.endif

; blitter command flags for the last blit
LASTBCMD	=	(SRCEN|LFU_S|DSTEN|DSTENZ|DSTWRZ|ZMODEGT|BKGWREN)

srcpix		.equr	b_color			; next value for A1_PIXEL
srcfpix		.equr	atemp2			; next value for A1_FPIXEL

z0		.equr	srcpix			; first Z value for second blit

gpuflags	.equr	b_iinc			; flags for the GPU buffer


altbcount	.equr	traptemp0		; adjusted count (for GPU RAM, count must be even)
countaddr	.equr	traptemp1		; address of B_COUNT
bi3addr		.equr	traptemp2		; address of B_I3
texdoneaddr	.equr	traptemp3
texlineaddr	.equr	traptemp4
texzerocntaddr	.equr	traptemp5

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

	movefa	srcflags,temp0
	movei	#XADDINC,temp1
	or	temp1,temp0
	moveta	temp0,srcflags

;
; set up the increment registers
;
.if TEXSHADE = GSHADE
	movei	#B_PATD,temp0		; set the pattern data register to 0 for shading
	moveq	#0,temp1
	store	temp1,(temp0)
	addqt	#4,temp0
	store	temp1,(temp0)

	movefa	b_iinc,temp0
	movei	#B_IINC,temp2
	shlq	#8,temp0		; strip the color component
	shrq	#8,temp0
	store	temp0,(temp2)
.endif

	movei	#A1_INC,temp2
	movefa	b_vinc,temp1		; get integer parts of source increments
	movefa	b_uinc,temp0		; (u is source X, v is source Y)
	shrq	#16,temp1
	shrq	#16,temp0
	shlq	#16,temp1		; vinc (=source Y increment) goes in high word
	or	temp0,temp1
	store	temp1,(temp2)		; set A1_INC

	movefa	b_uinc,temp0		; get fractional parts of source increments
	movefa	b_vinc,temp1
	shlq	#16,temp0
	shlq	#16,temp1
	shrq	#16,temp0		; uinc (= source X increment) goes in low word
	addqt	#(A1_FINC-A1_INC),temp2
	or	temp0,temp1
	jump	(return)
	store	temp1,(temp2)		; set A1_FINC


;**********************************************
; Render a texture mapped trapezoid
;**********************************************

	.globl	textrap
textrap:
	.REGBANK0				; we are entered in register bank 0

	cmpq	#1,anumlines		; if anumlines < 1, return
	movei	#texdone,atemp0
	jump	MI,(atemp0)
	moveta	atemp0,texdoneaddr

	movei	#B_COUNT,atemp0
.if TEXSHADE = GSHADE
	movei	#B_I3,atemp1
.else
	movei	#B_DSTD,atemp1
.endif
	moveta	atemp0,countaddr
	moveta	atemp1,bi3addr

	movei	#texzerocount,atemp0
	movei	#texline1,atemp1
	moveta	atemp0,texzerocntaddr
	moveta	atemp1,texlineaddr
	movei	#(PIXEL16|WID320|PITCH1|XADDPIX),gpuflags	; initial A2_FLAGS

	.globl	texline1
texline1:

	subq	#1,anumlines
	movefa	texdoneaddr,atemp0	; branch address is "texdone"
	jump	MI,(atemp0)

	move	leftx,atemp0
	move	rightx,bcount
	shrq	#16,atemp0
	shrq	#16,bcount
	sub	atemp0,bcount
	or	atemp0,ay

	cmpq	#1,bcount
	movefa	texzerocntaddr,atemp0
	jump	MI,(atemp0)		; if the line is empty, don't actually do a blit
	bset	#16,bcount

	movei	#FIRSTBCMD,bcmdval
;
; set up srcpix and srcfpix
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
	moveta	bcount,altbcount
	or	atemp0,srcfpix

.if TEXSHADE != GSHADE
	rorq	#16,lefti			; put significant bits in low word (for B_DSTD)
.endif

; for blits into GPU RAM, count must be even
	addqt	#1,bcount

.bwait:
	load	(bcmd_ptr),atemp1
	bclr	#0,bcount
	btst	#0,atemp1
	jr	EQ,.bwait
	moveq	#0,atemp0

	store	srcpix, (a1_ptr)		; set A1_PIXEL
	store	atemp0,(a2_ptr)					; set A2_PIXEL to 0
	addqt	#(A1_FPIXEL-A1_PIXEL),a1_ptr	; move to A1_FPIXEL
	subqt	#(A2_PIXEL-A2_FLAGS),a2_ptr
	store	srcfpix, (a1_ptr)
	store	gpuflags,(a2_ptr)				; set A2_FLAGS
	subqt	#(A1_FPIXEL-A1_BASE),a1_ptr	; move to A1_BASE
	addqt	#(A2_PIXEL-A2_FLAGS),a2_ptr
	store	srcaddr,(a1_ptr)

	movefa	countaddr,atemp1
	addqt	#4,a1_ptr			; move to A1_FLAGS
	store	bcount,(atemp1)			; set B_COUNT
	store	srcflags,(a1_ptr)
	movefa	bi3addr,atemp0
	addqt	#(A1_PIXEL-A1_FLAGS),a1_ptr
	store	lefti,(atemp0)			; set up intensity
	store	bcmdval,(bcmd_ptr)		; start the first blit

.if TEXSHADE != GSHADE
	rorq	#16,lefti			; restore lefti before updating it
.else
;
; set up for the second blit
;
	movei	#MIDBCMD,bcmdval
	moveq	#0,srcpix			; value for A2_PIXEL
.gwait:
	load	(bcmd_ptr),atemp0
	btst	#0,atemp0
	jr	EQ,.gwait
	nop

	store	srcpix,(a2_ptr)			; reset A2_PIXEL
	store	bcount,(atemp1)			; atemp1 still points at B_COUNT
	store	bcmdval,(bcmd_ptr)		; set B_CMD: starts the blit
.endif

;
; set up for the last blit
;
	movei	#LASTBCMD,bcmdval
	movefa	altbcount,bcount

;
; because of the Z buffer bug (if source and destination are
; not phrase aligned, the blitter incorrectly shifts the
; destination) we can't do "real" Z buffering. However, we
; can get acceptable results by using a constant Z value
; across the line. This constant Z value must be duplicated
; in both the integer and fractional parts of the Z values
;
	move	leftz,z0
	move	leftz,atemp0
	shrq	#16,z0
	shrq	#16,atemp0
	shlq	#16,z0
	or	atemp0,z0

	add	leftistep,lefti
	add	leftzstep,leftz
	sat24	lefti
	add	rightxstep,rightx
	add	leftxstep,leftx
	add	leftvstep,leftv
	add	leftustep,leftu

	move	bz3_ptr,atemp2
	bclr	#16,gpuflags		; convert XADDPIX to XADDPHR
	addqt	#4,atemp2

	moveq	#0,atemp1
.bwait2:
	load	(bcmd_ptr),atemp0
	btst	#0,atemp0
	jr	EQ,.bwait2
	nop

texline2:
	store	z0,(bz3_ptr)			; set Z values
	store	z0,(atemp2)
	addqt	#8,bz3_ptr
	addqt	#8,atemp2
	store	z0,(bz3_ptr)
	store	z0,(atemp2)
	subqt	#8,bz3_ptr

	store	ay,(a1_ptr)			; set A1_PIXEL
	store	atemp1,(a2_ptr)			; set A2_PIXEL
	subqt	#(A1_PIXEL-A1_BASE),a1_ptr
	subqt	#(A2_PIXEL-A2_FLAGS),a2_ptr
	store	destaddr,(a1_ptr)		; set A1_BASE
	store	gpuflags,(a2_ptr)		; set A2_FLAGS
	addqt	#(A1_FLAGS-A1_BASE),a1_ptr	; move to A1_FLAGS
	addqt	#(A2_PIXEL-A2_FLAGS),a2_ptr
	store	destflags,(a1_ptr)
	movefa	countaddr,atemp0
	addqt	#(A1_PIXEL-A1_FLAGS),a1_ptr	; set A1_FLAGS
	store	bcount,(atemp0)
	store	bcmdval,(bcmd_ptr)		; start the blit

;
; now set up for the next blit, which will be the source->GPU RAM
; blit
;
	bset	#16,gpuflags			; convert XADDPHR->XADDPIX in A2_FLAGS

	shrq	#16,ay				; isolate just the Y value
	movefa	texlineaddr,atemp1
	addqt	#1,ay				; increment it
	jump	(atemp1)
	shlq	#16,ay				; put Y back in high word

;
; if a zero length line was encountered, we must re-do the whole thing
;
texzerocount:
	add	leftistep,lefti
	add	leftzstep,leftz
	add	rightxstep,rightx
	add	leftxstep,leftx
	add	leftvstep,leftv
	add	leftustep,leftu

	shrq	#16,ay				; isolate just the Y value
	movefa	texlineaddr,atemp1
	addqt	#1,ay				; increment it
	jump	(atemp1)
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
	.equrundef	adjusti
