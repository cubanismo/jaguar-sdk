
STADDR = 4000
MACFLAGS = -fb -rq
ALNFLAGS = -v -v -rq -e -a $(STADDR) x x

#====================================================================

.SUFFIXES:      .o .s

.s.o:
	mac $(MACFLAGS) $<

#====================================================================

all: maketoc.cof usetoc.cof
 
maketoc.cof: maketoc.o
	aln $(ALNFLAGS) -o maketoc.cof maketoc.o

usetoc.cof: usetoc.o
	aln $(ALNFLAGS) -o usetoc.cof usetoc.o

