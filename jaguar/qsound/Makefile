#====================================================================
#       Macro & Assembler flags
#====================================================================

STADDR = 802000 x 4000
MACFLAGS = -fb -g -rq
ALNFLAGS = -v -v -l -e -rq -g -a $(STADDR)

#====================================================================
#       Default Rules
#====================================================================
.SUFFIXES:      .o .s

.s.o:
	mac $(MACFLAGS) $<

.SUFFIXES:	.o .das

.das.o:
	mac $(MACFLAGS) $*.das

#====================================================================
#       EXECUTABLES
#====================================================================

OBJ = startup.o qdemo.o demo.o qpanner.o joypad.o
 
qdemo.cof: $(OBJ)
	aln $(ALNFLAGS) -o qdemo.cof $(OBJ)  -c qdemo.lnk

