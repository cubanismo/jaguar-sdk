struct olist_bitmap {			/* bitmap object: unpacked version */
	unsigned short	type;
	unsigned short	xpos;
	unsigned short	ypos;
	unsigned long link;			/* if 0, fall through to next object */
	void	*data;
	unsigned short	height;
	unsigned short	dwidth;
	unsigned short	iwidth;
	unsigned short	depth;
	unsigned short	pitch;
	unsigned short	index;			/* palette index */
	unsigned short	flags;
#define OL_REFLECT	0x1
#define OL_RMW		0x2
#define OL_TRANS	0x4
#define OL_RELEASE	0x8
	unsigned short	firstpix;
	unsigned short	hscale;
	unsigned short	vscale;
	unsigned short	remainder;
};

struct olist_gpu {
	unsigned short	type;
	unsigned short	reserved;
	unsigned short	ypos;
	unsigned long	data[2];
};

struct olist_branch {
	unsigned short	type;
	unsigned short	condition;
#define OL_CCEQ	0x1
#define OL_CCGT	0x2
#define OL_CCLT	0x4
#define OL_CCFLG 0x8
#define OL_CC2ND 0x10
	unsigned short	ypos;
	unsigned long	link;
};

struct olist_stop {
	unsigned short	type;
	unsigned short	reserved;
	unsigned short	intflag;
#define OL_INT	1
	unsigned long	data[2];
};

union olist {
	struct olist_bitmap	bit;
	struct olist_gpu	gpu;
	struct olist_branch	bra;
	struct olist_stop	stp;
	unsigned short type;
};

/* defines for "type" of olist union */
#define OL_BITMAP	0
#define OL_SCALEBITMAP	1
#define OL_GPU		2
#define OL_BRANCH	3
#define OL_STOP		4
#define OL_SKIP		0xfe

/* defines for various scaling factors */
#define OL_SCALE_NONE	0x20
#define OL_SCALE_HALF	0x10
#define OL_SCALE_DOUBLE	0x40
#define OL_SCALE_TRIPLE	0x60

void *OLbuild(union olist *unpacked);
void OLbldto(union olist *unpacked, void *ptr);
long OLsize(union olist *unpacked);

extern long OLPstore[];
extern void *OList;

#define OLPset(ptr) OList = ptr

