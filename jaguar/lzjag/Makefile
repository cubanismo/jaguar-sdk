include $(JAGSDK)/tools/build/jagdefs.mk

#====================================================================
#       EXECUTABLES
#====================================================================

OBJS = testlzss.o delzjag.o
PROGS = testlzss.cof
 
testlzss.cof: $(OBJS)
	$(LINK) $(LINKFLAGS) -o $@ $^ -i mou.lzj moucode

*.o: Makefile

include $(JAGSDK)/tools/build/jagrules.mk
