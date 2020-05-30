*****************************************************************************
              CONFIDENTIAL INFORMATION - PROPERTY OF ATARI CORP.
*****************************************************************************
                      Cinepak Scaling/Rotation Demo v1.5
                         Copyright (c)1995 Atari Corp.
                               by Scott Sanders
*****************************************************************************

=============
INTRODUCTION
=============
This demo was constructed to illustrate some of the ways the Cinepak Player
code can be integrated into a typical high-demand gaming environment. The
Cinepak Player code was never meant to be a 'black box' solution. Instead,
both this demo and the original sample player were meant to contain some
reusable code but mostly be examples how to access the Cinepak decompression
engine.

==============
USING THE DEMO
==============
This demo code is meant to work with a Jaguar format CD-ROM where the boot
track is the first track of the second session (Session #1) and data follows
on each subsequent track. The demo code contains two equates at the top of
PLAYER.S as follows:

START_SESS	equ	1
START_TRACK	equ	1

START_SESS selects the initial session to begin looking for movie files in.
START_TRACK (zero-based) selects the track offset within that session. The
demo will begin searching for a new movie per track until the last track is
reached at which point it will start from the begin point specified
(essentially looping).

If you have a CD setup like this great. If you have a CD where the movies
start on Track #1 Sess #0, just set both values to 0.

This demo will _not_ work well using the CD emulator unless you are using
movies with a fairly low data rate (probably 220k or less). It requires the
latest rev of the Cinepak player (1.2) that supports phrase interleaving.

The demo will allow you to playback any image up to 320x240 (don't hand it
one bigger because it doesn't error check and will die quite ungracefully).
This isn't a limitation of Cinepak, simply the way the demo was built. While
you can scale any image, you can only rotate 160x120 images. It is actually
possible to rotate just about any image running at a lower frame rate (i.e.
15 fps), however most of our movies run around 260-280k.

Here are the controls:
Joypad		- Move image
B+Joypad	- Scale image
1		- Reset aspect ratio
C		- Reset all settings
4		- Rotate counterclockwise
6 		- Rotate clockwise
OPTION 		- Flip screen horizontally
A+Joypad Left 	- Previous movie
A+Joypad Right 	- Next movie
A+# sequence 	- Select that movie (relative to first
0 		- Mute sound
*+# 		- Reset to first movie

This demo expects movies to contain the 'extra' AIFF wrapper. The Atari track
header and tailer are optional. In reality, a Cinepak player should probably
just use a .CRG and search for the track header or a partition marker. Some
of our demo movies already contain the wrapper so what the heck.

===============
CODE HIGHLIGHTS
===============

Startup
-------
This demo uses our standard startup code (shown here in STARTUP.S) which now
uses the GPU to set the OLP _always_.

GPU Usage
---------
1. Startup Stub (GPUSTART.S) - This stub configures interrupts and launches
(jumps to) the Cinepak Player code after switching to the secondary register
bank. This allows Cinepak an entire set of registers while interrupts chew up
as many as they want.

2. OP Interrupt Handler (GPUSTART.S) - Because the CD-BIOS needs to access
the bus so frequently, a 68k interrupt handler that maintains the object list
is out of the question. This handler does the work in the GPU.

3. PIT Interrupt Handler (GPUSTART.S) - The original player code timed
playback based on the 60Hz vertical frame interrupt. This demo uses Tom's PIT
to generate a 600 Hz timer which is better for films because its divisble
evenly by 12/15/24/30.

4. DSP Interrupt Handler (CD-BIOS) - The CD-BIOS uses this interrupt to
handle requests from Jerry.

5. Cinepak Decompressor - This is the latest greatest code that supports
phrase interleaving and a reliable way to stop itself.

6. CPU Interrupt Handler (GROTATE.S) - This handler takes a parameter which
if 0 means calculate a rotation based on some other parameters and fire the
blitter (you'll probably recognize the rotation code from the Jagrot Demo).
Otherwise, use the parameter to plug the OLP with a new value.

68k Interrupts
--------------
Because timing and object list update were moved the the GPU, only GPU
interrupts need to be supported now. This is found in INTSERV.S

Table of Contents
-----------------
This demo uses the TOC it finds at $2C00 to locate movies from. If you aren't
using this from a bootable disk (which you probably aren't), you should
preload the TOC of your disk to $2C00. A nice bunch of code you can lift from
here is TOCREAD.S

DSP Audio
---------
This demo contains an almost completely rewritten audio daemon though it is
backwardly compatible. We have recently defined an additional chunk that may
be inserted manually or with a tool that has yet to be developed. This was
done mostly for this demo but may be of use if you plan to do titles that
have movies of varying audio content. Look for this in DSPCODE.S.

The Audio Data Description chunk follows the Frame Description Atom (if
present) and looks like this (each row is a longword):

'ADSC'
AtomSize (20)
Audio Data Description
SCLK Rate
Drift Rate

The Audio Data Description is a bit mask array as follows:

Bit(s)	Meaning
------  -------
  0	0 = Mono, 1 = Stereo
  1	0 = 8-bit, 1 = 16-bit
 2-7    Compression Code
	0 = Uncompressed
	1 = n^2 Compression
 8-30	Reserved
  31	Two's Complement Flag

The SCLK rate is the exact value to plug into Jerry's SCLK register and the
drift rate is a 0.32 number that is added each sample period to an
accumulator that causes a sample to be skipped when an overflow occurs.

If an Audio Description Atom isn't found, that's ok, it'll just default to
standard audio (22.252kHz 8-bit mono).

Error Checking
--------------
This demo does do some more error checking (though not as much as probably
should be done like checking for hard errors). It will normally try to skip
to the next key frame if it can.

PLEASE NOTE!!! Cinepak frames contain embedded offsets which are used to
compute addresses. If a hard CD error occurs and one of these values happens
to be affected, a 68k address error could occur. You must protect against this
in commercial game code. If a CD error is reported by CD_ptr you should
invalidate any data before the reported error and at least 16k past it. Either
way reread the data, skip ahead in your movie, or stop altogether.

Joystick Reading/Scaling Computations
-------------------------------------
All joystick reading and scaling computation is done at the head of the Sample
loop. There are a few bad things about this design. One, the joystick read
frequency is dependant on the frame rate, and two, if video is lagging for
some reason, it should probably skip the joystick read since this is the 68k
we're talking about. All of this is done in SCALVARS.S

Buffering (Triple)
------------------
To display an image without tearing, I have implemented a triple buffering
scheme that seems suitable to Cinepak. One buffer is constanly being used as
a decompression buffer (handed to Decompress). Remeber that Cinepak must
always have the contents of the last frame to work from.

After Decompress is done, a blit (either rotated in pixel mode or copied in
phrase mode) is made to the buffer currently _not_ being displayed. A flag is
set after the blit completes so the screens are swapped at the next vertical
blank.

If we were in rotation mode, another phrase mode blit must be done to the now
non-displayed screen to clear it (so we don't get rotation trails).

Please note that an added feature of the new Cinepak decompressor is
phrase-interleaving which is used in this demo. All three buffers are
interleaved so that blits occur much faster (less DRAM page faults).

========
COMMENTS
========
If you have any	questions or comments regarding this code, please call:

Scott Sanders
Jaguar Guru
Jaguar Developer Support
(408) 745-2143
Internet: 70007.1135@compuserve.com
