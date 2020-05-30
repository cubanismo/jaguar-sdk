/*
 *
 *	JAGUAR.H  Hardware Equates for JAGUAR System
 *
 *	COPYRIGHT 1992-1994 Atari Computer Corporation
 *	UNAUTHORIZED REPRODUCTION, ADAPTATION, DISTRIBUTION,
 *	PERFORMANCE OR DISPLAY OF THIS COMPUTER PROGRAM OR
 *	THE ASSOCIATED AUDIOVISUAL WORK IS STRICTLY PROHIBITED.
 *	ALL RIGHTS RESERVED.
 *
 *     Last Modified: 9/02/94 - SDS
 */

/* GENERIC DEFINES */

#define DRAM		0x000000	/* Physical Start of RAM */
#define USERRAM	0x004000	/* Start of Available RAM */
#define ENDRAM		0x200000	/* End of RAM */
#define INITSTACK	(ENDRAM-4)	/* Recommended Stack Location */

/*
 * CPU REGISTERS
 */

#define LEVEL0		0x100		/* 68000 Level 0 Autovector */
#define USER0		0x100		/* Pseudonym */

/*
 * Masks for INT1 CPU Interrupt Control
 */

#define C_VIDENA	0x0001		/* Enable CPU Video Interrupts */
#define C_GPUENA	0x0002		/* Enable CPU GPU Interrupts */
#define C_OPENA	0x0004		/* Enable CPU OP Interrupts */
#define C_PITENA	0x0008		/* Enable CPU PIT Interrupts */
#define C_JERENA	0x0010		/* Enable CPU Jerry Interrupts */

#define C_VIDCLR	0x0100		/* Clear CPU Video Interrupts */
#define C_GPUCLR	0x0200		/* Clear CPU GPU Interrupts */
#define C_OPCLR	0x0400		/* Clear CPU OP Interrupts */
#define C_PITCLR	0x0800		/* Clear CPU PIT Interrupts */
#define C_JERCLR	0x1000		/* Clear CPU Jerry Interrupts */

/*
 * JAGUAR REGISTERS
 */

#define BASE		0xF00000	/* TOM Internal Register Base */

/*
 * TOM REGISTERS
 */

#define HC    		(short *)(BASE+4)	/* Horizontal Count */
#define VC    		(short *)(BASE+6)	/* Vertical Count */
#define LPH   		(short *)(BASE+8)	/* Horizontal Lightpen */
#define LPV   		(short *)(BASE+0x0A)	/* Vertical Lightpen */
#define OB0   		(short *)(BASE+0x10)	/* Current Object Phrase */
#define OB1   		(short *)(BASE+0x12)
#define OB2   		(short *)(BASE+0x14)
#define OB3   		(short *)(BASE+0x16)
#define OLP   		(long *)(BASE+0x20)	/* Object List Pointer */
#define OBF   		(short *)(BASE+0x26)	/* Object Processor Flag */
#define VMODE 		(short *)(BASE+0x28)	/* Video Mode */
#define BORD1 		(short *)(BASE+0x2A)	/* Border Color (Red & Green) */
#define BORD2 		(short *)(BASE+0x2C)	/* Border Color (Blue) */
#define HDB1  		(short *)(BASE+0x38)	/* Horizontal Display Begin One */
#define HDB2  		(short *)(BASE+0x3A)	/* Horizontal Display Begin Two */
#define HDE   		(short *)(BASE+0x3C)	/* Horizontal Display End */
#define VS    		(short *)(BASE+0x44)	/* Vertical Sync */
#define VDB   		(short *)(BASE+0x46)	/* Vertical Display Begin */
#define VDE   		(short *)(BASE+0x48)	/* Vertical Display End */
#define VI    		(short *)(BASE+0x4E)	/* Vertical Interrupt */
#define PIT0  		(short *)(BASE+0x50)	/* Programmable Interrupt Timer (Lo) */
#define PIT1  		(short *)(BASE+0x52)	/* Programmable Interrupt Timer (Hi) */
#define BG    		(short *)(BASE+0x58)	/* Background Color */

#define INT1  		(short *)(BASE+0xE0)	/* CPU Interrupt Control Register */
#define INT2  		(short *)(BASE+0xE2)	/* CPU Interrupt Resume Register */

#define CLUT  		(long *)(BASE+0x400)	/* Color Lookup Table */

