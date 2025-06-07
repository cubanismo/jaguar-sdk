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

$(CGPUOBJS):%o:%c
	$(CC_JRISC) $(CDEFS) $(CINCLUDES) $(CFLAGS_JRISC) -o $(patsubst %.c,g_%.s,$<) -S $<
	gawk -i inplace '/.*::?	.DCB.B	8,0/{print "	.long" RS $$0;next}1' $(patsubst %.c,g_%.s,$<)
	$(ASM) $(ASMFLAGS) -u -o $@ $(patsubst %.c,g_%.s,$<)

$(CDSPOBJS):%o:%c
	$(CC_JRISC) $(CDEFS) $(CINCLUDES) $(CFLAGS_JRISC) $(CFLAGS_DSP) -o $(patsubst %.c,g_%.s,$<) -S $<
	gawk -i inplace '/.*::?	.DCB.B	8,0/{print "	.long" RS $$0;next}1' $(patsubst %.c,g_%.s,$<)
	$(ASM) $(ASMFLAGS) -u -o $@ $(patsubst %.c,g_%.s,$<)

.PHONY: clean
clean:
	rm -f $(OBJS) $(PROGS) $(GENERATED)
