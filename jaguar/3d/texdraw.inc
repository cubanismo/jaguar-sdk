;***********************************************************
; Texture mapping module
; For now, this just does basic texture mapping
;***********************************************************


bcount_ptr	.equr	b_zinc			; address of B_COUNT
srcpix		.equr	b_color			; next value for A1_PIXEL
srcfpix		.equr	atemp2			; next value for A1_FPIXEL


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
; set up Z increment register
;
	movefa	b_zinc,temp0
	movei	#B_ZINC,temp2
	store	temp0,(temp2)

;
; set up the destination registers
;
	movefa	a2_ptr,temp2
	movefa	destaddr,temp1
	subqt	#(A2_PIXEL-A2_BASE),temp2
	store	temp1,(temp2)		; set A2_BASE
	addqt	#4,temp2
	movefa	destflags,temp1
	movei	#XADDPIX,temp0
	or	temp1,temp0
	store	temp0,(temp2)		; set A2_FLAGS
;
; set up the source registers
;
	movei	#A1_INC,temp2
	movefa	b_vinc,temp1		; get integer parts of source increments
	movefa	b_uinc,temp0		; (u is source X, v is source Y)
	shrq	#16,temp1
	shrq	#16,temp0
	shlq	#16,temp1		; vinc (=source Y increment) goes in high word
	or	temp0,temp1
	store	temp1,(temp2)		; set A1_INC
	addqt	#(A1_FINC-A1_INC),temp2

	movefa	b_uinc,temp0		; get fractional parts of source increments
	movefa	b_vinc,temp1
	shlq	#16,temp0
	shlq	#16,temp1
	shrq	#16,temp0		; uinc (= source X increment) goes in low word
	or	temp0,temp1
	store	temp1,(temp2)		; set A1_FINC

	movefa	a1_ptr,temp2
	movefa	srcaddr,temp1
	subqt	#(A1_PIXEL-A1_BASE),temp2
	store	temp1,(temp2)		; set A1_BASE
	addqt	#4,temp2
	movefa	srcflags,temp1
	movei	#XADDINC,temp0
	or	temp1,temp0
	store	temp0,(temp2)		; set A1_FLAGS


	movei	#SRCEN|LFU_S|DSTA2|ZBUFF|ZMODEGT|DSTENZ|DSTWRZ|DSTEN|BKGWREN,temp1
	movei	#B_COUNT,temp0
	moveta	temp1,bcmdval
	moveta	temp0,bcount_ptr
	jump	(return)
	nop

;
; per-trapezoid set up for texture mapping
;
	.globl	textrap
textrap:
	.REGBANK0

	move	leftx,atemp0
	move	rightx,bcount
	shrq	#16,atemp0
	shrq	#16,bcount
	or	atemp0,ay
	sub	atemp0,bcount

	movei	#texdone,trapdone

	move	PC,traploop
	addqt	#4,traploop

texline:

	subq	#1,anumlines
	jump	MI,(trapdone)
;	nop

	cmpq	#1,bcount
	movei	#.zerocount,atemp0
	jump	MI,(atemp0)		; if the line is empty, don't actually do a blit
	bset	#16,bcount

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
	or	atemp0,srcfpix

.bwait:
	load	(bcmd_ptr),atemp0
	btst	#0,atemp0
	jr	EQ,.bwait
	nop

;
; set A2_PIXEL, B_COUNT, B_Z3, and B_CMD, and A1_PIXEL, A1_FPIXEL
;
	
	store	srcpix, (a1_ptr)			; set A1_PIXEL
	store	leftz, (bz3_ptr)		; set B_Z3
	addqt	#(A1_FPIXEL-A1_PIXEL),a1_ptr	; move to A1_FPIXEL
	store	srcfpix, (a1_ptr)
	store	ay,(a2_ptr)			; set A2_PIXEL
	subqt	#(A1_FPIXEL-A1_PIXEL),a1_ptr

	store	bcount,(bcount_ptr)
	store	bcmdval,(bcmd_ptr)	; starts the blit

.zerocount:
	shrq	#16,ay			; strip X from the pixel stuff
	add	leftzstep,leftz
	add	leftxstep,leftx
	add	rightxstep,rightx
	move	leftx,atemp0
	move	rightx,bcount
	shrq	#16,atemp0
	shrq	#16,bcount
	addqt	#1,ay			; increment Y
	sub	atemp0,bcount
	shlq	#16,ay			; put Y in high word
	or	atemp0,ay		; put X in low word
;
; increment appropriate stuff
;
	add	leftvstep,leftv
	add	leftustep,leftu

	jump	(traploop)
	nop

texdone:

	movei	#G_FLAGS,atemp0			; switch back to bank 1
	load	(atemp0),atemp1
	movefa	return,atemp2
	bset	#14,atemp1
	jump	(atemp2)
	store	atemp1,(atemp0)			; the jump will flush the prefetch queue
;	nop					; and take 3 cycles, giving time for the new flags
;	nop					; to take effect
	.REGBANK1

	.equrundef	bcount_ptr
	.equrundef	srcpix
	.equrundef	srcfpix
