; Skunkboard console support functions (68k)
; Code by Tursi/M.Brent http://www.harmlesslion.com
; Orig:5 July 2008
; Rev: 3 Sep 2008  - added skunkNOP
; Rev: 7 Sep 2008  - added double confirm with data from PC, increased timeouts
; Rev: 16 Oct 2008 - Made the console close function wait for both buffers
; Rev: 23 Nov 2008 - added alignment instructions
; Rev: 15 Feb 2009 - Make console close wait for PC acknowledgement
;					 Added bank switch helpers and 6MB mode handling
; Rev: 30 Jul 2009 - Fixed timeout loops from dbra to regular count so they aren't limited to 16-bits!
; Rev: 21 Sep 2020 - Fixed skunkFILEREAD return value to fill entire d0 long word.
; 
; This file is licensed freely and may be used for any purpose, commercial or
; otherwise, without notice or compensation.
;
; All console functions will delay if buffers are full, 
; and will time out if they stay full. If the console reconnects
; then they should resume but previous accesses are lost.
; If your program *relies* on the console input then it
; should test skunkConsoleUp after a call.
;
; You should not use these functions in your production cartridge,
; rather create dummy stubs that do nothing or comment the calls out 
; in your code. Without the Skunkboard they may work, they may not, 
; there are no guarantees.
;
; None of these functions are 'thread safe' so you should resist
; calling them from interrupts.
;
; All addresses must be on a word boundary. All lengths must be
; even, except text writes may be an odd count (but an even number
; of bytes are still read and transmitted).
;
; Note that SebRmv has an alternate higher level support library
; with more functionality available in the Removers library, check out 
; http://removers.online.fr/softs/download.php

; skunkRESET()
; Resets the library, marks the console as available, and
; clears both buffers. 
;
; skunkRESET6MB()
; Same as skunkRESET, but use this one if you are running
; the flash in 6MB mode. This is necessary because 6mb mode and
; the console are slightly incompatible, so the code needs
; to know to turn it back on. Even so, this is a hack - 
; the console should never be used from a 6MB ROM as it
; will crash if it's not in the first 4MB of the first bank
;
; skunkNOP()
; No action, no options. Can be useful to start a program
; with two NOPs to guarantee synchronization of the buffers
; with the PC console.
;
; skunkCONSOLEWRITE(a0)
; Write text to the console, if it is active
; a0 - address of the text to be written, terminated with a 0 byte
; Will write to either buffer, whichever is free first. Note that
; if the length is not an even number, one additional byte will be
; sent to the PC, though it should not be printed.
; You can clear the screen in Windows as of JCP 2.3.2 by sending a 
; form-feed character (ASCII character 12)
;
; skunkCONSOLECLOSE()
; Instructs the console to close. No arguments.
; Expects the console is closed after the fact.
;
; a0=skunkCONSOLEREAD(d0)
; Reads text from the console keyboard and returns it at a0,
; which is a buffer d0 bytes long. The maximum return is 4064 bytes.
; Note the returned string is NOT necessarily NUL terminated,
; so you can't just turn around and print it!
;
; skunkFILEOPEN(a0,d0)
; Opens a file on the PC in the current folder (paths are not supported)
; a0 - points to the filename, terminated with a 0 byte
; d0 - 0 for write mode. 1 for read mode.
; This function will wait until the PC acknowledges the buffer
; to reduce ordering problems.
;
; skunkFILEWRITE(a0,d0)
; Writes a block on the PC to the currently open file (if open to write)
; a0 - points to the data - will be updated!
; d0 - number of bytes to write, up to 4060. (must be even)
; This function will wait until the PC acknowledges the buffer
; to reduce ordering problems. There's no guarantee of actual write,
; only that it was sent to the PC.
;
; a0=skunkFILEREAD(d0)
; Reads data from the currently open file (if opened for read)
; which is a buffer d0 bytes long. The maximum return is 4064 bytes.
; d0 is updated with the actual number of bytes read. If 0, either
; EOF or an error occurred. a0 is also updated.
;
; skunkFILECLOSE()
; Instructs the currently open file to close. No arguments.
;
;---------------------------------------------------------------------

	.extern skunkRESET
	.extern skunkRESET6MB
	.extern skunkNOP
	.extern skunkCONSOLEWRITE
	.extern skunkCONSOLECLOSE
	.extern skunkCONSOLEREAD
	.extern skunkFILEOPEN
	.extern skunkFILEWRITE
	.extern skunkFILEREAD
	.extern skunkFILECLOSE

