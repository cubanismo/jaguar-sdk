Controls for the demo:
----------------------

A	=	Move model towards -Z
B	=	Move model slowly towards -Z
C	=	Move model towards +Z

up,down,
left,right,
1,3	=	Rotate model

2,8	=	Move model in Y direction
4,6	=	Move model in X direction

0+any of the above
	=	Move camera instead of model



Option	=	Next model

#	=	Next renderer
*	=	Previous renderer






Source Code for the New 3D Library
----------------------------------
April 25,1995


PLEASE NOTE: THIS IS A PRELIMINARY VERSION OF THE LIBRARY, AND AS SUCH IS
STILL SUBJECT TO CHANGE

There are five renderers provided with the C demo code.  These are found in:

(1) Wire Frame Renderer 	-- wfrend.s
(2) Gouraud Only (no textures)	-- gourrend.s
(3) Plain Textures		-- texrend.s
(4) "Flat" Shaded Textures	-- flattex.s
(5) Gouraud Shaded Textures	-- gstex.s


Each renderer includes a variety of .inc files.  There are four basic
modules:

init	-- initializes global variables

load	-- loads points from RAM, transforms them (if
	   necessary), and stores them in our internal
	   format

clip	-- does a perspective transform, and clips polys
	   to the screen. The perspective transform is
	   done here rather than in 'load' because
	   clipping to the front view plane must be done
	   in world coordinates, not screen coordinates.

draw	-- draws the polygons


init.inc
	Initializes global variables.

load.inc
 loadxpt.inc

	Loads faces and points.  Does backface culling.  Transforms and
	lights points (as needed), and calculates clip codes.  Stores
	vertices into GPU RAM in internal format.

	loadxpt.inc is an inline subroutine to load and transform 1 point,
	and save it to GPU RAM.

clip.inc
 clibsubs.inc

	Does trivial accept/reject processing, and if necessary clips
	polygons to the canonical viewing pyramid.  After clipping is done in
	3D space, does the perspective transformation and projects to 3D
	space.

	clipsubs.inc contains the subroutines necessary for clipping a
	polygon to a single plane.

draw.inc
 dotri.inc
  gourdraw.inc
  texdraw.inc
  texdraw1.inc
  texdraw2.inc

	Draws a polygon onto screen.  This is done by decomposing polygons
	into triangles (increments for gouraud shading and texture mapping
	can be calculated once per triangle, saving up to 3 divides per scan
	line).

	dotri.inc renders a single triangle.

	gourdraw.inc and texdraw*.inc contain routines for setting up
	(untextured) gouraud shaded triangles, and texture mapped triangles,
	and for rendering trapezoids.  The different texdraw.inc files do
	different kinds of shading on the triangles.


Any of the modules can be replaced relatively easily.  For example, the wire
frame renderer replaces the draw module and its subroutines with a single
file, wfdraw.inc, for drawing a polygon in wire frames.


Some Quirks and Optimizations
-----------------------------

Init
----
init.inc sets up the transformation matrix from object space to camera space.
The transformation also includes a scale, so that the viewing pyramid becomes
the "canonical" view volume, z > MINZ AND x < z < -x AND y < z < -y.  This
volume can be clipped to very easily.  When the perspective transformation
takes place, the scaling is undone so that the proper viewing rectangle is
drawn to.


Load
----
All points are initially marked as untransformed.  As points are needed for
rendering, they are checked in the tpoints[] array to see if a transformed
version exists.  If so, this is used; if not, the point is transformed and
lit, and then saved into tpoints[].  The advantage of this approach is that
vertices which only appear in faces which are backface culled do not need to
be transformed at all.

Backface culling and lighting are done in object space.  This means that face
and vertex normals never need to be transformed.  The disadvantage is that
the object->world space transformation must be isometric (i.e.  scaling of
objects is not supported).


Clip
----
Clipping is done in 3D space, *before* the perspective transformation.  This
has the following benefits:

(1) clipping to the front viewing plane (Z=MINZ) must be done before
perspective transformation for correct results

(2) Quantities which do not interpolate linearly in screen space (e.g.
texture coordinates) are clipped more accurately when done before perspective
transformation

The major disadvantage of this approach is speed: each point must be
perspective-transformed every time it is used, rather than just once per
point.


