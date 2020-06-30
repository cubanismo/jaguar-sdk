/*
 * Test program for new 3D renderer.
 * Copyright 1995 Atari Corporation.
 * All Rights Reserved.
 */

#include "olist.h"
#include "font.h"
#include "blit.h"
#include "joypad.h"
#include "string.h"
#include "stdlib.h"
#include "n3d.h"
#include "n3dintern.h"

/****************************************************************
 *	Defines							*
 ****************************************************************/

/* camera width and height */
#define CAMWIDTH 320
#define CAMHEIGHT 200

/* the width and height of the screen object */
#define OBJWIDTH 320
#define OBJHEIGHT 200
#define WIDFLAG WID320		/* blitter flags corresponding to OBJWIDTH */

/* length in bytes of a screen line (2 data buffers+1 Z buffer ->
   3*2 = 6 bytes/pixel */
#define LINELEN (OBJWIDTH*6L)

/* 1/100th of the clock speed */
#define MHZ 265900L

/****************************************************************
 *	Type definitions					*
 ****************************************************************/

/* structure that records the rotation and
 * position of an object
 */
struct angles {
	short alpha, beta, gamma;		/* rotations */
	short xpos, ypos, zpos;		/* position */
};

/*
 * a renderer consists of:
 * (1) The name of the renderer
 * (2) The GPU package to load
 * (3) Entry point for that
 * (4) A flag specifying whether textures should be
 *     in normal format (0) or relative to 0x80 (1)
 */

typedef struct renderer {
	char *name;
	long *gpucode;
	void (*gpuenter)();
	short texflag;
	short null;		/* here for padding only */
} RENDERER;

/*
 * a model consists of:
 * (1) a pointer for the data for the model
 * (2) starting X,Y,Z coordinates for the model
 */
typedef struct model {
	N3DObjdata *data;
	short initx, inity, initz;
	short reserved;		/* pads structure to a longword boundary */
} MODEL;

/****************************************************************
 *	External functions					*
 ****************************************************************/

extern void VIDon(int);				/* turns video on */
extern void VIDsync(void);			/* waits for a vertical blank interrupt */
extern void mkMatrix(Matrix *, struct angles *); /* builds a matrix */
extern void GPUload(long *);			/* loads a package into the GPU */
extern void GPUrun(void (*)());			/* runs a GPU program */
extern int sprintf(char *, const char *, ...);	/* you know what this does */

/* NOTE: clock() is useful only for debugging; it works on
 * current developer consoles, but may fail on production
 * units and/or future Jaguar consoles!
 */
extern unsigned long clock(void);		/* timer function using the PIT */


/****************************************************************
 *	External variables					*
 ****************************************************************/

/* library count of number of 300ths of a second elapsed */
extern long _timestamp;

/* long-aligned parameter block for the GPU */
extern long params[];

/* timing information */
extern long proftime[];

/* the 2 screen buffers */
extern short DISPBUF0[], DISPBUF1[];
#define DATA1 ((char *)DISPBUF0)
#define DATA2 ((char *)DISPBUF1)

/* the font we'll use for printing stuff on screen */
extern FNThead usefnt[];

/* 3D object data */
extern N3DObjdata ship1data, globedata, radardata, torusdata, knightdata, robotdata, castledata, cubedata;

/****************************************************************
 *	External GPU references					*
 ****************************************************************/

extern long wfcode[], gourcode[], gourphrcode[],
	texcode[], flattexcode[], gstexcode[];

extern void wfenter(), gourenter(), gourphrenter(),
	texenter(), flattexenter(), gstexenter();

/****************************************************************
 *	Initialized Data					*
 ****************************************************************/

/* renderers supported */
RENDERER rend[] = {
	{"Wire Frames", wfcode, wfenter, 0},
	{"Gouraud Only", gourcode, gourenter, 0},
	{"Phrase Mode Gouraud", gourphrcode, gourphrenter, 0},
	{"Unshaded Textures", texcode, texenter, 0},
	{"Flat Shaded Textures", flattexcode, flattexenter, 0},
	{"Gouraud Shaded Textures", gstexcode, gstexenter, 1},
};
#define maxrenderer (sizeof(rend)/sizeof(RENDERER))

/* models we can draw */
MODEL models[] = {
	{ &globedata, 0, 0, 400, 0 },
	{ &ship1data, 0, 0, 1500, 0 },
	{ &torusdata, 0, 0, 2024, 0 },
	{ &knightdata, 0, 0, 600, 0 },
	{ &robotdata, 0, 0, 800, 0 },
	{ &radardata, 0, 0, 256, 0 },
	{ &castledata, 0, 0, 6000, 0 },
	{ &cubedata, 0, 0, 800, 0 },
};

