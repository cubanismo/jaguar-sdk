#====================================================================
# Makefile	EXAMPLES
#====================================================================

#====================================================================
#	Macro & Assembler flags
#====================================================================

STADDR = 802000
MACFLAGS = -fb 
ALNFLAGS = -e -v -rd -v -l -a $(STADDR) x 4000

#====================================================================
#	Default Rules
#====================================================================
.SUFFIXES:	.o .s

.s.o:
	smac $(MACFLAGS) $<

#====================================================================
#	EXECUTABLES
#====================================================================

COMMON = intserv.o vidinit.o listbar.o clearbar.o

all: jagshad.cof jagskew.cof jagblck.cof jagslnt.cof jagline.cof

jagshad.cof: jagline.o $(COMMON) blitshad.o
	aln $(ALNFLAGS) -o jagshad jagline.o $(COMMON) blitshad.o

jagskew.cof: jagline.o $(COMMON) blitskew.o
	aln $(ALNFLAGS) -o jagskew jagline.o $(COMMON) blitskew.o

jagblck.cof: jagline.o $(COMMON) blitblck.o
	aln $(ALNFLAGS) -o jagblck jagline.o $(COMMON) blitblck.o

jagslnt.cof: jagline.o $(COMMON) blitslnt.o
	aln $(ALNFLAGS) -o jagslnt jagline.o $(COMMON) blitslnt.o

jagline.cof: jagline.o $(COMMON) blitline.o
	aln $(ALNFLAGS) -o jagline jagline.o $(COMMON) blitline.o
