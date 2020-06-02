include $(JAGSDK)/tools/build/jagdefs.mk

#====================================================================
#       EXECUTABLES
#====================================================================

OBJS = startup.o testrgb.o test.o
PROGS = testrgb.cof
 
testrgb.cof: $(OBJS)
	$(LINK) $(LINKFLAGS) -o $@ $(OBJS)

#############################################################################

startup.o: startup.s $(JAGSDK)/jaguar/source/sample.rgb

include $(JAGSDK)/tools/build/jagrules.mk