;---------------------------------------------------------------------
		.long

timeout	.equ	200000

; skunkRESET()
; Resets the library, waits for the PC, and marks the console up or down
skunkRESET::
		movem.l	a1-a2,-(sp)

		move.w	#$4001,skunkReadMode	; ensure normal 4MB mode set

continueRESET:
		move.l	#-1,skunkConsoleUp		; optimistic!
		
		bsr		setAddresses		; get HPI addresses into a1 & a2
		; try and get both buffers, that tells us the console is up
		bsr		getBothBuffers		; also sets skunkConsoleUp

		bsr		restoreMode			; set correct flash mode
		movem.l (sp)+,a1-a2			; Restore regs
		rts
		
; skunkRESET6MB()
; Same as skunkRESET, but use this one if you are running
; the flash in 6MB mode.
skunkRESET6MB::
		movem.l	a1-a2,-(sp)

		; set bank 0 and enable 6MB mode
		move.w	#$4BA0,(a1)				; select bank 0
		move.w	#$4003,skunkReadMode	; will enable 6MB mode. Note, this disables EZ-HOST reads
		
		bra		continueRESET

; skunkNOP()
; No action, no options. Can be useful to start a program
; with two NOPs to guarantee synchronization of the buffers
; with the PC console.
skunkNOP::
		movem.l	d1/a1-a2,-(sp)

		bsr		setAddresses		; get HPI addresses into a1 & a2
		bsr		getBuffer			; get a free buffer into d1
		tst.l	d1
		beq		.exit				; if we didn't get a buffer, return
		
		move.w #$4004,(a1)			; enter HPI write mode
		move.w d1,(a1)				; set HPI write data address
		move.w #$ffff,(a2)			; write data
		move.w #$0000,(a2)			; write data
		
		add.w	#$FEA,d1			; get address of length flag
		move.w	d1,(a1)				; set address
		move.w	#4,(a2)				; write data
		
.exit:
		bsr		restoreMode			; set correct flash mode
		movem.l (sp)+,d1/a1-a2		; Restore regs
		rts

; skunkCONSOLEWRITE(a0)
; Write text to the console, if it is active
; a0 - address of the text to be written, terminated with a 0 byte
; Will write to either buffer, whichever is free first. Note that
; if the length is not an even number, one additional byte will be
; sent to the PC, though it should not be printed.
skunkCONSOLEWRITE::
		movem.l	d0-d2/a0-a2,-(sp)
		
		; determine length of the string (including the 0)
		move.l	a0,a1
		moveq	#1,d0				; we start at 1 to make the rounding up work
.lp1:
		addq	#1,d0
		tst.b	(a1)+
		bne		.lp1
.done1:
		move.l	d0,d2				; save the true count
		subq	#1,d2				; minus one to make it real
		lsr.l	d0					; divide by two to get word count
		subq	#1,d0				; subtract by 1 for the dbra below
		
		bsr		setAddresses		; get HPI addresses into a1 & a2
		bsr		getBuffer			; get a free buffer into d1
		tst.l	d1
		beq		.exit				; if we didn't get a buffer, return

		move.w #$4004,(a1)			; enter HPI write mode
		move.w d1,(a1)				; set HPI write data address
.wrlp:
		move.w (a0)+,(a2)			; write data
		dbra	d0,.wrlp
		
		add.w	#$FEA,d1			; get address of length flag
		move.w	d1,(a1)				; set address
		move.w	d2,(a2)				; write length (PC gets this buffer now)

.exit:		
		bsr		restoreMode			; set correct flash mode
		movem.l (sp)+,d0-d2/a0-a2   ; Restore regs
		rts

