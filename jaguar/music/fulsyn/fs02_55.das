;*============================================================================*
;*      TITLE:    FULSYN.DAS                                                  *
;*                                                                            *
;*      COPYRIGHT 1992,1993,1994,1995 Atari U.S. Corporation                  *
;*                                                                            *
;*      UNATHORIZED REPRODUCTION, ADAPTATION, DISTRIBUTION,                   *
;*      PERFORMANCE OR DISPLAY OF THIS COMPUTER PROGRAM OR                    *
;*      THE ASSOCIATED AUDIOVISUAL WORK IS STRICTLY PROHIBITED.               *
;*      ALL RIGHTS RESERVED.                                                  *
;*============================================================================*
;               Rev 2.55 for Jerry
;               Date: 1/17/1995
;______________________________________________________________________________
		include "jaguar.inc"
		include "fulsyn.inc"
		include "synth.cnf"
;______________________________________________________________________________
;       68K Header for loading the code from DRAM into DSP RAM
;______________________________________________________________________________

	.68000
SYN_COPY::
	dc.l    FULSYN_S                ; Load address
	dc.l    (FULSYN_E - FULSYN_S)   ; Code Length
;______________________________________________________________________________
	.DSP

	.globl  buffstart               ; small buffer for sample
	.globl	INTEREST                ; fct which fills up bufffer
	.globl  SEMAPHORE               ; used to signal next sample tick
	.globl  TIMER_ADD               ; current time
	.globl  SCORE_ADD               ; pointer to score
	.globl  PATCHLOC                ; pointer to patches
	.globl  SYNTHEND                ; end of synth
	.globl  TMR1_ISR                ; (interrupt 2 - Timer 1)
	.globl  NOTE_OFF
	.globl  SHUTDOWN
	.globl  TIMELEFT
	.globl  VOLUME                  ; MIDI VOLUME
	.globl  UEBERVOLUME             ; Global Volume
	.globl  VOL_ENV_TABLE           ; tables to envelopes

	.ORG    D_RAM                   ; start of DSP RAM
FULSYN_S::
DSPORG::
	movei   #start,r0               ; (interrupt 0  - DSP Control)
	jump    (r0)
	nop
	nop
	nop
	nop

;______________________________________________________________________________
	movei   #i2s_isr,r29                    ; (interrupt 1 - I2S)
	jump    (r29)
	nop
	nop
TIMELEFT:
	nop
	nop

;______________________________________________________________________________
	movei   #tmr1_isr,r29                   ; (interrupt 2 - Timer 1)
	jump    (r29)
	nop
	nop
	nop
	nop
VOLUME:                                         ; this is the MIDI VOLUME
	nop                                     ; used in note_on events
	nop

start:
	movei   #STACKPOS,r31           ; Set up a stack
	moveta  r31,r31                 ; in both banks

	movei   #D_FLAGS,r1             ; load dsp flags to go to bank 1
	moveta  r1,r1                   ; in both banks
	load    (r1),r0
	bset    #14,r0                  ; Use bank 1
	bset    #5,r0                   ; enable I2S interrupt
	bset    #6,r0                   ; enable Timer 1 interrupt
	store   r0,(r1)                 ; save dsp flags
	nop                             ; NEEDS TWO NOPS TO PROTECT AGAINST 
	nop                             ; EXTERNAL LOADINGS

; The following registers in bank 0 are in use
;       0       .       .       24
;       1       9       .17     .25
;       2       10      18      .26
;       3       11      19      .27
;       4.      .12     20      28      in interrupt
;       5.      13      21      29      "	"
;       6.      14      .22     30      "	"
;       7.      15      .23     31      "	"

	movei   #tablestart,r0
	moveta  r0,r0

	movei   #nexttab,r0
	moveta  r0,r1

	movei   #MODULETABLE,r0
	moveta  r0,r2

	movei   #taboff-4,r0
	moveta  r0,r3

	movei   #$f1a148,r0     ; right DAC
	moveta  r0,r9

	movei   #loop,r0        ;ptr to do absolute jump
	moveta  r0,r10

	movei   #$ff,r0         ;=1 ish under 24.8 representation
	moveta  r0,r11
.if WAVETAB_MOD
	movei   #no2fade,r0
	moveta  r0,r13
.endif
	movei   #$7fff,r0       ; panval
	moveta  r0,r14

	movei   #-4,r0          ;kill voice
	moveta  r0,r15

	movei   #TIMER_ADD,r0   ; Initialize the timer position
	moveta  r0,r16

	moveq   #0,r1           ; clear output counter
	store   r1,(r0)         ; Initialize the timer value
	moveta  r1,r21

	movei   #SCORE_ADD,r0   ; Initialize the score pointer
	moveta  r0,r17

	movei   #ROM_SINE,r0    ;Sinewave position
	moveta  r0,r18

	movei   #$007fffff,r0   ;sinetable buffer length<<16
	moveta  r0,r19

	movei   #D_FLAGS,r0     ; get flags ptr
	moveta  r0,r20

; R21 handled above (see initialize timer value)

	movei   #D_RAM+28,r0
	moveta  r0,r24           ; uses register freed up above
	
; The following registers in bank 1 are in use
;       0       8       16      24
;       1       9       17      25
;       2       10      18      26
;       3       11      19      27
;       4       12      20      .!28
;       5       13      21      .
;       6       14      22      .
;       7       15      23      .

	moveq   #0,r28          ; Set up input buffer counter
	
; Set up the modulo adders to handle tables that are 128 longs in length

	movei   #$f1a118,r25    ;MODPARM
	movei   #$FFFFFE00,r0
	store   r0,(r25)

