
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
; Revision 1.1  04/27/94  16:04:45  jpe
; CD-BIOS changes incorporated.
;
; Revision 1.0  04/08/94  13:59:30  jpe
; Initial revision.
;******************************************************************************


		.nlist
		.include	'memory.inc'
		.include	'jaguar.inc'
		.include	'cd.inc'
		.include	'cinepak.inc'
		.list

;==============================================================================
;	Subroutine to locate sync pattern in buffer.
;
;		Input:	d0 = sync pattern
;				a0 = starting address
;
;		Output:	a0 = data address (immediately following sync)
;
;	If sync is not found within a prescribed length, a zero is returned in a0.
;==============================================================================

FindSync:
		movem.l	a1-a2/d7,-(a7)			; Save registers
		movea.l	a0,a1					; Make a copy of starting address
		adda.l	#SRCH_WIN,a1			; Add length of search window

CoarseSearch:
		cmp.l	(a0),d0					; Sync pattern?
		beq.s	FineSearch				; Yes, begin fine search

ResumeCoarse:
		lea		SYNC_SIZE(a0),a0		; Move over to next group
		cmpa.l	a0,a1					; Reached end of window?
		bgt.s	CoarseSearch			; No, continue

		movea.l	#0,a0					; Yes, return 0 (search failed)
		bra.s	SyncExit				; Report the bad news

FineSearch:
		clr		d7						; Clear sync counter
		lea		0(a0),a2				; Start from current location

FindStart:
		cmp.l	-(a2),d0				; Found upstream sync pattern?
		bne.s	FoundStart				; No, continue counting at (a0)

		addq	#1,d7					; Yes, increment counter
		bra.s	FindStart				; Back up and look again

FoundStart:
		lea		0(a0),a2				; Continue at coarse search point

CountSync:
		cmp.l	(a2)+,d0				; Sync pattern?
		bne.s	ResumeCoarse			; No, break out and try again

		addq	#1,d7					; Yes, incrememnt counter
		cmpi	#SYNC_SIZE/4,d7			; Found the right number?
		bne.s	CountSync				; Not yet, keep counting

		movea.l	a2,a0					; Yep, we're done

SyncExit:
		movem.l	(a7)+,a1-a2/d7			; Restore registers
		rts

;==============================================================================
;	Subroutine to find current DRAM write address for CD-ROM data. If we are
;	not using the CD-ROM, CBUF_END is substituted.
;
;		Input:	None
;
;		Output:	None
;==============================================================================

GetCDWritePtr:
		movem.l	a0-a1,-(a7)				; Save used registers

	.if ^^defined USE_CDROM 

		jsr		CD_ptr					; Get pointer location
	.else
		movea.l	#CBUF_END,a0			; Fudge the value
	.endif

		move.l	a0,CDWritePtr			; Store it for later reference
		movem.l	(a7)+,a0-a1				; Restore used registers
		rts

;==============================================================================
;	Subroutine to compute time code.
;
;		Input:	d0 = data offset in bytes
;
;		Output:	d0 = time code (00:mm:ss:bb)
;==============================================================================

GetTimeCode:
		move.l	d1,-(a7)				; Save register

		move.l	mediaOffset,d1			; Media offset
		add.l	d0,d1					; Add data offset
		move	#BLK_SIZE,d0			; Block offset from media base
		bsr		LongDivide				; Convert to blocks
		addi.l	#MEDIA_BASE,d1			; Seek address in blocks

		divu	#BLK_RATE,d1			; d1 = 00:bb:00:ss
		clr.l	d0						; d0 = 00:00:00:00
		swap	d1						; d1 = 00:ss:00:bb
		move	d1,d0					; d0 = 00:00:00:bb
		clr		d1						; Nuke the remainder
		swap	d1						; d1 = 00:00:00:ss
		divu	#60,d1					; d1 = 00:ss:00:mm
		swap	d1						; d1 = 00:mm:00:ss
		lsl		#8,d1					; d1 = 00:mm:ss:00
		or.l	d1,d0					; d0 = 00:mm:ss:bb

		move.l	(a7)+,d1				; Restore register
		rts