; skunkCONSOLECLOSE()
; Instructs the console to close. No arguments.
; Expects the console is closed after the fact.
skunkCONSOLECLOSE::
		movem.l	d1/a1-a2,-(sp)

		bsr		setAddresses		; get HPI addresses into a1 & a2
		bsr		getBothBuffers		; wait for both buffers, get first in d1
		tst.l	d1
		beq		.exit				; if we didn't get a buffer, return
		
		move.w #$4004,(a1)			; enter HPI write mode
		move.w d1,(a1)				; set HPI write data address
		move.w #$ffff,(a2)			; write data
		move.w #$0001,(a2)			; write data
		
		add.w	#$FEA,d1			; get address of length flag
		move.w	d1,(a1)				; set address
		move.w	#4,(a2)				; write data
		
		move.w	#$4001,(a1)			; enter flash read-only mode
		
		bsr		waitforbufferack	; wait for the PC to acknowledge
		
		move.l	#0,skunkConsoleUp	; clear the active flag

.exit:
		bsr		restoreMode			; set correct flash mode
		movem.l (sp)+,d1/a1-a2		; Restore regs
		rts

; a0=skunkCONSOLEREAD(d0)
; Reads text from the console keyboard and returns it at a0,
; which is a buffer d0 bytes long. The maximum return is 4064 bytes.
; Note the returned string is NOT necessarily NUL terminated,
; so you can't just turn around and print it!
skunkCONSOLEREAD::
		movem.l	d0-d2/a0-a2,-(sp)
		
		bsr		setAddresses		; get HPI addresses into a1 & a2
		bsr		getBothBuffers		; wait for both buffers to free, return the first in d1
		tst.l	d1
		beq		.exit				; if we didn't get a buffer, return
		move.w	#$4004,(a1)			; enter HPI write mode
		move.w	d1,(a1)				; set HPI write data address
		move.w	#$ffff,(a2)			; write data
		move.w	#$0002,(a2)			; write data
		
		add.w	#$FEA,d1			; get address of length flag
		move.w	d1,(a1)				; set address
		move.w	#4,(a2)				; write data
		
		move.w	#$4001,(a1)			; enter flash read-only mode

		add.w	#$1000,d1			; switch to second buffer for reply
.inploop2:	
		; wait for a response - note no timeout here! Thus an interrupted
		; input can hang the Jaguar. User input can be too slow to timeout.
		move.w	d1,(a1)				; write address
		move.w	(a1),d2				; read data
		andi.w	#$FF00,d2
		cmp.w	#$FF00,d2			; test if used
		beq .inploop2

		; get the true value again now that we're happy with it
		move.w	d1,(a1)				; write address
		move.w	(a1),d2				; read data
		
		; we have input - copy it into the user's buffer at a0,
		; but copy no more than d0 bytes. Since we will copy
		; two bytes at a time, round d0 down to the nearest word size
		lsr.l	d0
		subq	#1,d0				; subtract 1 for dbra loop
		; check whether the input text is shorter (probably)
		addq	#1,d2				; so we don't lose a byte
		lsr.l	d2					; divide by two for words
		subq	#1,d2				; subtract 1 for dbra loop
		cmp		d2,d0				; which is bigger?
		ble		.nochange
		move.l	d2,d0				; copy smaller value
.nochange:
		sub.w	#$FEA,d1			; get base address of buffer
		move.w	d1,(a1)				; set address
.cplp:
		move.w	(a1),(a0)+			; write data
		dbra	d0,.cplp

		; now clear the buffer to acknowledge it and we're done			
		add.w	#$FEA,d1			; go back up to the length field again			
		move.w	#$4004,(a1)			; enter HPI write mode
		move.w	d1,(a1)				; set HPI write data address
		move.w	#$0000,(a2)			; write data - this flags to the PC that we are done

.exit:
		bsr		restoreMode			; set correct flash mode
		movem.l (sp)+,d0-d2/a0-a2	; Restore regs
		rts
		
