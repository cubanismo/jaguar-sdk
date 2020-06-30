NEWPOLY	=	1
;
;
; drawpoly.inc: draw a polygon, using the GPU
; Parameters:
;	altpgon: points to material to use for this polygon
;	pgon:	points to polygon structure:
;		1 long word giving number of points, then:
;		{ long x,y,z,u,v,i; } 	<-- one per point 
;
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
;
; Uses the trapezoid rendering definitions given above
; Runs with Bank 1 as the default, switches to Bank 0
; during the trapezoid rendering
;

FUDGE	=	7

start		.equr	pgon		; pointer to first point in polygon
end		.equr	r4,1		; pointer to last point in polygon
vertsrem	.equr	r5,1		; number of vertices remaining in polygon
left		.equr	r6,1		; pointer to left side point
right		.equr	r7,1		; pointer to right side point
y		.equr	r8,1		; current Y value
ly		.equr	r9,1		; left Y value
ry		.equr	r10,1		; right Y value
;
; some temporary register definitions
;
tmap		.equr	r12,1		; pointer to texture map
color		.equr	r13,1		; color for this polygon

	.globl	drawpoly
drawpoly:
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
	movei	#gourtrap,temp0
	movei	#gourpoly,temp1
.if TEXTURES
	cmpq	#0,tmap
	jr	EQ,.funcsok
	nop
		movei	#textrap,temp0
		movei	#texpoly,temp1
.funcsok:
.endif
	moveta	temp0,atemp0		; save per-trapezoid function in atemp0
	moveta	temp1,atemp1		; save per-polygon function in atemp1
	.equrundef	color
	.equrundef	tmap

	load	(start),vertsrem			; get number of vertices
	moveq	#SIZEOF_XPOINT,end			; adjust for size of points
	addqt	#4,start				; start = &pgon->pt[0]
	mult	vertsrem,end
	add	start,end				; end = &pgon->pt[vertsrem]

;
; find the top vertex, and put it into "left"
;
	move	start,right
	move	start,left
	addqt	#SIZEOF_XPOINT,right

;
; initialize y
;
	addqt	#4,left					; skip X
	addqt	#4,right				; skip X

.loadleft:
	load	(left),y				; set y = left->y
	sharq	#16,y
.forlp:
	cmp	end,right
	jr	PL,.endfor
	nop
	load	(right),temp0
	addqt	#SIZEOF_XPOINT,right
	sharq	#16,temp0				; set temp0 = right->y
	cmp	y,temp0					; if y <= right->y
	jr	PL,.forlp				; 	continue
	nop
	move	right,left
	subqt	#SIZEOF_XPOINT,left
	move	temp0,y
	jr	.forlp
	nop
.endfor:

;
; at this point, "y" contains the smallest Y value, and "left" points to the
; Y value of a topmost vertex
;
	subqt	#4,left				; point to start of vertex record
	move	y,ly
	move	y,ry
	subqt	#1,ly
	subqt	#1,ry
	move	left,right

;***********************************
; make sure the blitter is finished
;***********************************
	movefa	bcmd_ptr,temp1
.bwloop1:
	load	(temp1),temp0	
	btst	#0,temp0
	jr	EQ,.bwloop1
	movefa	atemp1,temp2		; retrieve address of per-polygon routine

;
; do per-polygon setup
;
	move	PC,return
	jump	(temp2)
	addqt	#6,return

numlines	.equr	r11,1		; divisor for various things
nlnorm		.equr	r12,1		; 
nextval		.equr	r13,1		; temporary register
trapfunc	.equr	r14,1		; address of per-trapezoid rendering function
innerloop	.equr	return		; inner loop branch address

;
; registers r15-r22 are now free
; (AND ARE USED BY POLYREGS.INC)

	movefa	atemp0,trapfunc
