;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Jaguar Development System Source Code					   
; Copyright (c) 1994, 1995 Atari Corp.
; ALL RIGHTS RESERVED
;
; Project: eeprom.s - E2PROM Read & Write Functions (Non-Handshaking Version)
;  Module: eeprom.s - Low & High Level Read/Write Functions
;
; Revision History:
;	24-Sep-93 -  DS: Created
;     	29-Nov-94 - SDS: Modified to use delay rather than busy poll
;       	         for wait after write.
;       15-Dec-94 - SDS: Added Eeprom series of high level calls.
;	18-Jan-95 - SDS: Renamed calls from Eeprom... to ee...
;                        for more signifigant letters in Alcyon
;                        compilation.
;       14-Mar-95 - SDS: Fixed two routines to not save D0 so an
;                        error code is actually returned.
;       22-Sep-95 -  MF: Added Library identification header string
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		.include "jaguar.inc"	

;;;;;;;;;;;;;;;;;;;
;;; Global Symbols

		.globl eeWriteWord
		.globl eeWriteBank
		.globl eeReadWord
		.globl eeReadBank
		.globl eeUpdateChecksum
		.globl eeValidateChecksum

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;	Hi-Score on-board-cartridge EEPROM primitives 
;;;	for use by Jaguar game cartridge developers.
;;;
;;;	128 bytes (accessible as 64 words) of non-volatile
;;;	memory are available on Jaguar game cartridges to
;;;	preserve Hi-scores or other game status The last
;;;     word (word #63) should be used for a checksum on
;;;	data validity.
;;;
;;;	Data is retained for up to 10 years, and a minimum
;;;     of 100,000 write cycles is assured, according to
;;;	product literature. 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GPIO_0		.equ	$f14800		;General purpose I/O #0
GPIO_1		.equ	$f15000		;General purpose I/O #1

;   Equates derived from the above
;   to allow indirect with 16-bit displacement addressing

GPIO_0of	.equ	GPIO_0-JOYSTICK	;offset to GPIO_0 (when addr reg Ax -> JOY1) 
GPIO_1of	.equ	GPIO_1-JOYSTICK	;offset to GPIO_1 (when addr reg Ax -> JOY1) 

;   Commands tested on:
;	National Semiconductor NM93C14
;       Excel (equiv)
;	Atmel (equiv)
;	ISSI (equiv)
;
;  9-bit commands..
;		 876543210

eREAD		.equ	%110000000		;read from EEPROM
eEWEN		.equ	%100110000		;Erase/write Enable
eWRITE		.equ	%101000000		;Write selected register
eEWDS		.equ	%100000000		;Erase/Write disable (default)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  DO (data out)	- is read on bit0 of JOY1
;  DI (data in) 	- is written on bit0 of GPIO_0
;  CS (chip select)	- is pulsed low by any access to GPIO_1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EEPROM Library Header

		dc.b	"EEPROM Library",0,0		; 16 bytes long
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Procedure: eeWriteWord
;;;            Write a word to EEPROM and ensure it was written.
;;;
;;;  Inputs: d0.w = data to be written
;;;	     d1.w = least signifigant 6 bits specify write address (0-63)  
;;;
;;; Returns: d0.w = Non-zero indicates an error occurred

eeWriteWord:
		move.l	d2,-(sp)
		move.w	d0,d2		; Save value

		bsr	eewrite		; Write value
		bsr	eeread		; Read value back

		cmp.w	d0,d2		; Are they the same?
		bne	.badwrite

		move.w	#$0,d0		; Success
		bra	.ewwout
.badwrite:
		move.w	#$1,d0
.ewwout:
		move.l	(sp)+,d2
		rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Procedure: eeReadWord
;;;            Read a word from the EEPROM.
;;;
;;;  Inputs: d1.w = Least signifigant 6 bits specify write address (0-63)  
;;;
;;; Returns: d0.w = Word read

eeReadWord:
		bsr	eeread
		rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Procedure: eeWriteBank
;;;            Write 63 words to EEPROM plus one checksum word.
;;;
;;;  Inputs: a0.l = Pointer to data buffer containing 63 words to write
;;;
;;; Returns: d0.w = Non-zero indicates an error occurred

eeWriteBank:
		movem.l a0/d1-d3,-(sp)

		clr.w	d1		; Address counter
		clr.w	d2		; Checksum Accumulator
.loopwrite:
		move.w	(a0)+,d0
		add.w	d0,d2		; Add value to checksum

		move.w	d0,d3		; Copy it.

		bsr	eewrite		; Write the word
		bsr	eeread		; Read the word back

		cmp.w	d0,d3		; Are they the same?
		beq	.nextword

		bra	.errwrite
.nextword:
		addq.w	#1,d1
		cmp.w	#63,d1		; Write 63 words (0-62)
		blt	.loopwrite
		
		eor.w	#$FFFF,d2	; IMPORTANT!!!
		move.w	d2,d0
		
		bsr	eewrite
		bsr	eeread
		
		cmp.w	d0,d2
		bne	.errwrite
		
		move.w	#$0,d0
		bra	.ewbout
.errwrite:
		move.w	#$1,d0	
.ewbout:
		movem.l	(sp)+,a0/d1-d3
		rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Procedure: eeReadBank
;;;            Read a bank of 63 words (+ checksum) from the EEPROM.
;;;
;;;  Inputs: a0.l = Destination buffer of write data  
;;;
;;; Returns: d0.w = Non-zero indicates an error occurred

eeReadBank:
		movem.l	a0/d1-d2,-(sp)

		clr.w	d1		; Address counter
		clr.w	d2		; Checksum accumulator
.nextread:
		jsr	eeread		; Read data
		add.w	d0,d2		; Add to checksum
		move.w	d0,(a0)+	; Store data in buffer
		
		addq.w	#1,d1
		cmp.w	#63,d1
		blt	.nextread
		
		eor.w	#$FFFF,d2	; IMPORTANT!!!

		bsr	eeread
		cmp.w	d0,d2		; Do checksums match?
		bne	.bankerror
		
		move.w	#$0,d0
		bra	.eerbout
.bankerror:
		move.w	#$1,d0	
.eerbout:
		movem.l	(sp)+,a0/d1-d2
		rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Procedure: eeUpdateChecksum
;;;            Read a bank of 63 words, calculate a new checksum, and write it.
;;;
;;; Returns: d0.w = Non-zero indicates an error occurred

eeUpdateChecksum:
		movem.l	d1-d2,-(sp)

		clr.w	d1		; Address counter
		clr.w	d2		; Checksum accumulator
.nextread:
		bsr	eeread		; Read data
		add.w	d0,d2		; Add to checksum
		
		addq.w	#1,d1
		cmp.w	#63,d1
		blt	.nextread
		
		eor.w	#$FFFF,d2	; IMPORTANT!!!

		move.w	d2,d0
		jsr	eeWriteWord	; Will return error in D0

		movem.l	(sp)+,d1-d2
		rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Procedure: eeValidateChecksum
;;;            Read a bank of 63 words (+ checksum) and return
;;;	       an error code if checksum does not validate.
;;;
;;; Returns: d0.w = Non-zero indicates an error occurred

eeValidateChecksum:
		movem.l	d1-d2,-(sp)

		clr.w	d1		; Address counter
		clr.w	d2		; Checksum accumulator
.nextread:
		bsr	eeread		; Read data
		add.w	d0,d2		; Add to checksum
		
		addq.w	#1,d1
		cmp.w	#63,d1
		blt	.nextread
		
		eor.w	#$FFFF,d2	; IMPORTANT!!!

		bsr	eeread
		cmp.w	d0,d2		; Do checksums match?
		bne	.bankerror
		
		move.w	#$0,d0
		bra	.eerbout
.bankerror:
		move.w	#$1,d0	
.eerbout:
		movem.l	(sp)+,d1-d2
		rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; LOW-LEVEL PRIMITIVE (DO NOT CALL DIRECTLY...OR MODIFY FOR THAT MATTER)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Procedure: eewrite
;;;            Write a word to EEPROM
;;;
;;;  Inputs: d0.w = data to be written
;;;	     d1.w = least signifigant 6 bits specify write address (0-63)  
;;;

eewrite:
		movem.l	a0/d0-d3,-(sp)
		lea	JOYSTICK,a0  	;set ptr to EEPROM i/o addresses

		tst.w	GPIO_1of(a0)	;strobe ChipSelect

		move.w	#eEWEN,d2	;erase/write enable command
		bsr	out9bits	;send it to EEPROM

		tst.w	GPIO_1of(a0)	;strobe ChipSelect

		andi.w	#$3f,d1		;force write addr to be legit (0-63)
		ori.w	#eWRITE,d1	;form WRITE command
		move.w	d1,d2
		bsr	out9bits	;send it to EEPROM

		move.w	d0,d2		;get 16-bit data word to send
		bsr	out16bit	;  & send it

		tst.w	GPIO_1of(a0)	;strobe ChipSelect

;;; Chip specs say to wait 1 msec for status valid...we wait an additional
;;; 10 to ensure write has completed because the chip status report can't
;;; be relied upon in our case.

		move.w	#5267,d0    	; Wait 11 msecs
wrwait:
		nop			
		nop
		nop
		nop
		nop
		nop
		dbra	d0,wrwait

		move.w	#eEWDS,d2	;get erase/write disable command
		bsr	out9bits	;send it

		tst.w	GPIO_1of(a0)	;strobe ChipSelect

		movem.l	(sp)+,a0/d0-d3
		rts			;we're done

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; LOW-LEVEL PRIMITIVE (DO NOT CALL DIRECTLY...OR MODIFY FOR THAT MATTER)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Procedure: eeread
;;;            Read a word from EEPROM
;;;
;;;  Inputs: d1.w = least signifigant 6 bits specify read address (0-63)  
;;;
;;; Returns: d0.w = data as read from EEPROM
;;;

eeread:
		movem.l	a0/d1-d3,-(sp)
		lea	JOYSTICK,a0 	;set ptr to EEPROM i/o address

		tst.w	GPIO_1of(a0)	;strobe ChipSelect

		andi.w	#$3f,d1		;force legit read addr
		ori.w	#eREAD,d1
		move.w	d1,d2
		bsr	out9bits

		moveq	#0,d0
		moveq	#15,d2		;pick up 17 bits (1st is dummy)
inlp:	
		tst.w	GPIO_0of(a0)
		nop
		move.w	(a0),d1
		lsr.w	#1,d1
		addx.w	d0,d0
		nop
		nop
		nop
		nop
		nop
		nop
		dbra	d2,inlp

		movem.l	(sp)+,a0/d1-d3
		rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Procedures: out16bit/out9bits
;;;             Output 'x' bits to the eeprom.
;;;	      Serial data sent to device is written to DI, bit0 of GPIO_0
;;;
;;; Inputs: a0.l = JOYSTICK
;;;  	    d2.w = 9/16-bit data word to write
;;;
;;; Register Usage: d2.w, d3.l are destroyed
;;;			     

out16bit:
		rol.w	#1,d2		;align 1st serial data bit (bit15) to bit0
		moveq	#15,d3		;send 16 bits
		bra.s	out9lp
out9bits:
		rol.w	#8,d2		;align 1st serial data bit (bit8) to bit0
		moveq	#8,d3		;send 9
out9lp:
		move.w	d2,GPIO_0of(a0)	;write next bit
		nop
		nop
		nop			;delay next write
		nop
		nop
		nop
		rol.w	#1,d2		;adjust bit0 for next datum
		dbra	d3,out9lp	;go for all 9 or all 16
		rts

		.end

