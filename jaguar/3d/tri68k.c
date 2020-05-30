/*
 * Object rendering code.
 */

#include "stdlib.h"
#include "blit.h"
#include "tri.h"
#include "triintern.h"

#define NEWCLIP		/* define this to get the new clipping code */
#define MINZ 8				/* minimum z value */

long camxscale, camyscale;

extern void memset(void *, int, size_t);
extern long debug[256];

/*
 * utility function: find i such that (x >> i) is at most 15 bits
 */
int
normi(long x)
{
	int i;

	if (x < 0) x = -x;

	i = 0;
	while (x > 0x7fff) {
		x = x >> 1;
		i++;
	}
	return i;
}

long
shr(long x, int count)
{
	if (count < 0) {
		return x << (-count);
	}
	return x >> count;
}

/*
 * fixed point math code
 */
extern void GPUload(), GPUexec();
extern long gpufixdivcode[];
extern void fixeddiv();
extern long diva, divb;
extern long divresult;

typedef long Fixed;

Fixed Fixdiv( Fixed a, Fixed b ) {	/* compute a/b as a 16.16 fixed point number */
	int sign;

	if (a < 0) {
		sign = -1;
		diva = -a;
	} else {
		diva = a;
		sign = 1;
	}
	if (b < 0) {
		sign = -sign;
		divb = -b;
	} else {
		divb = b;
	}

	GPUexec(fixeddiv);
	return (sign < 0) ? -divresult : divresult;
}

/*
 * there are 2 sets of clipping planes: the world space ones
 * (used for deciding whether a point may need to be clipped)
 * and the screen space ones (used for actually clipping the
 * point)
 */
#define NUMCLIPPLANES 5
Clipplane wcplanes[NUMCLIPPLANES];
Clipplane scplanes[NUMCLIPPLANES-1];	/* the Z plane is the same for both */

/*
 * temporary variable storage
 */
Matrix	M;			/* cumulative transformation matrix */
extern Lightmodel TLights;		/* transformed lights */

Fixed p_iinc;			/* increment for I */
Fixed p_zinc;			/* increment for Z */
Fixed p_uinc;
Fixed p_vinc;

/*
 * global variables for transformations, etc.
 */
TPoint	*tpoints;
Point	*points;

/*
 * code to load and transform (if necessary) a point; the XPoint version
 * of the point is stuffed into the place pointed to by xp. Returns
 * the clipping code for the point.
 *
 * Parameters:
 *	xp:	pointer to the polygon point we are loading
 *	pindex:	index of the point in the points or tpoints array
 *	cam:	current camera
 *	
 */
long lightscale = 4;


