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

OBJ = mou_init.o mou_list.o
 
mou.cof: $(OBJ)
	aln $(ALNFLAGS) -o mou.cof $(OBJ) -i ..\\data\\jaguar.bin jagbits

mou_init.o: mou_init.s mou.inc

mou_list.o: mou_list.s mou.inc
