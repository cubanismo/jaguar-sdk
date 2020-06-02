include $(JAGSDK)/tools/build/jagdefs.mk

OBJS = startup.o
PROGS = startup.cof
 
startup.cof: $(OBJS)
	$(LINK) $(LINKFLAGS) -o $@ $(OBJS)

startup.o: startup.s lt_box.rgb

include $(JAGSDK)/tools/build/jagrules.mk
