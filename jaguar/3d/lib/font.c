/*
 * Jaguar bit-to-pixel font library
 *
 * All fonts are (presently) encoded as 1 bit per pixel bitmaps, with
 * a fixed width. If the width is not a multiple of 8 bits, then each
 * character must be right-aligned within a box which *is* a multiple
 * of 8 bits (presently only 8, 16, and 32 bit boxes are supported).
 * This is due to the idiosyncratic way the blitter's bit to pixel
 * expansion works.
 *
 * These functions work on any font in 8 and 16 bit per pixel modes,
 * but in < 8 bit per pixel modes they work only if every character
 * output is byte aligned (again, thank the blitter for this).
 *
 * Entry points:
 *
 * long
 * FNTbox( char *str, FNThead *fnt )
 *
 * Returns the size (in pixels) of a box which will enclose the given
 * string when printed with the given font. This is encoded the same
 * way blitter windows are, i.e. with height in the high word and
 * width in the low word.
 * If you use this function, then your programs will work with
 * proportional fonts.
 *
 * long
 * FNTstr( int x, int y, char *str, void *dest, long blitflags, FNThead *fnt, unsigned fgcolor, unsigned bgcolor )
 *
 * Blits a string to a blitter window, at position x,y.
 * The blitter window is specified by its base (dest) and the blitter flags necessary to write into it (blitflags).
 * The font to use is given by fnt.
 * The foreground color for the blit is fgcolor.
 * The background color is bgcolor, or 0 if no background color is to be used.
 * Returns the width & height of the string that was just blitted.
 */

#include "blit.h"
#include "font.h"

/*************************************************************************
wid(flags): return the blitter width for a given set of blitter flags
This is done by a table lookup on "widtab"; each entry in widtab consists
of two longs, the first being the width as an integer, the second being
the corresponding blitter bits.
*************************************************************************/
static unsigned int widtab[] = {
2,	0x0800,
4,	0x1000,
6,	0x1400,
8,	0x1800,
10,	0x1A00,
12,	0x1C00,
14,	0x1E00,
16,	0x2000,
20,	0x2200,
24,	0x2400,
28,	0x2600,
32,	0x2800,
40,	0x2A00,
48,	0x2C00,
56,	0x2E00,
64,	0x3000,
80,	0x3200,
96,	0x3400,
112,	0x3600,
128,	0x3800,
160,	0x3A00,
192,	0x3C00,
224,	0x3E00,
256,	0x4000,
320,	0x4200,
384,	0x4400,
448,	0x4600,
512,	0x4800,
640,	0x4A00,
768,	0x4C00,
896,	0x4E00,
1024,	0x5000,
1280,	0x5200,
1536,	0x5400,
1792,	0x5600,
2048,	0x5800,
2560,	0x5A00,
3072,	0x5C00,
3584,	0x5E00,
0,	0x0000
};

int
wid(unsigned int blitflag)
{
	unsigned *ptr;

	blitflag &= 0x7E00;

	ptr = widtab;
	while (ptr[0] != 0) {
		if (ptr[1] == blitflag) {
			return ptr[0];
		}
		ptr += 2;		/* skip the image width and blitter bits */
	}
	return 1;		/* punt */
}

/*
 * find the width in pixels of a string when
 * printed using the given font
 */
long
FNTbox( char *_str, FNThead *fnt )
{
	unsigned int wid;
	int c;
	unsigned char *charwidths;
	unsigned char *str = (unsigned char *)_str;

	wid = 0;
	if (fnt->type == 2) {			/* proportional font */
		charwidths = ((unsigned char *)fnt->data)+fnt->res*(long)fnt->height*2;
		while ( (c=*str++) != 0) {
			if (c < fnt->firstchar || c > fnt->lastchar)
				c = 0;
			else
				c -= fnt->firstchar;
			wid += charwidths[c];
		}
	} else {
		while ( (c=*str++) != 0)
			wid += fnt->width;
	}
	return (((long)fnt->height) << 16) | wid;
}

/*
 * function to find the step value for a phrase or pixel mode blit
 * (for pixel mode, "pixels_per_phrase" will be 0)
 */
long
phrase_step( long pixel, unsigned width, unsigned pixels_per_phrase )
{
	long endx;
	int stepx;

	stepx = -width;
	endx = ( (unsigned)pixel + width ) & pixels_per_phrase;
	if (endx > 0)
		stepx -= (pixels_per_phrase+1-endx);
	return 0x00010000 | ((long)stepx & 0x0000ffff);
}

