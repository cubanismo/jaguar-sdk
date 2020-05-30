; Jaguar Development System Source Code					   
; Copyright (c)1994,95 Atari Corp.
; ALL RIGHTS RESERVED
;
; Project: eeprom.s - E2PROM Read & Write Functions (Non-Handshaking Version)
;  Module: test_e2.s - E2PROM High Level Function Tests
;
; Revision History:
;       15-Dec-94 - SDS: Created.
;       18-Jan-95 - SDS: Changed named Eeprom... to ee... for
;                        more label signifigance in Alcyon symbol links.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Test the four E2prom High-Level Functions:
; 	eeWriteWord, eeReadWord
; 	eeWriteBank, eeReadBank
; 	eeUpdateChecksum, eeValidateChecksum
;
; 1. Call eeWriteBank with one of two alternating patterns of data called
;    testbank1 and testbank2.
; 2. Call eeReadBank and compare to original copy.
; 3. For each 63 addresses:
;	Call eeWriteWord to write some incrementing word.
;       Call eeReadWord to read word just written.
;	Call eeWriteWord to write !(some incrementing word).
;       Call eeReadWord to read word just written.
;	Call eeWriteWord to write 0.
;       Call eeReadWord to read word just written.
;	Call eeWriteWord to write $FFFF.
;       Call eeReadWord to read word just written.
;	Call eeWriteWord to write 0.
;       Call eeReadWord to read word just written.
; 4. Call eeUpdateChecksum to update checksum we just trashed.
; 5. Call eeValidateChecksum to ensure things are ok.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		.globl eeWriteWord
		.globl eeWriteBank
		.globl eeReadWord
		.globl eeReadBank
		.globl eeUpdateChecksum
		.globl eeValidateChecksum

		.68000
start:
		lea	errqueue,a6

		lea	testbank1,a3
		lea	testbank2,a4
		lea	testbuf,a5

		move.w	#0,d4		; Incrementing write value

		clr.l	d7		; # of iterations
		clr.l	goodwrites
loop:
		move.l	a3,a0		; Current test bank
		jsr	eeWriteBank

		tst.w	d0		; Did an error occur?
		beq	readbank

		move.l	#0,(a6)+	; Error #0
		move.l	d7,(a6)+	; @ position	
readbank:
		move.l	a5,a0		; Test buffer
		jsr	eeReadBank

		tst.w	d0		; Did an error occur?
		beq	cmpbufs

		move.l	#1,(a6)+	; Error #1
		move.l	d7,(a6)+	; @ position
cmpbufs:
		move.l	a3,a0		; Original Buffer
		move.l	a5,a1		; Buffer read

		move.w	#62,d1		; Compare 63 words
looptest:
		cmp.w	(a0)+,(a1)+	; Are they equal?
		bne	badfound
		dbra	d1,looptest

		bra	loopnums
badfound:
		move.l	#2,(a6)+	; Error #2
		move.l	d7,(a6)+	
loopnums:
		move.w	#62,d1
donext:
		move.w	d4,d0
		jsr	eeWriteWord

		tst.w	d0		; Did an error occur
		beq	.okwrite

		move.l	#3,(a6)+	; Error #3
		move.l	d7,(a6)+	; @ position
.okwrite:
		jsr	eeReadWord
		
		cmp.w	d0,d4
		beq	doxor
			
		move.l	#4,(a6)+	; Error #4
		move.l	d7,(a6)+	; @ position
doxor:
		move.w	d4,d0
		eor.w	#$FFFF,d0
		jsr	eeWriteWord

		tst.w	d0		; Did an error occur
		beq	.okwrite

		move.l	#5,(a6)+	; Error #5
		move.l	d7,(a6)+	; @ position
.okwrite:
		jsr	eeReadWord
		
		eor.w	#$FFFF,d0
		cmp.w	d0,d4
		beq	dozeroone
			
		move.l	#6,(a6)+	; Error #6
		move.l	d7,(a6)+	; @ position
