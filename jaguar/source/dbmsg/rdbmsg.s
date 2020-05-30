start:
	pea	msg
	move.w	#$f000,-(sp)
	move.l	#$000b0005,-(sp)
	trap	#14
	add.l	#10,sp

; Have to restart it from debugger

	nop
	nop
	nop

	pea	msg2
	move.w	#$f000,-(sp)
	move.l	#$000b0005,-(sp)
	trap	#14
	add.l	#10,sp

; Have to restart it from debugger

	nop
	nop
	nop

	pea	cmd1
	move.w	#$f100,-(sp)
	move.l	#$000b0005,-(sp)
	trap	#14
	add.l	#10,sp

; Don't have to restart it from debugger, 'cos command includes 'g' at end

	nop
	nop
	nop

	pea	msg3
	move.w	#$f000,-(sp)
	move.l	#$000b0005,-(sp)
	trap	#14
	add.l	#10,sp

; Have to restart it from debugger

	nop
	nop
	nop

	illegal

msg:
	.dc.b	"Testing 1,2.3...",0
msg2:
	.dc.b	"Not LOTUS 1,2,3!",0
msg3:
	.dc.b	"All done!",0
cmd1:
	.dc.b	"l .start ; g",0

