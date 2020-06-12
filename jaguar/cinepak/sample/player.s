
;******************************************************************************
; (C) Copyright 1992-1994, SuperMac Technology, Inc.
; All rights reserved.
;
; This source code and any compilation or derivative thereof is the sole
; property of SuperMac Technology, Inc. and is provided pursuant to a
; Software License Agreement.  This code is the proprietary information
; of SuperMac Technology and is confidential in nature.  Its use and
; dissemination by any party other than SuperMac Technology are strictly
; limited by the confidential information provisions of the Agreement
; referenced above.
;
; Revision 1.31 6/1/95 mf
; Changed 'GPU_READY' reference to 'GPU_READ' to eliminate linker error
; when PLAYER.S is assembled to a BSD object module instead of Alcyon.;
;
; Revision 1.3	09/23/94  11:12:45  jpe
; Disabled CD setup and mode selection for RAM playback.
; Fixed bug in calculation of fractional portion of timeIncr.
;
; Revision 1.2	04/27/94  18:46:55  jpe
; CD-BIOS changes incorporated.
;
; Revision 1.1	04/25/94  17:07:10  jpe
; Corrected aspect-ratio problem with video timing.
; Fixed bug which prevented operation without CD-ROM.
; Fixed bug which caused improper handling of empty chunk.
; Added initialization of audio drift rate.
;
; Revision 1.0	04/08/94  13:57:05  jpe
; Initial revision.
;******************************************************************************

	.nlist
	.include    'memory.inc'
	.include    'jaguar.inc'
	.include    'cd.inc'
	.include    'cinepak.inc'
	.list

;==============================================================================

	ori	#$300,sr		; Disable interrupts

	movea.l #ROM_BASE+$100000,a0	; Start of debug history buffer
	move.l	a0,debugHandle		; Initialize handle
	movea.l a0,a1			; Make a copy
	adda.l	#$100000,a1		; Allow a megabyte
	clr.l	d0			; Clear buffer to aid EOF search

ClearROM:
	move.l	d0,(a0)+		; Write a long
	cmpa.l	a0,a1			; Done yet?
	bne.s	ClearROM		; No, do another

	move.l	#$70007,G_END		; Set Motorola mode in Tom
	move.l	#$70007,D_END		; Set Motorola mode in Jerry
    
;   Initialize the environment.

	bsr	Clear			; Clear the screen RAM
	bsr	VideoIni		; Create the video timing
	bsr	Lister			; Set up the object processor
	bsr	IntInit 		; Set up interrupts
	move.w	#$6C7,VMODE		; Turn on the display in RGB

	bsr	LoadDSP 		; Download the DSP code
	bsr	LoadGPU 		; Download the GPU code

;   Start up the DSP.

	move.l	#DRIFT_RATE,AUDIO_DRIFT ; Set audio drift rate for DSP
	move.l	#DSP_ENTR,D_PC		; Load DSP program counter
	move.l	#$1,D_CTRL		; Start the DSP

    .if ^^defined USE_CDROM 
	jsr	CD_setup		; Initialize CD-ROM system

	move	#$3,d0			; CD-ROM, double-speed
	jsr	CD_mode 		; Set CD-ROM speed
    .endif

	lea	GPU_READ,a0		; GPU_READY flag 
	adda.l	GPUOffset,a0		; Relocated address
	move.l	#0,(a0) 		; Clear the ready flag
	move.l	#G_RAM+GPU_OFFSET,G_PC	; Load GPU program counter
	move.l	#$1,G_CTRL		; Start the GPU

;   Wait for GPU to finish startup sequence, then allow external interrupts.

WaitGPU:
	move.l	(a0),d0 		; Get ready flag
	tst.l	d0
	beq.s	WaitGPU 		; Loop until GPU has set it

;   Enable DSP interrupt in GPU and tell Jerry to pass interrupts along to Tom.

