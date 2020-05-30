;
; Jaguar Example Source Code
; Copyright (c)1994 Atari Corp.
; ALL RIGHTS RESERVED
;
; Program: cpkdemo.cof - Cinepak Playback w/Buffering, Scaling, & Rotation
;  Module: grotate.s   - Rotate a bitmap by setting the Blitter with the GPU
;
; Revision History:
;  07/27/94 - SDS: Brought over from Eric S's JAGROT code.
;  08/02/94 - SDS: Module first working that will take any src/dest bitmap.
;  12/08/94 - SDS: Copied/Modified from my Jagrot Workshop Example
;
;----------------------------------------------------------------------------
; Parameters are passed in hi ram, as follows:
;
; ANGLEVAL      Angle of rotation (2048 = 360 degrees).
; SRCADDR       Address of source bitmap.
; SRCWIDTH      Width of source bitmap in pixels.
; SRCHEIGHT     Height of source bitmap in pixels.
; SRCWIDFLD     Width 'field' of src bitmap for BLiTTer flags
; DESTADDR      Address of dest bitmap (must be large enough)
; DESTXCNTR     X coordinate of *center* of destination
; DESTYCNTR     Y coordinate of *center* of destination
; DESTWIDFLD	Width 'field' of destination bitmap
;
; Note: No clipping is performed on the destination image; it is assumed to
; fit on the destination raster area.

		.include        "jaguar.inc"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; GPU Parameters
;;; Setup parameters and trigger a CPU interrupt
;;;
		.extern runframes

		.globl	ANGLEVAL	
		.globl	SRCADDR     	
		.globl	SRCWIDTH	
		.globl	SRCHEIGHT	
		.globl	SRCWIDFLD	
		.globl	DESTADDR	
		.globl	DESTXCNTR	
		.globl	DESTYCNTR	
		.globl	DESTWIDFLD

;;;;;;;;;;;;;;;;;;;;;;;
;;; CPU Interrupt Stub
;;;;;;;;;;;;;;;;;;;;;;;	

GPU_CPUINT	.equ	(G_RAM+$C00)

		.globl	gpu_bmprot
		.globl	gpu_bmprotx
		.globl	GPU_CPUINT
		.globl	GCHANGEOLP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; GPU ROTATION CODE (big letters for ominous effect)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		.68000
		.text
gpu_bmprot:
		.gpu
	
dest_x          .equr   r0      ; X coordinate of center of destination
dest_y          .equr   r1      ; Y coordinate of center of destination
xstep           .equr   r2      ; X increment for blitting
ystep           .equr   r3      ; Y increment for blitting
src_x           .equr   r4      ; X and Y coordinates of upper left hand corner of destination
src_y           .equr   r5
dest_w          .equr   r6      ; width of destination rectangle
dest_h          .equr   r7      ; height of destination rectangle
	
pi2             .equr   r10     ; pi/2 (a constant)
sintbl          .equr   r11     ; pointer to trig table
asin            .equr   r12     ; sin in 0.14 format
acos            .equr   r13     ; cos in 0.14 format
half            .equr   r14     ; 1/2 in 16.16 fixed point
index           .equr   r15     ; for index into sine table
mod             .equr   r16     ; to hold remainder of /16
mod16           .equr   r17     ; mask value for above
mask            .equr   r18     ; For AND #$1FC
masklow         .equr   r19     ; $FFFF masks off low WORD

xtemp           .equr   r20     ; various temporary registers
ytemp           .equr   r21
temp            .equr   r22
temp2           .equr   r23

flags           .equr   r24     ; used to build blitter flags

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		.org    GPU_CPUINT

		movei	#G_FLAGS,r30
		load	(r30),r29

;;; SPECIAL!!! - If GCHANGEOLP is non-zero, change OLP and exit.

		movei	#GCHANGEOLP,temp	; Test Value
		load	(temp),temp2
		cmpq	#0,temp2

		jr	EQ,dorot		; Do rotation
		nop

		movei	#OLP,temp		; Store value in OLP
		store	temp2,(temp)

		bclr	#3,r29
		bset	#9,r29
		load	(r31),r28
		addq	#2,r28
		addq	#4,r31
		jump	(r28)			; End CPU Interrupt
		store	r29,(r30)
dorot:
		moveq   #1,pi2
		shlq    #9,pi2          ; pi/2 = 512 in our measurement system

		movei   #$8000,half     ; 1/2 in 16.16 format
		moveq   #$F,mod16       ; for obtaining % 16
		movei   #$1FC,mask      ; to mask valid sine table indexes
		movei   #$FFFF,masklow

		movei   #ANGLEVAL,temp
		movei   #ROM_SINE,sintbl        ; ROM SINE Table in Jerry

		load    (temp),index    ; get angle of rotation
		move    index,mod

		shrq    #4,index        ; Make 0-2048 -> 0-128
		shlq    #2,index        ; Make 0-128.b 0-128.l

