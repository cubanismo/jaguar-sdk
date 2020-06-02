include $(JAGSDK)/tools/build/jagdefs.mk

#====================================================================
#       EXECUTABLES
#====================================================================

OBJS = scl_init.o scl_list.o scl_scal.o

PROGS = scale.cof
 
scale.cof: $(OBJS) ../data/jaguar.bin
	$(LINK) $(LINKFLAGS) -o $@ $(OBJS) -i ../data/jaguar.bin jagbits

scl_init.o: scl_init.s scale.inc

scl_list.o: scl_list.s scale.inc

scl_scal.o: scl_scal.s scale.inc

include $(JAGSDK)/tools/build/jagrules.mk
