include $(JAGSDK)/tools/build/jagdefs.mk

JCP=~/jaguar/bin/jcp

OBJS = \
startup.o \
jag.o

PROGS = jaghello.cof

jaghello.cof: $(OBJS)
	$(LINK) $(LINKFLAGS) $(OBJS) -o $@


go:	$(PROGS)
	$(JCP) $(PROGS)

include $(JAGSDK)/tools/build/jagrules.mk