; skunkFILEOPEN(a0,d0)
; Opens a file on the PC in the current folder (paths are not supported)
; a0 - points to the filename, terminated with a 0 byte
; d0 - 0 for write mode. 1 for read mode.
; This function will wait until the PC acknowledges the buffer
; to reduce ordering problems.
skunkFILEOPEN::
		movem.l	d0-d2/a0-a3,-(sp)
		
		bsr		setAddresses		; get HPI addresses into a1 & a2
		bsr		getBuffer			; get a free buffer into d1
		tst.l	d1
		beq		.exit				; if we didn't get a buffer, return

		move.w	#$4004,(a1)			; enter HPI write mode
		move.w	d1,(a1)				; set write address
		move.w	#$FFFF,(a2)			; write data
		and.l	#$1,d0				; mask off the valid range (1 bit! yay!)
		add.w	#3,d0				; set mode
		move.w	d0,(a2)				; write file mode

		; determine length of the string (including the 0)
		move.l a0,a3
		moveq	#1,d0				; we start at 1 to make the rounding up work
.lp1:
		addq	#1,d0
		tst.b	(a3)+
		bne		.lp1

		move.l	d0,d2				; save the count
		addq	#3,d2				; add three to make it real including the header
		lsr.l	d0					; divide by two to get word count
		subq	#1,d0				; subtract by 1 for the dbra below
		
.wrlp:
		move.w (a0)+,(a2)			; write data
		dbra	d0,.wrlp
		
		add.w	#$FEA,d1			; get address of length flag
		move.w	d1,(a1)				; set address
		move.w	d2,(a2)				; write length (PC gets this buffer now)

		move.w	#$4001,(a1)			; enter flash read-only mode
		
		bsr		waitforbufferack	; wait for the buffer to clear

.exit:		
		bsr		restoreMode			; set correct flash mode
		movem.l (sp)+,d0-d2/a0-a3   ; Restore regs
		rts

; skunkFILEWRITE(a0,d0)
; Writes a block on the PC to the currently open file (if open to write)
; a0 - points to the data - will be updated!
; d0 - number of bytes to write, up to 4060. (must be even)
; This function will wait until the PC acknowledges the buffer
; to reduce ordering problems. There's no guarantee of actual write,
; only that it was sent to the PC.
skunkFILEWRITE::
		movem.l	d0-d2/a1-a3,-(sp)
		
		bsr		setAddresses		; get HPI addresses into a1 & a2
		bsr		getBuffer			; get a free buffer into d1
		tst.l	d1
		beq		.exit				; if we didn't get a buffer, return

		move.w	#$4004,(a1)			; enter HPI write mode
		move.w	d1,(a1)				; set write address
		move.w	#$FFFF,(a2)			; write data
		move.w	#$0005,(a2)			; write data

		move.l	d0,d2				; save true length
		addq	#4,d2				; add header size
		
		addq	#1,d0				; for the divide about to come
		lsr.l	d0					; divide by two to get word count
		subq	#1,d0				; subtract by 1 for the dbra below
.wrlp:
		move.w (a0)+,(a2)			; write data
		dbra	d0,.wrlp
		
		add.w	#$FEA,d1			; get address of length flag
		move.w	d1,(a1)				; set address
		move.w	d2,(a2)				; write length (PC gets this buffer now)
		
		move.w #$4001,(a1)			; enter flash read-only mode

		bsr		waitforbufferack	; wait for the buffer to clear

.exit:		
		bsr		restoreMode			; set correct flash mode
		movem.l (sp)+,d0-d2/a1-a3   ; Restore regs
		rts

