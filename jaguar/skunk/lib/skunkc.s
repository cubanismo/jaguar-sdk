		.include	'skunk.inc'

		.extern _skunkRESET
		.extern _skunkNOP
		.extern _skunkCONSOLEWRITE
		.extern _skunkCONSOLECLOSE
		.extern _skunkCONSOLESETUPREAD
		.extern _skunkCONSOLECHECKREAD
		.extern _skunkCONSOLEFINISHREAD
		.extern _skunkCONSOLEREAD
		.extern _skunkFILEOPEN
		.extern _skunkFILEWRITE
		.extern _skunkFILEREAD
		.extern _skunkFILECLOSE

.text

_skunkRESET:
		jmp	skunkRESET

_skunkNOP:
		jmp	skunkNOP

_skunkCONSOLEWRITE:
		move.l	4(sp), a0
		jmp	skunkCONSOLEWRITE

_skunkCONSOLECLOSE:
		jmp	skunkCONSOLECLOSE

_skunkCONSOLESETUPREAD:
		jmp	skunkCONSOLESETUPREAD

_skunkCONSOLECHECKREAD:
		jmp	skunkCONSOLECHECKREAD

_skunkCONSOLEFINISHREAD:
		move.l	8(sp),d0
		move.l	4(sp),a0
		jmp	skunkCONSOLEFINISHREAD

_skunkCONSOLEREAD:
		move.l	8(sp),d0
		move.l	4(sp),a0
		jmp	skunkCONSOLEREAD

_skunkFILEOPEN:
		move.l	8(sp),d0
		move.l	4(sp),a0
		jsr	skunkFILEOPEN
		rts

_skunkFILEWRITE:
		move.l	8(sp),d0
		move.l	4(sp),a0
		jmp	skunkFILEWRITE

_skunkFILEREAD:
		move.l	8(sp),d0
		move.l	4(sp),a0
		jmp	skunkFILEREAD

_skunkFILECLOSE:
		jmp	skunkFILECLOSE
