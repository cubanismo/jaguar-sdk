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
# $23??-$23FC: Skunkboard BIOS stack. It makes very light use of the stack.
# $2000-$????: BJL loader variables and stack (aliases Memory Track)
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
# JDB         - 0x270 bytes for text section. It doesn't have a data or BSS
#               section, but it also needs...
# JDB         - 0xb4 bytes for shadow copy of registers + 0xC bytes for
#               exception data at hard-coded absolute addresses. If the shadow
#               register buffer moves, jserve needs to be updated as well. It
#               hard-codes this address too.
# regdump.bin - 0xa0 bytes of GPU/DSP code to dump RISC registers. This code
#               is position-independent, but its load address is hard-coded in
#               this script.
# regdump.bin - 0x100 for shadow copy of RISC registers ((32 * 4) * (2 banks))
#               The address of this buffer is hard-coded in regdump.bin itself
#               and this script.
# RISC break  - 0x4 bytes for a two-instruction RISC loop used to corral a RISC
#               processor when it hits a software breakpoint. The location of
#               this loop is hard-coded in this script. The Atari gpu.db file
#               places this at $1C, which is the TRAPV exception vector, but I
#               see no good reason to hide it there unless we're *really*
#               hurting for space, which we don't appear to be.
#
# Solution:
#
# $0400-$0404 - RISC break
# $0500-$05a0 - regdump.bin
# $05a0-$05c4 - regset.bin
# $0600-$0700 - regdump.bin shadow copy of RISC registers
# $1000-$1300 - JDB code, leaving 0x90 bytes free for future expansion.
# $1300-$13C0 - JDB shadow copy of registers and exception data

set $jrisc_break = 0x400
set $regdump_code = 0x500
set $regset_code = 0x5a0
set $regset_val = 0x5c0
set $regset_oldval = 0x5bc
set $regdump_shadow = 0x600

define savegpc
	set $backup_gpc = {unsigned long}0xf02110
end

define resetgpc
	setgpc $backup_gpc+0x2
end

define showgpc
	printf "G_PC: 0x%08x\n", {unsigned long}0xf02110 + 2
end

document showgpc
Display the G_PC register's value.

Prints the address of the next insruction the GPU will execute.
end

define stopgpu
	set {unsigned long}0xf02114 = 0x00000008
end

document stopgpu
Stop the GPU

The G_CTRL register is written to 0x8, halting the GPU.
end

define setgpc
	stopgpu
	set {unsigned long}0xf02110 = $arg0
end

document setgpc
Set the GPU program counter

The GPU is halted if it is running, then the program counter
is set to the specified value.
end

define gogpu
	set {unsigned long}0xf02114 = 0x00000011
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
	gdb.execute('restore ' + os.environ['DBPATH'] + '/regdump-500.bin binary $regdump_code')
	gdb.execute('restore ' + os.environ['DBPATH'] + '/regset-5a0.bin binary $regset_code')
else:
	gdb.execute('printf "Environment variable \'DBPATH\' not found!\n"')
	gdb.execute('printf "Please set up the jaguar-sdk environment variables by sourcing\n"')
	gdb.execute('printf "\n"')
	gdb.execute('printf "  \'<jaguar-sdk directory>/env.sh\'\n"')
	gdb.execute('printf "\n"')
	gdb.execute('printf "before using jag.gdb\n"')
end
end

define tg
	if ($argc>0)
		setgpc $arg0
	end

	set $done = 0
	set $ctrl_val = 0x00000009
	while ($done == 0)
		set $local_gpc = {unsigned long}0xf02110 + 2
		set $nexti = {unsigned short}$local_gpc
		if ((($local_gpc & 2) == 0) && (($nexti >> 10) == 38))
			# Long-aligned movei instructions don't single-step
			# correctly. To work around this, move the instruction
			# to the scratch space at the start of the regdump code
			# and execute it there.
			set {unsigned short}($regdump_code + 2) = $nexti
			set $immediate_val = {unsigned long}($local_gpc + 2)
			set {unsigned long}($regdump_code + 4) = $immediate_val
			# Restart single stepping at the relocated instruction.
			setgpc $regdump_code+2
			set $ctrl_val = 0x00000009
			set {unsigned long}0xf02114 = $ctrl_val
			set $temp = {unsigned long}0xf02114
			while (($temp & 0x00000008) == 0)
				set $temp = {unsigned long}0xf02114 & 0x00000008
			end
			# Execution of the relocated instruction is complete.
			# Restore G_PC to the instruction after the movei and
			# continue through the tracing loop.
			setgpc $local_gpc+6
		else
			set {unsigned long}0xf02114 = $ctrl_val
			set $ctrl_val = $ctrl_val | 0x10
			set $temp = {unsigned long}0xf02114
			while (($temp & 0x00000008) == 0)
				set $temp = {unsigned long}0xf02114 & 0x00000008
			end
		end
		set $g0 = {unsigned long}0xf02110 + 2

		if ($argc < 2)
			set $done = 1
		else
			if ($g0 == $arg1)
				set $done = 1
			end
		end
	end
	# XXX Disassemble instruction at G_PC
