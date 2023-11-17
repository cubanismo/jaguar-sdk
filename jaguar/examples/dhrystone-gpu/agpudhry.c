#include	"dhry.h"

extern	RecordType x1, x2;
/*
 * Package 1
 */
extern	int		IntGlob;
extern	boolean		BoolGlob;
extern	Char		Char1Glob;
extern	Char		Char2Glob;
extern	Array1Dim	Array1Glob;
extern	Array2Dim	Array2Glob;
extern	RecordPtr	PtrGlb;
extern	RecordPtr	PtrGlbNext;

extern	volatile	long	LoopCount,DebugFlag;
extern	Char	Str0[],Str1[],Str2[];
extern	String30	String1Loc,String2Loc;

#define	SETFLAG(x)	DebugFlag=x

void	Proc0();
static	int	strcmp(Char *d,Char *s);
static	void	strcpy(Char *d,Char *s);
static	void	Proc1(),Proc2(),Proc3(),Proc4(),Proc5(),Proc6(),Proc7(),Proc8();

void	Proc0()
{
	OneToFifty		IntLoc1;
	REG OneToFifty		IntLoc2;
	OneToFifty		IntLoc3;
	REG Char		CharLoc;
	REG Char		CharIndex;
	Enumeration	 	EnumLoc;

	register unsigned int	i;
dprintf("Proc0\n");
	DebugFlag=0L;
	PtrGlbNext = (RecordPtr) &x1;
	PtrGlb = (RecordPtr) &x2;
	PtrGlb->PtrComp = PtrGlbNext;
	PtrGlb->Discr = Ident1;
	PtrGlb->EnumComp = Ident3;
	PtrGlb->IntComp = 40;
	strcpy(PtrGlb->StringComp,Str0);	/* r2 bug */
#ifndef	GOOF
	strcpy(String1Loc,Str1);	/*GOOF*/
#endif
	Array2Glob[8][7] = 10;	/* Was missing in published program */

	for (i = 0; i != LOOPS; ++i) {
		Proc5();
		Proc4();
		IntLoc1 = 2;
		IntLoc2 = 3;
		strcpy(String2Loc,Str2);
		EnumLoc = Ident2;
		BoolGlob = ! Func2(String1Loc, String2Loc);
		while (IntLoc1 < IntLoc2) {
			IntLoc3 = 5 * IntLoc1 - IntLoc2;
			Proc7(IntLoc1, IntLoc2, &IntLoc3);
			++IntLoc1;
		}
		Proc8(Array1Glob, Array2Glob, IntLoc1, IntLoc3);
		SETFLAG(0x12345678);
		Proc1(PtrGlb);
		SETFLAG(0x87654321);
		for (CharIndex = 'A'; CharIndex <= Char2Glob; ++CharIndex)
			if (EnumLoc == Func1(CharIndex, 'C'))
				Proc6(Ident1, &EnumLoc);
		IntLoc3 = (unsigned short)IntLoc2 * (unsigned short)IntLoc1;
		IntLoc2 = IntLoc3 / IntLoc1;
		IntLoc2 = 7 * (IntLoc3 - IntLoc2) - IntLoc1;
		Proc2(&IntLoc1);
		LoopCount=i;
	}
}

void	Proc1(PtrParIn)
REG RecordPtr	PtrParIn;
{
#define	NextRecord	(*(PtrParIn->PtrComp))

dprintf("Proc1\n");
	structassign(NextRecord, *PtrGlb);
	PtrParIn->IntComp = 5;
	NextRecord.IntComp = PtrParIn->IntComp;
	NextRecord.PtrComp = PtrParIn->PtrComp;
	Proc3(NextRecord.PtrComp);
	if (NextRecord.Discr == Ident1)
	{
		NextRecord.IntComp = 6;
		Proc6(PtrParIn->EnumComp, &NextRecord.EnumComp);
		NextRecord.PtrComp = PtrGlb->PtrComp;
		Proc7(NextRecord.IntComp, 10, &NextRecord.IntComp);
	}
	else
		structassign(*PtrParIn, NextRecord);

#undef	NextRecord
}

void	Proc2(IntParIO)
OneToFifty	*IntParIO;
{
	REG OneToFifty		IntLoc;
	REG Enumeration		EnumLoc;

dprintf("Proc2\n");
	IntLoc = *IntParIO + 10;
	for(;;)
	{
		if (Char1Glob == 'A')
		{
			--IntLoc;
			*IntParIO = IntLoc - IntGlob;
			EnumLoc = Ident1;
		}
		if (EnumLoc == Ident1)
			break;
	}
}

