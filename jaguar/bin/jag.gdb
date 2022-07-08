#
# GDB helper functions for remote debugging the Jaguar GPU and DSP processors
# with the help of a Skunkboard.
# 
# These work in conjunction with the jdb.cof debug stub running on the Jaguar
# and the jserve bridge which translates GDB remote commands to binary commands
# sent and received to the Skunkboard over USB.
#
# The Jaguar-side code all needs to live below $4000, and there are various
# existing users of that reserved memory. We should do our best to avoid
# olliding with relevant ones. Here are the currently known users:
#
# Start End+1
# ----- -----
# $0000-$0400: m68k exception vectors
# $0400-$04??: Jaguar BIOS boot code (Very small)
# $04??-$0FF0: unused?
# $0FF0-$0FF8: Skunkboard object list
# $1000-$1400: BJL loader screen bitmap (Overflows this a bit in 2005 version)
# $1400-$????: Skunkboard BIOS code.
# $2000-$2C00: Memory Track flash driver.
# $2000-$????: BJL loader variables and stack (aliases Memory Track)
# $23??-$23FC: Skunkboard BIOS stack. It makes very light use of the stack.
# $2C00-$2???: Jaguar CD table of contents (TOC)
# $3000-$3???: Jaguar CD BIOS
# $3???-$4000: Jaguar BIOS Stack
#
# JDB's code and data sections can't conflict with the Skunkboard BIOS code, as
# we'll be using at least some of the Skunkboard BIOS code to get the JDB stub
# uploaded to Jaguar RAM in the first place. However, once the JDB stub is
# running, this range is available, since JDB will never rts to it. Same goes
# for the Skunkboard BIOS stack.
#
# We probably never want to conflict with the Skunkboard object list. It
# technically remains in use until the client program loads another one.
#
# It would be best to stay out of the way of the CD and Memory Track BIOS code,
# though it is difficult to debug CD programs because CD controller ("BUTCH")
# accesses via the ROM/cartridge port can happen asynchronously via the GPU, and
# the communication between JDB and the Skunkboard uses the same port, but the
# Jaguar CD is a 32-bit "cartridge" and the Skunkboard is a 16-bit cartridge.
# JDB would need to be updated to save/restore MEMCON1 and force 16-bit mode
# while not in run mode, but this could mess up any asynchronous transfers in
# progress. Still, for the time being, let's avoid this region.
#
# There should be no problem using the BJL loader regions. The BJL loader won't
# be in use while the Skunkboard BIOS is running, nor after JDB is started.
#
# The Jaguar BIOS code won't be running anymore, so this region and its stack
# should be available for our use.
#
# What we need:
#
# JDB            - 0x270 bytes for text section. It doesn't have a data or BSS
#                  section, but it also needs...
# JDB            - 0xb4 bytes for shadow copy of registers + 0xC bytes for
#                  exception data at hard-coded absolute addresses. If the
#                  shadow register buffer moves, jserve needs to be updated as
#                  well. It hard-codes this address too.
# regdumpset.bin - 0x1be bytes of GPU/DSP code to dump RISC registers. This code
#                  is position-independent, but its load address is hard-coded
#                  in this script.
# regdumpset.bin - 0x100 for shadow copy of RISC registers
#                  ((32 * 4) * (2 banks)). The address of this buffer is hard-
#                  coded in regdumpset.bin itself and this script.
# RISC break     - 0x4 bytes for a two-instruction RISC loop used to corral a
#                  RISC processor when it hits a software breakpoint. The
#                  location of this loop is hard-coded in this script. The Atari
#                  gpu.db file places this at $1C, which is the TRAPV exception
#                  vector. This value was likely chosen because it is small
#                  enough to be loaded with a moveq instruction.
#
# Solution:
#
# $0400-$0404 - RISC break XXX Not going to work with moveq!
# $0500-$06be - regdumpset-500.bin
# $0700-$0800 - regdumpset shadow copy of RISC registers
# $1000-$1300 - JDB code, leaving 0x90 bytes free for future expansion.
# $1300-$13C0 - JDB shadow copy of registers and exception data

set $jrisc_break = 0x400
set $regdump_code = 0x500
set $regdump_code_end = 0x5e0
set $regset_code = 0x5e4
set $regset_code_end = 0x6ba
set $reg_shadow = 0x700

