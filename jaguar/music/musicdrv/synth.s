;----------------------------------------------------------------------------
; This is a simple sample program to play a tune on the synth code.
;
; MODULE: SYNTH DATA FILE
; DESCR:  THIS FILE CONTAINS THE PATCHES, SAMPLES, ENVELOPES, USER WAVEFORMS
;	  AND AN INITIALIZED VOICE TABLE.
;
;	  COPYRIGHT 1992,1993,1994 Atari U.S. Corporation           	     
;									      
;         UNAUTHORIZED REPRODUCTION, ADAPTATION, DISTRIBUTION,               
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
	dc.w	1			; NUMBER OF PATCHES 
					; Always update this count if you add
					; or delete patches!

; Patch 0           
	.include 'patches/strlow.jaf'	; strlow patch
					; uses 's_strlow' sample
					; and  'e_strlow' envelope

	.even
;---------------------------------------------------------------------------
;	SAMPLES - Since samples are binary files, use the '.incbin' command!
;---------------------------------------------------------------------------

s_strlow:
	.even
	.incbin	'patches/strlow.cmp' ; string sample used in patch 0
				
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

e_strlow:
	.include "patches/strlow.env"	; envelope used in patch 0



;****************************************************************************
;**                        EDIT UP TO THIS POINT                           **
;****************************************************************************

; have slop for sloppy loader
	.dc.l	0,0
TABSEND::					; DO NOT EDIT THIS LABEL
	.dc.l	0
	.end
;____________________________________EOF____________________________________


