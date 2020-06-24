#====================================================================
#       Makefile for Cinepak sample programs
#====================================================================

include $(JAGSDK)/tools/build/jagdefs.mk

#====================================================================
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

ASMFLAGS += -dUSE_CDROM     # Comment out to play movie from DRAM
#ASMFLAGS += -dENDLESS_LOOP # Uncomment to play movie in endless loop

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

CPK_DIR = $(JAGSDK)/jaguar/cinepak
CINEPAK = $(CPK_DIR)/decomp/gpucode.og $(CPK_DIR)/decomp/codec.o

player.cof: $(OBJS) $(CINEPAK)
	$(LINK) $(LINKFLAGS) -o $@ $^

include $(JAGSDK)/tools/build/jagrules.mk