/*
 * function to find the number of pixels in a phrase, from the blitter flags
 * if phrase mode is not allowed, return 0
 */
static inline
unsigned
pixels_per_phrase( long blitflags )
{
	switch(blitflags & (PIXEL1|PIXEL2|PIXEL4|PIXEL8|PIXEL16|PIXEL32)) {
	case PIXEL1:
		return 0;		/* phrase mode not allowed */
	case PIXEL2:
		return 0;		/* phrase mode not allowed */
	case PIXEL4:
		return 0;		/* phrase mode still not allowed */
	case PIXEL8:
		return 7;
	case PIXEL16:
		return 3;
	default:
		return 1;
	}
}

/*
 * internal routine: bit-blit characters from a bit image into a destination bitmap
 * it is assumed that the source and destination have the same number of bits
 * per pixel!
 * Also: it is assumed that the font is fixed width.
 * Color 0 is treated as transparent.
 */
long
FNTcopy( int x, int y, unsigned char *str, void *dest, long blitflags, FNThead *fnt )
{
	unsigned	cwidth;		/* width of each character (and hence of each blit) */
	long	cmd;			/* cmd to give the blitter */
	long	a1pixel;
	int	c;
	long	count;
	volatile long *patd;
	long bndbox;
	unsigned pix_per_phrase;

	cwidth = fnt->width;

	cmd = SRCEN|UPDA1|UPDA2|LFU_REPLACE|DSTEN|DCOMPEN;

	a1pixel = (((long)y) << 16L) | (unsigned)x;

	A2_BASE = (long)fnt->data;
	A1_BASE = (long)dest;

	pix_per_phrase = pixels_per_phrase(blitflags);
	if (pix_per_phrase != 0) {	/* phrase mode is OK */
		A2_FLAGS = XADDPHR|(fnt->blitflags & ~XADDINC)|PITCH1;
		A1_FLAGS = XADDPHR|(blitflags & ~XADDINC);
	} else {
		A2_FLAGS = XADDPIX|(fnt->blitflags & ~XADDINC)|PITCH1;
		A1_FLAGS = XADDPIX|(blitflags & ~XADDINC);
	}

/* set up for transparent blit */
	patd = (volatile long *)B_PATD;
	*patd++ = 0;
	*patd = 0;

	bndbox = ((long)fnt->height << 16L);
	count = ((long)fnt->height << 16L) | cwidth;

	while ( (c = *str++) != 0 ) {
		if (c < fnt->firstchar || c > fnt->lastchar) {
		/* if the character isn't in the font, just skip it */
			a1pixel += cwidth;
			bndbox += cwidth;
		} else {
			long a1step, a2step;

			c -= fnt->firstchar;

			c *= cwidth;

			a1step = phrase_step( a1pixel, cwidth, pix_per_phrase );
			a2step = phrase_step( c, cwidth, pix_per_phrase );

			if (a1step < a2step)
				a2step -= (pix_per_phrase+1);

			A1_STEP = a1step;
			A2_STEP = a2step;

			A2_PIXEL = c;
			A1_PIXEL = a1pixel;
			B_COUNT = count;
			/* if the source is not phrase aligned, we may need to set the SRCENX bit */
			/* note that if we're in pixel mode, pix_per_phrase is set to 0, and the test works */
			if ( (c & pix_per_phrase) != 0 &&
			     (c & pix_per_phrase) > (a1pixel & pix_per_phrase) ) {
				B_CMD = cmd | SRCENX;
			} else {
				B_CMD = cmd;
			}
			a1pixel += cwidth;
			bndbox += cwidth;
		}
	}
	return bndbox;
}

/*
 * internal routine: expand an 8 bit per pixel image into a 16 bit per pixel
 * destination. Uses a palette located at the end of the image data.
 * The font is assumed to be fixed width.
 * Color 0x0000 in the look up table is treated as transparent.
 */
