-----------------------
IMPORTANT NOTE! 2/13/95
-----------------------

The BPEG utilities, decompression routines, and sample code are intended
as complete replacements for the JAGPEG files previously distributed.
If you are using the JAGPEG utilities and decompression code, you should
check out the new BPEG stuff.  The top ten reasons you should use BPEG
instead of JAGPEG are:

10) BPEG features a single step conversion/compression utility.
    The JAGPEG utilities used a multi-stage conversion/compression
    process that had memory problems on some systems.

9)  BPEG does a better job of compressing the image than JAGPEG does,
    without additional loss of image quality.  This means you can use
    a slightly higher quality setting and get the same compression
    ratio you get now.  Or you can use the same quality setting and get
    even higher compression ratios.

8)  BPEG's conversion utility understands several input formats such as
    GIF and TARGA.  The JAGPEG conversion process required 24-bit Targa
    files as input and wouldn't work with anything else.

7)  BPEG is faster than JAGPEG.

6)  BPEG can decompress images into CRY mode, even if the source picture was
    RGB, saving you at least one, if not two, steps.  JAGPEG worked only with
    RGB images.

5)  BPEG is much, much faster than JAGPEG.

4)  BPEG only requires a single output file for the compressed images, and
    one source file for the decompression routines.  JAGPEG created an image
    file for each picture, a separate data table for each quality setting,
    and two more files for the decompression routine code and data table.

3)  BPEG is a whole lot faster than JAGPEG.

2)  BPEG comes with the complete source for the decompression routines,
    so you can customize it as needed for your project.

1)  Did we mention that BPEG is really much, much, much faster than JAGPEG?
    It cooks!  It smokes!  It leaves JAGPEG in the dust!

----------------------------------------------------------------------------

BPEG Compression Utility

The BPEG compression utility (CBPEG.EXE, CBPEG.TTP) is a modified version of
the JPEG encoder version 4.0, written by the Independant JPEG Group (IJG).
It can take GIF/TARGA/PPM/RLE image files, and output a BPEG file directly
usable by the decoder.  There is no need for another program unless your
images must be converted from other picture file formats.

Usage:

	cbpeg [switches] inputfile outputfile

Switches (names may be abbreviated):

	-quality N     Compression quality (0..100; 5-95 is useful range)

	-targa         Input file is Targa format (usually not needed)

	-smooth N      Smooth dithered input (N=1..100 is strength)

	-maxmemory N   Maximum memory to use (in kbytes)

	-verbose       Emit debug output

	-debug         Emit debug output (same as -verbose)

	-qtables file  Use quantization tables given in file

Example:

	CBPEG -targa -quality 80 image.tga image.bpg

This will convert the Targa file named IMAGE.TGA into a compressed image
file named IMAGE.BPG using a quality setting of 80%.

The lower the quality setting, the higher is the compression ratio.  Higher
compression ratios come at the cost of lower image quality.

----------------------------------------------------------------------------

The BPEG.S file contains the source for the BPEG decompression routines.
This file contains several flags which customize the operation of BPEG.
While these flags are meant to be used at assembly time, you may wish to
modify the code so that they may be set at runtime.

The flags CRY15, CRY16, RGB15, RGB16, RGB32 control the output mode of
the decompressor.  One of these must be set to TRUE (non-zero) and the
others set to FALSE (zero).

The decoding steps are:

1: Call 'BPEGInit' (no input or output parameters).

2: Call 'BPEGDecode'

   Input:

	A0 is the BPEG stream pointer
	A1 is the output buffer address
	D0 is the output buffer line width (in bytes)

   Output:

	D0 = 0 (no problem)/ 1 (bad format)

3: Test 'BPEGStatus' (long value).  Possible values are:

    -1 (decoding)
     0 (finished)
     2 (decoding aborted, Huffman error)


If you want to decode another image, just go to step 2.


What exactly these functions do?
--------------------------------

'BPEGInit' copies the GPU code in the GPU RAM, without using the blitter.
You can change this if the blitter is not used at this moment.

'BPEGDecode' sets some variables in the GPU, and run it.  The GPU uses (and
so corrupt) ALL REGISTERS FROM BOTH BANKS, and almost all GPU memory (the
amount of memory used depends of the chosen output mode).

If you require that some GPU registers be left alone (like for interrupt
processing), then you will have to edit the BPEG.S source file so that it
leaves a few registers free.   However, recognize that this will result in
slower decode times.

Note: If you're decoding an image in CRY15/CRY16 modes, you must have the
32Kb RGB->CRY conversion table, and declare the GLOBAL symbol 'CRYTable',
at the start of the table.  This table is included in the file RGB2CRY.S.

Tip: Don't forget that cartridge access is slower than RAM access. It's a good
idea to copy some of the BPEG tables in RAM, before running the decoder, for
ultimate speed.

----------------------------------------------------------------------------

If you find some good speed improvement on this code, it's a good idea to
contact Brainstorm, in order that they may implement it for a new release.
Contact Brainstorm at:

Fax:   +331-44670811 (France)
BBS:   +331-44670844 (France)
Email: raphael@brasil.frmug.fr.net

----------------------------------------------------------------------------

The sample code for BPEG is a revision of the sample code provided with
the JAGPEG distribution.

TESTBPEG is a sample program for the Jaguar that demonstrates how to take the
files created with the BPEG tools and use them in a program with the BPEG
routine and tools.

This sample program is similar to the programs in the EXAMPLES directory for
the most part, except that it sets up the video a bit differently with a
16-bit RGB mode instead of 16-bit CRY, and a creates a 16-bit RGB bitmap
object instead of an 8-bit palette-based object.  This is, of course, to
accomodate the JPEG pictures which the program displays.

The interesting parts of this are in the TEST.S file, which sets up and calls
the DEJAG routine to display the pictures.  It switches back and forth between
two different pictures which were compressed with different quality settings.
One of the pictures is the default 75% quality, the other is set to only 25%
but still manages to look pretty decent.

Also take a look at the MAKEFILE, which shows how the .BPG picture files are
included in the program.  It also shows how you can specify a command input
file for the ALN linker to get around the 128-byte MSDOS commandline length
limitation.

If there are any questions, comments, bugs regarding this demo program which
you'd like to throw my way, contact me at any or all of the following:

Mike Fulton
Atari Corporation
1196 Borregas Ave.
Sunnyvale, CA  94089
Tel: (408) 745-8821
Fax: (408) 745-2088
Compuserve: 75300,1141
GEnie: MIKE-FULTON
Internet E-mail: 75300.1141@compuserve.com

----------------------------------------------------------------------------
Changes: 02/13/95
----------------------------------------------------------------------------

The 8Kb buffer 'DataBitsBuffer' used in earlier versions is not needed
anymore (the STATIC_TABLE equate doesn't exist).  So, the 'InitBPEGTable'
function is also removed.  The only functions are now: 'BPEGInit' and
'BPEGDecode'.

The decoder is between 7~10% faster (Huffman decoder improvements).

There is now a LINUX version of the CBPEG encoder program.


