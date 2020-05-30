
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

OBJ = scl_init.o scl_list.o scl_scal.o
 
scale.cof: $(OBJ)
	aln $(ALNFLAGS) -o scale.cof $(OBJ) -i ..\\data\\jaguar.bin jagbits

scl_init.o: scl_init.s scale.inc

scl_list.o: scl_list.s scale.inc

scl_scal.o: scl_scal.s scale.inc

