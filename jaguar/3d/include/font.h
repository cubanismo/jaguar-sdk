/*
 * Jaguar Font format:
 * The header must be 1 phrase long.
 * The font image must be ROUND(width)*count pixels
 * wide, and height pixels high; ROUND(x) is x
 * rounded up to the nearest byte boundary. Characters
 * must be byte aligned within the image.
 */

typedef struct {
	unsigned char	type;		/* type of font: 1 for normal, 2 for proportional, 3 for multi-bit image */
	unsigned char	res;		/* reserved for future expansion, set to 0 */
	unsigned char	width;		/* width of largest char. in font */
	unsigned char	height;
	unsigned char	firstchar;	/* first character in font */
	unsigned char	lastchar;	/* last character in font */
	short	blitflags;		/* blitter flags for font width (e.g. WID80 for an 8xn font with 10 characters */
	short	data[0];		/* the actual font image follows the header*/
} FNThead;


long FNTbox( char *str, FNThead *fnt );
long FNTstr( int x, int y, char *str, void *dest, long blitflags, FNThead *fnt, unsigned fgcolor, unsigned bgcolor );
