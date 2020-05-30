;
; draw a triangle
;
; input:
; 	the global registers "start", "left", and "right"
; point to 3 points of the triangle
; 	the global registers "polyfunc" and "trapfunc" point
; to the functions to call per-triangle and per-trapezoid.

; fudge factor for rightxstep
FUDGE	=	7

Ax		.equr	r4,1
Ay		.equr	r5,1
Az		.equr	r6,1
Ai		.equr	r7,1
Au		.equr	r8,1
Av		.equr	r9,1

Bx		.equr	r10,1
By		.equr	r11,1
Bz		.equr	r12,1
Bi		.equr	r13,1
Bu		.equr	r14,1
Bv		.equr	r15,1

Cx		.equr	r16,1
Cy		.equr	r17,1
Cz		.equr	r18,1
Ci		.equr	r19,1
Cu		.equr	r20,1
Cv		.equr	r21,1

gaddr		.equr	r22,1		; G_FLAGS register

Aptr		.equr	Av
Bptr		.equr	Bv
Cptr		.equr	Cv

	.globl	dotri
dotri:
	move	start,Aptr
	move	right,Bptr
	addqt	#4,Aptr			; point at Y component of structure
	addqt	#4,Bptr			; ditto
	load	(Aptr),Ay
	load	(Bptr),By
	subqt	#4,Aptr
	subqt	#4,Bptr
	move	left,Cptr
	addqt	#4,Cptr			; and another Y component
	load	(Cptr),Cy
	subqt	#4,Cptr

	; strip low bits from the Y values
	shrq	#16,Ay
	shrq	#16,By
	shlq	#16,Ay
	shlq	#16,By
	shrq	#16,Cy
	shlq	#16,Cy

	; rename A,B,C so that A is at the top
	; this needs to happen only if (Ay > By) || (Ay >= Cy)
	;  i.e. if Ay-By <=0 and Ay-Cy < 0 we can skip it

	move	Ay,temp0
	move	Ay,temp1
	sub	By,temp0
	sub	Cy,temp1
	subq	#1,temp0
	and	temp1,temp0	; see if both temp0 and temp1 have negative bits set
	movei	#.donerot,temp2
	jump	MI,(temp2)
	nop

	move	Aptr,temp0		; **branch optimization
	move	Ay,temp1

	; if (By > Cy) rotate counter clockwise
	; i.e. if (Cy - By) >= 0 skip this
	cmp	By,Cy
	jr	PL,.clockwise
	nop
		move	Cptr,Aptr
		move	Cy,Ay
		move	Bptr,Cptr
		move	By,Cy
		move	temp0,Bptr
		jr	.donerot
		move	temp1,By
.clockwise:
	move	Bptr,Aptr
	move	By,Ay
	move	Cptr,Bptr
	move	Cy,By
	move	temp0,Cptr
	move	temp1,Cy
.donerot:

	; now load up the points
	load	(Aptr),Ax
	load	(Bptr),Bx
	addqt	#8,Aptr			; skip y, we already have it
	addqt	#8,Bptr
	load	(Aptr),Az
	load	(Bptr),Bz
	addqt	#4,Aptr
	addqt	#4,Bptr
	load	(Aptr),Ai
	load	(Bptr),Bi
.if TEXTURES
	addqt	#4,Aptr
	addqt	#4,Bptr
	load	(Aptr),Au
	load	(Bptr),Bu
	addqt	#4,Aptr
	addqt	#4,Bptr
	load	(Aptr),Av		; these instructions trash Aptr and Bptr!
	load	(Bptr),Bv
.endif

	load	(Cptr),Cx
	addqt	#8,Cptr			; skip y, we already have it
	load	(Cptr),Cz
	addqt	#4,Cptr
	load	(Cptr),Ci
.if TEXTURES
	addqt	#4,Cptr
	load	(Cptr),Cu
	addqt	#4,Cptr
	load	(Cptr),Cv		; this instruction trashes Cptr
.endif

	moveta	Ax,leftx
	moveta	Ay,ay
	moveta	Ax,rightx
	moveta	Az,leftz
	moveta	Ai,lefti
.if TEXTURES
	moveta	Au,leftu
	moveta	Av,leftv
