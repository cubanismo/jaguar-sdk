include $(JAGSDK)/tools/build/jagdefs.mk

#====================================================================
#       EXECUTABLES
#====================================================================

OBJS = clp_init.o clp_list.o clp_clip.o
PROGS = clip.cof
 
clip.cof: $(OBJS) ../data/jaguar.bin
	$(LINK) $(LINKFLAGS) -o $@ $(OBJS) -i ../data/jaguar.bin jagbits

clp_init.o: clp_init.s clip.inc

clp_list.o: clp_list.s clip.inc

clp_clip.o: clp_clip.s clip.inc

include $(JAGSDK)/tools/build/jagrules.mk