; a0=skunkFILEREAD(d0)
; Reads data from the currently open file (if opened for read)
; which is a buffer d0 bytes long. The maximum return is 4064 bytes.
; d0 is updated with the actual number of bytes read. If 0, either
; EOF or an error occurred. a0 is also updated.
skunkFILEREAD::
		movem.l	d1-d2/a1-a2,-(sp)
		
		bsr		setAddresses		; get HPI addresses into a1 & a2
		bsr		getBothBuffers		; wait for both buffers to free, return the first in d1
		tst.l	d1
		beq		.exit				; if we didn't get a buffer, return
		
		move.w	#$4004,(a1)			; enter HPI write mode
		move.w	d1,(a1)				; set HPI write data address
		move.w	#$ffff,(a2)			; write data
		move.w	#$0006,(a2)			; write data
		
		add.w	#$FEA,d1			; get address of length flag
		move.w	d1,(a1)				; set address
		andi.l	#$FFFE,d0			; make sure it's even and word-sized
		move.w	d0,(a2)				; write data
		
		move.w	#$4001,(a1)			; enter flash read-only mode

		add.w	#$1000,d1			; switch to second buffer for reply
		; wait for a response - (done with d0 since
		; the PC side must honor our length request)
		move.l  #timeout,d0
.inploop2:	
		move.w	d1,(a1)				; write address
		move.w	(a1),d2				; read data
		andi.w	#$FF00,d2
		cmp.w	#$FF00,d2			; test if used
		bne		.gotresp
		subq	#1,d0
		tst.l	d0
		bne		.inploop2
		; got nothing, give up
		bra		.exit

.gotresp:		
		; get the real value again
		move.w	d1,(a1)				; write address
		clr.l	d2				; Clear top word of d2
		move.w	(a1),d2				; read data

		; we have input - copy it into the user's buffer at a0
		; The length must be less than or equal to d0, and d0
		; should have been even, so we won't enforce the values here
		move.l	d2,d0				; to return to the user
		beq		.nodata				; no data to copy?
		
		addq	#1,d2				; so we don't lose a byte
		lsr.l	d2					; divide by two for words
		subq	#1,d2				; subtract 1 for dbra loop

		sub.w	#$FEA,d1			; get base address of buffer
		move.w	d1,(a1)				; set address
.cplp:
		move.w	(a1),(a0)+			; write data
		dbra	d2,.cplp

		; now clear the buffer to acknowledge it and we're done			
		add.w	#$FEA,d1			; go back up to the length field again			
.nodata:
		move.w	#$4004,(a1)			; enter HPI write mode
		move.w	d1,(a1)				; set HPI write data address
		move.w	#$0000,(a2)			; write data

.exit:
		bsr		restoreMode			; set correct flash mode
		movem.l (sp)+,d1-d2/a1-a2	; Restore regs
		rts
		
; skunkFILECLOSE()
; Instructs the currently open file to close. No arguments.
skunkFILECLOSE::
		movem.l	d1/a1-a2,-(sp)

		bsr		setAddresses		; get HPI addresses into a1 & a2
		bsr		getBuffer			; get a free buffer into d1
		tst.l	d1
		beq		.exit				; if we didn't get a buffer, return
		
		move.w	#$4004,(a1)			; enter HPI write mode
		move.w	d1,(a1)				; set HPI write data address
		move.w	#$ffff,(a2)			; write data
		move.w	#$0007,(a2)			; write data
		
		add.w	#$FEA,d1			; get address of length flag
		move.w	d1,(a1)				; set address
		move.w	#4,(a2)				; write data
		
		move.w	#$4001,(a1)			; enter flash read-only mode

		bsr		waitforbufferack	; wait for the buffer to clear

.exit:
		bsr		restoreMode			; set correct flash mode
		movem.l (sp)+,d1/a1-a2		; Restore regs
		rts
		
; ---------------------------------------------------------------------
; Helper functions - not intended to be externally called
; ---------------------------------------------------------------------
		
; setAddresses - helper function to set console addresses
; also sets the ROM mode to flash read-only in preparation for access
setAddresses:
		move.l	#$C00000,a1			; HPI write address/read data
		move.l	#$800000,a2			; HPI write data
		move.w	#$4001,(a1)			; set flash read only mode
		rts

; restoreMode - call at the end of each function to set either flash read-only
; or flash 6MB mode, depending on the current state
restoreMode:
		move.w	skunkReadMode,(a1)	
		rts
		