#
# Conventions:
#
# - jagptr_*: Internal variable holding address of register or memory location
# - jagval_*: Internal variable holding cached value of register or memory
# - jag_*:    Internal helper function
#
set $jagptr_gflags = 0xf02100
set $jagptr_gpc = 0xf02110
set $jagptr_gctrl = 0xf02114
set $jagval_gpc = 0xf02ffe
set $jagval_gflags = 0x0

define jag_savegpc
	set $jagval_gpc = {unsigned long}$jagptr_gpc
end

define jag_resetgpc
	# G_PC always reads back as two less than the current instruction
	setgpc $jagval_gpc+0x2
end

define jag_savegflags
	set $jagval_gflags = {unsigned long}$jagptr_gflags
end

define jag_resetgflags
	set {unsigned long}$jagptr_gflags = $jagval_gflags
end

define showgpc
	# G_PC always reads back as two less than the current instruction
	printf "G_PC: 0x%08x\n", {unsigned long}$japptr_gpc + 2
end

document showgpc
Display the G_PC register's value.

Prints the address of the next insruction the GPU will execute.
end

define stopgpu
	set {unsigned long}$jagptr_gctrl = 0x00000008
end

document stopgpu
Stop the GPU

The G_CTRL register is written to 0x8, halting the GPU.
end

define setgpc
	stopgpu
	set {unsigned long}$jagptr_gpc = $arg0
end

document setgpc
Set the GPU program counter

The GPU is halted if it is running, then the program counter
is set to the specified value.
end

define gogpu
	set {unsigned long}$jagptr_gctrl = 0x00000011
end

document gogpu
Start the GPU

The GPU begins executing code starting at the current value
of G_PC and runs until it is halted.
end

define gpustuf
# Note python code can't have any unexpected indentation, so don't indent
# this function's top-level contents.
python
import os
if 'DBPATH' in os.environ:
	gdb.execute('restore ' + os.environ['DBPATH'] + '/regdumpset-500.bin binary $regdump_code')
else:
	gdb.execute('printf "Environment variable \'DBPATH\' not found!\n"')
	gdb.execute('printf "Please set up the jaguar-sdk environment variables by sourcing\n"')
	gdb.execute('printf "\n"')
	gdb.execute('printf "  \'<jaguar-sdk directory>/env.sh\'\n"')
	gdb.execute('printf "\n"')
	gdb.execute('printf "before using jag.gdb\n"')
end
end

define gstepi
	set $local_gpc = {unsigned long}$jagptr_gpc + 2
	if ($argc>0)
		if ($local_gpc != $arg0)
			setgpc $arg0
		end
	end

	set $done = 0
	set $jagval_ctrl_step = 0x00000019
	set $jagval_ctrl_steponly = 0x00000009
	set $jagval_ctrl_stepdone = 0x00000008
	while ($done == 0)
		set $local_gpc = {unsigned long}$jagptr_gpc + 2
		set $nexti = {unsigned short}$local_gpc
		set $unaligned_movei = 0
		if ((($local_gpc & 2) == 0) && (($nexti >> 10) == 38))
			# Long-aligned movei instructions don't single-step correctly.
			# To work around this, move the instruction to the register
			# shadow memory scratch space and execute it there.
			set $unaligned_movei = 1
			set {unsigned short}($reg_shadow + 2) = $nexti
			set $immediate_val = {unsigned long}($local_gpc + 2)
			set {unsigned long}($reg_shadow + 4) = $immediate_val
			# Add two nop instructions after the movei out of paranoia
			set {unsigned long}($reg_shadow + 8) = 0xe400e400
			# Restart single stepping at the relocated instruction.
			setgpc $reg_shadow+2
			set {unsigned long}$jagptr_gctrl = $jagval_ctrl_steponly
		else
			set {unsigned long}$jagptr_gctrl = $jagval_ctrl_step
		end

		set $temp  = {unsigned long}$jagptr_gctrl
		set $count = 0
		while (($count < 50) && ($temp & 1) && (($temp & $jagval_ctrl_stepdone) == 0))
			set $temp = {unsigned long}$jagptr_gctrl
			set $count = $count + 1
		end

		if (($temp & 1) == 0)
			printf "GPU stopped itself\n"
			set $done = 1
		end

		if (($done == 0) && ($count >= 50))
			printf "Timeout. Did the GPU die?\n"
			set $done = 1
		end

		if (($done == 0) && ($unaligned_movei != 0))
			# Execution of the relocated instruction is complete.
			# Restore G_PC to the instruction after the movei and
			# continue through the tracing loop.
			setgpc $local_gpc+6
		end

		set $local_gpc = {unsigned long}$jagptr_gpc + 2

		if ($argc < 2)
			set $done = 1
		else
			if ($local_gpc == $arg1)
				set $done = 1
			end
		end
	end
	if ($temp & 1)
		gdis
	end
