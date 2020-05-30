Cinepak Decompression Engine Beta
---------------------------------

This archive contains a new version (1.4) of the Cinepak decompression engine
that includes the following two changes:

1) A new function 'HaltCpk' is exported from codec.o. This function takes no
   parameters, returns nothing, and uses no registers. It sets a semaphore
   causing the Cinepak decompression engine to halt itself safely (i.e.
   the GPU is shut off).

2) The function 'Decompress' now takes an additional parameter. Actually, one
   parameter was shortened to a word and a new word was added. The new
   parameter is the 'PITCH' parameter much the same as the OP and Blitter
   use which defines how many phrases to skip in-between successive phrases.

   The 'PITCH' parameter facilitates double/triple-bufferring schemes by
   causing less page-faults per copy.

   The new calling definition for 'Decompress' is:

   16(a7).l: Return Value
   12(a7).l: Address of auxillary Cinepak Data
    8(a7).l: Address of start of frame
    4(a7).l: Frame buffer address (top left of image)
    2(a7).w: Bytes per row in frame buffer
     (a7).w: Pitch value (0 for no skip, 1 for one phrase, etc...)


The CODEC.O file is a BSD-format object module ready to be linked with ALN.
If your project uses Alcyon format instead of BSD format object modules, you
should switch to using BSD-format if at all possible, as this will give you
longer symbol names, source level debugging, and more flexible symbol
relocation capabilities.  Selecting BSD format is done by using the "-fb"
switch on MADMAC's command line (possibly instead of "-fa") and in most cases
requires no other changes to your code.  (GASM code may require some minor
changes to assemble using Madmac).  If switching to BSD-format is a problem
contact Atari Developer Support for assistance or to obtain an ALCYON-format
version of CODEC.O.

If you have any questions or bug reports, call...

Scott Sanders
Jaguar Guru
Jaguar Developer Support
70007.1135@compuserve.com

