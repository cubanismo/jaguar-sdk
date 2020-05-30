/*
 * Object rendering code.
 */

#include "stdlib.h"
#include "blit.h"
#include "tri.h"
#include "triintern.h"

extern int option_key;

extern void memset(void *, int, size_t);
extern void GPUload(), GPUexec();
extern long gstexcode[];
extern void gstexenter();
extern long params[];

/*
 * there are 2 sets of clipping planes: the world space ones
 * (used for deciding whether a point may need to be clipped)
 * and the screen space ones (used for actually clipping the
 * point)
 */
/* these arrays must come together! */
Clipplane wcplanes[(2*NUMCLIPPLANES)-1];
#define scplanes (&wcplanes[NUMCLIPPLANES])

/*
 * temporary variable storage
 */
Matrix	M;			/* cumulative transformation matrix */
extern Lightmodel TLights;		/* transformed lights */

/*
 * global variables for transformations, etc.
 */
TPoint	*tpoints;

void
TRIrender(Object *obj, Camera *cam, Lightmodel *lmodel)
{
	/* load GPU code */
	GPUload(gstexcode);

	/* allocate temporary storage */
	tpoints = malloc(sizeof(TPoint)*obj->data->numpoints);

	/* mark all points as untransformed */
	if (option_key == 0)
		memset(tpoints, 0xff, sizeof(TPoint)*obj->data->numpoints);

	params[0] = (long)obj->data;
	params[1] = (long)&obj->M;
	params[2] = (long)cam;
	params[3] = (long)lmodel;
	params[4] = (long)tpoints;

	GPUexec(gstexenter);

	free(tpoints);
}