; The SINE table in Jerry is laid out a little funny. There are 128 32-bit
; entries but only the low 16 bits are signifigant and are simply sign-extended.
;
; The first entry is the first entry _above_ zero and the last entry is for
; zero. Our example rewinds one entry to compensate for this. Every time the
; index is modified it is mask'ed off to cause the pointer to wrap within
; the table.
;
; Since 128 entries isn't enough to do rotation with more than 2 or 3 degree
; accuracy we interpolate values through averaging to come closer.
;
		subq    #4,index        ; To account for sine table layout.
		and     mask,index

		and     mod16,mod       ; Get angle % 16
		
		load    (index+sintbl),asin

		addq    #4,index        ; Get next entry for interpolation
		and     mask,index

		load    (index+sintbl),temp2
		sub     asin,temp2
		sharq   #4,temp2        ; 1/16 of difference of both entries

		imult   mod,temp2       ; remainder * 1/16 = offset
		add     temp2,asin      ; offset + value1 = interpolated value
		sharq   #1,asin         ; make it a 0.14 value

;;; Now do cosine (cos x = sin x+90)    

		movei   #124,temp       ; (sintbl length)/4 - 4 
		add     temp,index
		and     mask,index      ; New index

		load    (index+sintbl),acos

		addq    #4,index
		and     mask,index

		load    (index+sintbl),temp2
		sub     acos,temp2
		sharq   #4,temp2

		imult   mod,temp2
		add     temp2,acos
		sharq   #1,acos

		movei   #DESTXCNTR,temp ; Center of destination rectangle
		load    (temp),dest_x
		movei   #DESTYCNTR,temp 
		load    (temp),dest_y

		movei   #SRCWIDTH,temp  ; Rectangle extents
		load    (temp),dest_w
		movei   #SRCHEIGHT,temp
		load    (temp),dest_h

; New Height = h*abs(cos) + w*abs(sin)

		move    acos,xtemp
		move    asin,ytemp
		abs     xtemp
		abs     ytemp

		imultn  dest_h,xtemp
		imacn   dest_w,ytemp
		resmac  temp2

; New Width - w*abs(cos) + h*abs(sin)

		imultn  dest_h,ytemp
		imacn   dest_w,xtemp
		resmac  temp

		move    temp2,dest_h
		move    temp,dest_w

		move    half,temp       ; Round off the width and height
		shrq    #2,temp         ; Convert down to 0.14 format
		add     temp,dest_h
		add     temp,dest_w
		sharq   #14,dest_h      ; Convert to integers
		sharq   #14,dest_w

		move    dest_w,xtemp
		move    dest_h,ytemp
		sharq   #1,xtemp
		sharq   #1,ytemp
		sub     xtemp,dest_x    ; upper left corner of the dest. rectangle
		sub     ytemp,dest_y

; Now transform the destination bounding rectangle back to the
; source bitmap. The inverse transformation is:
;       x' = x*cos + y*sin
;       y' = -x*sin + y*cos

		imultn  xtemp,acos
		imacn   ytemp,asin
		resmac  src_x
		shlq    #2,src_x

		neg     xtemp
		imultn  xtemp,asin
		imacn   ytemp,acos
		resmac  src_y
		shlq    #2,src_y
	
		neg     src_x
		neg     src_y

		movei   #SRCWIDTH,temp  ; Width of source bitmap
		load    (temp),xtemp
		shrq    #1,xtemp        ; Divide by 2
		shlq    #16,xtemp       ; Make 16.16 format

		movei   #SRCHEIGHT,temp
		load    (temp),ytemp
		shrq    #1,ytemp        ; Divide by 2
		shlq    #16,ytemp       ; Make 16.16 format

		add     xtemp,src_x     ; Translate to upper left of destination
		add     ytemp,src_y

; wait for the blitter to become free
		movei   #B_CMD,temp2
wloop:
		load    (temp2),temp
		btst    #0,temp
		jr      EQ,wloop
		nop

