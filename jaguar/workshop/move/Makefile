include $(JAGSDK)/tools/build/jagdefs.mk

#====================================================================
#       EXECUTABLES
#====================================================================

OBJS = mov_init.o mov_list.o mov_move.o
PROGS = move.cof
 
move.cof: $(OBJS) ../data/jaguar.bin
	$(LINK) $(LINKFLAGS) -o $@ $(OBJS) -i ../data/jaguar.bin jagbits

mov_init.o: mov_init.s move.inc

mov_list.o: mov_list.s move.inc

mov_move.o: mov_move.s move.inc

include $(JAGSDK)/tools/build/jagrules.mk