;
; set up initial left and right values
;
	load	(left),temp0			; temp0 = (left->x << 16)
	addqt	#8,left				; skip X and Y
	moveta	temp0,leftx
	moveta	temp0,rightx
	load	(left),temp0			; temp0 = left->z
	addqt	#4,left
	load	(left),temp1			; temp1 = left->i
	addqt	#4,left
	moveta	temp0,leftz
	moveta	temp1,lefti
	moveta	temp0,rightz
	moveta	temp1,rightz
.if TEXTURES
	load	(left),temp0			; temp0 = left->u
	addqt	#4,left
	load	(left),temp1			; temp1 = left->v
	subqt	#20,left			; move back to start
	moveta	temp0,leftu
	moveta	temp1,leftv
	moveta	temp0,rightu
	moveta	temp1,rightv
.else
	subqt	#16,left
.endif

;
; main loop goes here
;
	.globl	polyloop
polyloop:
	; while (vertsrem > 0)
	sat16	vertsrem
	movei	#endloop,temp0
	jump	EQ,(temp0)
	nop

	; find bottom right vertex
	; while (ry <= y && vertsrem > 0)

.rightloop:
	cmp	ry,y
	movei	#doneright,temp2
	jump	MI,(temp2)
	nop
.repeatright:
	move	PC,innerloop
	subq	#1,vertsrem
	jump	MI,(temp2)			; temp2 still contains "doneright"
	nop
		load	(right),temp0		; temp0 = current right->x	 (branch optimization)
		addqt	#8,right
		load	(right),temp1
		addqt	#4,right
		moveta	temp0,rightx
		moveta	temp1,rightz
		load	(right),temp0		; temp0 = lefti
		addqt	#4,right
		moveta	temp0,righti
.if TEXTURES
		load	(right),temp0
		addqt	#4,right
		load	(right),temp1
		addqt	#4,right
		moveta	temp0,rightu
		moveta	temp1,rightv
.else
		addqt	#8,right
.endif

		cmp	right,end
		jr	NE,.norightwrap
		nop
			move	start,right
.norightwrap:
		load	(right),nextval		; nextval = right->x
		addqt	#4,right
		load	(right),ry		; ry = right->y
		subqt	#4,right		; put right at beginning of point so the jump EQ,(innerloop) below will work
		shrq	#16,ry
;
; divides are expensive, so instead of dividing to find the various step values, we multiply
; by 1/numlines, which is stored as a 15 bit fraction in "numlines" with an exponent in 
; "nlnorm"
;
		move	ry,temp0
		movei	#(1<<24),numlines
		sub	y,temp0			; temp0 = (ry - y)
		jump	EQ,(innerloop)		; if (ry == y) repeat the loop
		shlq	#16,temp0

		addqt	#8,right		; move right to right->z
		div	temp0,numlines

		movefa	rightx,temp0
		sub	temp0,nextval		; rightxstep = Fixdiv( nextval - rightx, numlines )

		normi	numlines,nlnorm
		addqt	#9,nlnorm		; make it a 15 bit fraction instead of 24 bit
		sha	nlnorm,numlines
		neg	nlnorm			; now nlnorm is an adjustment for multiplies
		addqt	#(24-16),nlnorm		; norm is a 24 bit fraction; but we will predivide nextval by 16

		move	nextval,temp0		; temp0 = fractional part of nextval
		sharq	#16,nextval		; make nextval an integer
		mult	numlines,temp0
		imult	numlines,nextval
		shrq	#16,temp0
		add	temp0,nextval		; now nextval is "numlines*nextval" >> 16
		sha	nlnorm,nextval

		moveta	nextval,rightxstep

		movefa	rightz,temp0
		movefa	righti,temp1
		load	(right),nextval		; nextval = right->z
		addqt	#4,right
		load	(right),temp2		; temp2 = right->i
		addqt	#4,right
		sub	temp0,nextval
		sub	temp1,temp2

		move	nextval,temp0		; temp0 = fractional part of nextval
		sharq	#16,nextval		; make nextval an integer
		mult	numlines,temp0
		imult	numlines,nextval
		shrq	#16,temp0
		add	temp0,nextval		; now nextval is "numlines*nextval" >> 16
		sha	nlnorm,nextval

		move	nextval,rightzstep

		move	temp2,nextval		; nextval = nextright->i - curright->i
		move	temp2,temp0		; temp0 = fractional part of nextval
		sharq	#16,nextval		; make nextval an integer
		mult	numlines,temp0
		imult	numlines,nextval
		shrq	#16,temp0
		add	temp0,nextval		; now nextval is "numlines*nextval" >> 16
		sha	nlnorm,nextval

		move	nextval,rightistep

