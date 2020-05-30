/*======================================================================*
;*                TITLE:                  BLIT.INC			*
;*                Function:               Blitter variables		*
;*                                                                      *
;*                Project #:              JAGUAR                        *
;*                Programmer:             Andrew J. Burgess		*
;*                                        Rob Zdybel    		*
;*                                        Leonard Tramiel		*
;*                                                                      *
;*			COPYRIGHT 1992 Atari Computer Corporation       *
;*          UNATHORIZED REPRODUCTION, ADAPTATION, DISTRIBUTION,         *
;*          PERFORMANCE OR DISPLAY OF THIS COMPUTER PROGRAM OR          *
;*        THE ASSOCIATED AUDIOVISUAL WORK IS STRICTLY PROHIBITED.       *
;*                            ALL RIGHTS RESERVED.			*
;*                                                                      *
;*======================================================================*/

/*======================================================================*
;* ADDRESS REGISTERS
;*======================================================================*/

#define	A1_BASE 	*(volatile long *)0xf02200	/* A1 Base Address */
#define	A1_FLAGS	*(volatile long *)0xf02204	/* A1 Control Flags */
#define	A1_CLIP		*(volatile long *)0xf02208	/* A1 Clipping Size */
#define	A1_PIXEL	*(volatile long *)0xf0220C	/* A1 Pixel Pointer */
#define	A1_STEP		*(volatile long *)0xf02210	/* A1 Step (Integer Part) */
#define	A1_FSTEP	*(volatile long *)0xf02214	/* A1 Step (Fractional Part) */
#define	A1_FPIXEL	*(volatile long *)0xf02218	/* A1 Pixel Pointer (Fractional) */
#define	A1_INC		*(volatile long *)0xf0221C	/* A1 Increment (Integer Part) */
#define	A1_FINC		*(volatile long *)0xf02220	/* A1 Increment (Fractional Part) */
#define	A2_BASE		*(volatile long *)0xf02224	/* A2 Base Address */
#define	A2_FLAGS	*(volatile long *)0xf02228	/* A2 Control Flags */
#define	A2_MASK		*(volatile long *)0xf0222C	/* A2 Address Mask */
#define	A2_PIXEL	*(volatile long *)0xf02230	/* A2 PIXEL */
#define	A2_STEP		*(volatile long *)0xf02234	/* A2 Step (Integer) */

#define	B_CMD		*(volatile long *)0xf02238	/* Command */
#define	B_COUNT		*(volatile long *)0xf0223C	/* Counters */
#define	B_SRCD		((volatile long *)0xf02240)	/* Source Data */
#define	B_DSTD		((volatile long *)0xf02248)	/* Destination Data */
#define	B_DSTZ		((volatile long *)0xf02250)	/* Destination Z */
#define	B_SRCZ1		((volatile long *)0xf02258)	/* Source Z (Integer) */
#define	B_SRCZ2		((volatile long *)0xf02260)	/* Source Z (Fractional) */
#define	B_PATD		((volatile long *)0xf02268)	/* Pattern Data */
#define	B_IINC		*(volatile long *)0xf02270	/* Intensity Increment */
#define	B_ZINC		*(volatile long *)0xf02274	/* Z Increment */
#define	B_STOP		*(volatile long *)0xf02278	/* Collision stop control */

#define	B_I3		*(volatile long *)0xf0227C	/* Blitter Intensity 3 */
#define	B_I2		*(volatile long *)0xf02280	/* Blitter Intensity 2 */
#define	B_I1		*(volatile long *)0xf02284	/* Blitter Intensity 1 */
#define	B_I0		*(volatile long *)0xf02288	/* Blitter Intensity 0 */

#define	B_Z3		*(volatile long *)0xf0228C	/* Blitter Z 3 */
#define	B_Z2		*(volatile long *)0xf02290	/* Blitter Z 2 */
#define	B_Z1		*(volatile long *)0xf02294	/* Blitter Z 1 */
#define	B_Z0		*(volatile long *)0xf02298	/* Blitter Z 0 */


/*======================================================================*
;* BLITTER Command Register equates					*
;*======================================================================*/