#define maxmodel (sizeof(models)/sizeof(MODEL))

/* object list for first screen */
union olist buf1_olist[2] =
{
	{{OL_BITMAP,	/* type */
	 20+(320-OBJWIDTH)/2, 20+(240-OBJHEIGHT),		/* x, y */
	 0L,		/* link */
	 DATA1,		/* data */
	 OBJHEIGHT, OBJWIDTH*3/4, OBJWIDTH/4,		/* height, dwidth, iwidth */
	 4, 3, 0, 0, 0,	/* depth, pitch, index, flags, firstpix */
	 0,0,0}},		/* scaling stuff */

	{{OL_STOP}}
};

/* object list for second screen */
union olist buf2_olist[2] =
{
	{{OL_BITMAP,	/* type */
	 20+(320-OBJWIDTH)/2, 20+(240-OBJHEIGHT),		/* x, y */
	 0L,		/* link */
	 DATA2,		/* data */
	 OBJHEIGHT, OBJWIDTH*3/4, OBJWIDTH/4,		/* height, dwidth, iwidth */
	 4, 3, 0, 0, 0,	/* depth, pitch, index, flags, firstpix */
	 0,0,0}},		/* scaling stuff */

	{{OL_STOP}}
};

/* Bitmaps for the two screens */
Bitmap scrn1 = {
	CAMWIDTH, CAMHEIGHT,
	PIXEL16|PITCH3|ZOFFS2|WIDFLAG,
	(void *)(DATA1 + ((OBJWIDTH-CAMWIDTH)*3L) + (((OBJHEIGHT-CAMHEIGHT)/2)*LINELEN) ),
};

/* initial data for camera corresponding to second screen buffer */
Bitmap scrn2 = {
	CAMWIDTH, CAMHEIGHT,
	PIXEL16|PITCH3|ZOFFS1|WIDFLAG,
	(void *)(DATA2 + ((OBJWIDTH-CAMWIDTH)*3) + (((OBJHEIGHT-CAMHEIGHT)/2)*LINELEN) ),
};

Lightmodel lightm = {
	0x0000,
	1,
	{
	  { -0x24f3, -0x24f3, -0x24f3, 0x4000 },
	  { 0, 0, 0, 0xC000 },
	  { 0x4000, 0, 0, 0x4000 },
	  { 0, 0x4000, 0, 0x4000 },
	  { 0, 0, 0x4000, 0x4000 },
	}
};


/****************************************************************
 *	Global variables					*
 ****************************************************************/

/* flag for current texture state */
int texturestate;

/* pointer to temporary storage for transformed points */
TPoint	*tpoints;

/* storage for packed object lists */
int packed_olist1[160];
int packed_olist2[160];

struct angles camangles, objangles;

N3DObject testobj;


/****************************************************************
 *	Functions						*
 ****************************************************************/

/****************************************************************
 *	N3Dclrbuf(buf)						*
 * Clears the bitmap pointed to by "buf", filling its data with *
 * a solid color, and its Z buffer with a null value		*
 ****************************************************************/

void
N3Dclrbuf(Bitmap *buf)
{
	long bgcolor = 0x27a027a0;		/* fill color, duplicated */
	long zvalue = 0xffffffff;		/* Z value (16.16 fraction) */

	B_PATD[0] = bgcolor;
	B_PATD[1] = bgcolor;
	B_Z3 = zvalue;
	B_Z2 = zvalue;
	B_Z1 = zvalue;
	B_Z0 = zvalue;
	A1_BASE = (long)buf->data;
	A1_STEP = 0x00010000L | ((-buf->width) & 0x0000ffff);
	A1_FLAGS = buf->blitflags|XADDPHR;
	A1_PIXEL = 0;
	A1_CLIP = 0;
	B_COUNT = ((long)buf->height << 16) | (buf->width);
	B_CMD = UPDA1|DSTWRZ|PATDSEL;
}

/****************************************************************
 *	N3Drender(window, obj, cam, lmodel, rend)		*
 * Render an object into a bitmap. The parameters are:		*
 *	window: the destination bitmap				*
 *	obj:	the N3D object to render			*
 *	cam:	the viewing matrix				*
 *	lmodel:	the lighting model				*
 *	rend:	the renderer to use (wireframe, gouraud,	*
 *		or texture mapped				*
 ****************************************************************/

