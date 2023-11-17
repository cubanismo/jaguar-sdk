#.c.o:
#	$(CC) $(CFLAGS) -c $<
.s.o:
	$(AS) $(SFLAGS) $<
#.o.cof:
#	$(LN) $(LFLAGS) $<

JDIR=/usr/local/jaguar/
JBIN=$(JDIR)bin/#				jaguar binaries path
VFLAGS=-v#					verbose on
GFLAGS=-g#					source-level debugging
DFLAGS=#-da#					get output source,dump GCC debug files

C68KFLAGS=-b m68k -O2 -fomit-frame-pointer#	M68K flags
CGPUFLAGS=-b agpu -O2 -fomit-frame-pointer#	AGPU flags
CC=$(JDIR)gcc263 -B$(JDIR) -v#			C compiler's name
CFLAGS=$(GFLAGS)#				C compiler's flags

AS=$(JBIN)mac#					assembler's name
SFLAGS=-fb -i$(JDIR)inc $(GFLAGS)#		assembler's flags
LN=$(JBIN)aln#					linker's name
LFLAGS=-g -e -a 802000 4000 x -l $(VFLAGS) -y $(JDIR)lib#	linker's flags
LIBS=#gpustd.a

RM=rm -f

C68KOBJ=m68kdhry.o
CGPUOBJ=agpudhry.o
OBJS=m68kmisc.o $(C68KOBJ) $(CGPUOBJ)

dhry.cof:	$(OBJS)
	$(LN) $(LFLAGS) -o dhry.cof $(OBJS) $(LIBS)

$(C68KOBJ):%o:%c
	$(CC) $(C68KFLAGS) $(CFLAGS) -c $<
$(CGPUOBJ):%o:%c
	$(CC) $(CGPUFLAGS) $(CFLAGS) $(DFLAGS) -c $<

.PHONY:	clean realclean distclean

clean:
	$(RM) *.o *~
realclean:	clean
	$(RM) dhry.cof
distclean:	realclean
	$(RM) agpudhry.s *.err *.greg *.lreg *.combine *.flow *.cse *.jump *.rtl *.tree *.loop *.dbr *.jump2 *.sched *.cse2 *.sched2 *.stack
