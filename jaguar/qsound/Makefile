include $(JAGSDK)/tools/build/jagdefs.mk

#====================================================================
#       Macro & Assembler flags
#====================================================================

# Override ASMFLAGS and LINKFLAGS to use quad-phrase alignment. (Why?)
ASMFLAGS += -rq
LINKFLAGS = -e -g -l -rq -a $(STADDR) x $(BSSADDR) $(VERBOSE)

#====================================================================
#       Default Rules
#====================================================================

.SUFFIXES:	.o .das

.das.o:
	$(ASM) $(ASMFLAGS) $*.das

#====================================================================
#       EXECUTABLES
#====================================================================

OBJS = startup.o qdemo.o demo.o qpanner.o joypad.o
PROGS = qdemo.cof
 
qdemo.cof: $(OBJS) qsound.ot valogo16.pic copter.snd phaser.snd mix3.snd ../source/sample.rgb
	$(LINK) $(LINKFLAGS) -o $@ $(OBJS)  -c qdemo.lnk

include $(JAGSDK)/tools/build/jagrules.mk