void
N3Drender(Bitmap *window, N3DObject *obj, Matrix *cam, Lightmodel *lmodel, RENDERER *rend)
{
	/* load GPU code */
	GPUload(rend->gpucode);

	/* allocate temporary storage */
	tpoints = malloc(sizeof(TPoint)*obj->data->numpoints);

	params[0] = (long)obj->data;
	params[1] = (long)&obj->M;
	params[2] = (long)window;
	params[3] = (long)cam;
	params[4] = (long)lmodel;
	params[5] = (long)tpoints;

	GPUrun(rend->gpuenter);

	free(tpoints);
}

/****************************************************************
 *	fixtexture( texture )					*
 * Adjust all intensities in a texture so that they are		*
 * relative to 0x80. This is done for renderers that do		*
 * shading on textures; because of the way the shading is	*
 * done, the source data must with intensities as signed	*
 * offsets to a base intensity (namely 0x80). So before using	*
 * a renderer that does shading on textures, this function	*
 * must be called on all textures in the model to be rendered.	*
 *								*
 * Note that because of the implementation, calling this	*
 * function twice yields the original texture back. This is	*
 * handy because it means that we can switch from unshaded	*
 * textures to shaded ones and then back again, calling this	*
 * function each time we switch.				*
 ****************************************************************/

void
fixtexture( Bitmap *texture )
{
	long *lsrc;
	long numpixs;
	long i;

	numpixs = ((long)texture->width * (long)texture->height)/4;
	lsrc = (long *)texture->data;

	for (i = 0; i < numpixs; i++) {
		*lsrc++ ^= 0x00800080L;
		*lsrc++ ^= 0x00800080L;
	}
}

/*
 * Fix up all textures in all models.
 * This is called when switching between renderers;
 * if the new renderer uses a different texture
 * shading model than the old renderer, then we
 * call fixtexture() on every texture in every
 * model.
 */

void
fixalltextures(int newrender)
{
	int i, j;
	N3DObjdata *curobj;
	Bitmap *map;

	if (texturestate != newrender) {
		for (i = 0; i < maxmodel; i++) {
			curobj = models[i].data;
			for (j = 0; j < curobj->nummaterials; j++) {
				map = curobj->materials[j].tmap;
				if (map)
					fixtexture(map);
			}
		}
		texturestate = newrender;
	}
}



/****************************************************************
 *	main()							*
 * The main demo loop.						*
 ****************************************************************/

