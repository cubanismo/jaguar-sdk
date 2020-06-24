#====================================================================
#       Makefile for Cinepak sample programs
#====================================================================

include $(JAGSDK)/tools/build/jagdefs.mk

#====================================================================
#       Objects
#====================================================================

OBJS = startup.o player.o intserv.o utils.o clear.o makelist.o \
	scalvars.o tocread.o dspcode.o grotate.o gpustart.o

PROGS = cpkdemo.cof

CPK_DIR = $(JAGSDK)/jaguar/cinepak
CINEPAK = $(CPK_DIR)/decomp/gpucode.og $(CPK_DIR)/decomp/codec.o

#====================================================================
#       Skunk Library
#====================================================================

# Uncomment if running from Skunkboard.  Must be after defining OBJS
#include $(JAGSDK)/jaguar/skunk/skunk.mk

# Uncomment to use Skunkboard console messages
#ASMFLAGS += -dSKUNK_CONSOLE

# Uncomment to use verbose Skunkboard console messages.  These
# interfere with playback, but are useful when debugging.
#ASMFLAGS += -dSKUNK_CONSOLE_VERBOSE

#====================================================================
#       EXECUTABLES
#====================================================================

cpkdemo.cof: $(OBJS) $(CINEPAK)
	$(LINK) $(LINKFLAGS) -o $@ $^

startup.o: startup.s
player.o: player.s player.inc memory.inc Makefile
intserv.o: intserv.s Makefile
utils.o: utils.s player.inc memory.inc Makefile
clear.o: clear.s player.inc memory.inc Makefile
makelist.o: makelist.s player.inc memory.inc Makefile
scalvars.o: scalvars.s player.inc memory.inc Makefile
tocread.o: tocread.s Makefile
dspcode.o: dspcode.s Makefile
gpustart.o: gpustart.s Makefile
grotate.o: grotate.s Makefile

include $(JAGSDK)/tools/build/jagrules.mk
