-----------------------------------------------------------------------------
                        Jaguar Program Startup Code
                    Copyright (c)1995 Atari Corporation
                CONFIDENTIAL MATERIAL PROPERTY OF ATARI CORP.
-----------------------------------------------------------------------------

Introduction
------------
Starting up a Jaguar (initializing video, the object list, etc...) is the 
most important thing a program must do correctly. This startup code 
(STARTUP.S) performs all of the program initialization correctly and 
must _always_ be used. Modifying, reordering, or omitting any part of 
this startup (except where noted) will likely cause your software to fail
our hardware testing procedures.

How to Use It
-------------
Link STARTUP.S first to make it the first code to be executed. Do not 
perform any initialization of any kind prior to running this startup 
code. When this code finishes it will jump to the label '_start' to enter 
your code.

What Does It Do?
----------------
Our startup performs the following steps:

1. Sets GPU and DSP Endian registers correctly.

2. Disables video refresh.

3. Sets the 68k stack pointer to the end of DRAM.

4. Initializes video registers.

5. Creates an object list as follows:

           BRANCH Object (Branches to stop object if past display area)
           BRANCH Object (Branches to stop object if prior to display area)
           BITMAP Object (Jaguar License Acknowledgement - see below)
           STOP Object

6. Installs an interrupt handler, configures VI, enables 68k video interrupts,
   lowers 68k IPL to allow interrupts.

7. Uses GPU routine 'gSetOLP' to stuff OLP with pointer to object list.

8. Turns on RGB video ($6C7 in VMODE).

9. Jumps to _start (your supplied code).

As soon as your code gains control you should perform whatever other
initialization tasks your code may need to allow the graphic to be on screen
for a reasonable amount of time.

When you need to transfer control to your object list (for your title screen
or whatever else) you should poll the variable 'ticks' for a change. At this
point (vertical blank) you should switch interrupt handlers (by placing a new
value at LEVEL0 $100) and change the OLP. Remember, the OLP should only be
changed by the GPU (you can use our DRAM routine if the GPU isn't already
running).

The Licensing Graphic
---------------------
Included with STARTUP.S are two licensing graphics (the one you use depends
upon the conditions indicated below). The use of this specific graphic is
optional and the places in the code where it may be replaced are indicated.

The "license_logo" macro at the top of STARTUP.S defines the name of the
graphic file used.  The 'Licensed to Atari' graphic should only be used by
subcontractors working for Atari who are doing a port of an existing game 
created by a company other than Atari. The 'Licensed by Atari' graphic should
be used in all other cases.

If you just want to change graphic shown, the "license logo" macro definition
and the equates just above it should be all you need to change in STARTUP.S.

-----------------------------------------------------------------------------
WARNING!!! The default startup graphic will be located in ROM. This is not
too terrible a thing if only one small bitmap is on screen (ROM accesses are
much slower than RAM accesses). Due to an Alpine Bug, however, displaying
an in-ROM bitmap with an object-list in the low 64k of RAM will cause the
memory location(s) being updated during the vertical-blank (the first
phrase of the bitmap) to be shadowed $800000 above (unfortunately, usually
smack dab in the middle of your game code). The solution is to write-protect
the Alpine, move the bitmap to RAM, or move the object list higher up in RAM.
-----------------------------------------------------------------------------

Questions?
----------
If you still have questions, please contact:

Scott Sanders
Jaguar Guru
Jaguar Developer Support
(408) 745-2143
Compuserve: 70007,1135
Internet: 70007.1135@compuserve.com
