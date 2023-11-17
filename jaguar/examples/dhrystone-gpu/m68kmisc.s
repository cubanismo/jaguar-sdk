	include	"jaguar.inc"
	extern	_DATA_E,_BSS_E,_Main,_VblCount

Start::	lea	_DATA_E,a0
	lea	_BSS_E,a1
	lea	$4000(a1),sp	;set stack
.l1:	cmp.l	a0,a1		;clean BSS
	ble.s	.s1
	clr.l	(a0)+
	bra.s	.l1
.s1:	move.l	#$55aaaa55,d0	;trash stack
.l2:	cmp.l	a0,sp
	ble.s	.main
	move.l	d0,(a0)+
	bra.s	.l2
.main:	;clr.w	VMODE
	;lea	MEMCON1,a0
	;move.w	(a0),d0
	;and.w	#$e7ff,d0
	;or.w	#$1000,d0
	;move.w	d0,(a0)
	bsr	_Main
	illegal

_Vbl::	move.w	d0,-(sp)
	move.w	INT1,d0
	cmp.w	#1,d0
	bne.s	.end
	addq.l	#1,_VblCount
.end:	move.w	#$101,INT1
	clr.w	INT2
	move.w	(sp)+,d0
	rte