int
main()
{
	int drawbuf;			/* flag: 0 means first buffer, 1 means second */
	Bitmap *curwindow;		/* pointer to output bitmap */
	Matrix cammatrix;		/* camera matrix */
	struct angles *curangles;	/* which set of angles (viewer or camera) are being manipulated */
	long buts, shotbuts;		/* joystick buttons pushed */
	long curframe;			/* current frame counter */
	long framespersecond;		/* frames per second counter */
	long time;			/* elapsed time */
	int currender;			/* current renderer in use (index into table) */
	int curmodel;			/* current model in use (index into table) */
	char buf[256];			/* scratch buffer for sprintf */

	/* build packed versions of the two object lists */
	/* (output is double buffered)			 */
	OLbldto(buf1_olist, packed_olist1);
	OLbldto(buf2_olist, packed_olist2);

	/* initialize the video */
	OLPset(packed_olist2);
	VIDon(0x6c1);			/* 0x6c1 = CRY; 0x6c7 = RGB */

	/* wait for video sync (paranoid code) */
	VIDsync();


	/* clear the drawing area to black */
	memset(DATA1, 0x00, OBJWIDTH*(long)OBJHEIGHT*2L*3);	/* clear screen to black */


	drawbuf = 0;			/* draw on buffer 1, while displaying buffer 2 */
	currender = 0;			/* initial render package to use */
	curmodel = 0;			/* initial model to draw */

	/* initialize the test object */
	memset(&testobj, 0, sizeof(testobj));
	testobj.data = models[curmodel].data;
	objangles.xpos = models[curmodel].initx;	/* get initial position */
	objangles.ypos = models[curmodel].inity;
	objangles.zpos = models[curmodel].initz;

	/* no rotation, initially */
	objangles.alpha = objangles.beta = objangles.gamma = 0;

	/* set up the viewer's position */
	camangles.alpha = camangles.beta = camangles.gamma = 0;
	camangles.xpos = camangles.ypos = 0;
	camangles.zpos = 0;

	/* initially all rotation and movement is applied to the object,
	   not the viewer
	 */
	curangles = &objangles;


	/* initialize timing information */
	curframe = _timestamp;			/* timestamp is updated every vblank, and is elapsed time in 300ths of a second */
	framespersecond = 1;

	/* initially textures are unshaded */
	texturestate = 0;

	/* set up the textures for the first renderer */
	fixalltextures(rend[currender].texflag);


	/* loop forever */
	for(;;) {
		/* select bitmap for drawing */
		curwindow = (drawbuf) ? &scrn2 : &scrn1;

		/* generate transformation matrices from angles */
		mkMatrix(&testobj.M, &objangles);
		mkMatrix(&cammatrix, &camangles);

		/* clear the current draw buffer */
		N3Dclrbuf(curwindow);

		/* now draw the object, timing how long it takes */
		/* NOTE: the clock() function uses unsupported hardware
		 * mechanisms; it happens to work on current developer
		 * machines, but will fail on some Jaguars. If this
		 * were production code, we would have to use a
		 * different timing mechanism!
		 */
		time = clock();
		N3Drender(curwindow, &testobj, &cammatrix, &lightm, &rend[currender]);
		time = clock() - time;

		/* Pring some statistics into the draw buffer (curwindow) */
		/* FNTstr draws text; see font.c for details */
		FNTstr(20, 0, rend[currender].name, curwindow->data, curwindow->blitflags, usefnt, 0x7fff, 0 );

		sprintf(buf, "%d faces/%d fps", testobj.data->numpolys, (int)framespersecond);
		FNTstr(20, 12, buf, curwindow->data, curwindow->blitflags, usefnt, 0x27ff, 0 );

		/* there are MHZ * 100 ticks in a second, and drawing 1 poly takes
		 * (time/testobj.data->numpolys) ticks,
		 * so the throughput is 100*MHZ/(time/testobj->data.numpolys)
		 */
		sprintf(buf, "%ld polys/sec", 100L * ( (MHZ * testobj.data->numpolys)/time) );
		FNTstr(20, 24, buf, curwindow->data, curwindow->blitflags, usefnt, 0x27ff, 0 );


		/* timing statistics */
		sprintf(buf, "%08lx draw time", time);
		FNTstr(20, 36, buf, curwindow->data, curwindow->blitflags, usefnt, 0xf0ff, 0 );

		/* buts will contain all buttons currently pressed */
		/* shotbuts will contain the ones that are pressed now, but weren't
		   pressed last time JOYget() was called
		 */
		buts = JOYget(JOY1);
		shotbuts = JOYedge(JOY1);


		/* now interpret the user's keypresses */
#define DELTA 4
		if (buts & FIRE_A) {
			curangles->zpos -= 0x10;
		} else if (buts & FIRE_B) {
			curangles->zpos -= 0x02;
		} else if (buts & FIRE_C) {
			curangles->zpos += 0x10;
		} else if (buts & KEY_2) {
			curangles->ypos -= DELTA;
		} else if (buts & KEY_8) {
			curangles->ypos += DELTA;
		} else if (buts & KEY_4) {
			curangles->xpos -= DELTA;
		} else if (buts & KEY_6) {
			curangles->xpos += DELTA;
		}

#define ROTINC 0x10
		if (buts & JOY_UP) {
			curangles->alpha -= ROTINC;
		} else if (buts & JOY_DOWN) {
			curangles->alpha += ROTINC;
		}
		if (buts & JOY_LEFT) {
			curangles->beta -= ROTINC;
		} else if (buts & JOY_RIGHT) {
			curangles->beta += ROTINC;
		}
		if (buts & KEY_1) {
			curangles->gamma -= ROTINC;
		} else if (buts & KEY_3) {
			curangles->gamma += ROTINC;
		}

		/* if the 0 key is held down, move the camera rather than
		 * the object
		 */
		if (buts & KEY_0) {
			curangles = &camangles;
		} else {
			curangles = &objangles;
		}

		if (shotbuts & OPTION) {
			curmodel++;
			if (curmodel >= maxmodel)
				curmodel = 0;
			testobj.data = models[curmodel].data;

			objangles.xpos = models[curmodel].initx;
			objangles.ypos = models[curmodel].inity;
			objangles.zpos = models[curmodel].initz;
			objangles.alpha = objangles.beta = objangles.gamma = 0;
		}

		if (shotbuts & KEY_H) {
			currender++;
			if (currender >= maxrenderer)
				currender = 0;
			fixalltextures(rend[currender].texflag);
		}

		if (shotbuts & KEY_S) {
			if (currender == 0)
				currender = maxrenderer;
			currender--;
			fixalltextures(rend[currender].texflag);
		}

		/* display the buffer we just drew */
		OLPset(drawbuf ? packed_olist2 : packed_olist1);

		/* wait for vblank */
		VIDsync();

		/* calculate frames per second, etc. */
		framespersecond = 300/(_timestamp - curframe);
		curframe = _timestamp;

		/* switch drawing buffers */
		drawbuf = !drawbuf;
	}

	return 0;
}
