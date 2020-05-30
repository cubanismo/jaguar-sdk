#====================================================================
#       Macro & Assembler flags
#====================================================================

STADDR = 802000
MACFLAGS = -fb -g
ALNFLAGS = -w -v -v -e -rd -g -l -a $(STADDR) x 4000

#====================================================================
#       Default Rules
#====================================================================
.SUFFIXES:      .o .s

.s.o:
	mac $(MACFLAGS) $<

#.tga.rgb:
#    dorgb $*.rgb $<

#====================================================================
#       EXECUTABLES
#====================================================================

PICTURES = fish.bpg patrick.bpg

#############################################################################
# if using CRY mode screen, then must include 'rgb2cry.o' in list of object
# module files.

OBJ = startup.o test.o bpeg.o
 
testbpeg.cof: $(OBJ)
	aln $(ALNFLAGS) -o testbpeg.cof $(OBJ) -c testbpeg.lnk

#############################################################################

fish.bpg: fish.tga
	cbpeg -quality 25 fish.tga fish.bpg

patrick.bpg: patrick.tga
	cbpeg -quality 75 patrick.tga patrick.bpg

startup.o: startup.s \jaguar\source\sample.rgb