#define LBUFA 		(long *)(BASE+0x800)	/* Line Buffer A */
#define LBUFB 		(long *)(BASE+0x1000)	/* Line Buffer B */
#define LBUFC 		(long *)(BASE+0x1800)	/* Line Buffer Current */

/*
 * OBJECT PROCESSOR EQUATES 
 */

#define BITOBJ		0		/* Bitmap Object Type */
#define SCBITOBJ	1		/* Scaled Bitmap Object Type */
#define GPUOBJ		2		/* GPU Interrupt Object Type */
#define BRANCHOBJ	3		/* Branch Object Type */
#define STOPOBJ	4		/* Stop Object Type */

#define O_REFLECT	0x00002000	/* OR with top LONG of BITMAP object */
#define O_RMW		0x00004000
#define O_TRANS	0x00008000
#define O_RELEASE	0x00010000

#define O_DEPTH1	(0<<12)		/* DEPTH Field for BITMAP objects */
#define O_DEPTH2	(1<<12)
#define O_DEPTH4	(2<<12)
#define O_DEPTH8	(3<<12)
#define O_DEPTH16	(4<<12)
#define O_DEPTH32	(5<<12)

#define O_NOGAP	(1<<15)		/* Phrase GAP between image phrases */
#define O_1GAP		(2<<15)
#define O_2GAP		(3<<15)
#define O_3GAP		(4<<15)
#define O_4GAP		(5<<15)
#define O_5GAP		(6<<15)
#define O_6GAP		(7<<15)

#define O_BREQ		(0<<14)		/* CC field of BRANCH objects */
#define O_BRGT		(1<<14)
#define O_BRLT		(2<<14)
#define O_BROP		(3<<14)
#define O_BRHALF	(4<<14)

#define O_STOPINTS	0x00000008	/* Enable Interrupts in STOP object */

/*
 * VIDEO INITIALIZATION CONSTANTS
 */

#define NTSC_WIDTH	1409		/* Width of screen in clocks */
#define NTSC_HMID	823		/* Middle of screen in clocks */
#define NTSC_HEIGHT	241		/* Height of screen in pixels */
#define NTSC_VMID	266		/* Middle of screen in half-lines */

#define PAL_WIDTH	1381		/* Same as above for PAL  */
#define PAL_HMID	843
#define PAL_HEIGHT	287
#define PAL_VMID	322

/* The following mask will extract the PAL/NTSC flag bit from the */
/* CONFIG register. NTSC = Bit Set, PAL = Bit Clear               */

#define VIDTYPE	0x10

/* The following are Video Mode Regiter Masks */

#define VIDEN		0x0001		/* Enable Video Interrupts */

#define CRY16		0x0000		/* 16-bit CRY mode */
#define RGB24		0x0002		/* 24-bit RGB mode */
#define DIRECT16	0x0004		/* 16-bit Direct mode */
#define RGB16		0x0006		/* 16-bit RGB mode */

#define GENLOCK	0x0008		/* Not supported on Jaguar Console */
#define INCEN		0x0010		/* Enable Encrustation */
#define BINC		0x0020		/* Select Local Border Color */
#define CSYNC		0x0040		/* Enable Composite Sync */
#define BGEN		0x0080		/* Clear Line Buffer to BG register */
#define VARMOD		0x0100		/* Enable Variable Resolution mode */

#define PWIDTH1	0x0000		/* Pixel Dividers */
#define PWIDTH2	0x0200
#define PWIDTH3	0x0400
#define PWIDTH4	0x0600
#define PWIDTH5	0x0800
#define PWIDTH6	0x0A00
#define PWIDTH7	0x0C00
#define PWIDTH8	0x0E00  

/*
 * GPU REGISTERS
 */

#define G_FLAGS 	(long *)(BASE+0x2100)	/* GPU Flags */
#define G_MTXC		(long *)(BASE+0x2104)	/* GPU Matrix Control */
#define G_MTXA		(long *)(BASE+0x2108)	/* GPU Matrix Address */
#define G_END		(long *)(BASE+0x210C)	/* GPU Data Organization */
#define G_PC		(long *)(BASE+0x2110)	/* GPU Program Counter */
#define G_CTRL		(long *)(BASE+0x2114)	/* GPU Operation Control/Status */
#define G_HIDATA 	(long *)(BASE+0x2118)	/* GPU Bus Interface high data */
#define G_REMAIN 	(long *)(BASE+0x211C)	/* GPU Division Remainder */
#define G_DIVCTRL 	(long *)(BASE+0x211C)  	/* GPU Divider control */
#define G_RAM		(long *)(BASE+0x3000)	/* GPU Internal RAM */
#define G_ENDRAM	(long *)(G_RAM+(4*1024))