unsigned
loadXpoint(Xpoint *xp, int pindex, Camera *cam, Lightmodel *lmodel)
{
	long x,y,z, one;	
	long vx, vy, vz;
	long lx, ly, lz;
	long dist;
	long bright;
	unsigned long basei;
	long tempi;
	unsigned clipcodes;
	int i;
	Clipplane *thisplane;
	unsigned code;

	if (tpoints[pindex].basei & 0x80) {
	/* do lighting (in object space) */
		vx = points[pindex].vx;
		vy = points[pindex].vy;
		vz = points[pindex].vz;
		x = points[pindex].x;
		y = points[pindex].y;
		z = points[pindex].z;
		one = 0x4000;


		basei = lmodel->ambient;
		for (i = 0; i < lmodel->numlights; i++) {
			bright = lmodel->lights[i].bright;
			lx = lmodel->lights[i].x;
			ly = lmodel->lights[i].y;
			lz = lmodel->lights[i].z;

			if (bright == 0) {
				/* sunlight */
				tempi = (vx * lx + vy*ly + vz*lz) >> 12;	/* multiply by 4 to get full sunlight effect */
				if (tempi > 0) {
					basei += tempi;
				}
			} else {
				/* in scene light */	
				lx -= x;
				ly -= y;
				lz -= z;
				dist = (lx*lx + ly*ly + lz*lz);
				tempi = (vx * lx + vy*ly + vz*lz);
				if (tempi > 0) {
					tempi = Fixdiv( tempi >> lightscale, dist);
					if (tempi > 0x0000ffff) tempi = 0x0000ffff;
					basei += (bright * tempi) >> 14;
				}
			}
		}
		if (basei > 0x0000ffffL)
			basei = 0x0000ffffL;

		xp->i = basei;

	/* point needs to be transformed to screen space, and clipped */
	/* rotate to screen viewing space */
	/* after the multiplication, the coordinates are 14.14 numbers;
	 * scale them here to 14.16 (canonical form)
	 */
		xp->x = (M.xrite*x + M.xdown*y + M.xhead*z + M.xposn*one) << 2;
		xp->y = (M.yrite*x + M.ydown*y + M.yhead*z + M.yposn*one) << 2;
#ifdef NEWCLIP
		xp->z = (M.zrite*x + M.zdown*y + M.zhead*z + M.zposn*one);
#else
		xp->z = (M.zrite*x + M.zdown*y + M.zhead*z + M.zposn*one) << 2;
#endif
	/* clip to viewing pyramid */
		clipcodes = 0;
		code = 1;
#ifdef NEWCLIP
		if (xp->z < MINZ) clipcodes |= 1;
		if (xp->z + xp->x < 0) clipcodes |= 2;		/* x/z < -1 */
		if (xp->z - xp->x < 0) clipcodes |= 4;		/* x/z > 1 */
		if (xp->z + xp->y < 0) clipcodes |= 8;		/* y/z < -1 */
		if (xp->z - xp->y < 0) clipcodes |= 16;		/* y/z > 1 */
#else
		thisplane = wcplanes;
		for (i = 0; i < NUMCLIPPLANES; i++) {
		/* the multiplies are of 15 bit signed numbers, so re-scale x,y, and z */
			int tempx, tempy, tempz;

			tempx = (xp->x >> 16);
			tempy = (xp->y >> 16);
			tempz = (xp->z >> 16);
			if ((tempx*thisplane->x + tempy*thisplane->y + tempz*thisplane->z + thisplane->d) < 0)
				clipcodes |= code;
			code = code << 1;
			thisplane++;
		}
#endif

	/* save transformed point to memory */
		tpoints[pindex].x = xp->x;
		tpoints[pindex].y = xp->y;
		tpoints[pindex].z = xp->z;
		tpoints[pindex].basei = (xp->i << 8) | clipcodes;
	} else {
		xp->x = tpoints[pindex].x;
		xp->y = tpoints[pindex].y;
		xp->z = tpoints[pindex].z;
		xp->i = (tpoints[pindex].basei) >> 8;		/* I is 15 bits */
		clipcodes = (tpoints[pindex].basei) & 0x00ff;
	}

	return clipcodes;
}


extern long p_gradient;

#define DDABITS 16

/*
 * find a number i such that (x >> i) and (y >> i) are both
 * less than 0x8000
 */
int
inormi2(long x, long y)
{
	int i;

	if (x < 0) x = -x;
	if (y < 0) y = -y;

	x |= y;
	i = 0;
	while (x >= 0x00008000L) {
		i++;
		x = x >> 1;
	}
	return i;
}

/*
 * Calculate fixed increments for a polygon.
 * This takes place in screen space, after
 * the perspective transform
 * Numerical considerations are very important
 * here!!!
 */
void
calcincs(Polygon *pgon)
{
	long xinc;
	long zinc, iinc, uinc, vinc;
	long i1,i2,y1,y2;
	int xnorm, ynorm, znorm, unorm, vnorm, inorm;
	const int i = 0;

	y2 = (pgon->pt[i+2].y - pgon->pt[0].y);
	y1 = -(pgon->pt[i+1].y - pgon->pt[0].y);
	ynorm = inormi2(y1, y2);
	y1 = y1 >> ynorm;
	y2 = y2 >> ynorm;

	i2 = (pgon->pt[i+2].x - pgon->pt[0].x);
	i1 = (pgon->pt[i+1].x - pgon->pt[0].x);
	xnorm = inormi2(i1, i2);
	i1 = i1 >> xnorm;
	i2 = i2 >> xnorm;
	xinc = (i1*y2 + i2*y1);

	i2 = (pgon->pt[i+2].z - pgon->pt[0].z);
	i1 = (pgon->pt[i+1].z - pgon->pt[0].z);
	znorm = inormi2(i1, i2);
	i1 = i1 >> znorm;
	i2 = i2 >> znorm;
	zinc = (i1*y2 + i2*y1);
	p_zinc = shr(Fixdiv(zinc,xinc), xnorm - znorm);

	i2 = (pgon->pt[i+2].i - pgon->pt[0].i);
	i1 = (pgon->pt[i+1].i - pgon->pt[0].i);
	inorm = inormi2(i1, i2);
	i1 = i1 >> inorm;
	i2 = i2 >> inorm;
	iinc = (i1*y2 + i2*y1);
	p_iinc = shr(Fixdiv(iinc,xinc), xnorm - inorm);

	i2 = (pgon->pt[i+2].u - pgon->pt[0].u);
	i1 = (pgon->pt[i+1].u - pgon->pt[0].u);
	unorm = inormi2(i1, i2);
	i1 = i1 >> unorm;
	i2 = i2 >> unorm;
	uinc = (i1*y2 + i2*y1);
	p_uinc = shr(Fixdiv(uinc,xinc), xnorm - unorm);

	i2 = (pgon->pt[i+2].v - pgon->pt[0].v);
	i1 = (pgon->pt[i+1].v - pgon->pt[0].v);
	vnorm = inormi2(i1, i2);
	i1 = i1 >> vnorm;
	i2 = i2 >> vnorm;
	vinc = (i1*y2 + i2*y1);
	p_vinc = shr(Fixdiv(vinc,xinc), xnorm - vnorm);

}

