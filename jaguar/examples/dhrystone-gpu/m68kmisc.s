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
.if ^^defined USE_SKUNK
	; The skunk BIOS disables video interrupts. Reactivate them.
	move.l	#_EmptyVbl,LEVEL0
	move.w	#519,VI
	move.w	#C_VIDENA,INT1
	move.w	sr,d0
	and.w	#$F8FF,d0
	move.w	d0,sr
.endif ; ^^defined USE_SKUNK
	bsr	_Main
	illegal

.if ^^defined USE_SKUNK
_EmptyVbl: ; No-op VBlank interrupt handler for environments that don't have one
	move.w	#$101,INT1
	clr.w	INT2
	rte
.endif ; ^^defined USE_SKUNK

_Vbl::	move.w	d0,-(sp)
	move.w	INT1,d0
	cmp.w	#1,d0
	bne.s	.end
	addq.l	#1,_VblCount
.end:	move.w	#$101,INT1
	clr.w	INT2
	move.w	(sp)+,d0
	rte

.if ^^defined USE_SKUNK
.bss
	.long
_skunkstr::
	.ds.b	128
.endif ; ^^defined USE_SKUNK
