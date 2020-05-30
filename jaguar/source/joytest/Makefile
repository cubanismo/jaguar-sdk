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
	mac $(MACFLAGS) $<

#====================================================================
#       EXECUTABLES
#====================================================================

OBJ = jt_init.o jt_list.o jt_loop.o
 
joytest.cof: $(OBJ)
	aln $(ALNFLAGS) -o joytest.cof $(OBJ)

jt_init.o: jt_init.s joytest.inc

jt_list.o: jt_list.s joytest.inc

jt_loop.o: jt_loop.s joytest.inc
