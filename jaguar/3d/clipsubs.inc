;
; clip_to_plane:
; this subroutine clips the input polygon (pgon) to a
; specified plane (thisplane), producing an output
; polygon (altpgon)
;
; Assumptions:
; thisplane, pgon, and altpgon are set up
;

;thisplane	.equr	r4,1		; points to plane to clip to
A		.equr	r5,1		; points to first point of an edge
B		.equr	r6,1		; points to second point of an edge
OUT		.equr	r7,1		; points to output polygon
distA		.equr	r8,1		; distance from A to plane
distB		.equr	r9,1		; distance from B to plane
frac		.equr	r10,1		; fraction of distance
norm		.equr	r11,1		; normalizer for points
outrloop	.equr	r12,1		; outer loop address
cereturn	.equr	r13,1		; return address for "cutedge" subroutine
countr		.equr	r14,1		; counter for cutedge
braddr		.equr	r15,1		; loop address for cutedge

planex		.equr	r16,1		; equation of plane (planex*x+planey*y+planez*z+planed = 0)
planey		.equr	r17,1
planez		.equr	r18,1
planed		.equr	r19,1

numpoints	.equr	r20,1		; number of points written to the output polygon so far
vertsrem	.equr	r21,1		; number of vertices left in input

brfpoint	.equr	r22,1		; address of "fracpoint" subroutine

;
; sub-subroutine: produce an output point from an edge that crosses a
; clipping plane
;
; Inputs:
;	OUT	points to where to put the edge-plane intersection
;	A	points to the point on the negative side of the plane
;	distA	distance from point A to the plane (this is negative)
;	B	points to the point on the positive side of the plane
;	distB	distance from point B to the plane (positive or 0; if 0, do nothing)
;	cereturn is the place to return to
;
; trashes: ptrA, ptrB, frac, temp0, temp1, temp2, countr
;
	.globl	cutedge
cutedge:
	cmpq	#0,distB		; if distB <= 0, do nothing
	jump	MI,(cereturn)
	nop
	jump	EQ,(cereturn)
	cmpq	#0,distA		; branch optimization
	jump	PL,(cereturn)		; if distA >= 0, do nothing
	move	distB,temp0		; branch optimization
	move	distB,frac
	sub	distA,temp0		; temp0 = distB - distA
	div	temp0,frac		; frac = distA/(distB+distA)
	moveq	#5,countr		; 6 numbers to calculate
	move	PC,brfpoint		; get the address of "fracpoint" into brfpoint
	shrq	#1,frac			; make "frac" a 15 bit signed fraction
	addqt	#6,brfpoint
