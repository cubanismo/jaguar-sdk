README file for this version of player		1994-Aug-01, nbk

a) I added some nicer examples of films (two sequences from the
beginning of the sequence 'ESCAPE' taken from 'Starwars')

ESC6.CRG 	the first six chunks of the large CD file 
ESC13.CRG	the first thirteen chunks of the same file

Both films are in chunky format, 16 Bit RBG, the film resolution 
is 216x288 and they run 24 frames per second

b) in order to make the buffer large enough for the player to
run all 13 chunks of ESC13.CRG from memory I made the buffer 
size in CINEPAK.INC depending on the existance of the flag 
USE_CDROM. If it is NOT there, then I assume the circular buffer 
starting at CBUF should be $1c0000 bytes long.

c) I wrote an endless version of the player (included as ENDLESS.*)
to check for reliability of the player code.


1994 (c) Atari Corp. Confidential. All Rights Reserved.