;______________________________________________________________________________;
;	FULSYN.INC
;______________________________________________________________________________

;Tables are positioned every 80 bytes. The first long word of an entry is
;always the module type. A module type of zero indicates the end of the list.
;A module type of -4 is skipped.

tablestart	equ     D_RAM+$c00		; THE voice table
taboff          equ     20*4

; Patchtable RAM location
PATCHTAB	equ	$40000			; replace by PATCHPTR
						; here are the patches
; Stack Pointer
STACKPOS	equ     D_RAM+16

; Effects
EFFBUFF         equ     $401000			; Used when there are effects
BUFFLEN         equ     $ffff			; Used when there are effects
