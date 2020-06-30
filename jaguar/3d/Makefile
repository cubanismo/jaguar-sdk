#############################################################################
# Makefile for new 3D package demo
#############################################################################

include $(JAGSDK)/tools/build/jagdefs.mk

#############################################################################
# location of various directories
#############################################################################

INC=include
LIB=lib
FONTDIR=fonts

#############################################################################
# names of various commands
#############################################################################

RM=rm -f
CFLAGS += -mshort -Wall -fno-builtin -nostdinc -I$(INC)

#
# rules for making things
#
.SUFFIXES: .o .3ds
.SUFFIXES: .cry .tga

.3ds.o:
	3dsconv -o $*.s $<
	$(ASM) $(ASMFLAGS) $*.s
	$(RM) $*.s

.tga.cry:
	tga2cry -binary $<

#############################################################################
# C library objects
# Normally we would put these into an archive (a .a file) and let the linker
# sort out which ones we need; for demo purposes, though, here they all are
# explicitly
#############################################################################
CRT0= $(LIB)/jagrt.o

LIBOBJS = $(LIB)/alloc.o $(LIB)/clock.o $(LIB)/ctype.o $(LIB)/font.o \
	$(LIB)/gpulib.o $(LIB)/joyinp.o $(LIB)/joypad.o $(LIB)/memset.o \
	$(LIB)/olist.o $(LIB)/sprintf.o $(LIB)/strcat.o $(LIB)/strcmp.o \
	$(LIB)/strcpy.o $(LIB)/strdup.o $(LIB)/strncmp.o $(LIB)/util.o \
	$(LIB)/video.o

SRCOBJS = miscasm.o demo.o trig.o mkmat.o \
	wfrend.o gourrend.o gourphr.o \
	texrend.o flattex.o gstex.o

MODELS = radar.o globe.o torus.o robot.o ship1.o knight.o castle.o cube.o

TEXTURES = c1.cry c2.cry c3.cry u1.cry u2.cry u3.cry l1.cry l2.cry l3.cry \
	radar1a.cry radar1b.cry radar1d.cry radar1e.cry turret1b.cry \
	winrt.cry winfrnt.cry hood.cry rtfront.cry rtside.cry roof.cry \
	gunside.cry guntop.cry wing.cry wingside.cry gunback.cry engfrnt.cry \
	engtop.cry engside.cry bottomfr.cry bottom.cry finside.cry fin.cry \
	engbot.cry back3.cry

GENERATED += $(TEXTURES)

PROGS = demo.cof

#############################################################################
# the textures are arranged in decreasing order of size
#############################################################################
FIXDATA = -ii rtside.cry _rtside -ii c1.cry _c1 -ii c2.cry _c2 \
	-ii c3.cry _c3 -ii u1.cry _u1 -ii u2.cry _u2 -ii u3.cry _u3 \
	-ii l1.cry _l1 -ii l2.cry _l2 -ii l3.cry _l3 \
	-ii radar1b.cry _radar1b -ii radar1d.cry _radar1d \
	-ii roof.cry _roof -ii wing.cry _wing -ii turret1b.cry _turret1b \
	-ii engside.cry _engside -ii rtfront.cry _rtfront \
	-ii winfrnt.cry _winfrnt -ii hood.cry _hood -ii back3.cry _back3 \
	-ii winrt.cry _winrt -ii engtop.cry _engtop \
	-ii wingside.cry _wingside -ii bottom.cry _bottom \
	-ii fin.cry _fin -ii guntop.cry _guntop -ii engfrnt.cry _engfrnt \
	-ii radar1a.cry _radar1a -ii radar1e.cry _radar1e \
	-ii bottomfr.cry _bottomfr -ii gunside.cry _gunside \
	-ii finside.cry _finside -ii gunback.cry _gunback \
	-ii engbot.cry _engbot \
	-ii $(FONTDIR)/clr6x12.jft _usefnt

OBJS = $(CRT0) $(SRCOBJS) $(MODELS) $(LIBOBJS)

demo.cof: $(OBJS) $(TEXTURES)
	$(LINK) $(LINKFLAGS) -o demo.cof $(OBJS) $(FIXDATA)

wfrend.o: wfrend.s wfdraw.inc load.inc loadxpt.inc clip.inc init.inc clipsubs.inc
gourrend.o: gourrend.s drawpoly.inc load.inc loadxpt.inc clip.inc init.inc gourdraw.inc clipsubs.inc
gourphr.o: gourphr.s drawpoly.inc load.inc loadxpt.inc clip.inc init.inc phrdraw.inc clipsubs.inc
texrend.o: texrend.s drawpoly.inc load.inc loadxpt.inc clip.inc init.inc gourdraw.inc texdraw.inc clipsubs.inc
flattex.o: flattex.s drawpoly.inc load.inc loadxpt.inc clip.inc init.inc gourdraw.inc texdraw1.inc clipsubs.inc
gstex.o: gstex.s drawpoly.inc load.inc loadxpt.inc clip.inc init.inc gourdraw.inc texdraw2.inc clipsubs.inc

include $(JAGSDK)/tools/build/jagrules.mk