;==============================================================================
;	Subroutine to copy over the DSP program.
;
;		Input:	None
;
;		Output:	None
;==============================================================================

LoadDSP:
		lea		DSP_STOP,a0
		move.l	#1,(a0)					; Tell the DSP to stop

WaitDSP:
		move.l	D_CTRL,d0				; Read DSP control register
		btst	#0,d0					; Is it still running?
		bne.s	WaitDSP					; Yes, wait for it to stop

		clr.l	(a0)					; Now clear the stop flag

		movea.l	#DSP_LOAD,a1			; Destination in DSP memory
		movea.l	#DSP_S,a0				; Source in CPU memory

.Loop0:
		move.l	(a0)+,(a1)+
		cmpa.l	#DSP_E,a0				; Reached EOF in CPU memory?
		bne.s	.Loop0					; No, continue

; Make sure the DACs are silent!

		move.l	#0,R_DAC
		move.l	#0,L_DAC

; Set up the I2S mode and clock.

		move.l	#18,SCLK				; 21.793 kHz
		move.l	#$15,SMODE				; FALLING, WSEN, INTERNAL

; Enable sound (mute bit).

		move.w	#$100,JOYSTICK
	
		rts

;==============================================================================
;	Subroutine to copy over both GPU Cinepak decompressor, followed by CD-ROM
;	support code.
;
;		Input:	None
;
;		Output:	None
;==============================================================================