LoopTrk:
	clr.l	d0
	move.l	d0,mediaOffset		; Clear mediaOffset
	move	d0,CRYmovie		; Clear CRYmovie
	move	d0,playPhase		; Clear playPhase
	move	d0,catchUp		; Clear catchUp

    .if ^^defined USE_CDROM 
	move.l	#FILM_BASE,a0		; Where to put CD-ROM data
	moveq	#0,d0			; Byte offset on CD-ROM
	bsr	ReadCDData
    .endif

	move.l	#FILM_SYNC,d0		; Pattern to look for
	movea.l #FILM_BASE,a0		; Where to start looking
	movea.l a0,a1			; Make a copy
	adda.l	#SRCH_WIN,a1		; Length of search window

.ClearWindow:
	bsr	GetCDWritePtr
	cmpa.l	CDWritePtr,a1		; See where GPU write pointer is
	bge.s	.ClearWindow		; Wait for GPU to clear search window

	bsr	FindSync		; Find sync pattern

	cmpa.l	#0,a0			; Did sync search fail?
	bne.s	CheckFilm		; No, look for film tag

	move.l	#SYNC_FAIL,d0		; Load error flag
	illegal 			; Trap

CheckFilm:
	cmpi.l	#FILM_TAG,(a0)		; Have we found start of film?
	beq.s	RelocTable		; Yes, relocate chunk table

	move.l	#BOGUS_FILM,d0		; Load error flag
	illegal 			; Trap

RelocTable:
	move.l	4(a0),d0		; Number of bytes to move
	move.l	#FILM_BASE,a1		; Destination

CopyCT:
	bsr	GetCDWritePtr
	cmpa.l	CDWritePtr,a0		; See where GPU write pointer is
	bge.s	CopyCT			; Wait for GPU to get ahead

	move.l	(a0)+,(a1)+		; Move a long
	subq.l	#4,d0			; Knock off 4 bytes
	bne.s	CopyCT			; Loop until done

	movea.l #FILM_BASE,a5		; Film header
	move.l	4(a5),d0		; Size
	add.l	#SYNC_SIZE,d0		; Account for film sync
	move.l	d0,mediaOffset		; Fix offset on CD-ROM

	move.l	a5,d0			; Movie base
	add.l	4(a5),d0		; Add header/CT size
	move.l	d0,cBufBase		; Base of circular buffer

	move.l	#CBUF_END,d1		; End of circular buffer
	sub.l	d0,d1			; Free memory
	move.l	d1,cBufSize		; Size of circular buffer

	lea	$10(a5),a5		; Frame description
	move.l	$8(a5),d0		; cType
	cmpi.l	#'$CRY',d0		; Is it a CRY movie?
	bne.s	CalcDest		; No, continue

	move	#1,CRYmovie		; Set CRYmovie flag true
	move	#$6C1,VMODE		; Turn on the display in CRY

CalcDest:
	move.l	#NPIXELS,d0		; screenWidth
	sub.l	$10(a5),d0		; FrameDesc->Width
	move.l	#NLINES,d1		; screenHeight
	sub.l	$c(a5),d1		; FrameDesc->Height
	asr	#1,d1			; >> = 1
	addi.l	#SCREEN_BASE,d0 	; screenBase + (h << 1)
	mulu	#ROWBYTES,d1		; v*screenRowBytes
	add.l	d1,d0			; Screen destination
	move.l	d0,dest 		; Save it

	lea	$14(a5),a5		; Chunk table	    
	move.l	$c(a5),filmChunks	; Number of chunks in film

	move.l	$8(a5),d0		; Time scale
	divu	#TICK_RATE,d0		; Time per tick (integer part)
	move.l	d0,d1			; Remainder << 16 to d1
	clr	d1			; Nuke integer part
	divu	#TICK_RATE,d1		; Fractional part
	swap	d0			; Integer part to high word
	move	d1,d0			; Merge fractional part (Q16)
	move.l	d0,timeIncr

	move.l	$8(a5),d0		; Time scale
	mulu	#MAX_DELAY,d0		; Delay in units of time (Q16)
	addi.l	#$8000,d0		; Round off
	swap	d0			; Keep integer portion
	ext.l	d0			; Convert to long
	move.l	d0,maxDelay

	move.l	cBufSize,d1
	divu	#BLK_SIZE,d1		; Blocks in circular buffer
	swap	d1			; Make Q16
	move	#2*BLK_RATE,d0		; Blocks per second
	bsr	LongDivide		; Fill time in Q16 format
	subi.l	#AUDIO_LAG,d1		; fillTime - audioLag
	lsr.l	#3,d1			; Make Q13 (difference < 8!!)
	mulu	$a(a5),d1		; Convert to time
	lsl.l	#2,d1			; Divide by 2, make Q16
	addi.l	#$8000,d1		; Round off
	swap	d1			; Keep integer portion
	ext.l	d1			; Convert to long
	move.l	d1,deltaTime

	lea	$10(a5),a5		; First table entry
	move.l	$c(a5),d0		; Pattern to look for
	movea.l cBufBase,a0		; Where to start looking
	movea.l a0,a1			; Make a copy
	adda.l	#SRCH_WIN,a1		; Length of search window

