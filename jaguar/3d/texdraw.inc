;***********************************************************
; Texture mapping module: very simple version
; no shading
;***********************************************************
;
;

FIRSTBCMD	=	(SRCEN|LFU_S|DSTEN|DSTENZ|DSTWRZ|ZMODEGT|ZBUFF|DSTA2|BKGWREN)

srcpix		.equr	righti			; next value for A1_PIXEL
srcfpix		.equr	b_color			; next value for A1_FPIXEL

;
; SET-UP ROUTINE FOR TEXTURE MAPPED POLYGONS
; called in regbank 1
;
;	.REGBANK1

	.globl	POLYinit
POLYinit:
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

	jump	(return)
	nop


;**********************************************
; Render a texture mapped trapezoid
;**********************************************

	.globl	POLYdraw
POLYdraw:
textrap:

	.REGBANK0				; we are entered in register bank 0

;
; set up the destination registers
;

	movei	#A2_BASE,atemp2
	store	destaddr,(atemp2)		; set A2_BASE

	movei	#XADDPIX,atemp1
	or	destflags,atemp1
	movei	#A2_FLAGS,atemp2
	store	atemp1,(atemp2)		; set A2_FLAGS
;
; set up the source registers (or as many as we can)
;
	movei	#A1_BASE,atemp2
	store	srcaddr,(atemp2)
	movei	#XADDINC,atemp1
	or	srcflags,atemp1
	addqt	#4,atemp2
	store	atemp1,(atemp2)


	shrq	#16,ay						; strip fractional part of ay
	shlq	#16,ay


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
	or	atemp0,ay		; now ay has Y in high word, X in low word

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

	shlq	#16,atemp1			; atemp2 has UINC; strip high word (integer part)
	shlq	#16,b_vinc
	shrq	#16,atemp1
	or	atemp1,b_vinc

	movei	#FIRSTBCMD,bcmdval

.bwait:
	load	(bcmd_ptr),atemp0
	btst	#0,atemp0
	jr	EQ,.bwait
	nop

	store	srcpix, (a1_ptr)		; set A1_PIXEL
	addqt	#(A1_FPIXEL-A1_PIXEL),a1_ptr	; move to A1_FPIXEL
	store	ay,(a2_ptr)			; set A2_PIXEL to destination pixel
	store	srcfpix, (a1_ptr)
	movei	#A1_INC,a1_ptr		; move to A1_INC
	movei	#B_COUNT,atemp1
	store	bcount,(atemp1)			; set B_COUNT

	store	leftz,(bz3_ptr)			; set up the Z value
	store	b_uinc,(a1_ptr)
	addqt	#(A1_FINC-A1_INC),a1_ptr
	store	b_vinc,(a1_ptr)
	subqt	#(A1_FINC-A1_PIXEL),a1_ptr
	movei	#B_ZINC,atemp2
	store	b_zinc,(atemp2)
	store	bcmdval,(bcmd_ptr)			; start the first blit


;
; come here if a zero length line was encountered
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


	.equrundef	srcpix
	.equrundef	srcfpix
