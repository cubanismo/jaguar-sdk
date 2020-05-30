;
; Jaguar Example Source Code
; Copyright (c)1994 Atari Corp.
; ALL RIGHTS RESERVED
;
; Program: crypick.cof  - Easy CRY Color Picker
;  Module: cpk_loop.s   - Contains code to poll joystick, update slider,
;                         and redraw color blocks.
;
; Revision History:
; 8/18/94   - SDS: Created
; 8/25/94   - SDS: Used Atari 8x8 font rather than hand-drawn
; 8/26/94   - SDS: Added delay loop to slow down new-improved blitter routines 


		.include        "jaguar.inc"
		.include        "crypick.inc"
	      
		.globl          InitColorBars
		.globl          InitSlider
		.globl          InitVars
		.globl          MainLoop
		.globl          slider_pos
		.globl          crval

		.extern         BlitFill
		.extern         BlitShade
		.extern         TEXT_ADDR
		.extern         YMAP_ADDR

; Atari 8x8 character font
		.extern         _font8x8

; BYTE character offsets into font array
num0            .equ            $30
num1            .equ            $31
num2            .equ            $32
num3            .equ            $33
num4            .equ            $34
num5            .equ            $35
num6            .equ            $36
num7            .equ            $37
num8            .equ            $38
num9            .equ            $39

letA            .equ            $41
letB            .equ            $42
letC            .equ            $43
letD            .equ            $44
letE            .equ            $45
letF            .equ            $46
letG            .equ            $47
letR            .equ            $52
letY            .equ            $59

colon           .equ            $3A
space           .equ            $20
smallx          .equ            $78
percent .equ            $25

; CRY to RGB conversion tables
		.extern         RedTable
		.extern         GreenTable
		.extern         BlueTable
		
		.text

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: InitVars
;            Initialize variables and buffers
;

InitVars:
		movem.l a0-a2,-(sp)

		clr.w   delay           ; Initialize delay counter

		move.w  #127,slider_pos ; Intensity starts at 127
		move.w  #127,last_int

		clr.w   crval           ; Color starts at 0
		clr.w   last_color

		move.w  #$0000,CLUT     ; Initialize palette for
		move.w  #$88FF,CLUT+2   ; B/W objects

; Now draw the initial line of text
		lea     TEXT_ADDR,a0    ; Address of text bitmap
		lea     text_arr,a1     ; Address of offset array
nextchar:
		move.l  (a1)+,a2        ; Get offset until -1 found
		cmp.l   #-1,a2
		beq     nomorechars

		add.l   #_font8x8,a2    ; Add offset to font array

		move.b  (a2),(a0)       ; Copy one 8x8 character data
		move.b  256(a2),32(a0)
		move.b  512(a2),64(a0)
		move.b  768(a2),96(a0)
		move.b  1024(a2),128(a0)
		move.b  1280(a2),160(a0)
		move.b  1536(a2),192(a0)
		move.b  1792(a2),224(a0)

		addq    #1,a0           ; Increment to next character
		bra     nextchar        
nomorechars:
		movem.l (sp)+,a0-a2
		rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: InitColorBars
;             Draw the initial color cube
;

InitColorBars:
		movem.l d0-d7/a0,-(sp)

		movea.l #CRMAP_ADDR,a0  ; Address of Color Cube
		move.w  #0,d2           ; Pixel Offset: X=0 Y=0
		move.w  #0,d3

		move.w  #0,d0           ; For CR portion of color
		move.w  #20,d5          ; Width = 20 pels
		move.w  #WID320,d6      ; Blitter form width code
		move.w  #10,d7          ; Height = 10 pels
loop:
		move.w  d0,d4           ; Create CRY value from color
		lsl.w   #8,d4           ; and current intensity.
		or.w    slider_pos,d4

		jsr     BlitFill        ; Create one block

		add.w   #1,d0           ; Increment CR portion

		add.w   #20,d2          ; Move one column right
		cmp.w   #320,d2         ; Edge of screen?
		blt     sameline        ; Nope, do next.

		clr.w   d2              ; Start back at left edge
		add.w   #10,d3          ; New row
		cmp.w   #160,d3         ; End of cube?
		bge     drawdone        ; Yes, we're done.
sameline:
		bra     loop
drawdone:
		movem.l (sp)+,d0-d7/a0
		rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: InitSlider
