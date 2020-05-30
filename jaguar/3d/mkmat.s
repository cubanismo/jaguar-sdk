; mkmat.s - computes a rotation matrix
;	input:	4(sp) a pointer to a matrix
;		8(sp) a pointer to a structure, containing:
;			int alpha, beta, gamma, xpos, ypos, zpos
;
;	output:
;		a 4x3 matrix is placed into matrix
;
;	/* init matrix */
;	xrite =	matrix[0] = cos(gamma) * cos(beta) + sin(gamma) * sin(beta) * sin(alpha);
;	yrite = matrix[1] = sin(gamma) * cos(alpha);
;	zrite = matrix[2] = sin(gamma) * sin(alpha) * cos(beta) - cos(gamma) * sin(beta);

;	xdown = matrix[3] = cos(gamma) * sin(alpha) * sin(beta) - sin(gamma) * cos(beta);
;	ydown = matrix[4] = cos(gamma) * cos(alpha);
;	zdown = matrix[5] = cos(gamma) * sin(alpha) * cos(beta) + sin(gamma) * sin(beta);

;	xhead = matrix[6] = sin(beta) * cos(alpha);
;	yhead = matrix[7] = -sin(alpha);
;	zhead = matrix[8] = cos(beta) * cos(alpha);

	.globl	_mkMatrix

	.extern	_sin
	.extern	_cos
	.extern sin
	.extern cos

alpha	equ	0
beta	equ	2
gamma	equ	4

xpos	equ	6
ypos	equ	8
zpos	equ	10

	.text

; register usage:
; d3 = sin(alpha)
; d4 = sin(beta)
; d5 = sin(gamma)
; d6 = cos(alpha)
; d7 = cos(beta)
; a1 = ptr to matrix
; a2 = ptr to angle structure
; a5 = cos(gamma)

_mkMatrix:
	move.l	4(sp),a1			; get pointer to matrix
	move.l	8(sp),a0
	movem.l	d2-d7/a2-a6,-(sp)
	move.l	a0,a2

	; fill current trig vals
	move.w	alpha(a2), d0
	jsr		sin
	move.w	d0, d3

	move.w	beta(a2), d0
	jsr		sin
	move.w	d0, d4

	move.w	gamma(a2), d0
	jsr		sin
	move.w	d0, d5

	move.w	alpha(a2), d0
	jsr		cos
	move.w	d0, d6

	move.w	beta(a2), d0
	jsr		cos
	move.w	d0, d7

	move.w	gamma(a2), d0
	jsr		cos
	move.w	d0, a5

	moveq	#14, d2
; fill the array
	;matrix[0] = cos(gamma) * cos(beta) + sin(gamma) * sin(beta) * sin(alpha);
	muls		d7, d0
	move.w	d5, d1
	muls		d4, d1
	moveq	#14, d2
	asr.l	d2, d1
	muls		d3, d1
	add.l    	d1, d0
	moveq	#14, d2
	asr.l	d2, d0
	move.w	d0, (a1)

	;matrix[1] = sin(gamma) * cos(alpha);
	move.w	d5, d0
	muls		d6, d0
	moveq	#14, d2
	asr.l	d2, d0
	move.w	d0, 2(a1)

	;matrix[2] = sin(gamma) * sin(alpha) * cos(beta) - cos(gamma) * sin(beta);
	move.w	d5, d0
	muls		d3, d0
	moveq	#14, d2
	asr.l	d2, d0
	muls		d7, d0
	move.w	a5, d1
	muls		d4, d1
	sub.l	d1, d0
	moveq	#14, d2
	asr.l	d2, d0
	move.w	d0, 4(a1)

	;matrix[3] = cos(gamma) * sin(alpha) * sin(beta) - sin(gamma) * cos(beta);
	move.w	a5, d0
	muls		d3, d0
	moveq	#14, d2
	asr.l	d2, d0
	muls		d4, d0
	move.w	d5, d1
	muls		d7, d1
	sub.l	d1, d0
	moveq	#14, d2
	asr.l	d2, d0
	move.w	d0, 6(a1)

	;matrix[4] = cos(gamma) * cos(alpha);
	move.w	a5, d0
	muls		d6, d0
	moveq	#14, d2
	asr.l	d2, d0
	move.w	d0, 8(a1)

	;matrix[5] = cos(gamma) * sin(alpha) * cos(beta) + sin(gamma) * sin(beta);
	move.w	a5, d0
	muls		d3, d0
	moveq	#14, d2
	asr.l	d2, d0
	muls		d7, d0
	move.w	d5, d1
	muls		d4, d1
	add.l	d1, d0
	moveq	#14, d2
	asr.l	d2, d0
	move.w	d0, 10(a1)

	;matrix[6] = sin(beta) * cos(alpha);
	move.w	d4, d0
	muls		d6, d0
	moveq	#14, d2
	asr.l	d2, d0
	move.w	d0, 12(a1)

	;matrix[7] = -sin(alpha);
	move.w	d3, d0
	neg.w	d0
	move.w	d0, 14(a1)

	;matrix[8] = cos(beta) * cos(alpha);
	move.w	d7, d0
	muls		d6, d0
	moveq	#14, d2
	asr.l	d2, d0
	move.w	d0, 16(a1)

	; now update the positions
	; matrix[9] = xposn
	; matrix[10] = yposn
	; matrix[11] = zposn

	move.w	xpos(a2),18(a1)
	move.w	ypos(a2),20(a1)
	move.w	zpos(a2),22(a1)

	movem.l	(sp)+,d2-d7/a2-a6
	rts
