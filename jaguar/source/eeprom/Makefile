#====================================================================
#       Makefile for DEMO CODE for erasing and readin EEPROM
#====================================================================

include $(JAGSDK)/tools/build/jagdefs.mk

#====================================================================
#       EXECUTABLES
#====================================================================

OBJS = test_e2.o eeprom.o
PROGS = test_e2.cof

test_e2.cof: $(OBJS)
	$(LINK) $(LINKFLAGS) -o $@ $(OBJS)

include $(JAGSDK)/tools/build/jagrules.mk