end

document tg
Trace GPU

Usage: tg                   - single-step GPU from current G_PC
       tg <new_PC>          - single-step GPU from new G_PC
       tg <new_PC> <end_PC> - step GPU from new G_PC until end G_PC
end

define xgrinternal
	set $backup_gflags = {unsigned long}0xf02100
	savegpc
	setgpc $regset_code 

	# Build a long-word of <High word of old value address>|<Store old value>
	set {unsigned long}($regset_code + 4) = 0x0000BFE0|$arg0

	# Build a long-word of <addq #4,r31>|<load new value>
	set {unsigned long}($regset_code + 8) = 0x089Fa7E0|$arg0

	# Store the new value at the temp location
	set {unsigned long}$regset_val = $arg1

	gogpu

	set $gpucontrol = 0xFFFFFFFF
	set $count = 0
	while (($count < 10) && ($gpucontrol != 0))
		set $gpucontrol = {unsigned long}0xf02114
		set $count = $count + 1
	end

	printf "R%d was: 0x%08x and is now: 0x%08x\n", $arg0, {unsigned long}$regset_oldval, $arg1

	set {unsigned long}0xf02100 = $backup_gflags
	resetgpc
end

define xgrusage
	printf "Usage: xgr Register# NewRegisterData\n"
	printf " where Register# is 0-29 decimal and NewRegisterData is 32-bit hex\n"
end

define xgr
	if ($argc < 2)
		xgrusage
	else
		if (($arg0 < 0) || ($arg0 > 29))
			printf "Register number %d is out of range\n", $arg0
			xgrusage
		else
			xgrinternal $arg0 $arg1
		end
		
	end
end

document xgr
Usage: xgr <RegNumber> <NewRegisterData>
 where <RegNumber> is 0-29 decimal and <NewRegisterData> is a 32-bit
 unsigned value. Registers r30 and r31 are clobbered as part of the
 register setting process.
end

define xg
	set $backup_gflags = {unsigned long}0xf02100

	printf "G_FLAGS:"
	if (($backup_gflags&1)==0)
		printf " ZC"
	end
	if (($backup_gflags&1)!=0)
		printf " ZS"
	end
	if (($backup_gflags&2)==0)
		printf " CC"
	end
	if (($backup_gflags&2)!=0)
		printf " CS"
	end
	if (($backup_gflags&4)==0)
		printf " NC"
	end
	if (($backup_gflags&4)!=0)
		printf " NS"
	end

	printf " Register Bank %d", $backup_gflags & 0x4000 >> 14
	printf "  G_PC: %08x\n", {unsigned long}0xf02110 + 0x2

	savegpc
	setgpc ($regdump_code+0x8) 
	set {unsigned long}($regdump_shadow+0x7c) = 0xffffffff
	set {unsigned long}($regdump_shadow+0x78) = 0x0
	set {unsigned long}($regdump_code+0x8c) = 0x981f2114
	set {unsigned long}($regdump_code+0x90) = 0x00f0981e

	gogpu

	set $temp1 = 0xffffffff
	set $temp2 = 0
	set $count = 0
	while (($count < 10) && ($temp1 != $temp2))
		set $temp1 = {unsigned long}($regdump_shadow+0x7c)
		set $temp2 = {unsigned long}($regdump_shadow+0x78)
		set $count = $count + 1
	end

	if ($count < 10)
		set $row = 0
		while ($row < 4)
			printf "R%02d:", ($row * 8)
			set $count = 0
			while ($count < 8)
				if ((($row * 8) + $count) < 30)
					printf " %08x", {unsigned long}($regdump_shadow+($row*32)+($count*4))
				else
					printf " TRASHED!"
				end
				set $count = $count + 1
			end
			printf "\n"
			set $row = $row + 1
		end
	else
		printf "Did the GPU die?\n"
	end
	set {unsigned long}0xf02100 = $backup_gflags
	resetgpc
end

document xg
Dump GPU registers

Usage: xg - Dump the registers in the current register bank. Registers
            r30 and r31 are clobbered as part of the readback process.
end
