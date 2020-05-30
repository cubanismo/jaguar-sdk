MAKETOC & USETOC
----------------
MAKETOC and USETOC are a combination of script files for the DB debugger and 
Jaguar executable programs which are designed to streamline the process of
initializing the CD during the development process 

  MAKETOC Overview
  ----------------
  MAKETOC is designed to load the Jaguar CD BIOS from your development system 
  host computer's hard disk into the Jaguar console's RAM.  Then it reads the
  TABLE OF CONTENTS information from the current CD or from the Jaguar CD
  Emulator.  Finally, it saves the TABLE OF CONTENTS information out to
  a TOC.DAT file.


  USETOC Overview
  ----------------
  USETOC is designed to load the Jaguar CD BIOS from your development system 
  host computer's hard disk into the Jaguar console's RAM.  Then it reads the
  TABLE OF CONTENTS information from a TOC.DAT file in the current directory.


Usage
-----
Normally you would load the USETOC script at the start of a debugging 
session to load the CD BIOS and the current TABLE OF CONTENTS information.
Then you would only need to load the MAKETOC script when you changed the 
contents of the CD and need to insure that the TABLE OF CONTENTS information
is current and correct.


MAKETOC Details
---------------
To use MAKETOC, load the debugger (WDB or RDBJAG) and type the command
"load maketoc.db".  This will load and execute the MAKETOC script.

MAKETOC.DB first loads the CD BIOS files, then it calls the MAKETOC.COF 
executable file, which is responsible for reading the current TABLE OF CONTENTS
into the Jaguar's RAM.  Finally, it writes out a new TOC.DAT file.  If there
is an existing TOC.DAT file, the debugger will ask you if you're sure that you
want to overwrite it.

Note that TOC.DAT is written to the current directory, and you can have
different versions in different directories.  So you can have multiple 
copies for different projects or different discs as required.

The MAKETOC.COF file loaded by the MAKETOC.DB script loads to address $4000
and uses just a small amount of memory.  However, if loading to this address
is inconvenient, the source code for MAKETOC.COF is included in the directory
\JAGUAR\CDROM\DEBUG_CD.  You can easily change the MAKEFILE to specify a
different load address, then rebuild MAKETOC.COF.

Once MAKETOC is finished, you can exit the debugger or load another program
or script to begin the rest of your debugging session.


USETOC Details
--------------
To use MAKETOC, load the debugger (WDB or RDBJAG) and type the command
"load maketoc.db".  This will load and execute the MAKETOC script.

USETOC.DB first loads the CD BIOS files, then it reads the TOC.DAT file
from the current directory into the Jaguar's RAM.

Once USETOC is finished, you can begin the rest of your debugging session.

The \JAGUAR\CDROM\DEBUG_CD directory contains a MADMAC source file named
USETOC.S.  This is a Jaguar program that communicates with the debugger and
does basically the same thing as the USETOC.DB script.