/* GPU Flags Register Equates */

#define G_CPUENA	0x00000010	/* CPU Interrupt enable bits */
#define G_DSPENA	0x00000020	/* DSP Interrupt enable bits */
#define G_PITENA	0x00000040	/* PIT Interrupt enable bits */
#define G_OPENA	0x00000080	/* Object Processor Interrupt enable bits */
#define G_BLITENA	0x00000100	/* Blitter Interrupt enable bits */
#define G_CPUCLR	0x00000200	/* CPU Interrupt clear bits */
#define G_DSPCLR	0x00000400	/* DSP Interrupt clear bits */
#define G_PITCLR	0x00000800	/* PIT Interrupt clear bits */
#define G_OPCLR	0x00001000	/* Object Processor Interrupt clear bits */
#define G_BLITCLR	0x00002000	/* Blitter Interrupt clear bits */

/* GPU Control/Status Register */

#define GPUGO		0x00000001	/* Start and Stop the GPU */
#define GPUINT0	0x00000004	/* generate a GPU type 0 interrupt */

#define G_CPULAT	0x00000040	/* Interrupt Latches */
#define G_DSPLAT	0x00000080
#define G_PITLAT	0x00000100
#define G_OPLAT	0x00000200
#define G_BLITLAT	0x00000400

/*
 * BLITTER REGISTERS
 */

#define A1_BASE 	(long *)(BASE+0x2200)	/* A1 Base Address */
#define A1_FLAGS	(long *)(BASE+0x2204)	/* A1 Control Flags */
#define A1_CLIP	(long *)(BASE+0x2208)	/* A1 Clipping Size */
#define A1_PIXEL	(long *)(BASE+0x220C)	/* A1 Pixel Pointer */
#define A1_STEP	(long *)(BASE+0x2210)	/* A1 Step (Integer Part) */
#define A1_FSTEP	(long *)(BASE+0x2214)	/* A1 Step (Fractional Part) */
#define A1_FPIXEL	(long *)(BASE+0x2218)	/* A1 Pixel Pointer (Fractional) */
#define A1_INC		(long *)(BASE+0x221C)	/* A1 Increment (Integer Part) */
#define A1_FINC	(long *)(BASE+0x2220)	/* A1 Increment (Fractional Part) */
#define A2_BASE	(long *)(BASE+0x2224)	/* A2 Base Address */
#define A2_FLAGS	(long *)(BASE+0x2228)	/* A2 Control Flags */
#define A2_MASK	(long *)(BASE+0x222C)	/* A2 Address Mask */
#define A2_PIXEL	(long *)(BASE+0x2230)	/* A2 PIXEL */
#define A2_STEP	(long *)(BASE+0x2234)	/* A2 Step (Integer) */

#define B_CMD		(long *)(BASE+0x2238)	/* Command */
#define B_COUNT	(long *)(BASE+0x223C)	/* Counters */
#define B_SRCD		(long *)(BASE+0x2240)	/* Source Data */
#define B_DSTD		(long *)(BASE+0x2248)	/* Destination Data */
#define B_DSTZ		(long *)(BASE+0x2250)	/* Destination Z */
#define B_SRCZ1	(long *)(BASE+0x2258)	/* Source Z (Integer) */
#define B_SRCZ2	(long *)(BASE+0x2260)	/* Source Z (Fractional) */
#define B_PATD		(long *)(BASE+0x2268)	/* Pattern Data */
#define B_IINC		(long *)(BASE+0x2270)	/* Intensity Increment */
#define B_ZINC		(long *)(BASE+0x2274)	/* Z Increment */
#define B_STOP		(long *)(BASE+0x2278)	/* Collision stop control */

#define B_I3		(long *)(BASE+0x227C)	/* Blitter Intensity 3 */
#define B_I2		(long *)(BASE+0x2280)	/* Blitter Intensity 2 */
#define B_I1		(long *)(BASE+0x2284)	/* Blitter Intensity 1 */
#define B_I0		(long *)(BASE+0x2288)	/* Blitter Intensity 0 */

