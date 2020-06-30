;
; Subroutine: load and transform (if necessary) a point
; Parameters:
;	temp2: contains point index (high word) and UV coordinates (low word)
;	altpgon: points at the Xpoint structure to be filled in
;	tri:	points at the point in the triangle to load
;	cam:	points at the camera
;	tpoints: ptr to transformed points array
;	points:	ptr to original points array
;	colori:  triangle color (actually only the intensity, i.e. the low 8 bits)
;	texwidth: texture map width
;	texheight: texture map height
;
; Global variables:
;	GPUM:	transformation matrix
;	GPUcplanes: clipping planes (must follow transformation matrix in memory)
;	GPUTLights: transformed lighting model
;
; Returns:
;	temp0 = clip codes for transformed point

	.extern	_TLights		; lighting model

NUMCLIPPLANES = 5			; number of clipping planes
lightscale = 4				; parameter for tweaking lighting (in-scene lights are darkened by 2^lightscale)

.if 0
tpoints		.equr	r5,1		; transformed points
points		.equr	r6,1		; non-transformed points
lx		.equr	r7,1		; light source
lz		.equr	r8,1
ly		.equr	r9,1
.else
lx		.equr	xcolori
lz		.equr	xtexwidth
ly		.equr	xtexheight
.endif

x		.equr	r10,1		; point
z		.equr	r11,1		; NOTE: z has to follow x because we sometimes pack x,y,z,1 into
y		.equr	r12,1		; the X and Z registers (for mmult instructions)
vx		.equr	r13,1		; vertex normal
vz		.equr	r14,1
vy		.equr	r15,1
basei		.equr	r16,1		; base intensity (ambient light)
clipcodes	.equr	r17,1		; clipping code
bright		.equr	r18,1		; brightness of light source
countr		.equr	r19,1		; counter
uv		.equr	r20,1
lmodel		.equr	r21,1
;;;endloop		.equr	r22,1		; defined in load.inc

_loadxpoint:
	; temp2 has point index (high word) and UV coordinates (low word)
.if TEXTURES
	move	temp2,uv
.endif
	moveq	#12,temp1		; 12 == sizeof(point)
	shrq	#16,temp2
	mult	temp2,temp1		; temp1 = index*12
	shlq	#4,temp2		; temp2 = index*16 (== sizeof(tpoint))
	add	tpoints,temp2		; temp2 points to tpoints array entry
	load	(temp2),basei		; load basei and clip code
	addqt	#4,temp2
	load	(temp2),x		; load transformed x 
	addqt	#4,temp2
	load	(temp2),y		; load transformed y
	addqt	#4,temp2
	load	(temp2),z		; load z; leave temp2 pointing at tpoints+12
	btst	#7,basei		; has this point been transformed yet?
	movei	#setxpoint,temp0
	jump	EQ,(temp0)		; yes -- go set the Xpoint
	nop
;
; save the colori,texwidth,and texheight registers
;
.if (^^defined PROFILING)
	moveta	temp1,atemp1
	moveta	temp2,atemp2
	ADDTIME	DATALD
	movefa	atemp2,temp2
	movefa	atemp1,temp1
.endif

	moveta	xcolori,atemp0
.if TEXTURES
	moveta	xtexwidth,atemp1
	moveta	xtexheight,atemp2
.endif

;
; here we have to transform the point, and do lighting calculations for it
;
	add	points,temp1		; temp1 points to the (object space) coordinates
	load	(temp1),x		; load X and Y
	addqt	#4,temp1
	load	(temp1),z		; load Z and VX
	addqt	#4,temp1
	load	(temp1),vz		; load VY and VZ
	move	x,y
	rorq	#16,x			; get X into low word (keep Y in high word for later use)
	move	z,vx				; vx is already in low word
	shrq	#16,z			; get Z into low word
	move	vz,vy				; Vy is in high word
	bset	#30,z			; set high word of Z to 1
	shrq	#16,vy				; get Vy into low word
