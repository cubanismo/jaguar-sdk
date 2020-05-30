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

OBJ = cpk_init.o cpk_list.o cpk_blit.o cpk_loop.o crytable.o font.o
 
crypick.cof: $(OBJ)
	aln $(ALNFLAGS) -o crypick.cof $(OBJ)

cpk_init.o: cpk_init.s crypick.inc

cpk_list.o: cpk_list.s crypick.inc

cpk_blit.o: cpk_blit.s

cpk_loop.o: cpk_loop.s

crytable.o: crytable.s

font.o: font.s
