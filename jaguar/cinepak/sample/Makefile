#====================================================================
#       Makefile for Cinepak sample programs
#====================================================================

include $(JAGSDK)/tools/build/jagdefs.mk

#====================================================================
# Delete option '-dUSE_CDROM' to run from DRAM
# For DRAM execution of film file use the following commands:
#
# aread player.abs
# read SYNC 3ffc0        
# read TALK.CPK 40000          << TALK.CPK, CINEJUL.CPK or SHAVE.CPK
# g4000
#
# Or on a skunkboard:
#
# jcp -n sync 0x3ffc0
# jcp -n TALK.CPK 0x40000      << TALK.CPK, SINEJUL.CPK or SHAVE.CPK
# jcp player.cof
#
#====================================================================

ASMFLAGS += -dUSE_CDROM

#====================================================================
#       Default Rules
#====================================================================

.SUFFIXES: .o .das

.das.o:
	$(ASM) $(ASMFLAGS) $*.das

#====================================================================
#       EXECUTABLES
#====================================================================

OBJS = player.o utils.o clear.o vidinit.o lister.o intserv.o dspcode.o

PROGS = player.cof

CINEPAK = ../decomp/gpucode.og ../decomp/codec.o

player.cof: $(OBJS) $(CINEPAK)
	$(LINK) $(LINKFLAGS) -o $@ $^

include $(JAGSDK)/tools/build/jagrules.mk