void	Proc3(PtrParOut)
RecordPtr	*PtrParOut;
{
dprintf("Proc3\n");
	if (PtrGlb != NULL)
		*PtrParOut = PtrGlb->PtrComp;
	else
		IntGlob = 100;
	Proc7(10, IntGlob, &PtrGlb->IntComp);
}

void	Proc4()
{
	REG boolean	BoolLoc;

dprintf("Proc4\n");
	BoolLoc = Char1Glob == 'A';
	BoolLoc |= BoolGlob;
	Char2Glob = 'B';
}

void	Proc5()
{
dprintf("Proc5\n");
	Char1Glob = 'A';
	BoolGlob = FALSE;
}

extern boolean Func3();

void	Proc6(EnumParIn, EnumParOut)
REG Enumeration	EnumParIn;
REG Enumeration	*EnumParOut;
{
dprintf("Proc6\n");
	*EnumParOut = EnumParIn;
	if (! Func3(EnumParIn) )
		*EnumParOut = Ident4;
	switch (EnumParIn)
	{
	case Ident1:	*EnumParOut = Ident1; break;
	case Ident2:	if (IntGlob > 100) *EnumParOut = Ident1;
			else *EnumParOut = Ident4;
			break;
	case Ident3:	*EnumParOut = Ident2; break;
	case Ident4:	break;
	case Ident5:	*EnumParOut = Ident3;
	}
}

void	Proc7(IntParI1, IntParI2, IntParOut)
OneToFifty	IntParI1;
OneToFifty	IntParI2;
OneToFifty	*IntParOut;
{
	REG OneToFifty	IntLoc;

dprintf("Proc7\n");
	IntLoc = IntParI1 + 2;
	*IntParOut = IntParI2 + IntLoc;
}

void	Proc8(Array1Par, Array2Par, IntParI1, IntParI2)
Array1Dim	Array1Par;
Array2Dim	Array2Par;
OneToFifty	IntParI1;
OneToFifty	IntParI2;
{
	REG OneToFifty	IntLoc;
	REG OneToFifty	IntIndex;

dprintf("Proc8\n");
	IntLoc = IntParI1 + 5;
	Array1Par[IntLoc] = IntParI2;
	Array1Par[IntLoc+1] = Array1Par[IntLoc];
	Array1Par[IntLoc+30] = IntLoc;
	for (IntIndex = IntLoc; IntIndex <= (IntLoc+1); ++IntIndex)
		Array2Par[IntLoc][IntIndex] = IntLoc;
	++Array2Par[IntLoc][IntLoc-1];
	Array2Par[IntLoc+20][IntLoc] = Array1Par[IntLoc];
	IntGlob = 5;
}

Enumeration Func1(CharPar1, CharPar2)
CapitalLetter	CharPar1;
CapitalLetter	CharPar2;
{
	REG CapitalLetter	CharLoc1;
	REG CapitalLetter	CharLoc2;

dprintf("Func1\n");
	CharLoc1 = CharPar1;
	CharLoc2 = CharLoc1;
	if (CharLoc2 != CharPar2)
		return (Ident1);
	else
		return (Ident2);
}

boolean Func2(StrParI1, StrParI2)
String30	StrParI1;
String30	StrParI2;
{
	REG OneToThirty		IntLoc;
	REG CapitalLetter	CharLoc;

dprintf("Func2\n");
	IntLoc = 1;
	while (IntLoc <= 1)
		if (Func1(StrParI1[IntLoc], StrParI2[IntLoc+1]) == Ident1)
		{
			CharLoc = 'A';
			++IntLoc;
		}
	if (CharLoc >= 'W' && CharLoc <= 'Z')
		IntLoc = 7;
	if (CharLoc == 'X')
		return(TRUE);
	else
	{
		if (strcmp(StrParI1, StrParI2) > 0)
		{
			IntLoc += 7;
			return (TRUE);
		}
		else
			return (FALSE);
	}
}

boolean Func3(EnumParIn)
REG Enumeration	EnumParIn;
{
	REG Enumeration	EnumLoc;

dprintf("Func3\n");
	EnumLoc = EnumParIn;
	if (EnumLoc == Ident3) return (TRUE);
	return (FALSE);
}

#ifdef	NOSTRUCTASSIGN
memcpy(d, s, l)
register Char	*d;
register Char	*s;
register int	l;
{
	while (l--) *d++ = *s++;
}
#endif

static	void	strcpy(Char *d,Char *s)
{
	while (*d++=*s++);
}

static	int	strcmp(Char *d,Char *s)
{
	while (*d && *d==*s)
		d++,s++;
	return(*d-*s);
}
