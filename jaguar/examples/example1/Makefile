JAGPATH=$(HOME)/jaguar
CROSSPATH=/usr/local/m68k-aout/m68k-aout
MADMAC=$(JAGPATH)/bin/mac
ALN=$(JAGPATH)/bin/aln
WDB=$(JAGPATH)/bin/wdb
JCP=$(JAGPATH)/bin/jcp
RDB=$(JAGPATH)/bin/rdbjag
LO=$(JAGPATH)/bin/lo -p $(PARIRQ)
CC=$(CROSSPATH)/bin/gcc
LIB=$(CROSSPATH)/lib/m68000
INCL=$(CROSSPATH)/include

STADDR=4000
ALNFLAGS=-a $(STADDR) x x -rq -v -v -v -y $(LIB)
MACFLAGS=-fb -v
CFLAGS=-mc68000 -Wall -fomit-frame-pointer -O2 -msoft-float -funroll-loops

PROJECT=example1
SRCC=example1.c
#SRCS=data.s
SRCS=
SRCH=
OBJS=$(SRCC:.c=.o) $(SRCS:.s=.o) 
OTHEROBJS=data.o
#OTHEROBJS=
RMVLIBS=display.o interrupt.o rmvlib.a

DISTFILES=Makefile README $(SRCC) $(SRCH) $(SRCS) $(OTHEROBJS)

TARFILE=$(PROJECT).tar.gz

all: .depend $(PROJECT).cof $(PROJECT).bin

$(PROJECT).cof: $(SRCH) $(OBJS) Makefile $(INCDATA)
	$(ALN) $(ALNFLAGS) -e -o $(PROJECT).cof crt0.o $(OBJS) $(OTHEROBJS) $(RMVLIBS) jlibc.a libgcc.a 

$(PROJECT).bin: $(SRCH) $(OBJS) Makefile $(INCDATA)
	$(ALN) $(ALNFLAGS) -n -o $(PROJECT).bin crt0.o $(OBJS) $(OTHEROBJS) $(RMVLIBS) jlibc.a libgcc.a 

%.o: %.s
	$(MADMAC) $(MACFLAGS) $<

%.o: %.c
	$(CC) $(CFLAGS) -c $<

dist: $(PROJECT).cof $(PROJECT).bin
	tar cfvz $(TARFILE) $(DISTFILES) $(PROJECT).cof $(PROJECT).bin

alpine: $(PROJECT).cof
	$(RDB) $(PROJECT).cof

bjl: $(PROJECT).bin
	$(LO) -8 $(PROJECT).bin

debug: $(PROJECT).cof
	$(WDB) $(PROJECT).cof

go:	$(PROJECT).cof
	$(JCP) $(PROJECT).cof

clean:
	rm -f *~ $(OBJS) $(PROJECT).cof $(PROJECT).bin

.depend: $(SRCC)
	$(CC) -MM $(SRCC) > .depend

-include .depend
