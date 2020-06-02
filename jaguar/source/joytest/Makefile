include $(JAGSDK)/tools/build/jagdefs.mk

#====================================================================
#       EXECUTABLES
#====================================================================

OBJS = jt_init.o jt_list.o jt_loop.o
PROGS = joytest.cof
 
joytest.cof: $(OBJS)
	$(LINK) $(LINKFLAGS) -o joytest.cof $(OBJS)

jt_init.o: jt_init.s joytest.inc

jt_list.o: jt_list.s joytest.inc

jt_loop.o: jt_loop.s joytest.inc

include $(JAGSDK)/tools/build/jagrules.mk
