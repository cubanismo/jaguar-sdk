Jaguar dev tools version 1.01
October 20th 2009 
Linux Version

The following archive contains a suite of development tools for budding Jaguar
developers who use Linux as their main OS.

First off a big thanks goes out to the following people who made this archive
possible with their various jaguar related dev tools.

Dr. Volker Barthelmann and Frank Wille.  For vbcc, vlink, and vasm
SebRmv for his Removers Library, image converter tool, rmvjcp, and gcc build script
Tursi and Kskunk, for the skunkboard and jcp utility
SubQMod for smac and sln

This archive contains the following

Atari's linux dev tools for the Jaguar and associated files.  The main parts are th aln linker, mac assembler, wdb/rdbjag alpine utilities.

GCC retargeted for the 68000 CPU

VBCC retargetted for the 68000 CPU

The Removers library and Jagaur library.

To install do the following.

	untar the archive into your home directory.

	Two sub directories will be created inside your home directory
		jaguar:  Contains the Atari Jaguar tools, VBCC,
			 jcp,smac,sln,converter,vc,vasm,vlink,wdb,rdbjag
			 aln,mac, and various atari samples

		m68k-aout	
			Contains gcc retargetted for the 68000 and 
			the removers library and jaguar library. Move
			the m68k-aout directory to your /usr/local directory.  

			You can put the m68k-aout and its sub directories
			anywhere if you wish, but be aware you need to edit
			any makefiles to reference the location you put it.
			So I recommend just putting them in /usr/local

	Also in your home directory you will find two other files.

		vc.config:	This is the configuration for vbcc.  You have
				two choices.  Leave it in your home directory
				or move it to the /etc directory.  This file
				MUST be in one of those two spots.

		env.sh:		These are the environmental varibales needed
				for proper usage of the dev tools.  You should
				edit your Linux distros shell script to make
				these changes take effect whenever you launch
				a shell.  Most Linux distros use BASH for the
				shell.  So typically you can just add the 
				contents of env.sh to .bashrc or .bash_profile

				Be aware that changes to .bashrc or .bash_profile
				wont take effect in your current shell.  You must
				close it and bring up a new shell

	Once you have extracted the files from the archive in your home directory,
	set the environmental variables as noted above, and either left vc.config
	in your home directory or moved to /etc, you are ready to develop for the
	jaguar.

	Check out the demos in /jaguar/examples for samples of how to use the tools.
	There are three sample programs to test the dev tools with in the examples
	directory.  One is jag256 which does a simple 256 color background image
	with some text on top.  This sample uses gcc as the 68000 compiler and the
	Atari macro assembler mac as the assembler, and Atari's aln for linking.  
	The jaghello example is a simple program that brings up a blank screen and
	puts some text on it.  This sample uses smac for the assembler, and the
	vbcc compiler/linker.  Lastly example1 is an example from Seb on using his
	Removers Library.  

	If your linux OS gives you errors when trying to run mac/aln/wdb/rdbjag
	it is probably because your distro does not enable support for the old a.out
	executable format.   For distros like Ubuntu and Slackware this can be
	fixed by doing an "sudo modprobe binfmt_aout".  This will allow the older
	format executables to run.  You will need to set this to happen every
	boot up or you will have to issue the command manually each time you
	boot Linux.  Each linux distro varies slightly in how this can be
	accomplished.  Some allow editing /etc/modules (Ubuntu variants), some you 
	can put the modprobe command in your /etc/rc.local file. 

	It should also be noted that depending on the version of your Linux 
	kernel you may find that even after loading the binfmt_aout module you
	get a "killed" message when you try to run the old Atari developed binaries
	(mac/aln/rdbjag/wdb).  I have found a fix for this (although not 100% sure why 		it works).  But on Ubuntu variants you can type the following to add the wine 		package to your system.  Something wine installs fixes the "killed" message.  		Install wine under Ubuntu/debian variants like this.

		sudo apt-get install wine

	If you get the killed message and installing wine doesn't help you can simply
	use the fix listed below for wdb and rdbjag to make those programs suid.  Only
	make the suid change to mac and aln if you need to.

	Some linux terminal clients handle the ansi graphics of wdb differently,
	so if your an alpine user you may need to try different terminal clients
	to find one that works well with wdb.  If you dont have an alpine 
	developers board, you can ignore this.   I have found Eterm works well
	with wdb.  Omf reported that installing putty on your linux system give 
	excellent ansi graphics used by wdb.

	Also it should be noted that for wdb and rdbjag users (people with Alpine
	boards) you may need to go into the ~/jaguar/bin directory and edit some of
	the *.db files to path to other files that are loaded in those debug scripts.
	The files in question are.

		cdbios45.db fill.db gpu.db maketoc.db rdb.rc usetoc.db

	Some Linux distros have problems running jcp/wdb/rdbjag without the
	user having root privs.  While you can run them with an sudo command
	it is easier to do the following two commands to make the programs
	suid.   The example below shows how to give jcp root setuid.  If you
	need to do this with wdb and rdbjag just substitude wdb or rdbjag for 
	jcp in the below lines.  Make sure you are in ~/jaguar/bin before running
	the below commands.

		sudo chown root jcp
		sudo chmod +s jcp

	Good luck with the dev tools and if you have any questions feel free to
	drop me an email.

	mhill@hillsoftware.com