#define B_Z3		(long *)(BASE+0x228C)	/* Blitter Z 3 */
#define B_Z2		(long *)(BASE+0x2290)	/* Blitter Z 2 */
#define B_Z1		(long *)(BASE+0x2294)	/* Blitter Z 1 */
#define B_Z0		(long *)(BASE+0x2298)	/* Blitter Z 0 */

/* BLITTER Command Register defines */

#define SRCEN		0x00000001	/* d00:     source data read (inner loop) */
#define SRCENZ		0x00000002	/* d01:     source Z read (inner loop) */
#define SRCENX		0x00000004	/* d02:     source data read (realign) */
#define DSTEN		0x00000008	/* d03:     destination data read (inner loop) */
#define DSTENZ		0x00000010	/* d04:     destination Z read (inner loop) */
#define DSTWRZ		0x00000020	/* d05:     destination Z write (inner loop) */
#define CLIP_A1	0x00000040	/* d06:     A1 clipping enable */
#define UPDA1F		0x00000100	/* d08:     A1 update step fraction */
#define UPDA1		0x00000200	/* d09:     A1 update step */
#define UPDA2		0x00000400	/* d10:     A2 update step */
#define DSTA2		0x00000800	/* d11:     reverse usage of A1 and A2 */
#define GOURD		0x00001000	/* d12:     enable Gouraud shading */
#define ZBUFF		0x00002000	/* d13:     polygon Z data updates */
#define TOPBEN		0x00004000	/* d14:     intensity carry into byte */
#define TOPNEN		0x00008000	/* d15:     intensity carry into nibble */
#define PATDSEL	0x00010000	/* d16:     Select pattern data */
#define ADDDSEL	0x00020000	/* d17:     diagnostic */
					/* d18-d20: Z comparator inhibit */
#define ZMODELT	0x00040000	/* 	     source < destination */
#define ZMODEEQ	0x00080000	/*	     source = destination */
#define ZMODEGT	0x00100000	/*	     source > destination */
					/* d21-d24: Logic function control */
#define LFU_NAN	0x00200000	/* 	     !source & !destination */
#define LFU_NA		0x00400000	/* 	     !source &  destination */
#define LFU_AN		0x00800000	/* 	      source & !destination */
#define LFU_A		0x01000000	/* 	      source &  destination */
#define CMPDST		0x02000000	/* d25:     pixel compare pattern & dest */
#define BCOMPEN	0x04000000	/* d26:     bit compare write inhibit */
#define DCOMPEN	0x08000000	/* d27:     data compare write inhibit */
#define BKGWREN	0x10000000	/* d28:     data write back */
#define BUSHI		0x20000000	/* d29	   blitter priority */
#define SRCSHADE	0x40000000	/* d30:	   shade src data w/IINC value */

/* The following are ALL 16 possible logical operations of the LFUs */

#define LFU_ZERO	0x00000000	/* All Zeros */
#define LFU_NSAND	0x00200000	/* NOT Source AND NOT Destination */
#define LFU_NSAD	0x00400000	/* NOT Source AND Destination */
#define LFU_NOTS	0x00600000	/* NOT Source */
#define LFU_SAND	0x00800000	/* Source AND NOT Destination */
#define LFU_NOTD	0x00A00000	/* NOT Destination */
#define LFU_N_SXORD	0x00C00000	/* NOT (Source XOR Destination) */
#define LFU_NSORND	0x00E00000	/* NOT Source OR NOT Destination */
#define LFU_SAD	0x01000000	/* Source AND Destination */
#define LFU_SXORD	0x01200000	/* Source XOR Destination */
#define LFU_D		0x01400000	/* Destination */
#define LFU_NSORD	0x01600000	/* NOT Source OR Destination */
#define LFU_S		0x01800000	/* Source */
#define LFU_SORND	0x01A00000	/* Source OR NOT Destination */
#define LFU_SORD	0x01C00000	/* Source OR Destination */
#define LFU_ONE	0x01E00000	/* All Ones */

/* These are some common combinations with less boolean names */

#define LFU_REPLACE	0x01800000	/* Source REPLACEs destination */
#define LFU_XOR	0x01200000	/* Source XOR with destination */
#define LFU_CLEAR	0x00000000	/* CLEAR destination */

/* BLITTER Flags (A1 or A2) register defines */

