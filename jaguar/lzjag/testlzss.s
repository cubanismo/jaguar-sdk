;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; JAGUAR Multimedia Entertainment System Source Code
;;;
;;;	COPYRIGHT (c)1994 Atari Computer Corporation
;;;	UNAUTHORIZED REPRODUCTION, ADAPTATION, DISTRIBUTION,
;;;	PERFORMANCE OR DISPLAY OF THIS COMPUTER PROGRAM OR
;;;	THE ASSOCIATED AUDIOVISUAL WORK IS STRICTLY PROHIBITED.
;;;	ALL RIGHTS RESERVED.
;;;
;;;	Module: testlzss.s
;;;		Test LZSS Decompression Routine
;;;
;;;   History: 09/20/94 - Created (SDS)
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		.include	"jaguar.inc"
		
		.extern		_dlzstart
		.extern		_dlzend
		.extern		delzss

		.extern		lzinbuf
		.extern		lzoutbuf
		.extern		lzworkbuf

		.extern		moucode

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Program Entry Point Follows

		move.l	#$00070007,G_END
		move.w	#$FFFF,VI
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Load the GPU with the DELZSS routine
blitwait:
		move.l	B_CMD,d0	; Make sure blitter is idle
		andi.l	#1,d0
		beq	blitwait

		lea	_dlzstart,a0	; Start of GPU code in ROM
		move.l	#_dlzend,d0	; End of GPU code in ROM
		sub.l	a0,d0		; Find # of bytes to copy
		lsr.l	#2,d0		; make # of longs to copy

; The destination pointer is the GPU RAM Address + $8000 for 32-bit copies
		move.l	#delzss+$8000,A1_BASE	
		move.l	a0,A2_BASE	; Source in ROM from above

		move.l	#PITCH1|PIXEL32|XADDPHR,A1_FLAGS
		move.l	#PITCH1|PIXEL32|XADDPHR,A2_FLAGS

		move.l	#0,A1_CLIP	; Required for Blitter Bug

		move.l	#0,A1_PIXEL
		move.l	#0,A2_PIXEL

		or.l	#$00010000,d0	; One outer loop
		move.l	d0,B_COUNT
		move.l	#SRCEN|LFU_REPLACE,B_CMD

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Now set up the Decompression parameters
		move.l	#moucode,lzinbuf	; Pointer to compressed data
		move.l	#$100000,lzoutbuf	; Pointer where code executes
		move.l	#$40000,lzworkbuf	; 8k working buffer

		move.l	#delzss,G_PC
		move.l	#1,G_CTRL

;;; If you have other things to do here that don't need the buffers
;;; or the GPU, now would be a good time. Just wait for the GPU to
;;; stop as shown below before using any of the above

gpuwait:
		move.l	G_CTRL,d0		; Wait for GPU to finish
		andi.l	#1,d0
		bne	gpuwait

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Start the newly decompressed code

		move.l	#$100000,a0
		jmp	(a0)

		.end
		 