dozeroone:
		move.w	#0,d0
		jsr	eeWriteWord

		tst.w	d0		; Did an error occur
		beq	.okwrite

		move.l	#7,(a6)+	; Error #7
		move.l	d7,(a6)+	; @ position
.okwrite:
		jsr	eeReadWord
		
		cmp.w	#0,d0
		beq	doone
			
		move.l	#8,(a6)+	; Error #8
		move.l	d7,(a6)+	; @ position
doone:
		move.w	#1,d0
		jsr	eeWriteWord

		tst.w	d0		; Did an error occur
		beq	.okwrite

		move.l	#9,(a6)+	; Error #9
		move.l	d7,(a6)+	; @ position
.okwrite:
		jsr	eeReadWord
		
		cmp.w	#1,d0
		beq	dozerotwo
			
		move.l	#10,(a6)+	; Error #10
		move.l	d7,(a6)+	; @ position
dozerotwo:
		clr.w	d0
		jsr	eeWriteWord

		tst.w	d0		; Did an error occur
		beq	.okwrite

		move.l	#11,(a6)+	; Error #11
		move.l	d7,(a6)+	; @ position
.okwrite:
		jsr	eeReadWord
		
		cmp.w	#0,d0
		beq	doupdate
			
		move.l	#12,(a6)+	; Error #12
		move.l	d7,(a6)+	; @ position
doupdate:
		jsr	eeUpdateChecksum

		tst.w	d0
		beq	dovalid

		move.l	#13,(a6)+	; Error #13
		move.l	d7,(a6)+	; @ position
dovalid:
		jsr	eeValidateChecksum

		tst.w	d0
		beq	incvars

		move.l	#14,(a6)+	; Error #14
		move.l	d7,(a6)+	; @ position
incvars:
		exg	a3,a4		; Switch test banks
		add.w	#1,d4		; Increment write value
		add.l	#1,d7		; Increment # of trials
		move.l	d7,goodwrites

		movem.l	d0-d2/a0-a2,-(sp)
		
		pea	msg		; Print a 'happy' msg
		move.w	#$F100,-(sp)
		move.l	#$000B0005,-(sp)
		trap	#14
		lea	10(sp),sp

		movem.l	(sp)+,d0-d2/a0-a2

		bra	loop

;;;;
;;;; Test Data
;;;;
		.data

testbank1:	
		.dc.w	0,1,2,3,4,5,6,7
		.dc.w	8,9,10,11,12,13,14,15
		.dc.w	16,17,18,19,20,21,22,23
		.dc.w	24,25,26,27,28,29,30,31
		.dc.w	32,33,34,35,36,37,38,39
		.dc.w	40,41,42,43,44,45,46,47
		.dc.w	48,49,50,51,52,53,54,55
		.dc.w	56,57,58,59,60,61,62
testbank2:
		.dc.w	$0000,$0001,$0002,$0004,$0008,$0010,$0020,$0040
		.dc.w	$0080,$0100,$0200,$0400,$0800,$1000,$2000,$4000
		.dc.w	$8000,$7FFF,$BFFF,$DFFF,$EFFF,$F7FF,$FBFF,$FDFF
		.dc.w	$FEFF,$FF7F,$FFBF,$FFDF,$FFEF,$FFF7,$FFFB,$FFFD
		.dc.w	$FFFE,$FFFF,$FFF0,$FF0F,$F0FF,$0FFF,$FF00,$00FF
		.dc.w	$F000,$0F00,$00F0,$000F,$0000,$1111,$2222,$3333
		.dc.w	$4444,$5555,$6666,$7777,$8888,$9999,$AAAA,$BBBB
		.dc.w	$CCCC,$DDDD,$EEEE,$FFFF,$1234,$5678,$FFFF	

msg:		.dc.b	"echo \"Completed an iteration...\";g",0

		.bss
testbuf:
		.ds.w	64
goodwrites:
		.ds.l	1
errqueue:
		.ds.l	4096		; Make this the last entry

		.end