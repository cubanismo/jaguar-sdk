include $(JAGSDK)/tools/build/jagdefs.mk

OBJS = rdbmsg.o
PROGS = rdbmsg.cof
 
rdbmsg.cof: $(OBJS)
	$(LINK) $(LINKFLAGS) -o $@ $(OBJS) 

include $(JAGSDK)/tools/build/jagrules.mk
