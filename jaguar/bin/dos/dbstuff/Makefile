ALNFLAGS=-a 2200 x x -n -o fillcode.dat

fillcode.dat:	fillcode.o
	aln $(ALNFLAGS) fillcode.o

fillcode.o:	fillcode.s
	mac fillcode.s

