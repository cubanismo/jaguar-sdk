#define NULL	0
/* Accuracy of timings and human fatigue controlled by next two lines */
#define LOOPS	60000		/* Use this for slow or 16 bit machines */
/* #define LOOPS	50000		/* Use this for slow or 16 bit machines */

/* Compiler dependent options */
/* #undef	NOENUM			/* Define if compiler has no enum's */
#undef	NOSTRUCTASSIGN		/* Define if compiler can't assign structures */
/* #define	NOSTRUCTASSIGN		/* Define if compiler can't assign structures */

/* define only one of the next three defines */
/*#define GETRUSAGE		/* Use getrusage(2) time function */
/* #define TIMES			/* Use times(2) time function */
/*#define TIME			/* Use time(2) time function */

/* define the granularity of your times(2) function (when used) */
#define HZ	60		/* times(2) returns 1/60 second (most) */
/*#define HZ	100		/* times(2) returns 1/100 second (WECo) */

/* for compatibility with goofed up version */
/*#define GOOF			/* Define if you want the goofed up version */

#ifdef	NOSTRUCTASSIGN
#define	structassign(d, s)	memcpy(&(d), &(s), sizeof(d))
#else
#define	structassign(d, s)	d = s
#endif

#ifdef	NOENUM
#define	Ident1	1
#define	Ident2	2
#define	Ident3	3
#define	Ident4	4
#define	Ident5	5
typedef int	Enumeration;
#else
typedef enum	{Ident1, Ident2, Ident3, Ident4, Ident5} Enumeration;
#endif

typedef int	OneToThirty;
typedef int	OneToFifty;
typedef	unsigned	char	Char;
typedef Char	CapitalLetter;
typedef Char	String30[31];
typedef int	Array1Dim[51];
typedef int	Array2Dim[51][51];

struct	Record
{
	struct Record		*PtrComp;
	Enumeration		Discr;
	Enumeration		EnumComp;
	OneToFifty		IntComp;
	String30		StringComp;
};

typedef struct Record 	RecordType;
typedef RecordType *	RecordPtr;
typedef int		boolean;

#define	TRUE		1
#define	FALSE		0

#ifndef REG
#define	REG
#endif

extern Enumeration	Func1();
extern boolean		Func2();
#ifdef USE_SKUNK
extern char		skunkstr[];
#endif

#ifdef DEBUG
#define dprintf printf
#else
#define dprintf(s)
#endif

void	printf(Char *str);