end

document gstepi
Trace GPU

Usage: gstepi                   - single-step GPU from current G_PC
       gstepi <new_PC>          - single-step GPU from new G_PC
       gstepi <new_PC> <end_PC> - step GPU from new G_PC until end G_PC
end

# Helper function to run the register dump and register set code
#
# arg0 = GPU code start address
# arg1 = GPU code end address, which should be a tight loop jumping to itself.
# arg2 = return value: 0 = failure, 1 = success
define jag_grununtil
	jag_savegflags
	jag_savegpc

	setgpc $arg0
	gogpu

	set $count = 0
	while (($count < 10) && ($gpc() < $arg1))
		set $count = $count + 1
	end

	stopgpu

	jag_resetgflags
	jag_resetgpc

	if ($count < 10)
		set $arg2 = 1
	else
		set $arg2 = 0
	end
end

define jag_xgr
	# First, read back the current register values
	set $success = 0
	jag_grununtil $regdump_code $regdump_code_end $success

	set $current_bank = ($jagval_gflags & 0x4000) >> 14

	if ($argc < 3)
		set $req_bank = $current_bank
	else
		set $req_bank = $arg2
	end

	if ($current_bank == $req_bank)
		set $shadow_addr = $reg_shadow + ($arg0 * 4)
	else
		set $shadow_addr = $reg_shadow + 0x80 + ($arg0 * 4)
	end

	if ($success != 0)
		# Find the old value
		set $oldval = {unsigned long}$shadow_addr

		# Store the new value at the shadow location
		set {unsigned long}$shadow_addr = $arg1

		set $success = 0
		jag_grununtil $regset_code $regset_code_end $success
	end

	if ($success != 0)
		if (($arg0 == 30) && ($current_bank == $req_bank))
			printf "R30 in bank %d was: <UNKNOWN> and is now: 0x%08x\n", $req_bank, $arg1
		else
			printf "R%d in bank %d was: 0x%08x and is now: 0x%08x\n", $arg0, $req_bank, $oldval, $arg1
		end
	else
		printf "Did the GPU die?\n"
	end
end

define xgr
	if ($argc < 2)
		help xgr
	else
		if (($arg0 < 0) || ($arg0 > 31))
			printf "Register number %d is out of range\n", $arg0
			help xgr
		else
			if ($argc > 2)
				if (($arg2 != 0) && ($arg2 != 1))
					printf "Invalid register bank: %d\n", $arg2
					help xgr
				else
					jag_xgr $arg0 $arg1 $arg2
				end
			else
				jag_xgr $arg0 $arg1
			end
		end
	end
end

document xgr
Usage: xgr <RegNumber> <NewRegisterData> [RegisterBank]
 where <RegNumber> is 0-31 decimal, <NewRegisterData> is a 32-bit
 unsigned value, and [RegisterBank] is 0 or 1.

 If not specified, [RegisterBank] defaults to the current bank.

 The value of R30 in the current bank is clobbered unless it is
 the register being set.
end

define xg
	set $success = 0
	jag_grununtil $regdump_code $regdump_code_end $success

	# Decode the G_FLAGS and G_PC values saved by jag_gpu_readregs
	printf "G_FLAGS: %04x", $jagval_gflags & 0xff
	if (($jagval_gflags&1)==0)
		printf " NZ"
	end
	if (($jagval_gflags&1)!=0)
		printf " ZE"
	end
	if (($jagval_gflags&2)==0)
		printf " CC"
	end
	if (($jagval_gflags&2)!=0)
		printf " CS"
	end
	if (($jagval_gflags&4)==0)
		printf " PL"
	end
	if (($jagval_gflags&4)!=0)
		printf " NE"
	end

	printf "  Current Register Bank: %d", $jagval_gflags & 0x4000 >> 14
	# G_PC always reads back as two less than the current instruction
	printf "  G_PC: %08x\n", $jagval_gpc + 0x2

	if ($success != 0)
		# Use python to print the register shadow memory so we can do with in one
		# 128-byte read rather than 32 4-byte reads. The former is much faster.
