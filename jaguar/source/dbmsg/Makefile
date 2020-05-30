
STADDR = 802000
MACFLAGS = -fb -g
ALNFLAGS = -v -v -e -g -l -a $(STADDR) x 4000

#====================================================================

.SUFFIXES:      .o .s

.s.o:
	mac $(MACFLAGS) $<

#====================================================================

OBJ =   rdbmsg.o
 
rdbmsg.cof: $(OBJ)
	aln $(ALNFLAGS) $(OBJ)

