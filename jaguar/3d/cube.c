#include	"n3d.h"

#define SIDE 200

Point cubepts[] = {
	{-SIDE, -SIDE, 0, -0x24f3,-0x24f3,-0x24f3 },
	{SIDE, -SIDE, 0, 0x24f3,-0x24f3,-0x24f3 },
	{SIDE, SIDE, 0, 0x24f3,0x24f3,-0x24f3 },
	{-SIDE, SIDE, 0, -0x24f3,0x24f3,-0x24f3 },
};


extern Bitmap chkbrd[];

Material cubemats[] = {
	{ 0x78c0, 0, chkbrd },		/* flags, color, texture map */
	{ 0x7fc0, 0, 0 }
};

/* this is misnamed: it's a two-sided rectangle, now */

Face cubetris[] = {
	{0,0,0xC000,0,	/* face normal -- front face */
	 3, 0,		/* flags, material */
	 {0, 0,		/* point A, ua, va */
	  1, 0xff00,	/* point B */
	  3, 0x00ff,
	 },
	},

	{0,0,0xC000,0,	/* face normal -- front face */
	 3,0,		/* flags, material */
	 {1, 0xff00,	/* point A, ua, va */
	  2, 0xffff,	/* point B */
	  3, 0x00ff,
	 },
	},

	{0,0,0x4000,0,	/* face normal -- back face */
	 3, 1,		/* flags, material */
	 {0, 0x0000,	/* point A, ua, va */
	  3, 0x00ff,	/* point B */
	  1, 0xff00,
	 },
	},

	{0,0,0x4000,0,	/* face normal -- back face */
	 3, 1,		/* flags, material */
	 {1, 0xff00,	/* point A, ua, va */
	  3, 0x00ff,	/* point B */
	  2, 0xffff,
	 },
	},
};

N3DObjdata cubedata = { 4, 4, 2, 0, cubetris, cubepts, cubemats };
