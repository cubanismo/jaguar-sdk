	.include        'jaguar.inc'

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.globl  IntInit

	.extern a_vde
	.extern Lister  ; Object processor list creator

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This will set up the VI (Vertical line counter Interrupt)

IntInit:
	move.l  #Frame,USER0            ; Set up the vector

	move.w  a_vde,d0
	or.w    #1,d0
	move.w  d0,VI                   ; Get the maximum VBLANK time

	move.w  #1,INT1

	move.w  sr,d0
	and.w   #$f8ff,d0               ; Lower the 68K IPL
	move.w  d0,sr

	rts

Frame:
	movem.l d0-d5/a0-a5,-(sp)

	jsr     Lister

	move.w  #$101,INT1
	move.w  #0,INT2
	movem.l (sp)+,d0-d5/a0-a5
	rte

	.phrase ; Force object code size alignment

