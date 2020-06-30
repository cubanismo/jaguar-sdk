/*
 * Data structures for new 3D renderer
 */

/*
 * a light can be of 1 of two types:
 * (1) an "in scene" light: this has attenuation based on distance to
 *	the point being illuminated
 * (2) sunlight: this is just a vector
 */

typedef struct light {
	short	x,y,z;		/* light position, for in scene, or normal vector for sunlight */
	unsigned short bright;		/* base intensity, for in scene, or 0 for sunlight */
} Light;

/*
 * a lighting model consists of:
 * (1) ambient illumination (from 0-$ffff)
 * (2) some number of lights
 *
 * we (arbitrarily) impose a limit of MAXLIGHTS lights
 * per scene. (Actually, it's not completely arbitrary;
 * the amount of GPU RAM available is the limiting factor.)
 */

#define MAXLIGHTS 6

typedef struct lightmodel {
	unsigned short	ambient;	/* ambient illumination */
	short	numlights;		/* number of lights */
	Light	lights[MAXLIGHTS];		/* pointer to lights */
} Lightmodel;

/*
 * transformation matrix: a 4x4 matrix, last column is always 0 0 0 1 so is not stored
 * numbers are 0.14 fractions (1 = 0x4000)
 */
typedef struct matrix {
	short	xrite,yrite,zrite;
	short	xdown,ydown,zdown;
	short	xhead,yhead,zhead;
	short	xposn,yposn,zposn;
} Matrix;

/*
 * points consist of the point + its vertex normal
 */
typedef struct point {
	short	x, y, z;
	short	vx, vy, vz;
} Point;


/*
 * a bitmap consists of:
 * (1) the width and height of the map
 * (2) blitter flags for the map
 * (3) a pointer to the actual data
 */
typedef struct texmap {
	short	width, height;
	long	blitflags;
	unsigned short *data;
} Bitmap;

/*
 * a "material" consists of:
 * a color (used for Gouraud shading)
 * flags (currently unused, set to 0)
 * a pointer to a bitmap used for texture
 * mapping
 */
typedef struct material {
	unsigned short	color;
	unsigned short	flags;
	Bitmap		*tmap;
} Material;

/* data structure for a face */
typedef struct triangle {
	short	fx, fy, fz, fd;		/* plane equation for polygon (face normal and -normal*point) */

	short	npts;			/* number of points (same as # of sides) */
	short	material;		/* index into Materials table */

/* for each point, keep:
   (1) the index of the point into the points or tpoints table (2 bytes)
   (2) texture map coordinates (U,V) (1 byte for each of U and V)
   Thus, the points[] array has 2 words (4 bytes) per point
 */
	unsigned short points[6];
} Face;

/* object data: many objects may share the same object data (e.g. if there are 3 identical spaceships
   flying around, all 3 objects can use the same data) */

typedef struct objdata {
	short	numpolys;		/* number of faces in object */
	short	numpoints;		/* number of points in object */
	short	nummaterials;		/* number of entries in the materials table */
	short	reserved;		/* reserved for future expansion, set to 0 */
	Face	*faces;			/* pointer to polygons */
	Point	*points;		/* point table */
	Material *materials;		/* pointer to table of materials (e.g. colors) */
} N3DObjdata;

/*
 * animation instructions: tells how to animate an object
 * There are 3 kinds of animations:
 * (1) Delta animations: the object's matrix M is updated
 *     based on velocity and pitch,yaw,roll deltas
 * (2) Frame animations: the object's matrix M is replaced
 *     by the appropriate frame of an animation.
 * (3) Procedural animations: a GPU program is executed
 *     to update the animation
 */

/* velocities are stored as signed 5.10 bit fractions representing units per
 * 300th of a second. This gives us a range of possible velocities:
 * 0.3 to 9600 points per second, or 0.06 to 1920 points per NTSC frame 
 *
 * rotations are stored as 8.7 bit fractions of angles, giving the amount
 * of rotation in a 300th of a second. Angular units are such that
 * 360 degrees = 2048, so the range of possible revolution speeds
 * is roughly 4 revolutions per hour to 74 revolutions per second
 */

struct delta_anim {
	short	type;		/* distinguishes type of animation: == 0 */
	short	scale;		/* reserved for future expansion, set to 0 */
	short	vx,vy,vz;	/* x, y, z velocities, as fractions as described above */
	short	pitch,yaw,roll;	/* amount of pitch, yaw, and roll to apply */
};

struct frame_anim {
	short	type;		/* distinguishes type of animation: == 1 */
	short	reserved;	/* reserved for future expansion, set to 0 */
	short	total_frames;	/* total number of frames in animation */
	short	frame_rate;	/* a signed 7.8 fraction giving the frames per 300th of a second */
	long	frame_number;	/* current frame number, as a 16.8 fraction (0-total_frames) */
	Matrix	frames[0];	/* list of animation frames */
};

struct gpu_anim {
	short	type;		/* distinguishes type of animation: == 2 */
	short	data0;		/* private data for animation */
	short	*gpupack;	/* GPU package to load for animation */
	long	gpuenter;	/* entry point for package */
	void	*data;		/* pointer to more private data for GPU animation */
};

typedef union animation {
	short	type;		/* 0 = delta_anim, 1 = frame_anim, 2 = gpu_anim */
	struct delta_anim delta;
	struct frame_anim frame;
	struct gpu_anim   gpu;
} Animation;

/* finally, an object: a transformation matrix, pointer to object data, plus
 * whatever else we eventually decide to include.
 */

typedef struct object {
	N3DObjdata	*data;
	Matrix	M;			/* object space -> world space  transformation */
	struct object *siblings;	/* pointer to object tree members at same level */
	struct object *children;	/* pointer to lower level objects */
	Animation *animation;
} N3DObject;