.ClearWindow:
	bsr	GetCDWritePtr
	cmpa.l	CDWritePtr,a1		; See where GPU write pointer is
	bge.s	.ClearWindow		; Wait for GPU to clear search window

	bsr	FindSync		; Find sync pattern

	cmpa.l	#0,a0			; Did sync search fail?
	bne.s	.CheckSample		; No, look for sample tag

	move.l	#SYNC_FAIL,d0		; Load error flag
	illegal 			; Trap

.CheckSample:
	cmpi.l	#SAMP_TAG,(a0)		; Have we found start of chunk?
	beq.s	.ChunkOK		; Yes, get ready to do it       

	move.l	#BOGUS_SAMP,d0		; Load error flag
	illegal 			; Trap

.ChunkOK:
	lea	-$40(a0),a4		; Back up to start of sync
	lea	$40(a4),a3		; Skip around sync

	movea.l a4,a0			; First chunk in circular buffer
	move.l	a5,pNextGroup		; Phony startup condition
	bsr	SetNextGroup		; Set params for next group of chunks

	movea.l a4,a0			; Start of data in buffer
	adda.l	#HEAD_START,a0		; Force space between R/W pointers

WaitToFill:
	bsr	GetCDWritePtr
	cmpa.l	CDWritePtr,a0		; See where GPU write pointer is
	bge.s	WaitToFill		; Allow GPU to get ahead

	move.l	buffChunks,d7		; Number of chunks in circular buffer
	move.l	time,d0 		; Read time

WaitForTick:
	cmp.l	time,d0 		; Still the same?
	beq.s	WaitForTick		; Yes, wait for it to change

	clr.l	time			; Start at zero
	clr	time+4

ChunkLoop:
	move.l	$c(a3),d5		; Number of samples
	move.l	a3,d4
	add.l	4(a3),d4		; Base of sample data
	lea	$10(a3),a3		; Base of sample table

SampleLoop:
	bsr	Snapshot		; Take a snapshot for debug

	cmpi.l	#-1,8(a3)		; s->Time == -1?
	bne.s	DoVideo 		; No, it's video

	lea	DSP_ARGS,a0		; DSP argument list
	move.l	d4,4(a0)		; Transfer *audioData (Do first!!)
	move.l	4(a3),(a0)		; Transfer count
	bra	NextSample		; We're done with audio
    
DoVideo:
	move.l	8(a3),d2		; s->Time
	bclr	#31,d2			; Get rid of MSB
    
KillTime:
	move.l	time,d0 		; Get current time
	cmp.l	d0,d2			; Ahead of schedule?
	bgt.s	KillTime		; Yes, wait

	tst	catchUp 		; Is catch-up flag set?
	bne.s	LookForKey		; Yes, look for key frame

	sub.l	d2,d0			; Amount we've slipped
	cmp.l	maxDelay,d0		; Are we too far behind?
	bmi.s	DisplayFrame		; Not yet, continue

	move	#1,catchUp		; Yes, set catch-up flag

LookForKey:
	move.l	#0,-(a7)		; Return value
	move.l	d4,-(a7)		; Pointer to frame
	bsr	CheckKeyFrame

	lea	$4(a7),a7		; Balance stack
	move.l	(a7)+,d0		; Pop return value
	tst.l	d0			; Is it a key frame?

	beq.s	CheckCDPlay		; No, skip the frame

	clr	catchUp 		; Yes, clear flag and display frame

