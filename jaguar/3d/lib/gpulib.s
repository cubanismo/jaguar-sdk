;
; GPU library interface
; routines:
;
; void GPUload(long *gpuprog):
;	loads up the GPU program pointed to by "gpuprog"
;	the first 2 longs are assumed to be the start and end
;	addresses, respectively
;
; void GPUrun(long *gpuaddr):
;	execute a GPU program, starting at the given address
;	in GPU ram, and wait for it to complete
;
	.include	'jaguar.inc'

	.extern	_GPUdone		; in video.s


_GPUload::
	move.l	4(sp),a0		; get pointer to program
	move.l	(a0)+,a1		; get pointer to start
	move.l	(a0)+,d0		; get pointer to length
;
; assembly language interface to load the GPU
; input: a0 points to source
;	 a1 points to destination in GPU land
;	 d0 is the length of the program

gpuload::
	move.l	#$8000,d1
	adda.l	d1,a1				; blit to 32 bit memory in GPU ram

	move.l	a0,d1
	and.l	#7,d1				; is source phrase aligned?
	bne.b	.slowway			; nope == do it the slow way
	move.l	a1,d1				; is destination phrase aligned?
	and.l	#7,d1				; nope == do it the slow way
	bne.b	.slowway
	move.l	a0,A2_BASE			; set source
	move.l	#PIXEL8|WID8|XADDPHR,A2_FLAGS
	move.l	#0,A2_PIXEL
	move.l	a1,A1_BASE			; set destination
	move.l	#PIXEL8|WID8|XADDPHR,A1_FLAGS
	move.l	#0,A1_PIXEL
	move.l	#0,A1_FPIXEL
	or.l	#$00010000,d0			; set outer loop counter = 1
	move.l	d0,B_COUNT
	lea	B_CMD,a0
	move.l	#SRCEN|LFU_S,(a0)		; start up the blitter
.bwait:
	move.l	(a0),d0				; wait for the blit
	btst	#0,d0
	beq.b	.bwait

	rts
.slowway:
	asr.l	#2,d0				;convert bytes to longs
	subq.l	#1,d0				;subtract 1 for loop counter
.20:	move.l	(a0)+,(a1)+
	dbra		d0,.20
	rts

_GPUrun::
	move.l	4(sp),a0
gpurun::
	move.l	a0,G_PC
	clr.w	_GPUdone
	move.l	#$11,G_CTRL		; turn on the GPU
.10:
	stop	#$2000			; wait for a GPU interrupt
	tst.w	_GPUdone		; to signal the GPU is done
	beq.b	.10
.ret:
	rts

