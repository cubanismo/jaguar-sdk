include $(JAGSDK)/tools/build/jagdefs.mk

#====================================================================
#       EXECUTABLES
#====================================================================

OBJS = startup.o jagmand.o mandle.o calcmand.o
PROGS = jagmand.cof
 
jagmand.cof: $(OBJS)
	$(LINK) $(LINKFLAGS) -o $@ $(OBJS)

#############################################################################

startup.o: startup.s $(JAGSDK)/jaguar/source/sample.rgb

include $(JAGSDK)/tools/build/jagrules.mk