LoadGPU:
		clr.l	d0						; (can't CLR.L to GPU!!)
		move.l	d0,G_CTRL				; Stop the GPU
		move.l	d0,G_FLAGS				; Clear interrupt enables

		move.l	#GPU_OFFSET,GPUOffset	; Initialize offset value
		movea.l	#G_RAM+GPU_OFFSET,a0	; Where to load decompressor
		movea.l	#DECOMP_S,a1			; Source in CPU memory

GPULoop:
		move.l	(a1)+,(a0)+
		cmpa.l	#DECOMP_E,a1			; Reached EOF in CPU memory?
		bne.s	GPULoop					; No, continue
	.if ^^defined USE_CDROM
		jsr		CD_init					; Load support code
	.endif
		rts

;==============================================================================
;	Subroutine to perform long division. Correctly handles overflow in cases
;	where the quotient exceeds 16-bit range. Remainder is discarded.
;
;		Input:	d0 = unsigned 16-bit divisor
;				d1 = unsigned 32-bit dividend: [Dhi,Dlo]
;
;		Output:	d1 = unsigned 32-bit quotient: [Qhi,Qlo]
;==============================================================================

LongDivide:
		divu	d0,d1					; d1 = Rlo, Qlo
		bvs.s	FixOverflow				; We overflowed, fix it

		swap	d1						; d1 = Qlo, Rlo
		clr		d1						; d1 = Qlo, 000
		swap	d1						; d1 = 000, Qlo
		rts

FixOverflow:
		move.l	d2,-(a7)				; Save register

		move	d1,d2					; d2 = xxx, Dlo
		clr		d1						; d1 = Dhi, 000
		swap	d1						; d1 = 000, Dhi
		divu	d0,d1					; d1 = Rhi, Qhi
		swap	d1						; d1 = Qhi, Rhi
		swap	d2						; d2 = Dlo, xxx
		move	d1,d2					; d2 = Dlo, Rhi
		swap	d2						; d2 = Rhi, Dlo
		divu	d0,d2					; d2 = Rlo, Qlo
		move	d2,d1					; d1 = Qhi, Qlo

		move.l	(a7)+,d2				; Restore register
		rts

;==============================================================================
;	Subroutine to set up controls and play data from CD-ROM.
;
;		Input:	a0 = starting destination address
;				d0 = data offset on CD-ROM
;
;		Output:	None
;==============================================================================

ReadCDData:
	.if ^^defined USE_CDROM 

		movem.l	a1-a2/d1,-(a7)			; Save registers (CD_read uses a2/d1)

		movea.l	#CBUF_END,a1			; End of destination buffer
		bsr		GetTimeCode				; Get start time code in d0
		jsr		CD_read					; Read from specified time code

		movem.l	(a7)+,a1-a2/d1			; Restore registers
	.endif
		rts

;==============================================================================
;	Subroutine to set up parameters used to read next group of chunks from
;	CD-ROM.
;
;		Input:	a0 = Address of first chunk in circular buffer
;
;		Output:	None
;==============================================================================

SetNextGroup:
		move.l	a1,-(a7)				; Save registers

		movea.l	pNextGroup,a1			; Pointer to next group of chunks
		clr.l	buffChunks				; Clear buffer chunk count

AddChunkSize:
		adda.l	$4(a1),a0				; Add chunk size
		cmpa.l	#CBUF_END,a0			; Did chunk fit in buffer?
		bgt.s	SetPointer				; No, set chunk pointer

		lea		$10(a1),a1				; Advance chunk table pointer
		addq.l	#1,buffChunks			; Increment buffer chunk count
		subq.l	#1,filmChunks			; Decrement film chunk count
		bne.s	AddChunkSize			; Alternate exit if no more left

SetPointer:
		move.l	a1,pNextGroup			; Update pointer

		move.l	(a7)+,a1				; Restore registers
		rts

;==============================================================================
;	Subroutine to dump a snapshot of key pointers and variables in ROM emulator
;	memory. End of file is flagged with $eeeeeeee to facilitate post-mortems.
;
;		Input:	None
;
;		Output:	None
;==============================================================================

Snapshot:
		movem.l	d0/a0,-(a7)				; Save registers

		movea.l	debugHandle,a0			; Get debug pointer
		move.l	#$a5,d0
		move.l	d0,(a0)+				; 000000a5
		move.l	a5,(a0)+				; a5 contents
		move.l	#$a4,d0
		move.l	d0,(a0)+				; 000000a4
		move.l	a4,(a0)+				; a4 contents
		move.l	#$a3,d0
		move.l	d0,(a0)+				; 000000a3
		move.l	a3,(a0)+				; a3 contents
		move.l	#$d4,d0
		move.l	d0,(a0)+				; 000000d4
		move.l	d4,(a0)+				; d4 contents
		move.l	#$d5,d0
		move.l	d0,(a0)+				; 000000d5
		move.l	d5,(a0)+				; d5 contents
		move.l	#$d7,d0
		move.l	d0,(a0)+				; 000000d7
		move.l	d7,(a0)+				; d7 contents
		move	#0,(a0)+
		move	catchUp,(a0)+			; catchUp
		bsr		GetCDWritePtr
		move.l	CDWritePtr,(a0)+		; CD write pointer
		move.l	8(a3),(a0)+				; s->Time
		move.l	time,(a0)+				; time
		move.l	#$eeeeeeee,(a0)			; Marker
		move.l	a0,debugHandle			; Save pointer for next time

		movem.l	(a7)+,d0/a0				; Restore registers
		rts

;------------------------------------------------------------------------------
;	Declare externals and globals.
;------------------------------------------------------------------------------

		.extern		DSP_LOAD
		.extern 	DSP_S
		.extern		DSP_E

		.extern 	DECOMP_S
		.extern		DECOMP_E

		.extern		DSP_STOP			; Flag tells DSP to stop

		.extern		buffChunks
		.extern		catchUp
		.extern		CDWritePtr
		.extern		debugHandle
		.extern		filmChunks
		.extern		GPUOffset
		.extern		mediaOffset
		.extern		pNextGroup
		.extern		time

		.extern		Play_CD				; Play the CD-ROM

		.globl		FindSync			; Find sync pattern in data stream
		.globl		GetCDWritePtr		; Get location of CD-ROM write
		.globl		LoadDSP				; Load DSP code
		.globl		LoadGPU				; Load GPU code
		.globl		LongDivide			; Long division routine
		.globl		ReadCDData			; Play CD and fill circular buffer
		.globl		SetNextGroup		; Set next chunk group's parameters
		.globl		Snapshot			; Make debug snapshot in ROM

		.end
%
