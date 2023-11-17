#include	<jaguar.h>
#include	"dhry.h"
#ifdef USE_SKUNK
#include    "skunk.h"
#endif
#ifdef	GOOF
#define	VERSION	"1.0"
#else
#define	VERSION	"1.1"
#endif
#define	BANNER	"Dhrystone - " VERSION

#define	Debugger()	asm("illegal"::)

typedef	unsigned	short	ushort;

extern	long	agpudhry_start,agpudhry_end;
extern	long	agpudhry_size;
extern	long	Proc0,Vbl;
volatile	long	LoopCount,VblCount=0L,DebugFlag=0L;
Char	Str0[]="DHRYSTONE PROGRAM, SOME STRING";
Char	Str1[]="DHRYSTONE PROGRAM, 1'ST STRING";
Char	Str2[]="DHRYSTONE PROGRAM, 2'ND STRING";
String30		String1Loc,String2Loc;

static	void	GPUExec(long *data,long size,long addr);
static	void	print(Char *str);
static	void	NbToDec(char *buf,ushort dec);
static	void	strcpy(Char *d,Char *s);
static	void	strcat(Char *d,Char *s);
static	int	strcmp(Char *d,Char *s);

void	Main(void)
{
	ushort	secs,dum1,dum2;
	long	*vbl=(void *)0x100,oldvbl;
	char	buf[80],buf2[80];

#ifdef USE_SKUNK
	skunkRESET();
	skunkNOP();
	skunkNOP();
#endif

	oldvbl=*vbl;
	*vbl=(long)&Vbl;
	GPUExec(&agpudhry_start,&agpudhry_end-&agpudhry_start,(long)&Proc0);
	while(LoopCount<LOOPS-1);
	*vbl=oldvbl;
	strcpy(buf,BANNER);
	strcat(buf,": time for ");
	NbToDec(buf2,LOOPS);
	strcat(buf,buf2);
	strcat(buf," passes = ");
	dum1=(ushort)VblCount;
	dum2=HZ;
	secs=dum1/dum2;
	NbToDec(buf2,secs);
	strcat(buf,buf2);
	strcat(buf," => -t -i ");
	dum1=LOOPS;
	NbToDec(buf2,dum1/secs);
	strcat(buf,buf2);
	strcat(buf," -r \" dhrystones/second.\"");
	print(buf);

#ifdef USE_SKUNK
	skunkCONSOLECLOSE();
#endif
}

static	void	NbToDec(char *buf,ushort dec)
{
	char	tmpbuf[20],*tmp=&tmpbuf[19];

	*tmp--=0;
	do {
		*tmp--=dec%10+'0';
		dec/=10;
	} while (dec);
	tmp++;
	while (*tmp)
		*buf++=*tmp++;
	*buf=0;
}

static	void	GPUExec(long *src,long size,long addr)
{
	long	*dst=(void *)G_RAM;
	volatile	long	*pc=(void *)G_PC;
	volatile	long	*ctrl=(void *)G_CTRL;

	while (size--)
		*dst++=*src++;
	*pc=addr;
	*ctrl=GPUGO;
}

static	void	print(Char *str)
{
#ifdef USE_SKUNK
	/* Ensure the string is word-aligned */
	strcpy(skunkstr, str);
	strcat(skunkstr, "\n");
	skunkCONSOLEWRITE(skunkstr);
#else
	/*
	 * Original code. I assume this implements logging on Alpine boards
	 * Needs to be ported to gasm syntax to work on SDK m68k compiler.
	 */
	asm("move%.l	%0,%-"::"m"(str));
	asm("move%.w	%0,%-"::"g"(0xf000));
	asm("move%.l	%0,%-"::"g"(0xb0005));
	asm("trap	%0"::"g"(14));
	asm("lea	10%@,sp"::);
#endif
}

static	void	strcpy(Char *d,Char *s)
{
	while (*d++=*s++);
}

static	void	strcat(Char *d,Char *s)
{
	while (*d)	d++;
	while (*d++=*s++);
}

static	int	strcmp(Char *d,Char *s)
{
	while (*d && *d==*s)
		d++,s++;
	return(*d-*s);
}
RecordType x1, x2;
/*
 * Package 1
 */
int		IntGlob;
boolean		BoolGlob;
Char		Char1Glob;
Char		Char2Glob;
Array1Dim	Array1Glob;
Array2Dim	Array2Glob;
RecordPtr	PtrGlb;
RecordPtr	PtrGlbNext;
