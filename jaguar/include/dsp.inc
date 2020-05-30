;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Header File: DSP.INC
;              Jaguar DSP Equates
;
; NOTICE: This file has been incorporated into JAGUAR.INC. This file
;         is for compatibility reasons only.
;
	
	.include        "jaguar.inc"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; WARNING!!! The following EQU's exist here for compatibility only.
;;; Do not use them. There are more EQUs with better names in JAGUAR.INC
;;; These EQUs - Including this whole include file will go away in the next
;;; release
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		IF      COMPAT

INT_ENA5        EQU     $00010000       ; d16:     DSP interrupt enable
INT_CLR5        EQU     $00020000       ; d17:     DSP interrupt disable

		ENDIF