/* Pitch d00-d01:
	distance between pixel phrases */
#define PITCH1		0x00000000	/* 0 phrase gap */
#define PITCH2		0x00000001	/* 1 phrase gap */
#define PITCH4		0x00000002	/* 3 phrase gap */
#define PITCH3		0x00000003	/* 2 phrase gap */

/* Pixel d03-d05
	bit depth (2^n) */
#define PIXEL1		0x00000000	/* n = 0 */
#define PIXEL2		0x00000008	/* n = 1 */
#define PIXEL4		0x00000010	/* n = 2 */
#define PIXEL8		0x00000018	/* n = 3 */
#define PIXEL16	0x00000020	/* n = 4 */
#define PIXEL32	0x00000028	/* n = 5 */

/* Z offset d06-d08
	offset from phrase of pixel data from its corresponding
	Z data phrases	*/
#define ZOFFS0		0x00000000	/* offset = 0	UNUSED */
#define ZOFFS1		0x00000040	/* offset = 1 */
#define ZOFFS2		0x00000080	/* offset = 2 */
#define ZOFFS3		0x000000C0	/* offset = 3 */
#define ZOFFS4		0x00000100	/* offset = 4 */
#define ZOFFS5		0x00000140	/* offset = 5 */
#define ZOFFS6		0x00000180	/* offset = 6 */
#define ZOFFS7		0x000001C0	/* offset = 7	UNUSED */

/* Width d09-d14
	width used for address generation
	This is a 6-bit floating point value in pixels
	4-bit unsigned exponent
	2-bit mantissa with implied 3rd bit of 1	*/
#define WID2		0x00000800	/* 1.00 X 2^1  ( 4<<9) */
#define WID4 		0x00001000	/* 1.00 X 2^2  ( 8<<9) */
#define WID6		0x00001400	/* 1.10 X 2^2  (10<<9) */
#define WID8		0x00001800	/* 1.00 x 2^3  (12<<9) */
#define WID10		0x00001A00	/* 1.01 X 2^3  (13<<9) */
#define WID12		0x00001C00	/* 1.10 X 2^3  (14<<9) */
#define WID14		0x00001E00	/* 1.11 X 2^3  (15<<9) */
#define WID16		0x00002000	/* 1.00 X 2^4  (16<<9) */
#define WID20		0x00002200	/* 1.01 X 2^4  (17<<9) */
#define WID24		0x00002400	/* 1.10 X 2^4  (18<<9) */
#define WID28		0x00002600	/* 1.11 X 2^4  (19<<9) */
#define WID32		0x00002800	/* 1.00 X 2^5  (20<<9) */
#define WID40		0x00002A00	/* 1.01 X 2^5  (21<<9) */
#define WID48		0x00002C00	/* 1.10 X 2^5  (22<<9) */
#define WID56		0x00002E00	/* 1.11 X 2^5  (23<<9) */
#define WID64		0x00003000	/* 1.00 X 2^6  (24<<9) */
#define WID80		0x00003200	/* 1.01 X 2^6  (25<<9) */
#define WID96		0x00003400	/* 1.10 X 2^6  (26<<9) */
#define WID112		0x00003600	/* 1.11 X 2^6  (27<<9) */
#define WID128		0x00003800	/* 1.00 X 2^7  (28<<9) */
#define WID160		0x00003A00	/* 1.01 X 2^7  (29<<9) */
#define WID192		0x00003C00	/* 1.10 X 2^7  (30<<9) */
#define WID224		0x00003E00	/* 1.11 X 2^7  (31<<9) */
#define WID256		0x00004000	/* 1.00 X 2^8  (32<<9) */
#define WID320		0x00004200	/* 1.01 X 2^8  (33<<9) */
#define WID384		0x00004400	/* 1.10 X 2^8  (34<<9) */
#define WID448		0x00004600	/* 1.11 X 2^8  (35<<9) */
#define WID512		0x00004800	/* 1.00 X 2^9  (36<<9) */
#define WID640		0x00004A00	/* 1.01 X 2^9  (37<<9) */
#define WID768		0x00004C00	/* 1.10 X 2^9  (38<<9) */
#define WID896		0x00004E00	/* 1.11 X 2^9  (39<<9) */
#define WID1024	0x00005000	/* 1.00 X 2^10 (40<<9) */
#define WID1280	0x00005200	/* 1.01 X 2^10 (41<<9) */
#define WID1536	0x00005400	/* 1.10 X 2^10 (42<<9) */
#define WID1792	0x00005600	/* 1.11 X 2^10 (43<<9) */
#define WID2048	0x00005800	/* 1.00 X 2^11 (44<<9) */
#define WID2560	0x00005A00	/* 1.01 X 2^11 (45<<9) */
#define WID3072	0x00005C00	/* 1.10 X 2^11 (46<<9) */
#define WID3584	0x00005E00	/* 1.11 X 2^11 (47<<9) */