;
; walk through the lighting model
;
	movefa	altlmodel,lmodel
	load	(lmodel),countr		; get number of lights (low word) & ambient light (high word)
	addqt	#4,lmodel
	move	countr,basei		; get base intensity
	shlq	#16,countr
	shrq	#16,basei
	shrq	#16,countr
loopbr	.equr	clipcodes			; temporary re-use of register

	move	PC,loopbr
	addqt	#4,loopbr

.lightloop:
	subq	#1,countr		; any more lights left?
	jump	MI,(endloop)		; no == leave the loop
	nop
		load	(lmodel),lx	; load up the next light (x in high word, y in low)
		addqt	#4,lmodel
		load	(lmodel),lz	; z in high word, bright in low
		addqt	#4,lmodel
		move	lx,ly
		move	lz,bright
		shrq	#16,lx
		shrq	#16,lz
		shlq	#16,bright
		shlq	#16,ly
		shrq	#16,bright
		shrq	#16,ly
		btst	#15,bright	; if bit 15 of "bright" is set, this is an in-scene light
		jr	NE,.notsun
		bclr	#15,bright

		; sunlight: just find the dot product of the light vector and vertex normal
		imultn	vx,lx
		imacn	vy,ly
		imacn	vz,lz
		resmac	temp1
		sharq	#14,temp1	; re-normalize after multiplying 
		sat16	temp1		; if negative, make it 0
		mult	bright,temp1	; adjust by brightness factor
		shrq	#12,temp1	; adjust sunlight product (12 is arbitrary, but looks good)
		jump	(loopbr)
		add	temp1,basei
.notsun:
		; an in-scene light
		sub	x,lx		; make a vector from the light's location to the point's location
		sub	y,ly
		sub	z,lz
		imultn	lx,lx		; find the magnitude of that vector
		imacn	ly,ly
		imacn	lz,lz
		resmac	temp0		; temp0 = distance from point to light (squared)
		imultn	vx,lx		; calculate angle between light vector and vertex normal
		imacn	vy,ly
		imacn	vz,lz
		resmac	temp1
		sharq	#6,temp1	; re-normalize ("6" is arbitrary, but looks good)
		jump	MI,(loopbr)	; to lighting
		nop
			div	temp0,temp1		; divide by distance (squared)
			sat16	temp1
			mult	bright,temp1		; adjust by brightness
			shrq	#13,temp1
			jump	(loopbr)
			add	temp1,basei
endlightloop:
	.equrundef	loopbr

	; saturate base intensity to $ffff
	sat16	basei

	; OK, lighting is done
	; now transform the point; put X into vx, y into vx, z into vz
	movei	#_GPUM,temp0
	movefa	altgmtxa,temp1
	store	temp0,(temp1)		; set the GPU matrix address to _GPUM
	nop				; WARNING: we need at least 1 instruction between any store and mmult instruction; if any other
	nop				; processor (e.g. the blitter) is accessing GPU RAM, we need 2 instructions
	mmult	x,vx
	nop
	nop
	mmult	x,vy
	nop
	nop
	mmult	x,vz

	shlq	#2,vx			; convert X from 14.14 to 14.16
	shlq	#2,vy			; convert Y from 14.14 to 14.16
	move	vz,clipcodes
	shlq	#2,vz			; convert Z from 14.14 to 14.16

	sharq	#14,clipcodes		; convert clipcodes to Z as an integer
.if PERSP_SHIFT > 0
	sharq	#PERSP_SHIFT,vz		; adjust for perspective shift effect on clipping
					; (X and Y will be shifted left by PERSP_SHIFT before plotting)
