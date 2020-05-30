;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This program will send the debugger a command that will cause the
; CD BIOS (v4.5) to be loaded (it must be in the current directory)
; into the Jaguar's memory.  Then it will load the table of contents
; from the current CD or emulator setup.  Next it will write out a
; file named TOC.DAT that contains the table of contents information.
; At this point, you can load and debug your CD code.
;
; This code assumes the machine is in an idle state (as in following
; power-on or RESET).
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; WARNING!  WARNING!  WARNING!  WARNING!  WARNING!  WARNING!  WARNING!
; This is strictly for debugging / development purposes only, and is
; not to be used as a shell or example of accessing the Jaguar CD.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Copyright (c) 1995 Atari Corporation, All Rights Reserved
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Commented out lines are not required if this program is being
; called from the MAKETOC.DB script.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.include	"jaguar.inc"
	.include	"cd.inc"

	.68000
	.text

	move.l	#$70007,D_END	; Set up DSP endian mode

;	pea	cmd1		; Command to load CD BIOS
;	move.w	#$f100,-(sp)	; Sending cmd for execution, not msg
;	move.l	#$000b0005,-(sp)
;	trap	#14		; Send to DB head
;	add.l	#10,sp

	jsr	CD_setup	; initialize CD
	move.w	#0,d0
	jsr	CD_mode
	lea	$2c00,a0
	jsr	CD_getoc	; and load up the TOC

;	pea	cmd2		; Command to write TOC to file
;	move.w	#$f100,-(sp)	; Sending cmd for execution, not msg
;	move.l	#$000b0005,-(sp)
;	trap	#14		; Send to DB head
;	add.l	#10,sp

	illegal			; Quit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 	.data
cmd1:
	dc.b	"load cdbios45.db ; g",0

cmd2:
	dc.b	"write toc.dat 2c00[100] ; g",0

	.end