/* X add control d16-d17
	controls the update of the X pointer on each pass
	round the inner loop */
#define XADDPHR	0x00000000	/* 00 - add phrase width and truncate */
#define XADDPIX	0x00010000	/* 01 - add pixel size (add 1)	 */
#define XADD0		0x00020000	/* 10 - add zero */
#define XADDINC	0x00030000	/* 11 - add the increment */

/* Y add control	d18
	controls the update of the Y pointer within the inner loop.
	it is overridden by the X add control if they are in add increment */
#define YADD0		0x00000000	/* 00 - add zero */
#define YADD1		0x00040000	/* 01 - add 1 */

/* X sign d19
	add or subtract pixel size if X add control = 01 (XADDPIX) */
#define XSIGNADD	0x00000000	/* 0 - add pixel size */
#define XSIGNSUB	0x00080000	/* 1 - subtract pixel size */

/* Y sign d20
	add or subtract pixel size if Y add control = 01 (YADD1) */
#define YSIGNADD	0x00000000	/* 0 - add 1 */
#define YSIGNSUB	0x00100000	/* 1 - sub 1 */


/*
 * JERRY REGISTERS
 */

#define JPIT1		(long *)(BASE+0x10000)	/* Timer 1 Pre-Scaler */
#define JPIT2		(long *)(BASE+0x10002)	/* Timer 1 Divider */
#define JPIT3		(long *)(BASE+0x10004)	/* Timer 2 Pre-Scaler */
#define JPIT4		(long *)(BASE+0x10006)	/* Timer 2 Divider */

#define J_INT          (long *)(BASE+0x10020)	/* Jerry Interrupt control (to TOM) */
		
#define JOYSTICK       (long *)(BASE+0x14000)	/* Joystick register and mute */
#define JOYBUTS	(long *)(BASE+0x14002)	/* Joystick register */
#define CONFIG		(long *)(BASE+0x14002)	/* Also has NTSC/PAL */

#define MOD_MASK	(long *)(BASE+0x1A118)	/* Mask for ADDQ(SUBQ)MOD */

#define SCLK		(long *)(BASE+0x1A150)	/* SSI Clock Frequency */
#define SMODE		(long *)(BASE+0x1A154)	/* SSI Control */

#define L_I2S		(long *)(BASE+0x1A148)	/* Left I2S Serial */	
#define R_I2S		(long *)(BASE+0x1A14C)	/* Right I2S Serial */

/*
 * Jerry Interrupt Control Flags
 */

#define J_EXTENA	0x0001		/* Enable Jerry External Ints */
#define J_DSPENA	0x0002		/* Enable Jerry DSP Ints */
#define J_TIM1ENA	0x0004		/* Enable Jerry Timer 1 Ints */
#define J_TIM2ENA	0x0008		/* Enable Jerry Timer 2 Ints */
#define J_ASYNENA	0x0010		/* Enable Jerry Asynch Serial Ints */
#define J_SYNENA	0x0020		/* Enable Jerry Synch Serial Ints */

#define J_EXTCLR	0x0100		/* Clear Pending External Ints */
#define J_DSPCLR	0x0200		/* Clear Pending DSP Ints */
#define J_TIM1CLR	0x0400		/* Clear Pending Timer 1 Ints */
#define J_TIM2CLR	0x0800		/* Clear Pending Timer 2 Ints */
#define J_ASYNCLR	0x1000		/* Clear Pending Asynch Serial Ints */
#define J_SYNCLR	0x2000		/* Clear Pending Synch Serial Ints */

/*
 * Joystick Equates
 *
 * Bits when LONGword is formatted as below (from JOYTEST\JT_LOOP.S).
 * Format: xxApxxBx RLDU147* xxCxxxox 2580369#
 */