Draw
----
Shaded texture mapping is done with a 2 (or 3 pass blit).  Basically, data is
copied from external RAM to GPU RAM, and then back out to external RAM.  This
is done to work around a blitter bug (Z buffering and source shading can't be
used together).  Gouraud shaded texture mapping adds an extra blit, within
GPU RAM, to do the shading.

Another blitter bug prevents phrase mode Z buffered writes from working
correctly unless the source and destination pixels have the same alignment
within a phrase.  (If they do not have the same alignment, sometimes the
fractional parts of the computed Z values are used instead of the integer
parts).  Since GPU RAM can only be read/written on longword boundaries, it is
very difficult to work around this bug while keeping the buffer in GPU RAM.
4 solutions are:

(1) Put the buffer in DRAM. This is much slower.

(2) Use pixel modes for all writes. Also much slower.

(3) Put the buffer in the color lookup table.  This works well, but restricts
polygons to having at most 256 pixels per line.  Also, if the color lookup
table is in use, or if the RELEASE bit is set on objects, this method will
not work.

(4) Punt and assume that Z is constant throughout a line.  In this case, the
integer and fractional parts of the Z value can be made identical, so that
the blitter bug won't matter and the GPU buffer can always be written to at a
long word boundary.

Option (4) was used.  This does result in visual artifacts for highly curved
surfaces or surfaces that are close together, but in many cases it works
well.  Modifying texdraw1.gas and/or texdraw2.gas to use one of the other
work-arounds should not be difficult.





Using the New 3D Library for the Jaguar
---------------------------------------
April 20,1995


PLEASE NOTE: THIS IS A PRELIMINARY VERSION OF THE LIBRARY, AND AS SUCH IS
STILL SUBJECT TO CHANGE


Introduction
------------
The "new" 3D library for Jaguar (N3D) has been designed as a general purpose,
easy to modify and easy to use package.  It has the following features:

	-- Hidden surface removal via Z-buffering
	-- Gouraud shading and texture mapping
	-- Output to an arbitrarily sized bitmap
	-- Easily modified lighting models

Z-buffering was chosen for hidden surface removal because the hardware
implementation on Jaguar makes this relatively efficient, and much more
general purpose and easy to use than other hidden surface removal methods
(e.g.  sorting or BSP trees).  Models may be drawn into the screen in any
order, and the correct display will result.

The library can be configured to support a variety of texture mapping
options: no textures (all polygons are drawn Gouraud shaded in a single
color), textures without shading, "flat" shaded textures (actually these are
Gouraud shaded along the Y axis, but the shade is constant across scan lines;
this is useful for depth shading, for example), or Gouraud shaded textures.

The size and base address of the destination bitmap are parameters to the
library, so it is easy to support different drawing windows.



Calling the Renderer
--------------------
Calling the renderer is quite easy.  Load the parameters for the renderer
(see below for a description of these) into a long aligned array of long
words called _params, load the rendering package into the GPU, and jump to
the entry point.  The rendering package has a small header prepended to it
giving the start address for the load, then the number of bytes to load; the
actual GPU code follows this header.  So, for example, a quick and dirty way
to copy the Gouraud-shaded texture map renderer (the address of which is
_gstexcode) is, with the 68000:

	; get the address of the package into a0
	lea	_gstexcode,a0
	; get the GPU address for the package
	move.l	(a0)+,a1
	; get the size of the package
	move.l	(a0)+,d0
.loop:
	move.l	(a0)+,(a1)+	; copy 4 bytes
	subq.l	#4,d0
	bgt.b	.loop



Parameters for the Renderer
---------------------------
The renderer takes 6 parameters:

(1) A pointer to the N3D object data for the object to render.

(2) A pointer to the transformation matrix for that object.

(3) A pointer to the output bitmap (i.e.  the window into which to render).

(4) A pointer to the camera's transformation matrix.

(5) A pointer to the lighting model.

(6) A pointer to a work area consisting of 16 bytes for every point in the
N3D object data.


We will discuss these parameters in order.


(1) N3D Object Data
-------------------
Object data for the renderer is specified by a N3DObjdata structure (see the
file n3d.h for a C definition of this).  This structure has the following
fields:

short numpolys
	A 16 bit integer giving the number of polygons in the object.

