include $(JAGSDK)/tools/build/jagdefs.mk

#====================================================================
#       EXECUTABLES
#====================================================================

OBJS = jr_init.o jr_list.o jr_clr.o jr_grot.o jagpic.o
PROGS = jr.cof
 
jr.cof: $(OBJS)
	$(LINK) $(LINKFLAGS) -o $@ $(OBJS)

jr_init.o: jr_init.s jr.inc

jr_list.o: jr_list.s jr.inc

jr_clr.o: jr_clr.s jr.inc

jr_grot.o: jr_grot.s jr.inc

jagpic.o: jagpic.s

include $(JAGSDK)/tools/build/jagrules.mk