#define FUDGE 
long fudge = 0x00000000L;

#if 1
Fixed leftx, leftxstep;		/* left X values, and step value for moving to the next line */
Fixed leftz, leftzstep;		/* left Z and Zstep values */
Fixed lefti, leftistep;		/* I and Istep values */
Fixed leftu, leftustep;
Fixed leftv, leftvstep;
Fixed rightx, rightxstep;		/* right X value, and step value for this */
long anumlines;			/* number of lines for trapezoid */
long ay;

void
dotrap(Texmap *tmap)
{
	while (anumlines > 0) {
		int pixcount;

		pixcount = (rightx >> 16) - (leftx >> 16);
		if (pixcount > 0) {
			A2_PIXEL = (ay << 16) | (leftx >> 16);
			B_COUNT = 0x00010000L | pixcount;
			if (tmap) {
			/* draw texture mapped line */
				A1_PIXEL = (leftv & 0xffff0000) | ((unsigned long)leftu >> 16);
				A1_FPIXEL = ((leftv & 0x0000ffff) << 16) | (leftu & 0x0000ffff);
				B_CMD = SRCEN|LFU_S|DSTA2;
			} else {
			/* draw Gouraud shaded line */
				B_I3 = lefti;
				B_CMD = PATDSEL|GOURD|DSTA2;
			}
		}

		rightx += rightxstep;
		leftx += leftxstep;
		leftu += leftustep;
		leftv += leftvstep;
		lefti += leftistep;
		leftz += leftzstep;
		ay++;
		--anumlines;
	}
}

void
dotri(Xpoint *Aptr, Xpoint *Bptr, Xpoint *Cptr, Texmap *tmap)
{
	Xpoint *tempptr;
	long	temp1;
	Fixed Ay;
	Fixed Bx,By,Bz,Bu,Bv,Bi;
	Fixed Cx,Cy,Cz,Cu,Cv,Ci;


	Ay = Aptr->y;
	By = Bptr->y;
	Cy = Cptr->y;

	/* rename A,B,C so that A is at the top */
	if ( (Ay > By) || (Ay >= Cy) ) {
		tempptr = Aptr;
		temp1 = Ay;
		if (By > Cy) {			/* C is topmost */
		/* rotate counter clockwise */
			Aptr = Cptr;
			Ay = Cy;
			Cptr = Bptr;
			Cy = By;
			Bptr = tempptr;
			By = temp1;
		} else {
		/* rotate clockwise */
			Aptr = Bptr;
			Ay = By;
			Bptr = Cptr;
			By = Cy;
			Cptr = tempptr;
			Cy = temp1;
		}
	}
	/* load up the points */
	/* point A is going to form the left side of the trapezoid */
	leftx = Aptr->x;
	leftz = Aptr->z;
	lefti = Aptr->i;
	leftu = Aptr->u;
	leftv = Aptr->v;
	ay = (Ay >> 16);
	rightx = leftx;

	Bx = Bptr->x;
	Bz = Bptr->z;
	Bi = Bptr->i;
	Bu = Bptr->u;
	Bv = Bptr->v;

	Cx = Cptr->x;
	Cz = Cptr->z;
	Ci = Cptr->i;
	Cu = Cptr->u;
	Cv = Cptr->v;

	/* calculate right side step values */
	anumlines = ((By >> 16) - ay) << 16;
	rightxstep = Fixdiv(Bx - rightx, anumlines);

	/* calculate left side step values */
	anumlines = ((Cy >> 16) - ay) << 16;
	leftxstep = Fixdiv(Cx - leftx, anumlines);
	leftzstep = Fixdiv(Cz - leftz, anumlines);
	leftistep = Fixdiv(Ci - lefti, anumlines);
	leftustep = Fixdiv(Cu - leftu, anumlines);
	leftvstep = Fixdiv(Cv - leftv, anumlines);

	/* now, at this point there are two possibilities:
	 * (1)   A		or (2)	A
	 *	C			 B
	 *	  B		      C
	 * For both cases we need to draw 2 trapezoids.
	 * in case (1) we need to recalculate the left step
	 * values twice, in case (2) the right step values
	 * twice.
	 */
	if (By > Cy) {
		/* case 1 */
		/* trapezoid 1 */
		anumlines = anumlines >> 16;
		dotrap(tmap);
		/* re-calculate left side step values */
		anumlines = ( (By >> 16) - (Cy >> 16) ) << 16;
		if (anumlines <= 0) return;
		leftx = Cx;
		leftz = Cz;
		lefti = Ci;
		leftu = Cu;
		leftv = Cv;
		leftxstep = Fixdiv(Bx - leftx, anumlines);
		leftzstep = Fixdiv(Bz - leftz, anumlines);
		leftistep = Fixdiv(Bi - lefti, anumlines);
		leftustep = Fixdiv(Bu - leftu, anumlines);
		leftvstep = Fixdiv(Bv - leftv, anumlines);
		/* trapezoid 2 */
		anumlines = anumlines >> 16;
		dotrap(tmap);
	} else {
		/* case 2 */
		/* trapezoid 1 */
		anumlines = ((By >> 16) - (Ay >> 16));
		dotrap(tmap);
		/* recalculate right side step values */
		anumlines = ( (Cy >> 16) - (By >> 16) ) << 16;
		if (anumlines <= 0) return;
		rightx = Bx;
		rightxstep = Fixdiv(Cx - rightx, anumlines);
		/* trapezoid 2 */
		anumlines = anumlines >> 16;
		dotrap(tmap);
	}
}

