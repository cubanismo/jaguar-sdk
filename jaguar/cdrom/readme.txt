Atari Jaguar CDROM BIOS

Notes for Release 2
	This version adds the CD_getoc call. Other changes also exist in the
	area of performance. These functions REQUIRE the use of the revised
	interface circuitry, as will ALL future versions!

Notes for Release 3
	Two new calls have been added CD_initf and CD_initm. These are
	variants on the setup for CD_read.

	CD_initf 
	The same parameters as CD_init and CD_read is unchanged.
	The differences are:
		1) The block of long align memory in the GPU is 216 bytes long.
		2) Registers r18 thru r31 in bank 0 are used in the transfer.
			They MAY NOT be used in the mainline code.
		3) The code is about 30% faster than CD_init provides.

	CD_initm 
	This call allows for the automatic detection and alignment of data to
	headers that consist of 16 consecutive long words, long word aligned.
	In addition the system will also support continuous storage into a
	circular buffer. These buffers are 2^n long on 2^(n+1) boundaries.
	To allow for these added features, when CD_read is called, after
	CD_initm is used, two new parameters are required:

	d1	Contains the long the defines the data header
	d2	Contains n where the circular buffer size is 2^n bytes. The
		minimum functional size for n is 3. This produces a circular
		buffer 8 bytes (2 longs in length). If the circular buffer
		feature is not needed set d2 to 0.

		Note: The buffer filling WILL stop if the buffer extends past
		      the value in A1 even if a circular buffer is defined.

	The required, long aligned block of GPU memory is 336 bytes long.
	The system performance is less than that of CD_init especially during
	the time that the header is being searched for.

Notes for Release 3.1

	Fixed a stupid mistake in CD_initm, Special thanks to Zareh Johannes and ATD.

Notes for Release 4

	Added CD_switch
	This call allows a game to span multiple discs. When this call is made, the
	system waits for the lid to open, and then closed with a new CD. The new
	TOC is loaded at $2c00 and the CD is left spinning. 
	Assume nothing else such as the CD_mode state.
	Do a CD_stop with acknowledge prior to this call.

	NOTE!!!! Some developer units have no lid. This call will hang forever on these
	machines. Use CD_switch only on systems with lids.

Notes for Release 4.01

	Cleaned up CD_switch a bit.

Notes for Release 4.03

	Cleaned up CD_switch even more

Notes for Release 4.04

	Added error reporting to CD_switch. If the disc during CD_switch has a data
	read or other problem causing an unreadable directory this is reflected as
	a negative number in the first word of the TOC.

Notes for Release 4.05

	Changed the sense of err_flag.
	Changed the time-out scheme on TOC in CD_switch.

