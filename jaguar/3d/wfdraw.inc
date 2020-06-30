;
; wfdraw.inc: draw a wire frame polygon
; Parameters:
;	altpgon:	points to material to use for this polygon
;	pgon:		points to polygon structure:
;		1 long word giving number of points, then:
;		{ long x,y,z,u,v,i; } 	<-- one per point 
;
; This version of the polygon draw routine works by
; dividing polygons up into triangles. For a triangle,
; dz/dx (or du/dx, etc.) is constant across a scan
; line, so we can get away with *many* fewer divides, in
; general.
;
; REGISTER ASSUMPTIONS:
;
; Assumes the following registers have been initialized:
; destaddr
; destflags
; a1_ptr
; a2_ptr
; bz3_ptr
; bcmd_ptr

start		.equr	pgon		; pointer to first point in polygon
end		.equr	orclips		; pointer to last point in polygon
left		.equr	andclips	; pointer to left side point (end point of line)
right		.equr	altpgon		; pointer to right side point (start point of line)

color		.equr	r4,1		; color for this polygon
sx		.equr	r5,1		; start X coordinate for a line
sy		.equr	r6,1		; start Y coordinate for line
ex		.equr	r7,1		; end X coordinate (converted to X increment)
ey		.equr	r8,1		; end Y coordinate (converted to Y increment)
linelen		.equr	r9,1		; length of the line
bcount_addr	.equr	r10,1		; address of B_COUNT
bcmd_addr	.equr	r11,1		; address of B_CMD
a1inc_addr	.equr	r12,1		; address of A1_INC
a1finc_addr	.equr	r13,1		; address of A1_FINC
a1pix_addr	.equr	r14,1		; address of A1_PIXEL
a1fpix_addr	.equr	r15,1		; address of A1_FPIXEL
bcmd_val	.equr	r16,1		; value for B_CMD
inc_val		.equr	r17,1		; value for A1_INC
finc_val	.equr	r18,1		; value for A1_FINC
outrloop	.equr	r19,1		; outer loop address

	.globl	drawpoly
drawpoly:

	movefa	bcmd_ptr,bcmd_addr
	movefa	a1_ptr,a1pix_addr
	movei	#B_COUNT,bcount_addr
	movei	#A1_FPIXEL,a1fpix_addr
	movei	#A1_INC,a1inc_addr
	movei	#A1_FINC,a1finc_addr
	movei	#PATDSEL,bcmd_val
;*
; set up the color and texture; "altpgon" points at the material for the
; polygon
;*
	load	(altpgon),color				; get color & intensity (high word) and flags (low word)
	shrq	#16,color				; isolate color

;
; set up the blitter
;
.bwait1:
	load	(bcmd_addr),temp0
	btst	#0,temp0
	jr	EQ,.bwait1
	nop

	movei	#B_PATD,temp2
	store	color,(temp2)

	.equrundef	color


;*
; set up for main polygon loop
; "start" is the same as the global register "pgon", and points to the beginning
; of the polygon.
;*

	load	(start),temp0				; get number of vertices
	moveq	#SIZEOF_XPOINT,end			; adjust for size of points
	addqt	#4,start				; start = &pgon->pt[0]
	mult	temp0,end
	add	start,end				; end = &pgon->pt[vertsrem]

	move	end,right
	move	start,left
	subqt	#SIZEOF_XPOINT,right

	move	PC,outrloop
	addqt	#4,outrloop
polyloop:
	load	(right),sx
	load	(left),ex
	addqt	#4,right
	addqt	#4,left
	load	(right),sy
	load	(left),ey
	subqt	#4,right
	subqt	#4,left

	shrq	#16,sx			; strip fractional parts of X
	shrq	#16,ex
	shlq	#16,sx
	shlq	#16,ex
	shrq	#16,sy			; strip fractional parts of Y
	shrq	#16,ey
	shlq	#16,sy
	shlq	#16,ey
	sub	sx,ex			; convert ex and ey to delta x and delta y
	sub	sy,ey
	move	ex,temp0
	move	ey,linelen
	abs	temp0
	abs	linelen
	add	temp0,linelen
	shrq	#16,linelen
	shlq	#16,linelen
	; convert ex and ey to delta x and delta y
	abs	ey
	jr	CC,.posy
	div	linelen,ey
	; while the divide is happening, convert sy to have y in the high word, x in the low
		shrq	#16,sx
		or	sx,sy
		jr	.doney
		neg	ey
.posy:
	shrq	#16,sx
	or	sx,sy
.doney:

	move	ey,inc_val			; make sure the divide is finished

	abs	ex
	jr	CC,.posx
	div	linelen,ex
		move	ey,finc_val
		shrq	#16,inc_val
		shlq	#16,finc_val
		shlq	#16,inc_val
		shrq	#16,linelen
		bset	#16,linelen
		jr	.donex
		neg	ex
.posx:
	move	ey,finc_val
	shrq	#16,inc_val
	shlq	#16,finc_val
	shlq	#16,inc_val

	shrq	#16,linelen
	bset	#16,linelen
.donex:
	move	ex,temp0
	shlq	#16,ex
	shrq	#16,temp0
	shrq	#16,ex
	or	temp0,inc_val
	or	ex,finc_val
	moveq	#0,sx
;
; wait for the blitter
;
.bwait2:
	load	(bcmd_addr),temp0
	btst	#0,temp0
	jr	EQ,.bwait2
	nop

	store	sy,(a1pix_addr)
	store	sx,(a1fpix_addr)
	store	inc_val,(a1inc_addr)
	store	finc_val,(a1finc_addr)
	store	linelen,(bcount_addr)
	store	bcmd_val,(bcmd_addr)

	move	left,right
	addqt	#SIZEOF_XPOINT,left
	cmp	left,end
	jump	NE,(outrloop)
	nop

donedraw:
;
; restore registers we spilled
;
	movei	#camscale,cam

	.equrundef	trapfunc
	.equrundef	polyfunc
	.equrundef	start
	.equrundef	end
	.equrundef	left
	.equrundef	right

	.equrundef	color
	.equrundef	sx
	.equrundef	sy
	.equrundef	ex
	.equrundef	ey
	.equrundef	linelen
	.equrundef	bcount_addr
	.equrundef	bcmd_addr
	.equrundef	a1inc_addr
	.equrundef	a1finc_addr
	.equrundef	a1pix_addr
	.equrundef	a1fpix_addr
	.equrundef	bcmd_val
	.equrundef	inc_val
	.equrundef	finc_val
	.equrundef	outrloop