void
drawpoly(Camera *cam, Polygon *pgon, unsigned color, Texmap *tmap)
{
	Xpoint *start, *end;
	Xpoint *right, *left;

	calcincs( pgon );
	color = (color & 0xff00);

	A2_BASE = (long)cam->outdata;
	A2_FLAGS = cam->outflags|XADDPIX;

	if (tmap) {
		A1_BASE = (long)(tmap->data);
		A1_FLAGS = tmap->blitflags | XADDINC;
		A1_INC = (p_vinc & 0xffff0000L) | ((unsigned long)p_uinc >> 16);
		A1_FINC = ((p_vinc & 0x0000ffffL) << 16) | (p_uinc & 0x0000ffffL);
	}

	B_PATD[0] = B_PATD[1] = ((long)color << 16) | (color);

	B_IINC = (p_iinc & 0x00ffffff);
	B_ZINC = p_zinc;

	start = &pgon->pt[0];
	end = &pgon->pt[pgon->numpoints];

	right = &pgon->pt[1];
	left = &pgon->pt[2];

	while (left != end) {
		dotri(start, right, left, tmap);
		right = left;
		left++;
	}
}

#else
void
drawpoly(Camera *cam, Polygon *pgon, unsigned color, Texmap *tmap)
{
	Xpoint *start, *end;		/* start and end of polygon */
	Xpoint *left, *right;		/* bottom left and right points */
	int ly, ry;			/* bottom left and right Y values */
	int y;				/* current Y value */
	int vertsrem;			/* number of vertices remaining */

	Fixed leftx, leftxstep;		/* left X values, and step value for moving to the next line */
	Fixed leftz, leftzstep;		/* left Z and Zstep values */
	Fixed lefti, leftistep;		/* I and Istep values */
	Fixed leftu, leftustep;
	Fixed leftv, leftvstep;
	Fixed rightx, rightxstep;		/* right X value, and step value for this */

	long numlines;			/* number of lines for trapezoid */
	Fixed nextval;


	calcincs( pgon );
	color = (color & 0xff00);

	A2_BASE = (long)cam->outdata;
	A2_FLAGS = cam->outflags|XADDPIX;

	if (tmap) {
		A1_BASE = (long)(tmap->data);
		A1_FLAGS = tmap->blitflags | XADDINC;
		A1_INC = (p_vinc & 0xffff0000L) | ((unsigned long)p_uinc >> 16);
		A1_FINC = ((p_vinc & 0x0000ffffL) << 16) | (p_uinc & 0x0000ffffL);
	}

	numlines = ((long)color << 16) | (color);
	B_PATD[0] = B_PATD[1] = numlines;

	B_IINC = (p_iinc & 0x00ffffff);
	B_ZINC = p_zinc;
	vertsrem = pgon->numpoints;
	start = &pgon->pt[0];
	end = &pgon->pt[pgon->numpoints];

	left = start;
	y = left->y >> 16;

/* find the top left vertex */
	for (right = start+1; right < end; right++) {
		if ( ((right->y>>16) < y) ) {
			left = right;
			y = left->y >> 16;
		}
	}
/* at this point:
 * "y" contains the smallest Y value (16.16 value), and "left" points to the top left vertex
 */


	ly = ry = y-1;
	right = left;

	leftx = ((long)left->x);
	rightx = ((long)right->x);
	lefti = ((unsigned long)left->i);
	leftz = (long)left->z;

	leftu = ((unsigned long)left->u);
	leftv = ((unsigned long)left->v);

	leftxstep = rightxstep = 0;
	leftistep = leftzstep = 0;
	leftustep = leftvstep = 0;

	while (vertsrem > 0) {

	/* find bottom right vertex */
		while (ry <= y && vertsrem > 0) {
			vertsrem--;
			rightx = (long)right->x;
			right++;
			if (right == end) right = start;
			nextval = (long)right->x;
			ry = right->y >> 16;
			numlines = ((long)ry - y) << 16;
			rightxstep = Fixdiv( nextval - rightx, numlines);
			rightx += FUDGE;
		}

	/* find bottom left vertex */
		while (ly <= y && vertsrem > 0) {
			vertsrem--;
			leftx = (long)left->x;
			leftz = (long)left->z;
			lefti = ((unsigned long)left->i);
			leftu = ((unsigned long)left->u);
			leftv = ((unsigned long)left->v);

			if (left == start) left = end;
			left--;

			ly = left->y >> 16;
			numlines = (((long)ly - y)) << 16;

			nextval = (long)left->x;
			leftxstep = Fixdiv( nextval - leftx, numlines );

			nextval = (long)left->z;
			leftzstep = Fixdiv( nextval - leftz, numlines );

			nextval = ((unsigned long)left->i);
			leftistep = Fixdiv( nextval - lefti, numlines );

			if (tmap) {
				nextval = ((unsigned long)left->u);
				leftustep = Fixdiv( nextval - leftu, numlines);
				nextval = ((unsigned long)left->v);
				leftvstep = Fixdiv( nextval - leftv, numlines);
			}
		}

	/* draw a trapezoid */

		numlines = ly - y;
		if (ry - y < numlines)
			numlines = ry - y;

		while (numlines > 0) {
			int pixcount;

			pixcount = (rightx >> 16) - (leftx >> 16);
			if (pixcount > 0) {
				A2_PIXEL = ((long)y << 16) | (leftx >> 16);
				B_COUNT = 0x00010000L | pixcount;
				if (tmap) {
				/* draw texture mapped line */
					A1_PIXEL = (leftv & 0xffff0000) | ((unsigned long)leftu >> 16);
					A1_FPIXEL = ((leftv & 0x0000ffff) << 16) | (leftu & 0x0000ffff);
					B_CMD = SRCEN|LFU_S|DSTA2;
				} else {
				/* draw Gouraud shaded line */
					B_I3 = lefti;
					B_CMD = PATDSEL|GOURD|DSTA2;
				}
			}

			rightx += rightxstep;
			leftx += leftxstep;
			leftu += leftustep;
			leftv += leftvstep;
			lefti += leftistep;
			leftz += leftzstep;
			y++;
			--numlines;
		}
	}
}
#endif

