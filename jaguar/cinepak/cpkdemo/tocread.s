;
; Jaguar Sample Code
; Copyright (c)1994 Atari Corp.
; All Rights Reserved 
;
; Project: cpkdemo.cof - Cinepak Scaling/Motion Demo
;  Module: tocread.s   - Use the in-memory TOC to choose film files
;
; History: 11/10/94 - Created (SDS)
;

		.include "cd.inc"

		.68000
		.text

		.globl	MediaGetFirst
		.globl	MediaGetNext
		.globl	MediaGetTrack
		.globl	GetNextTrack
		.globl	GetPrevTrack

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: MediaGetFirst
;            Get disk information from the TOC and return the block
;            number of the session/track specified.
;
;    Inputs: d0.b - Session Number
;            d1.b - Track Number
;
;   Returns: d0.l (-1 = error, otherwise block number of track start)
;
; The first 8-byte Table of Contents entry has the form:
; XX:XX:FT:LT TS:LM:LS:LF
;
; XX = Unused (0)
; FT = First Track Number
; LT = Last Track Number
; TS = Total number of Sessions
; LM = Start of lead-out time (end of disk) in Minutes
; LS = Start of lead-out time in Seconds
; LF = Start of lead-out time in Frames
;
; Succeeding entries in the Table of Contents has the format:
; TT:MM:SS:FF SS:DM:DS:DF
;
; TT = Track Number 1..99 (all fields are bytes)
; MM = Offset in Minutes (from start of CD)
; SS = Offset in Seconds (from start of CD)
; FF = Offset in Frames (from start of CD)
; SS = Session Number 0..99
; DM = Duration in Minutes
; DS = Duration in Seconds
; DF = Duration in Frames
;
; There are 75 frames per second and 2352 bytes per block.
;                 

MediaGetFirst:
		movem.l	d1-d4/a0,-(sp)

		move.b	d0,session_num	; Store for MediaGetNext
		move.b	d1,track_num

		move.w	#0,d4
		movea.l	#CD_toc+8,a0	; First track entry
loopsession:
		movem.l	(a0)+,d2-d3	; Load 8-byte entry
		tst.l	d2		; zeros?
		bne	testsession

		move.l	#-1,d0		; No tracks?????
		bra	endfirst
testsession:
		rol.l	#8,d3		; -> DM:DS:DF:SS

		cmp.b	d0,d3		; Sessions equal?
		bne	loopsession

		cmp.b	d1,d4		; Offsets equal?
		beq	gotmatch
		
		add.w	#1,d4
		bra	loopsession	
gotmatch:
		move.l	a0,next_entry

		ror.l	#8,d3		; Restore
		bsr	toc2block	; Calculate
		move.l	#1,trackoff	; Current Track Offset
endfirst:
		movem.l	(sp)+,d1-d4/a0
		rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: MediaGetTrack
;            Get disk information from the TOC and return the block
;            number of the track offset specified.
;
;    Inputs: d0.b - Session Number
;            d1.b - Track Number
;	     d2.l - Offset from Start of Disc
;
;   Returns: d0.l (-1 = error, otherwise block number of track start)
;

MediaGetTrack:
		movem.l	d1-d5/a0,-(sp)

		move.b	d0,session_num	; Store for MediaGetNext
		move.b	d1,track_num
		move.l	d2,d5		; Store in D5 (cause we use D2)

		move.w	#0,d4
		movea.l	#CD_toc+8,a0	; First track entry
findsession:
		movem.l	(a0)+,d2-d3	; Load 8-byte entry
		tst.l	d2		; zeros?
		bne	chksession

		move.l	#-1,d0		; No tracks?????
		bra	endlook
chksession:
		rol.l	#8,d3		; -> DM:DS:DF:SS

		cmp.b	d0,d3		; Sessions equal?
		bne	findsession

		cmp.b	d1,d4		; Offsets equal?
		beq	foundit
		
		add.w	#1,d4
		bra	findsession	
foundit:
		sub.l	#8,a0		; Skip to beg of entry

		move.l	d5,d4
		sub.l	#1,d5		; -1 for dbra -1 for zero offset
.loop:
		movem.l	(a0)+,d2-d3
		tst.l	d2		; Early problem
		beq	badexit

		dbra	d5,.loop
		move.l	a0,next_entry
		bra	calc
badexit:
		move.l	#-1,d0
		bra	endlook
calc:
		bsr	toc2block	; Calculate
		move.l	d4,trackoff	; Current Track Offset
endlook:
		movem.l	(sp)+,d1-d5/a0
		rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: MediaGetNext
;            Using info stored from MediaGetFirst and the Disk TOC,
;            find the next track. If no more tracks on disk, return -1.
;            Otherwise return the block number of the track + 2 seconds.
;
;    Inputs: None
;
;   Returns: d0.l (-1 = end of disc, otherwise block number of next track)
;

MediaGetNext:
		movem.l	d2-d3/a0,-(sp)

		move.l	next_entry,a0	; Next TOC entry

		movem.l	(a0)+,d2-d3	; Load 8-byte entry in d2/d3
		tst.l	d2		; Empty?
		bne	calcoffset

		move.l	#-1,d0		; End of disc
		bra	endnext
calcoffset:
		move.l	a0,next_entry
		bsr	toc2block	; Returns block number in D0
		add.l	#1,trackoff
endnext:
		movem.l	(sp)+,d2-d3/a0
		rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: toc2block
;            Utility function to convert TOC entry to block number.
;
;    Inputs: d2.l/d3.l - TOC entry
;
;   Returns: d0.l - Block number
;

toc2block:
		movem.l	d1-d2,-(sp)
					; TT:MM:SS:FF
		swap	d2		; -> SS:FF:TT:MM

		clr.l	d0		; d0 = MM
		move.b	d2,d0

		mulu	#60,d0		; Make minutes, seconds.

		rol.l	#8,d2		; FF:TT:MM:SS

		clr.l	d1		; d1 = SS
		move.b	d2,d1

		add.l	d1,d0		; Add seconds to (minutes*60)
		mulu	#75,d0		; Make seconds, frames

		rol.l	#8,d2		; TT:MM:SS:FF

		move.b	d2,d1

		add.l	d1,d0		; Total Frames

		movem.l	(sp)+,d1-d2
		rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: GetNextTrack
;	     Find next Track number
;
;   Returns: d0.l (Next Track Number)
;

GetNextTrack:
		move.l	a0,-(sp)

		move.l	trackoff,d0
				
		lea	next_entry,a0	; If at last entry no inc
		tst.l	(a0)
		beq	.exit

		add.l	#1,d0
.exit:
		move.l	(sp)+,a0
		rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: GetPrevTrack
;	     Find next Track number
;
;   Returns: d0.l (Next Track Number)
;

GetPrevTrack:
		move.l	trackoff,d0
		sub.l	#1,d0
		bne	.good

		move.l	#1,d0		; Bound at one...
.good:
		rts

		.data

next_entry:	.dc.l	1
trackoff:	.dc.l	1
session_num:	.dc.b	1
track_num:	.dc.b	1

		.end
		
