;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; JAGUAR Multimedia Entertainment System Source Code
;;;
;;;	COPYRIGHT (c)1994 Atari Computer Corporation
;;;	UNAUTHORIZED REPRODUCTION, ADAPTATION, DISTRIBUTION,
;;;	PERFORMANCE OR DISPLAY OF THIS COMPUTER PROGRAM OR
;;;	THE ASSOCIATED AUDIOVISUAL WORK IS STRICTLY PROHIBITED.
;;;	ALL RIGHTS RESERVED.
;;;
;;;	Module: delzjag.s
;;;		GPU Code to Un-LZSS a Block of Memory
;;;
;;;   History: 09/20/94 - Created (SDS)
;;;            08/15/95 - Inserted a second NOP after store to G_CTRL (NBK)
;;;			  (Thanks for pointing that out to Nigel @ Distinctive) 
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		.include	"jaguar.inc"

;;; Exposed Globals
		.globl		_dlzstart
		.globl		_dlzend
		
		.globl		delzss

		.globl		lzinbuf
		.globl		lzoutbuf
		.globl		lzworkbuf

;;; Equates
INDEX_BIT_COUNT	.equ	13
LENGTH_BIT_COUNT	.equ	4
BREAK_EVEN		.equ	((1+INDEX_BIT_COUNT+LENGTH_BIT_COUNT)/9)		

		.68000
		.phrase
_dlzstart:
		.gpu
		.org	G_RAM+$100

;;; Register Equates
lzinbufptr	.equr	r0
lzoutbufptr	.equr	r1
lzworkbufptr	.equr	r2

currentpos	.equr	r3
ch		.equr	r4

addr		.equr	r5
temp		.equr	r6

matchlen	.equr	r7
matchpos	.equr	r8
mask		.equr	r9
rack		.equr	r10
bufmask	.equr	r11
bigmask	.equr	r12
startmask	.equr	r13

rbigloop	.equr	r14
mreg		.equr	r15
preg		.equr	r16
inner		.equr	r17
compressed	.equr	r18
done		.equr	r19

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; INPUT_BITS destreg,num_bits

MACRO	INPUT_BITS	destreg, num_bits
		moveq	#1,bigmask		; bigmask = 1 << (bit_count - 1)
		moveq	#0,\destreg

		shlq	#\num_bits-1,bigmask

		movei	#.m\~,mreg
		movei	#.p\~,preg
.m\~:
		cmpq	#0,bigmask		; If bigmask == 0 we're done
		jump	EQ,(preg)		; (1 wait)
		nop
		
		cmp	startmask,mask		; (1 wait)
		jr	NE,.n\~
		nop

		load	(lzinbufptr),rack	; Load new input byte
		addq	#4,lzinbufptr
.n\~:
		move	rack,temp		; if( rack & mask ) destreg |= bigmask
		and	mask,temp		; (1 wait)

		jr	EQ,.o\~			; (1 wait)
		nop

		or	bigmask,\destreg
.o\~:
		shrq	#1,bigmask		; bigmask >>= 1
		shrq	#1,mask			; mask >>= 1
		
		jump	NE,(mreg)		; (1 wait )
		nop

		move	startmask,mask
		jump	T,(mreg)
		nop
.p\~:
ENDM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; This is our routine entry point (instructions are interleaved for speed)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
delzss:
		movei	#lzinbuf,addr		; Address of variables
		movei	#$80000000,mask	  	; Mask to shift
		movei	#cstream,compressed	

		load	(addr),lzinbufptr	
		addq	#4,addr			; Next long variable

		movei	#$1FFF,bufmask		; Mask for 8k buffer
		load	(addr),lzoutbufptr
		addq	#4,addr			; Next long buffer

		load	(addr),lzworkbufptr

		movei	#bigloop,rbigloop	; Put in register for quick access
		move	mask,startmask		; Copy for later compares
		movei	#getchs,inner
		moveq	#1,currentpos		; Current position in window
		movei	#alldone,done
bigloop:
		cmp	startmask,mask		; Is mask $80?
		jr	NE,noreread
		nop

		load	(lzinbufptr),rack	; Get a new byte
		addq	#4,lzinbufptr
noreread:
		move	rack,temp		; Make a copy
		and	mask,temp		; Isolate bit (1 wait)

		shrq	#1,mask			; mask >>= 1
		jr	NE,havemask		; (1 wait)
		nop

		move	startmask,mask		; If mask == 0, mask = $80
havemask:
		cmpq	#0,temp			; Do final test to set ZERO flag
		jump	EQ,(compressed)		; If 0, get compressed stream	
		nop

		INPUT_BITS	ch,8

		storeb	ch,(lzoutbufptr)	; store byte
		addq	#1,lzoutbufptr		; go to next buffer pos

		and	bufmask,currentpos	; force range of 0-8191

		move	lzworkbufptr,addr  	; get address of window
		add	currentpos,addr		; add offset (1 wait)
		addq	#1,currentpos		; increment window pointer
		storeb	ch,(addr)		; update window

		jump	T,(rbigloop)		
		nop
cstream:
		INPUT_BITS	matchpos,13	; Get Index into Window

		cmpq	#0,matchpos		; END_OF_STREAM???
		jump	EQ,(done)		; (1 wait)
		nop
		
		INPUT_BITS	matchlen,4	; Get Length of Match
		addq	#BREAK_EVEN,matchlen
getchs:
		and	bufmask,matchpos
		move	lzworkbufptr,addr  	; Get Window Address + Offset
		and	bufmask,currentpos	; Range check currentpos
		add	matchpos,addr		; ^ avoids 1 wait

		loadb	(addr),ch		; Load a byte from window
		or	ch,ch			; (1 wait on purpose)
		storeb	ch,(lzoutbufptr)	; Store it to our buffer
		addq	#1,lzoutbufptr
					   
		move	lzworkbufptr,temp  	; Store byte in window
		add	currentpos,temp		; @ currentpos (1 wait)
		addq	#1,currentpos		; Update Window Position
		storeb	ch,(temp)		; Update Buffer
		
		addq	#1,matchpos		; Increment window read addr
		subq	#1,matchlen		; Decrement loop counter

		jump	PL,(inner)		; ->getchs (1 wait)
		nop

		jump	T,(rbigloop)
		nop

;;; Ok, we're done... now leave.
alldone:
		moveq	#0,temp
		movei	#G_CTRL,addr
		store	temp,(addr)
		nop
		nop

		.long

lzinbuf: 	.dc.l	0		; Pointer to Compressed Data
lzoutbuf:	.dc.l	0		; Pointer of Destination Buffer
lzworkbuf:	.dc.l	0		; Pointer to 8k LZSS Window

		.68000
_dlzend:
		.end