/*
 * initialize clipping planes
 */

/*
 * initialize clipping planes
 */
void
TRIinitclip(Camera *cam)
{
	memset(wcplanes, 0, sizeof(wcplanes));
	memset(scplanes, 0, sizeof(scplanes));

	wcplanes[0].z = 1;  wcplanes[0].d = -8;			/* clip backwards against z=0x8 */

	/* for world space clipping, we want:
	 * x' = cam->xscale*x/z + cam->xcenter > 0
	 */
	wcplanes[1].x = cam->xscale; wcplanes[1].z = cam->xcenter;
	wcplanes[2].x = -cam->xscale; wcplanes[2].z = cam->width - cam->xcenter;

	wcplanes[3].y = cam->yscale; wcplanes[3].z = cam->ycenter;
	wcplanes[4].y = -cam->yscale; wcplanes[4].z = cam->height - cam->ycenter;

	scplanes[0].x = 1;  scplanes[0].d = 0;			/* clip against x = 0 */
	scplanes[1].x = -1; scplanes[1].d = cam->width-1;
	scplanes[2].y = 1;  scplanes[2].d = 0;
	scplanes[3].y = -1; scplanes[3].d = cam->height-1;
}


/*
 * clip an input polygon against a plane, producing an output polygon
 */


/*
 * utility function: given two 14.16 numbers, find a number that is "frac"
 * fraction along the line from B to A; "frac" is a 0.16 fixed point number
 * (unsigned)
 */
long
fracpoint( long B, long A, long frac)
{
	long diff;
	int norm;

	diff = A - B;
	norm = normi(diff);
	diff = diff >> norm;
	diff = (diff * frac) >> (16 - norm);
	return B+diff;
}

