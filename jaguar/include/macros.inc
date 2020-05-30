;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; MACROS.INC - Copyright (c)1994 Atari Corp.
;;              All Rights Reserved
;;
;; Last Modification: 8/18/94 - SDS
;;
;; UNAUTHORIZED REPRODUCTION, ADAPTATION, DISTRIBUTION,
;; PERFORMANCE OR DISPLAY OF THIS COMPUTER PROGRAM OR
;; THE ASSOCIATED AUDIOVISUAL WORK IS STRICTLY PROHIBITED.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;*======================================================================*
;*	REGISTER EQUATES
;*======================================================================*

IF DEBUG_ON

DbTemp1       	REGEQU	r26
DbTemp2       	REGEQU	r27
DbOut		REGEQU	r28

ENDIF

;*======================================================================*
;*	MACROS
;*======================================================================*
;
;	General Purpose JSR
;

MACRO	JSR			; Jump to subroutine macro
				;	trashes R0
	subq	4,SP		; adjust the stack pointer
	nop
	move	PC,r0		; determine current program address
	addq	16,r0		; new address for after this macro
	store	r0,(SP)		; push return address onto stack
	movei	@1,r0		; load up subroutine address
	jump	(r0)		; jump to subroutine
	nop			; jump doesn't occur until this instr
ENDM

MACRO	RTS			; Return from Subroutine macro
				;	trashes r0
	load	(SP),r0		; load up return address
	addq	4,SP		; adjust the stack pointer
	jump	(r0)		; jump back to return address
	nop			; jump doesn't occur until this instr
ENDM

MACRO	PUSH			; push a value onto the stack
	store	@1,(SP)		; put argument onto the stack
	subq	4,SP		; adjust the stack pointer
	nop
ENDM

MACRO	POP			; pop a value off the stack
	load	(SP),@1		; take arguement off the stack
	addq	4,SP		; adjust stack pointer
	nop
ENDM

MACRO	CLEAR			; set a register to 0
	xor	@1,@1		; XOR of self is 0, quicker than movei **I'm not convinced this is true!!**
ENDM


MACRO	DEBUG
	IF	DEBUG_ON
	nop
	moveta	r0,DbTemp1     	; save r0 to use for output
	moveta	r1,DbTemp2     	; save r1
	move	@1,r1
	movefa	DbOut,r0       	; load output address
	store	r1,(r0)	       	; output register contents
	addq	#4,r0	       	; advance output address
	nop
	moveta	r0,DbOut       	; save output address
	move	r1,@1	       	; restore data
	movefa	DbTemp2,r1     	; restore r1
	nop
	movefa	DbTemp1,r0     	; restore r0
	nop
	ENDIF
ENDM

MACRO	DEBUG_INIT	       	; initialize debug area
	IF	DEBUG_ON
	movei	#$00f03e00,r0  	; Debug output address
	moveta	r0,DbOut       	; Debug in alternate register bank
	ENDIF
ENDM

MACRO	LEAVE		       	; forced exit of GPU program
	IF	DEBUG_ON
	movei	#gpuend,r0
	nop
	jump	(r0)
	nop
	ENDIF
ENDM

MACRO	VOMIT
	moveta	@1,r0	       	; **WARNING: Lark's Vomit**
ENDM					

MACRO	TIMEBAR		       	; timing bar utility
	IF	BAR_ON
	moveta	r0,r0	       	; save r0 to use for output
	moveta	r1,r1	       	; save r1
	movei	#@1,r0
	movei	#(BORD1+$7000000),r1
	store	r0,(r1)
	nop
	movefa	r1,r1	       	; restore r1
	nop
	movefa	r0,r0	       	; restore r0
	nop
	ENDIF
ENDM


;;;;;;;;;;;;;
;;;; EOF ;;;;
;;;;;;;;;;;;;