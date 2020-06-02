include $(JAGSDK)/tools/build/jagdefs.mk

#====================================================================
#       EXECUTABLES
#====================================================================

OBJS = cpk_init.o cpk_list.o cpk_blit.o cpk_loop.o crytable.o font.o
PROGS = crypick.cof
 
crypick.cof: $(OBJS)
	$(LINK) $(LINKFLAGS) -o $@ $(OBJS)

cpk_init.o: cpk_init.s crypick.inc

cpk_list.o: cpk_list.s crypick.inc

cpk_blit.o: cpk_blit.s

cpk_loop.o: cpk_loop.s

crytable.o: crytable.s

font.o: font.s

include $(JAGSDK)/tools/build/jagrules.mk
