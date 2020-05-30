;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; GPUINT.INC - Constant file for GPU Interrupt Example

PPP		.equ	4		; Pixels per Phrase (16-bit CRY)
BMP_WIDTH	.equ	192		; Width in Pixels
BMP_PHRASES	.equ	(192/PPP)	; Width in Phrases
BMP_HEIGHT	.equ	67		; Height in Pixels
BMP_LINES	.equ	(BMP_HEIGHT*2)	; Height in Half Scanlines

LISTSIZE	.equ	8		; List length (in phrases)

BITMAP_OFF	.equ	16		; Byte Offset to bitmap in object list

ISTACK		.equ	$F03EFC		; Location of interrupt stack

OP_INT		.equ	$F03030		; GPU Object Processor Interrupt
					; Entry Point
OP_HNDLR_ADDR	.equ	$F03080		; Handler for GPU Object Processor
					; Interrupt
GPU_LOOP_ADDR	.equ	$F03200		; Address of program code which waits for a flag
					; and then shuts itself off.