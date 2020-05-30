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
; Revision History:
; 08/01/94  23:14:00  nbk
; Increased buffer size for circular buffer depending on setting
; of USE_CDROM, so you can see a 13 chunks version of the ESCAPE
; sequence from starwars
;
; 07/09/94  00:22:00  nbk
; Minimal changes to be surely to run even on outer rim of CD Rev. 2
; development systems and some more commets where to modify MEDIA_BASE
; to start reading film data other than at the beginning of the disk
;  
; 04/27/94  16:09:35  jpe
; CD-BIOS changes incorporated.
;
; 04/25/94  16:56:30  jpe
; Increased NLINES from 200 to 216.
; Increased SAMP_RATE from 22100 to 22252.
; Added definition of DRIFT_RATE.
;
; 04/08/94  13:52:35  jpe
; Initial revision.
;******************************************************************************

NPIXELS     	equ      320            ; Display pixels per line
NLINES      	equ      240            ; Display lines per screen
ROWBYTES        equ      2*NPIXELS      ; Bytes per line (16-bit pixels)

CBUF_SIZE       equ     $100000         ; Use 1 MByte for circular buffer

CBUF_END        equ     FILM_BASE+CBUF_SIZE  ; End of circular buffer
HEAD_START      equ     $c0000         ; Initial space between R/W pointers
			
GPU_OFFSET      equ     $200           ; Start of Cinepak GPU Code

FILM_SYNC       equ     '1111'         ; Main sync (precedes chunk table)
FILM_TAG        equ     'FILM'         ; FIlm header tag
SAMP_TAG        equ     'STAB'         ; Sample table tag

NORMAL_END      equ     $00000000      	; Normal end to program
SYNC_FAIL       equ     $11111111      	; Failed in sync search
BOGUS_FILM      equ     $22222222      	; Tag not found in film header
BOGUS_SAMP      equ     $33333333      	; Tag not found in sample table
PREDEC_ERR      equ     $44444444      	; Pre-decompress failed
DECOMP_ERR      equ     $55555555      	; Decompress failed

TICK_RATE       equ     600             ; PIT rate
AUD_CHUNK       equ     $4000           ; Audio chunk size (IMPORTANT!!!)
SAMP_RATE       equ     22252           ; Audio sample rate (IMPORTANT!!!)

;  The input sample rate is 22.252 kHz; the output rate is 21.867 kHz. The
;  ratio of these values is 1.017606439. A correction must periodically be
;  made to  prevent audio drift.

DRIFT_RATE  	equ     $481db08        ; 0.017606439 * (65536)^2 in Q32

AUDIO_LAG       set     (AUD_CHUNK<<16)/SAMP_RATE   ; Q16 value
AUDIO_LAG       set     AUDIO_LAG+(AUDIO_LAG>>1)    ; Multiply by 1.5

MAX_DELAY       set     8              ; Reciprocal of video-audio delay
MAX_DELAY       set     (1<<16)/MAX_DELAY       ; Q16 value

;  Time code parameters.

BLK_SIZE        equ     2352            ; CD block (sector) size in bytes
BLK_RATE        equ     75              ; 75 blocks/second @ 1X
SILENCE         equ     150             ; Number of silence blocks (when lead-in)
LEADER          equ     24              ; Number of blocks in leader (extra AIFF wrapper)

; this can be changed to make things work if you get sync problems all the time
MARGIN          equ     6               ; Safety margin
MEDIA_BASE  	equ 	0		; Not used in this demo

;  Data synchronization parameters.

SYNC_SIZE       equ      64             ; Number of bytes in sync
SRCH_WIN    	equ      (BLK_SIZE*31) 	; Search window (31 blocks)

; Object List Equates
LISTSIZE	.equ		6
BMP_PHRASES	.equ		(NPIXELS/4)
BITMAP_OFF	.equ		(3*8)
