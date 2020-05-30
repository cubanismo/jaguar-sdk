JCP=~/jaguar/bin/jcp

OFILES = \
startup.o \
jag.o

jag : $(OFILES)
	aln -c jag.lnk 

GAS2OBJ = mac -fb -g $?
C2OBJ = /usr/local/m68k-aout/m68k-aout/bin/gcc -mc68000 -Wall -DJAGUAR -O2 -c -o $@ $?

#
# 68k jaguar specific asm files
#

startup.o : startup.s
	$(GAS2OBJ)

#
# 68k jaguar specific C files
#	
jag.o : jag.c
	$(C2OBJ)

go:	jag.cof
	$(JCP) jag.cof

clean :
	rm *.o
	rm *.cof


