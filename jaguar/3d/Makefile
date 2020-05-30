#############################################################################
# Makefile for new 3D package demo
# MS-DOS version
#############################################################################

#############################################################################
# location of various directories
#############################################################################

INC=include
LIB=lib
FONTDIR=fonts

#############################################################################
# names of various commands
# (Change 'erase' to 'rm' if running under GULAM or similar shell on Atari.)
#############################################################################

RM=erase
CC= /home/mhill/m68k/m68k-aout/bin/gcc 

#############################################################################
# Flags for commands
#############################################################################

CFLAGS= -mc68000 -O2 -Wall -I$(INC)
MACFLAGS = -fb -i$(INC)
ALNFLAGS = -s -e -a 4000 x x 

#############################################################################
# rules for making things
# (Change 'docry' to 'tga2cry -binary' if using GULAM or similar shell on Atari.)
#############################################################################

.SUFFIXES: .o .s .c
.SUFFIXES: .cry .tga

.c.o:
	$(CC) $(CFLAGS) -o $*.o -c $<

.s.o:
	smac $(MACFLAGS) $<

.tga.cry:
	tga2cry $<

#############################################################################
# C library objects
# Normally we would put these into an archive (a .a file) and let the linker
# sort out which ones we need; for demo purposes, though, here they all are 
# explicitly
#############################################################################

CRT0= $(LIB)/jagrt.o

LIBOBJS = $(LIB)/alloc.o $(LIB)/clock.o $(LIB)/ctype.o $(LIB)/font.o $(LIB)/gpulib.o \
	$(LIB)/joyinp.o $(LIB)/joypad.o $(LIB)/memset.o $(LIB)/olist.o \
	$(LIB)/sprintf.o $(LIB)/strcat.o $(LIB)/strcmp.o $(LIB)/strcpy.o $(LIB)/strdup.o \
	$(LIB)/strncmp.o $(LIB)/util.o $(LIB)/video.o

SRCOBJS = demo.o trig.o mkmat.o miscasm.o gstex.o texrend.o wfrend.o gourrend.o flattex.o

MODELS = radar.o globe.o castle.o

TEXTURES = back3.cry \
	bottom.cry bottomfr.cry engbot.cry engfrnt.cry engside.cry engtop.cry \
	fin.cry finside.cry gunback.cry gunside.cry guntop.cry hood.cry roof.cry \
	rtfront.cry rtside.cry winfrnt.cry wing.cry wingside.cry winrt.cry \
	c1.cry c2.cry c3.cry u1.cry u2.cry u3.cry l1.cry l2.cry l3.cry \
	radar1a.cry radar1b.cry radar1d.cry radar1e.cry turret1b.cry

FIXDATA=-ii $(FONTDIR)/clr6x12.jft _usefnt \
	-ii back3.cry _back3 -ii bottom.cry _bottom -ii bottomfr.cry _bottomfr -ii engbot.cry _engbot \
	-ii engfrnt.cry _engfrnt -ii engside.cry _engside -ii engtop.cry _engtop -ii fin.cry _fin \
	-ii finside.cry _finside -ii gunback.cry _gunback -ii gunside.cry _gunside -ii guntop.cry _guntop \
	-ii hood.cry _hood -ii roof.cry _roof -ii rtfront.cry _rtfront -ii rtside.cry _rtside \
	-ii winfrnt.cry _winfrnt -ii wing.cry _wing -ii wingside.cry _wingside -ii winrt.cry _winrt \
	-ii c1.cry _c1 -ii c2.cry _c2 -ii c3.cry _c3 -ii u1.cry _u1 -ii u2.cry _u2 -ii u3.cry _u3 \
	-ii l1.cry _l1 -ii l2.cry _l2 -ii l3.cry _l3 \
	-ii radar1a.cry _radar1a -ii radar1b.cry _radar1b -ii radar1d.cry _radar1d -ii radar1e.cry _radar1e \
	-ii turret1b.cry _turret1b


#############################################################################

demo.cof: demo.lnk $(CRT0) $(SRCOBJS) $(TEXTURES) $(LIBOBJS) $(MODELS)
	aln $(ALNFLAGS) -o demo.cof -c demo.lnk

clean:
	$(RM) $(SRCOBJS) $(TEXTURES) $(MODELS) $(LIBOBJS) $(CRT0)

#############################################################################

gstex.o: gstex.s draw.inc load.inc loadxpt.inc clip.inc init.inc dotri.inc gourdraw.inc texdraw2.inc clipsubs.inc
flattex.o: flattex.s draw.inc load.inc loadxpt.inc clip.inc init.inc dotri.inc gourdraw.inc texdraw1.inc clipsubs.inc
gourrend.o: gourrend.s draw.inc load.inc loadxpt.inc clip.inc init.inc dotri.inc gourdraw.inc clipsubs.inc
texrend.o: texrend.s draw.inc load.inc loadxpt.inc clip.inc init.inc dotri.inc gourdraw.inc texdraw.inc clipsubs.inc
wfrend.o: wfrend.s wfdraw.inc load.inc loadxpt.inc clip.inc init.inc clipsubs.inc
