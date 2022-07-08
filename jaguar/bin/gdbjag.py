import jrisc

class PyGpuPCFunc(gdb.Function):
	def __init__(self):
		super (PyGpuPCFunc, self).__init__("gpc")

	def invoke(self):
		return gdb.parse_and_eval('{unsigned long}0xf02110') + 2

PyGpuPCFunc()

class PyDspPCFunc(gdb.Function):
	def __init__(self):
		super (PyDspPCFunc, self).__init__("dpc")

	def invoke(self):
		return gdb.parse_and_eval('{unsigned long}0xf1a110') + 2

PyDspPCFunc()

def invoke_disassemble(arg, from_tty, dsp):
	args = gdb.string_to_argv(arg)
	length = 6;
	explicitLength = False
	showMachineCode = False
	numArgs = len(args)
	curArg = 0

	if curArg < numArgs:
		if args[curArg] == "/r":
			showMachineCode = True
			curArg += 1

	if curArg >= numArgs:
		if dsp:
		    location = gdb.parse_and_eval('$dpc()')
		else:
		    location = gdb.parse_and_eval('$gpc()')
	else:
		rangeTuple = args[curArg].split(',')
		location = gdb.decode_line(rangeTuple[0])
		if location[1]:
			syms = location[1]
			location = syms[0].pc
			location &= ~1
		else:
			raise Exception("Invalid location: '%s'" % (args[curArg]))
		if len(rangeTuple) > 1:
			if rangeTuple[1][0] == "+":
				length = int(rangeTuple[1][1:], 0)
			else:
				length = int(rangeTuple[1], 0) - location

			length = (length + 1) & ~1

			if length < 2:
				length = 2

			explicitLength = True

	instmem = gdb.selected_inferior().read_memory(location, length)
	disassembly = jrisc.disassemble(bytes(instmem),
									baseAddress=int(location),
									dsp=dsp, machineCode=showMachineCode)

	if explicitLength:
		print(*disassembly, sep="\n")
	else:
		# Only print the first instruction found. If it wasn't
		# a movei, there could be up to 2 more instructions in
		# the 6 bytes read.
		print(disassembly[0])

class PyJriscDisGpu(gdb.Command):
	def __init__(self):
		super (PyJriscDisGpu, self).__init__("gdisassemble", gdb.COMMAND_USER)

	def invoke(self, arg, from_tty):
		invoke_disassemble(arg, from_tty, False)

# Instantiate the command
PyJriscDisGpu()

class PyJriscDisDsp(gdb.Command):
	def __init__(self):
		super (PyJriscDisDsp, self).__init__("ddisassemble", gdb.COMMAND_USER)

	def invoke(self, arg, from_tty):
		invoke_disassemble(arg, from_tty, True)

# Instantiate the command
PyJriscDisDsp()

class PyJriscGoBreakGpu(gdb.Command):
	def __init__(self):
		super (PyJriscGoBreakGpu, self).__init__("gadvance", gdb.COMMAND_USER)

	def invoke(self, arg, from_tty):
		args = gdb.string_to_argv(arg)

		# Set mem@0x1C to "jr *+0; nop
		gdb.selected_inferior().write_memory(0x1c, b'\xd7\xe0\xe4\x00')

		location = gdb.decode_line(args[0])
		if location[1]:
			syms = location[1]
			location = syms[0].pc
			location &= ~1
		else:
			raise Exception("Invalid location: '%s'" % (args[0]))

		addr = location & 0xfffffffc

		# Convert from gdb.Value to int so that the variables don't
		# continue to track updates to the associated memory locations
		# in the inferior, which would defeat the goal here of saving
		# the old opcodes.
		opcode0 = int(gdb.parse_and_eval("{unsigned long}0x%x" % (addr)))
		opcode1 = int(gdb.parse_and_eval("{unsigned long}0x%x" % (addr + 4)))

		# Set b0 to moveq 0x1c,r30; jump (r30)
		b0 = 0x8f9ed3c0

		# Set b1 to "nop; <second opcode in opcode1>"
		b1 = opcode1 & 0x0000ffff
		b1 |= 0xe4000000

		# If the breakpoint is not long-aligned, shift everything
		# over 2 bytes to compensate.
		if ((location & 2) != 0):
			b0 = opcode0 & 0xffff0000
			b0 |= 0x8f9e
			b1 = 0xd3c0e400

		# Overwrite the instructions at the breakpoint location with our
		# new instructions implementing the breakpoint.
		gdb.execute("set {unsigned long}0x%x = 0x%x" % (addr, b0))
		gdb.execute("set {unsigned long}0x%x = 0x%x" % (addr + 4, b1))

		# Start the GPU
		gdb.execute("gogpu")

		breakHit = False
		while (True):
			ctrl_val = gdb.parse_and_eval("{unsigned long}$jagptr_gctrl")
			if ((ctrl_val & 0x1) == 0):
				print('The GPU self-terminated')
				break

			gpc_val = gdb.parse_and_eval("$gpc()")

			if (gpc_val < 100):
				print('GPU breakpoint hit:')
				breakHit = True
				gdb.execute("stopgpu")
				break

		# Restore the code under the breakpoint and restore G_PC
		gdb.execute("set {unsigned long}0x%x = 0x%x" % (addr, opcode0))
		gdb.execute("set {unsigned long}0x%x = 0x%x" % (addr + 4, opcode1))
		gdb.execute("set {unsigned long}$jagptr_gpc = 0x%x" % (location))

		if breakHit:
			# Disassemble the current instruction if breakpoint hit
			gdb.execute("gdis")

# Instantiate the command
PyJriscGoBreakGpu()