#define	SRCEN	0x00000001	/* d00:     source data read (inner loop) */
#define	SRCENZ	0x00000002	/* d01:     source Z read (inner loop) */
#define	SRCENX	0x00000004	/* d02:     source data read (realign) */
#define	DSTEN	0x00000008	/* d03:     destination data read (inner loop) */
#define	DSTENZ	0x00000010	/* d04:     destination Z read (inner loop) */
#define	DSTWRZ	0x00000020	/* d05:     destination Z write (inner loop) */
#define	CLIP_A1	0x00000040	/* d06:     A1 clipping enable */
#define	NOGO	0x00000080	/* d07:     diagnostic */
#define	UPDA1F	0x00000100	/* d08:     A1 update step fraction */
#define	UPDA1	0x00000200	/* d09:     A1 update step */
#define	UPDA2	0x00000400	/* d10:     A2 update step */
#define	DSTA2	0x00000800	/* d11:     reverse usage of A1 and A2 */
#define	GOURD	0x00001000	/* d12:     enable Gouraud shading */
#define	ZBUFF	0x00002000	/* d13:     polygon Z data updates */
#define	TOPBEN	0x00004000	/* d14:     intensity carry into byte */
#define	TOPNEN	0x00008000	/* d15:     intensity carry into nibble */
#define	PATDSEL	0x00010000	/* d16:     Select pattern data */
#define	ADDDSEL	0x00020000	/* d17:     diagnostic */
					/* d18-d20: Z comparator inhibit */
#define	ZMODELT	0x00040000	/* 	     source < destination */
#define	ZMODEEQ	0x00080000	/*	     source = destination */
#define	ZMODEGT	0x00100000	/*	     source > destination */
					/* d21-d24: Logic function control */
#define	LFU_NAN	0x00200000	/* 	     !source & !destination */
#define LFU_NA	0x00400000	/*	     !source &  destination */
#define LFU_AN	0x00800000	/* 	      source & !destination */
#define LFU_A	0x01000000	/* 	      source &  destination */

/* The following are ALL 16 possible logical operations of the LFUs */

#define	LFU_ZERO	0x00000000	/* All Zeros */
#define	LFU_NSAND	0x00200000	/* NOT Source AND NOT Destination */
#define	LFU_NSAD	0x00400000	/* NOT Source AND Destination */
#define	LFU_NOTS	0x00600000	/* NOT Source */
#define	LFU_SAND	0x00800000	/* Source AND NOT Destination */
#define	LFU_NOTD	0x00A00000	/* NOT Destination */
#define	LFU_N		0x00C00000	/* NOT (Source XOR Destination) */
#define	LFU_NSORND	0x00E00000	/* NOT Source OR NOT Destination */
#define	LFU_SAD		0x01000000	/* Source AND Destination */
#define	LFU_SXORD	0x01200000	/* Source XOR Destination */
#define	LFU_D		0x01400000	/* Destination */
#define	LFU_NSORD	0x01600000	/* NOT Source OR Destination */
#define	LFU_S		0x01800000	/* Source */
#define	LFU_SORND	0x01A00000	/* Source OR NOT Destination */
#define	LFU_SORD	0x01C00000	/* Source OR Destination */
#define	LFU_ONE		0x01E00000	/* All Ones */

/* These are some common combinations with less boolean names */

#define	LFU_REPLACE	0x01800000	/* Source REPLACEs destination */
#define	LFU_XOR		0x01200000	/* Source XOR with destination */
#define	LFU_CLEAR	0x00000000	/* CLEAR destination */

#define	CMPDST		0x02000000	/* d25:     pixel compare pattern & dest */
#define	BCOMPEN		0x04000000	/* d26:     bit compare write inhibit */
#define	DCOMPEN		0x08000000	/* d27:     data compare write inhibit */
#define	BKGWREN		0x10000000	/* d28:     data write back */
#define	BUSHI		0x20000000	/* d29	   blitter priority */
#define	SRCSHADE	0x40000000	/* d30:	   shade src data w/IINC value */
/*======================================================================*
;* BLITTER Flags (A1 or A2) register equates
;*======================================================================*/

/* Pitch d00-d01:
;	distance between pixel phrases */

#define	PITCH1		0x00000000	/* 0 phrase gap */
#define	PITCH2		0x00000001	/* 1 phrase gap */
#define	PITCH4		0x00000002	/* 3 phrase gap */
#define	PITCH3		0x00000003	/* 2 phrase gap */

/* Pixel d03-d05
;	bit depth (2^n) */
#define	PIXEL1		0x00000000	/* n = 0	0 color */
#define	PIXEL2		0x00000008	/* n = 1	2 colors */
#define	PIXEL4		0x00000010	/* n = 2	4 colors  */
#define	PIXEL8		0x00000018	/* n = 3	8 colors */
#define	PIXEL16		0x00000020	/* n = 4	16 colors */
#define	PIXEL32		0x00000028	/* n = 5	32 colors */

/* Z offset d06-d08
;	offset from phrase of pixel data from its corresponding
;	Z data phrases */
#define	ZOFFS0		0x00000000	/* offset = 0	UNUSED */
#define	ZOFFS1		0x00000040	/* offset = 1 */
#define	ZOFFS2		0x00000080	/* offset = 2 */
#define	ZOFFS3		0x000000C0	/* offset = 3 */
#define	ZOFFS4		0x00000100	/* offset = 4 */
#define	ZOFFS5		0x00000140	/* offset = 5 */
#define	ZOFFS6		0x00000180	/* offset = 6 */
#define	ZOFFS7		0x000001C0	/* offset = 7	UNUSED */

