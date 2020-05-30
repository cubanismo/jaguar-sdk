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

OBJ = gpu_init.o gpu_list.o gpu_hndl.o
 
gpuint.cof: $(OBJ)
	aln $(ALNFLAGS) -o gpuint.cof $(OBJ) -i ..\\data\\jaguar.bin jagbits

gpu_init.o: gpu_init.s gpuint.inc

gpu_list.o: gpu_list.s gpuint.inc

gpu_hndl.o: gpu_hndl.s gpuint.inc
