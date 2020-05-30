
	.include	'memory.inc'
	.include	'jaguar.inc'
	.include	'player.inc'

	.globl		Clear
Clear:
	move.l	#PITCH1|PIXEL16|WID256|XADDPHR,A1_FLAGS

; Point A1BASE to the data
	move.l	#SCREEN_BASE,A1_BASE
; Set the pixel point to 0,0
	move.l	#0,A1_PIXEL
; No clipping (must set anyway)
	move.l	#0,A1_CLIP

	move.w	#1,d0			
	swap	d0
	move.w	#(-256),d0		
	move.l	d0,A1_STEP

	move.w	#(ROWBYTES*NLINES/512)*3,d0	; *2 for two buffers
	swap	d0
	move.w	#256,d0			
	move.l	d0,B_COUNT

	move.l	#$0,B_PATD	
	move.l	#$0,B_PATD+4

	move.l	#PATDSEL|UPDA1,d0
	move.l	d0,B_CMD
dowa:
	move.l	B_CMD,d0
	andi.w	#1,d0
	beq	dowa

	rts