.endif
	subqt	#MINZ,clipcodes
	shrq	#31,clipcodes		; bit 0 of clipcodes is 1 if vz < MINZ
	move	vz,temp0
	move	vz,temp1
	add	vx,temp0
	sub	vx,temp1
	shrq	#31,temp0		; bit 0 of temp0 is 1 if vz+vx < 0, i.e. vx > -vz
	shrq	#31,temp1		; bit 0 of temp1 is 1 if vz-vx < 0, i.e. vx < vz
	shlq	#1,temp0
	shlq	#2,temp1
	or	temp0,clipcodes
	or	temp1,clipcodes

	move	vz,temp0
	move	vz,temp1
	add	vy,temp0
	sub	vy,temp1
	shrq	#31,temp0		; bit 0 of temp0 is 1 if vz+vy < 0, i.e. vy > -vz
	shrq	#31,temp1		; bit 0 of temp1 is 1 if vz-vy < 0, i.e. vy > vz
	shlq	#3,temp0
	shlq	#4,temp1
	or	temp0,clipcodes
	shlq	#8,basei		; make room for clipcodes
	or	temp1,clipcodes
	subqt	#12,temp2		; temp2 still points at the end of the tpoints entry; make it point at the beginning
	or	clipcodes,basei
	; save the transformed point to the tpoints array
	; the format is X Y Z I|clipcodes, where X,Y,Z are 32 bits, I is 16 bits, and clipcodes are 8 bit
	; temp2 still points just past the appropriate entry
	store	basei,(temp2)		; store intensity and clip codes
	addqt	#4,temp2
	store	vx,(temp2)		; store X back into tpoints array (DRAM)
	addqt	#4,temp2
	store	vy,(temp2)		; store Y
	addqt	#4,temp2
	store	vz,(temp2)		; store Z
	move	vx,x
	move	vy,y
	move	vz,z
;
; restore colori, texwidth, and texheight
;
	movefa	atemp0,xcolori
.if TEXTURES
	movefa	atemp1,xtexwidth
	movefa	atemp2,xtexheight
.endif

.if (^^defined PROFILING)
	moveta	temp1,atemp1
	moveta	temp2,atemp2
	ADDTIME	TRANSFORM
	movefa	atemp2,temp2
	movefa	atemp1,temp1
.endif

setxpoint:
	store	x,(altpgon)		; store X to local (SRAM) copy of polygon
	addqt	#4,altpgon
	store	y,(altpgon)		; store Y
	addqt	#4,altpgon
	store	z,(altpgon)		; store Z
	addqt	#4,altpgon
	move	basei,clipcodes
	shrq	#8,basei		; strip clipping codes from intensity
	shlq	#24,clipcodes
	mult	xcolori,basei		; multiply by polygon's intensity
	shrq	#24,clipcodes
.if TEXTURES
	move	uv,temp0		; put V into temp0
	store	basei,(altpgon)		; store I
	addqt	#4,altpgon
	shrq	#8,uv			; isolate U
	shlq	#24,temp0		; isolate V
	shlq	#8,uv			; now uv = U as a 16 bit unsigned number
	shrq	#16,temp0		; and temp0 = V as a 16 bit number
	mult	xtexwidth,uv		; multiply U by texture width
	mult	xtexheight,temp0	; multiply V by texture height
	store	uv,(altpgon)		; store U
	addqt	#4,altpgon
	store	temp0,(altpgon)		; store V
	addqt	#4,altpgon
.else
	store	basei,(altpgon)
	addqt	#12,altpgon		; skip U and V
.endif
	load	(tri),temp2		; get the next point index from DRAM

	and	clipcodes,andclips
	or	clipcodes,orclips

	.equrundef	tpoints
	.equrundef	points
	.equrundef	x
	.equrundef	z
	.equrundef	y
	.equrundef	vx
	.equrundef	vz
	.equrundef	vy
	.equrundef	lx
	.equrundef	lz
	.equrundef	ly
	.equrundef	basei
	.equrundef	clipcode
	.equrundef	bright
	.equrundef	countr
	.equrundef	uv
	.equrundef	lmodel
	.equrundef	endloop
