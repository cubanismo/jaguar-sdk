;***********************************************************************
; Point loading and backface culling module.
; Loads the polygon data up and puts it into GPU RAM (at _GPUP1).
; If the polygon is facing away from us, culls it away.
;***********************************************************************

xy		.equr	r4
zd		.equr	r5
campos		.equr	r6
g_mtxa		.equr	r7
endloop		.equr	r8
bfculladdr	.equr	r9
material	.equr	r10

	movei	#G_MTXA,g_mtxa
	movei	#_GPUcampos,campos
	moveta	g_mtxa,altgmtxa
	movei	#endtriloop,endloop

bfcull:
	move	PC,bfculladdr
	addqt	#4,bfculladdr

	; we come here when a face has been backface culled; in that case, we don't need
	; to re-load the registers above
	subq	#1,tricount

	; set matrix address
	store	campos,(g_mtxa)

	jump	MI,(endloop)
	nop

;
; do backface culling
;
	; get polygon plane equation for backface clipping
	load	(tri),xy			; get plane equation (X and Y)
	addqt	#4,tri
	load	(tri),zd			; get plane equation (Z and D)
	addqt	#4,tri
	load	(tri),material			; get material
	addqt	#4,tri
	rorq	#16,xy				; put into proper format for mmult
	rorq	#16,zd				; (also makes sure the load is done)
	move	material,subr			; make "subr" equal to the count
	mmult	xy,temp2			; find dot product of camera position and plane equation
	cmpq	#1,temp2			; if positive, we have to display this triangle
	jr	PL,.noremove
	nop
		shlq	#8,material		; strip flags
		shrq	#22,material		; now material = number of points in polygon, times 4
		jump	(bfculladdr)
		add	material,tri		; skip 3 points (4 byte each)
.noremove:

.if (^^defined PROFILING)
	ADDTIME	OUTRLP
.endif

.equrundef	xy
.equrundef	zd
.equrundef	g_mtxa
.equrundef	campos
.equrundef	endloop

tpoints		.equr	r5,1		; transformed points
points		.equr	r6,1		; non-transformed points
xcolori		.equr	r7,1		; base intensity for triangle
xtexwidth	.equr	r8,1		; texture width
xtexheight	.equr	r9,1		; texture height
;material	.equr	r10,1		; material (defined earlier)

	movei	#materialtable,temp1
	shlq	#16,material		; strip count from "material"
	load	(temp1),temp1		; load address of material table
	shrq	#13,material		; and multiply material by 8 (== sizeof(Material))
	shlq	#8,subr			; strip flags from count
	add	material,temp1		; now temp1 points at the material
	shrq	#24,subr		; and make count an integer
	load	(temp1),xcolori		; get color (high word) and flags
	addqt	#4,temp1
	load	(temp1),temp1		; now temp1 points at a texture map
.equrundef	material

; save the texture map and color
	movei	#curmaterial,temp2
	store	xcolori,(temp2)
	addqt	#4,temp2
	shlq	#8,xcolori		; make xcolori be just the intensity
	store	temp1,(temp2)
	shrq	#24,xcolori

.if TEXTURES
	cmpq	#0,temp1		; is the texture map non-zero?
	moveq	#0,xtexheight
	jr	EQ,.skiptexload
	nop

.if TEXSHADE
	movei	#$00ff,xcolori
.endif

;*
; get the texture map data
;*
	load	(temp1),xtexheight	; get texture height (low word) and width (high word)
	addqt	#4,temp1
	load	(temp1),temp0		; get the blitter flags
	addqt	#4,temp1
	load	(temp1),temp1		; get the actual output address
	moveta	temp0,srcflags		; save source flags
	moveta	temp1,srcaddr		; and source address

.skiptexload:
	move	xtexheight,xtexwidth
	shlq	#16,xtexheight
	shrq	#16,xtexwidth
	shrq	#16,xtexheight

.endif	; TEXTURES

;*
; copy the polygon's points into GPU RAM
;*
	movei	#gpoints,temp0
	load	(temp0),points
	addqt	#4,temp0
	load	(temp0),tpoints
	movei	#_GPUP1,pgon

	move	pgon,altpgon
	store	subr,(pgon)			; save the number of points
	addqt	#4,altpgon			; skip to points array

	load	(tri),temp2			; get first point index from DRAM

	movei	#_GPUTLights,temp0
	movei	#$ff,andclips
	moveta	temp0,altlmodel

endloop		.equr	r22,1		; end of lighting calculation loop

	movei	#endlightloop,endloop

	move	PC,return
	moveq	#0,orclips
	addqt	#6,return
.pointlp:
	addqt	#4,tri

	.include	"loadxpt.inc"

; loadxpt.inc is responsible for loading the next point index from DRAM into temp2

	subq	#1,subr
	jump	NE,(return)			; jumps if subr != 0
	nop

.if (^^defined PROFILING)
	ADDTIME	DATALD
.endif
