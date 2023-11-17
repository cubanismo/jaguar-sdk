include $(JAGSDK)/tools/build/jagdefs.mk

# Change this to 0 to build without the skunk console dependency.
# Things like printf won't work.
SKUNKLIB := 1

CGPUOBJS=agpudhry.o
OBJS=m68kmisc.o m68kdhry.o $(CGPUOBJS)

ifeq ($(SKUNKLIB),1)
	OBJS += skunkc.o skunk.o
endif

# Additional M68K CFLAGS
CFLAGS += -fno-builtin

# Additional AGPU CFLAGS
CFLAGS_JRISC += -v -fno-builtin

PROGS = dhry.cof

ifeq ($(SKUNKLIB),1)
	include $(JAGSDK)/jaguar/skunk/skunk.mk
endif

dhry.cof: $(OBJS)
	$(LINK) $(LINKFLAGS) -o $@ $(OBJS)

skunkc.o: $(SKUNKDIR)/lib/skunkc.s
	$(ASM) $(ASMFLAGS) -o $@ $<

include $(JAGSDK)/tools/build/jagrules.mk
