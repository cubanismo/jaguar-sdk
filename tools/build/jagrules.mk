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
	$(CC_JRISC) $(CDEFS) $(CINCLUDES) $(CFLAGS_JRISC) -c $<

$(CDSPOBJS):%o:%c
	$(CC_JRISC) $(CDEFS) $(CINCLUDES) $(CFLAGS_JRISC) $(CFLAGS_DSP) -c $<

.PHONY: clean
clean:
	rm -f $(OBJS) $(PROGS) $(GENERATED)
