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
; 10/19/94  18:16:10  jpe
; Disabled CD setup and mode selection for RAM playback.
; Fixed bug in calculation of fractional portion of timeIncr.
; Truncated GPU_READY to GPU_READ to keep COFF linker happy.
;
; 04/27/94  18:46:55  jpe
; CD-BIOS changes incorporated.
;
; 04/25/94  17:07:10  jpe
; Corrected aspect-ratio problem with video timing.
; Fixed bug which prevented operation without CD-ROM.
; Fixed bug which caused improper handling of empty chunk.
; Added initialization of audio drift rate.
;
; 04/08/94  13:57:05  jpe
; Initial revision.
;******************************************************************************
; Atari In-House Revisions:
; 1.3.1: SDS
;        Converted to Cinepak Demo Code...not for distribution.
; 1.3.2: SDS
;        Made DSP Code play different format audio.
; 1.3.3: SDS
;        Hold on to your seats...rotation!
; 1.3.4: SDS
;        GPU/DSP now never stop.
; 1.4.0: SDS
;        Triple-Interleaved Buffering.
; 1.4.1: SDS
;        DSP Code Fix/New & Better Startup
; 1.4.2: SDS
;        Correct Expanded RGB Handling
;-------------------------------------
;   1.5: SDS
;        First chunk no longer needs to be searched for (since it
;        immediately follows chunk table).
;        Single-chunk movies are handled correctly.
;        All audio types now work (hopefully).
;
;** BUGS **********************************************************************
; The variables SAMP_RATE and AUD_CHUNK are hard-coded for 8-bit Mono Audio.
; This can affect movies with other audio types and cause them not to play
; correctly due to buffer mis-management. Change these for your purposes!!!
;
; Hard CD errors are currently ignored.        
;******************************************************************************

		.nlist
		.include    'memory.inc'
		.include    'jaguar.inc'
		.include    'cd.inc'
		.include    'player.inc'
	.if ^^defined USE_SKUNK
		.include    'skunk.inc'
	.endif
		.list

START_SESS  	.equ    1
START_TRACK 	.equ    1

_start:

; Initialize the environment.
	.if ^^defined SKUNK_CONSOLE
		jsr	skunkRESET
		jsr	skunkNOP
		jsr	skunkNOP
		move.l	#HELLO_MSG,a0
		jsr	skunkCONSOLEWRITE
	.endif

	.if ^^defined USE_SKUNK
		move	#$1865,MEMCON1		; Skunk is 16-bit ROM, CD is 32-bit
	.endif

		bsr     Clear			; Clear display buffers
		bsr	InitVars		; Do at program start
		bsr     InitMoviList          	; Set up the object list

		clr.w	hasinited

		jsr 	CD_setup            	; Initialize CD-ROM system

	.if ^^defined SKUNK_CONSOLE
		move	#$187B,MEMCON1
		move.l	#CD_SETUP_MSG,a0
		jsr	skunkCONSOLEWRITE
		move	#$1865,MEMCON1
	.endif

		move    #$3,d0              	; CD-ROM, double-speed
		jsr 	CD_mode             	; Set CD-ROM speed

	.if ^^defined SKUNK_CONSOLE
		move	#$187B,MEMCON1
		move.l	#CD_MODE_MSG,a0
		jsr	skunkCONSOLEWRITE
		move	#$1865,MEMCON1
	.endif

	.if ^^defined USE_SKUNK
		move	#$2C00,a0		; Manually get TOC when using skunk
		jsr	CD_getoc

	.if ^^defined SKUNK_CONSOLE
		move	#$187B,MEMCON1
		move.l	#CD_TOC_MSG,a0
		jsr	skunkCONSOLEWRITE
		move	#$1865,MEMCON1
	.endif ; defined SKUNK_CONSOLE
	.endif ; defined USE_SKUNK

		bsr 	LoadDSP			; Download the DSP code
		bsr	LoadGPU         	; Download the GPU code
; Start the DSP.
		move.l  #DRIFT_RATE,AUDIO_DRIFT ; (Default)
		move.l  #0,AUDIO_DESC
		move.l  #DSP_ENTR,D_PC          ; Load DSP program counter
		move.l  #$1,D_CTRL          	; Start the DSP