.endif
;
; Calculate various increments
;
i1	.equr	Ax
i2	.equr	Ay
y1	.equr	Az
y2	.equr	Ai
xinc	.equr	Au
xnorm	.equr	Av

;	y2 = (pgon->pt[i+2].y - pgon->pt[0].y);
;	y1 = -(pgon->pt[i+1].y - pgon->pt[0].y);
;	ynorm = inormi2(y1, y2);
;	y1 = y1 >> ynorm;
;	y2 = y2 >> ynorm;

	movefa	ay,y1
	movefa	ay,y2
	sub	By,y1
	sub	Cy,y2
	neg	y1
	move	y2,temp2
	move	y1,temp1
	abs	temp2
	abs	temp1
	or	temp2,temp1
	normi	temp1,temp1
	addqt	#10,temp1		; find normalizer to 14 bits
	sha	temp1,y1
	sha	temp1,y2

;	i2 = (pgon->pt[i+2].x - pgon->pt[0].x);
;	i1 = (pgon->pt[i+1].x - pgon->pt[0].x);
;	xnorm = inormi2(i1, i2);
;	i1 = i1 >> xnorm;
;	i2 = i2 >> xnorm;
;	xinc = (i1*y2 + i2*y1);

	movefa	leftx,i1
	movefa	leftx,i2
	sub	Bx,i1
	sub	Cx,i2
	move	i1,temp1
	move	i2,temp2
	abs	temp1
	abs	temp2
	or	temp2,temp1
	normi	temp1,xnorm
	addqt	#10,xnorm		; find normalizer to 14 bits
	sha	xnorm,i1
	sha	xnorm,i2
	imultn	i1,y2
	imacn	i2,y1
	resmac	temp1

	moveq	#1,xinc
.if 0
;
; do backface culling: if temp1 <= 0, the polygon is facing away from us
;
	cmpq	#1,temp1
	movei	#donedraw,temp0
	jump	MI,(temp0)
.endif
	shlq	#28,xinc

;
; set xinc to 1/xinc, so we can multiply by it
;
	div	temp1,xinc

calczinc:
;
; calculate Z increment
;
	movefa	leftz,i1
	movefa	leftz,i2
	sub	Bz,i1
	sub	Cz,i2
	move	i1,temp1
	move	i2,temp2
	abs	temp1
	abs	temp2
	or	temp2,temp1
	normi	temp1,temp1
	addqt	#10,temp1		; find normalizer to 14 bits
	sha	temp1,i1
	sha	temp1,i2
	imultn	i1,y2
	imacn	i2,y1
	resmac	temp0