; now set up the blitter registers
; window A1 is the source
; window A2 is the destination

		movei   #SRCADDR,temp   
		load    (temp),temp
		movei   #A1_BASE,temp2
		store   temp,(temp2)
		
		movei   #PITCH3|XADDINC|PIXEL16,flags

		movei   #SRCWIDFLD,temp         ; WID64, WID192, etc...
		load    (temp),temp
		or      temp,flags

		movei   #A1_FLAGS,temp
		store   flags,(temp)

		move    src_y,temp              ; Integer part of starting pixel
		shrq    #16,temp
		shlq    #16,temp
		move    src_x,temp2
		shrq    #16,temp2
		or      temp2,temp
		movei   #A1_PIXEL,temp2
		store   temp,(temp2)

		move    src_y,temp              ; Fractional part of pixel
		shlq    #16,temp
		move    src_x,temp2
		and     masklow,temp2
		or      temp2,temp
		movei   #A1_FPIXEL,temp2
		store   temp,(temp2)

		move    asin,temp               ; Increment: 
		neg     temp                    ; X increment is cos, Y is -sin
		shrq    #14,temp                ; 0.14 to 16 bit integer
		and     masklow,temp
		shlq    #16,temp
		move    acos,temp2
		shrq    #14,temp2
		and     masklow,temp2
		or      temp2,temp
		movei   #A1_INC,temp2
		store   temp,(temp2)

		move    asin,temp               ; Fractional Increment
		neg     temp
		shlq    #18,temp
		move    acos,temp2
		shlq    #2,temp2                ; 0.14 to 0.16 fixed point
		and     masklow,temp2
		or      temp2,temp
		movei   #A1_FINC,temp2
		store   temp,(temp2)

;
; To step between lines, we must step back by "width" times the x and y increments, and
; then forward by sin (in the x direction) and cos (in the y direction).
;
		move    dest_w,xstep
		move    dest_w,ystep
		neg     xstep
		imult   acos,xstep              ;(1) Note: changing the order to 2,1,4,3,5,6 
		imult   asin,ystep              ;(2)       would avoid all together 2 
		add     asin,xstep              ;(3)       wait cycles here
		add     acos,ystep              ;(4)
		shlq    #2,xstep                ;(5) cos and sin are /4, remember?
		shlq    #2,ystep                ;(6)

		move    ystep,temp
		shrq    #16,temp                
		shlq    #16,temp                ;(1) Note: If 1 and 2 would be swapped
		move    xstep,temp2             ;(2)       this avoids 1 wait cycle
		shrq    #16,temp2
		or      temp2,temp
		movei   #A1_STEP,temp2
		store   temp,(temp2)

		move    ystep,temp
		shlq    #16,temp
		move    xstep,temp2
		shlq    #16,temp2
		shrq    #16,temp2
		or      temp2,temp
		movei   #A1_FSTEP,temp2
		store   temp,(temp2)

		movei   #SRCHEIGHT,temp
		load    (temp),temp
		shlq    #16,temp

		movei   #SRCWIDTH,temp2
		load    (temp2),temp2
		or      temp2,temp
		
		movei   #A1_CLIP,temp2          ; Clip Window is source window extent
		store   temp,(temp2)

; Set up destination pointers

		movei   #DESTADDR,temp          ; Address of destination bitmap
		load    (temp),temp
		movei   #A2_BASE,temp2
		store   temp,(temp2)

		movei   #PITCH3|XADDPIX|PIXEL16,flags   ; Contiguous Data/Pixel Mode

		movei   #DESTWIDFLD,temp        ; OR with Blitter width code
		load    (temp),temp
		or      temp,flags

		movei   #A2_FLAGS,temp          
		store   flags,(temp)

		moveq   #1,temp                 ; Step is X = 1, Y = -Width
		shlq    #16,temp
		move    dest_w,temp2
		neg     temp2
		shlq    #16,temp2
		shrq    #16,temp2
		or      temp2,temp
		movei   #A2_STEP,temp2
		store   temp,(temp2)

		move    dest_y,temp             ; Pixel offset into destination buffer
		shlq    #16,temp
		or      dest_x,temp
		movei   #A2_PIXEL,temp2
		store   temp,(temp2)

		move    dest_h,temp             ; Setup Inner/Outer Loop Counts
		shlq    #16,temp
		or      dest_w,temp
		movei   #B_COUNT,temp2
		store   temp,(temp2)

;;;;; Engage...

		movei   #CLIP_A1|SRCEN|UPDA1F|UPDA1|UPDA2|DSTA2|LFU_REPLACE,temp
		movei   #B_CMD,temp2
		store   temp,(temp2)

		moveq	#0,temp		       	; Signal CPU we've started Blit
		movei	#SRCADDR,temp2		
		store	temp,(temp2)

		bclr	#3,r29
		bset	#9,r29
		load	(r31),r28
		addq	#2,r28
		addq	#4,r31
		jump	(r28)			; End CPU Interrupt
		store	r29,(r30)

		.long

ANGLEVAL:	.dc.l	0
SRCADDR:     	.dc.l	0
SRCWIDTH:	.dc.l	0
SRCHEIGHT:	.dc.l	0
SRCWIDFLD:	.dc.l	0
DESTADDR:	.dc.l	0
DESTXCNTR:	.dc.l	0
DESTYCNTR:	.dc.l	0
DESTWIDFLD:	.dc.l	0

		.68000
gpu_bmprotx:
		.end
