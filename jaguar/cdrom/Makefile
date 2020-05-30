#====================================================================
#       Makefile for Cinepak sample programs
#====================================================================

#====================================================================
#       Macro & Assembler flags
#====================================================================

STADDR = 802000
ALNFLAGS = -l -rl -e -g -a $(STADDR) x 4000
MACFLAGS = -fb -rl

#====================================================================
#       Default Rules
#====================================================================

.SUFFIXES: .o .s

.s.o:
	mac $(MACFLAGS) $<

#====================================================================
#       EXECUTABLES
#====================================================================

all: cd_samp.cof cd_asamp.cof cd_switc.cof

cd_samp.cof: cd_samp.o cd_sampg.o makefile
	aln $(ALNFLAGS) -o cd_samp.cof cd_samp.o cd_sampg.o

cd_asamp.cof: cd_asamp.o inout.o makefile
	aln $(ALNFLAGS) -o cd_asamp.cof cd_asamp.o inout.o

cd_switc.cof: cd_switc.o inout.o makefile
	aln $(ALNFLAGS) -o cd_switc.cof cd_switch.o inout.o