long
FNTexpand( int x, int y, unsigned char *str, unsigned short *dest, long blitflags, FNThead *fnt, unsigned fgcolor)
{
	unsigned	cwidth;		/* width of each character in pixels */
	unsigned	cheight;	/* height of each character in pixels */
	unsigned long srcwidth;		/* pixels per line in the source */
	unsigned char *src;
	unsigned short *palette;	/* color look up table for font */
	long	cmd;			/* cmd to give the blitter */
	long	a1pixel;
	int	c;
	long bndbox;

	fgcolor &= 0xff00;
	cwidth = fnt->width;
	cheight = fnt->height;
	srcwidth = wid(fnt->blitflags);
	palette = (unsigned short *) (((unsigned char *)fnt->data) + cheight * srcwidth);
	palette++;	/* skip the "number of entries in palette" entry */

	A1_BASE = (long)dest;
	A2_FLAGS = XADDPIX|(fnt->blitflags & ~XADDINC)|PITCH1;
	A1_FLAGS = XADDPIX|(blitflags & ~XADDINC);

	cmd = LFU_REPLACE|DCOMPEN;

/* set up for transparent blit */
	B_PATD[0] = B_PATD[1] = 0;

	bndbox = FNTbox(str, fnt);

	while ( (c = *str++) != 0 ) {
		if (c < fnt->firstchar || c > fnt->lastchar) {
		/* if the character isn't in the font, just skip it */
			;
		} else {
			short color;
			int i, j;

			a1pixel = (((long)y) << 16L) | (unsigned)x;
			c -= fnt->firstchar;
			c *= cwidth;
			src = ((unsigned char *)fnt->data)+c;
			for (i = 0; i < cheight; i++) {
				A1_PIXEL = a1pixel;
				for (j = 0; j < cwidth; j++) {
	/* copy using the blitter so that the destination blitter flags can be arbitrary
	 * (e.g. for double buffered or Z buffered screens)
	 */
					color = palette[src[j]];
					if (color != 0)
						color = fgcolor | (color & 0x00ff);
					B_SRCD[0] = color;
					B_COUNT = 0x00010001;
					B_CMD = cmd;
				}
				src += srcwidth;
				a1pixel += 0x00010000;
			}
		}
		x += cwidth;
	}
	return bndbox;
}

/*
 * blit a string of characters from a font into a window
 * starting at *dest and with blitter flags destblitflags,
 * at position x, y
 * Returns: the bounding box of the string we just blitted.
 */

/* macro for converting PIXEL1 widths to PIXEL8 widths */
#define divby8(x) ( ((x)&0x7e00) - 0x1800 )