;
; Writes the number which is "frac" fraction along the line from B to A
; int OUT (i.e. *OUT = *ptrB + frac*(*ptrA-*ptrB);
; Advances ptrA, ptrB, and OUT to the next numbers
;
; All numbers are assumed to be 32 bits, except for "frac", which is a 15 bit
; unsigned fraction
;
fracpoint:
	load	(A),temp0
	load	(B),temp1
	addqt	#4,A
	addqt	#4,B
	move	temp0,temp2
	sub	temp1,temp0		; temp0 contains the difference A-B (integer part)
	sub	temp1,temp2		; temp2 contains the difference A-B (fractional part)
	sharq	#16,temp0		; put integer part in temp0
	mult	frac,temp2		; multiply both integer and fractional parts
	imult	frac,temp0
	shrq	#15,temp2		; the fractional part needs to be divided by 15 bits
	shlq	#1,temp0		; adjust integer part (because fraction was only 15 bits)
	add	temp2,temp1
	add	temp0,temp1
	store	temp1,(OUT)
	addqt	#4,OUT

	subq	#1,countr
	jump	PL,(brfpoint)
	nop

	subqt	#24,A			; restore A and B
	subqt	#24,B

	jump	(cereturn)
	addqt	#1,numpoints		; increment number of points written to output polygon

;
;
;
clip_to_plane:
;
; load plane equation
;
	load	(thisplane),planex
	addqt	#4,thisplane
	load	(thisplane),planey
	addqt	#4,thisplane
	load	(thisplane),planez
	addqt	#4,thisplane
	load	(thisplane),planed
	subqt	#12,thisplane			; restore "thisplane" to original value

	moveq	#SIZEOF_XPOINT,A
	move	pgon,B				; B = &pgon->pt[0]
	load	(pgon),vertsrem			; get number of vertices in polygon
	addqt	#4,B
	mult	vertsrem,A
	add	B,A
	subqt	#SIZEOF_XPOINT,A		; A = &pgon->pt[vertsrem-1]
	move	altpgon,OUT
	addqt	#4,OUT				; OUT = &altpgon->pt[0]

	moveq	#0,numpoints
;
; initialize point A
;
	
	load	(A),temp0		; temp0 = A->x
	addqt	#4,A
	load	(A),temp1		; temp1 = A->y
	addqt	#4,A
	load	(A),temp2		; temp2 = A->z
	subqt	#8,A
;
; normalize x,y,z to 16 bits
;
	move	temp2,norm
	moveta	temp0,atemp0
	moveta	temp1,atemp1
	abs	norm
	abs	temp0
	abs	temp1
	or	temp0,norm
	or	temp1,norm
	movefa	atemp0,temp0
	movefa	atemp1,temp1
	normi	norm,norm
	addqt	#9,norm

	sha	norm,temp0		; x,y,z were 14.16 numbers, make them fit in 16 bits
	sha	norm,temp1
	sha	norm,temp2

	imultn	temp0,planex		; calculate distance from point A to plane
	imacn	temp1,planey
	imacn	temp2,planez
	resmac	distA
	neg	norm
	sha	norm,distA
	add	planed,distA

	movei	#.entercutloop,temp0
	movei	#cutedge,braddr

	move	PC,outrloop
	jump	(temp0)			; jump to .entercutloop
	addqt	#6,outrloop		; set outrloop to .cutloop

.cutloop:
	load	(B),temp0
	addqt	#4,B
	load	(B),temp1
	addqt	#4,B
	load	(B),temp2
	subqt	#8,B

;
; normalize x,y,z to 16 bits
;
	move	temp2,norm
	moveta	temp0,atemp0
	moveta	temp1,atemp1
	abs	norm
	abs	temp0
	abs	temp1
	or	temp0,norm
	or	temp1,norm
	movefa	atemp0,temp0
	movefa	atemp1,temp1
	normi	norm,norm
	addqt	#9,norm

	sha	norm,temp0		; x,y,z were 14.16 numbers, make them fit in 16 bits
	sha	norm,temp1
	sha	norm,temp2

	imultn	temp0,planex		; calculate distance from point B to plane
	imacn	temp1,planey
	imacn	temp2,planez
	resmac	distB
	neg	norm
	sha	norm,distB
	add	planed,distB

	movei	#.entercutloop,temp0
	cmpq	#0,distA
	jr	PL,.distAplus
	nop					; if A is on the negative side
		movei	#.donewithA,cereturn	; try cutting B
		jump	(braddr)		; call cutedge
		nop				; (the call will return to .donewithA)
.distAplus:
	; copy point A to OUT
	load	(A),temp0
	addqt	#4,A
	load	(A),temp1
	addqt	#4,A
	load	(A),temp2
	addqt	#4,A
	store	temp0,(OUT)
	addqt	#4,OUT
	store	temp1,(OUT)
	addqt	#4,OUT
	store	temp2,(OUT)
	addqt	#4,OUT
	load	(A),temp0
	addqt	#4,A
	load	(A),temp1
	addqt	#4,A
	load	(A),temp2
	subqt	#20,A
	store	temp0,(OUT)
	addqt	#4,OUT
	store	temp1,(OUT)
	addqt	#4,OUT
	store	temp2,(OUT)
	addqt	#4,OUT
	addqt	#1,numpoints

	cmpq	#0,distB			; if distB < 0
	jr	PL,.donewithA
	nop					;   then
		move	B,temp0			; swap A and B
		move	A,B
		move	temp0,A
		move	distA,temp0		; exchange distB and distA
		move	distB,distA
		move	temp0,distB
		move	PC,cereturn
		jump	(braddr)		; call cutedge
		addqt	#6,cereturn		
		move	A,B			; restore B
		jr	.donewithB		; we already moved distB to distA, and B to A, so skip those instructions
		nop
.donewithA:
	move	distB,distA
	move	B,A
.donewithB:
	addqt	#SIZEOF_XPOINT,B

.entercutloop:
	subq	#1,vertsrem
	jump	PL,(outrloop)
	nop

	store	numpoints,(altpgon)		; store number of points in polygon
	move	altpgon,temp0			; swap pgon and altpgon
	move	pgon,altpgon
	jump	(return)			; return to caller
	move	temp0,pgon

.equrundef	A
.equrundef	B
.equrundef	OUT
.equrundef	distA
.equrundef	distB
.equrundef	frac
.equrundef	outrloop
.equrundef	cereturn
.equrundef	countr
.equrundef	braddr
.equrundef	planex
.equrundef	planey
.equrundef	planez
.equrundef	planed
.equrundef	numpoints
.equrundef	vertsrem
.equrundef	brfpoint
.equrundef	half
