;68K PIC fill routine for RDBJAG.
;This fills 1M in less than 2 sec.
;TAB=8

fill:
	bra.s	.beg
.dat:
	dcb.l	4,0			;size,with,nb,addr
.beg:
	movem.l	d0-d2/a0-a2,-(sp)
	movem.l	.dat(pc),d0-d2/a0-a2	;d0=size,d1=with,d2=nb,a0=addr
	subq.l	#1,d2
	bmi.s	.end

	subq.l	#1,d0
	bmi.s	.byte
	beq.s	.word

.long:
	move.l	d1,(a0)+
	subq.l	#1,d2
	bpl.s	.long
	bra.s	.end

.word:
	move.w	d1,(a0)+
	subq.l	#1,d2
	bpl.s	.word
	bra.s	.end

.byte:
	move.b	d1,(a0)+
	subq.l	#1,d2
	bpl.s	.byte

.end:
	pea	.msg(pc)
	move.w	#$f000,-(sp)
	move.l	#$b0005,-(sp)
	trap	#14
	add.l	#10,sp

	movem.l	(sp)+,d0-d2/a0-a2
	illegal

.msg:
	dc.b	"Fill done.",0