;______________________________________________________________________________
loop:
;______________________________________________________________________________
	movefa  r0,r15          ;position of first table (#tablestart)
	moveq   #0,r9           ;right channel
	moveq   #0,r26          ;left channel
	movefa  r1,r27          ;get #nexttab
innerloop:
	load    (r15),r16       ;table type

	movefa  r2,r14          ;module table
	load    (r14+r16),r25   ;load module address
	jump    (r25)           ;jumps to module (or nexttab or endlist)
	addq    #4,r15          ;step up table, so pointers are correct.

;______________________________________________
nexttab:
	movefa  r3,r1           ;offset to next table
	jr      innerloop
	add     r1,r15          ;next table:
;______________________________________________
endlist:
	sharq   #15,r9          ;shift o/p back into range
	sharq   #15,r26         ;and right o/p

	movei   #UEBERVOLUME,r2 ; do GLOABL VOLUME 
	load    (r2),r2
	imult   r2,r9
	imult   r2,r26
	sharq   #15,r9
	sharq   #15,r26

; This block will fill a short buffer of sample
; to be extracted from by the interrupt routine

; First lets store the data just computed
interest:
	movei   #buffstart,r1
	move    r28,r2
	shlq    #3,r2
	add     r2,r1
	store   r26,(r1)
	addq    #4,r1
	store   r9,(r1)
; Now we increment the IC (Input counter)
; and compare to the OC (Output Counter)
	addq    #1,r28
	bclr    #3,r28
	moveq   #0,r0
	subq    #1,r0

	movefa  r21,r2
delay:
	cmp     r28,r2
	movefa  r21,r2
	jr      EQ, delay
	addqt   #1,r0

	movefa  r24,r2          ; Counter storage point
	store   r0,(r2)

	movefa  r10,r27         ;ptr to do absolute jump
	jump    (r27)           ;return to beginning of main loop
	nop

;______________________________________________________________________________
;____________________________ end of main program _____________________________

;______________________________________________________________________________
;________________________ start of wavetable module 2__________________________


.if WAVETAB_MOD
wave2mod:
	load    (r15+9),r14     ;next instruction (and stop marker)
; BREAK UP LOADS
	load    (r15+7),r8      ;-n -> length of fade 2^n-1 (ticks)
	btst    #31,r14
	moveq   #1,r20
	jr      nz, shutoff     ; have we hit a stop point?

	sh      r8,r20          ;gives 2^-n
	load    (r15+1),r1      ;release flag : frequency (23.8)
	subq    #1,r20          ;2^n-1 gives fade length
	load    (r15+10),r0     ;amplitude (ls16bits) (internal)
	btst    #31,r1          ;release note?
	load    (r15+3),r5      ;number of ticks left on this table
	jr      EQ,not2rel      ;no, so skip this bit
	bclr    #31,r1          ;(always) clear flag so add is correct

	load    (r15+4),r14     ;load release instruction
	move    r20,r5          ;force a fade
	store   r14,(r15+9)     ;and substitute in.
	store   r1,(r15+1)      ;store cleared flag
	jr      not2rel
	nop
shutoff:
	subq    #4,r15
	movefa  r15,r0          ; kill voice
	store   r0,(r15)
	jump    (r27)
	addq    #4,r15
;_____________________________________________
not2rel:
	load    (r15+8),r16     ;amplitude delta figure
	subq    #1,r5           ;decrement reps value
	load    (r15+2),r2      ;current position
	load    (r15+6),r4      ;length of buffer (24:8)-1 stays same ;; moved before jr
	jr      PL,notnext2inst ;exhausted number of reps?
	nop

start2new:
	load    (r14+2),r5      ;reps is a new value now (saved later)
; BREAK UP LOADS
	load    (r14+3),r16     ;amplitude factor
; BREAK UP LOADS
	load    (r14+5),r12     ;next instruction ptr
; BREAK UP LOADS
	load    (r14+4),r11     ;length of fade
; BREAK UP LOADS
	load    (r14),r3        ;load new parameters, and save in current
	store   r16,(r15+8)     ;amplitude
	cmpq    #0,r3           ;fade to new table?
	store   r12,(r15+9)     ;instruction ptr
	store   r11,(r15+7)     ;length of fade ;; moved before jr
	jr      EQ,notnext2inst ;skip new instrustion fade is specified
	nop

	store   r3,(r15+5)      ;wavetable pos

;_____________________________________________
notnext2inst:

	store   r5,(r15+3)      ;save reps value
	add     r1,r2           ;current+const->current
	load    (r15+5),r3      ;start of current buffer
	and     r4,r2           ;wrap round
	imult   r16,r0          ;Change amplitude
	sharq   #14,r0
	btst    #15,r0
	store   r2,(r15+2)      ;save position          ; moved before jr
	jr      EQ,notnegamp
	nop
	movefa  r14,r0
notnegamp:
	move    r2,r7           ;fractional part
	store   r0,(r15+10)
; Is this what makes the wavetable so quiet?
;       sharq   1,r0            ;shift down for multiply
	movefa  r11,r6
	shrq    #8,r2           ;take out fraction
	and     r6,r7           ;take out high length
	shlq    #2,r2           ;hilength

	add     r2,r3           ;add to start position
	sub     r7,r6           ;r7= frac, r6=1-frac

	load    (r3),r13        ;first actual value
	addqmod #4,r3           ;prepare to get second value
	imult   r6,r13          ;(1-frac)*firstval
	load    (r3),r16        ;second actual value
	imult   r7,r16          ;frac*secondval
	add     r16,r13         ;add for interpolation
	sharq   #8,r13          ;shift down to realign d.p.

;___________next table fader
	cmp     r20,r5
	movefa  r13,r25
	load    (r14),r12       ;position of buffer start ;; moved before jump
	jump    PL,(r25)        ;if above is true, then this will still work
	nop

	cmpq    #0,r12
	jr      nz,notjustamp
	add     r2,r12

	moveq   #0,r5           ;we should be just fading amplitude,
	store   r5,(r15+3)      ;table load, and ignore fade. ;; moved before jump
	jump    (r25)           ;so reset reps counter,to force next
	nop
				;These three instructions only happen once
				;in any one fade, and so should not affect
				;performance

notjustamp:
	load    (r12),r11       ;first actual value
	addqmod #4,r12          ;prepare to get second value
	imult   r6,r11          ;(1-frac)*firstval
	load    (r12),r16       ;second actual value
	neg     r8
	imult   r7,r16          ;frac*secondval
	sub     r5,r20          ;fadelength-counts left
	add     r16,r11         ;add for interpolation
	sharq   #8,r11          ;shift down to realign d.p.

	imult   r5,r13          ;this table*counts left
	imult   r20,r11         ;next table*(fadelength-counts left)
	add     r11,r13         ;add together
	sh      r8,r13          ;shift down to realign d.p.
no2fade:
	imult   r0,r13          ;multiply by the internal amplitude
	load    (r15),r1        ;external amplitude
	sharq   #15,r13         ;shift down value for DAC

	load    (r15+18),r19    ;left pan value
	imult   r1,r13          ;multiply by external amplitude
	movefa  r14,r20
	sharq   #15,r13         ;shift down value for DAC
	sub     r19,r20         ;right panvalue
	imult   r13,r19         ;right o/p
	imult   r13,r20         ;left o/p
	add     r19,r9
	jump    (r27)
	add     r20,r26

.endif
;______________________________________________________________________________
;__________________________ end of wave table module __________________________

;______________________________________________________________________________

;_____________________________ start of fm module _____________________________
;______________________________________________________________________________

.if FMSIMPLE_MOD
fmmod:
	load    (r15+2),r2      ;current pointer position (16.16)
				; BREAK UP LOADS
	load    (r15+3),r3      ;const step omega (16.16)
				; BREAK UP LOADS
	load    (r15+6),r6      ;fm pointer position (16.16)
	add     r3,r2           ;current+const->current
	load    (r15+7),r7      ;fm const step (16.16)
				; BREAK UP LOADS
	load    (r15+4),r4      ;variable offset beta (16.16)
	add     r7,r6           ;fm current+const->current
	movefa  r19,r1
	add     r4,r2           ;current+variable->current
	load    (r15),r14       ;start address
	and     r1,r2           ;wrap round
	load    (r15+5),r5      ;amplitude alpha
	and     r1,r6           ;fm wrap round
	load    (r15+8),r8      ;fm index (0:7.8)

	store   r2,(r15+2)      ;save position

	movefa  r11,r10         ;1 in 23.8 format
	move    r2,r12          ;position (used for interpolation)

	shrq    #16,r2          ;hilength
	shrq    #8,r12
	store   r6,(r15+6)      ;fm save position
	and     r10,r12         ;leave fractional part only
	shrq    #16,r6          ;fm hilength
	sub     r12,r10         ;1-frac;
	shlq    #2,r2           ;hilength
	shlq    #2,r6           ;fm hilength

	load    (r15+1),r21     ;position of modulation wave
	shrq    #14,r1
	load    (r14+r2),r3     ;actual value 1
	addq    #4,r2           ;point at next sample
	add     r6,r21
	and     r1,r2
	load    (r21),r4        ;fm value for next sample
; BREAK UP LOADS
	load    (r14+r2),r11    ;actual value 2

	imultn  r3,r10          ;val1*(1-frac)
	imacn   r11,r12         ;val2*(frac)
	resmac  r13             ;result

	sharq   #8,r13          ;shift back into range
	load    (r15+18),r19    ;left pan value
	imult   r5,r13          ;multiply by amplitude
	imult   r8,r4           ;this is next fm setting
	movefa  r14,r20
	sharq   #7,r4           ;shift into range
	sharq   #15,r13         ;shift down value for next stage
	store   r4,(r15+4)

	sub     r19,r20         ;right panvalue
	imult   r13,r19         ;right o/p
	imult   r13,r20         ;left o/p
	add     r19,r9
	jump    (r27)
	add     r20,r26
.endif
;______________________________________________________________________________
;____________________________ end of fm module ________________________________
;______________________________________________________________________________
;_________________________ start of compressed sampler module _________________
;______________________________________________________________________________

.if CSMPL16_MOD
csampmod:
	load    (r15+2),r2      ;const step omega (24.8)
	movefa  r11,r24         ;=1 ish in 24.8
	load    (r15+5),r5      ;current position (24.8)
; BREAK UP LOADS
	load    (r15+3),r3      ;loop end(24.8)
	add     r2,r5           ;current+const->current
	load    (r15),r0        ;amplitude+flags
	cmp     r5,r3           ;is pointer above end?
	load    (r15+4),r4      ;loop length (24:8)

	jr      PL,nokillc      ;no, so don't process
	btst    #31,r0          ;is this a stop loopend?

	jr      nz,nokillc      ;no, loop exists
	sub     r4,r5           ;wrap round

	subq    #4,r15          ;This is a stopend
	movefa  r15,r0          ;kill voice
	store   r0,(r15)        ;
	jump    (r27)
	addq    #4,r15

nokillc:
	move    r5,r4           ;fractional part
	store   r5,(r15+5)      ;save position (always done)
	shrq    #8,r5           ;take out fraction
	and     r24,r4          ;take out high length
	movefa  r14,r20
	load    (r15+1),r1      ;start of sample
	move    r24,r6          ;=1 under 24.8 representation

	add     r1,r5           ;add to start position
	sub     r4,r6           ;r4= frac, r6=1-frac

	loadb   (r5),r13        ;first actual value
	addq    #1,r5           ;prepare to get second value
	loadb   (r5),r7         ;second actual value
	move    r13,r1
	bclr    #7,r13
	btst    #7,r1
	jr      EQ,j1
	mult    r13,r13         ; square to decompress!!!!!!!!!
	neg     r13
j1:     
	move    r7,r2
	bclr    #7,r7
	btst    #7,r2
	jr      EQ,j2
	mult    r7,r7           ; square to decompress!!!!!!!!!
	neg     r7
j2:     

	imult   r6,r13          ;(1-frac)*firstval
	imult   r4,r7           ;frac*secondval
	add     r7,r13          ;add for interpolation
	load    (r15+18),r19    ;left pan value
; Sharq by seven so we don't need to multiply by two above
	sharq   #7,r13          ;shift down to realign d.p.

	imult   r0,r13           ;multiply by the amplitude (ls 15 bits of flag)
	sharq   #15,r13

	sub     r19,r20         ;right panvalue
	imult   r13,r19         ;right o/p
	imult   r13,r20         ;left o/p
	add     r19,r9
	jump    (r27)
	add     r20,r26
.endif
;______________________________________________________________________________
;_________________________ end of compressed sampler module ______________________________

;_________________________ start of fast compressed sampler module ____________
;______________________________________________________________________________

.if FCSMP_MOD
fcsmpmod:
	load    (r15+2),r2      ;const step omega (24.8)
	load    (r15+5),r5      ;current position (24.8)
; BREAK UP LOADS
	load    (r15+7),r3      ;loop end(24.8)
	add     r2,r5           ;current+const->current

	cmp     r5,r3           ;is pointer above end?

	jr      PL,fine         ;no, so don't process
	load    (r15),r0        ;amplitude+flags

	subq    #4,r15          ;This is a stopend
	movefa  r15,r0          ;kill voice
	store   r0,(r15)        ;
	jump    (r27)
	addq    #4,r15

fine:
	store   r5,(r15+5)      ;save position (always done)
	shrq    #8,r5           ;take out fraction
	load    (r15+1),r1      ;start of sample
	movefa  r14,r20

	add     r1,r5           ;add to start position

	loadb   (r5),r13        ;first actual value
;       or      r13,r13
	move    r13,r1
	bclr    #7,r13
	btst    #7,r1
	jr      EQ,fc1
	mult    r13,r13         ; square to decompress!!!!!!!!!
	neg     r13
fc1:
	load    (r15+18),r19    ;left pan value
; Sharq by seven so we don't need to multiply by two above
	imult   r0,r13           ;multiply by the amplitude (ls 15 bits of flag)
	sub     r19,r20         ;right panvalue
	sharq   #15,r13

	imult   r13,r19         ;right o/p
	imult   r13,r20         ;left o/p
	add     r19,r9
	jump    (r27)
	add     r20,r26
.endif
;______________________________________________________________________________
;_________________________ end of compressed fast sampler module ______________________________


;______________________________________________________________________________

;_____________________________ start of fmenv module _____________________________
;______________________________________________________________________________

.if FMENV_MOD
fmenv:
	move    r15,r17
	addq    #2*4,r17
	load    (r17),r2        ;current pointer position (16.16)
	addq    #4,r17
	load    (r17),r3        ;const step omega (16.16)
	addq    #3*4,r17
	load    (r17),r6        ;fm pointer position (16.16)
	addq    #4*4,r17
	load    (r17),r23       ;env rate
	addq    #3*4,r17
	load    (r17),r22       ;current envelope position

	add     r3,r2           ;current+const->current
	load    (r15+7),r7      ;fm const step (16.16)
	add     r23,r22         ;new current position
	load    (r15+4),r4      ;variable offset beta (16.16)
	add     r7,r6           ;fm current+const->current
	movefa  r19,r1
	add     r4,r2           ;current+variable->current
	load    (r15),r14       ;start address
	and     r1,r2           ;wrap round
	load    (r15+5),r5      ;amplitude alpha
	and     r1,r6           ;fm wrap round
	load    (r15+8),r8      ;fm index (0:7.8)

	store   r2,(r15+2)      ;save position

	movefa  r11,r10         ;1 in 23.8 format
	move    r2,r12          ;position (used for interpolation)

	shrq    #16,r2          ;hilength
	shrq    #8,r12
	store   r6,(r15+6)      ;fm save position
	and     r10,r12         ;leave fractional part only
	shrq    #16,r6          ;fm hilength
	sub     r12,r10         ;1-frac;
	shlq    #2,r6           ;fm hilength
	shlq    #2,r2           ;hilength

	load    (r15+1),r21     ;position of modulation wave
	shrq    #14,r1
	load    (r14+r2),r3     ;actual value 1
	addq    #4,r2           ;point at next sample
	add     r6,r21
	and     r1,r2
	load    (r14+r2),r11    ;actual value 2

; Now we interpolate the envelope

	movefa  r11,r20         ;1 in 23.8 format
	load    (r15+11),r24    ;loop end (15.16)
	cmp     r22,r24         ;Above end?           ; ASSUMES r22 HAS CURRENT POSITION
	load    (r15+12),r25    ;loop length (15.16)
	jr      PL,notendf
	btst    #31,r5          ; ASSUMES R5 HAS VOLUME/FLAG
	jr      nz,notendf
	sub     r25,r22         ;wrap by current-length ; ASSUMES R22 HAS CURRENT POINTER
	subq    #4,r15
	movefa  r15,r0
	store   r0,(r15)
	jump    (r27)
	addq    #4,r15
notendf:
	store   r22,(r15+13)    ;save position         ; ASSUMES r22 GETS CURRENT POINTER
	move    r22,r16         ;position (used for interpolation)
	shrq    #8,r16
	load    (r15+9),r14     ;envelope start address
	and     r20,r16         ;leave fractional part only
	shrq    #16,r22         ;hilength               ; r22 AGAIN
	sub     r16,r20         ;1-frac;
	shlq    #2,r22          ;hilength               ; r22 AGAIN
	load    (r21),r4        ; MOVED TO AVOID LOAD LOAD
	add     r14,r22                                 ; And again
	load    (r22),r0        ;actual value 1
	addq    #4,r22          ;point at next sample
	load    (r22),r21       ;actual value 2
	imultn  r0,r20          ;val1*(1-frac)
	imacn   r21,r16         ;val2*(frac)
	resmac  r16             ;result
	sharq   #8,r16          ;shift back into range

; Interpolated envelope in r16

	imultn  r3,r10          ;val1*(1-frac)
	imacn   r11,r12         ;val2*(frac)
	resmac  r13             ;result

	load    (r15+15),r22    ; get depth of depth envelope   NEW

	sharq   #8,r13          ; shift back into range

	imult   r5,r13          ; multiply by amplitude

	imult   r16,r22         ; multiply envelope by depth    NEW
	sharq   #15,r13         ; normalize
	sharq   #15,r22         ;                               NEW
	imult   r16,r13         ; multiply by envelope
	add     r22,r8          ; add to current depth          NEW

	load    (r15+18),r19    ;left pan value

	imult   r8,r4           ;this is next fm setting
	movefa  r14,r20
	sharq   #7,r4           ;shift into range
	store   r4,(r15+4)

	sharq   #15,r13         ;shift down value for next stage
	sub     r19,r20         ;right panvalue
	imult   r13,r19         ;right o/p
	imult   r13,r20         ;left o/p
	add     r19,r9
	jump    (r27)
	add     r20,r26
.endif
;______________________________________________________________________________
;____________________________ end of fmenv module ________________________________

;______________________________________________________________________________

;_________________________ start of sampler module ____________________________
;______________________________________________________________________________

.if SMPL16_MOD
sampmod:
	load    (r15+2),r2      ;const step omega (24.8)
	movefa  r11,r24         ;=1 ish in 24.8
	load    (r15+5),r5      ;current position (24.8)
; BREAK UP LOADS
	load    (r15+3),r3      ;loop end(24.8)
	add     r2,r5           ;current+const->current
	load    (r15),r0        ;amplitude+flags
	cmp     r5,r3           ;is pointer above end?
	load    (r15+4),r4      ;loop length (24:8)

	jr      PL,nokill       ;no, so don't process
	btst    #31,r0          ;is this a stop loopend?

	jr      nz,nokill       ;no, loop exists
	sub     r4,r5           ;wrap round

	subq    #4,r15          ;This is a stopend
	movefa  r15,r0          ;kill voice
	store   r0,(r15)        ;
	jump    (r27)
	addq    #4,r15

nokill:
	move    r5,r4           ;fractional part
	store   r5,(r15+5)      ;save position (always done)
	shrq    #8,r5           ;take out fraction
	and     r24,r4          ;take out high length
	load    (r15+1),r1      ;start of sample
	shlq    #1,r5           ;hilength
	move    r24,r6          ;=1 under 24.8 representation

	add     r1,r5           ;add to start position
	sub     r4,r6           ;r4= frac, r6=1-frac
	loadw   (r5),r13        ;first actual value
	addq    #2,r5           ;prepare to get second value
	imult   r6,r13          ;(1-frac)*firstval
	loadw   (r5),r7         ;second actual value
	imult   r4,r7           ;frac*secondval
	add     r7,r13          ;add for interpolation

	load    (r15+18),r19    ;left pan value
	sharq   #8,r13          ;shift down to realign d.p.

	movefa  r14,r20
	imult   r0,r13           ;multiply by the amplitude (ls 15 bits of flag)
	sharq   #15,r13

	sub     r19,r20         ;right panvalue
	imult   r13,r19         ;right o/p
	imult   r13,r20         ;left o/p
	add     r19,r9
	jump    (r27)
	add     r20,r26
.endif
;______________________________________________________________________________
;_________________________ end of sampler module ______________________________

;_________________________ start of sampler module 2 __________________________
;                        sampler with volume envelope
;______________________________________________________________________________

.if SMPLENV_MOD
sampmod2:
	load    (r15+2),r2      ;const step omega (24.8)
	movefa  r11,r24         ;=1 ish in 24.8
	load    (r15+5),r5      ;current position (24.8)
; BREAK UP LOADS
	load    (r15+3),r3      ;loop end(24.8)
	add     r2,r5           ;current+const->current
	load    (r15),r0        ;amplitude+flags
	cmp     r5,r3           ;is pointer above end?
	load    (r15+4),r4      ;loop length (24:8)

	jr      PL,snokill      ;no, so don't process
	btst    #31,r0          ;is this a stop loopend?

	jr      nz,snokill      ;no, loop exists
	sub     r4,r5           ;wrap round

snokill:
	move    r5,r4           ;fractional part
	store   r5,(r15+5)      ;save position (always done)
	shrq    #8,r5           ;take out fraction
	and     r24,r4          ;take out high length
	load    (r15+1),r1      ;start of sample
	shlq    #1,r5           ;hilength
	move    r24,r6          ;=1 under 24.8 representation

	add     r1,r5           ;add to start position
	sub     r4,r6           ;r4= frac, r6=1-frac
	loadw   (r5),r13        ;first actual value
	addq    #2,r5           ;prepare to get second value
	imult   r6,r13          ;(1-frac)*firstval
	loadw   (r5),r7         ;second actual value
	imult   r4,r7           ;frac*secondval
	add     r7,r13          ;add for interpolation

	sharq   #8,r13          ;shift down to realign d.p. - moved up to here

; Interpolated sample in r13

	move    r0, r5          ; volume in r5 now

;       bail out

	btst    #30, r5         ; In release
	jr      nz,senv2
	btst    #31,r5          ; note off?
	jr      nz,senv2
	nop
	bset    #30,r5          ; flag in release
	store   r5,(r15)        ; store flag in volume

	load    (r15+9),r2      ; get the release slope
	store   r2,(r15+11)     ; Store it current slope
	moveq   #0,r2           ; set r2 to zero
	store   r2,(r15+12)     ; store destination to zero

; Now we apply the envelope

senv2:
	load    (r15+10),r3     ; load the current value
	load    (r15+12),r11    ; get destination
	load    (r15+11),r2     ; get current slope
	add     r2,r3           ; add slope to current value

	move    r3,r19          ; save the envelope value in r19
	sharq   #15,r19         ; get integer part
	sub     r19,r11         ; sub current value from dest.
	xor     r2,r11          ; check for slope vs. dest.
	btst    #31,r11         ; see if done
	movei   #scheat2,r8
	jump    EQ, (r8)
; change envelope

	btst    #30,r5          ; if in release then we're done
	jr      EQ,snotdone     ; else we have to do more
	nop
; done - kill it
	subq    #4,r15
	movefa  r15,r0          ;kill the voice
	store   r0,(r15)
	jump    (r27)
	addq    #4,r15          

snotdone:
	load    (r15+12),r3     ; store current value as dest you passed
	shlq    #15,r3          ; store it as 15.15
	load    (r15+8),r14     ; get current volume envelope location
	addq    #8,r14          ; go to next
	store   r14,(r15+8)     ; store new position
	load    (r14),r2        ; get new slope
	store   r2,(r15+11)     ; store new slope
	addq    #4,r14          ; point to new destination
	load    (r14),r19       ; get new dest.
	store   r19,(r15+12)    ; store new dest.
; Interpolated envelope in r12

scheat2:
	store   r3,(r15+10)     ; store new value

	shrq    #15,r3          ; get integer part
	imult   r3,r13          ; use the envelope
	sharq   #15,r13         ; shift sample back down

	imult   r5,r13          ; Do the volume
	sharq   #15,r13         ;shift down value for next stage

	load    (r15+18),r19    ;left pan value

	movefa  r14,r20

	sub     r19,r20         ;right panvalue
	imult   r13,r19         ;right o/p
	imult   r13,r20         ;left o/p
	add     r19,r9
	jump    (r27)
	add     r20,r26
.endif
;______________________________________________________________________________
;_________________________ end of sampler module 2 ____________________________

;______________________ start of compressed sampler module 2 __________________
;                        sampler with volume envelope
;______________________________________________________________________________

.if CSMPLENV_MOD
sampc2mod:
	load    (r15+2),r2      ;const step omega (24.8)
	movefa  r11,r24         ;=1 ish in 24.8
	load    (r15+5),r5      ;current position (24.8)
; BREAK UP LOADS
	load    (r15+3),r3      ;loop end(24.8)
	add     r2,r5           ;current+const->current
	load    (r15),r0        ;amplitude+flags
	cmp     r5,r3           ;is pointer above end?
	load    (r15+4),r4      ;loop length (24:8)

	jr      PL,scnokill     ;no, so don't process
	btst    #31,r0          ;is this a stop loopend?

	jr      nz,scnokill     ;no, loop exists
	sub     r4,r5           ;wrap round

scnokill:
	move    r5,r4           ;fractional part
	store   r5,(r15+5)      ;save position (always done)
	shrq    #8,r5           ;take out fraction
	and     r24,r4          ;take out high length
	movefa  r14,r20
	load    (r15+1),r1      ;start of sample
	move    r24,r6          ;=1 under 24.8 representation

	add     r1,r5           ;add to start position
	sub     r4,r6           ;r4= frac, r6=1-frac

	loadb   (r5),r13        ;first actual value
	addq    #1,r5           ;prepare to get second value
	loadb   (r5),r7         ;second actual value
	move    r13,r1
	bclr    #7,r13
	btst    #7,r1
	jr      EQ,sj1
	mult    r13,r13         ; square to decompress!!!!!!!!!
	neg     r13
sj1:
	move    r7,r2
	bclr    #7,r7
	btst    #7,r2
	jr      EQ,sj2
	mult    r7,r7           ; square to decompress!!!!!!!!!
	neg     r7
sj2:

	imult   r6,r13          ;(1-frac)*firstval
	imult   r4,r7           ;frac*secondval
	add     r7,r13          ;add for interpolation

	sharq   #7,r13          ;shift down to realign d.p. - moved up to here

; Interpolated sample in r13

	move    r0, r5          ; volume in r5 now

;       bail out

	btst    #30, r5         ; In release
	jr      NE,scenv2
	btst    #31,r5          ; note off?
	jr      NE,scenv2
	nop
	bset    #30,r5          ; flag in release
	store   r5,(r15)        ; store flag in volume

	load    (r15+9),r2      ; get the release slope
	store   r2,(r15+11)     ; Store it current slope
	moveq   #0,r2           ; set r2 to zero
	store   r2,(r15+12)     ; store destination to zero

; Now we apply the envelope

scenv2:
	load    (r15+10),r3     ; load the current value
	load    (r15+11),r2     ; get current slope
	load    (r15+12),r11    ; get destination
	add     r2,r3           ; add slope to current value

	move    r3,r19          ; save the envelope value in r19
	sharq   #15,r19         ; get integer part
	sub     r19,r11         ; sub current value from dest.
	xor     r2,r11          ; check for slope vs. dest.
	btst    #31,r11         ; see if done
	movei   #sccheat2,r8
	jump    EQ, (r8)
; change envelope

	btst    #30,r5          ; if in release then we're done
	jr      EQ,scnotdone    ; else we have to do more
	nop
; done - kill it
	subq    #4,r15
	movefa  r15,r0          ;kill the voice
	store   r0,(r15)
	jump    (r27)
	addq    #4,r15          

scnotdone:
	load    (r15+12),r3     ; store curr value as dest you just passed
	shlq    #15,r3          ; store it as 15.15
	load    (r15+8),r14     ; get current volume envelope location
	addq    #8,r14          ; go to next
	store   r14,(r15+8)     ; store new position
	load    (r14),r2        ; get new slope
	store   r2,(r15+11)     ; store new slope
	addq    #4,r14          ; point to new destination
	load    (r14),r19       ; get new dest.
	store   r19,(r15+12)    ; store new dest.
; Interpolated envelope in r12

sccheat2:
	store   r3,(r15+10)     ; store new value

	shrq    #15,r3          ; get integer part
	imult   r3,r13          ; use the envelope
	sharq   #15,r13         ; shift sample back down

	imult   r5,r13          ; Do the volume
	sharq   #15,r13         ;shift down value for next stage

	load    (r15+18),r19    ;left pan value

	movefa  r14,r20

	sub     r19,r20         ;right panvalue
	imult   r13,r19         ;right o/p
	imult   r13,r20         ;left o/p
	add     r19,r9
	jump    (r27)
	add     r20,r26
.endif
;______________________________________________________________________________
;_________________________ end of compressed sampler module 2 _________________

;______________________________________________________________________________

;_________________________ start of 8-bit sampler module ____________________________
;______________________________________________________________________________

.if SMPL8_MOD

samp8mod:
	load    (r15+2),r2      ;const step omega (24.8)
	movefa  r11,r24         ;=1 ish in 24.8
	load    (r15+5),r5      ;current position (24.8)
; BREAK UP LOADS
	load    (r15+3),r3      ;loop end(24.8)
	add     r2,r5           ;current+const->current
	load    (r15),r0        ;amplitude+flags
	cmp     r5,r3           ;is pointer above end?
	load    (r15+4),r4      ;loop length (24:8)

	jr      PL,nokill8      ;no, so don't process
	btst    #31,r0          ;is this a stop loopend?

	jr      NE,nokill8      ;no, loop exists
	sub     r4,r5           ;wrap round

	subq    #4,r15          ;This is a stopend
	movefa  r15,r0          ;kill voice
	store   r0,(r15)        ;
	jump    (r27)
	addq    #4,r15

nokill8:
	move    r5,r4           ;fractional part
	store   r5,(r15+5)      ;save position (always done)
	shrq    #8,r5           ;take out fraction
	and     r24,r4                  ;take out high length
	load    (r15+1),r1      ;start of sample
	move    r24,r6          ;=1 under 24.8 representation

	add     r1,r5           ;add to start position
	sub     r4,r6           ;r4= frac, r6=1-frac
LOADBYTE:
	loadb   (r5),r13        ;first actual value
	addq    #1,r5           ;prepare to get second value
	shlq    #8,r13
	imult   r6,r13          ;(1-frac)*firstval
	loadb   (r5),r7         ;second actual value
	shlq    #8,r7
	imult   r4,r7           ;frac*secondval
	add     r7,r13          ;add for interpolation
	load    (r15+18),r19    ;left pan value
	sharq   #8,r13          ;shift down to realign d.p.

	movefa  r14,r20
	imult   r0,r13          ;multiply by the amplitude (ls 15 bits of flag)
	sharq   #15,r13

	sub     r19,r20         ;right panvalue
	imult   r13,r19         ;right o/p
	imult   r13,r20         ;left o/p
	add     r19,r9
	jump    (r27)
	add     r20,r26
.endif
;______________________________________________________________________________
;_________________________ end of sampler module ______________________________

;______________________________________________________________________________

;_____________________________ start of fm2 module ____________________________
;______________________________________________________________________________

.if FMCMPLX_MOD
fm2mod:
	load    (r15+2),r2      ;current pointer position (16.16)
	move    r15,r24
	addq    #3*4,r24
	load    (r24),r3
	addq    #4,r24
	load    (r24),r4
	
	movefa  r19,r1
	load    (r15+6),r6      ;fm pointer position (16.16)
	load    (r15+7),r7      ;fm const step (16.16)
	add     r3,r2           ;current+const->current
	load    (r15+14),r18    ;ptr for fmstep modulator
	add     r7,r6           ;fm current+const->current
	load    (r15+15),r16    ;step for fmstep modulator
	move    r18,r21
	load    (r15+11),r11    ;ptr for fmindex modulator
	add     r16,r18         ;fmstepm current+const->current
	load    (r15+12),r12    ;step for fmindex modulator

	add     r12,r11         ;fmindexm current+const->current
	load    (r15+9),r23     ;fm step (variable)
	add     r4,r2           ;current+variable->current
	add     r23,r6          ;fm current+variable->current
	and     r1,r2           ;wrap round
	and     r1,r6           ;fm wrap round
	store   r2,(r15+2)      ;save position
	and     r1,r18          ;fmstep wrap round
	store   r6,(r15+6)      ;fm save position
	and     r1,r11          ;fmindex wrap round
	store   r18,(r15+14)    ;fmstep save position
	movefa  r11,r20
	store   r11,(r15+11)    ;fmindex save position
	move    r2,r19
	shrq    #8,r19
	load    (r15),r14       ;start address
	and     r20,r19         ;frac
	load    (r15+5),r5      ;amplitude alpha
	sub     r19,r20         ;1-frac
	load    (r15+10),r10    ;fm index (variable)
	shrq    #16,r2          ;hilength
	load    (r15+13),r13    ;amplitude of fmindex modulator
	shrq    #16,r6          ;fm hilength
	move    r21,r18
	shrq    #16,r18         ;fmstep hilength
	load    (r15+8),r8      ;fm index (const)
	shrq    #16,r11         ;fmindex hilength
	load    (r15+16),r17    ;amplitude of fmstep modulator

	shlq    #2,r2           ;hilength
	shrq    #14,r1

	load    (r14+r2),r21    ;actual value
	addq    #4,r2           ; for interpolation
	and     r1,r2
	load    (r14+r2),r22    ;for interpolation
	shlq    #2,r6           ;fm hilength


	imultn  r21,r20         ;val1*(1-frac)
	imacn   r22,r19         ;val2*frac
	resmac  r21

; This next instruction allows a different waveform for the
; modulation of the modulator at the expense of polyphony!

	load    (r15+17),r14    ;mod of modulators' position
	shlq    #2,r11          ;fmindex hilength
	load    (r14+r6),r4     ;fm value for next sample
	shlq    #2,r18          ;fmstep hilength
	load    (r14+r11),r12   ;fmindex value

; BREAK UP LOADS
	load    (r14+r18),r16   ;fmstep value
	sharq   #8,r21

	add     r10,r8          ;add fmindex variable to const
	imult   r5,r21          ;multiply by amplitude
	imult   r8,r4           ;this is next fm setting
	sharq   #15,r21         ;shift down value for DAC
	sharq   #7,r4           ;shift fm setting down to allow lf osc
	load    (r15+18),r19    ;left pan value
	imult   r13,r12         ;multiply fmindex by fmindex amplitude
	imult   r17,r16         ;multiply fmstep by fmstep amplitude
	sharq   #15,r12         ;as for fmindex
	sharq   #7,r16          ;ditto for fmstep

	store   r4,(r15+4)      ;store fm setting in step (variable)
	store   r16,(r15+9)     ;store fmstep setting in fmstep (variable)
	movefa  r14,r20
	store   r12,(r15+10)    ;store fmindex setting in fmindex (variable)

	sub     r19,r20         ;right panvalue
	imult   r21,r19         ;right o/p
	imult   r21,r20         ;left o/p
	add     r19,r9
	jump    (r27)
	add     r20,r26
.endif
;______________________________________________________________________________
;____________________________ end of fm2 module ________________________________

;______________________________________________________________________________

;_____________________________ start of simple module _________________________
;______________________________________________________________________________

.if WAVEFM_MOD
simpmod:
	move    r15,r21
	move    r21,r22
	addq    #2*4,r21        ; 21 points to 2 
	addq    #3*4,r22        ; 22 points to 3
	load    (r21),r2        ; current pointer position (16.16)
	addq    #2*4,r21        ; 21 points to 4
	load    (r22),r3        ; current env position (16.16)
	addq    #2*4,r22        ; 22 points to 5
	load    (r21),r4
	addq    #2*4,r21        ; 21 points to 6
	load    (r22),r5        ; Volume
	add     r3,r2           ; INSERTED FOR PIPELINING ;current+const->current
	load    (r21),r6        ; const step env omega (16.16)

	add     r6,r4           ;current+const->current
	movefa  r19,r1          ; Length of sine table

; Now we interpolate the sample

	movefa  r11,r10         ;1 in 23.8 format
	load    (r15),r14       ;start address
	and     r1,r2           ;wrap round
	store   r2,(r15+2)      ;save position
	move    r2,r12          ;position (used for interpolation)
	shrq    #8,r12
	and     r10,r12         ;leave fractional part only
	shrq    #16,r2          ;hilength
	sub     r12,r10         ;1-frac;
	shlq    #2,r2           ;hilength
	add     r14,r2
	load    (r2),r3         ;actual value 1
	addqmod #4,r2           ;point at next sample
	load    (r2),r11        ;actual value 2
	imultn  r3,r10          ;val1*(1-frac)
	imacn   r11,r12         ;val2*(frac)
	resmac  r13             ;result
	sharq   #8,r13          ;shift back into range

; Interpolated sample in r13

; Now we interpolate the envelope

	movefa  r11,r10         ;1 in 23.8 format
	load    (r15+7),r7      ;loop end (15.16)
	cmp     r4,r7           ;Above end?
	load    (r15+8),r8      ;loop length (15.16)
	jr      PL,notend
	btst    #31,r5
	jr      NE,notend
	sub     r8,r4           ;wrap by current-length
	subq    #4,r15
	movefa  r15,r0          ;kill the voice
	store   r0,(r15)
	jump    (r27)
	addq    #4,r15
notend:
	store   r4,(r15+4)      ;save position
	move    r4,r12          ;position (used for interpolation)
	shrq    #8,r12
	load    (r15+1),r14     ;envelope start address
	and     r10,r12         ;leave fractional part only
	shrq    #16,r4          ;hilength
	sub     r12,r10         ;1-frac;
	shlq    #2,r4           ;hilength
	add     r14,r4
	load    (r4),r3         ;actual value 1
	addq    #4,r4           ;point at next sample
	load    (r4),r11        ;actual value 2
	imultn  r3,r10          ;val1*(1-frac)
	imacn   r11,r12         ;val2*(frac)
	resmac  r12             ;result

;       sharq   #8,r12          ;shift back into range

; Interpolated envelope in r12

cheat:
	imult   r5,r13          ; Do the volume
	sharq   #8,r12          ; MOVED FOR PIPELINE
	sharq   #15,r13         ;shift down value for next stage

	imult   r12,r13         ;multiply by amplitude
	load    (r15+18),r19    ;left pan value
	sharq   #15,r13         ;shift down value for next stage

	movefa  r14,r20

	sub     r19,r20         ;right panvalue
	imult   r13,r19         ;right o/p
	imult   r13,r20         ;left o/p

	add     r19,r9
	jump    (r27)
	add     r20,r26
.endif

;_____________________________ start of simple module  2 _________________________
;______________________________________________________________________________

.if WAVEFM2_MOD
simpmod2:
	move    r15,r21
	move    r21,r22
	addq    #2*4,r21        ; 21 points to 2
	load    (r21),r2        ; pts to 2: get current ptr position (16.16)
	addq    #3*4,r22        ; 22 points to 3
	load    (r22),r3        ; pts to 3: const step omega (16.16)
	addq    #3*4,r21        ; 21 points to 5
	load    (r21),r5        ; pts to 5: volume

	add     r3,r2           ; current+const->current

	movefa  r19,r1          ; Length of sine table

; Now we interpolate the sample

	movefa  r11,r10         ;1 in 23.8 format
	load    (r15),r14       ;start address
	and     r1,r2           ;wrap round
	store   r2,(r15+2)      ;save position
	move    r2,r12          ;position (used for interpolation)
	shrq    #8,r12
	and     r10,r12    ;leave fractional part only
	shrq    #16,r2          ;hilength
	sub     r12,r10         ;1-frac;
	shlq    #2,r2           ;hilength
	add     r14,r2
	load    (r2),r3           ;actual value 1
	addqmod #4,r2           ;point at next sample
	load    (r2),r11        ;actual value 2
	imultn  r3,r10          ;val1*(1-frac)
	imacn   r11,r12         ;val2*(frac)
	resmac  r13             ;result
	sharq   #8,r13          ;shift back into range

; Interpolated sample in r13

;       bail out

	btst    #30, r5         ; In release
	jr      NE,env2
	btst    #31,r5          ; note off?
	jr      NE,env2
	nop
	bset    #30,r5          ; flag in release
	store   r5,(r15+5)      ; store flag

	load    (r15+1),r2      ; get the release slope
	store   r2,(r15+7)      ; Store it current slope
	moveq   #0,r2           ; set r2 to zero
	store   r2,(r15+8)      ; store destination to zero

; Now we apply the envelope

env2:
	load    (r15+6),r3      ; load the current value
	load    (r15+7),r2      ; get current slope
	load    (r15+8),r11     ; get destination
	add     r2,r3           ; add slope to current value

	move    r3,r19          ; save the envelope value in r19
	sharq   #15,r19         ; save the envelope value in r19
	sub     r19,r11         ; sub current value from dest.
	xor     r2,r11          ; check for slope vs. dest.
	btst    #31,r11         ; see if done
	movei   #cheat2,r8
	jump    EQ, (r8)
; change envelope

	btst    #30,r5          ; if in release then we're done
	jr      EQ,notdone      ; else we have to do more
	nop
; done - kill it
	subq    #4,r15
	movefa  r15,r0          ;kill the voice
	store   r0,(r15)
	jump    (r27)
	addq    #4,r15          

notdone:
	load    (r15+8),r3      ; store curr value as dest you just passed
	shlq    #15,r3          ; store it as 15.15
	load    (r15+4),r14     ; get current volume envelope location
	addq    #8,r14          ; go to next
	store   r14,(r15+4)     ; store new position
	load    (r14),r2        ; get new slope
	store   r2,(r15+7)      ; store new slope
	addq    #4,r14          ; point to new destination
	load    (r14),r19       ; get new dest.
	store   r19,(r15+8)     ; store new dest.
; Interpolated envelope in r12

cheat2:
	store   r3,(r15+6)      ; store new value

	shrq    #15,r3          ; get integer part
	imult   r3,r13          ; use the envelope
	sharq   #15,r13         ; shift sample back down

	imult   r5,r13          ; Do the volume
	sharq   #15,r13         ;shift down value for next stage


	load    (r15+18),r19    ;left pan value

	movefa  r14,r20

	sub     r19,r20         ;right panvalue
	imult   r13,r19         ;right o/p
	imult   r13,r20         ;left o/p

	add     r19,r9
	jump    (r27)
	add     r20,r26

.endif
;_________________________end of simp mod 2 ___________________________________
;______________________________________________________________________________

;______________________________________________________________________________
;_________________________start of effects modules_____________________________
;______________________________________________________________________________

;____________________________start of echo module______________________________
;______________________________________________________________________________

.if 0
echo:
	load    (r14+2),r2      ;position
	movefa  r16,r4
	load    (r14),r0        ;delay
	addq    #4,r2           ;step on
	load    (r14+1),r1      ;fback
	and     r4,r2           ;wrap tap if necessary

	move    r9,r10
	store   r2,(r14+2)      ;save position
	move    r2,r3           ;copy position to work out tap
	sub     r0,r2           ;subtract to find tap pos
	movefa  r17,r15
	and     r4,r2           ;wrap if necessary on store pos

	load    (r15+r2),r6     ;load tap value
	add     r26,r10
	sharq   #1,r6           ;tap is stored at 17 bits res.
	imult   r1,r6           ;multiply by fback coeff
	sharq   15,r6           ;and shift down into range (17bits)
	add     r6,r10          ;add to original (17 bits)
	store   r10,(r15+r3)    ;and store in buffer
	sharq   #1,r10          ;shift back into range
	add     r10,r9
	jump    (r27)
	add     r10,r26
.endif
;______________________________________________________________________________
;______________________________end of echo module______________________________

;______________________________________________________________________________

;____________________________start of reverb module____________________________
;______________________________________________________________________________

.if 0
reverb:

	load    (r14),r0        ;delay1
; BREAK UP LOADS
	load    (r14+1),r1      ;fback1
; BREAK UP LOADS
	load    (r14+2),r10     ;delay2
; BREAK UP LOADS
	load    (r14+3),r11     ;fback2
; BREAK UP LOADS
	load    (r14+8),r2      ;position

	move    r26,r25
	add     r9,r25
	movefa  r16,r4
	addq    #4,r2           ;step on
	and     r4,r2           ;wrap tap if necessary
	movefa  r17,r15
	store   r2,(r14+8)      ;save position
	move    r2,r3           ;copy position to work out tap1
	move    r2,r12          ;ditto,tap2
	sub     r0,r2           ;subtract to find tap pos
	sub     r10,r12         ;ditto,tap2
	and     r4,r2           ;wrap tap if necessary
	and     r4,r12          ;ditto,tap2

	load    (r15+r2),r6     ;load tap value
; BREAK UP LOADS
	load    (r15+r12),r16   ;ditto,tap2
	sharq   #1,r6           ;taps stored in 17bit format
	sharq   #1,r16
	imult   r1,r6           ;multiply by fback coeff
	imult   r11,r16         ;ditto,tap2
	sharq   #15,r6          ;and shift down sort of into range
	sharq   #15,r16         ;ditto,tap2
	add     r6,r25          ;add to original
	add     r16,r25         ;ditto,tap2

		;__________________________________

	load    (r14+4),r0      ;delay3
; BREAK UP LOADS
	load    (r14+5),r1      ;fback3
; BREAK UP LOADS
	load    (r14+6),r10     ;delay4
; BREAK UP LOADS
	load    (r14+7),r11     ;fback4

	move    r3,r2
	move    r3,r12          ;ditto,tap4
	sub     r0,r2           ;subtract to find tap pos
	sub     r10,r12         ;ditto,tap4
	and     r4,r2           ;wrap tap if necessary
	and     r4,r12          ;ditto,tap4

	load    (r15+r2),r6     ;load tap value
; BREAK UP LOADS
	load    (r15+r12),r16   ;ditto,tap4
	sharq   #1,r6           ;taps stored in 17bit format
	sharq   #1,r16
	imult   r1,r6           ;multiply by fback coeff
	imult   r11,r16         ;ditto,tap4
	sharq   #15,r6          ;and shift down sort of into range
	sharq   #15,r16         ;ditto,tap4
	and     r4,r3           ;wrap if necessary on store pos
	add     r16,r25         ;add to originial ,tap4
	add     r6,r25          ;add to original

		;__________________________________
	store   r25,(r15+r3)    ;and store in buffer
	sharq   #1,r25          ;shift back into range

	add     r25,r9

	jump    (r27)
	add     r25,r26
.endif
;______________________________________________________________________________
;______________________________end of reverb module____________________________

;______________________________________________________________________________

;____________________________start of flange module____________________________
;______________________________________________________________________________

.if 0
flange:

	load    (r14),r1        ;const offset (samples 16:16)
; BREAK UP LOADS
	load    (r14+5),r7      ;sine position
	movefa  r19,r17         ;sinetable buffer length (23.8)
	add     r1,r7           ;increment sine pointer
	and     r17,r7          ;wrap round
	store   r7,(r14+5)      ;save position

	sharq   #16,r7          ;remove fraction
	movefa  r18,r0          ;Sinewave position
	shlq    #2,r7           ;adjust for long word align
	add     r0,r7           ;add offset of table
	load    (r14+2),r3      ;modulation index (samples)
; BREAK UP LOADS
	load    (r7),r8         ;load sine value
	imult   r3,r8           ;multiply by modulation index
	sharq   #8,r8           ;shift half back in range
	move    r8,r16          ;save for interpolation
	load    (r14+1),r2      ;base delay (samples)
	sharq   #8,r8           ;shift other half back in range
	add     r2,r8           ;add base delay
	load    (r14+6),r6      ;buffer position
	shlq    #2,r8           ;adjust for word align

	move    r6,r17          ;pass to tap2
	addq    #4,r6           ;increment store pointer
	move    r6,r10          ;pass to work variable for tap1
	sub     r8,r17          ;subtract delay from tap2
	movefa  r17,r24         ;set up offset
	movefa  r16,r23         ;set up wrap constant
	sub     r8,r10          ;subtract tap delay for tap1
	and     r23,r6          ;wrap store ptr
	and     r23,r10         ;wrap tap1 ptr
	store   r6,(r14+6)      ;save buffer position
	and     r23,r17         ;wrap tap1 ptr

	add     r24,r10          ;add offset to tap1 ptr
	add     r24,r17          ;add offset to tap2 ptr
	loadw   (r10),r11        ;load tap value
; BREAK UP LOADS
	loadw   (r17),r18       ;load tap2 value
	add     r24,r6          ;add offset to buffer ptr

	movefa  r11,r20
	and     r20,r16
	sub     r16,r20         ;r16= frac, r19=1-frac

	imult   r20,r11         ;(1-frac)*firstval
	imult   r16,r18         ;frac*secondval
	add     r18,r11         ;add for interpolation
	sharq   #8,r11          ;shift down to realign d.p.

; at this point, tap value is in r11, real value in r9

	load    (r14+3),r4      ;F      Feedback level
	movefa  r14,r8          ;set up 1
	imult   r4,r11          ;multiply tap val by fb level
	load    (r14+4),r12     ;effect level
	sharq   #15,r11         ;shift back into range
	sub     r12,r8          ;get 1-effect level
	move    r26,r25
	add     r9,r25
	sharq   #1,r25
	add     r25,r11         ;add to actual sample level, to get flange
	sat16   r11             ;saturate before saveing
	storew  r11,(r6)        ;save flange value in buffer

	imult   r8,r9           ;multiply right sample by 1-effect level
	imult   r8,r26          ;multiply left sample by 1-effect level
	imult   r11,r12         ;multiply by effect level

	sharq   #15,r9          ;shift back into range
	sharq   #15,r26         ;shift back into range
	sharq   #15,r12         ;shift back into range
	add     r12,r26

	jump    (r27)
	add     r12,r9          ;add effect onto sample

.endif
;______________________________________________________________________________
;______________________________end of flange module____________________________

;______________________________________________________________________________

;____________________________start of chorus module____________________________
;______________________________________________________________________________

chorus:

.if 0
	load    (r14+5),r7      ;sine position

	movefa  r17,r24
	load    (r14),r1        ;const offset (samples 16:16)
	movefa  r19,r17         ;sinetable buffer length
	add     r1,r7           ;increment sine pointer
	load    (r14+6),r6      ;buffer position
	and     r17,r7          ;wrap round
	store   r7,(r14+5)      ;save position

	sharq   #16,r7          ;remove fraction
	movefa  r18,r0          ;Sinewave position
	shlq    #2,r7           ;adjust for long word align
	load    (r14+2),r3      ;modulation index (samples)
	add     r0,r7           ;add offset of table
	load    (r7),r8         ;load sine value
	imult   r3,r8           ;multiply by modulation index
	load    (r14+1),r2      ;base delay (samples)
	sharq   #8,r8           ;shift half back in range
	move    r8,r16          ;save for interpolation
	sharq   #8,r8           ;shift other half back in range
	add     r2,r8           ;add base delay
	shlq    #2,r8           ;adjust for long word align

	move    r6,r17          ;pass to tap2
	addq    #4,r6           ;increment store pointer
	move    r6,r10          ;pass to work variable for tap1
	movefa  r16,r23
	and     r23,r6          ;wrap store ptr
	sub     r8,r17          ;subtract delay from tap2
	sub     r8,r10          ;subtract tap delay for tap1
	and     r23,r17         ;wrap tap1 ptr
	and     r23,r10         ;wrap tap1 ptr
	store   r6,(r14+6)      ;save buffer position

	add     r24,r10          ;add offset to tap1 ptr
	add     r24,r17          ;add offset to tap2 ptr
	add     r24,r6           ;add offset to buffer ptr
	load    (r10),r11        ;load tap value
	load    (r17),r18       ;load tap2 value

	movefa  r11,r20
	and     r20,r16
	sub     r16,r20         ;r16= frac, r19=1-frac

	imult   r20,r11         ;(1-frac)*firstval
	imult   r16,r18         ;frac*secondval
	add     r18,r11         ;add for interpolation
	sharq   #8,r11          ;shift down to realign d.p.

; at this point, tap value is in r11, real value in r9

	load    (r14+3),r4      ;F      Feedback level
	movefa  r14,r8          ;set up 1
	load    (r14+4),r12     ;effect level
	imult   r4,r11          ;multiply tab val by fb level
	sub     r12,r8          ;get 1=effect level
	sharq   #16,r11         ;shift back into range
	move    r26,r25
	add     r9,r25
	sharq   #1,r25
	sat16   r25             ;saturate before saving
	store   r25,(r6)        ;save raw value in buffer
	add     r25,r11         ;add to actual sample level, to get flange
	imult   r8,r9           ;multiply sample by 1-effect level
	imult   r8,r26          ;multiply sample by 1-effect level
	imult   r11,r12         ;multiply by effect level
	sharq   #16,r9          ;shift back into range
	sharq   #16,r26         ;shift back into range
	sharq   #16,r12         ;shift back into range

	add     r12,r26
	jump    (r27)
	add     r12,r9          ;add effect onto sample

.endif

;______________________________________________________________________________
;______________________________end of chorus module____________________________

;______________________________________________________________________________

;____________________________start of ring modulation module___________________
;______________________________________________________________________________

.if 0
ring:

	load    (r14),r1        ;step (24:8)
	load    (r14+1),r7      ;effect level
	load    (r14+2),r4      ;current pointer

;______________________________________________________________________________

	movefa  r18,r0          ;position
	movefa  r14,r2          ;modulo arithmetic
	move    r9,r5           ;save current sample
	move    r26,r10
	add     r1,r4           ;increment pointer
	and     r2,r4           ;wrap round if necessary
	store   r4,(r14+2)      ;and save pointer

	shrq    #8,r4           ;kill fractional part
	shlq    #2,r4           ;multiply to get to long word boundary
	add     r0,r4           ;add on sine table position
	load    (r4),r6         ;sinewave sample

	movefa  r14,r8          ;set up 1
	imult   r6,r5           ;multiply sample by sinewave sample
	imult   r6,r10
	sub     r7,r8           ;get 1=effect level
	sharq   #16,r5          ;shift back into range
	sharq   #16,r10         ;shift back into range
	imult   r8,r9           ;multiply sample by 1-effect level
	imult   r8,r26          ;multiply sample
	imult   r7,r5           ;multiply by effect level
	imult   r7,r10          ;multiply by effect level
	sharq   #15,r9          ;shift back into range
	sharq   #15,r26
	sharq   #15,r5          ;shift back into range
	sharq   #15,r10         ;shift back into range

	add     r5,r9           ;after adding to original sample
	jump    (r27)
	add     r10,r26
.endif
;______________________________________________________________________________
;______________________________end of ring module______________________________

;______________________________________________________________________________


;______________________________________________________________________________
;______________________________end of effects modules__________________________
;______________________________________________________________________________

;____________________start of I2S interrupt service routine__________________
;______________________________________________________________________________

; Sample Rate interrupt

i2s_isr:

; Put the Flags register away for safe keeping!!!

	move    r20,r30                 ; get flags ptr

	load    (r30),r12                ;load flags

; Now we need to actually store the data to the DACs here
	move    r21,r28                 ; get output counter
	shlq    #3,r28
	movei   #buffstart,r29          ; r29 will be read location
	add     r28,r29
	move    r9,r28                  ; get address of DAC
	load    (r29),r30
	store   r30,(r28)
	addq    #4,r29
	addq    #4,r28
	load    (r29),r30
	store   r30,(r28)
; And finally increment the OC (Output Counter)
	addq    #1,r21
	bclr    #3,r21
		
; The following code is the magic to do an rte
; Assuming that the Flags are in r12

	move    r20,r30                 ; get flags ptr

	bclr    #3,r12                  ; clear IMASK
	load    (r31),r28               ; get last instruction address
	bset    #10,r12                 ; clear I2S interrupt
	addq    #2,r28                  ; point at next to be executed
	addq    #4,r31                  ; update the stack pointer
	jump    (r28)                   ; and return
	store   r12,(r30)               ; restore flags
	nop                             ; NEEDS TWO NOPS TO PROTECT AGAINST 
	nop                             ; EXTERNAL LOADINGS


SHUTDOWN:
	movei   #D_CTRL,r0
	movei   #$f10000,r2
	movei   #$f10002,r3
	moveq   #0,r1
	storew  r1,(r2)
	storew  r1,(r3)
	store   r1,(r0)
	nop
	nop
	nop
	nop

;____________________start of Timer 2 interrupt service routine__________________
;______________________________________________________________________________


; Tempo Rate interrupt

; We assume that r16 points to the current time count
; We assume that r17 points to the current score pointer

tmr1_isr:
	move    r20,r30         ; Get address of FLAGS
	load    (r30),r22
	bclr    #3,r22          ; Clear IMASK
	bclr    #6,r22          ; don't allow nested interrupts
	bset    #11,r22         ; timer 1 interrupt latch clear
	bclr    #14,r22         ; Use bank 0!!!!!
	store   r22,(r30)
	nop                     ; wait for bank switch!!!!

; THIS FORCES SOMETHING AUDIBLE TO HAPPEN (if something good is at $f1b810
;       movei   #$f1b810,r23
;       load    (r23),r6
;       addq    #32,r6
;       store   r6,(r23)
; END OF FORCE OF AUDIBLE SOMETHING

inin:
	load    (r16),r4

	addq    #1,r4           ; Increment current time count

	load    (r17),r5        ; Get the current score pointer

	load    (r5),r6         ; Current score pointer in r5

	cmp     r4,r6
	jr      MI,l1
	nop             
	movei   #tmr1_ret,r23
	jump    (r23)
	nop             
l1:

; Coded events look like this
; EEEV|VVxx|xxxx|xxxx|xxxx|xxxx|xxxx|xxxx
; EEE = Event type
;       1xx means note on
;       000 means note off
; EEEV|VVPP|PPPF|FFFF|FFFF|FFFF|FAAA|AAAA
;       V|VV = Voice number
;       PP|PPP = Patch number
;       F|FFFF|FFFF|FFFF|F = Frequency
;       AAA|AAAA = Amplitude
;
;       001 PATCH CHANGE
; 001x|xxPP|PPPxx|xxxx|xxxx|xxxx|xxxx|xxxx
;       PP|PPP = patch number
;       Replace the patch in the table with
;       the next 20 longs in the data stream
;
;       010 CONTROLLER CHANGE
; 010V|VVPP|PPPF|CCCC|CNNN|NNNN|NNNN|NNNN
;       V|VV = voice number
;       PP|PPP = Patch Number
;       F = Flag to change the base patch
;       CCCC|C = Controller code (0-31)
;       NNN|NNNN|NNNN|NNNN = value
;       Controllers are:
;       Volume          7
;       Pitch Bend      9
;       Pan             10
;
;       Modulation 1
;       Depth 1
;       Modulation 2
;       Depth 2
;       Modulation 3
;       Depth 3
;
;       011 JUMP WITH COUNT
; 011E|DDDD|DDDD|DDDD|DDDD|DDDD|FFFF|CCCC
;       CCCC is number of loops played
;       FFFF is a backup of number of loops played
;       DDDD|DDDD|DDDD|DDDD|DDDD
;               is the number of phrases to jump
;       E is a flag for infinite looping
;
	addq    #4,r5

	load    (r5),r6         ; Got coded event in r6

	addq    #4,r5

	move    r6,r7           ; get the voice number
	shlq    #3,r7
	shrq    #29,r7          ; voice number is in r7

	movei   #vol_orgs,r8    ; back up of volume
	move    r7,r23          ; plus voice number     
	shlq    #2, r23         ; in longs
	add     r23,r8
	movei   #vol_op,r23
	store   r8,(r23)                

	movei   #pitch_orgs,r8  ; back up of pitch
	move    r7,r23          ; plus voice number
	shlq    #2, r23         ; in longs
	add     r23,r8  
	movei   #pitch_op,r23
	store   r8,(r23)                

	move    r3,r27          ; taboff-4
	addq    #4,r27          ; r27 has the size of a table
	mult    r27,r7
	add     r0,r7           ; address of desired voice table in r7

	btst    #31,r6
	jr      NE,note_on
	nop                     

	movei   #not_on,r25
	jump    (r25)
	nop                     

note_on:
; At this point we need to check to see if
; the voice is on or off!
; Voice table position is in r7
; If on, turn it off and punt

	load    (r7),r25
	btst    #31,r25
	jr      NE,l2
	nop

	subq    #8,r5           ; Rewind to do it again!
	movei   #tmr1_ret,r25
	jump    (r25)
	store   r15,(r7)        ; Turn off note
l2:

ntyp:
	move    r6,r25          ; get patch number
	shlq    #6,r25
	shrq    #27,r25         ; patch number is in r25

	move    r6,r26          ; get the frequency
	shlq    #11,r26
	shrq    #18,r26         ; frequency is in r26

	and     r11,r6
	bclr    #7,r6

	shlq    #6,r6           ; volume is in r6

; do volume adjust
	movei   #VOLUME,r23     ; MIDI VOLUME
	load    (r23),r23
	imult   r23,r6
	sharq   #15,r6

	cmpq    #0,r6
	jr      eq,vol_zero
	nop
	movei   #vol_op, r8
	load    (r8),r8
	store   r6,(r8)         ; backup of volume

; Now compute the address of the routine to fill in the rest of the stuff       
; This is based on the first number in a patch
vol_zero:
	movei   #PATCHLOC,r23
	load    (r23), r23 

	mult    r25,r27         ; r27 have size of table
	add     r27,r23         ; Start of patch in r23
	load    (r23),r8

	movei   #on_tab,r27
	add     r27,r8
	load    (r8),r8         ; got address of rest of routine
	
; at this point the position of the master patch is in r23
; the position of the destination voice is in r7
; Address of special code is in r8 
; Address next procedure goes into r25

copy_it:
; At this point the patch is pointed to by r23
; The destination voice table entry is pointed to by r7
; Both r25 and r27 are available

	movei   #19,r27
	movei   #80,r25
	add     r25,r23
	add     r25,r7
; Now r23 and r7 point to the end of the tables and r27 has a count

	subq    #4,r23
clop:
	subq    #4,r7
	load    (r23),r25
	subq    #1,r27
	store   r25,(r7)
	jr      PL,clop
	subqt   #4,r23

	movei   #tmr1_ret,r25

	jump    (r8)
	nop                     
	
; Now we munge the copied patch

simpmod_on:
simpmod2_on:

.if WAVEFM_NOTE

	movei   #pitch_op, r8
	load    (r8),r8
	store   r26,(r8)        ; backup pitch

	addq    #4*4,r7

	load    (r7), r23       ; do the pitch calculation
	mult    r23, r26

	shrq    #4, r26

	store   r26,(r7)

	addq    #4*2,r7         ; now get the volume
	load    (r7),r26


	move    r26,r23         ; save loop flag
	bclr    #31,r26         ; erase loop flag for now (volume env)
	bclr    #30,r26         ; erase loop flag for now (filter env)
	mult    r26,r6          ; do the multiply with the volume


	btst    #31,r23         ; was the loop flag set? (volume env)
	jr      EQ,sm_l1        ; no, go on
	shrq    #8,r6           ; MOVED DOWN FOR PIPLINIG (X1')
	bset    #31,r6          ; yes, we have to set it
sm_l1:
	btst    #30,r23         ; was the loop flag set? (filter env)
	jr      EQ,sm_nl        ; no, go on
	nop     
	bset    #30,r6          ; yes, we have to set it

sm_nl:
	jump    (r25)
	store   r6,(r7) 
.endif

fm2mod_on:
.if FMCMPLX_NOTE
	addq    #4*4,r7
	move    r26,r27

	movei   #pitch_op, r8
	load    (r8),r8
	store   r26,(r8)        ; backup pitch

	load    (r7), r23       ; do the pitch stuff
	mult    r23, r26
	shrq    #4,r26

	store   r26,(r7)

	addq    #4*2,r7         ; do the volume stuff
	load    (r7),r26
	mult    r26,r6
	shrq    #8,r6
	store   r6,(r7)

	addq    #4*2,r7
	load    (r7),r23        ; get frequency ratio
	btst    #31,r23
	jr      EQ,t1
	mult    r27,r23
	store   r23,(r7)
t1:
	addq    #4*5,r7
	load    (r7),r23        ; get frequency ratio
	btst    #31,r23
	jr      EQ,t2
	mult    r27,r23
	store   r23,(r7)
t2:
	addq    #4*3,r7
	load    (r7),r23        ; get frequency ratio
	btst    #31,r23
	jr      EQ,t3
	mult    r27,r23
	store   r23,(r7)
t3:
	jump    (r25)
	nop
.endif


fmmod_on:
fmenv_on:

.if FM_NOTE
	addq    #4*8,r7
	load    (r7),r23        ; get frequency ratio
	btst    #31,r23
	jr      EQ,t4
	mult    r26,r23
	store   r23,(r7)
t4:
	movei   #pitch_op, r8
	load    (r8),r8
	store   r26,(r8)        ; backup pitch

	subq    #4*4,r7         ; do the pitch stuff
	load    (r7), r23               
	mult    r23, r26
	shrq    #4,r26
	store   r26,(r7)

	addq    #4*2,r7         ; do volume
	load    (r7),r26

	move    r26,r23         ; save loop flag
	bclr    #31,r26         ; erase loop flag for now
	mult    r26,r6          ; do the multiply with the volume

	shrq    #8,r6

	btst    #31, r23        ; was the loop flag set?
	jr      EQ,fm_nl        ; no, go on
	nop     
	bset    #31,r6          ; yes, we have to set it

fm_nl:
	jump    (r25)
	store   r6,(r7)
.endif
sampmod_on:
samp8mod_on:
sampcmod_on:
sampmod2_on:
sampc2_on:
fcsmp_on:
.if SMPL_NOTE
	addq    #4*3,r7         ; pitch
	movei   #pitch_op, r8
	load    (r8),r8
	store   r26,(r8)        ; backup pitch
	load    (r7), r23
	mult    r23, r26        ; do the pitch
	shrq    #12, r26
	store   r26,(r7)                

	subq    #4*2,r7         ; do the volume
	load    (r7),r26
	move    r26,r23         ; save loop flag
	bclr    #31,r26
	mult    r26,r6          ; mulitply (volume)
	shrq    #8,r6

	btst    #31,r23         ; was loop flag set
	jr      EQ, smpl_nl     ; no, go on
	nop
	bset    #31,r6          ; yes, set it
smpl_nl:
	jump    (r25)
	store   r6,(r7)
.endif

wavemod_on:
.if WAVETAB_NOTE
	movei   #pitch_op, r8
	load    (r8),r8
	store   r26,(r8)        ; backup pitch

	addq    #4*2,r7         ; do pitch
	load    (r7), r23
	mult    r23, r26
	shrq    #4,r26


;;      bset    #31,r26 
	bclr    #31,r26 
	store   r26,(r7)

	subq    #4,r7           ; do volume
	load    (r7),r26
	move    r26,r23
	bclr    #31,r26
	mult    r26,r6
	shrq    #8,r6

	jump    (r25)
	store   r6,(r7)
.endif                          ; end wavetable note on

not_on:

; When we get to this point we have a coded event in r6

	move    r6,r23
	shrq    #29,r23
	jr      NE,sc_jump
	nop
	movei   #note_off,r8
	jump    (r8)
	nop

sc_jump:

; We know that it is not a note off
; At this point we have a coded event in r6
; r23 has the event type
; The voice table address is in r7

	movei   #do_jump,r25
	cmpq    #3,r23
	jump    eq,(r25)
	nop

	movei   #do_con_change,r25
	cmpq    #2,r23
	jump    eq,(r25)
	nop
ptch_change:
	jump    (r25)
	nop

; CONTROLLER CHANGES
; The size of a voice table is in r27
; Just take the voice table address in r7 and add r27-4
; replace this value with the value in the controller field

do_con_change:
	movei   #tmr1_ret,r25   ; return address

	btst    #29, r6         ; are we a JUMP WITH COUNT EVENT??
	movei   #do_jump, r23
	jump    NE, (r23)       ; uupps, we are; so do it
	nop

; *** code for controller changes 
				; coded event is in r6
	move    r6,r26          ; get controller number into r26
	shrq    #15,r26
	moveq   #$1F,r8
	and     r8,r26          ; now we have the controller number
				
	move    r6,r8           ; get patch number
	shlq    #6,r8
	shrq    #27,r8          ; patch number is in r8

	movei   #ctrl_vol, r23
	cmpq    #7, r26         ; is it "volume"?
	jump    eq,(r23)        
	nop
	movei   #ctrl_pan, r23
	cmpq    #10, r26        ; is it "pan"?
	jump    eq,(r23)
	cmpq    #9, r26         ; is it "pitch bend"?
	jr      eq,ctrl_pitch
	nop
	jump    (r25)           ; unknown controller, go back
	nop

; **************************
; * controller is pitch bend
; **************************
ctrl_pitch:
	btst    #20,r6          ; if flag is set we modify the patch table
	movei   #cp_pitch,r23
	jump    nz,(r23)        ; otherwise the voice table
	and     r14,r6          ; now we have the value in r6

;       first, change value in the voice table
				; coded event is in r6
				; patch # is in r8
				; return addr is in r25
				; r7 pts to specified voice table
				; r27 has size of one voice table

	
	load    (r7),r26        ; type of voice

	movei   #pitch_tab,r23
	add     r26,r23
	load    (r23),r8        ; get offset for volume
	add     r8,r7           ; now we know which addr to change

	movei   #pitch_op,r23
	load    (r23),r23       ; get pointer
	load    (r23),r26       ; get current org pitch

	mult    r6,r26          ; multiply by value

	cmpq    #12,r8          ;for samplers (and only those) this is always 12
	jr      nz, p_nosamp
	nop
	shrq    #12,r26         ; samplers get shift by 12
	jr      p_cont
	nop
p_nosamp:
	shrq    #4,r26          ; all others get shifted by 4
p_cont:
	jump    (r25)
	store   r26,(r7)        ; and store it back

;       ***
;       * second, change value in the patch table
;       ***
cp_pitch:
	movei   #PATCHLOC,r7    ; patch pointer
	load    (r7),r7 
	move    r8,r23
	mult    r27,r23         ; get right patch
	add     r23,r7

	movei   #pitch_tab,r23
	load    (r7),r26        ; get type of voice
	add     r26,r23
	load    (r23),r23       ; get offset for pitch
	add     r23,r7          ; now we know which addr to change
	
	jump    (r25)           ; done
	store   r6,(r7)         ; and store new pitch bend back

; *********************** 
; * controller is volume
; ***********************
ctrl_vol:
	btst    #20,r6          ; if flag is set we modify the patch table
	movei   #cp_vol,r23
	jump    nz,(r23)        ; otherwise the voice table
	and     r14,r6          ; now we have the value in r6

;       first, change value in the voice table
				; value is in r6
				; patch # is in r8
				; ptr to vol backup is in r28; do not rely on it
				; return addr is in r25
				; r7 pts to specified voice table
				; r27 has size of one voice table

	load    (r7),r26        ; type of voice

	movei   #vol_tab,r23
	add     r26,r23
	load    (r23),r26       ; get offset for volume
	add     r26,r7          ; now we know which addr to change
	movei   #vol_op, r26
	load    (r26),r26
	load    (r26),r26       ; get current org volume

	move    r26,r23         ; save loop flag
	bclr    #31,r26         ; clear it
	nop

	mult    r6,r26          ; multiply by value
	shrq    #8,r26

	btst    #31,r23         ; was loop flag set?
	jr      EQ, cv1_nl      ; no, go on
	nop
	bset    #31, r26        ; yes, so set it again
cv1_nl:
	jump    (r25)
	store   r26,(r7)        ; and store it back

cp_vol:
;       ***
;       * second, change value in the patch table
;       ***
	movei   #PATCHLOC,r7    ; patch pointer
	load    (r7),r7 
	move    r8,r23
	mult    r27,r23         ; get right patch
	add     r23,r7

	movei   #vol_tab,r23
	load    (r7),r26        ; get type of voice
	add     r26,r23
	load    (r23),r23       ; get offset for volume
	add     r23,r7          ; now we know which addr to change
	
	load    (r7),r23        ; get old volume from patch
	btst    #31,r23         ; was loop flag set?
	jr      EQ, cv2_nl      ; no, go on     
	nop
	bset    #31,r6          ; set loop flag
cv2_nl:
	jump    (r25)           ; done
	store   r6,(r7) ; and store it back

; *********************
; * controller is pan
; *********************
ctrl_pan:
	btst    #20,r6          ; if flag is set we modify the patch table
	jr      nz, cp_pan      ; otherwise the voice table
	and     r14,r6          ; now we have the value in r6

;       first, change value in the voice table
				; value is in r6
	movei   #76,r23         ; it's always the 19. long OK!!!
	add     r23,r7          ; now we know which addr to change

	shlq    #8, r6          ; in steps of 256!!
	subq    #1, r6
	jump    (r25)
	store   r6,(r7)         ; and store it back

cp_pan:
;       second, change value in the patch table
	movei   #PATCHLOC,r7    ; patch pointer
	load    (r7),r7 
	mult    r27,r8          ; get right patch
	add     r8,r7
	movei   #76,r23         ; it's always the 19. long
	add     r23,r7          ; now we know which addr to change

	shlq    #8, r6          ; in steps of 256!!
	subq    #1, r6

	jump    (r25)           ; done
	store   r6,(r7)         ; and store it back

chnge_patch:                    ; do we still need this?????
	nop
	nop
	jump    (r25)
		
do_jump:
; Extract count
	moveq   #$f, r23        ; 16 bits of count only
	and     r6,r23          ; r23 has the count
	jr      EQ,jump_fix
	btst    #28,r6          ; infinite flag means don't decrement
	jr      nz,no_dec       ; so jump over it       
	nop
	subq    #4,r5
	subq    #1,r6           ; decrement count
	store   r6,(r5)         ; and store
	addq    #4,r5
no_dec:
	shlq    #4,r6
	sharq   #12,r6
	shlq    #3,r6
	add     r6,r5

	load    (r5),r4
	jr      jump_done
jump_fix:                       ; copy back up of loop count to loop count
	shrq    #4,r6           ; get backup
	moveq   #$f,r23
	subq    #4,r5           ; get the right place
	and     r6,r23          ; now we have the backup in r23
	shlq    #4,r6
	or      r23,r6          ; now we "or" the backup into loop count
	store   r6,(r5)         ; and store
	addq    #4,r5
jump_done:
	movei   #tmr1_ret,r25
	jump    (r25)
	nop

; Now we figure out how to turn the note off
; Voice table position is in r7
; Now compute the address of the routine to fill in the rest of the stuff       
; This is based on the first number in the voice

note_off:
	load    (r7),r8
	movei   #off_tab,r27
	add     r27,r8
	load    (r8),r8         ; got address of rest of routine

	movei   #tmr1_ret,r25

	jump    (r8)
	nop                     
	

; NOTE THE FOLLOWING CODE HAS ALOT OF DUPLICATION

simpmod_off:
simpmod2_off:
filtmod_off:

.if WAVEFM_NOTE
	addq    #6*4,r7
	load    (r7),r8
	bclr    #31,r8
	store   r8,(r7)
	addq    #4*4,r7
	load    (r7),r8

	subq    #4*2,r7
	jump    (r25)
	store   r8,(r7)
.endif

fmenv_off:
.if FMENV_MOD
	addq    #6*4,r7
	load    (r7),r8
	bclr    #31,r8
	store   r8,(r7)
	addq    #8*4,r7
	addq    #4,r7
	load    (r7),r8

	subq    #3*4,r7         
	jump    (r25)
	store   r8,(r7)
.endif
wavemod_off:
.if WAVETAB_NOTE
	addq    #2*4,r7
	load    (r7),r8
;;      bclr    #31,r8
	bset    #31,r8
	jump    (r25)
	store   r8,(r7)
.endif

sampmod_off:
samp8mod_off:
sampcmod_off:
sampmod2_off:
sampc2_off:
fcsmp_off:
.if SMPL_NOTE
	addq    #1*4,r7
	load    (r7),r8
	bclr    #31,r8
	store   r8,(r7)
	addq    #4*7,r7
	load    (r7),r8

	subq    #4*4,r7
	jump    (r25)
	store   r8,(r7)
.endif

fm2mod_off:
fmmod_off:
; implied jump (r25)
	store   r15,(r7)        ; Turn note off

tmr1_ret:
; ************************************************************ EXTRA DEBUGGING
;       movei   #inin,r27
;       jump    (r27)           ; and return
;       nop
; ************************************************************ EXTRA DEBUGGING 
	store   r4,(r16)
	store   r5,(r17)
	move    r20,r7                  ; get flags ptr
	load    (r31),r27               ; get last instruction address
	bclr    #3,r22                  ; Clear IMASK
	bset    #6,r22                  ; reallow this interrupt
	bset    #14,r22                 ; Use bank 1!!!!!
	addq    #2,r27                  ; point at next to be executed
	addq    #4,r31                  ; update the stack pointer
	jump    (r27)                   ; and return
	store   r22,(r7)                ; restore flags

;______________________________________________________________________________
; end of real program 
;_____________________________________________________________________________

	LONG                    ; align long

parameters:
SEMAPHORE:
	dc.l    1              ; used to signal next sample tick


; Table for note on events
	dc.l    tmr1_ret
on_tab:
	dc.l    0               ; Dummy to make the code work better
	dc.l    fmenv_on
	dc.l    fmmod_on
	dc.l    sampmod_on
	dc.l    fm2mod_on
	dc.l    wavemod_on
	dc.l    simpmod_on
	dc.l    samp8mod_on
	dc.l    sampcmod_on
	dc.l    simpmod2_on
	dc.l    sampmod2_on
	dc.l    sampc2_on
	dc.l    fcsmp_on
	;______________________________________________________________________________
; Table for note off events
	dc.l    fmmod_off
off_tab:
	dc.l    0               ; Dummy to make the code work better
	dc.l    fmenv_off
	dc.l    fmmod_off
	dc.l    sampmod_off
	dc.l    fm2mod_off
	dc.l    wavemod_off
	dc.l    simpmod_off
	dc.l    samp8mod_off
	dc.l    sampcmod_off
	dc.l    simpmod2_off
	dc.l    sampmod2_off
	dc.l    sampc2_off
	dc.l    fcsmp_off

	;______________________________________________________________________________

buffstart:
	dc.l    0       ; 1
	dc.l    0       ; 2
	dc.l    0       ; 3
	dc.l    0       ; 4
	dc.l    0       ; 5
	dc.l    0       ; 6
	dc.l    0       ; 7
	dc.l    0       ; 8
	dc.l    0       ; 9
	dc.l    0       ; 10
	dc.l    0       ; 11
	dc.l    0       ; 12
	dc.l    0       ; 13
	dc.l    0       ; 14
	dc.l    0       ; 15
	dc.l    0       ; 16

vol_tab:                ; offset to find the address to be modified (volume)
	dc.l    0
	dc.l    24      ; fm/env
	dc.l    24      ; fm simple
	dc.l    4       ; 16 bit sampler
	dc.l    24      ; fm complex
	dc.l    4       ; wave table
	dc.l    24      ; wave form
	dc.l    4       ; 8 bit sample
	dc.l    4       ; compressed sampler 
	dc.l    24      ; simpmod 2
	dc.l    4       ; 16 bit sampler 2
	dc.l    4       ; compressed 16 bit sampler 2
	dc.l    4       ; fast compressed 16 bit sampler 
	dc.l    24      ; fm filter

vol_orgs:               ; backup of the voice's volume
	dc.l    0
	dc.l    0
	dc.l    0
	dc.l    0
	dc.l    0
	dc.l    0
	dc.l    0
	dc.l    0
	dc.l    0
	dc.l    0
	dc.l    0
	dc.l    0
	dc.l    0
	dc.l    0
	dc.l    0
	dc.l    0


vol_op:
	dc.l    0       ; pointer to the volume backup which we're modifying

pitch_tab:              ; offset to find the address to be modified (pitch)
	dc.l    0
	dc.l    16      ; fm/env
	dc.l    16      ; fm simple
	dc.l    12      ; 16 bit sampler
	dc.l    16      ; fm complex
	dc.l    8       ; wave table
	dc.l    16      ; wave form
	dc.l    12      ; 8 bit sample
	dc.l    12      ; compressed sampler 
	dc.l    16      ; simpmod2
	dc.l    12      ; 16 bit sampler 2
	dc.l    12      ; compressed 16 bit sampler 2
	dc.l    12      ; fast 16 bit sampler
	dc.l    16      ; fm filter

pitch_orgs:             ; backup of the voice's pitch
	dc.l    0
	dc.l    0
	dc.l    0
	dc.l    0
	dc.l    0
	dc.l    0
	dc.l    0
	dc.l    0
	dc.l    0
	dc.l    0
	dc.l    0
	dc.l    0
	dc.l    0
	dc.l    0
	dc.l    0
	dc.l    0
pitch_op:               ; pointer to the pitch backup which we're modifying
	dc.l    0



UEBERVOLUME:                            ; overall volume
	dc.l    0

SCORE_ADD:
	dc.l    0
TIMER_ADD:
	dc.l    0
PATCHLOC:
	dc.l    0 

	dc.l    nexttab
MODULETABLE:
	dc.l    endlist         ; 0
.if FMENV_MOD
	dc.l    fmenv           ; 4
.else
	dc.l    0
.endif
.if FMSIMPLE_MOD
	dc.l    fmmod           ; 8
.else
	dc.l    0
.endif
.if SMPL16_MOD
	dc.l    sampmod         ; 12
.else
	dc.l    0
.endif
.if FMCMPLX_MOD
	dc.l    fm2mod          ; 16
.else
	dc.l    0
.endif
.if WAVETAB_MOD
	dc.l    wave2mod        ; 20
.else
	dc.l    0
.endif
.if WAVEFM_MOD
	dc.l    simpmod         ; 24
.else
	dc.l    0
.endif
.if SMPL8_MOD
	dc.l    samp8mod        ; 28
.else
	dc.l    0
.endif
.if CSMPL16_MOD
	dc.l    csampmod        ; 32 this is for the compressed sampler
.else
	dc.l    0
.endif
.if WAVEFM2_MOD
	dc.l    simpmod2        ; 36
.else
	dc.l    0
.endif
.if SMPLENV_MOD
	dc.l    sampmod2        ; 40
.else
	dc.l    0
.endif
.if CSMPLENV_MOD
	dc.l    sampc2mod       ; 44 compressed 16 bit sampler 2
.else
	dc.l    0
.endif
.if FCSMP_MOD
	dc.l    fcsmpmod        ; 48 fast compressed 16 bit sampler
.else
	dc.l    0
.endif

; Note these are effects!

;       dc.l    reverb
;       dc.l    echo
;       dc.l    flange
;       dc.l    ring
;       dc.l    chorus

	.phrase

;______________________________________________________________________________

SYNTHEND:
FULSYN_E::
	.end