;             Initialize YMAP Slider
;

InitSlider:
		movem.l d0-d1/a0,-(sp)

		lea     YMAP_ADDR,a0    ; Address of Intensity Bitmap

		clr.w   d0              ; Initial intensity value
		move.w  #2047,d1        ; 8 bytes * 256 intensities -1 for dbra
.loop:
		move.w  d0,(a0)+        ; Store byte
		add.w   #1,d0           ; Increment intensity
		andi.w  #$FF,d0         ; Force range of 0-255
		dbra    d1,.loop        ; do next

		movem.l (sp)+,d0-d1/a0
		rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: UpdateColorBars
;            Draw the color cube based off of the intensity value
;            in slider_pos.
;

UpdateColorBars:
		movem.l d0-d4/a0,-(sp)

		movea.l #CRMAP_ADDR,a0  ; Address of Color Cube Bitmap

		move.w  slider_pos,d0   ; New intensity
		sub.w   last_int,d0     ; Old Intensity
		beq     endupdt         ; No difference? Skip.

		andi.l  #$FF,d0         ; Make possible WORD negative BYTE.
		move.w  d0,d1           ; copy
		swap    d0              ; put in high bits
		move.w  d1,d0           ; duplicate in low bits
		
		move.w  #320,d2         ; 320 pixel wide cube
		move.w  #WID320,d3      ; Blitter width code
		move.w  #160,d4         ; 160 lines high
		
		jsr     BlitShade       ; Reintensify cube
		
		move.w  slider_pos,last_int     ; Make new value old value

endupdt:
		movem.l (sp)+,d0-d4/a0
		rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: UpdateSlider
;             Setup and call a blit routine to appropriately color slider.
;

UpdateSlider:
		movem.l d0-d4/a0,-(sp)

		lea     YMAP_ADDR,a0    ; Intensity bitmap
		
		move.w  crval,d0        ; New Color Value BYTE
		andi.w  #$F,d0          ; Isolate RED
		move.w  last_color,d1   ; Old Color Value BYTE
		andi.w  #$F,d1          ; Isolate RED
		sub.w   d1,d0           ; Find offset
		andi.w  #$F,d0          ; Make possible WORD negative BYTE
		
		move.w  crval,d2        ; Now do same for CYAN component        
		lsr.w   #4,d2
		move.w  last_color,d3
		lsr.w   #4,d3
		sub.w   d3,d2
		andi.w  #$F,d2
		lsl.w   #4,d2

		or.w    d2,d0           ; Repack color offset
		beq     endslider       ; If zero, no update necessary

		move.w  d0,d1           ; Put value in both WORDs of LONG
		swap    d0
		move.w  d1,d0
		lsl.l   #8,d0           ; Shift to make CR of CRY
		
		move.w  #256,d2         ; 256 pixels wide
		move.w  #WID256,d3      ; Blitter Code
		move.w  #8,d4           ; 8 pixels high
		
		jsr     BlitShade       ; Recolor block
		
		move.w  crval,last_color        ; Make new color, old color
endslider:
		movem.l (sp)+,d0-d4/a0
		rts
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: UpdateText
;            Update the text for CRY hex and RGB percentages
;

UpdateText:
		movem.l a0-a3/d0-d5,-(sp)

		lea     TEXT_ADDR+10,a0 ; Address of last CRY hex digit
		
		move.w  #3,d2           ; 4 x digits in dbra loop

		clr.l   d0              ; Create CRY value from CR and Y
		move.w  crval,d0
		lsl.w   #8,d0
		or.w    slider_pos,d0
.loop:
		lea     hex_arr,a1      ; Address of font offset array

		move.l  d0,d1           ; Copy CRY value
		andi.l  #$F,d1          ; Extract hex digit

		lsl.l   #2,d1           ; Make LONG offset
		add.l   d1,a1           ; Add to hex_arr

		move.l  (a1),a1         ; Grab offset to digit
		add.l   #_font8x8,a1    ; Add to font base

		move.b  (a1),(a0)       ; Copy character information
		move.b  256(a1),32(a0)
		move.b  512(a1),64(a0)
		move.b  768(a1),96(a0)
		move.b  1024(a1),128(a0)
		move.b  1280(a1),160(a0)
		move.b  1536(a1),192(a0)
		move.b  1792(a1),224(a0)

		lsr.l   #4,d0           ; Clear current digit
		sub.l   #1,a0           ; Go to next character left

		dbra    d2,.loop        ; do next digit if any left     
		
