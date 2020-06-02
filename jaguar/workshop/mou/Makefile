include $(JAGSDK)/tools/build/jagdefs.mk

#====================================================================
#       EXECUTABLES
#====================================================================

OBJS = mou_init.o mou_list.o
PROGS = mou.cof
 
mou.cof: $(OBJS) ../data/jaguar.bin
	$(LINK) $(LINKFLAGS) -o $@ $(OBJS) -i ../data/jaguar.bin jagbits

mou_init.o: mou_init.s mou.inc

mou_list.o: mou_list.s mou.inc

include $(JAGSDK)/tools/build/jagrules.mk
