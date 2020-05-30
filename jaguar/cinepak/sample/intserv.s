
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
; Revision 1.01 6/1/95 mf
; removed local equate of USER0 interrupt vector (now defined in JAGUAR.INC)
;
; Revision 1.0	04/08/94  14:01:05  jpe
; Initial revision.
;******************************************************************************

	.include    'jaguar.inc'

	.globl	IntInit
	.globl	RefreshData
	.extern a_vde
	.extern Lister
	.extern time
	.extern timeIncr
	.extern semaphore

; This will set up the VI (Vertical line counter interrupt).

IntInit:
	lea	IntSvce,a0	    ; Address of service routine
	move.l	a0,USER0	    ; Set up the vector
	move	a_vde,d0
	or	#1,d0
	move	d0,VI		    ; Set the maximum VBLANK time
	move	#3,INT1 	    ; Enable GPU, VI    
	andi	#$f8ff,sr	    ; Lower the 68K IPL
	rts

IntSvce:
	movem.l d0-d1/a0-a1,-(sp)

	move	INT1,d0 	    ; Read interrupt control register
	btst	#0,d0		    ; Test VI bit
	beq.s	TestGPU 	    ; If zero, proceed

; Vertical interval interrupt: Refresh object list and increment time.

	lea	time+2,a0	    ; Lower 32 bits of time
	move.l	timeIncr,d1	    ; Q16 time increment
	add.l	d1,(a0) 	    ; Increment time
	bcc.s	ObjSvce 	    ; If no carry, do object list

	addq	#1,-(a0)	    ; Increment upper 16 bits

ObjSvce:
	lea	RefreshData,a0
	move.l	(a0)+,d1	    ; Start of object list
	movea.l d1,a1		    ; Make a copy

	lea	$10(a1),a1	    ; First phrase of bit-mapped object 
	move.l	(a0)+,(a1)+	    ; Refresh 1st long word
	move.l	(a0),(a1)	    ; Refresh 2nd long word

	swap	d1
	move.l	d1,OLP		    ; Start object processor

	ori	#$100,d0	    ; Clear VI pending

TestGPU:
	btst	#1,d0		    ; Test GPU bit
	beq.s	IntExit 	    ; If zero, proceed

; GPU interrupt: Set semaphore to wake up main program.

	lea	semaphore,a0
	move	#$ffff,(a0)	    ; Set semaphore
	ori	#$200,d0	    ; Clear GPU pending

IntExit:

	ori	#$3,d0		    ; Enable GPU, VI
	move	d0,INT1 	    ; Clear pending & re-enable
	move	d0,INT2 	    ; Resume normal bus priority

	movem.l (sp)+,d0-d1/a0-a1
	rte

; Here is where the data to refresh the object list are stored.

RefreshData:
	dc.l	0		    ; Start of object list
	dc.l	0		    ; 1st refresh datum
	dc.l	0		    ; 2nd refresh datum

	end