; Start the GPU.
		lea 	GPU_READ,a0         	; GPU_READY flag 
		adda.l  GPUOffset,a0        	; Relocated address
		move.l  #0,(a0)             	; Clear the ready flag
		move.l  #G_RAM+$50,G_PC     	; Load GPU program counter
		move.l  #RISCGO,G_CTRL      	; Start the GPU

;   Wait for GPU to finish startup sequence, then allow external interrupts.

WaitGPU:
		move.l  (a0),d0             	; Get ready flag
		tst.l   d0
		beq.s   WaitGPU             	; Loop until GPU has set it

		move.b  #START_SESS,d0
		move.b  #START_TRACK,d1
		jsr     MediaGetFirst       	; Get Session #1/Track #2

		tst.l   d0
		bpl 	gotfirst

		ori.l	#$80,listcopy+8		; Set transparent bit
		move.w  #$F000,BG		; so error shows up RED.

		move.l  #$CDCDCDCD,fatal
badcd:		
		jmp	badcd
gotfirst:
		add.l   #LEADER-MARGIN,d0   	; Cinepak Leader/Safety Margin
		move.l  d0,blockOffset
nextmovie:
		clr.l   d0
		move.l  d0,mediaOffset      	; Clear mediaOffset
		move    d0,CRYmovie     	; Clear CRYmovie
		move    d0,playPhase       	; Clear playPhase
		move    d0,catchUp      	; Clear catchUp
	
		move.l  #FILM_BASE,a0           ; Where to put CD-ROM data
		movea.l a0,a1               	; Make a copy
		adda.l  #CBUF_SIZE,a1       	; Length of search window
		moveq   #0,d0               	; Byte offset on CD-ROM
		bsr 	ReadCDData

		move.l  #FILM_SYNC,d0       	; Pattern to look for
		movea.l #FILM_BASE,a0       	; Where to start looking
		movea.l a0,a1               	; Make a copy
		adda.l  #SRCH_WIN,a1        	; Length of search window
.ClearWindow:
		bsr 	GetCDWritePtr

		cmpa.l  CDWritePtr,a1       	; See where GPU write pointer is
		bge.s   .ClearWindow        	; Wait for GPU to clear search window

		bsr 	FindSync            	; Find sync pattern

		cmpa.l  #0,a0               	; Did sync search fail?
		bne.s   CheckFilm           	; No, look for film tag

		move.l  #SYNC_FAIL,fatal    	; Load error flag
		jmp 	diskbeg
CheckFilm:
		cmpi.l  #FILM_TAG,(a0)      	; Have we found start of film?
		beq.s   RelocTable      	; Yes, relocate chunk table

		move.l  #BOGUS_FILM,fatal       ; Load error flag
		jmp 	diskbeg
RelocTable:
		move.l  4(a0),d0        	; Number of bytes to move
		move.l  #FILM_BASE,a1		; Destination

		move.l	a0,d1			; Base of film in buffer
		add.l	d0,d1			; Calc base of first chunk
		add.l	#$40,d1			; Size of Sync
		move.l	d1,firstChunk		; Store for later
CopyCT:
		bsr 	GetCDWritePtr
		cmpa.l  CDWritePtr,a0       	; See where GPU write pointer is
		bge.s   CopyCT          	; Wait for GPU to get ahead

		move.l  (a0)+,(a1)+     	; Move a long
		subq.l  #4,d0           	; Knock off 4 bytes
		bne.s   CopyCT          	; Loop until done

		movea.l #FILM_BASE,a5       	; Film header
		move.l  4(a5),d0        	; Size
		add.l   #SYNC_SIZE,d0       	; Account for film sync
		add.l   #20,d0
		move.l  d0,mediaOffset      	; Fix offset on CD-ROM

		move.l  a5,d0           	; Movie base
		add.l   4(a5),d0        	; Add header/CT size

		add.l   #20,d0          	; Kludge (REMOVE LATER)
		
		move.l  d0,cBufBase     	; Base of circular buffer

		move.l  #CBUF_END,d1        	; End of circular buffer
		sub.l   d0,d1           	; Free memory
		move.l  d1,cBufSize     	; Size of circular buffer

