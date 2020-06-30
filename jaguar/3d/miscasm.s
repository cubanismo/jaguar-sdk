;
; miscellaneous assembly language stuff
; 
	.include	'jaguar.inc'

	.globl	_DISPBUF0
	.globl	_DISPBUF1
	.globl	DISPBUF0
	.globl	DISPBUF1

	.bss
DISPBUF0:
_DISPBUF0:
	.ds.w	4
DISPBUF1:
_DISPBUF1:
	.ds.w	3*320*240


; space for passing parameters

	.long
	.globl	_params
_params:
	.ds.l	32

; ram buffer for Gouraud shaded texture mapping;
; use this if the CLUT is unavailable

	.globl	_rambuf
	.phrase
_rambuf:
	.ds.w	324


;
; array for holding profiling information
; not currently used
;
	.globl	_proftime
	.long
_proftime:
	.ds.l	32

	.data
	.phrase
;
; checkerboard pattern
;
	.phrase
	.globl	_chkbrd
_chkbrd:
	.dc.w	8,8
	.dc.l	WID8|PIXEL16
	dc.w	$7820,$78c0,$7820,$78c0,$7820,$78c0,$7820,$78c0
	dc.w	$78c0,$7820,$78c0,$7820,$78c0,$7820,$78c0,$7820
	dc.w	$7820,$78c0,$7820,$78c0,$7820,$78c0,$7820,$78c0
	dc.w	$78c0,$7820,$78c0,$7820,$78c0,$7820,$78c0,$7820
	dc.w	$7820,$78c0,$7820,$78c0,$7820,$78c0,$7820,$78c0
	dc.w	$78c0,$7820,$78c0,$7820,$78c0,$7820,$78c0,$7820
	dc.w	$7820,$78c0,$7820,$78c0,$7820,$78c0,$7820,$78c0
	dc.w	$78c0,$7820,$78c0,$7820,$78c0,$7820,$78c0,$7820

;
; alternating colored squares
;
	.phrase
	.globl	_squares
; 8x8 checkered flag pattern
_squares:
	.dc.w	8,8
	.dc.l	WID8|PIXEL16
	dc.w	$f080,$7f80,$f080,$7f80,$f080,$7f80,$f080,$7f80
	dc.w	$7f80,$f080,$7f80,$f080,$7f80,$f080,$7f80,$f080
	dc.w	$f080,$7f80,$f080,$7f80,$f080,$7f80,$f080,$7f80
	dc.w	$7f80,$f080,$7f80,$f080,$7f80,$f080,$7f80,$f080
	dc.w	$f080,$7f80,$f080,$7f80,$f080,$7f80,$f080,$7f80
	dc.w	$7f80,$f080,$7f80,$f080,$7f80,$f080,$7f80,$f080
	dc.w	$f080,$7f80,$f080,$7f80,$f080,$7f80,$f080,$7f80
	dc.w	$7f80,$f080,$7f80,$f080,$7f80,$f080,$7f80,$f080
