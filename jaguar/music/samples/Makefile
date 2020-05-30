#============================================================================
# Makefile	MUSIC DRIVER
#============================================================================

SYNTHPATH = /jaguar/music/fulsyn

#============================================================================
# Use 'erase' and 'move' on MS-DOS
# Use 'rm' and 'mv' on Atari w/ csh
#============================================================================

ERASE  = erase
RENAME = move

#============================================================================
#	MIDI FILE WITHOUT EXTENTION (!!)
#============================================================================

MIDIFILE = iron

# If you have more than one MIDI file, you  have to make changes to this 
# 'makefile'. This above variable 'MIDIFILE' has to have the name of the 
# output file of the merged MIDI files (e.g. 'music'). For each of your 
# MIDI files you have to add these lines to your makefile:
#
#   midifile.out:
#	parse -q -x offset -n nr_of_voices -o midifile.out midifile.mid		
#
# To get the MIDI files merged, add:
#
#   $(MIDIFILE).out:
#	merge $(MIDIFILE).out file1.out file2.out ...
#
# Example using the MIDI files:
#
# MIDIFILE = music
# 
# a.out:
#	parse -q -x 0 -n 2 -o a.out a.mid
# b.out:
#	parse -q -x 2 -n 3 -o b.out b.mid
# c.out:
#	parse -q -x 5 -n 2 -o c.out c.mid
#
# $(MIDIFILE).out:
#	merge $(MIDIFILE).out a.out b.out c.out
#

#============================================================================
#	MIDI Parser flags
#============================================================================

PARSERFLAGS = -q

#============================================================================
# Assembler & Linker flags
#============================================================================

MACFLAGS = -fb -rd -i$(SYNTHPATH);$(MACPATH)
ALNFLAGS = -g -e -l -rd -a 4000 x x

#============================================================================
# Default Rules
#============================================================================

.SUFFIXES:	.o .mid

.mid.o:
	parse $(PARSERFLAGS) -o $*.out $*.mid
	mac $(MACFLAGS) -o$*.o $*.out
	$(ERASE) $*.out

#============================================================================
.SUFFIXES:	.out .mid

.mid.out:
	parse $(PARSERFLAGS) -o $*.out $*.mid

#============================================================================
.SUFFIXES:	.o .out

.out.o:
	mac $(MACFLAGS) -o$*.o $*.out

#============================================================================
.SUFFIXES:	.o .s

.s.o:
	mac $(MACFLAGS) $<

#============================================================================
.SUFFIXES:	.oj .das

.das.oj:
	mac $(MACFLAGS) -o$*.oj $*.das

#============================================================================

SYNTH = $(SYNTHPATH)/fs02_55
FULSYN	= $(SYNTH).oj
OBJS	= startup.o driver.o synth.o $(MIDIFILE).o
SCORE	= $(MIDIFILE).o
EXEC	= test.cof

#============================================================================
#	EXECUTABLES
#============================================================================

$(EXEC): $(OBJS) $(FULSYN)
	aln $(ALNFLAGS) -o $(EXEC) $(OBJS) $(FULSYN)

#============================================================================
#	Dependencies
#============================================================================

driver.o:		driver.s synth.cnf $(SYNTHPATH)/fulsyn.inc

synth.o:		synth.s synth.cnf $(SYNTHPATH)/fulsyn.inc

$(MIDIFILE).scr:	$(MIDIFILE).out parse.cnf

$(FULSYN):		$(SYNTH).das synth.cnf $(SYNTHPATH)/fulsyn.inc
	mac $(MACFLAGS) -o$*.oj $*.das

ironsnr1.out:
	parse -q -d -x 0 -n 6 -o ironsnr1.out ironsnr1.mid

ironsnr2.out:
	parse -q -d -x 6 -n 1 -o ironsnr2.out ironsnr2.mid

$(MIDIFILE).out: ironsnr1.out ironsnr2.out
	merge $(MIDIFILE).out ironsnr1.out ironsnr2.out


