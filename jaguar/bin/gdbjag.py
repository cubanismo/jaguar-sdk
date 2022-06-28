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