short numpoints
	A 16 bit integer giving the total number of vertices in the object.

short nummaterials
	A 16 bit integer giving the number of entries in the materials table
	(see below).

short reserved
	A 16 bit field reserved for future expansion (and to preserve
	alignment).  It must be set to 0.

void *faces
	A pointer to a list of faces.

void *points
	A pointer to the list of vertices.

void *materials
	A pointer to the table of materials.

Faces

Each face consists of:

short fx,fy,fz,fd:
	Four 16-bit integers that together give the plane equation for the
	polygon (namely, "fx*x + fy*y + fz*z + fd = 0").  The signs of
	fx,fy,fz, and fd are chosen so that if the plane equation evaluated
	at a point is negative, that point is behind the polygon.

short npts:
	The number of points in the face.  This must be either 3 or 4 (i.e.
	the current renderers support only triangles or quadrilaterals).

short material:
	A 16 bit index into the materials table, giving the color and/or
	texture for this face.

Points:
	"npts" points, each consisting of:

	(1) A 16 bit index into the vertex table (giving
	    the point's x,y,z coordinates and a vertex normal).

	(2) An 8 bit source texture X coordinate.

	(3) An 8 bit source texture Y coordinate.

	Texture coordinates are 8 bit unsigned fractions, with
	0.0 = $00 and 1.0 = $ff.

By making the texture coordinates fractions, the data structure is relatively
independent of the particular texture chosen; thus, several identically
shaped models could share the same face data, but have different texture maps
(possibly of different sizes) given in their material tables.

Vertices

Each vertex consists of:

short x,y,z:
	The X, Y, and Z coordinates of the vertex.  These are signed 16 bit
	numbers.  To avoid overflow in Z buffer calculations (particularly in
	phrase mode) we recommend that these numbers be kept in the range
	-$4000 to +$4000.

	The coordinate system is left-handed, i.e.  in the viewer's space,
	positive X points to the right of the screen, positive Y points to
	the bottom of the screen, and positive Z points into the screen.

short vx,vy,vz:
	The vertex normal for this vertex.  Each number is a signed 14 bit
	fraction, with 1.0 = $4000 and -1.0 = $C000.

Materials

The material table gives the colors and/or textures for each face.  Using a
lookup table for these makes it easy to achieve effects such as animated
texture maps.  Each entry in the materials table consists of:

short color:
        A 16 bit CRY color to be used for drawing if no texture is specified,
	or if a renderer doesn't support texture mapping.

short flags:
        Flags for supporting special kinds of materials (e.g.
	self-illuminating or transparent).  Set to 0 for now, since no
	support is present for such materials.

Bitmap *tmap:
        Texture map for this material, or 0 if the material has no texture
	map.

The Bitmap structure consists of:

short width,height:
	16 bit width and height of the texture

long blitflags:
        The blitter flags for use with this texture.  None of the
	XADDINC/XADDPIX/ XADDPHR bits should be set.  E.g.  for a 16 bit per
	pixel, 32 pixel wide bitmap, use (PITCH1|PIXEL16|WID32).

void *data:
	The address of the actual pixel	data for this bitmap.


Making an Object from 3D Studio

The 3DSCONV program will automatically build an N3DObjdata structure from a
3D Studio input file and its associated Targa files (if there are texture
maps in the model).  The usage is:

	3DSCONV [-l _label] foo.3ds

This will build an assembly language file called "foo.n3d" which will contain
the N3DObjectdata structure.  The structure will be labelled with the global
label "_label"; if none is given, the default label for foo.3ds is
"_foodata".

Note that the texture maps must still be compiled and linked separately,
using the TGA2CRY utility.  If a .3DS file uses a texture called BAR.TGA,
then the corresponding .N3D file will expect the converted, compiled version
of the texture to be labelled "_bar".


Textures and Shading

If, when you compile, you select TEXSHADE=0, then no shading at all will be
applied to textures.  This means that the texture input format may be either
RGB or CRY.  However, untextured polygons will be drawn in CRY mode, so we
recommend use of CRY for textures as well.

If you select TEXSHADE=1 or TEXSHADE=2, then textures will be shaded.  In
these cases, the input textures must be in CRY format.  Moreover, because of
the way shading is performed, they must be in a special kind of CRY format:
the pixel intensities must be given as signed offsets to 0x80.  Textures can
be produced like this by the TGA2CRY program, if you give it the "-relative
0x80" option.  Alternatively, you can convert a regular texture (i.e.  one
with normal pixel intensities) to "-relative 0x80" format by exclusive or'ing
each pixel with 0x0080.  This can be done very quickly by the blitter.