# Begin python code: No indenting to keep python happy
		python
regview = gdb.selected_inferior().read_memory(gdb.parse_and_eval("$reg_shadow"), (8 * 32))
for i in range(0, 32, 8):
	print("R%02d:" % i, end = '')
	for j in range(i*4, (i+8)*4, 4):
		if (j == (30 * 4)): # r30 is clobbered by the readback code
			print(" TRASHED!", end = '')
		else:
			print(" %s" % regview[j:j+4].hex(), end = '')
	print("")
for i in range(0, 32, 8):
	print("A%02d:" % i, end = '')
	for j in range(128+(i*4), 128+((i+8)*4), 4):
		print(" %s" % regview[j:j+4].hex(), end = '')
	print("")
end
# End python
	else
		printf "Did the GPU die?\n"
	end
end

document xg
Dump GPU registers

Usage: xg - Dump the registers in the current register bank. Register r30
            is clobbered as part of the readback process.
end

#
# Document commands implemented in python in gdbjag.py
#
document gdisassemble
Disassemble GPU code

Usage: gdisassemble
          Dissassemble the instruction at G_PC

       gdisassemble <Address>
          Disassemble the instruction at <Address>

       gdisassemble <Address>,+<Count>
          Disassemble the instructions in the range
          [<Address>, <Address>+<Count>)

       gdisassemble <BeginAddress>,<EndAddress>
          Disassemble the instructions in the range
          [<BeginAddress>, <EndAddress>)

  The <Address> and <BeginAddress> parameters can be an absolute address
  preceeded by a '*' character, a symbol, or a line number. The <Count> and
  <EndAddress> parameters are currently parsed as simple integers.

  Examples:

    Disassemble the next instruction:

      gdis

    Longer version of the same thing:

      gdis *$gpc()

    Disassemble the next instruction and the following 8 bytes

      gdis *$gpc(),+8

    Disassemble the instructions between 0xf03000 and 0xf03020

      gdis *0xf03000,0xf03020
end

document ddisassemble
Disassemble DSP code

Usage: ddisassemble
          Dissassemble the instruction at D_PC

       ddisassemble <Address>
          Disassemble the instruction at <Address>

       ddisassemble <Address>,+<Count>
          Disassemble the instructions in the range
          [<Address>, <Address>+<Count>)

       ddisassemble <BeginAddress>,<EndAddress>
          Disassemble the instructions in the range
          [<BeginAddress>, <EndAddress>)

  The <Address> and <BeginAddress> parameters can be an absolute address
  preceeded by a '*' character, a symbol, or a line number. The <Count> and
  <EndAddress> parameters are currently parsed as simple integers.

  Examples:

    Disassemble the next instruction:

      ddis

    Longer version of the same thing:

      ddis *$dpc()

    Disassemble the next instruction and the following 8 bytes

      ddis *$dpc(),+8

    Disassemble the instructions between 0xf03000 and 0xf03020

      ddis *0xf03000,0xf03020

end

document gadvance
Run the GPU until it reaches the specified address

Usage: gadvance <BreakAddress>

  <BreakAddress> can be an absolute address preceeded by a '*' character, a
  symbol, or a line number.

  Note: Do not set breakpoints less than 6 bytes before the current G_PC
  value. This will confuse the breakpoint logic and produce undefined results.
  E.g., given the following code and G_PC value:

            0xf03000 loadb   (r1), r6
            0xf03002 xor     r5, r4
            0xf03004 add     r6, r4
    G_PC -> 0xf03006 xor     r6, r4
            0xf03008 shlq    #24, r4

  It is safe to set a breakpoint at 0xf03000, but not 0xf03002 or 0xf03004.
  To set a breakpoint at the latter locations, first single-step the GPU
  forward one or two instructions respectively.