.if TEXTURES
		load	(right),nextval		; nextval = right->u
		addqt	#4,right
		load	(right),temp2		; temp2 = right->v
		subqt	#20,right
		movefa	rightu,temp0
		movefa	rightv,temp1
		sub	temp0,nextval		; now nextval = nextright->u - curright->u
		sub	temp1,temp2		; and temp2 = nextright->v - curright->v

		move	nextval,temp0		; temp0 = fractional part of nextval
		sharq	#16,nextval		; make nextval an integer
		mult	numlines,temp0
		imult	numlines,nextval
		shrq	#16,temp0
		add	temp0,nextval		; now nextval is "numlines*nextval" >> 16
		sha	nlnorm,nextval

		move	nextval,rightustep

		move	temp2,nextval		; nextval = nextright->v - curright->v
		move	temp2,temp0		; temp0 = fractional part of nextval
		sharq	#16,nextval		; make nextval an integer
		mult	numlines,temp0
		imult	numlines,nextval
		shrq	#16,temp0
		add	temp0,nextval		; now nextval is "numlines*nextval" >> 16
		sha	nlnorm,nextval

		move	nextval,rightvstep
.else
		subqt	#16,right
.endif

doneright:

	; now find the bottom left vertex
	; while (ly <= y && vertsrem > 0)
.leftloop:
	cmp	ly,y
	movei	#doneleft,temp2
	jump	MI,(temp2)
	nop
.repeatleft:
	move	PC,innerloop
	subq	#1,vertsrem
	jump	MI,(temp2)			; temp2 still contains "doneleft"
	nop
		load	(left),temp0		; temp0 = left->x		
		addqt	#8,left			; skip X and Y

		moveta	temp0,leftx
		load	(left),temp0		; temp0 = leftz
		addqt	#4,left
		moveta	temp0,leftz
		load	(left),temp1		; temp1 = lefti
.if TEXTURES
		addqt	#4,left
.else
		subqt	#12,left		; move back to start of poly
.endif
		moveta	temp1,lefti

.if TEXTURES
		load	(left),temp1		; temp1 = left->u
		addqt	#4,left
		moveta	temp1,leftu
		load	(left),temp0		; temp2 = left->v
		subqt	#20,left		; reset to beginning
		moveta	temp0,leftv
.endif

		; if (left == start) left = end
		cmp	start,left
		jr	NE,.noleftwrap
		nop
			move	end,left
.noleftwrap:
		; left--
		subqt	#SIZEOF_XPOINT,left

		load	(left),nextval		; nextval = left->x
		addqt	#4,left
		load	(left),ly		; ly = left->y
		subqt	#4,left			; put left at beginning of point so the jump EQ,(innerloop) below will work
		shrq	#16,ly
