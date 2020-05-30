#====================================================================
#       Macro & Assembler flags
#====================================================================

STADDR = 802000
MACFLAGS = -fb -g
ALNFLAGS = -v -v -e -g -l -rd -a $(STADDR) x 4000

#====================================================================
#       Default Rules
#====================================================================
.SUFFIXES:      .o .s

.s.o:
	mac $(MACFLAGS) $*

#====================================================================
#       EXECUTABLES
#====================================================================

OBJ = jr_init.o jr_list.o jr_clr.o jr_grot.o jagpic.o
 
jr.cof: $(OBJ)
	aln $(ALNFLAGS) -o jr.cof $(OBJ)

jr_init.o: jr_init.s jr.inc

jr_list.o: jr_list.s jr.inc

jr_clr.o: jr_clr.s jr.inc

jr_grot.o: jr_grot.s jr.inc

jagpic.o: jagpic.s
