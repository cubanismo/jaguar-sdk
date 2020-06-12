#====================================================================
#       Makefile for Cinepak sample programs
#====================================================================

include $(JAGSDK)/tools/build/jagdefs.mk

#====================================================================
#       EXECUTABLES
#====================================================================

OBJS = startup.o player.o intserv.o utils.o clear.o makelist.o \
	scalvars.o tocread.o dspcode.o grotate.o gpustart.o

PROGS = cpkdemo.cof

CINEPAK = ../decomp/gpucode.og ../decomp/codec.o

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
