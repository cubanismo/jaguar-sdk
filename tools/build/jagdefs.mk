#====================================================================
#       Macro & Assembler flags
#====================================================================

# BJL/in-RAM start address
STADDR = 4000

# BSS follows directly after text and data sections
BSSADDR = x

ASMFLAGS = -fb -g
# Link flags:
#  -e  - Output using COF file format
#  -g  - Output source level debugging (where supported)
#  -l  - Add local symbols
#  -rd - Align sections to double phrase (16 byte) boundaries
#  -a  - Absolute section addresses
LINKFLAGS = -e -g -l -rd -a $(STADDR) x $(BSSADDR)

# Enable additional logging if requested on the command line.
V ?= 0
VERBOSE =
ifeq ($(V),1)
  VERBOSE += -v
endif
ifeq ($(V),2)
  VERBOSE += -v -v
endif

LINKFLAGS += $(VERBOSE)

# Use rmac and rln as the assembler/linker respectively.
ASM = rmac
LINK = rln

# Use gcc to build C files
CFLAGS ?= -O2
CDEFS = -DJAGUAR
CC = m68k-aout-gcc

# Default build target
all:
.PHONY: all
