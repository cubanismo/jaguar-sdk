#include <stdlib.h>	/* for malloc() */
#include "olist.h"

#define HILINK(l) (((l) & 0x07ff00L) >> 8L)
#define LOLINK(l) (((l) & 0x00ff))
#define HIIWIDTH(w) (((w) & 0x3f0L) >> 4L)
#define LOIWIDTH(w) ((w) & 0x0fL)
#define DWIDTH(w) (w)

long
OLsize(union olist *o)
{
	long size = 0;
	short type;

	do {
		type = o->type;
		o++;
		switch(type) {
		case	OL_BITMAP:
			if (size & 15) {
				size = size+8;		/* align with a null branch object */
			}
			size += 16;
			break;
		case	OL_SCALEBITMAP:
			while (size & 31) {
				size = size+8;		/* align as needed */
			}
			size += 24;
			break;
		case	OL_GPU:
		case	OL_BRANCH:
		case	OL_STOP:
			size += 8;
			break;
		default:
			break;
		}
	} while (type != OL_STOP);

	return size;
}

void
OLbldto(union olist *o, void *packed) {
	long *lptr = (long *)packed;
	long l0, l1;
	int done;
	long curlink, nextlink;
	long align;
	long *linkaddr;
	union olist *obj;
	long objindex;

/* first, find number of objects in list
 */
	l0 = 1;		/* for last object */
	for (obj = o; obj->type != OL_STOP; obj++) {
		l0++;
	}
	linkaddr = alloca(4*(l0+1));
/*
 * next, find the link addresses of everything in
 * the list
 */
	curlink = ((long)OLPstore) + 32L;		/* first 4 phrases are stop objects & branches */
	curlink /= 8;
	done = 0;
	obj = o;
	objindex = 0;
	while (!done) {
		switch(obj->type) {
		case OL_BITMAP:
			curlink = (curlink+1) & ~1L;	/* double phrase align */
			l0 = 2;				/* takes 2 phrases */
			break;
		case OL_SCALEBITMAP:
			curlink = (curlink+3) & (~3L);	/* quad phrase align */
			l0 = 3;				/* takes 3 phrases */
			break;
		case OL_STOP:
			done = 1;			/* fall through */
		default:
			l0 = 1;				/* takes 1 phrase */
			break;
		}
		linkaddr[objindex] = curlink;
		curlink += l0;
		objindex++;
		obj++;
	}

/*
 * finally, actually build the object list
 */
	done = 0;
	objindex = 0;
	curlink = ((long)OLPstore) + 32L;		/* first 4 phrases are stop objects & branches */
	curlink /= 8;

	while (!done) {
		nextlink = linkaddr[objindex+1];
		l0 = l1 = 0;
		switch (o->type) {
		case OL_BITMAP:
			align = 1L;
			goto dobitmap;
		case OL_SCALEBITMAP:
			align = 3L;
dobitmap:
		/* align the bitmap object on the proper boundary */
			while (curlink & align) {
				curlink++;
				*lptr++ = HILINK(curlink);			/* stuff in a fake branch object */
				*lptr++ = (LOLINK(curlink) <<24L) | OL_BRANCH;
			}
		/* now fill in the various fields */
		/* first phrase, high long (bits 32-63) */
			if (o->bit.link != 0) {
				nextlink = linkaddr[o->bit.link-1];
			}
			l0 = ((((long)o->bit.data) & 0x00fffff8L)<< 8L) | HILINK(nextlink);
		/* first phrase, low long (bits 0-31) */
			l1 = ((long)LOLINK(nextlink) << 24L) | ((long)o->bit.height << 14L) | ((long)o->bit.ypos << 3L) | o->type;
			*lptr++ = l0;
			*lptr++ = l1;
			curlink++;

		/* second phrase */
			l0 = ((long)o->bit.firstpix << (49L-32L)) | ((long)o->bit.flags << (45L-32L)) | ((long)(o->bit.index>>1) << (38L-32L)) |
				HIIWIDTH(o->bit.iwidth);
			l1 = ((long)LOIWIDTH(o->bit.iwidth) << 28L) | ((long)o->bit.dwidth << 18L) | ((long)o->bit.pitch << 15L) |
				((long)o->bit.depth << 12L) | (o->bit.xpos);
			*lptr++ = l0;
			*lptr++ = l1;
			curlink++;

		/* last phrase */
			if (o->type == OL_SCALEBITMAP) {
				l0 = 0;
				l1 = ((long)o->bit.remainder << 16L) | ((long)o->bit.vscale << 8L) | (o->bit.hscale);
				*lptr++ = l0;
				*lptr++ = l1;
				curlink++;
			}
			break;
		case OL_GPU:
			l0 = o->gpu.data[0];
			l1 = (o->gpu.data[1] << 14L) | ((long)o->gpu.ypos << 3L) | (o->type);
			*lptr++ = l0;
			*lptr++ = l1;
			curlink++;
			break;
		case OL_BRANCH:
			nextlink = linkaddr[o->bra.link];
			l0 = HILINK(nextlink);
			l1 = (LOLINK(nextlink) << 24L) | ((long)o->bra.condition << 14L) | (o->bra.ypos << 3L) | (o->type);
			*lptr++ = l0;
			*lptr++ = l1;
			break;
		case OL_STOP:
			l0 = o->stp.data[0];
			l1 = (o->stp.data[1] << 4L) | ((o->stp.intflag & 1L) << 3L) | (o->type);
			*lptr++ = l0;
			*lptr++ = l1;
			curlink++;
			done = 1;
			break;
		}
		o++;
		objindex++;
	}
}

void *
OLbuild(union olist *unpacked) {
	long size;
	void *packed;

	size = OLsize(unpacked);
	packed = malloc(size);
	if (packed) {
		OLbldto(unpacked, packed);
	}
	return packed;
}