long
FNTstr( int x, int y, char *_str, void *dest, long blitflags, FNThead *fnt, unsigned fgcolor, unsigned bgcolor )
{
	int bshift;		/* convert from character to pixel with this shift */
	int fwidth;		/* width for the first blit */
	int c;			/* character to be blitted */
	long count;		/* contents of blitter COUNT register */
	long a1pixel;		/* destination address (y,x) */
	long cmd;		/* contents of blitter CMD register */
	long bits;		/* flag bits for the blitter */
	int numblits;		/* number of blits to perform */
	unsigned char *charwidths;	/* points to table of character widths, for proportional fonts */
	unsigned char *str = (unsigned char *)_str;
	long bndbox;		/* bounding box of the string we just blitted */

	switch(fnt->type) {
	case 4: /* 8 bit per pixel, with palette */
		if ((blitflags & 0x38) == PIXEL16) {
			return FNTexpand(x, y, str, (unsigned short *)dest, blitflags, fnt, fgcolor);
		}
		/* else fall through */
	case 3:
		/* plain bitmap image; just blit it as a copy */
		return FNTcopy(x, y, str, dest, blitflags, fnt);
	case 2:
		/* proportional font: find the character width table */
		charwidths = ((unsigned char *)fnt->data)+fnt->res*(long)fnt->height*2;
		break;
	default:
		/* fixed width font; no character width table is necessary */
		charwidths = 0;
		break;
	}

	/* figure out how to access characters in the font */
	/* all characters must be on a byte boundary (hence the	
	   "+7" and "& ~7"). Characters wider than 8 bits will
	   require more than one blit, since bit to pixel expansion
	   doesn't work properly for > 8 pixels wide. (Actually, it
	   does work for multiples of 8, but we don't take advantage
	   of that here.)
	 */

	switch(	(fnt->width+7) & ~7 ) {
		default: bshift = 0; numblits = 1; break;
		case 16: bshift = 1; numblits = 2; break;
		case 24:
		case 32:
			bshift = 2; numblits = 4; break;
	}

	/* for fixed width fonts, precalculate some blitter parameters
	 * if the width is > 8, we'll blit from 1-8 characters
	 * in the first blit, otherwise we'll do the whole
	 * thing on the first blit
	 */
	if (!charwidths) {
		if (fnt->width > 8) {
			/* this weird expression gives 1-8 for the first blit */
			fwidth = 1+((fnt->width-1)&0x7);
		} else {
			fwidth = fnt->width;
		}
		count = (((long)fnt->height) << 16) | fwidth;
	}
	a1pixel = (((long)y) << 16L) | (unsigned)x;
	cmd = SRCENX|UPDA1|UPDA2|PATDSEL|BCOMPEN|BKGWREN;

	/*
	 * NOTE:
	 * in < 1 byte/pixel modes, we must shift the color
	 * around to get at least 8 bits of the color register
	 * filled.
	 * Also: in these modes we must enable DSTEN in order to
	 * read write just some of a byte's pixels.
	 */
	bits = blitflags & (PIXEL1|PIXEL2|PIXEL4|PIXEL8|PIXEL16);
	switch(bits) {
	case PIXEL1:
		if (fgcolor) fgcolor = 0xff;
		if (bgcolor) bgcolor = 0xff;
		cmd |= DSTEN;
		break;
	case PIXEL2:
		fgcolor = (fgcolor << 2) | fgcolor;
		bgcolor = (bgcolor << 2) | bgcolor;
		fgcolor = (fgcolor << 4) | fgcolor;
		bgcolor = (bgcolor << 4) | bgcolor;
		cmd |= DSTEN;
		break;
	case PIXEL4:
		fgcolor = (fgcolor << 4) | fgcolor;
		bgcolor = (bgcolor << 4) | bgcolor;
		cmd |= DSTEN;
		break;
	case PIXEL8:
		break;
	default:	/* only 16 bits; we don't support 32 */
		break;
	}

	/* set up the colors */
	*(volatile long *)B_PATD = fgcolor;
	if (bgcolor) {
		*(volatile long *)B_DSTD = bgcolor;
	} else {
		cmd |= DSTEN;
	}

	/* set up the blitter windows */
	/* for bit to pixel expansion, we read the pixels as bytes; this is quirky, but the way the
	 * blitter was designed (if we read the "normal" way, the expansion doesn't work in 1, 2, and
	 * 4 bit per pixel modes)
	 */
	A2_BASE = (long)fnt->data;
	A1_BASE = (long)dest;


	A2_FLAGS = XADDPIX|divby8(fnt->blitflags)|PITCH1|PIXEL8;
	A1_FLAGS = XADDPIX|(blitflags & ~XADDINC);

	A2_STEP = 0x0001ffff;		/* the source step is always fixed */

	bndbox = ((long)fnt->height) << 16;

	/* now blit it */
	while ( (c = *str++) != 0 ) {
		int blitcount;

		if (c < fnt->firstchar || c > fnt->lastchar)
			c = 0;
		else
			c -= fnt->firstchar;

		/* for proportional width fonts, find the character width */
		if (charwidths) {
			fwidth = charwidths[c];
			blitcount = ((fwidth+7)&~7) >> 3;
			if (fwidth > 8) {
				/* this weird expression gives 1-8 for the first blit */
				fwidth = 1+((fwidth-1)&0x7);
			}
			count = (((long)fnt->height) << 16) | fwidth;

			/* for proportional fonts we may have to skip some blits
			 * (the character may have been padded on the left more than other
			 * characters in the font)
			 */
			c = c << bshift;
			if (numblits > blitcount) {
				c += (numblits-blitcount);
			}
			count = (((long)fnt->height) << 16) | fwidth;
		} else {
			blitcount = numblits;
			c = c << bshift;
		}

		A2_PIXEL = c;
		A1_PIXEL = a1pixel;
		B_COUNT = count;

		A1_STEP = 0x00010000L | ((-fwidth) & 0x0000ffffL);
		B_CMD = cmd;

		a1pixel += fwidth;
		bndbox += fwidth;

		if (blitcount > 1) {
			blitcount--;
			/* now blit the remaining 8xn blocks in the
			   character; all these blits will be 8 bits
			   wide
			 */
			c += 1;
		
			A1_STEP = 0x0001fff8L;

			while (blitcount > 0) {
				A2_PIXEL = c;
				A1_PIXEL = a1pixel;
				B_COUNT = (((long)fnt->height) << 16) | 8;

				B_CMD = cmd;

				a1pixel += 8;
				c += 1;
				bndbox += 8;
				blitcount--;
			}
		}
	}
	return bndbox;
}
