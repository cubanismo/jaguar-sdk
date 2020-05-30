/*
 * joypad structure definitions
 */

typedef struct {
	unsigned long lastval;		/* last values read from this stream */
	unsigned long curval;		/* current stream value */
	unsigned long *addr;		/* joystick port address */
} JOYSTREAM;


extern JOYSTREAM *JOY1, *JOY2;

unsigned long JOYget(JOYSTREAM *);
unsigned long JOYedge(JOYSTREAM *);

#define	JOY_UP		(1L<<20)		/* joypad values */
#define	JOY_DOWN	(1L<<21)
#define	JOY_LEFT	(1L<<22)
#define	JOY_RIGHT	(1L<<23)

#define	FIRE_A		(1L<<29)
#define	FIRE_B		(1L<<25)
#define	FIRE_C		(1L<<13)
#define	OPTION		(1L<<9)
#define	PAUSE		(1L<<28)

#define	KEY_S		(1L<<16)
#define	KEY_7		(1L<<17)
#define	KEY_4		(1L<<18)
#define	KEY_1		(1L<<19)

#define	KEY_0		(1L<<4)
#define	KEY_8		(1L<<5)
#define	KEY_5		(1L<<6)
#define	KEY_2		(1L<<7)

#define	KEY_H		(1L<<0)
#define	KEY_9		(1L<<1)
#define	KEY_6		(1L<<2)
#define	KEY_3		(1L<<3)

