#====================================================================
#       Skunklib Makefile fragment
#====================================================================

SKUNKDIR = $(JAGSDK)/jaguar/skunk

# Can be used in code to detect presence of Skunkboard at build time.
ASMFLAGS += -dUSE_SKUNK
CDEFS += -DUSE_SKUNK
CINCLUDES += -I$(JAGSDK)/jaguar/skunk/include

skunk.o: $(SKUNKDIR)/lib/skunk.s $(SKUNKDIR)/include/skunk.inc
	$(ASM) $(ASMFLAGS) $< -o $@

OBJS += skunk.o
