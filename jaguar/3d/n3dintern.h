/*
 * Internal data structures (not visible to clients) for
 * the new 3D rendering package
 */
/* transformed point */
/* clipcodes stored in low byte of "basei" and are used for clipping against the viewing pyramid
 * bit 0: Z < 0
 * bit 1: X < 0
 * bit 2: X > max_x
 * bit 3: Y < 0
 * bit 4: Y > max_y
 * bit 7: set if point has not yet been transformed
 */
typedef struct tpoint {
	unsigned long basei;	/* 0.16 unsigned fraction in middle 2 bytes; 8 bit clipping codes in low byte */
	long	x, y;		/* 14.16 signed fixed point numbers */
	long	z;		/* 14.16 signed fixed point (before perspective), 0.24 fixed point fraction (after perspective) */
} TPoint;


/* points as stored in polygons */

typedef struct xpoint {
	long		x,y;	/* 10.16 fixed point numbers (after clipping and perspective) */
	long		z;	/* 0.30 fixed point fraction (it's actually 1/z) */
	long		i;	/* 8.16 unsigned fixed point */
	long		u,v;	/* 9.16 unsigned fixed point (after perspective, these are u/z and v/z */
} Xpoint;

#define MAXPOLYPOINTS 8

typedef struct polygon {
	long	numpoints;
	Xpoint	pt[MAXPOLYPOINTS];
} N3DPolygon;