/* Width d09-d14
;	width used for address generation
;	This is a 6-bit floating point value in pixels
;	4-bit unsigned exponent
;	2-bit mantissa with implied 3rd bit of 1 */

#define	WID2		0x00000800	/* 1.00 X 2^1  ( 4<<9) */
#define	WID4 		0x00001000	/* 1.00 X 2^2  ( 8<<9) */
#define	WID6		0x00001400	/* 1.10 X 2^2  (10<<9) */
#define	WID8		0x00001800	/* 1.00 x 2^3  (12<<9) */
#define	WID10		0x00001A00	/* 1.01 X 2^3  (13<<9) */
#define	WID12		0x00001C00	/* 1.10 X 2^3  (14<<9) */
#define	WID14		0x00001E00	/* 1.11 X 2^3  (15<<9) */
#define	WID16		0x00002000	/* 1.00 X 2^4  (16<<9) */
#define	WID20		0x00002200	/* 1.01 X 2^4  (17<<9) */
#define	WID24		0x00002400	/* 1.10 X 2^4  (18<<9) */
#define	WID28		0x00002600	/* 1.11 X 2^4  (19<<9) */
#define	WID32		0x00002800	/* 1.00 X 2^5  (20<<9) */
#define	WID40		0x00002A00	/* 1.01 X 2^5  (21<<9) */
#define	WID48		0x00002C00	/* 1.10 X 2^5  (22<<9) */
#define	WID56		0x00002E00	/* 1.11 X 2^5  (23<<9) */
#define	WID64		0x00003000	/* 1.00 X 2^6  (24<<9) */
#define	WID80		0x00003200	/* 1.01 X 2^6  (25<<9) */
#define	WID96		0x00003400	/* 1.10 X 2^6  (26<<9) */
#define	WID112		0x00003600	/* 1.11 X 2^6  (27<<9) */
#define	WID128		0x00003800	/* 1.00 X 2^7  (28<<9) */
#define	WID160		0x00003A00	/* 1.01 X 2^7  (29<<9) */
#define	WID192		0x00003C00	/* 1.10 X 2^7  (30<<9) */
#define	WID224		0x00003E00	/* 1.11 X 2^7  (31<<9) */
#define	WID256		0x00004000	/* 1.00 X 2^8  (32<<9) */
#define	WID320		0x00004200	/* 1.01 X 2^8  (33<<9) */
#define	WID384		0x00004400	/* 1.10 X 2^8  (34<<9) */
#define	WID448		0x00004600	/* 1.11 X 2^8  (35<<9) */
#define	WID512		0x00004800	/* 1.00 X 2^9  (36<<9) */
#define	WID640		0x00004A00	/* 1.01 X 2^9  (37<<9) */
#define	WID768		0x00004C00	/* 1.10 X 2^9  (38<<9) */
#define	WID896		0x00004E00	/* 1.11 X 2^9  (39<<9) */
#define	WID1024		0x00005000	/* 1.00 X 2^10 (40<<9) */
#define	WID1280		0x00005200	/* 1.01 X 2^10 (41<<9) */
#define	WID1536		0x00005400	/* 1.10 X 2^10 (42<<9) */
#define	WID1792		0x00005600	/* 1.11 X 2^10 (43<<9) */
#define	WID2048		0x00005800	/* 1.00 X 2^11 (44<<9) */
#define	WID2560		0x00005A00	/* 1.01 X 2^11 (45<<9) */
#define	WID3072		0x00005C00	/* 1.10 X 2^11 (46<<9) */
#define	WID3584		0x00005E00	/* 1.11 X 2^11 (47<<9) */

/* X add control d16-d17
;	controls the update of the X pointer on each pass
;	round the inner loop */

#define	XADDPHR		0x00000000	/* 00 - add phrase width and truncate */
#define	XADDPIX		0x00010000	/* 01 - add pixel size (add 1)	 */
#define	XADD0		0x00020000	/* 10 - add zero */
#define	XADDINC		0x00030000	/* 11 - add the increment */

/* Y add control	d18
;	controls the update of the Y pointer within the inner loop.
;	it is overridden by the X add control if they are in add increment */

#define	YADD0		0x00000000	/* 00 - add zero */
#define	YADD1		0x00040000	/* 01 - add 1 */

/* X sign d19
;	add or subtract pixel size if X add control = 01 (XADDPIX) */
#define	XSIGNADD	0x00000000	/* 0 - add pixel size */
#define	XSIGNSUB	0x00080000	/* 1 - subtract pixel size */

/* X sign d20
;	add or subtract pixel size if X add control = 01 (YADD1) */
#define	YSIGNADD	0x00000000	/* 0 - add 1 */
#define	YSIGNSUB	0x00100000	/* 1 - sub 1 */

