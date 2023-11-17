	MACRO	_RTS
	load	(ST),TMP
	jump	T,(TMP)
	addqt	#4,ST		;rts
	ENDM

	.GPU
ST	.REGEQU	r31
TMP	.REGEQU	r29
