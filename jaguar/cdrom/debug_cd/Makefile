# Use quad-phrase alignment
ALIGN=q

include $(JAGSDK)/tools/build/jagdefs.mk

OBJS = maketoc.o usetoc.o
PROGS = maketoc.cof usetoc.cof
 
maketoc.cof: maketoc.o
	$(LINK) $(LINKFLAGS) -o $@ $^

usetoc.cof: usetoc.o
	$(LINK) $(LINKFLAGS) -o $@ $^

*.o: Makefile

include $(JAGSDK)/tools/build/jagrules.mk