; Following functions assume setAddresses has been called!		
; check buffer - test if buffer in d1 is available (d1 points to length word)
checkbuffer:
		move.l	d0,-(sp)
		
		move.w	d1,(a1)				; set read address
		move.w	(a1),d0				; read data
		andi.w	#$ff00,d0			; saw a race where the low byte was set first, high can never be $FF
		cmp.w	#$ff00,d0			; is it empty?
		beq		.empty
		clr.l	d1					; not empty
		jmp		.exit
.empty:	
		sub.w	#$FEA,d1			; get base address

.exit:
		move.l	(sp)+,d0
		rts		
		
; checkBuffer1 - test if buffer 1 is available (returns in d1)
checkBuffer1:
		move.l	#($1800+$FEA),d1
		jmp		checkbuffer

; checkBuffer2 - test if buffer 2 is available (returns in d1)
checkBuffer2:
		move.l	#($2800+$FEA),d1
		jmp		checkbuffer

; getBuffer - helper function to return either buffer when it's free in d1
; returns 0 in d1 if neither buffer is free 
getBuffer:
		bsr		checkBuffer1
		tst.l	d1
		bne		.exit
		bsr		checkBuffer2
		tst.l	d1
		bne		.exit
		; both buffers are in use - do we sit and wait?
		tst.l	skunkConsoleUp
		beq		.exit			; no, console was down last time too
		
		; else yes, we want to wait here for a few spins
		move.l	d0,-(sp)		; get a work register
		move.l	#timeout,d0		; number of spins to wait
.waitlp:
		bsr		checkBuffer1
		tst.l	d1
		bne		.exitwait
		bsr		checkBuffer2
		tst.l	d1
		bne		.exitwait
		subq	#1,d0
		tst.l	d0
		bne		.waitlp
		
		; whatever we have now, we're going to go with
.exitwait:		
		move.l	(sp)+,d0		; fix the stack
.exit:
		move.l	d1,skunkConsoleUp	; save the result for next time
		rts		

; getBothBuffers - waits for both buffers to be free then returns the
; first buffer ($1800) in d1. Returns 0 in d1 if both buffers do not free up.
getBothBuffers:
		bsr		checkBuffer2
		tst.l	d1
		beq		.trywait		; busy - try waiting
		bsr		checkBuffer1
		tst.l	d1
		beq		.trywait		; busy - try waiting
		; both buffers are free, we can exit already! (note we put buffer 1 last)
		bra		.exit

.trywait:
		tst.l	skunkConsoleUp
		beq		.exit			; no, console was down last time too
		
		; else yes, we want to wait here for a few spins
		move.l	d0,-(sp)		; get a work register
		move.l	#timeout,d0		; number of spins to wait
.waitlp:
		bsr		checkBuffer2
		tst.l	d1
		beq		.dolp			; still busy, repeat loop
		bsr		checkBuffer1
		tst.l	d1
		bne		.exitwait		; not busy (and buffer 2 not busy), exit loop
.dolp:
		subq	#1,d0
		tst.l	d0
		bne		.waitlp
		; whatever we have now, we're going to go with
.exitwait:		
		move.l	(sp)+,d0		; fix the stack
.exit:
		move.l	d1,skunkConsoleUp	; save the result for next time
		rts		

; waitforbufferack - waits for the buffer with d1 pointing to the length offset
; to be cleared by the PC. will time out but the timeout is longer than the length
; of getBuffer.
waitforbufferack:
		movem.l	d0-d2,-(sp)
		; wait for that buffer to be cleared by the PC - d1 already has the right value in it
		; but checkbuffer will nuke d1 if it's not ready, so we need to save it off
		move.l	d1,d0
		move.l	#timeout,d2
.synclp:
		move.l	d0,d1
		jsr		checkbuffer
		tst.l	d1
		bne		.exit
		subq	#1,d2
		tst.l	d2
		bne		.synclp

.exit:
		movem.l	(sp)+,d0-d2
		rts

		.bss
		.long

; Set to nonzero when console is okay, cleared to 0 if the console times out
; (so only the first operation lags)
skunkConsoleUp::	ds.l	1
; set to the correct value for flash read mode - $4001 normally, $4003 for 6MB mode
skunkReadMode::		ds.w	1
; even out the address counter
		.long
		