;
; divides are expensive, so instead of dividing to find the various step values, we multiply
; by 1/numlines, which is stored as a 15 bit fraction in "numlines" with an exponent in 
; "nlnorm"
;
		move	ly,temp0
		movei	#(1<<24),numlines
		sub	y,temp0			; temp0 = (ly - y)
		jump	EQ,(innerloop)		; if (ly == y) repeat the loop
		shlq	#16,temp0

		addqt	#8,left			; move left to left->z (interleaved, so it's free)
		div	temp0,numlines

		movefa	leftx,temp0
		sub	temp0,nextval		; leftxstep = Fixdiv( nextval - leftx, numlines )

		normi	numlines,nlnorm
		addqt	#9,nlnorm		; make it a 15 bit fraction instead of 24 bit
		sha	nlnorm,numlines
		neg	nlnorm			; now nlnorm is an adjustment for multiplies
		addqt	#(24-16),nlnorm		; norm is a 24 bit fraction; but we will predivide nextval by 16

		move	nextval,temp0		; temp0 = fractional part of nextval
		sharq	#16,nextval		; make nextval an integer
		mult	numlines,temp0
		imult	numlines,nextval
		shrq	#16,temp0
		add	temp0,nextval		; now nextval is "numlines*nextval" >> 16
		sha	nlnorm,nextval

		moveta	nextval,leftxstep

		movefa	leftz,temp0
		movefa	lefti,temp1
		load	(left),nextval		; nextval = left->z
		addqt	#4,left
		load	(left),temp2		; temp2 = left->i
		addqt	#4,left
		sub	temp0,nextval
		sub	temp1,temp2

		move	nextval,temp0		; temp0 = fractional part of nextval
		sharq	#16,nextval		; make nextval an integer
		mult	numlines,temp0
		imult	numlines,nextval
		shrq	#16,temp0
		add	temp0,nextval		; now nextval is "numlines*nextval" >> 16
		sha	nlnorm,nextval

		move	nextval,leftzstep

		move	temp2,nextval		; nextval = nextleft->i - curleft->i
		move	temp2,temp0		; temp0 = fractional part of nextval
		sharq	#16,nextval		; make nextval an integer
		mult	numlines,temp0
		imult	numlines,nextval
		shrq	#16,temp0
		add	temp0,nextval		; now nextval is "numlines*nextval" >> 16
		sha	nlnorm,nextval

		move	nextval,leftistep


.if TEXTURES
		load	(left),nextval		; nextval = left->u
		addqt	#4,left
		load	(left),temp2		; temp2 = left->v
		subqt	#20,left
		movefa	leftu,temp0
		movefa	leftv,temp1
		sub	temp0,nextval
		sub	temp1,temp2

		move	nextval,temp0		; temp0 = fractional part of nextval
		sharq	#16,nextval		; make nextval an integer
		mult	numlines,temp0
		imult	numlines,nextval
		shrq	#16,temp0
		add	temp0,nextval		; now nextval is "numlines*nextval" >> 16
		sha	nlnorm,nextval

		move	nextval,leftustep

		move	temp2,nextval		; nextval = nextleft->v - curleft->v
		move	temp2,temp0		; temp0 = fractional part of nextval
		sharq	#16,nextval		; make nextval an integer
		mult	numlines,temp0
		imult	numlines,nextval
		shrq	#16,temp0
		add	temp0,nextval		; now nextval is "numlines*nextval" >> 16
		sha	nlnorm,nextval

		move	nextval,leftvstep
.else
		subqt	#16,left
.endif
doneleft:

; TRAPEZOID DRAW GOES HERE

	move	y,temp0			; set temp0 = 16.16 version of y
	move	ly,numlines		; numlines = ly - y
	move	ry,temp1		; temp1 = ry - y
	sub	y,numlines
	sub	y,temp1
	shlq	#16,temp0
	cmp	temp1,numlines		; if (ry - y) < numlines
	moveta	temp0,ay
	jr	MI,.noswitch
	nop
		move	temp1,numlines
.noswitch:

	moveta	numlines,anumlines
;
; switch to bank 0
;
	movei	#G_FLAGS,temp1
	add	numlines,y		; update value of Y
	load	(temp1),temp0		; get G_FLAGS register
	movei	#polyloop,return		; when we return from gourtrap, we should go back to the start of the loop
	bclr	#14,temp0		; set bank flag to 0
	jump	(trapfunc)
	store	temp0,(temp1)		; switch banks during the jump

endloop:

donedraw:

	.equrundef	start
	.equrundef	end
	.equrundef	left
	.equrundef	right
	.equrundef	ly
	.equrundef	ry
	.equrundef	y
	.equrundef	vertsrem
	.equrundef	numlines
	.equrundef	texwidth
	.equrundef	texheight
	.equrundef	nextval
	.equrundef	innerloop
	.equrundef	trapfunc
	.equrundef	gaddr
