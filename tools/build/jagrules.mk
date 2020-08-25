#====================================================================
#       Default Rules
#====================================================================

all: $(PROGS)

.SUFFIXES: .o .s .c

.s.o:
	$(ASM) $(ASMFLAGS) $<

.c.o:
	$(CC) $(CDEFS) $(CINCLUDES) $(CFLAGS) -c -o $@ $<

.PHONY: clean
clean:
	rm -f $(OBJS) $(PROGS) $(GENERATED)
