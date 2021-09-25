		.include	'skunk.inc'

		.extern _skunkRESET
		.extern _skunkNOP
		.extern _skunkCONSOLEWRITE
		.extern _skunkCONSOLECLOSE
		.extern _skunkCONSOLEREAD
		.extern _skunkFILEOPEN
		.extern _skunkFILEWRITE
		.extern _skunkFILEREAD
		.extern _skunkFILECLOSE

.text

_skunkRESET:
		jsr	skunkRESET
		rts

_skunkNOP:
		jsr	skunkNOP
		rts

_skunkCONSOLEWRITE:
		move.l	4(sp), a0
		jsr	skunkCONSOLEWRITE
		rts

_skunkCONSOLECLOSE:
		jsr	skunkCONSOLECLOSE
		rts

_skunkCONSOLEREAD:
		move.l	8(sp),d0
		move.l	4(sp),a0
		jsr	skunkCONSOLEREAD
		rts

_skunkFILEOPEN:
		move.l	8(sp),d0
		move.l	4(sp),a0
		jsr	skunkFILEOPEN
		rts

_skunkFILEWRITE:
		move.l	8(sp),d0
		move.l	4(sp),a0
		jsr	skunkFILEWRITE
		rts

_skunkFILEREAD:
		move.l	8(sp),d0
		move.l	4(sp),a0
		jsr	skunkFILEREAD
		rts

_skunkFILECLOSE:
		jsr	skunkFILECLOSE
		rts
