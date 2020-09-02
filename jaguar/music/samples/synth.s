;----------------------------------------------------------------------------
; This is a simple sample program to play a tune on the synth code.
;
; MODULE: SYNTH DATA FILE
; DESCR:  THIS FILE CONTAINS THE PATCHES, SAMPLES, ENVELOPES, USER WAVEFORMS
;	  AND AN INITIALIZED VOICE TABLE.
;
;	  COPYRIGHT 1992,1993,1994 Atari U.S. Corporation           	     
;									      
;         UNATHORIZED REPRODUCTION, ADAPTATION, DISTRIBUTION,               
;         PERFORMANCE OR DISPLAY OF THIS COMPUTER PROGRAM OR               
;         THE ASSOCIATED AUDIOVISUAL WORK IS STRICTLY PROHIBITED.          
;         ALL RIGHTS RESERVED.
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
; 	INCLUDE FILES
;----------------------------------------------------------------------------
	.include	'jaguar.inc'
	.include	'fulsyn.inc'
	.include	'synth.cnf'
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; 	DATA SECTION
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	.data
	.even
;****************************************************************************
;**                        EDIT AFTER THIS POINT                           **
;****************************************************************************
	
;---------------------------------------------------------------------------
;	PATCHES
;---------------------------------------------------------------------------
;	Recommended name convention for samples, envelopes & user waveforms
;	in patch files:
;		sample:		s_patchname
;	 	envelopes:	e_patchname
;	 	user waveform:	u_patchname
;
;	NOTE: If you have set your assembler to output DRI (default) instead 
;	      of BSD format, only the first eight characters of a label are
;	      recognized! So 'e_string' and 'e_string1' are the same label.
;

patches::
	dc.w	14			; NUMBER OF PATCHES 
					; Always update this count if you add
					; or delete patches!

kick1:
	.include 'patches/kick.jaf'
	
snare1:
	.include 'patches/snare.jaf'
	
chh:
	.include 'patches/chh.jaf'

toms:
	.include 'patches/toms.jaf'

pbass1:
	.include 'patches/resbass1.jaf'

bassL:
	.include 'patches/sawblipl.jaf'
	
bassR:
	.include 'patches/sawblipr.jaf'
	
stix:
	.include 'patches/stix.jaf'

slap:
	.include 'patches/slap.jaf'

kick2:
	.include 'patches/kick2.jaf'

snare2:
	.include 'patches/snare2.jaf'

mgun:
	.include 'patches/mgun.jaf'

step:
	.include 'patches/step.jaf'

stepr:
	.include 'patches/stepr.jaf'

	
;---------------------------------------------------------------------------
;	SAMPLES - Since samples are binary files, use the '.incbin' command!
;---------------------------------------------------------------------------

.even	
s_kick:
.even
	.incbin 'patches/kick.cmp'

.even
s_snare:
.even
	.incbin 'patches/snare.cmp'

.even
s_chh:
.even
	.incbin 'patches/chh.cmp'

.even
s_toms:
.even
	.incbin 'patches/toms.cmp'
	
.even
s_stix:
.even
	.incbin 'patches/stix.cmp'

.even
s_slap:
.even
	.incbin 'patches/slap.cmp'

.even
s_kick2:
.even
	.incbin 'patches/kick2.cmp'
	
.even
s_snare2:
.even
	.incbin 'patches/snare2.cmp'

.even
s_mgun:
.even
	.incbin 'patches/mgun.cmp'

.even
s_step:
.even
	.incbin 'patches/step.cmp'

.even
s_stepr:
.even
	.incbin 'patches/stepr.cmp'

.even
s_sawblipl:
.even
	.incbin 'patches/sawblipl.cmp'
	
.even
s_sawblipr:
.even
	.incbin 'patches/sawblipr.cmp'
	
.even
s_resbass1:
.even
	.incbin 'patches/resbass1.cmp'

	.even
;---------------------------------------------------------------------------
;                       +++ START OF DSP SECTION +++
;---------------------------------------------------------------------------
	.DSP

TABS_COPY::
	dc.l	TABSSTART			; DO NOT EDIT THIS LABEL
	dc.l	TABSEND - TABSSTART		; DO NOT EDIT THIS LABEL

;---------------------------------------------------------------------------
;	INITALIZED VOICETABLE
;	A zero in the first field tells FULSYN that this is the last voice
;	to be used!
;---------------------------------------------------------------------------
	.ORG	tablestart

TABSSTART::					; DO NOT EDIT THIS LABEL
	dc.l	-4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0  ; voice 0
	dc.l	-4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0  ; voice 1
	dc.l	-4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0  ; voice 2
	dc.l	-4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0  ; voice 3
	dc.l	-4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0  ; voice 4
	dc.l	-4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0  ; voice 5
	dc.l	-4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0  ; voice 6
	dc.l	 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0  ; voice 7-LAST VOICE
	dc.l	-4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0  ; voice 8
	dc.l	-4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0  ; voice 9
	dc.l	-4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0  ; voice 10
	dc.l	-4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0  ; voice 11
	dc.l	 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

;---------------------------------------------------------------------------
;	USER WAVEFORMS - With the above voice table it's asured that they
;                        start on 512 byte boundary!
;---------------------------------------------------------------------------
	
;---------------------------------------------------------------------------
;	ENVELOPES
;---------------------------------------------------------------------------

;****************************************************************************
;**                        EDIT UP TO THIS POINT                           **
;****************************************************************************

; have slop for sloppy loader
	.dc.l	0,0
TABSEND::					; DO NOT EDIT THIS LABEL
	.dc.l	0
	.end
;____________________________________EOF____________________________________


