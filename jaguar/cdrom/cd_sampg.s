; last modified: nbk, 95-Jul-24
; fixed bug of stack and space allocation directive 
;
	.include "jaguar.inc"

	.globl	GPUSTART
	.globl	GPUEND

GPUSTART:
	.gpu
	.org	$f03000

	.globl	SETUP
	.globl	CDREADER
	.globl	CODE_TOP

CPU_VEC:
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop

DSP_VEC:
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop

PIT_VEC:
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop

OBJ_VEC:
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop

BLIT_VEC:
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop

SETUP:

; THIS SETUP OF REGISTERS IS JUST "JUNK" CODE
; IT PLACES EASY TO SEE DATA IN THE REGISTERS
; SO THAT IT WILL BE OBVIOUS WHAT REGISTERS
; ARE USED.
;
; ONLY R31 (the Stack) NEEDS TO BE SETUP

	movei	#$1000,r0

	movei	#$1001,r1

	movei	#$1002,r2

	movei	#$1003,r3

	movei	#$1004,r4

	movei	#$1005,r5

	movei	#$1006,r6

	movei	#$1007,r7

	movei	#$1008,r8

	movei	#$1009,r9

	movei	#$1010,r10

	movei	#$1011,r11

	movei	#$1012,r12

	movei	#$1013,r13

	movei	#$1014,r14

	movei	#$1015,r15

	movei	#$1016,r16

	movei	#$1017,r17

	movei	#$1018,r18

	movei	#$1019,r19

	movei	#$1020,r20

	movei	#$1021,r21

	movei	#$1022,r22

	movei	#$1023,r23

	movei	#$1024,r24

	movei	#$1025,r25

	movei	#$1026,r26

	movei	#$1027,r27

	movei	#$1028,r28

	movei	#$1029,r29

	movei	#$1030,r30

; DONE PLAYING

; Do something useful

	movei	#STACK,r31

; this is just an empty loop. For IRQ handlers to be working the
; GPU must be runnning.

loploc:
	nop
	jr	loploc
	nop

	.long

stackbot:
;	dc.l 16			;BUG !!! This allocates only one long with value 16 !
	.dcb.l	16,0
STACK:

CDREADER:
;	dc.b 224		;BUG !!! This allocates only one byte with value 224 !

	.dcb.b	224,0		; This number is correct only for CD_init, not initf or initm!
				; the correct numbers for CD_initf and CD_initm are documented 
				; in the CDBIOS developer documentation
CODE_TOP:
	.68000
GPUEND:

