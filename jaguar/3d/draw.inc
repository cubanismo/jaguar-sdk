;
; draw.s: draw a polygon
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

trapfunc	.equr	subr		; function to call to draw a trapezoid
polyfunc	.equr	cam		; function for setting up a polygon

start		.equr	pgon		; pointer to first point in polygon
end		.equr	orclips		; pointer to last point in polygon
left		.equr	andclips	; pointer to left side point
right		.equr	altpgon		; pointer to right side point

tmap		.equr	r8,1		; texture map for this polygon
color		.equr	r9,1		; color for this polygon

	.globl	drawpoly
drawpoly:
;***********************************
; make sure the blitter is finished
;***********************************
	movefa	bcmd_ptr,temp1
.bwloop1:
	load	(temp1),temp0
	btst	#0,temp0
	jr	EQ,.bwloop1
	nop

;*
; set up the color and texture; "altpgon" points at the material for the
; polygon
;*
	load	(altpgon),color				; get color & intensity (high word) and flags (low word)
.if TEXTURES
	addqt	#4,altpgon

;
; get the texture map info
;
	load	(altpgon),tmap
.endif ; TEXTURES

	shrq	#24,color				; isolate color
	shlq	#8,color
	move	color,temp0				; duplicate color into a long
	shlq	#16,color
	or	temp0,color

	moveta	color,b_color

;
; set up functions
;
	movei	#gourtrap,trapfunc
	movei	#gourpoly,polyfunc
.if TEXTURES
	cmpq	#0,tmap
	jr	EQ,.funcsok
	nop
		movei	#textrap,trapfunc
		movei	#texpoly,polyfunc
.funcsok:
.endif
	.equrundef	color
	.equrundef	tmap

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

	move	start,left
	move	start,right
	addqt	#SIZEOF_XPOINT,left
	addqt	#SIZEOF_XPOINT,right			; right = &pgon->pt[1]
	addqt	#SIZEOF_XPOINT,left			; left = &pgon->pt[0]

polyloop:
	.include	"dotri.inc"

	move	left,right
	addqt	#SIZEOF_XPOINT,left
	cmp	left,end
	movei	#polyloop,temp0
	jump	NE,(temp0)
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
