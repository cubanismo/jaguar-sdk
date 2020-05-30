#############################################################################
# Define BINDIR to point at location of AGPU & M68K directories.
# Note the use of forward slashes, not backslashes
#############################################################################

BINDIR = /jaguar/bin/

#############################################################################
# Basic flags for compiling to GPU/DSP code (see \JAGUAR\DOCS\GCC.TXT for info)
# Specify directory, GPU/DSP code, GCC v2.6, Optimization level 2, Source output
#############################################################################

GCCFLAGS_GPU = -B$(BINDIR) -b agpu -V2.6 -O2 -S

#############################################################################
# Basic flags for compiling to 68000 code (see \JAGUAR\DOCS\GCC.TXT for info)
# Specify directory, 680x0 code, GCC v2.6, Optimization level 2, Source output
#############################################################################

GCCFLAGS_68K = -B$(BINDIR) -b m68k -V2.5 -O2 -S

test.o: test.c
	gccjag $(GCCFLAGS_GPU) -c $*.c