;;; Now calculate the RGB percentages and display

		lea     percent_arr,a0  ; Address of component array
		
		move.w  #2,d0           ; Loop counter (3 components)
		move.w  crval,d2        ; current color value
each_rgb:
		move.l  (a0)+,a1        ; Address of lookup table
		move.l  (a0)+,d1        ; Offset into TEXT_ADDR

		lea     TEXT_ADDR,a2    ; Address of text bitmap
		add.l   d1,a2           ; Add offset to last digit of component

		clr.l   d3              ; Clear longword and get color
		move.b  0(a1,d2.w),d3   ; weighting for current CR value

		mulu    slider_pos,d3   ; Scale color from intensity 
		divu    #255,d3
		ext.l   d3
		
		mulu    #100,d3         ; Now scale 0-255 value
		divu    #255,d3         ; to 0-100 value
		ext.l   d3              ; must be long for divide
		
		;;; Now do the INT to ASCII conversion
		move.w  #2,d5           ; For dbra, 3 ASCII digits
do_digit:
		divu    #10,d3          ; Divide by ten
		swap    d3              ; swap result out and remainder in

		clr.l   d4              ; Clear longword and
		move.w  d3,d4           ; copy first digit (remainder of /10)
		lsl.w   #2,d4           ; Mul x4 for longword offset

		clr.w   d3              ; Clear remainder portion and
		swap    d3              ; swap result back in for next digit
		 
		lea     hex_arr,a3      ; Load address of hexdigit array
		add.l   d4,a3           ; add offset to decimal digit
		move.l  (a3),a3         ; Grab offset into font
		add.l   #_font8x8,a3    ; and add font base

		move.b  (a3),(a2)       ; Now copy character into bitmap
		move.b  256(a3),32(a2)
		move.b  512(a3),64(a2)
		move.b  768(a3),96(a2)
		move.b  1024(a3),128(a2)
		move.b  1280(a3),160(a2)
		move.b  1536(a3),192(a2)
		move.b  1792(a3),224(a2)

		sub.l   #1,a2           ; Next digit left in bitmap
		dbra    d5,do_digit     ; do next digit
		dbra    d0,each_rgb     ; do next component

		movem.l (sp)+,a0-a3/d0-d5
		rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: MainLoop
;            Check Joypad/Update Values/Redraw Colors/Update Text
;

MainLoop:
		movem.l d0-d3,-(sp)

		jsr     ReadJoypad      ; Update Joypad values

		move.l  joycur,d0       ; joypad state -> d0.l
		move.w  slider_pos,d1   ; intensity    -> d1.w
		move.w  crval,d2        ; color BYTE   -> d2.w
		move.w  delay,d3        ; delay        -> d3.w

		andi.w  #$FF,d3         ; Do test(s) every 256 iterations
		bne     updexit

		move.w  delay,d3
		btst.l  #8,d3           ; Do only intensity half the time
		bne     test_a

		btst.l  #JOY_LEFT,d0
		beq     test_right

		sub.w   #1,d2           ; Left direction = -1 color
test_right:
		btst.l  #JOY_RIGHT,d0
		beq     test_up

		add.w   #1,d2           ; Right direction = -1 color
test_up:
		btst.l  #JOY_UP,d0
		beq     test_down

		cmp.w   #15,d2          ; If on top row ignore
		ble     test_down

		sub.w   #16,d2          ; otherwise, go one row up
test_down:
		btst.l  #JOY_DOWN,d0
		beq     test_a

		cmp.w   #240,d2         ; If on bottom row, ignore
		bge     test_a

		add.w   #16,d2          ; otherwise, go one row down
test_a:
		btst.l  #FIRE_A,d0
		beq     test_c

		add.w   #1,d1           ; Increment intensity
test_c:
		btst.l  #FIRE_C,d0
		beq     checkslider

		sub.w   #1,d1           ; Decrement intensity
checkslider:
		tst.w   d1
		bge     high_slider     

		clr.w   d1              ; If Y < 0 Y=0
		bra     checkcrval
high_slider:
		cmp.w   #255,d1
		ble     checkcrval

		move.w  #255,d1         ; If Y > 255 Y=255                   
