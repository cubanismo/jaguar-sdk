Cinepak Full Motion Video For Jaguar
------------------------------------

The Cinepak Full-Motion Video playback module can be used to play back a
16-bit RGB or 16-bit CRY Cinepak-encoded movie, complete with stereo
sound, on the Atari Jaguar.

While it's true that full-motion video usually involves reading the data
from the CD-ROM drive, the Cinepak module itself does not care where the
movie data comes from, and does not access the CD-ROM drive on its own. 
While there are obvious limitations due to available space, you can have
a cartridge-based program playing a Cinepak movie from memory rather
than reading it from the CD-ROM.

Basically, to play a Cinepak movie from CD-ROM, your program starts
reading the movie from the disc and then feeds the data to the Cinepak
decompression routines.  To play a movie from ROM or RAM, your program
simply points the Cinepak routines at the memory address where the movie
data begins.

The sample Cinepak player program we've included has the option of
playing a movie either from DRAM or from a CD-ROM in the Jaguar CD-ROM
drive.  This is controlled in the source files PLAYER.S and UTILS.S by
a conditional flag at assembly time.  The MAKEFILE for the sample program
shows how you can change this flag to build either a CD-ROM player or a
DRAM player.

Cinepak movies are highly compressed, but full-motion video still takes
a lot of space (which is why you normally do it from CD-ROM where that's
not a big problem).  In order for a movie to be small enough to fit into
a cartridge, you either have to have a full screen movie that's only a few
seconds long, or a movie that takes up a smaller portion of the screen
(but which runs more than a few seconds).

There are several sample movies that can be played full-screen directly
from DRAM.  Each of these only lasts for a few seconds, but they serve
to show the possibilities open to you using Cinepak.  These movies are
available online on the Atari Developer BBS and on Compuserve, or
directly from Jaguar Developer Support.

For those developers with a CD-ROM development system, we can also make
available a sample CD-ROM disc with several movies on it.  Please
contact Normen Kowalewski at (408) 745-2127 for more information.

Files - What's what?
--------------------

Directory                  Description of Contents
-----------------------------------------------------------------------------

JAGUAR\CINEPAK             This is the main directory containing everything
                           else.  The README.TXT file is located here.

JAGUAR\CINEPAK\DECOMP      This directory contains the linkable object
                           modules with the Cinepak decompression routines.


JAGUAR\CINEPAK\MOVIES      This directory is where the sample movies are
                           located.  There is also a version of the
			   player program that is configured to play the
 			   smaller movie files from DRAM.  Each of
			   these movies has a debugger script file to
			   automate the process of loading and playing them.

			   Movies in the 16-bit RGB file format should
			   use a filename extension of .CRG and 16-bit
			   CRY movies should use an extension of .CCR.


JAGUAR\CINEPAK\SAMPLE	   This directory contains the source for the
			   player program.  You can switch between a
			   CD-ROM player and a DRAM player by changing a
			   flag in the MAKEFILE.

