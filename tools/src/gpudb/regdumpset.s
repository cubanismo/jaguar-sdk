		.text
		.org 500
		.gpu
		.org 500
regdump:
		or	r30,r30
		movei	#$600,r30
		or	r0,r0
		store	r0,(r30)
		or	r14,r14
		move	r14,r0
		move	r30,r14
		store	r0,(r14+14)
		store	r1,(r14+1)
		store	r2,(r14+2)
		store	r3,(r14+3)
		store	r4,(r14+4)
		store	r5,(r14+5)
		store	r6,(r14+6)
		store	r7,(r14+7)
		store	r8,(r14+8)
		store	r9,(r14+9)
		store	r10,(r14+10)
		store	r11,(r14+11)
		store	r12,(r14+12)
		store	r13,(r14+13)
		store	r15,(r14+15)
		store	r16,(r14+16)
		store	r17,(r14+17)
		store	r18,(r14+18)
		store	r19,(r14+19)
		store	r20,(r14+20)
		store	r21,(r14+21)
		store	r22,(r14+22)
		store	r23,(r14+23)
		store	r24,(r14+24)
		store	r25,(r14+25)
		store	r26,(r14+26)
		store	r27,(r14+27)
		store	r28,(r14+28)
		store	r29,(r14+29)
		store	r31,(r14+31)
		load	(r14+14),r14
		or	r14,r14
		load	(r30),r0
		or	r0,r0
		nop
.enddump:	jr	.enddump
		nop

regset:
		movei	#$600,r14
		load	(r14),r0
		load	(r14+1),r1
		load	(r14+2),r2
		load	(r14+3),r3
		load	(r14+4),r4
		load	(r14+5),r5
		load	(r14+6),r6
		load	(r14+7),r7
		load	(r14+8),r8
		load	(r14+9),r9
		load	(r14+10),r10
		load	(r14+11),r11
		load	(r14+12),r12
		load	(r14+13),r13
		load	(r14+15),r15  
		load	(r14+16),r16
		load	(r14+17),r17
		load	(r14+18),r18
		load	(r14+19),r19
		load	(r14+20),r20
		load	(r14+21),r21
		load	(r14+22),r22
		load	(r14+23),r23
		load	(r14+24),r24
		load	(r14+25),r25
		load	(r14+26),r26
		load	(r14+27),r27
		load	(r14+28),r28
		load	(r14+29),r29
		load	(r14+31),r31
		move	r14,r30
		addqt	#32,r30		; Add 4 * 14 to r30
		addqt	#24,r30
		load	(r30),r14
.endset:	jr	t,.endset
		nop

		.end