;
; normalize 1/xinc (actually, we have 1/(xinc >> xnorm) = (1/xinc) << xnorm
;

	normi	xinc,temp2
	addqt	#10,temp2
	sha	temp2,xinc		; xinc is now a 14 bit fraction
	sub	temp2,xnorm
	addqt	#14,xnorm
;
; now find temp0 * 1/xinc
	neg	temp1
	sharq	#14,temp0
	add	xnorm,temp1
	imult	xinc,temp0
	sha	temp1,temp0

	moveta	temp0,b_zinc

calciinc:
;
; calculate I increment
;
	movefa	lefti,i1
	movefa	lefti,i2
	sub	Bi,i1
	sub	Ci,i2
	move	i1,temp1
	move	i2,temp2
	abs	temp1
	abs	temp2
	or	temp2,temp1
	normi	temp1,temp1
	addqt	#10,temp1		; find normalizer to 14 bits
	sha	temp1,i1
	sha	temp1,i2
	imultn	i1,y2
	imacn	i2,y1
	resmac	temp0

;
; now find temp0 * 1/xinc
	neg	temp1
	sharq	#14,temp0
	add	xnorm,temp1
	imult	xinc,temp0
	sha	temp1,temp0
	moveta	temp0,b_iinc

.if TEXTURES
calcuinc:
;
; calculate U increment
;
	movefa	leftu,i1
	movefa	leftu,i2
	sub	Bu,i1
	sub	Cu,i2
	move	i1,temp1
	move	i2,temp2
	abs	temp1
	abs	temp2
	or	temp2,temp1
	normi	temp1,temp1
	addqt	#10,temp1		; find normalizer to 14 bits
	sha	temp1,i1
	sha	temp1,i2
	imultn	i1,y2
	imacn	i2,y1
	resmac	temp0

;
; now find temp0 * 1/xinc
	neg	temp1
	sharq	#14,temp0
	add	xnorm,temp1
	imult	xinc,temp0
	sha	temp1,temp0

	moveta	temp0,b_uinc

calcvinc:
;
; calculate V increment
;
	movefa	leftv,i1
	movefa	leftv,i2
	sub	Bv,i1
	sub	Cv,i2
	move	i1,temp1
	move	i2,temp2
	abs	temp1
	abs	temp2
	or	temp2,temp1
	normi	temp1,temp1
	addqt	#10,temp1		; find normalizer to 14 bits
	sha	temp1,i1
	sha	temp1,i2
	imultn	i1,y2
	imacn	i2,y1
	resmac	temp0

;
; now find temp0 * 1/xinc
	neg	temp1
	sharq	#14,temp0
	add	xnorm,temp1
	imult	xinc,temp0
	sha	temp1,temp0

	moveta	temp0,b_vinc
.endif ; TEXTURES


;
; Call the per-polygon setup function
;
	move	PC,return
	jump	(polyfunc)
	addqt	#6,return

;
; Calculate right side step values
;
	movefa	ay,temp0
	move	By,temp1
	sharq	#16,temp0
	sharq	#16,temp1
	sub	temp0,temp1		; temp1 = # of lines
	move	Bx,temp2
	movefa	rightx,temp0
	shlq	#16,temp1
	sub	temp0,temp2
	abs	temp2
	jr	CC,.posright
	div	temp1,temp2
	; precalculate some stuff for the left side while we're waiting for the divide
		movefa	ay,temp0
		move	Cy,temp1
		sharq	#16,temp0
		sharq	#16,temp1
		moveq	#0,xinc
		sub	temp0,temp1		; temp1 = # of lines
		bset	#(24-16),xinc		; set xinc to (1 << 24-16)
		jr	.setrightxstep
		neg	temp2
.posright:

;
; Calculate left side step values
;
	movefa	ay,temp0
	move	Cy,temp1
	sharq	#16,temp0
	sharq	#16,temp1
	moveq	#0,xinc
	sub	temp0,temp1		; temp1 = # of lines
	bset	#(24-16),xinc		; set xinc to (1 << 24-16)

.setrightxstep:
	addqt	#FUDGE,temp2		; add a fudge factor to compensate for numerical inaccuracies
	moveta	temp2,rightxstep

;
; divides are expensive, so instead of dividing to find the various step values, we multiply
; by 1/numlines, which is stored as a 15 bit fraction in "xinc" with an exponent in 
; "xnorm"
;
	div	temp1,xinc
	movei	#G_FLAGS,gaddr			; put this instruction here so it executes during the divide

	move	Cx,temp2
	movefa	leftx,temp1
	sub	temp1,temp2
	move	temp2,temp0			; temp0 = fractional part of Cx-Ax

	normi	xinc,xnorm		; normalize xinc
	sharq	#16,temp2			; temp2 = integer part of Cx-Ax
	addqt	#9,xnorm		; make it a 15 bit fraction instead of 24 bit
	sha	xnorm,xinc
	mult	xinc,temp0
	neg	xnorm			; now xnorm is an adjustment for multiplies
	imult	xinc,temp2
	addqt	#(24-16),xnorm		; xinc is a 24 bit fraction, but we will preshift the value we're multiplying
					; by 16

	shrq	#16,temp0
	add	temp0,temp2		; now temp2 is (Cx-Ax)/numlines >> 16
	sha	xnorm,temp2
	moveta	temp2,leftxstep

	move	Cz,temp2
	movefa	leftz,temp1
	sub	temp1,temp2
	move	temp2,temp0		; temp0 = fractional part of Cz-Az
	sharq	#16,temp2		; temp2 = integer part of Cz-Az
	mult	xinc,temp0
	imult	xinc,temp2
	shrq	#16,temp0
	add	temp0,temp2		; now temp2 is (Cz-Az)/numlines >> 16
	sha	xnorm,temp2
	moveta	temp2,leftzstep

	move	Ci,temp2
	movefa	lefti,temp1
	sub	temp1,temp2
	move	temp2,temp0		; temp0 = fractional part of Ci-Ai
	sharq	#16,temp2		; temp2 = integer part of Ci-Ai
	mult	xinc,temp0
	imult	xinc,temp2
	shrq	#16,temp0
	add	temp0,temp2		; now temp2 is (Ci-Ai)/numlines >> 16
	sha	xnorm,temp2
	moveta	temp2,leftistep

.if TEXTURES
	move	Cu,temp2
	movefa	leftu,temp1
	sub	temp1,temp2
	move	temp2,temp0		; temp0 = fractional part of Cu-Au
	sharq	#16,temp2		; temp2 = integer part of Cu-Au
	mult	xinc,temp0
	imult	xinc,temp2
	shrq	#16,temp0
	add	temp0,temp2		; now temp2 is (Cu-Au)/numlines >> 16
	sha	xnorm,temp2
	moveta	temp2,leftustep

	move	Cv,temp2
	movefa	leftv,temp1
	sub	temp1,temp2
	move	temp2,temp0		; temp0 = fractional part of Cv-Av
	sharq	#16,temp2		; temp2 = integer part of Cv-Av
	mult	xinc,temp0
	imult	xinc,temp2
	shrq	#16,temp0
	add	temp0,temp2		; now temp2 is (Cv-Av)/numlines >> 16
	sha	xnorm,temp2
	moveta	temp2,leftvstep
.endif

	.equrundef	ynorm

;	/* now, at this point there are two possibilities:
;	 * (1)   A		or (2)	A
;	 *	C			 B
;	 *	  B		      C
;	 * For both cases we need to draw 2 trapezoids.
;	 * in case (1) we need to recalculate the left step
;	 * values once, in case (2) the right step values
;	 * once.
;	 */
;
; case 1 holds if By > Cy, i.e. if Cy - By < 0
;

	movei	#tricase2,temp0
	cmp	By,Cy
	jump	PL,(temp0)
	nop

	movefa	ay,temp0			; # of lines to draw is int(Ay-Cy)
	move	Cy,temp1
	shrq	#16,temp0
	shrq	#16,temp1
	sub	temp0,temp1
	jr	EQ,.notrap1
	moveta	temp1,anumlines
		load	(gaddr),temp0
.call1:
		move	PC,return		; draw the trapezoid
		bclr	#14,temp0
		addqt	#(.notrap1-.call1),return
		jump	(trapfunc)
		store	temp0,(gaddr)
.notrap1:
	; recalculate left step values here
	moveta	Cx,leftx
	moveta	Cy,ay
	moveta	Cz,leftz
	moveta	Ci,lefti
.if TEXTURES
	moveta	Cu,leftu
	moveta	Cv,leftv
.endif
	movefa	ay,temp0
	move	By,temp1
	sharq	#16,temp0
	sharq	#16,temp1
	moveq	#0,xinc
	sub	temp0,temp1		; temp1 = # of lines

;
; divides are expensive, so instead of dividing to find the various step values, we multiply
; by 1/numlines, which is stored as a 15 bit fraction in "xinc" with an exponent in 
; "xnorm"
;
	bset	#(24-16),xinc		; set xinc to 1<<(24-16); the -16 is because temp1 is a 0.16 number
	moveta	temp1,anumlines
	div	temp1,xinc
	normi	xinc,xnorm
	addqt	#9,xnorm		; make it a 15 bit fraction instead of 24 bit
	sha	xnorm,xinc
	neg	xnorm			; now xnorm is an adjustment for multiplies
	addqt	#(24-16),xnorm		; xinc is a 24 bit fraction, but we will preshift the value we're multiplying
					; by 16

	move	Bx,temp2
	movefa	leftx,temp1
	sub	temp1,temp2
	move	temp2,temp0		; temp0 = fractional part of Bx-Cx
	sharq	#16,temp2		; temp2 = integer part of Bx-Cx
	mult	xinc,temp0
	imult	xinc,temp2
	shrq	#16,temp0
	add	temp0,temp2		; now temp2 is (Bx-Cx)/numlines >> 16
	sha	xnorm,temp2
	moveta	temp2,leftxstep

	move	Bz,temp2
	movefa	leftz,temp1
	sub	temp1,temp2
	move	temp2,temp0		; temp0 = fractional part of Bz-Cz
	sharq	#16,temp2		; temp2 = integer part of Bz-Cz
	mult	xinc,temp0
	imult	xinc,temp2
	shrq	#16,temp0
	add	temp0,temp2		; now temp2 is (Cz-Az)/numlines >> 16
	sha	xnorm,temp2
	moveta	temp2,leftzstep

	move	Bi,temp2
	movefa	lefti,temp1
	sub	temp1,temp2
	move	temp2,temp0		; temp0 = fractional part of Bi-Ci
	sharq	#16,temp2		; temp2 = integer part of Bi-Ci
	mult	xinc,temp0
	imult	xinc,temp2
	shrq	#16,temp0
	add	temp0,temp2		; now temp2 is (Bi-Ci)/numlines >> 16
	sha	xnorm,temp2
	moveta	temp2,leftistep

.if TEXTURES
	move	Bu,temp2
	movefa	leftu,temp1
	sub	temp1,temp2
	move	temp2,temp0		; temp0 = fractional part of Bu-Cu
	sharq	#16,temp2		; temp2 = integer part of Bu-Cu
	mult	xinc,temp0
	imult	xinc,temp2
	shrq	#16,temp0
	add	temp0,temp2		; now temp2 is (Bu-Cu)/numlines >> 16
	sha	xnorm,temp2
	moveta	temp2,leftustep

	move	Bv,temp2
	movefa	leftv,temp1
	sub	temp1,temp2
	move	temp2,temp0		; temp0 = fractional part of Bv-Cv
	sharq	#16,temp2		; temp2 = integer part of Bv-Cv
	mult	xinc,temp0
	imult	xinc,temp2
	shrq	#16,temp0
	add	temp0,temp2		; now temp2 is (Bv-Cv)/numlines >> 16
	sha	xnorm,temp2
	moveta	temp2,leftvstep
.endif

	; draw the second trapezoid, then go to the end
	load	(gaddr),temp0
	movei	#donetri,return
	bclr	#14,temp0
	jump	(trapfunc)
	store	temp0,(gaddr)		; switch to register bank 0

tricase2:
	movefa	ay,temp0			; # of lines to draw is int(Ay-By)
	move	By,temp1
	shrq	#16,temp0
	shrq	#16,temp1
	sub	temp0,temp1
	jr	EQ,.notrap1
	moveta	temp1,anumlines
		load	(gaddr),temp0
.call2:
		move	PC,return		; draw the trapezoid
		bclr	#14,temp0
		addqt	#(.notrap1-.call2),return
		jump	(trapfunc)
		store	temp0,(gaddr)
.notrap1:
	; recalculate right side step values

	move	By,temp0
	move	Cy,temp1
	sharq	#16,temp0
	sharq	#16,temp1
	sub	temp0,temp1		; temp1 = # of lines = int(Cy)-int(By)
	move	Cx,temp2
	moveta	temp1,anumlines
	move	Bx,temp0
	shlq	#16,temp1
	sub	temp0,temp2
	abs	temp2
	jr	CC,.posright
	div	temp1,temp2
		neg	temp2
.posright:
	addqt	#FUDGE,temp2		; add fudge factor to make up for numerical inaccuracies
	moveta	Bx,rightx
	moveta	temp2,rightxstep

; draw the trapezoid
	load	(gaddr),temp0
.call3:
	move	PC,return		; draw the trapezoid
	bclr	#14,temp0
	addqt	#(donetri-.call3),return
	jump	(trapfunc)
	store	temp0,(gaddr)		; switch banks while the jump is happening
donetri:

	.equrundef	y1
	.equrundef	y2
	.equrundef	i1
	.equrundef	i2
	.equrundef	xnorm
	.equrundef	xinc

	.equrundef	Ax
	.equrundef	Ay
	.equrundef	Az
	.equrundef	Ai
	.equrundef	Au
	.equrundef	Av
	.equrundef	Aptr

	.equrundef	Bx
	.equrundef	By
	.equrundef	Bz
	.equrundef	Bi
	.equrundef	Bu
	.equrundef	Bv
	.equrundef	Bptr

	.equrundef	Cx
	.equrundef	Cy
	.equrundef	Cz
	.equrundef	Ci
	.equrundef	Cu
	.equrundef	Cv
	.equrundef	Cptr

	.equrundef	gaddr
