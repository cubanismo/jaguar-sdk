#====================================================================
#       Makefile for Cinepak sample programs
#====================================================================

#====================================================================
#       Macro & Assembler flags
#====================================================================

STADDR = 4000
ALNFLAGS = -l -rq -e -g -a $(STADDR) x x
MACFLAGS = -fb -rq

#====================================================================
#       Default Rules
#====================================================================

.SUFFIXES: .o .s

.s.o:
	mac $(MACFLAGS) $*

#====================================================================
#       EXECUTABLES
#====================================================================

cpkdemo.cof: startup.o player.o intserv.o utils.o clear.o\
		 makelist.o scalvars.o tocread.o dspcode.o grotate.o\
                 gpustart.o
	aln $(ALNFLAGS) -o cpkdemo.cof -c cpkdemo.lnk

startup.o: startup.s
player.o: player.s player.inc memory.inc makefile
intserv.o: intserv.s makefile
utils.o: utils.s player.inc memory.inc makefile
clear.o: clear.s player.inc memory.inc makefile
makelist.o: makelist.s player.inc memory.inc makefile
scalvars.o: scalvars.s player.inc memory.inc makefile
tocread.o: tocread.s makefile
dspcode.o: dspcode.s makefile
gpustart.o: gpustart.s makefile
grotate.o: grotate.s makefile

#====================================================================
#       EOF
#====================================================================
