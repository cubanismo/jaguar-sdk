	.globl	_sin, _cos
	.globl	sin,cos
;
; trig.s - defines functions sin() and cos()
;	arg passed in d0 in units of PI/1024 - no range limits
;	result returned in d0
;	d1, a0 are munged

	.text

_cos:
	move.w	4(sp),d0
cos:
	add.w	#512, d0
	bra.b	sin
_sin:
	move.w	4(sp),d0
sin:
	move.w	d0, d1	; keep quadrant data in d1
	and.w	#511, d0	; strip quadrant data in d0
	btst		#9, d1
	beq		fine
		neg.w	d0
		add.w	#512, d0
fine:
	move.l	#sn, a0		; LUT base address
	asl.w	#1, d0		; word offset
	move.w	(a0, d0.w), d0
	btst		#10, d1
	beq		fine2
		neg.l	d0
fine2:
	rts

; Quarter-wave sin table
sn:
	dc.w  $0000, $0032, $0064, $0096, $00c9, $00fb, $012d, $015f
	dc.w  $0192, $01c4, $01f6, $0228, $025b, $028d, $02bf, $02f1
	dc.w  $0323, $0356, $0388, $03ba, $03ec, $041e, $0451, $0483
	dc.w  $04b5, $04e7, $0519, $054b, $057d, $05af, $05e1, $0613
	dc.w  $0645, $0677, $06a9, $06db, $070d, $073f, $0771, $07a3
	dc.w  $07d5, $0807, $0839, $086b, $089c, $08ce, $0900, $0932
	dc.w  $0964, $0995, $09c7, $09f9, $0a2a, $0a5c, $0a8d, $0abf
	dc.w  $0af1, $0b22, $0b54, $0b85, $0bb6, $0be8, $0c19, $0c4b
	dc.w  $0c7c, $0cad, $0cde, $0d10, $0d41, $0d72, $0da3, $0dd4
	dc.w  $0e05, $0e36, $0e67, $0e98, $0ec9, $0efa, $0f2b, $0f5c
	dc.w  $0f8c, $0fbd, $0fee, $101f, $104f, $1080, $10b0, $10e1
	dc.w  $1111, $1142, $1172, $11a2, $11d3, $1203, $1233, $1263
	dc.w  $1294, $12c4, $12f4, $1324, $1354, $1383, $13b3, $13e3
	dc.w  $1413, $1443, $1472, $14a2, $14d1, $1501, $1530, $1560
	dc.w  $158f, $15be, $15ee, $161d, $164c, $167b, $16aa, $16d9
	dc.w  $1708, $1737, $1766, $1794, $17c3, $17f2, $1820, $184f
	dc.w  $187d, $18ac, $18da, $1908, $1937, $1965, $1993, $19c1
	dc.w  $19ef, $1a1d, $1a4b, $1a79, $1aa6, $1ad4, $1b02, $1b2f
	dc.w  $1b5d, $1b8a, $1bb7, $1be5, $1c12, $1c3f, $1c6c, $1c99
	dc.w  $1cc6, $1cf3, $1d20, $1d4c, $1d79, $1da6, $1dd2, $1dfe
	dc.w  $1e2b, $1e57, $1e83, $1eb0, $1edc, $1f08, $1f34, $1f5f
	dc.w  $1f8b, $1fb7, $1fe2, $200e, $2039, $2065, $2090, $20bb
	dc.w  $20e7, $2112, $213d, $2168, $2192, $21bd, $21e8, $2212
	dc.w  $223d, $2267, $2292, $22bc, $22e6, $2310, $233a, $2364
	dc.w  $238e, $23b8, $23e1, $240b, $2434, $245e, $2487, $24b0
	dc.w  $24da, $2503, $252c, $2554, $257d, $25a6, $25cf, $25f7
	dc.w  $261f, $2648, $2670, $2698, $26c0, $26e8, $2710, $2738
	dc.w  $275f, $2787, $27af, $27d6, $27fd, $2824, $284b, $2872
	dc.w  $2899, $28c0, $28e7, $290e, $2934, $295a, $2981, $29a7
	dc.w  $29cd, $29f3, $2a19, $2a3f, $2a65, $2a8a, $2ab0, $2ad5
	dc.w  $2afa, $2b20, $2b45, $2b6a, $2b8e, $2bb3, $2bd8, $2bfc
	dc.w  $2c21, $2c45, $2c6a, $2c8e, $2cb2, $2cd6, $2cf9, $2d1d
	dc.w  $2d41, $2d64, $2d88, $2dab, $2dce, $2df1, $2e14, $2e37
	dc.w  $2e5a, $2e7c, $2e9f, $2ec1, $2ee3, $2f05, $2f28, $2f49
	dc.w  $2f6b, $2f8d, $2faf, $2fd0, $2ff1, $3013, $3034, $3055
	dc.w  $3076, $3096, $30b7, $30d8, $30f8, $3118, $3138, $3159
	dc.w  $3179, $3198, $31b8, $31d8, $31f7, $3216, $3236, $3255
	dc.w  $3274, $3293, $32b1, $32d0, $32ee, $330d, $332b, $3349
	dc.w  $3367, $3385, $33a3, $33c1, $33de, $33fb, $3419, $3436
	dc.w  $3453, $3470, $348c, $34a9, $34c6, $34e2, $34fe, $351a
	dc.w  $3536, $3552, $356e, $3589, $35a5, $35c0, $35dc, $35f7
	dc.w  $3612, $362c, $3647, $3662, $367c, $3696, $36b1, $36cb
	dc.w  $36e5, $36fe, $3718, $3731, $374b, $3764, $377d, $3796
	dc.w  $37af, $37c8, $37e0, $37f9, $3811, $3829, $3841, $3859
	dc.w  $3871, $3889, $38a0, $38b7, $38cf, $38e6, $38fd, $3913
	dc.w  $392a, $3941, $3957, $396d, $3983, $3999, $39af, $39c5
	dc.w  $39da, $39f0, $3a05, $3a1a, $3a2f, $3a44, $3a59, $3a6d
	dc.w  $3a82, $3a96, $3aaa, $3abe, $3ad2, $3ae6, $3afa, $3b0d
	dc.w  $3b20, $3b34, $3b47, $3b59, $3b6c, $3b7f, $3b91, $3ba3
	dc.w  $3bb6, $3bc8, $3bda, $3beb, $3bfd, $3c0e, $3c20, $3c31
	dc.w  $3c42, $3c53, $3c63, $3c74, $3c84, $3c95, $3ca5, $3cb5
	dc.w  $3cc5, $3cd4, $3ce4, $3cf3, $3d02, $3d12, $3d21, $3d2f
	dc.w  $3d3e, $3d4d, $3d5b, $3d69, $3d77, $3d85, $3d93, $3da1
	dc.w  $3dae, $3dbb, $3dc9, $3dd6, $3de2, $3def, $3dfc, $3e08
	dc.w  $3e14, $3e21, $3e2d, $3e38, $3e44, $3e50, $3e5b, $3e66
	dc.w  $3e71, $3e7c, $3e87, $3e92, $3e9c, $3ea7, $3eb1, $3ebb
	dc.w  $3ec5, $3ece, $3ed8, $3ee1, $3eeb, $3ef4, $3efd, $3f06
	dc.w  $3f0e, $3f17, $3f1f, $3f27, $3f2f, $3f37, $3f3f, $3f47
	dc.w  $3f4e, $3f55, $3f5d, $3f64, $3f6a, $3f71, $3f78, $3f7e
	dc.w  $3f84, $3f8a, $3f90, $3f96, $3f9c, $3fa1, $3fa6, $3fac
	dc.w  $3fb1, $3fb5, $3fba, $3fbf, $3fc3, $3fc7, $3fcb, $3fcf
	dc.w  $3fd3, $3fd7, $3fda, $3fde, $3fe1, $3fe4, $3fe7, $3fe9
	dc.w  $3fec, $3fee, $3ff0, $3ff2, $3ff4, $3ff6, $3ff8, $3ff9
	dc.w  $3ffb, $3ffc, $3ffd, $3ffe, $3ffe, $3fff, $3fff, $3fff
	dc.w  $4000, $4000

