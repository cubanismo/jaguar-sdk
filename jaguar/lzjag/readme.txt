This archive contains code and tools necessary for doing LZSS compression
on the Jaguar. LZSS is an efficient, yet lossless compression scheme
that works well with both program code as well as graphics data or sound
samples.


NEW INCLUDES
------------
WARNING!!! The source in this archive requires the newest versions of
the Jaguar system include files (dated Sept 22, 1994 or later).  If you
do not have these include files, you should download the latest INCLUD.ZIP 
file from the Atari developer area on Compuserve or from the Atari
Software Development BBS.



COMPRESSOR/DECOMPRESSOR UTILITY
-------------------------------
The Compression/decompression utility is named LZJAG.  It gets extracted
to the JAGUAR\BIN directory.  It is very simple to use.  A command like:

lzjag -c file.bin

will create a file named FILE.LZJ that is compressed. A command like:

lzjag -x file.lzj

will create a file named FILE.BIN that is decompressed. Please note that
the LZJ files created have no header; they are raw compressed data. 
Therefore, you could potentially try to decompress a file that isn't 
actually compressed and get strange results.




LZJAG
-----
The JAGUAR\LZJAG directory contains the decompression routines and a
test program that demonstrates how to use them.  The decompression
routines are contained in DELZJAG.S, which must be assembled and
linked with your code. To use the Jaguar GPU compressor you must:

1. Copy (or better yet Blit) the GPU code from the ROM into GPU RAM. It is
   currently assembled to run at $F03100 but that can be changed by
   changing the .ORG statement in the DELZJAG.S file appropriately.

2. Write the address of your compressed data and an output buffer to
   addresses 'lzinbuf' and 'lzoutbuf' respectively.

3. Write the address of a usable 8k block of buffer memory to 'lzworkbuf'.

4. Load the GPU PC counter with the address of the routine ('delzss') and
   start the GPU

5. If you have other things to do that take time and don't use the GPU
   or any of the above buffers, do them.

6. Finally, poll the G_CTRL register to ensure the decompression is
   finished.  The GPU will turn itself off when done.  You can change
   this by editing DELZJAG.S if necessary.


Things to be aware of: This subroutine does not use a stack but does use
(and trash) registers r0-r19 though you can start the GPU in either register 
bank.



TEST PROGRAM
------------
The other source code files in this directory are for the sample program
that demonstrates the decompression routines.  They make to form a short
stub that follows the above procedure to decompress a 4k block of 
compressed data into 26k of code at $100000 and then executes it (it 
displays the Jaguar logo).



IN CLOSING...
-------------
The source code for LZJAG is available if you need it for some reason.
It was built using Microsoft C/C++ 8.0 (Visual C++ v1.5) using the Huge 
memory model.  Please contact me for more information, or if you have
any questions.

Scott Sanders, Atari Corp.
1196 Borregas Ave.
Sunnyvale, CA  94089
Tel: (408) 745-2143
Fax: (408) 745-2088
Compuserve: 70007,1135
Internet: 70007,1135@compuserve.com
