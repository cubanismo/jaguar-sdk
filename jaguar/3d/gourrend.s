;*****************************************************************
; 3D POLYGON RENDERER
;
; Copyright 1995 Atari Corporation. All Rights Reserved.
;
; The renderer is basically divided up into 4 modules:
;	init	-- initializes global variables
;	load	-- loads points from RAM, transforms them (if
;		   necessary), and stores them in our internal
;		   format
;	clip	-- does a perspective transform, and clips polys
;		   to the screen. The perspective transform is
;		   done here rather than in 'load' because
;		   clipping to the front view plane must be done
;		   in world coordinates, not screen coordinates.
;	draw	-- draws the polygons
;*****************************************************************
;
; configuration info
;
; can we draw textures (0 if no, 1 if yes)
TEXTURES	=	0
;
; if we do textures, how do we shade them?
; (0 = no shading, 1 = flat shading, 2 = gouraud shading)
;
TEXSHADE	=	0
;
; Maximum number of polygon sides supported
;
POLYSIDES	=	4
;
; Maximum number of lights in a scene
;
MAX_LIGHTS	=	6
;
; Minimum Z value not clipped (must be > 0)
;
MINZ		=	8
;
; adjustment for perspective effect; this is a power of 2
; "2" is a good default; "0" produces very exaggerated
; perspective; bigger numbers produce smaller perspective
; effects
;
PERSP_SHIFT	=	2


	.include 	'jaguar.inc'
;
; GPU code for doing polygon rendering
;
SIZEOF_POLYGON	equ	(1+(6*(POLYSIDES+5)))		; polygon size in longs: 1 long for num. points, + 6 longs per point
							; make sure to allow 1 point per clipping plane for clipping
							; output relults!
SIZEOF_XPOINT	equ	24		; Xpoint size in bytes

	.extern	_params

	.globl	_gourcode
	.data
_gourcode:
	.dc.l	startblit, endblit-startblit

	.gpu
	.include 	"globlreg.inc"
	.include	"polyregs.inc"

	.org	G_RAM

startblit:

	.globl	_gourenter
_gourenter:

;
; GPU triangle renderer
;
; Parameters:
;	params[0] = pointer to object data
;	params[1] = pointer to object matrix
;	params[2] = pointer to camera
;	params[3] = pointer to lighting model
;	params[4] = pointer to scratch work area (16 bytes per point)
;
; Global variables initialized in init.inc
;
;	GPUcampos:	camera position vector (object space)
;	GPUM:		transformation matrix (longword entries)
;	GPUscplanes:	clipping planes for screen coordinates
;	GPUTLights:	lighting model (transformed to object space)

;
; make sure we're in bank 1
;
	movei	#G_FLAGS,r0
	load	(r0),r1
	bset	#14,r1
	store	r1,(r0)
	nop
	nop
;	.REGBANK1

;
; branch to the initialization code
;
	movei	#initonce,temp0
	move	PC,return
	jump	(temp0)
	addqt	#6,return

;***********************************************************************
; main loop goes here
; it is assumed that "return" points to "triloop"
;***********************************************************************

triloop:
	addqt	#(skipface-triloop),return
	moveta	return,altskip

	.globl	skipface
skipface:

;***********************************************************************
; Polygon loading code goes here
;***********************************************************************
	.include	"load.inc"

;***********************************************************************
; Clipping and perspective transformation code goes here
;***********************************************************************
	.include	"clip.inc"

;******************************************************************
; here's where we render the polygon
;******************************************************************
	movei	#curmaterial,altpgon
	.include "drawpoly.inc"

	movei	#triloop,return		; main loop expects its address in "return"
	jump	(return)		; branch to the main loop
	nop
;
; bottom of the triangle loop
;

endtriloop:
gpudone:

;
; now kill the GPU
;
	movei	#G_CTRL,r0
	moveq	#2,r1
.die:
	store	r1,(r0)
	nop
	nop
	jr	.die
	nop


	.include	"clipsubs.inc"

.if TEXTURES
.if TEXSHADE = 2
	.include	"texdraw2.inc"
.else
.if TEXSHADE = 1
	.include	"texdraw1.inc"
.else
	.include	"texdraw.inc"
.endif
.endif
.endif
	.include	"gourdraw.inc"

	.equrundef	thisplane

	.long
	.globl	_GPUcampos
	.globl	_GPUM
	.globl	_GPUscplanes
	.globl	_GPUTLights
;
; the code expects the next 3 arrays to always remain in order
	; 4x1 vector: camera's position in object space
_GPUcampos:
	.dcb.l	4,0
	; 4x3 matrix, 1 longword per entry
_GPUM:
	.dcb.l	12,0

	; screen coordinate clipping planes; z, x, x, y, y
_GPUscplanes:
	.dc.l	 0,  0, 1, -MINZ
	.dc.l	 1,  0, 1, 0
	.dc.l	-1,  0, 1, 0
	.dc.l	 0,  1, 1, 0
	.dc.l	 0, -1, 1, 0

	; lighting model: 4 bytes + 8 bytes per light
_GPUTLights:
	.dcb.l	1+(2*MAX_LIGHTS),0		; room for 8 lights
;
; variables
;
	.globl	gpoints,gtpoints
gnumpoints:
	.dc.l	0		; local copy of "numpoints" variable
gpoints:
	.dc.l	0		; local copy of "points" variable
gtpoints:
	.dc.l	0		; local copy of "tpoints" variable
materialtable:
	.dc.l	0		; local copy of materials table
camscale:
	.dc.l	0		; copy of camera x scale
	.dc.l	0		; copy of camera y scale
	.dc.l	0		; copy of camera x center
	.dc.l	0		; copy of camera y center
curmaterial:
	.dcb.l	2,0		; local copy of polygon material

;***********************************************************************
; Initialization code, and 324 word buffer for texture mapping
;
; The initialization code (which only needs to run once) can be
; shared with the GPU temporary buffer (which we only need
; after initialization is finished). The temporary buffer is used
; to accelerate texture mapping, and to allow shading, when Z-buffering.
; We do the initial blit from the texture source into GPU RAM, and
; then can do a phrase mode, Z-buffered blit from GPU RAM to the screen.
; This roughly halves the per-pixel cost (!) but also doubles the
; per scan-line cost.
;
; Note that the polygon storage areas (for polygon conversion) can also
; overlap the initialization code, since they aren't needed there.
;***********************************************************************
;
	.phrase

	; 1 screen wide draw buffer for texture mapped blits, plus 4 words for alignment
initcode:

	.globl	_GPUP1,_GPUP2
	.globl	_gpubuf

_GPUP1	=	initcode
_GPUP2	=	_GPUP1 + (4*SIZEOF_POLYGON)
_gpubuf = 	_GPUP2 + (4*SIZEOF_POLYGON)
; _gpubuf must be phrase aligned!


;
; include the initialization code
;
	.include	"init.inc"

	.long
endblit:

	.PRINT	"GPU RAM USE: ",/u/w (endblit-startblit), " Bytes used"
	.PRINT  "   ",/u/w 4096-(endblit-startblit), " Bytes free"
	.PRINT  "   ",/u/w 4096-(_gpubuf-startblit), " Bytes available for buffer"

