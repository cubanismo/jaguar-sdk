#====================================================================
#       Makefile for Cinepak sample programs
#====================================================================

#====================================================================
#       Macro & Assembler flags
#====================================================================

STADDR = 4000
ALNFLAGS = -v -v -g -e -l -a $(STADDR) x x

#====================================================================
# Delete option '-dUSE_CDROM' to run from DRAM
# For DRAM execution of film file use the following commands:
#
# aread player.abs
# read SYNC 3ffc0        
# read TALK.CPK 40000          << TALK.CPK, CINEJUL.CPK or SHAVE.CPK
# g4000
#====================================================================

MACFLAGS = -fb -g -dUSE_CDROM

#====================================================================
#       Default Rules
#====================================================================

.SUFFIXES: .o .s

.s.o:
	mac $(MACFLAGS) $<

.SUFFIXES: .od .das

.das.od:
	mac $(MACFLAGS) -o$*.od $*.das

#====================================================================
#       EXECUTABLES
#====================================================================

OBJ = player.o utils.o clear.o vidinit.o lister.o intserv.o dspcode.od

CINEPAK = gpucode.o codec.o

player.cof: $(OBJ) $(CINEPAK)
	aln $(ALNFLAGS) -c player.lnk