/* utility function: produce an output point from an edge that crosses a
 * clipping plane
 *
 * Inputs: OUT points to where to put the edge-plane intersection
 *         A points to the point on the -ve side of the plane
 *         B points to the point on the +ve side
 *         distA and distB are the distances to A and B, respectively
 */
void
cutedge(Xpoint *OUT, Xpoint *A, Xpoint *B, long distA, long distB)
{
	long frac;

	distA = -distA;
	frac = Fixdiv(distB, distB+distA);

	/* watch out! A->x is a 14.16 number (ditto for other components) */
	OUT->x = fracpoint(B->x, A->x, frac);
	OUT->y = fracpoint(B->y, A->y, frac);
	OUT->z = fracpoint(B->z, A->z, frac);

	OUT->i = fracpoint(B->i, A->i, frac);
	OUT->u = fracpoint(B->u, A->u, frac);
	OUT->v = fracpoint(B->v, A->v, frac);
}

/*
 * do the perspective transform on a polygon
 * ASSUMPTIONS: A->z is > 1 (so do this ONLY
 * after clipping to the front viewing plane!)
 */
void
doperspective(Polygon *P, Camera *cam)
{
	Xpoint *A;
	int i;
	long xcenter, ycenter;

	xcenter = ((long)cam->xcenter << 16);
	ycenter = ((long)cam->ycenter << 16);

	for (i = 0; i < P->numpoints; i++) {
		long zfrac, temp;
		int znorm, tempnorm;

		A = &P->pt[i];

		/* calculate 1/Z as a 23 bit fraction */
		zfrac = Fixdiv(1L << 23, A->z);
		znorm = normi(zfrac);
		zfrac = zfrac >> znorm;

		temp = A->x;
		tempnorm = normi(temp);
		temp = temp >> tempnorm;
		A->x = camxscale * shr(zfrac * temp, 23 - (znorm+tempnorm)) + xcenter;

		temp = A->y;
		tempnorm = normi(temp);
		temp = temp >> tempnorm;
		A->y = camyscale * shr(zfrac * temp, 23 - (znorm+tempnorm)) + ycenter;

#if 0
			A->u = Fixdiv(A->u << 7, A->z);
			A->v = Fixdiv(A->v << 7, A->z);
			A->z = Fixdiv(1L<<23, A->z);
#endif
	}
}


void
clip_to_plane(Polygon *pgon, Polygon *altpgon, Clipplane *thisplane, Camera *cam)
{
	int count;
	int numpoints;
	Xpoint *A, *B;
	Xpoint *OUT;
	long distA, distB;
	long tempx, tempy, tempz;

	count = pgon->numpoints;
	A = &pgon->pt[count-1];
	B = &pgon->pt[0];
	OUT = &altpgon->pt[0];

	/* x,y, and z are in world coordinates (14.16) */
	tempx = A->x >> 16;
	tempy = A->y >> 16;
	tempz = A->z >> 16;

	distA = (tempx * thisplane->x + tempy * thisplane->y + tempz * thisplane->z + thisplane->d);
	numpoints = 0;

	while (--count >= 0) {
		tempx = B->x >> 16;
		tempy = B->y >> 16;
		tempz = B->z >> 16;

		distB = (tempx * thisplane->x + tempy * thisplane->y + tempz * thisplane->z + thisplane->d);
		if (distA < 0) {
			if (distB > 0) {
				cutedge(OUT, A, B, distA, distB);
				OUT++;
				numpoints++;
			}
		} else {
			*OUT++ = *A;
			numpoints++;
			if (distA > 0 && distB < 0) {
				cutedge(OUT, B, A, distB, distA);
				OUT++;
				numpoints++;
			}
		}
		A = B;
		distA = distB;
		B++;
	}
	altpgon->numpoints = numpoints;

}

/*
 * render an object, using a given camera
 */
unsigned long ASPECT;

