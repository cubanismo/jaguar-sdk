; The most important thing in a Mandlebrot program is the inner loop
; The most important thing in a GPU program is to keep as much as possible
; in registers and as much of the rest in internal RAM
; First the inner loop:
; In order to handle both the Mandlebrot and Julia sets we make no assumptions
; about initial conditions.
; The basic loop is: (given xi, yi, cx, cy)
; temp=xi*yi
; sx=xi*xi
; sy=yi*yi
; yi=temp+temp+cy
; xi=sx-sy+cx
; count+=1
; interate until count>maxcount or sx+sy>4

; Note that the nubers used here are 3.13 fixed point
; For a Mandlebrot xi=yi=0 at the start always

; Assume that the following registers are already set up
;       movei   #MAXCNT,maxcnt
;       movei   #FOUR,four

	.gpu

	xi              .equr          R1
	yi              .equr          R2
	cx              .equr          R3
	cy              .equr          R4
	sx              .equr          R5
	sy              .equr          R6
	temp            .equr          R7
	count           .equr          R8
	maxcnt          .equr          R9
	four            .equr          R10
	inloop          .equr          R11
	semaphore       .equr          R12
	inbuf           .equr          R13

mandGPU::
	.org     $f03000

start_mandGPU::
	movei   #loop,inloop

	movei   #(4<<13),four
	movei   #254,maxcnt

	movei   #$0000bff0,semaphore
	movei   #$00f03810,inbuf

	xor     count,count

	load    (inbuf),cx
	addq    #4,inbuf

	load    (inbuf),cy
	addq    #4,inbuf

	load    (inbuf),xi
	addq    #4,inbuf

	load    (inbuf),yi
	addq    #4,inbuf

loop:
	move    xi,temp
	imult   yi,temp         ; temp=xi*yi

	imult   xi,xi           ; xi=xi*xi

	imult   yi,yi           ; yi=yi*yi

	sharq   #13,xi          ; normalize all mult results
	sharq   #13,temp
	sharq   #13,yi

; The folowing code has been interleaved

	add     temp,temp       ; temp=temp+temp

	move    yi,sy           ; sy=yi*yi

	add     cy,temp         ; temp=temp+temp+cy

	move    xi,sx           ; sx=xi*xi

	move    temp,yi         ; yi=temp+temp+cy

	sub     sy,xi           ; xi=sx-sy

	add     cx,xi           ; xi=sx-sy+cx


	addq    #1,count
	cmp     count,maxcnt

	jr      MI,noloop       ; MI is branch count<maxcnt
	nop

	add     sx,sy
	cmp     sy,four

	jr      EQ,noloop
	nop
	jump    CC,(inloop)
	nop

noloop:
	store   count,(semaphore)

;       NOTE: This halts the GPU
	movei   #0,R30
	movei   #$00f02114,R31
	store   R30,(R31)

	nop
	nop
;
	nop
	nop
	nop
	nop
	nop
	nop
end_mandGPU::

