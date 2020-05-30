;
; clock():	returns time elapsed
;		(in system clock ticks)
; WARNING WARNING WARNING
; PIT0 is in fact a write only register.
; It happens to be readable on current
; Jaguar consoles, but this *will not*
; be the case on some future machines
; DO NOT USE THIS FUNCTION FOR GAMES.
; USE IT ONLY FOR DEBUGGING
; WARNING WARNING WARNING
;
	.include "jaguar.inc"

_clock::
	move.l	PIT0,d0
	swap.w	d0
	neg.l	d0
	rts
