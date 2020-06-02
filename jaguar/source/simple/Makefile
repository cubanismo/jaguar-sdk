#====================================================================
# Makefile      SIMPLE
#====================================================================

include $(JAGSDK)/tools/build/jagdefs.mk

.SUFFIXES:      .oj .das

.das.oj:
	$(ASM) $(ASMFLAGS) -dmac=1 -o$*.oj $*.das

#====================================================================
#       EXECUTABLES
#====================================================================

OBJS = simple.o simpsyn.oj
PROGS = simple.cof

simple.cof: $(OBJS)
	$(LINK) $(LINKFLAGS) -o $@ $(OBJS)

include $(JAGSDK)/tools/build/jagrules.mk