void
TRIrender(Object *obj, Camera *cam, Lightmodel *lmodel)
{
	Triangle *tri;
	int	tricount;
	Polygon	*pgon, *altpgon;
	unsigned andclips, orclips, curclip;
	int	camx, camy, camz;
	int 	i;
	Texmap *tmap;
	unsigned color, basei;

	/* load up GPU code we will need */
	GPUload(gpufixdivcode);

	/* allocate temporary storage */
	tpoints = malloc(sizeof(TPoint)*obj->data->numpoints);

	/* mark all points as untransformed */
	memset(tpoints, 0xff, sizeof(TPoint)*obj->data->numpoints);

	/*
	 * transform lighting vectors from world space to object space
	 * for this, we need the inverse of the object->world space transform
	 */
	/* make M = inverse(obj->M) */
	M.xrite = obj->M.xrite;
	M.xdown = obj->M.yrite;
	M.xhead = obj->M.zrite;

	M.yrite = obj->M.xdown;
	M.ydown = obj->M.ydown;
	M.yhead = obj->M.zdown;

	M.zrite = obj->M.xhead;
	M.zdown = obj->M.yhead;
	M.zhead = obj->M.zhead;

	M.xposn = -(M.xrite*(long)obj->M.xposn + M.xdown*(long)obj->M.yposn + M.xhead*(long)obj->M.zposn) >> 14L;
	M.yposn = -(M.yrite*(long)obj->M.xposn + M.ydown*(long)obj->M.yposn + M.yhead*(long)obj->M.zposn) >> 14L;
	M.zposn = -(M.zrite*(long)obj->M.xposn + M.zdown*(long)obj->M.yposn + M.zhead*(long)obj->M.zposn) >> 14L;


	TLights.ambient = lmodel->ambient;
	TLights.numlights = lmodel->numlights;

	for (i = 0; i < lmodel->numlights; i++) {
		Light *lsrc, *ldest;
		long x,y,z,one, bright;

		lsrc = &lmodel->lights[i];
		ldest = &TLights.lights[i];
		x = lsrc->x; y = lsrc->y; z = lsrc->z;
		bright = lsrc->bright;
		one = 0;
		if (bright != 0) {		/* transform a vector */
			one = 0x4000;
		}
		ldest->x = (M.xrite*x + M.xdown*y + M.xhead*z + M.xposn*one) >> 14;
		ldest->y = (M.yrite*x + M.ydown*y + M.yhead*z + M.yposn*one) >> 14;
		ldest->z = (M.zrite*x + M.zdown*y + M.zhead*z + M.zposn*one) >> 14;
		ldest->bright = bright;
	}

	lmodel = &TLights;

	/* calculate object -> camera space transform */
	M.xrite = (cam->M.xrite*(long)obj->M.xrite + cam->M.xdown*(long)obj->M.yrite + cam->M.xhead*(long)obj->M.zrite) >> 14;
	M.xdown = (cam->M.xrite*(long)obj->M.xdown + cam->M.xdown*(long)obj->M.ydown + cam->M.xhead*(long)obj->M.zdown) >> 14;
	M.xhead = (cam->M.xrite*(long)obj->M.xhead + cam->M.xdown*(long)obj->M.yhead + cam->M.xhead*(long)obj->M.zhead) >> 14;
	M.xposn = cam->M.xposn + ((cam->M.xrite*(long)obj->M.xposn + cam->M.xdown*(long)obj->M.yposn + cam->M.xhead*(long)obj->M.zposn) >> 14);

	M.yrite = (cam->M.yrite*(long)obj->M.xrite + cam->M.ydown*(long)obj->M.yrite + cam->M.yhead*(long)obj->M.zrite) >> 14;
	M.ydown = (cam->M.yrite*(long)obj->M.xdown + cam->M.ydown*(long)obj->M.ydown + cam->M.yhead*(long)obj->M.zdown) >> 14;
	M.yhead = (cam->M.yrite*(long)obj->M.xhead + cam->M.ydown*(long)obj->M.yhead + cam->M.yhead*(long)obj->M.zhead) >> 14;
	M.yposn = cam->M.yposn + ((cam->M.yrite*(long)obj->M.xposn + cam->M.ydown*(long)obj->M.yposn + cam->M.yhead*(long)obj->M.zposn) >> 14);

	M.zrite = (cam->M.zrite*(long)obj->M.xrite + cam->M.zdown*(long)obj->M.yrite + cam->M.zhead*(long)obj->M.zrite) >> 14;
	M.zdown = (cam->M.zrite*(long)obj->M.xdown + cam->M.zdown*(long)obj->M.ydown + cam->M.zhead*(long)obj->M.zdown) >> 14;
	M.zhead = (cam->M.zrite*(long)obj->M.xhead + cam->M.zdown*(long)obj->M.yhead + cam->M.zhead*(long)obj->M.zhead) >> 14;
	M.zposn = cam->M.zposn + ((cam->M.zrite*(long)obj->M.xposn + cam->M.zdown*(long)obj->M.yposn + cam->M.zhead*(long)obj->M.zposn) >> 14);

	/* now calculate the camera's position in object space */
	/* for this, we need the inverse M' of the object->camera transform M. Now, if M is made up of a rotation followed
	 * by a translation (M = TR), then M' = R'T', i.e. translate first, then rotate.
	 */

	camx = -(M.xrite*(long)M.xposn + M.yrite*(long)M.yposn + M.zrite*(long)M.zposn) >> 14L;
	camy = -(M.xdown*(long)M.xposn + M.ydown*(long)M.yposn + M.zdown*(long)M.zposn) >> 14L;
	camz = -(M.xhead*(long)M.xposn + M.yhead*(long)M.yposn + M.zhead*(long)M.zposn) >> 14L;

#ifdef NEWCLIP
	/* adjust the object->camera space transform to squeeze the aspect ratio, so that the viewing pyramid
	 * will be the "canonical" one. For a square screen, this is a no-op, but for rectangular screens it should
	 * generally mean multiplying X by the ratio scrnY/scrnX.
	 */
	ASPECT = ((long)cam->height << 14)/cam->width;
	if (ASPECT > 0x7fff) ASPECT = 0x7fff;
	M.xrite = (M.xrite * ASPECT) >> 14;
	M.xdown = (M.xdown * ASPECT) >> 14;
	M.xhead = (M.xhead * ASPECT) >> 14;
	M.xposn = (M.xposn * ASPECT) >> 14;

	/* camxscale and camyscale are 9.0 fixed point numbers */
	camxscale = cam->width/2;
	camyscale = cam->height/2;
#else
	camxscale = cam->xscale;
	camyscale = cam->yscale;
#endif
	points = obj->data->points;
	tri = obj->data->tris;

	for (tricount = obj->data->numtris; tricount > 0; --tricount) {
	/* check for back-face removal by finding dot product of face equation and camera point */
		long bfval;

		bfval = (tri->fx*(long)camx + tri->fy*(long)camy + tri->fz*(long)camz + ((long)tri->fd<<14L));
		if (bfval <= 0)
			goto skipface;

	/* load up points, transforming if necessary */
		pgon = &P1;
		pgon->numpoints = 3;
		andclips = 0xff;
		orclips = 0;

		color = obj->data->materials[tri->material].color;
		basei = (color & 0x00ff);
		tmap = obj->data->materials[tri->material].tmap;

		curclip = loadXpoint(&pgon->pt[0], tri->pa, cam, lmodel);
		pgon->pt[0].u = (unsigned)tmap->width * (((unsigned long)tri->uva & 0xff00));
		pgon->pt[0].v = (unsigned)tmap->height * ((unsigned long)(tri->uva & 0x00ff) << 8);
		pgon->pt[0].i *= basei;
		andclips &= curclip;
		orclips |= curclip;
		curclip = loadXpoint(&pgon->pt[1], tri->pb, cam, lmodel);
		pgon->pt[1].u = (unsigned)tmap->width * (((unsigned long)tri->uvb & 0xff00));
		pgon->pt[1].v = (unsigned)tmap->height * ((unsigned long)(tri->uvb & 0x00ff) << 8);
		pgon->pt[1].i *= basei;
		andclips &= curclip;
		orclips |= curclip;
		curclip = loadXpoint(&pgon->pt[2], tri->pc, cam, lmodel);
		pgon->pt[2].u = (unsigned)tmap->width * (((unsigned long)tri->uvc & 0xff00));
		pgon->pt[2].v = (unsigned)tmap->height * ((unsigned long)(tri->uvc & 0x00ff) << 8);
		pgon->pt[2].i *= basei;
		andclips &= curclip;
		orclips |= curclip;

		/* trivial accept/reject:
			if orclips == 0, all points are inside the view pyramid (trivial accept)
			if andclips != 0, all points are on the "outside" of one of the planes (trivial reject)
		*/

		if (andclips != 0) goto skipface;

		altpgon = &P2;

		/* do Z clipping in world space */
		if (orclips & 1) {
			clip_to_plane(pgon, altpgon, &wcplanes[0], cam);
			pgon = altpgon;
			altpgon = &P1;
			/* if we clipped to the front Z plane, we may need to clip other planes, too */
			orclips = 0xff;
		}

		/* do the rest of the clipping in screen space */
		doperspective( pgon, cam );

		if (orclips != 0) {
		/* clip to view pyramid */
			curclip = 2;
			for (i = 0; i < NUMCLIPPLANES-1; i++) {
				Polygon *temp;

				if (orclips & curclip) {
				/* some point needs to be clipped to this plane */
					clip_to_plane(pgon, altpgon, &scplanes[i], cam);
					temp = altpgon;
					altpgon = pgon;
					pgon = temp;
				}
				curclip = curclip << 1;
			}

			if (pgon->numpoints < 3)
				goto skipface;

		}

	/* render polygon */
		drawpoly(cam, pgon, color, tmap);

	skipface:
		tri++;
	}

	free(tpoints);
}
