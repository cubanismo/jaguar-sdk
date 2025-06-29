# Jaguar SDK/Development Tools

This is an updated version of the Jaguar development tools released by Belboz here:

https://www.hillsoftware.com/files/atari/jaguar/

Some relatively minor cleanups have been performed to modernize the tools a bit and perform minor reformats such as fixing character encodings, line endings, add minimally invasive work-arounds for compiler or assembler bugs (e.g., replace XDEF with .globl), replace "illegal" instructions at the end of some samples with infinite loops that play nicer with virtual-jaguar and BJL/skunkboard-based development environments where a debugger isn't generally attached.  The Makefiles have been similarly reworked to use a unified set of common rules defined in tools/build/jagdefs.mk and tools/build/jagrules.mk rather than duplicating them (with slight variations) throughout all the samples.

## Tools

Whenever possible, the tools are provided as source code.  This helps future-proof things, given some of the original files are only available as DOS binaries or ancient statically-linked Linux a.out binaries that won't run on modern kernels.  Where source isn't available, replacements have been provided (mac->rmac, aln->rln for example), or wrapper scripts have been written to allow running the DOS binaries using dosemu, which allows them to be integrated into Makefiles just as they were in the original DOS SDK.

## Differences Vs the Belboz Development Tools

Besides those mentioned above, there were a few other changes made:

* The Removers library is not currently included.  No reason other than I haven't gotten around to integrating it.
* VBCC/VASM have been dropped.  Use GCC and rmac/rln or mac/aln instead.
* smac/sln are replaced with rmac/rln.
* The goal is to provide a unified DOS/Windows and Linux SDK, rather than two separate but very similar packages.  Currently, only Linux is supported, but all the DOS binary-only programs are included.
* As mentioned, most tools are provided in source code form out of the box, and must be compiled before you can start developing.  A helper script is provided.  See the instructions below.
* I found source for and included some tools that weren't previously available in Belboz's Linux SDK: 3dsconv (Version of 3ds2jag/3ds4jag compatible with the latest version of the 3D library) and tga2cry (The Atari version).
* The 3D library & demo are updated to the latest version available, slightly newer than the one included in the Belboz SDK.  The Belboz version never worked for me, while this one does.  It's not quite a straight replacement though: I took the liberty of merging in all the models from the older demo to make it a superset of the two versions.
* I've included a copy of the scanned original Atari developer documentation
files in jaguar/docs/dev/ for easy reference.  These are provided separately
as jagdox.zip on Belboz's site, and I believe were originally released by
Lars Hannig (according to his web page).

## Build/Installation

Prepare your system.  You'll need the prequisites required to build gcc from source, git to fetch the source, and libusb 0.9 (Named libusb-compat on some distros) development files/headers to build jcp (If you don't need jcp, just comment that section of the tools build script out).  You'll alsso need some python development tools to built the GDB python support and the JRISC tools python module used by GDB for JRISC disassembly. Optionally, you'll need dosemu to use the DOS-only tools from Linux.  Most projects and included sample code won't need these, but a couple of things, namely the Music/synth demos, do still require them.  On Ubuntu, this should be sufficient to get everything:

````sh
$ sudo apt install build-essential gcc-multilib git libusb-dev libncurses5-dev libpython3-dev python3-pip dosemu
````

On Arch, you'll need to enable multi-lib, then this should work:

````sh
$ sudo pacman -S base-devel git wget python-pip dosemu
````

If building on a 32-bit system, you can omit `gcc-multilib`.

If you installed dosemu, you'll need to tweak the configuration slightly to avoid most of the tools crashing immediately for some reason:

````sh
$ echo "\$_cpu_emu = \"full\"" >> ~/.dosemurc
````

Next, clone this repository from github, including all submodules:

````sh
$ git clone --recurse-submodules https://github.com/cubanismo/jaguar-sdk
````

Finally, build the tools which are provided as source:

````sh
$ cd jaguar-sdk
$ ./maketools.sh
````

## Docker Image

The SDK is also available as a docker image for those who prefer a ready-made environment. Assuming you have docker installed and configured on your system, you can fetch it using this command:

    $ docker pull cubanismo/jaguar-sdk

And then start an interactive session in it, mapping in a project in your home directory named 'MyJagProj' for building, build it, and exit, deleting the container and leaving you with a built project in your home directory.

    $ docker run --rm -it -v ~/MyJagProj:/MyJagProj cubanismo/jaguar-sdk
    # cd /MyJagProj
    # make
    # exit

## Usage/Examples

Once you have the tools built, you're ready to go.  Just source the env.sh file to add everything to your path and set up some other environment variables used by some of the tools.  There should be no need to edit this file 99% of the time, but it does use some bash-isms to find itself on the filesystem, so if bash isn't your thing, edit it and hard-code the path to the SDK directory or replace the first few lines with something that works in your shell of choice.

````sh
$ . env.sh
````

And that's it.  Looking for somewhere to start?  Try building the hello world sample project:

````sh
$ cd jaguar/examples/jaghello
$ make
````

Then either fire it up in virtual-jaguar:

````sh
$ virtual-jaguar jaghello.cof
````

Or run it on real hardware with a skunkboard:

````sh
$ jcp jaghello.cof
````

Or if you're old-school, BJL:

````sh
$ lo_inp -8 jaghello.cof
````

If you want something that works out a few more transistors, try the 3D demo:

````sh
$ cd ${JAGSDK}/jaguar/3d
$ make
$ jcp demo.cof
````

Have fun!  If somethings broken, file an issue or (preferably), create a pull request.

## Credits/Thanks

* Hill Software/Belboz: https://www.hillsoftware.com/files/atari/jaguar/ - Original development tools package
* Lars Hannig: http://www.larshannig.com - Atari Developer Documentation Scans
* ZeroSquare: lo_inp
* Harmless Lion/Tursi: http://harmlesslion.com/software/skunkboard - Skunkboard and JCP
* Reboot: https://www.reboot-games.com and http://reboot.untergrund.net - rmac/rln, pc_jagcrypt, and misc. other tools not included here.
