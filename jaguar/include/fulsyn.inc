;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; FULSYN.INC - Copyright (c)1994 Atari Corp.
;;              All Rights Reserved
;;
;; UNAUTHORIZED REPRODUCTION, ADAPTATION, DISTRIBUTION,
;; PERFORMANCE OR DISPLAY OF THIS COMPUTER PROGRAM OR
;; THE ASSOCIATED AUDIOVISUAL WORK IS STRICTLY PROHIBITED.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Tables are positioned every 80 bytes. The first long word of an entry is
;always the module type. A module type of zero indicates the end of the list.
;A module type of -4 is skipped.

tablestart	EQU     D_RAM+$c00	; THE voice table
taboff         EQU	20*4

; Patchtable RAM location

PATCHTAB	EQU	$40000		; replace by PATCHPTR
					; here are the patches
; Stack Pointer

STACKPOS	EQU     D_RAM+16

; Effects

EFFBUFF        EQU     $401000		; Used when there are effects
BUFFLEN        EQU     $ffff		; Used when there are effects