#define JOY_UP		20		/*joypad */
#define JOY_DOWN	21
#define JOY_LEFT	22
#define JOY_RIGHT	23

#define FIRE_A		29		/*fire buttons */
#define FIRE_B		25
#define FIRE_C		13
#define OPTION		9
#define PAUSE		28

#define KEY_STAR	16		/*keypad */
#define KEY_7		17
#define KEY_4		18
#define KEY_1		19

#define KEY_0		4
#define KEY_8		5
#define KEY_5		6
#define KEY_2		7

#define KEY_HASH	0
#define KEY_9		1
#define KEY_6		2
#define KEY_3		3

#define ANY_JOY	0x00F00000	/* AND joyedge with this - joypad was pressed if result is not 0 */
#define ANY_FIRE	0x32002200	/* AND joyedge with this - A,B C, Option or Pause was pressed if result is not 0 */
#define ANY_KEY	0x000F00FF	/* AND joyedge with this - 123456789*0# was pressed if result is not 0 */

/*
 *	ROM Tables built into Jerry - 128 samples each
 *	16 bit samples sign extended to 32
 */

#define ROM_TABLE   	(long *)(BASE+0x1D000)	/* Base of tables */

#define ROM_TRI     	(long *)(BASE+0x1D000)	/* A triangle wave */
#define ROM_SINE    	(long *)(BASE+0x1D200)	/* Full amplitude SINE */
#define ROM_AMSINE  	(long *)(BASE+0x1D400)	/* Linear (?) ramp SINE */
#define ROM_12W 	(long *)(BASE+0x1D600)	/* SINE(X)+SINE(2*X) : (was ROM_SINE12W) */
#define ROM_CHIRP16 	(long *)(BASE+0x1D800)	/* SHORT SWEEP */
#define ROM_NTRI    	(long *)(BASE+0x1DA00)	/* Triangle w/NOISE */
#define ROM_DELTA   	(long *)(BASE+0x1DC00)	/* Positive spike */
#define ROM_NOISE   	(long *)(BASE+0x1DE00)	/* Noise */

/*
 * JERRY Registers (DSP)
 */

#define D_FLAGS	(long *)(BASE+0x1A100)	/* DSP Flags */
#define D_MTXC		(long *)(BASE+0x1A104)	/* DSP Matrix Control */
#define D_MTXA		(long *)(BASE+0x1A108)	/* DSP Matrix Address */
#define D_END		(long *)(BASE+0x1A10C)	/* DSP Data Organization */
#define D_PC		(long *)(BASE+0x1A110)	/* DSP Program Counter */
#define D_CTRL		(long *)(BASE+0x1A114)	/* DSP Operation Control/Status */
#define D_MOD          (long *)(BASE+0x1A118)  /* DSP Modulo Instruction Mask */
#define D_REMAIN 	(long *)(BASE+0x1A11C)	/* DSP Division Remainder */
#define D_DIVCTRL 	(long *)(BASE+0x1A11C)	/* DSP Divider control */
#define D_MACHI        (long *)(BASE+0x1A120)  /* DSP Hi byte of MAC operations */
#define D_RAM		(long *)(BASE+0x1B000)	/* DSP Internal RAM */
#define D_ENDRAM	(long *)(D_RAM+(8*1024))

/*
 * JERRY Flag Register Equates
 */

#define D_CPUENA	0x00000010	/* CPU Interrupt Enable Bit */
#define D_I2SENA	0x00000020	/* I2S Interrupt Enable Bit */
#define D_TIM1ENA	0x00000040	/* Timer 1 Interrupt Enable Bit */
#define D_TIM2ENA	0x00000080	/* Timer 2 Interrupt Enable Bit */
#define D_EXT0ENA	0x00000100	/* External Interrupt 0 Enable Bit */
#define D_EXT1ENA	0x00010000	/* External Interrupt 1 Enable Bit */

#define D_CPUCLR	0x00000200	/* CPU Interrupt Clear Bit */
#define D_I2SCLR	0x00000400	/* I2S Interrupt Clear Bit */
#define D_TIM1CLR	0x00000800	/* Timer 1 Interrupt Clear Bit */
#define D_TIM2CLR	0x00001000	/* Timer 2 Interrupt Clear Bit */
#define D_EXT0CLR	0x00002000	/* External Interrupt 0 Clear Bit */
#define D_EXT1CLR	0x00020000	/* External Interrupt 1 Clear Bit */