DisplayFrame:
    .if ^^defined FORCE_DELAY
	bsr	ForceDelay		; Introduce a delay
    .endif
	move.l	#1,-(a7)		; Return value	    
	move.l	#CINEPAK_DATA,-(a7)	; c
	move.l	d4,-(a7)		; (Ptr)data
	move	CRYmovie,-(a7)		; CRYmovie
	bsr	PreDecompress

	lea	$a(a7),a7		; Balance stack
	move.l	(a7)+,d0		; Pop return value
	tst.l	d0			; Did we get an error?
	beq.s	StartDecomp		; No, continue  

	move.l	#PREDEC_ERR,d0		; Load error flag
	illegal 			; Trap

StartDecomp:
	move.l	#1,-(a7)		; Return value	    
	move.l	#CINEPAK_DATA,-(a7)	; c
	move.l	d4,-(a7)		; (Ptr)data
	move.l	dest,-(a7)		; dst
	move.l	#ROWBYTES,-(a7) 	; WORLD->screenRowBytes
	bsr	Decompress

	lea	$10(a7),a7		; Balance stack
	move.l	(a7)+,d0		; Pop return value
	tst.l	d0			; Did we get an error?
	beq.s	CheckCDPlay		; No, continue  

	move.l	#DECOMP_ERR,d0		; Load error flag
	illegal 			; Trap

CheckCDPlay:
    .if ^^defined USE_CDROM 
	cmpi	#0,playPhase		; Phase 0?
	bne.s	Check1			; No, check phase 1

	movea.l pNextGroup,a0		; First chunk in next group
	move.l	$8(a0),d0		; Get expiration time
	sub.l	time,d0 		; Subtract current time
	cmp.l	deltaTime,d0		; Time to play CD?
	bgt	NextSample		; No, proceed

	move.l	(a0),d0 		; Byte offset on CD-ROM
	move.l	cBufBase,a0		; Where to put CD-ROM data
	bsr	ReadCDData

	move	#1,playPhase		; Phase 1 is next
	bra.s	NextSample

Check1:
	cmpi	#1,playPhase		; Phase 1?
	bne.s	NextSample		; No, proceed

	movea.l cBufBase,a0		; Where to start looking
	movea.l a0,a1			; Make a copy
	adda.l	#SRCH_WIN,a1		; Length of search window

	bsr	GetCDWritePtr
	cmpa.l	CDWritePtr,a1		; See where GPU write pointer is
	bge.s	NextSample		; Wait for GPU to clear search window

	movea.l pNextGroup,a1		; Pointer to next group of chunks
	move.l	$c(a1),d0		; Pattern to look for
	bsr	FindSync		; Find sync pattern

	cmpa.l	#0,a0			; Did sync search fail?
	bne.s	.CheckSample		; No, look for sample tag

	move.l	#SYNC_FAIL,d0		; Load error flag
	illegal 			; Trap

.CheckSample:
	cmpi.l	#SAMP_TAG,(a0)		; Have we found start of chunk?
	beq.s	.ChunkOK		; Yes, get ready to do it       

	move.l	#BOGUS_SAMP,d0		; Load error flag
	illegal 			; Trap

.ChunkOK:
	lea	-$40(a0),a0		; Back up to start of sync
	move.l	a0,nextBufAddr		; Save for when we start next group
	bsr	SetNextGroup		; Set params for next group of chunks

	move	#2,playPhase		; Phase 2 is next
    .endif

NextSample:
	add.l	4(a3),d4		; Data for sample[m+1]
	lea	$10(a3),a3		; Advance sample table pointer
	subq.l	#1,d5			; Decrement sample counter
	bne	SampleLoop

NextChunk:
	subq.l	#1,d7			; Decrement buffer chunk counter
	beq	ResetBuffer		; If zero, reset buffer pointers

	adda.l	4(a5),a4		; Next chunk in FIFO
	lea	$10(a5),a5		; Advance chunk table pointer
	lea	$40(a4),a3		; Skip around sync
	tst.l	$c(a3)			; Is the chunk empty?
	beq.s	NextChunk		; Yes, skip it

	bra	ChunkLoop		; No, do it

