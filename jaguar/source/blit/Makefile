#====================================================================
# Makefile	EXAMPLES
#====================================================================

include $(JAGSDK)/tools/build/jagdefs.mk

#====================================================================
#	EXECUTABLES
#====================================================================

COMMON = jagline.o intserv.o vidinit.o listbar.o clearbar.o
OBJS = $(COMMON) blitshad.o blitskew.o blitblck.o blitslnt.o blitline.o

PROGS = jagshad.cof jagskew.cof jagblck.cof jagslnt.cof jagline.cof

jagshad.cof: $(COMMON) blitshad.o
	$(LINK) $(LINKFLAGS) -o $@ $(COMMON) blitshad.o

jagskew.cof: $(COMMON) blitskew.o
	$(LINK) $(LINKFLAGS) -o $@ $(COMMON) blitskew.o

jagblck.cof: $(COMMON) blitblck.o
	$(LINK) $(LINKFLAGS) -o $@ $(COMMON) blitblck.o

jagslnt.cof: $(COMMON) blitslnt.o
	$(LINK) $(LINKFLAGS) -o $@ $(COMMON) blitslnt.o

jagline.cof: $(COMMON) blitline.o
	$(LINK) $(LINKFLAGS) -o $@ $(COMMON) blitline.o

include $(JAGSDK)/tools/build/jagrules.mk
