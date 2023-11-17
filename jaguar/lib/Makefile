.s.o:
	$(AS) $(SFLAGS) $<

JDIR=/usr/local/jaguar/#			jaguar root directory
JBIN=$(JDIR)bin/#				jaguar binaries path
AS=$(JBIN)mac#					assembler's name
SFLAGS=-fb#					assembler's flags
AR=$(JBIN)ar#					archiver's name
AFLAGS=cs#					archiver's flags
LIBS=gpustd.a#					library names

OBJS=divhisi3.o divsi3.o mulsi3.o umulsi3.o

gpustd.a:	$(OBJS)
	$(AR) $(AFLAGS) gpustd.a $(OBJS)

.PHONY:	clean realclean distclean

clean:
	$(RM) *.o *~
realclean:	clean
	$(RM) $(LIBS)
distclean:	realclean
	$(RM) *.err

$(OBJS):	libinc.s