ResetBuffer:
    .if ^^defined USE_CDROM 
	move.l	buffChunks,d7		; Number of chunks in circular buffer
	beq.s	Done			; If zero, we're done!!

	lea	$10(a5),a5		; Advance chunk table pointer
	move.l	nextBufAddr,a4		; Start of fresh data
	lea	$40(a4),a3		; Skip around sync
	clr	playPhase		; Reset to phase 0
	tst.l	filmChunks		; Still more chunks after these?
	bne	ChunkLoop		; Yes, continue

	move	#3,playPhase		; Inhibit further CD-ROM activity
	clr.l	buffChunks		; No more chunks after these
	bra	ChunkLoop		; Finish what's in buffer
    .endif

Done:	    
    .if ^^defined USE_CDROM
	move	#$1,d0			; Wait for completion
	jsr	CD_stop 		; Stop the drive
    .endif

    .if ^^defined ENDLESS_LOOP
	bsr Clear
	jmp LoopTrk
    .else
	move.l	#NORMAL_END,d0		; Load completion flag
	illegal 			; Trap
    .endif

;------------------------------------------------------------------------------

;   130 cycles/loop ~ 9.77 usec/loop @ 13.3 MHz

ForceDelay:
	move	#$1234,d0		; Dummy divisor
	move	#1705,d2		; Loop count (1 tick)

ForceLoop:
	move.l	#$ffffff,d1		;  12 cycles
	divu	d0,d1			; 108 cycles
	dbra	d2,ForceLoop		;  10 cycles

	rts

;------------------------------------------------------------------------------
;   Declare storage for flags and variables.
;------------------------------------------------------------------------------

semaphore:	dc.w	0
CRYmovie:	dc.w	0
dest:		dc.l	0
timeIncr:	dc.l	0
time:		dc.l	0
		dc.w	0
mediaOffset:	dc.l	0
cBufBase:	dc.l	0
cBufSize:	dc.l	0
debugHandle:	dc.l	0
GPUOffset:	dc.l	0
deltaTime:	dc.l	0
filmChunks:	dc.l	0
pNextGroup:	dc.l	0
buffChunks:	dc.l	0
nextBufAddr:	dc.l	0
playPhase:	dc.w	0
catchUp:	dc.w	0
maxDelay:	dc.l	0
CDWritePtr:	dc.l	0
    
;------------------------------------------------------------------------------
;   Declare externals and globals.
;------------------------------------------------------------------------------

	.extern     DSP_ARGS		; Where to put DSP arguments
	.extern     DSP_ENTR		; Entry to DSP code
	.extern     AUDIO_DRIFT 	; Audio drift rate
	.extern     GPU_READ		; GPU has finished startup (8 char version of GPU_READY)

	.extern     CheckKeyFrame	; Check for key frame
	.extern     PreDecompress	; Cinepak codebook expansion
	.extern     Decompress		; Cinepak frame drawing

	.extern     Clear		; Clear display memory
	.extern     VideoIni		; Initialize video timing
	.extern     Lister		; Initialize object list
	.extern     IntInit		; Interrupt init & service

	.extern     FindSync		; Find sync pattern in data stream
	.extern     GetCDWritePtr	; Get location of CD-ROM write
	.extern     LoadDSP		; Load DSP code
	.extern     LoadGPU		; Load GPU code
	.extern     LongDivide		; Long division routine
	.extern     ReadCDData		; Play CD and fill circular buffer
	.extern     SetNextGroup	; Set next chunk group's parameters
	.extern     Snapshot		; Make debug snapshot in ROM

	.globl	    buffChunks
	.globl	    catchUp
	.globl	    CDWritePtr
	.globl	    debugHandle
	.globl	    filmChunks
	.globl	    GPUOffset
	.globl	    mediaOffset
	.globl	    pNextGroup
	.globl	    semaphore
	.globl	    time
	.globl	    timeIncr

	.end
