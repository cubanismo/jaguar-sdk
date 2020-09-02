#============================================================================
# Makefile	MUSIC DRIVER
#============================================================================

include $(JAGSDK)/tools/build/jagdefs.mk

SYNTHPATH = $(JAGSDK)/jaguar/music/fulsyn

#============================================================================
# Use 'erase' and 'move' on MS-DOS
# Use 'rm' and 'mv' on Atari w/ csh
#============================================================================

ERASE  = rm
RENAME = mv

#============================================================================
#	MIDI FILE WITHOUT EXTENTION (!!)
#============================================================================

MIDIFILE = iron

# If you have more than one MIDI file, you  have to make changes to this 
# 'makefile'. This above variable 'MIDIFILE' has to have the name of the 
# output file of the merged MIDI files (e.g. 'music'). For each of your 
# MIDI files you have to add these lines to your makefile:
#
#   midifile.ous:
#	parse -q -x offset -n nr_of_voices -o midifile.ous midifile.mid
#
# To get the MIDI files merged, add:
#
#   $(MIDIFILE).ous:
#	merge $(MIDIFILE).ous file1.ous file2.ous ...
#
# Example using the MIDI files:
#
# MIDIFILE = music
# 
# a.ous:
#	parse -q -x 0 -n 2 -o a.ous a.mid
# b.ous:
#	parse -q -x 2 -n 3 -o b.ous b.mid
# c.ous:
#	parse -q -x 5 -n 2 -o c.ous c.mid
#
# $(MIDIFILE).ous:
#	merge $(MIDIFILE).ous a.ous b.ous c.ous
#

#============================================================================
#	MIDI Parser flags
#============================================================================

PARSERFLAGS = -q

#============================================================================
# Default Rules
#============================================================================

.SUFFIXES:	.o .mid

.mid.o:
	parse $(PARSERFLAGS) -o $*.ous $*.mid
	$(ASM) $(ASMFLAGS) -o$*.o $*.ous
	$(ERASE) $*.ous

#============================================================================
.SUFFIXES:     .ous .mid

.mid.ous:
	parse $(PARSERFLAGS) -o $*.ous $*.mid

#============================================================================
.SUFFIXES:     .o .ous

.ous.o:
	$(ASM) $(ASMFLAGS) -o$*.o $*.ous

#============================================================================
.SUFFIXES:	.o .das

.das.o:
	$(ASM) $(ASMFLAGS) -o$*.o $*.das

#============================================================================

SYNTH = $(SYNTHPATH)/fs02_55
FULSYN	= $(SYNTH).o
OBJS	= startup.o driver.o synth.o $(MIDIFILE).o $(FULSYN)
PROGS	= test.cof

GENERATED += ironsnr1.ous ironsnr2.ous iron.ous

#============================================================================
#	EXECUTABLES
#============================================================================

test.cof: $(OBJS)
	$(LINK) $(LINKFLAGS) -o $@ $^

#============================================================================
#	Dependencies
#============================================================================

driver.o:		driver.s synth.cnf $(SYNTHPATH)/fulsyn.inc

synth.o:		synth.s synth.cnf $(SYNTHPATH)/fulsyn.inc

$(MIDIFILE).ous:	$(MIDIFILE).ous parse.cnf

$(FULSYN):		$(SYNTH).das synth.cnf $(SYNTHPATH)/fulsyn.inc

ironsnr1.ous:		ironsnr1.mid parse.cnf
	parse -q -d -x 0 -n 6 -o ironsnr1.ous ironsnr1.mid

ironsnr2.ous:		ironsnr2.mid parse.cnf
	parse -q -d -x 6 -n 1 -o ironsnr2.ous ironsnr2.mid

$(MIDIFILE).ous: ironsnr1.ous ironsnr2.ous
	merge $(MIDIFILE).ous ironsnr1.ous ironsnr2.ous

include $(JAGSDK)/tools/build/jagrules.mk