(2) Object Transformation Matrix
--------------------------------
An object's transformation matrix is a 3x4 matrix giving the transformation
from object space (i.e.  the object's coordinates) to world space.  It has
the following C definition:

typedef struct matrix {
	short	xrite,yrite,zrite;
	short	xdown,ydown,zdown;
	short	xhead,yhead,zhead;
	short	xposn,yposn,zposn;
} Matrix;

Each entry is a 14 bit signed fraction, with 1.0 = $4000.

xrite,yrite,zrite is a unit vector pointing to the right of the object.

xdown,ydown,zdown is a unit vector pointing below the object.

xhead,yhead,zhead is a unit vector pointing straight ahead of the object.

xposn,yposn,zposn is the position of the object in world space.

Note that the unit vector requirements above mean that the transformation
matrix must not include any scaling.


(3) Output Bitmap
-----------------
The bitmap into which the object is to be drawn is specified in the same way
as textures are, i.e.  as a pointer to a Bitmap structure with the following
fields:

short width,height:
	16 bit width and height of the output bitmap.

long blitflags:
	The blitter flags for use with this bitmap.  None of the
	XADDINC/XADDPIX/ XADDPHR bits should be set.  E.g.  for a 16 bit per
	pixel, 320 pixel wide double buffered bitmap with a Z buffer, use
	(PIXEL16|PITCH3|ZOFFS2|WID320) for the first buffer, and
	(PIXEL16|PITCH3|ZOFFS1|WID320) for the second buffer.

void *data:
	The address of the actual pixel	data for this bitmap.


There are some restrictions on the output bitmap's width and height:

-- The height cannot be two or more times the width (i.e.  a 160x200 bitmap
is permissible, but a 160x320 bitmap is not).

-- We recommend that the width not be more than 4 times the height (numerical
inaccuracies in the clipping and transformation code could become noticeable
at such exaggerated aspect ratios).


(4) Camera Transformation Matrix
--------------------------------
A camera transformation matrix specifies a transformation from camera
coordinates to world space coordinates.  It is a 3x4 matrix with the same
format as an object transformation matrix (see above).  In fact, if a camera
is attached to an object, the same matrix can be used for drawing the object
or for rendering from the object's point of view.

In technical terms, it is the inverse of the camera matrix that is used in
rendering (i.e.  we transfrom from object space -> world space using the
object transformation matrix, and then from world space -> camera space using
the inverse of the camera transformation matrix).


(5) Lighting Model
------------------
The lighting model is a long-aligned structure containing the following
items:

unsigned short ambient
	A 16 bit fraction giving the amount of ambient illumination; 0 means
	no ambient light, $FFFF means the maximum amount of ambient light.

short numlights
	A 16 bit integer giving the number of lights in the lighting model.
	In the current implementation there can be at most 6 lights.

After this come the actual lights (numlights of them).  Each light consists
of 4 short integers: x, y, z, and bright.

There are two types of lights: in-scene lights and external lights.  In-scene
lights have bit 15 of their bright field set to 1; external lights have this
bit set to 0.  For in-scene lights, the x, y, and z fields give the position
of the light in world coordinates.  For external lights, x, y, and z give the
direction to the light from any point in the scene as a unit vector.  In both
cases, (bright AND $7fff) gives the relative brightness of the light, as a 15
bit unsigned fraction.


(6) Work Area
-------------
The temporary work area is overwritten by the renderer with transformed and
illuminated points.  16 bytes of space are required for each point in the
object to be displayed.



BUGS
----

The shaded texture mapping modules suffer from a bug in their Z buffering.
Due to the way GPU RAM is accessed, combined with bugs in the blitter's
handling of Z buffering, the value of Z is constant across a scan line
(rather than being interpolated as it ought to be).  This causes some
glitches to appear, particularly in objects with a great deal of curvature
(e.g.  the radar dish in the demo) or where several faces are very close.


