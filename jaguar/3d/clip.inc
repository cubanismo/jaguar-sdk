;******************************************************************
; Clipping and perspective transformation module
; The perspective transformation is done after clipping. This is
; so that we can get more accurate results; most variables
; (in particular, Z, but also U,V, and I) do not really interpolate
; linearly in screen space. The errors this causes are very
; noticeable when Z is small, which is guaranteed to happen
; when we are clipping against the front viewing plane.
;******************************************************************

.if (^^defined PROFILING)
	ADDTIME	OUTRLP
.endif

;
; trivial reject test: if andclips != 0, all points are on the "outside" of one of the clipping planes (trivial reject)
;
	movefa	altskip,temp0
	cmpq	#0,andclips
	jump	NE,(temp0)
	nop

	movei	#clip_to_plane,subr
	movei	#_GPUP2,altpgon

;*
; clip to front viewing plane here (*before* the perspective transform!)
;*
thisplane	.equr	r4
	movei	#_GPUscplanes,thisplane		; clip to scplanes[0], i.e. front viewing plane
	shrq	#1,orclips
	jr	CC,.nocliptofront
	nop

	move	PC,return
	jump	CS,(subr)			; if bit 0 of orclips was 1, call clip_to_plane
	addqt	#6,return
	moveq	#15,orclips			; set all remaining planes to require clipping

.nocliptofront:

;*
; clip to remaining (screen) planes here
;*


	movei	#_GPUscplanes+16,thisplane		; clip to remaining planes
.cloop:
	cmpq	#0,orclips				; all done clipping?
	jr	EQ,.nomoreclips
	shrq	#1,orclips
	jr	CC,.dontclip
	nop
		move	PC,return			; clip to this plane
		jump	(subr)				; (subr still contains clip_to_plane)
		addqt	#6,return
.dontclip:
		addqt	#16,thisplane			; move to next plane
		jr	.cloop
		nop
.nomoreclips:

.if (^^defined PROFILING)
	ADDTIME	CLIPPING
.endif

;*
; perspective transform
;*
pt		.equr	r4,1
vertsrem	.equr	r5,1
xcenter		.equr	r6,1
ycenter		.equr	r7,1
xscale		.equr	r8,1
yscale		.equr	r9,1
zfrac		.equr	r10,1
znorm		.equr	r11,1
persploop	.equr	r12,1
X		.equr	r13,1
Y		.equr	r14,1
Z		.equr	r15,1

;
; if we clipped the polygon away completely, then give up
;

	move	pgon,pt
	addqt	#4,pt
	load	(pgon),vertsrem	; get number of points in polygon
	movefa	altskip,temp1
	cmpq	#3,vertsrem	; fewer than 3 points left?
	jump	MI,(temp1)
	subqt	#1,vertsrem	; prepare for dbra loop

;
; load the camera parameters
;
	load	(cam),xscale	; load scale for camera
	addqt	#4,cam
	load	(cam),yscale
	addqt	#4,cam
	load	(cam),xcenter	; load center for camera
	addqt	#4,cam
	load	(cam),ycenter
	move	PC,persploop	; set persploop to .loop
	subqt	#12,cam
	addqt	#6,persploop
.loop:
	load	(pt),X
	addqt	#4,pt
	load	(pt),Y
	addqt	#4,pt		; move to Z
	moveq	#1,zfrac
	load	(pt),Z		; 
	shlq	#30,zfrac
	subqt	#8,pt		; back to beginning of point
	div	Z,zfrac		; we may assume Z > 0, since we've clipped already

	move	X,temp1		; normalize X and Y
	move	Y,temp2
	abs	temp1		; temp1 = normi(X)
	abs	temp2		; temp2 = normi(Y)
	normi	temp1,temp1
	normi	temp2,temp2
	addqt	#9,temp1
	addqt	#9,temp2
	sha	temp1,X
	sha	temp2,Y
	normi	zfrac,znorm
	addqt	#9,znorm
	sha	znorm,zfrac
	add	znorm,temp1
	add	znorm,temp2
	neg	temp1
	neg	temp2
	addqt	#((30-15)),temp1		; we'll pre-shift the result by 15 in order to multiply by cam->xscale
	addqt	#((30-15)),temp2		; and cam->yscale
	imult	zfrac,X
	imult	zfrac,Y
	sharq	#15,X
	sharq	#15,Y
	imult	xscale,X		; scale for this camera
	imult	yscale,Y
	sha	temp1,X			; re-normalize the values
	sha	temp2,Y
	add	xcenter,X
	add	ycenter,Y
	store	X,(pt)			; save X, Y
	addqt	#4,pt
	store	Y,(pt)
.if PERSP_SHIFT > 0
	shlq	#PERSP_SHIFT,Z
.endif
	addqt	#4,pt
	store	Z,(pt)
	subq	#1,vertsrem		; interleaved
	addqt	#16,pt			; move to next point
	jump	PL,(persploop)
	nop

;*
; end of perspective transform
;*

	.equrundef	pt
	.equrundef	vertsrem
	.equrundef	xcenter
	.equrundef	ycenter
	.equrundef	xscale
	.equrundef	yscale
	.equrundef	zfrac
	.equrundef	znorm
	.equrundef	persploop
	.equrundef	X
	.equrundef	Y
	.equrundef	Z

.if (^^defined PROFILING)
	ADDTIME	PERSPECTIVE
.endif
