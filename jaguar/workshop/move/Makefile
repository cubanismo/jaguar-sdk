
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

OBJ = mov_init.o mov_list.o mov_move.o
 
move.cof: $(OBJ)
	aln $(ALNFLAGS) -o move.cof $(OBJ) -i ..\\data\\jaguar.bin jagbits

mov_init.o: mov_init.s move.inc

mov_list.o: mov_list.s move.inc

mov_move.o: mov_move.s move.inc