;;; Now we switch screens (if we hadn't already done so)
		tst.w	hasinited		; Have we already 'init'ed'?
		bne	doneinit

		bsr	IntInit			; Switch from startup screen
		move.w	#1,hasinited

	.if ^^defined SKUNK_CONSOLE
		move	#$187B,MEMCON1
		move.l	#DONE_INIT_MSG,a0
		jsr	skunkCONSOLEWRITE
		move	#$1865,MEMCON1
	.endif
doneinit:
		lea 	$10(a5),a5          	; Frame description
		move.l  $8(a5),d0           	; cType
		cmpi.l  #'$CRY',d0      	; Is it a CRY movie?
		bne	RGBmovie        	; No, continue
					   
		move.w  #1,CRYmovie     	; Set CRYmovie flag true
		move.w  #$6C1,VMODE     	; Turn on the display in CRY
		bra	CalcDest
RGBmovie:
		move.w	#$6C7,VMODE
		move.w	#0,CRYmovie

		cmpi.l	#'$RGB',d0
		bne	CalcDest

		move.w	#1,CRYmovie		; Already expanded
CalcDest:
		move.l	#SCREEN_BASE,dest

		move.l	$10(a5),d0		; Width of Movie
		move.l	$C(a5),d1		; Height of Movie

		move.l	d0,MovieWidth		; Store for later use
		move.l	d1,MovieHeight

		clr.w	doingangles		; Disable pixel blits
		move.l	#0,blitAngle
		cmp.w	#160,d0
		bgt	doangles

		cmp.w	#120,d1
		bgt	doangles

		move.w	#1,doingangles		; Enable Pixel Blits
doangles:
		move.w	d1,d2			; Form Blitter B_COUNT
		swap	d2
		move.w	d0,d2
		move.l	d2,blitCount

		move.l	d0,d2			; Form Blitter STEP regs
		neg.w	d2
		ori.l	#$10000,d2
		move.l	d2,blitStep

		move.l	#NLINES,d2		; Find true Vert center
		sub.l	d1,d2
		lsr.l	#1,d2
		swap	d2

		move.w	#NPIXELS,d2		; Find true Horz center
		sub.w	d0,d2
		lsr.w	#1,d2

		move.l	d2,blitPixel		; Built Blitter A1/A2_PIXEL

		jsr 	UpdateVars
		jsr 	ModifyOlist

		move.l  #0,AUDIO_DESC       	; Default Audio
		move.l  #18,SCLK        	; SCLK = 21.793 kHz
		move.l  #DRIFT_RATE,AUDIO_DRIFT ; 0.017606439 * (65536)^2

		lea 	$14(a5),a5      	; Chunk table or Audio Desc?
		cmp.l   #'ADSC',(a5)        	; Is it audio?
		bne 	ischunk

		move.l  $8(a5),AUDIO_DESC
		move.l  $C(a5),SCLK
		move.l  $10(a5),AUDIO_DRIFT

		lea 	$14(a5),a5
ischunk:
		move.l  $c(a5),filmChunks   	; Number of chunks in film

		cmp.l	#1,filmChunks		; Is there more than one chunk?
		bgt	morethanone

		move.w	#2,playPhase		; No, straight to playPhase #2
morethanone:
		move.l  $8(a5),d0       	; Time scale
		divu    #TICK_RATE,d0       	; Time per tick (integer part)
		move.l  d0,d1           	; Remainder << 16 to d1
		clr.w 	d1          		; Nuke integer part
		divu    #TICK_RATE,d1       	; Fractional part
		swap    d0          		; Integer part to high word
		move.w  d1,d0           	; Merge fractional part (Q16)
		move.l  d0,timeIncr   

		move.l  $8(a5),d0           	; Time scale
		mulu    #MAX_DELAY,d0       	; Delay in units of time (Q16)
		addi.l  #$8000,d0           	; Round off
		swap    d0              	; Keep integer portion
		ext.l   d0              	; Convert to long
		move.l  d0,maxDelay

		move.l  cBufSize,d1
		divu    #BLK_SIZE,d1        	; Blocks in circular buffer
		swap    d1              	; Make Q16
		move    #2*BLK_RATE,d0      	; Blocks per second
		bsr 	LongDivide      	; Fill time in Q16 format
		subi.l  #AUDIO_LAG,d1       	; fillTime - audioLag
		lsr.l   #3,d1           	; Make Q13 (difference < 8!!)
		mulu    $a(a5),d1       	; Convert to time
		lsl.l   #2,d1           	; Divide by 2, make Q16
		addi.l  #$8000,d1       	; Round off
		swap    d1          		; Keep integer portion
		ext.l   d1          		; Convert to long
		move.l  d1,deltaTime

		lea 	$10(a5),a5      	; First table entry
		move.l  $c(a5),d0       	; Pattern to look for
		movea.l cBufBase,a0     	; Where to start looking
		movea.l a0,a1           	; Make a copy
		adda.l  #SRCH_WIN,a1        	; Length of search window

.ClearWindow:
		bsr 	GetCDWritePtr
		cmpa.l  CDWritePtr,a1           ; See where GPU write pointer is
		bge.s   .ClearWindow            ; Wait for GPU to clear search window

		move.l	firstChunk,a0		; Should be at start of chunk
.CheckSample:
		cmpi.l  #SAMP_TAG,(a0)      	; Have we found start of chunk?
		beq.s   .ChunkOK        	; Yes, get ready to do it       

		move.l  #BOGUS_SAMP,fatal	; Load error flag
		jmp 	skipmovie
.ChunkOK:
		lea 	-$40(a0),a4     	; Back up to start of sync
		lea 	$40(a4),a3      	; Skip around sync

		movea.l a4,a0           	; First chunk in circular buffer
		move.l  a5,pNextGroup       	; Phony startup condition
		bsr 	SetNextGroup            ; Set params for next group of chunks

		movea.l a4,a0               	; Start of data in buffer
		adda.l  #HEAD_START,a0          ; Force space between R/W pointers
WaitToFill:
		bsr 	GetCDWritePtr
		cmpa.l  CDWritePtr,a0       	; See where GPU write pointer is
		bge.s   WaitToFill      	; Allow GPU to get ahead

		move.l  buffChunks,d7       	; Number of chunks in circular buffer
		move.l  time,d0         	; Read time
WaitForTick:
		cmp.l   time,d0             	; Still the same?
		beq.s   WaitForTick         	; Yes, wait for it to change
												 
		clr.l   time                	; Start at zero
		clr 	time+4

ChunkLoop:
	.if ^^defined SKUNK_CONSOLE_VERBOSE
		move	#$187B,MEMCON1
		move.l	#CHUNK_LOOP_MSG,a0
		jsr	skunkCONSOLEWRITE
		move	#$1865,MEMCON1
	.endif

		move.l  $c(a3),d5           	; Number of samples
		move.l  a3,d4
		add.l   4(a3),d4            	; Base of sample data
		lea 	$10(a3),a3          	; Base of sample table
SampleLoop:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; This seems like a logical place to insert a "game logic" routine ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		jsr 	UpdateScale		; Read Joystick and UpdateVars
		tst.l   d0			; -1=Reset; 0=No Action; 1+=New Track
		beq 	nochange        	; No value
		bpl 	changetrk          	; Reset!!!

		move.l  #0,DSP_ARGS
		move.l  #0,DSP_ARGS+4
		move.l	#1,DSP_STOP		; Shutdown sound (DSP stays running)

		bsr	InitVars
		bra	diskbeg
changetrk:
		move.l  d0,d2
		move.b  #START_SESS,d0      	; Yes, jump to start of disk
		move.b  #START_TRACK,d1
		jsr 	MediaGetTrack       	; Illegal Track Number

		tst.l   d0
		bpl 	goodtrack
nochange:
		cmpi.l  #-1,8(a3)       	; s->Time == -1?
		bne.s   DoVideo             	; No, it's video

		lea 	DSP_ARGS,a0         	; DSP argument list
		move.l  AudioDesc,8(a0)     	; Audio type
		move.l  d4,4(a0)            	; Transfer *audioData (Do first!!)
		move.l  4(a3),(a0)          	; Transfer count
		bra 	NextSample      	; We're done with audio
DoVideo:
		move.l  8(a3),d2        	; s->Time
		bclr    #31,d2          	; Get rid of MSB
KillTime:
		move.l  time,d0         	; Get current time
		cmp.l   d0,d2           	; Ahead of schedule?
		bgt.s   KillTime        	; Yes, wait

		tst.w 	catchUp         	; Is catch-up flag set?
		bne.s   LookForKey      	; Yes, look for key frame

		sub.l   d2,d0               	; Amount we've slipped
		cmp.l   maxDelay,d0         	; Are we too far behind?
		bmi.s   DisplayFrame        	; Not yet, continue
					
		move.w  #1,catchUp      	; Yes, set catch-up flag
LookForKey:
		move.l  #0,-(a7)        	; Return value
		move.l  d4,-(a7)        	; Pointer to frame
		bsr 	CheckKeyFrame

		lea 	$4(a7),a7       	; Balance stack
		move.l  (a7)+,d0        	; Pop return value
		tst.l   d0          		; Is it a key frame?

		beq 	CheckCDPlay     	; No, skip the frame

		clr 	catchUp         	; Yes, clear flag and display frame
DisplayFrame:
		move.l  #1,-(a7)            	; Return value      
		move.l  #CINEPAK_DATA,-(a7)     ; c
		move.l  d4,-(a7)            	; (Ptr)data
		move    CRYmovie,-(a7)          ; CRYmovie
		bsr 	PreDecompress

		lea 	$a(a7),a7           	; Balance stack
		move.l  (a7)+,d0            	; Pop return value
		tst.l   d0              	; Did we get an error?
		beq.s   StartDecomp         	; No, continue  

	.if ^^defined SKUNK_CONSOLE
		move	#$187B,MEMCON1
		move.l	#PREDEC_MSG,a0
		jsr	skunkCONSOLEWRITE
		move	#$1865,MEMCON1
	.endif
		move.l  #PREDEC_ERR,fatal       ; Load error flag
		jmp 	CheckCDPlay		; Ignore Error
StartDecomp:
	.if ^^defined SKUNK_CONSOLE_VERBOSE
		move	#$187B,MEMCON1
		move.l	#PREDEC_DONE_MSG,a0
		jsr	skunkCONSOLEWRITE
		move	#$1865,MEMCON1
	.endif

		move.l  #1,-(a7)            	; Return value      
		move.l  #CINEPAK_DATA,-(a7)     ; c
		move.l  d4,-(a7)            	; (Ptr)data
		move.l  dest,-(a7)          	; data offset

		move.w  #NPIXELS*2,-(a7)       	; WORLD->bytewidth
		move.w	#2,-(a7)		; Triple Bufferring

		bsr 	Decompress

		lea 	$10(a7),a7      	; Balance stack
		move.l  (a7)+,d0        	; Pop return value

	.if ^^defined SKUNK_CONSOLE
		tst.l	d0			; Did we get an error?
		beq.s   DoBufBlit         	; No, continue

		move	#$187B,MEMCON1
		move.l	#DEC_MSG,a0
		jsr	skunkCONSOLEWRITE
		move	#$1865,MEMCON1
	.endif

		; After logging error, ignore it and continue.
DoBufBlit:
	.if ^^defined SKUNK_CONSOLE_VERBOSE
		move	#$187B,MEMCON1
		move.l	#PRE_BLIT_MSG,a0
		jsr	skunkCONSOLEWRITE
		move	#$1865,MEMCON1
	.endif

		move.l  #SCREEN_BASE+$8,d0  	; Choose screen to blit to
		move.l	#SCREEN_BASE+$10,d1

		btst.b  #0,blitScreen
		beq 	blitme  

		exg.l	d0,d1			; Swap buffers
blitme:
		tst.w	doingangles	
		beq	phraseblit

		move.l	blitAngle,ANGLEVAL	; Store Rotation Parameters
		
		move.l	#SCREEN_BASE,SRCADDR
		move.l	MovieWidth,SRCWIDTH
		move.l	MovieHeight,SRCHEIGHT
		move.l	#WID320,SRCWIDFLD
		
		move.l	d0,DESTADDR
		move.l	#NPIXELS/2,DESTXCNTR
		move.l	#NLINES/2,DESTYCNTR
		move.l	#WID320,DESTWIDFLD

		move.l	#0,GCHANGEOLP		; No OLP change.
		move.l  #RISCGO|FORCEINT0,G_CTRL	; Force CPU Interrupt
.wait4gpu:
		move.l	SRCADDR,d2		; Has GPU started Blit?
		bne	.wait4gpu
.wait4blit:
		move.l	B_CMD,d2		; Is Blitter Done?
		btst.l	#0,d2
		beq	.wait4blit

		move.l  d0,scrbuf 	     	; store it for op vframe
		bchg.b  #0,blitScreen       	; Switch screen

		move.l	runframes,d2		; Wait for screen to swap...
.wait4frame:
		move.l	runframes,d3
		cmp.l	d3,d2
		beq	.wait4frame

		move.l	d1,A1_BASE		; Now clear other buffer
		move.l	#PIXEL16|XADDPHR|PITCH3|WID320,A1_FLAGS
		move.l	#(20<<16)|60,A1_PIXEL
		move.l	#$10000|(-200 & $FFFF),A1_STEP
		move.l	#(200<<16)|200,B_COUNT
		move.l	#0,B_PATD
		move.l	#0,B_PATD+4
		move.l	#SRCEN|UPDA1|PATDSEL,B_CMD

		bra	CheckCDPlay
phraseblit:
		move.l  d0,A1_BASE		; Do normal phrase screen copy
		move.l  #SCREEN_BASE,A2_BASE
		move.l  #PIXEL16|XADDPHR|PITCH3|WID320,A1_FLAGS
		move.l  #PIXEL16|XADDPHR|PITCH3|WID320,A2_FLAGS
		move.l  blitPixel,A1_PIXEL
		move.l  #0,A2_PIXEL
		move.l  blitStep,A1_STEP
		move.l  blitStep,A2_STEP
		move.l  blitCount,B_COUNT
		move.l  #SRCEN|UPDA1|UPDA2|LFU_REPLACE,B_CMD
.wait4blit:
		move.l	B_CMD,d1		; Ensure blit has finished
		btst.l	#0,d1
		beq	.wait4blit

		move.l  d0,scrbuf       	; store it for op vframe
		bchg.b  #0,blitScreen       	; Switch screen

	.if ^^defined SKUNK_CONSOLE_VERBOSE
		move	#$187B,MEMCON1
		move.l	#POST_BLIT_MSG,a0
		jsr	skunkCONSOLEWRITE
		move	#$1865,MEMCON1
	.endif
CheckCDPlay:
		cmpi    #0,playPhase        	; Phase 0?
		bne.s   Check1          	; No, check phase 1

		movea.l pNextGroup,a0       	; First chunk in next group
		move.l  $8(a0),d0       	; Get expiration time
		sub.l   time,d0         	; Subtract current time
		cmp.l   deltaTime,d0        	; Time to play CD?
		bgt 	NextSample      	; No, proceed
						
		move.l  (a0),d0             	; Byte offset on CD-ROM
		move.l  cBufBase,a0         	; Where to put CD-ROM data
		bsr 	ReadCDData     

		move    #1,playPhase        	; Phase 1 is next
		bra.s   NextSample
Check1:
		cmpi    #1,playPhase        	; Phase 1?
		bne.s   NextSample      	; No, proceed

		movea.l cBufBase,a0     	; Where to start looking
		movea.l a0,a1           	; Make a copy
		adda.l  #SRCH_WIN,a1        	; Length of search window
					
		bsr 	GetCDWritePtr
		cmpa.l  CDWritePtr,a1       	; See where GPU write pointer is
		bge.s   NextSample      	; Wait for GPU to clear search window

		movea.l pNextGroup,a1       	; Pointer to next group of chunks
		move.l  $c(a1),d0       	; Pattern to look for
		bsr 	FindSync        	; Find sync pattern

		cmpa.l  #0,a0           	; Did sync search fail?
		bne.s   .CheckSample        	; No, look for sample tag

		move.l  #SYNC_FAIL,fatal    	; Load error flag
		jmp 	skipmovie
.CheckSample:
		cmpi.l  #SAMP_TAG,(a0)      	; Have we found start of chunk?
		beq.s   .ChunkOK            	; Yes, get ready to do it       

		move.l  #BOGUS_SAMP,fatal   	; Load error flag
		jmp 	skipmovie
.ChunkOK:
		lea 	-$40(a0),a0     	; Back up to start of sync
		move.l  a0,nextBufAddr      	; Save for when we start next group
		bsr 	SetNextGroup        	; Set params for next group of chunks
					 
		move    #2,playPhase        	; Phase 2 is next
NextSample:
		add.l   4(a3),d4            	; Data for sample[m+1]
		lea 	$10(a3),a3          	; Advance sample table pointer
		subq.l  #1,d5               	; Decrement sample counter
		bne 	SampleLoop
NextChunk:
		subq.l  #1,d7               	; Decrement buffer chunk counter
		beq 	ResetBuffer         	; If zero, reset buffer pointers

		adda.l  4(a5),a4            	; Next chunk in FIFO
		lea 	$10(a5),a5          	; Advance chunk table pointer
		lea 	$40(a4),a3          	; Skip around sync
		tst.l   $c(a3)              	; Is the chunk empty?
		beq.s   NextChunk           	; Yes, skip it

		bra 	ChunkLoop           	; No, do it
ResetBuffer:
		move.l  buffChunks,d7       	; Number of chunks in circular buffer
		beq.s   skipmovie            	; If zero, we're done!!

		lea 	$10(a5),a5     	 	; Advance chunk table pointer
		move.l  nextBufAddr,a4      	; Start of fresh data
		lea 	$40(a4),a3     		; Skip around sync
		clr 	playPhase       	; Reset to phase 0
		tst.l   filmChunks      	; Still more chunks after these?
		bne 	ChunkLoop       	; Yes, continue

		move    #3,playPhase    	; Inhibit further CD-ROM activity
		clr.l   buffChunks      	; No more chunks after these
		bra 	ChunkLoop       	; Finish what's in buffer
skipmovie:
		jsr	CD_uread

		jsr 	MediaGetNext        	; Get Next Track
		tst.l   d0          		; Did an error occur?
		bpl 	goodtrack
diskbeg:
		move.b  #START_SESS,d0      	; Yes, jump to start of disk
		move.b  #START_TRACK,d1
		jsr 	MediaGetFirst
		tst.l   d0
		bpl 	goodtrack
goodtrack:
		move.l  #0,DSP_ARGS
		move.l  #0,DSP_ARGS+4
		move.l  #1,DSP_STOP     	; Stop DSP

		add.l   #LEADER-MARGIN,d0
		move.l  d0,blockOffset

		bsr 	Clear
		jmp 	nextmovie

;------------------------------------------------------------------------------
;   Declare storage for flags and variables.
;------------------------------------------------------------------------------

semaphore:      dc.w    0
CRYmovie:       dc.w    0
dest:           dc.l    0
tickrate:	dc.w	0	; System tick rate (SDS)
hasinited:	dc.w	0

		.long
timeIncr:       dc.l    0	; Read by GPU as LONG!

		.long
		dc.w	0	; Keep this...
time:           dc.l    0	; +2 is read by GPU as longword!
		dc.w    0
mediaOffset:    dc.l    0
blockOffset:    dc.l    0
cBufBase:       dc.l    0
cBufSize:       dc.l    0
debugHandle:    dc.l    0
GPUOffset:      dc.l    0
deltaTime:      dc.l    0
filmChunks:     dc.l    0
pNextGroup:     dc.l    0
buffChunks:     dc.l    0
nextBufAddr:    dc.l    0
playPhase:      dc.w    0
catchUp:        dc.w    0
maxDelay:       dc.l    0
CDWritePtr:     dc.l    0
firstChunk:	dc.l	0

lastCDerr:      dc.l    0   	; Address of last CD error
fatal:          dc.l    0   	; Last fatal error
AudioDesc:      dc.l    0   	; Audio Description Field
MovieWidth:     dc.l    0   	; Width of movie (in pixels)
MovieHeight:    dc.l    0   	; Height of movie (in pixels)
blitScreen:     dc.w    0	; For double-buffer blit (only high byte is used)

		.long
scrbuf:         dc.l    0	; Address of buffer to display (Read by GPU as long)
blitAngle:	dc.l	0	; Angle of Rotation (0-2048)
blitCount:      dc.l    0   	; Blit B_COUNT value (precomputed)
blitPixel:	dc.l	0	; Blit A1/A2_PIXEL value (precomputed)
blitStep:	dc.l	0	; Blit A1/A2_STEP value (precomputed)
reflect:        dc.w    0   	; Reflection (high byte)
fixtearing:     dc.w    0   	; Tearing fix (high byte)
doingangles:	dc.w	0	; Angles Enabled
	.if ^^defined SKUNK_CONSOLE
		.long
HELLO_MSG:	dc.b	'Welcome to the skunk console!',13,10,0
		.long
CD_SETUP_MSG:	dc.b	'Set up the CDROM',13,10,0
		.long
CD_MODE_MSG:	dc.b	'Set the CDROM mode',13,10,0
		.long
CD_TOC_MSG:	dc.b	'Read the CD table of contents',13,10,0
		.long
DONE_INIT_MSG:	dc.b	'Finished initialization',13,10,0
		.long
PREDEC_MSG:	dc.b	'Error in Cinepak pre-decode routine',13,10,0
		.long
DEC_MSG:	dc.b	'Error in Cinepak decode routine',13,10,0
	.endif	; ^^defined SKUNK_CONSOLE
	.if ^^defined SKUNK_CONSOLE_VERBOSE
		.long
PRE_BLIT_MSG:	dc.b	'Getting ready to blit',13,10,0
		.long
POST_BLIT_MSG:	dc.b	'Done with phrase blit',13,10,0
		.long
PREDEC_DONE_MSG:	dc.b	'Done with pre-decompress function',13,10,0
		.long
CHUNK_LOOP_MSG:	dc.b	'Entering chunk loop',13,10,0
	.endif	; ^^defined SKUNK_CONSOLE_VERBOSE

;------------------------------------------------------------------------------
;   Declare externals and globals.
;------------------------------------------------------------------------------

		.extern DSP_ARGS        ; Where to put DSP arguments
		.extern DSP_ENTR        ; Entry to DSP code
		.extern DSP_STOP    	; DSP run flag?
		.extern AUDIO_DRIFT     ; Audio drift rate
		.extern AUDIO_DESC	; Audio data description
		.extern GPU_READ        ; GPU has finished startup
		.extern RUN_GPU     	; GPU run flag?

		.extern CheckKeyFrame   ; Check for key frame
		.extern PreDecompress   ; Cinepak codebook expansion
		.extern Decompress      ; Cinepak frame drawing

		.extern Clear           ; Clear display memory
		.extern VideoIni        ; Initialize video timing
		.extern InitMoviList    ; Initialize object list
		.extern IntInit         ; Interrupt init & service
		.extern	runframes	; # of frames since start (SDS)

		.extern FindSync        ; Find sync pattern in data stream
		.extern GetCDWritePtr   ; Get location of CD-ROM write
		.extern LoadDSP         ; Load DSP code
		.extern LoadGPU         ; Load GPU code
		.extern LongDivide      ; Long division routine
		.extern ReadCDData      ; Play CD and fill circular buffer
		.extern SetNextGroup    ; Set next chunk group's parameters
		.extern Snapshot        ; Make debug snapshot in ROM

		.extern UpdateScale	; Added (SDS)
		.extern MediaGetFirst	;  |
		.extern MediaGetTrack	;  v
		.extern MediaGetNext	;
		.extern InitVars 	;
		.extern	UpdateVars	;
		.extern ModifyOlist	;
		.extern listcopy	;
		.extern data_off	;

		.extern GCHANGEOLP	;
		.extern	ANGLEVAL	;
		.extern	SRCADDR     	;
		.extern	SRCWIDTH	;
		.extern	SRCHEIGHT	; |
		.extern	SRCWIDFLD	; V
		.extern	DESTADDR	;
		.extern	DESTXCNTR	;
		.extern	DESTYCNTR	;
		.extern	DESTWIDFLD	;

		.globl  prgtop		;
		.globl  skipmovie	;
		.globl  lastCDerr	;
		.globl  MovieWidth	; |
		.globl  MovieHeight	; V
		.globl  ReadJoypad	;
		.globl  joyedge		;
		.globl  scrbuf		;
		.globl  blitCount	;
		.globl	blitAngle	;
		.globl	blitScreen	; 
		.globl  soundmute	; _

		.globl  buffChunks
		.globl  catchUp
		.globl  CDWritePtr
		.globl  debugHandle
		.globl  filmChunks
		.globl  GPUOffset
		.globl  mediaOffset
		.globl  blockOffset 	; Added (SDS)
		.globl  pNextGroup
		.globl  semaphore
		.globl  time
		.globl  timeIncr

		.globl	_start		; Added (SDS)

		.end
