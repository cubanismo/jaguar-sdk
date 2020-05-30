
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

OBJ = clp_init.o clp_list.o clp_clip.o
 
clip.cof: $(OBJ)
	aln $(ALNFLAGS) -o clip.cof $(OBJ) -i ..\\data\\jaguar.bin jagbits

clp_init.o: clp_init.s clip.inc

clp_list.o: clp_list.s clip.inc

clp_clip.o: clp_clip.s clip.inc

