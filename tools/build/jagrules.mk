#====================================================================
#       Default Rules
#====================================================================

all: $(PROGS)

.SUFFIXES: .o .s .c

.s.o:
	$(ASM) $(ASMFLAGS) $<

.c.o:
	$(CC) $(CDEFS) $(CINCLUDES) $(CFLAGS) -c -o $@ $<

.c.s:
	$(CC) $(CDEFS) $(CINCLUDES) $(CFLAGS) -S -o $@ $<

# Apply a few patches to the GPU C compiler's assembly output:
#
# -Fix the alignment of variables defined in GPU memory
#
# -Add a symbol defining the GPU base address of the object file's code.
#
# Note these don't handle filenames with illegal symbol characters in them.
# That's OK, because the similar logic in the GPU C compiler doesn't either!
$(CGPUOBJS):%o:%c
	$(CC_JRISC) $(CDEFS) $(CINCLUDES) $(CFLAGS_JRISC) -o $(patsubst %.c,g_%.s,$<) -S $<
	gawk -i inplace '/.*::?	.DCB.B	8,0/{print "	.long" RS $$0;next}1' $(patsubst %.c,g_%.s,$<)
	gawk -i inplace '/^gcc2_compiled_for_madmac:/{print $$0 RS "_$(patsubst %.c,%,$<)_loc::";next}1' $(patsubst %.c,g_%.s,$<)
	$(ASM) $(ASMFLAGS) -u -o $@ $(patsubst %.c,g_%.s,$<)

$(CDSPOBJS):%o:%c
	$(CC_JRISC) $(CDEFS) $(CINCLUDES) $(CFLAGS_JRISC) $(CFLAGS_DSP) -o $(patsubst %.c,g_%.s,$<) -S $<
	gawk -i inplace '/.*::?	.DCB.B	8,0/{print "	.long" RS $$0;next}1' $(patsubst %.c,g_%.s,$<)
	gawk -i inplace '/^gcc2_compiled_for_madmac:/{print $$0 RS "_$(patsubst %.c,%,$<)_loc::";next}1' $(patsubst %.c,g_%.s,$<)
	$(ASM) $(ASMFLAGS) -u -o $@ $(patsubst %.c,g_%.s,$<)

.PHONY: clean
clean:
	rm -f $(OBJS) $(PROGS) $(GENERATED)