checkcrval:
		tst.w   d2
		bge     highcrval

		clr.w   d2              ; If CR < 0 CR=0
highcrval:
		cmp.w   #255,d2
		ble     nowwrite

		move.w  #255,d2         ; If CR > 255 CR=255
nowwrite:
		move.w  d1,slider_pos   ; Store updated values
		move.w  d2,crval

		; Now start redrawing things...
		jsr     UpdateColorBars
		jsr     UpdateSlider
		jsr     UpdateText
updexit:
		add.w   #1,delay        ; Increment delay counter

		movem.l (sp)+,d0-d3
		rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: ReadJoypad
;            Read Joypad 1 and place values in joycur and joyedge
;

ReadJoypad:
		movem.l d0-d2,-(sp)

		move.l  #$f0fffffc,d1     ; d1 = Joypad data mask
		moveq.l #-1,d2            ; d2 = Cumulative joypad reading
	
		move.w  #$81fe,JOYSTICK   
		move.l  JOYSTICK,d0       ; Read joypad, pause button, A button
		or.l    d1,d0             ; Mask off unused bits
		ror.l   #4,d0             
		and.l   d0,d2             ; d2 = xxAPxxxx RLDUxxxx xxxxxxxx xxxxxxxx
		move.w  #$81fd,JOYSTICK
		move.l  JOYSTICK,d0       ; Read *741 keys, B button
		or.l    d1,d0             ; Mask off unused bits
		ror.l   #8,d0
		and.l   d0,d2             ; d2 = xxAPxxBx RLDU741* xxxxxxxx xxxxxxxx
		move.w  #$81fb,JOYSTICK
		move.l  JOYSTICK,d0       ; Read 2580 keys, C button
		or.l    d1,d0             ; Mask off unused bits
		rol.l   #6,d0
		rol.l   #6,d0
		and.l   d0,d2             ; d2 = xxAPxxBx RLDU741* xxCxxxxx 2580xxxx
		move.w  #$81f7,JOYSTICK
		move.l  JOYSTICK,d0       ; Read 369# keys, Option button
		or.l    d1,d0             ; Mask off unused bits
		rol.l   #8,d0
		and.l   d0,d2             ; d2 = xxAPxxBx RLDU741* xxCxxxOx 2580369# <== inputs active low

		moveq.l #-1,d1
		eor.l   d2,d1             ; d1 = xxAPxxBx RLDU741* xxCxxxOx 2580369# <== now inputs active high

		move.l  joycur,d0         ; old joycur needed for determining the new joyedge
		move.l  d1,joycur         ; Current joypad reading stored into joycur
		eor.l   d1,d0
		and.l   d1,d0
		move.l  d0,joyedge        ; joypad, buttons, keys that were just pressed

		movem.l (sp)+,d0-d2
		rts

;;;;;;;;;;;;;;;;;;;;;;;
;;; Some useful arrays

		.data

;;; Initial state of text
text_arr:
		.dc.l   letC,letR,letY,colon,space,num0
		.dc.l   smallx,num0,num0,num0,num0,space,space
		.dc.l   letR,letG,letB,colon,space
		.dc.l   num0,num0,num0,percent,space
		.dc.l   num0,num0,num0,percent,space
		.dc.l   num0,num0,num0,percent
		.dc.l   -1

; For converting hexadecimal numbers into font offsets
hex_arr:
		.dc.l   num0,num1,num2,num3,num4,num5,num6,num7,num8,num9
		.dc.l   letA,letB,letC,letD,letE,letF

; First value is table address for each color component.
; Second value is byte offset into text object for the last digit of each
; value. 
percent_arr:
		.dc.l   RedTable,20
		.dc.l   GreenTable,25
		.dc.l   BlueTable,30
		

;;;;;;;;;;;;;;;;;;;;;;;
; Uninitialized Data!!!
;;;;;;;;;;;;;;;;;;;;;;;

		.bss
slider_pos:
		.ds.w   1       ; This holds the current intensity byte
last_int:
		.ds.w   1       ; This holds the last intensity (updated)
crval:  
		.ds.w   1       ; This holds the current color byte
last_color:
		.ds.w   1       ; This holds the last color (updated)
joycur:
		.ds.l   1       ; Current state of the joystick
joyedge:
		.ds.l   1       ; Keys newly pressed
delay:
		.ds.w   1       ; Word used as counter for speed delay
				
		.end    