/*
 * JERRY Control/Status Register
 */

#define DSPGO		0x00000001	/* Start DSP */
#define DSPINT0	0x00000004	/* Generate a DSP Interrupt 0 */

#define D_CPULAT	0x00000040	/* Interrupt Latches */
#define D_I2SLAT	0x00000080
#define D_TIM1LAT	0x00000100
#define D_TIM2LAT	0x00000200
#define D_EXT1LAT	0x00000400
#define D_EXT2LAT	0x00010000

/*
 * JERRY Modulo Instruction Masks
 */

#define MODMASK2	0xFFFFFFFE	/* 2 byte circular buffer */
#define MODMASK4	0xFFFFFFFC	/* 4 byte circular buffer */
#define MODMASK8	0xFFFFFFF8	/* 8 byte circular buffer */
#define MODMASK16	0xFFFFFFF0	/* 16 byte circular buffer */
#define MODMASK32	0xFFFFFFE0	/* 32 byte circular buffer */
#define MODMASK64	0xFFFFFFC0	/* 64 byte circular buffer */
#define MODMASK128	0xFFFFFF80     	/* 128 byte circular buffer */
#define MODMASK256	0xFFFFFF00	/* 256 byte circular buffer */
#define MODMASK512	0xFFFFFE00	/* 512 byte circular buffer */
#define MODMASK1K	0xFFFFFC00	/* 1k circular buffer  */
#define MODMASK2K	0xFFFFF800	/* 2k circular buffer */
#define MODMASK4K	0xFFFFF000	/* 4k circular buffer */
#define MODMASK8K	0xFFFFE000	/* 8k circular buffer */
#define MODMASK16K	0xFFFFC000	/* 16k circular buffer */
#define MODMASK32K	0xFFFF8000	/* 32k circular buffer */
#define MODMASK64K	0xFFFF0000	/* 64k circular buffer */
#define MODMASK128K	0xFFFE0000	/* 128k circular buffer */
#define MODMASK256K	0xFFFC0000	/* 256k circular buffer */
#define MODMASK512K	0xFFF80000	/* 512k circular buffer */
#define MODMASK1M	0xFFF00000	/* 1M circular buffer */
	
/*
 * SHARED Equates for TOM (GPU) and JERRY (DSP)
 */

/* Control/Status Registers */

#define RISCGO		0x00000001	/* Start GPU or DSP */
#define CPUINT		0x00000002	/* Allow the GPU/DSP to interrupt CPU */
#define FORCEINT0	0x00000004	/* Cause an INT 0 on GPU or DSP */
#define SINGLE_STEP	0x00000008	/* Enter SINGLE_STEP mode */
#define SINGLE_GO	0x00000010	/* Execute one instruction */

#define REGPAGE	0x00004000	/* Register Bank Select */
#define DMAEN  	0x00008000	/* Enable DMA LOAD and STORE */

/* Flags Register */

#define ZERO_FLAG	0x00000001	/* ALU Zero Flag */
#define CARRY_FLAG	0x00000002	/* ALU Carry Flag */
#define NEGA_FLAG	0x00000004	/* ALU Negative Flag */

#define IMASK		0x00000008	/* Interrupt Service Mask */

/* Matrix Control Register */

#define MATRIX3	0x00000003	/* use for 3x1 Matrix */
#define MATRIX4	0x00000004	/* etc... */
#define MATRIX5	0x00000005
#define MATRIX6	0x00000006
#define MATRIX7	0x00000007
#define MATRIX8	0x00000008
#define MATRIX9	0x00000009
#define MATRIX10	0x0000000A
#define MATRIX11	0x0000000B
#define MATRIX12	0x0000000C
#define MATRIX13	0x0000000D
#define MATRIX14	0x0000000E
#define MATRIX15	0x0000000F

#define MATROW		0x00000000	/* Access Matrix by Row */
#define MATCOL		0x00000010	/* Access Matrix by Column */

/* Data Organisation Register */

#define BIG_IO		0x00010001	/* Make I/O Big-Endian */
#define BIG_PIX	0x00020002	/* Access Pixels in Big-Endian */
#define BIG_INST	0x00040004	/* Fetch Instructions in Big-Endian */

/* Divide Unit Control */

#define DIV_OFFSET	0x00000001	/* Divide 16.16 values if set */

/*******/
/* EOF */
/*******/
