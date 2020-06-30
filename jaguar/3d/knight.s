;*========================================
; 3D Library Data File
;*========================================


	.include	'jaguar.inc'

	.data
	.globl	_knightdata
_knightdata:
._default_data:
	dc.w	165		;Number of faces
	dc.w	148		;Number of points
	dc.w	8		;Number of materials
	dc.w	0		; reserved word
	dc.l	.facelist_default
	dc.l	.vertlist_default
	dc.l	.matlist
	.phrase
.facelist_default:
;* Face 0
	dc.w	$173,$807,$c086,$ffe3	; face normal
	dc.w	3		; number of points
	dc.w	4		; material BLUE MARBLE
	dc.w	3, $0000	; Point index, texture coordinates
	dc.w	1, $00ff	; Point index, texture coordinates
	dc.w	2, $ff00	; Point index, texture coordinates

;* Face 1
	dc.w	$d2dd,$807,$d358,$ffe1	; face normal
	dc.w	3		; number of points
	dc.w	4		; material BLUE MARBLE
	dc.w	1, $0000	; Point index, texture coordinates
	dc.w	9, $00ff	; Point index, texture coordinates
	dc.w	0, $ff00	; Point index, texture coordinates

;* Face 2
	dc.w	$d17b,$0,$d40c,$ffd6	; face normal
	dc.w	3		; number of points
	dc.w	4		; material BLUE MARBLE
	dc.w	1, $0000	; Point index, texture coordinates
	dc.w	8, $00ff	; Point index, texture coordinates
	dc.w	9, $ff00	; Point index, texture coordinates

;* Face 3
	dc.w	$d27a,$1ee,$d30f,$ffd9	; face normal
	dc.w	3		; number of points
	dc.w	4		; material BLUE MARBLE
	dc.w	1, $0000	; Point index, texture coordinates
	dc.w	7, $00ff	; Point index, texture coordinates
	dc.w	8, $ff00	; Point index, texture coordinates

;* Face 4
	dc.w	$cf72,$0,$d64e,$ffd7	; face normal
	dc.w	3		; number of points
	dc.w	4		; material BLUE MARBLE
	dc.w	1, $0000	; Point index, texture coordinates
	dc.w	6, $00ff	; Point index, texture coordinates
	dc.w	7, $ff00	; Point index, texture coordinates

;* Face 5
	dc.w	$c7b,$c16f,$faf5,$ffac	; face normal
	dc.w	4		; number of points
	dc.w	1		; material DARK GRAY LUSTER
	dc.w	0, $0000	; Point index, texture coordinates
	dc.w	10, $00ff	; Point index, texture coordinates
	dc.w	11, $ff00	; Point index, texture coordinates
	dc.w	1, $ffff	; Point index, texture coordinates

;* Face 6
	dc.w	$f385,$c16f,$50b,$ffaa	; face normal
	dc.w	4		; number of points
	dc.w	1		; material DARK GRAY LUSTER
	dc.w	1, $0000	; Point index, texture coordinates
	dc.w	11, $00ff	; Point index, texture coordinates
	dc.w	12, $ff00	; Point index, texture coordinates
	dc.w	2, $ffff	; Point index, texture coordinates

;* Face 7
	dc.w	$3b57,$0,$e806,$ff9f	; face normal
	dc.w	4		; number of points
	dc.w	1		; material DARK GRAY LUSTER
	dc.w	3, $0000	; Point index, texture coordinates
	dc.w	20, $00ff	; Point index, texture coordinates
	dc.w	14, $ff00	; Point index, texture coordinates
	dc.w	4, $ffff	; Point index, texture coordinates

;* Face 8
	dc.w	$2c7f,$2a57,$ee06,$ffbc	; face normal
	dc.w	4		; number of points
	dc.w	1		; material DARK GRAY LUSTER
	dc.w	4, $0000	; Point index, texture coordinates
	dc.w	14, $00ff	; Point index, texture coordinates
	dc.w	15, $ff00	; Point index, texture coordinates
	dc.w	5, $ffff	; Point index, texture coordinates

;* Face 9
	dc.w	$e250,$376a,$bff,$ffef	; face normal
	dc.w	4		; number of points
	dc.w	1		; material DARK GRAY LUSTER
	dc.w	5, $0000	; Point index, texture coordinates
	dc.w	15, $00ff	; Point index, texture coordinates
	dc.w	16, $ff00	; Point index, texture coordinates
	dc.w	6, $ffff	; Point index, texture coordinates

;* Face 10
	dc.w	$1db0,$376a,$f401,$fff2	; face normal
	dc.w	4		; number of points
	dc.w	1		; material DARK GRAY LUSTER
	dc.w	6, $0000	; Point index, texture coordinates
	dc.w	16, $00ff	; Point index, texture coordinates
	dc.w	17, $ff00	; Point index, texture coordinates
	dc.w	7, $ffff	; Point index, texture coordinates

;* Face 11
	dc.w	$d381,$2a57,$11fa,$ffb8	; face normal
	dc.w	4		; number of points
	dc.w	1		; material DARK GRAY LUSTER
	dc.w	7, $0000	; Point index, texture coordinates
	dc.w	17, $00ff	; Point index, texture coordinates
	dc.w	18, $ff00	; Point index, texture coordinates
	dc.w	8, $ffff	; Point index, texture coordinates

;* Face 12
	dc.w	$c4a9,$0,$17fa,$ff99	; face normal
	dc.w	4		; number of points
	dc.w	1		; material DARK GRAY LUSTER
	dc.w	8, $0000	; Point index, texture coordinates
	dc.w	18, $00ff	; Point index, texture coordinates
	dc.w	19, $ff00	; Point index, texture coordinates
	dc.w	21, $ffff	; Point index, texture coordinates

;* Face 13
	dc.w	$2d23,$807,$2ca8,$ffa9	; face normal
	dc.w	3		; number of points
	dc.w	1		; material DARK GRAY LUSTER
	dc.w	11, $0000	; Point index, texture coordinates
	dc.w	13, $00ff	; Point index, texture coordinates
	dc.w	12, $ff00	; Point index, texture coordinates

;* Face 14
	dc.w	$fe8d,$807,$3f7a,$ffa6	; face normal
	dc.w	3		; number of points
	dc.w	1		; material DARK GRAY LUSTER
	dc.w	19, $0000	; Point index, texture coordinates
	dc.w	11, $00ff	; Point index, texture coordinates
	dc.w	10, $ff00	; Point index, texture coordinates

;* Face 15
	dc.w	$fd12,$0,$3fef,$ff9c	; face normal
	dc.w	3		; number of points
	dc.w	1		; material DARK GRAY LUSTER
	dc.w	18, $0000	; Point index, texture coordinates
	dc.w	11, $00ff	; Point index, texture coordinates
	dc.w	19, $ff00	; Point index, texture coordinates

;* Face 16
	dc.w	$fe79,$1ee,$3ff4,$ff9d	; face normal
	dc.w	3		; number of points
	dc.w	1		; material DARK GRAY LUSTER
	dc.w	17, $0000	; Point index, texture coordinates
	dc.w	11, $00ff	; Point index, texture coordinates
	dc.w	18, $ff00	; Point index, texture coordinates

;* Face 17
	dc.w	$fa09,$0,$3fb9,$ff9e	; face normal
	dc.w	3		; number of points
	dc.w	1		; material DARK GRAY LUSTER
	dc.w	16, $0000	; Point index, texture coordinates
	dc.w	11, $00ff	; Point index, texture coordinates
	dc.w	17, $ff00	; Point index, texture coordinates

;* Face 18
	dc.w	$2e85,$0,$2bf4,$ff9e	; face normal
	dc.w	4		; number of points
	dc.w	1		; material DARK GRAY LUSTER
	dc.w	16, $0000	; Point index, texture coordinates
	dc.w	14, $00ff	; Point index, texture coordinates
	dc.w	13, $ff00	; Point index, texture coordinates
	dc.w	11, $ffff	; Point index, texture coordinates

;* Face 19
	dc.w	$2f0c,$420,$2b31,$ff9e	; face normal
	dc.w	3		; number of points
	dc.w	1		; material DARK GRAY LUSTER
	dc.w	15, $0000	; Point index, texture coordinates
	dc.w	14, $00ff	; Point index, texture coordinates
	dc.w	16, $ff00	; Point index, texture coordinates

;* Face 20
	dc.w	$2ee,$0,$c011,$ffd9	; face normal
	dc.w	3		; number of points
	dc.w	4		; material BLUE MARBLE
	dc.w	4, $0000	; Point index, texture coordinates
	dc.w	1, $00ff	; Point index, texture coordinates
	dc.w	3, $ff00	; Point index, texture coordinates

;* Face 21
	dc.w	$187,$1ee,$c00c,$ffdb	; face normal
	dc.w	3		; number of points
	dc.w	4		; material BLUE MARBLE
	dc.w	5, $0000	; Point index, texture coordinates
	dc.w	1, $00ff	; Point index, texture coordinates
	dc.w	4, $ff00	; Point index, texture coordinates

;* Face 22
	dc.w	$5f7,$0,$c047,$ffda	; face normal
	dc.w	3		; number of points
	dc.w	4		; material BLUE MARBLE
	dc.w	6, $0000	; Point index, texture coordinates
	dc.w	1, $00ff	; Point index, texture coordinates
	dc.w	5, $ff00	; Point index, texture coordinates

;* Face 23
	dc.w	$3b57,$0,$e807,$ff9f	; face normal
	dc.w	3		; number of points
	dc.w	1		; material DARK GRAY LUSTER
	dc.w	20, $0000	; Point index, texture coordinates
	dc.w	13, $00ff	; Point index, texture coordinates
	dc.w	14, $ff00	; Point index, texture coordinates

;* Face 24
	dc.w	$c4a9,$0,$17f9,$ff99	; face normal
	dc.w	3		; number of points
	dc.w	1		; material DARK GRAY LUSTER
	dc.w	8, $0000	; Point index, texture coordinates
	dc.w	21, $00ff	; Point index, texture coordinates
	dc.w	9, $ff00	; Point index, texture coordinates

;* Face 25
	dc.w	$e7b4,$3a64,$9d1,$2e	; face normal
	dc.w	3		; number of points
	dc.w	1		; material DARK GRAY LUSTER
	dc.w	0, $0000	; Point index, texture coordinates
	dc.w	21, $00ff	; Point index, texture coordinates
	dc.w	10, $ff00	; Point index, texture coordinates

;* Face 26
	dc.w	$d411,$27d5,$e7ee,$1d	; face normal
	dc.w	3		; number of points
	dc.w	1		; material DARK GRAY LUSTER
	dc.w	21, $0000	; Point index, texture coordinates
	dc.w	19, $00ff	; Point index, texture coordinates
	dc.w	10, $ff00	; Point index, texture coordinates

;* Face 27
	dc.w	$f11f,$27d5,$2fd5,$fff6	; face normal
	dc.w	3		; number of points
	dc.w	1		; material DARK GRAY LUSTER
	dc.w	0, $0000	; Point index, texture coordinates
	dc.w	9, $00ff	; Point index, texture coordinates
	dc.w	21, $ff00	; Point index, texture coordinates

;* Face 28
	dc.w	$184c,$3a64,$f62f,$31	; face normal
	dc.w	3		; number of points
	dc.w	1		; material DARK GRAY LUSTER
	dc.w	20, $0000	; Point index, texture coordinates
	dc.w	2, $00ff	; Point index, texture coordinates
	dc.w	12, $ff00	; Point index, texture coordinates

;* Face 29
	dc.w	$2bef,$27d5,$1812,$fff9	; face normal
	dc.w	3		; number of points
	dc.w	1		; material DARK GRAY LUSTER
	dc.w	20, $0000	; Point index, texture coordinates
	dc.w	3, $00ff	; Point index, texture coordinates
	dc.w	2, $ff00	; Point index, texture coordinates

;* Face 30
	dc.w	$ee2,$27d5,$d02b,$20	; face normal
	dc.w	3		; number of points
	dc.w	1		; material DARK GRAY LUSTER
	dc.w	20, $0000	; Point index, texture coordinates
	dc.w	12, $00ff	; Point index, texture coordinates
	dc.w	13, $ff00	; Point index, texture coordinates

;* Face 31
	dc.w	$1f09,$0,$c807,$ffae	; face normal
	dc.w	3		; number of points
	dc.w	2		; material GOLD
	dc.w	31, $0000	; Point index, texture coordinates
	dc.w	24, $00ff	; Point index, texture coordinates
	dc.w	23, $ff00	; Point index, texture coordinates

;* Face 32
	dc.w	$e0f7,$0,$c807,$ffae	; face normal
	dc.w	3		; number of points
	dc.w	2		; material GOLD
	dc.w	22, $0000	; Point index, texture coordinates
	dc.w	25, $00ff	; Point index, texture coordinates
	dc.w	30, $ff00	; Point index, texture coordinates

;* Face 33
	dc.w	$4000,$0,$0,$ffdd	; face normal
	dc.w	4		; number of points
	dc.w	2		; material GOLD
	dc.w	23, $0000	; Point index, texture coordinates
	dc.w	24, $00ff	; Point index, texture coordinates
	dc.w	28, $ff00	; Point index, texture coordinates
	dc.w	27, $ffff	; Point index, texture coordinates

;* Face 34
	dc.w	$c000,$0,$0,$ffdd	; face normal
	dc.w	4		; number of points
	dc.w	2		; material GOLD
	dc.w	25, $0000	; Point index, texture coordinates
	dc.w	22, $00ff	; Point index, texture coordinates
	dc.w	26, $ff00	; Point index, texture coordinates
	dc.w	29, $ffff	; Point index, texture coordinates

;* Face 35
	dc.w	$1f09,$0,$c807,$ffae	; face normal
	dc.w	3		; number of points
	dc.w	2		; material GOLD
	dc.w	24, $0000	; Point index, texture coordinates
	dc.w	31, $00ff	; Point index, texture coordinates
	dc.w	30, $ff00	; Point index, texture coordinates

;* Face 36
	dc.w	$e0f7,$0,$c807,$ffae	; face normal
	dc.w	3		; number of points
	dc.w	2		; material GOLD
	dc.w	22, $0000	; Point index, texture coordinates
	dc.w	30, $00ff	; Point index, texture coordinates
	dc.w	31, $ff00	; Point index, texture coordinates

;* Face 37
	dc.w	$e648,$3a9b,$0,$ffab	; face normal
	dc.w	3		; number of points
	dc.w	2		; material GOLD
	dc.w	22, $0000	; Point index, texture coordinates
	dc.w	32, $00ff	; Point index, texture coordinates
	dc.w	26, $ff00	; Point index, texture coordinates

;* Face 38
	dc.w	$197b,$0,$3ab5,$ffe1	; face normal
	dc.w	3		; number of points
	dc.w	2		; material GOLD
	dc.w	32, $0000	; Point index, texture coordinates
	dc.w	27, $00ff	; Point index, texture coordinates
	dc.w	28, $ff00	; Point index, texture coordinates

;* Face 39
	dc.w	$19b8,$3a9b,$0,$ffab	; face normal
	dc.w	4		; number of points
	dc.w	2		; material GOLD
	dc.w	32, $0000	; Point index, texture coordinates
	dc.w	31, $00ff	; Point index, texture coordinates
	dc.w	23, $ff00	; Point index, texture coordinates
	dc.w	27, $ffff	; Point index, texture coordinates

;* Face 40
	dc.w	$e648,$3a9b,$0,$ffab	; face normal
	dc.w	4		; number of points
	dc.w	2		; material GOLD
	dc.w	22, $0000	; Point index, texture coordinates
	dc.w	31, $00ff	; Point index, texture coordinates
	dc.w	32, $ff00	; Point index, texture coordinates
	dc.w	26, $ffff	; Point index, texture coordinates

;* Face 41
	dc.w	$e685,$0,$c54b,$1f	; face normal
	dc.w	4		; number of points
	dc.w	2		; material GOLD
	dc.w	32, $0000	; Point index, texture coordinates
	dc.w	33, $00ff	; Point index, texture coordinates
	dc.w	28, $ff00	; Point index, texture coordinates
	dc.w	27, $ffff	; Point index, texture coordinates

;* Face 42
	dc.w	$197b,$0,$c54b,$1f	; face normal
	dc.w	4		; number of points
	dc.w	2		; material GOLD
	dc.w	29, $0000	; Point index, texture coordinates
	dc.w	33, $00ff	; Point index, texture coordinates
	dc.w	32, $ff00	; Point index, texture coordinates
	dc.w	26, $ffff	; Point index, texture coordinates

;* Face 43
	dc.w	$e685,$0,$3ab5,$ffe1	; face normal
	dc.w	4		; number of points
	dc.w	2		; material GOLD
	dc.w	32, $0000	; Point index, texture coordinates
	dc.w	33, $00ff	; Point index, texture coordinates
	dc.w	29, $ff00	; Point index, texture coordinates
	dc.w	26, $ffff	; Point index, texture coordinates

;* Face 44
	dc.w	$197b,$0,$3ab5,$ffe1	; face normal
	dc.w	4		; number of points
	dc.w	2		; material GOLD
	dc.w	27, $0000	; Point index, texture coordinates
	dc.w	28, $00ff	; Point index, texture coordinates
	dc.w	33, $ff00	; Point index, texture coordinates
	dc.w	32, $ffff	; Point index, texture coordinates

;* Face 45
	dc.w	$ffea,$c012,$fcff,$ff5a	; face normal
	dc.w	3		; number of points
	dc.w	2		; material GOLD
	dc.w	37, $0000	; Point index, texture coordinates
	dc.w	35, $00ff	; Point index, texture coordinates
	dc.w	34, $ff00	; Point index, texture coordinates

;* Face 46
	dc.w	$cac2,$2339,$fb77,$fff1	; face normal
	dc.w	3		; number of points
	dc.w	2		; material GOLD
	dc.w	37, $0000	; Point index, texture coordinates
	dc.w	36, $00ff	; Point index, texture coordinates
	dc.w	35, $ff00	; Point index, texture coordinates

;* Face 47
	dc.w	$351c,$2323,$f99b,$ffe6	; face normal
	dc.w	3		; number of points
	dc.w	2		; material GOLD
	dc.w	37, $0000	; Point index, texture coordinates
	dc.w	34, $00ff	; Point index, texture coordinates
	dc.w	36, $ff00	; Point index, texture coordinates

;* Face 48
	dc.w	$11d,$666,$3fab,$2f4	; face normal
	dc.w	3		; number of points
	dc.w	2		; material GOLD
	dc.w	34, $0000	; Point index, texture coordinates
	dc.w	35, $00ff	; Point index, texture coordinates
	dc.w	38, $ff00	; Point index, texture coordinates

;* Face 49
	dc.w	$133d,$ce87,$23c1,$147	; face normal
	dc.w	3		; number of points
	dc.w	2		; material GOLD
	dc.w	35, $0000	; Point index, texture coordinates
	dc.w	36, $00ff	; Point index, texture coordinates
	dc.w	38, $ff00	; Point index, texture coordinates

;* Face 50
	dc.w	$edf4,$ce8e,$2468,$14b	; face normal
	dc.w	3		; number of points
	dc.w	2		; material GOLD
	dc.w	36, $0000	; Point index, texture coordinates
	dc.w	34, $00ff	; Point index, texture coordinates
	dc.w	38, $ff00	; Point index, texture coordinates

;* Face 51
	dc.w	$0,$398e,$1bfd,$1f	; face normal
	dc.w	3		; number of points
	dc.w	4		; material BLUE MARBLE
	dc.w	41, $0000	; Point index, texture coordinates
	dc.w	39, $00ff	; Point index, texture coordinates
	dc.w	42, $ff00	; Point index, texture coordinates

;* Face 52
	dc.w	$f585,$3a2b,$188c,$32	; face normal
	dc.w	3		; number of points
	dc.w	4		; material BLUE MARBLE
	dc.w	41, $0000	; Point index, texture coordinates
	dc.w	40, $00ff	; Point index, texture coordinates
	dc.w	39, $ff00	; Point index, texture coordinates

;* Face 53
	dc.w	$3b93,$e9b5,$711,$ff7f	; face normal
	dc.w	3		; number of points
	dc.w	1		; material DARK GRAY LUSTER
	dc.w	42, $0000	; Point index, texture coordinates
	dc.w	39, $00ff	; Point index, texture coordinates
	dc.w	45, $ff00	; Point index, texture coordinates

;* Face 54
	dc.w	$c000,$fffc,$f,$61	; face normal
	dc.w	3		; number of points
	dc.w	1		; material DARK GRAY LUSTER
	dc.w	40, $0000	; Point index, texture coordinates
	dc.w	41, $00ff	; Point index, texture coordinates
	dc.w	44, $ff00	; Point index, texture coordinates

;* Face 55
	dc.w	$f36b,$c246,$f4b3,$ffe4	; face normal
	dc.w	3		; number of points
	dc.w	1		; material DARK GRAY LUSTER
	dc.w	41, $0000	; Point index, texture coordinates
	dc.w	43, $00ff	; Point index, texture coordinates
	dc.w	44, $ff00	; Point index, texture coordinates

;* Face 56
	dc.w	$0,$c06e,$f89a,$ffcc	; face normal
	dc.w	3		; number of points
	dc.w	1		; material DARK GRAY LUSTER
	dc.w	41, $0000	; Point index, texture coordinates
	dc.w	42, $00ff	; Point index, texture coordinates
	dc.w	43, $ff00	; Point index, texture coordinates

;* Face 57
	dc.w	$3b74,$f35,$122c,$ff99	; face normal
	dc.w	3		; number of points
	dc.w	1		; material DARK GRAY LUSTER
	dc.w	42, $0000	; Point index, texture coordinates
	dc.w	45, $00ff	; Point index, texture coordinates
	dc.w	43, $ff00	; Point index, texture coordinates

;* Face 58
	dc.w	$f528,$f42,$c2cd,$ff6a	; face normal
	dc.w	3		; number of points
	dc.w	1		; material DARK GRAY LUSTER
	dc.w	40, $0000	; Point index, texture coordinates
	dc.w	44, $00ff	; Point index, texture coordinates
	dc.w	45, $ff00	; Point index, texture coordinates

;* Face 59
	dc.w	$ef18,$1fae,$cb06,$ff8e	; face normal
	dc.w	3		; number of points
	dc.w	1		; material DARK GRAY LUSTER
	dc.w	45, $0000	; Point index, texture coordinates
	dc.w	44, $00ff	; Point index, texture coordinates
	dc.w	43, $ff00	; Point index, texture coordinates

;* Face 60
	dc.w	$ef18,$fce6,$c25a,$ff7b	; face normal
	dc.w	3		; number of points
	dc.w	1		; material DARK GRAY LUSTER
	dc.w	40, $0000	; Point index, texture coordinates
	dc.w	45, $00ff	; Point index, texture coordinates
	dc.w	39, $ff00	; Point index, texture coordinates

;* Face 61
	dc.w	$fffb,$3fee,$302,$a6	; face normal
	dc.w	3		; number of points
	dc.w	2		; material GOLD
	dc.w	47, $0000	; Point index, texture coordinates
	dc.w	49, $00ff	; Point index, texture coordinates
	dc.w	46, $ff00	; Point index, texture coordinates

;* Face 62
	dc.w	$350e,$dcc7,$664,$b5	; face normal
	dc.w	3		; number of points
	dc.w	2		; material GOLD
	dc.w	48, $0000	; Point index, texture coordinates
	dc.w	49, $00ff	; Point index, texture coordinates
	dc.w	47, $ff00	; Point index, texture coordinates

;* Face 63
	dc.w	$cab3,$dcdd,$48a,$ff73	; face normal
	dc.w	3		; number of points
	dc.w	2		; material GOLD
	dc.w	46, $0000	; Point index, texture coordinates
	dc.w	49, $00ff	; Point index, texture coordinates
	dc.w	48, $ff00	; Point index, texture coordinates

;* Face 64
	dc.w	$11c,$f999,$c055,$fd0e	; face normal
	dc.w	3		; number of points
	dc.w	2		; material GOLD
	dc.w	47, $0000	; Point index, texture coordinates
	dc.w	46, $00ff	; Point index, texture coordinates
	dc.w	50, $ff00	; Point index, texture coordinates

;* Face 65
	dc.w	$ee05,$3179,$db99,$fe7f	; face normal
	dc.w	3		; number of points
	dc.w	2		; material GOLD
	dc.w	48, $0000	; Point index, texture coordinates
	dc.w	47, $00ff	; Point index, texture coordinates
	dc.w	50, $ff00	; Point index, texture coordinates

;* Face 66
	dc.w	$134e,$3172,$dc3f,$fef0	; face normal
	dc.w	3		; number of points
	dc.w	2		; material GOLD
	dc.w	46, $0000	; Point index, texture coordinates
	dc.w	48, $00ff	; Point index, texture coordinates
	dc.w	50, $ff00	; Point index, texture coordinates

;* Face 67
	dc.w	$0,$2ac5,$d063,$ff71	; face normal
	dc.w	3		; number of points
	dc.w	4		; material BLUE MARBLE
	dc.w	51, $0000	; Point index, texture coordinates
	dc.w	53, $00ff	; Point index, texture coordinates
	dc.w	54, $ff00	; Point index, texture coordinates

;* Face 68
	dc.w	$a7b,$27a1,$ceda,$ff7a	; face normal
	dc.w	3		; number of points
	dc.w	4		; material BLUE MARBLE
	dc.w	52, $0000	; Point index, texture coordinates
	dc.w	53, $00ff	; Point index, texture coordinates
	dc.w	51, $ff00	; Point index, texture coordinates

;* Face 69
	dc.w	$c46d,$a6,$1761,$7	; face normal
	dc.w	3		; number of points
	dc.w	1		; material DARK GRAY LUSTER
	dc.w	51, $0000	; Point index, texture coordinates
	dc.w	54, $00ff	; Point index, texture coordinates
	dc.w	57, $ff00	; Point index, texture coordinates

;* Face 70
	dc.w	$4000,$e,$8,$5d	; face normal
	dc.w	3		; number of points
	dc.w	1		; material DARK GRAY LUSTER
	dc.w	53, $0000	; Point index, texture coordinates
	dc.w	52, $00ff	; Point index, texture coordinates
	dc.w	56, $ff00	; Point index, texture coordinates

;* Face 71
	dc.w	$c95,$e41f,$3838,$c7	; face normal
	dc.w	3		; number of points
	dc.w	1		; material DARK GRAY LUSTER
	dc.w	55, $0000	; Point index, texture coordinates
	dc.w	53, $00ff	; Point index, texture coordinates
	dc.w	56, $ff00	; Point index, texture coordinates

;* Face 72
	dc.w	$0,$e75e,$3b12,$c0	; face normal
	dc.w	3		; number of points
	dc.w	1		; material DARK GRAY LUSTER
	dc.w	54, $0000	; Point index, texture coordinates
	dc.w	53, $00ff	; Point index, texture coordinates
	dc.w	55, $ff00	; Point index, texture coordinates

;* Face 73
	dc.w	$c48c,$15a9,$f664,$ffa0	; face normal
	dc.w	3		; number of points
	dc.w	1		; material DARK GRAY LUSTER
	dc.w	57, $0000	; Point index, texture coordinates
	dc.w	54, $00ff	; Point index, texture coordinates
	dc.w	55, $ff00	; Point index, texture coordinates

;* Face 74
	dc.w	$ad8,$c960,$e076,$68	; face normal
	dc.w	3		; number of points
	dc.w	1		; material DARK GRAY LUSTER
	dc.w	56, $0000	; Point index, texture coordinates
	dc.w	52, $00ff	; Point index, texture coordinates
	dc.w	57, $ff00	; Point index, texture coordinates

;* Face 75
	dc.w	$10e8,$d5cf,$d2f2,$36	; face normal
	dc.w	3		; number of points
	dc.w	1		; material DARK GRAY LUSTER
	dc.w	56, $0000	; Point index, texture coordinates
	dc.w	57, $00ff	; Point index, texture coordinates
	dc.w	55, $ff00	; Point index, texture coordinates

;* Face 76
	dc.w	$10e8,$c3e3,$f1fd,$92	; face normal
	dc.w	3		; number of points
	dc.w	1		; material DARK GRAY LUSTER
	dc.w	57, $0000	; Point index, texture coordinates
	dc.w	52, $00ff	; Point index, texture coordinates
	dc.w	51, $ff00	; Point index, texture coordinates

;* Face 77
	dc.w	$0,$0,$4000,$ff29	; face normal
	dc.w	4		; number of points
	dc.w	1		; material DARK GRAY LUSTER
	dc.w	59, $0000	; Point index, texture coordinates
	dc.w	61, $00ff	; Point index, texture coordinates
	dc.w	62, $ff00	; Point index, texture coordinates
	dc.w	58, $ffff	; Point index, texture coordinates

;* Face 78
	dc.w	$0,$0,$4000,$ff29	; face normal
	dc.w	3		; number of points
	dc.w	1		; material DARK GRAY LUSTER
	dc.w	59, $0000	; Point index, texture coordinates
	dc.w	60, $00ff	; Point index, texture coordinates
	dc.w	69, $ff00	; Point index, texture coordinates

;* Face 79
	dc.w	$d504,$d095,$0,$ffe1	; face normal
	dc.w	4		; number of points
	dc.w	1		; material DARK GRAY LUSTER
	dc.w	58, $0000	; Point index, texture coordinates
	dc.w	63, $00ff	; Point index, texture coordinates
	dc.w	64, $ff00	; Point index, texture coordinates
	dc.w	59, $ffff	; Point index, texture coordinates

;* Face 80
	dc.w	$c182,$dd0,$0,$ffdc	; face normal
	dc.w	4		; number of points
	dc.w	1		; material DARK GRAY LUSTER
	dc.w	59, $0000	; Point index, texture coordinates
	dc.w	64, $00ff	; Point index, texture coordinates
	dc.w	65, $ff00	; Point index, texture coordinates
	dc.w	60, $ffff	; Point index, texture coordinates

;* Face 81
	dc.w	$1ef5,$3804,$0,$ffce	; face normal
	dc.w	3		; number of points
	dc.w	1		; material DARK GRAY LUSTER
	dc.w	69, $0000	; Point index, texture coordinates
	dc.w	66, $00ff	; Point index, texture coordinates
	dc.w	61, $ff00	; Point index, texture coordinates

;* Face 82
	dc.w	$e10b,$3804,$0,$ffce	; face normal
	dc.w	3		; number of points
	dc.w	1		; material DARK GRAY LUSTER
	dc.w	60, $0000	; Point index, texture coordinates
	dc.w	65, $00ff	; Point index, texture coordinates
	dc.w	68, $ff00	; Point index, texture coordinates

;* Face 83
	dc.w	$3e7e,$dd0,$0,$ffdc	; face normal
	dc.w	4		; number of points
	dc.w	1		; material DARK GRAY LUSTER
	dc.w	61, $0000	; Point index, texture coordinates
	dc.w	66, $00ff	; Point index, texture coordinates
	dc.w	67, $ff00	; Point index, texture coordinates
	dc.w	62, $ffff	; Point index, texture coordinates

;* Face 84
	dc.w	$2afc,$d095,$0,$ffe1	; face normal
	dc.w	4		; number of points
	dc.w	1		; material DARK GRAY LUSTER
	dc.w	62, $0000	; Point index, texture coordinates
	dc.w	67, $00ff	; Point index, texture coordinates
	dc.w	63, $ff00	; Point index, texture coordinates
	dc.w	58, $ffff	; Point index, texture coordinates

;* Face 85
	dc.w	$17b2,$371a,$1652,$ff9b	; face normal
	dc.w	3		; number of points
	dc.w	1		; material DARK GRAY LUSTER
	dc.w	60, $0000	; Point index, texture coordinates
	dc.w	68, $00ff	; Point index, texture coordinates
	dc.w	66, $ff00	; Point index, texture coordinates

;* Face 86
	dc.w	$0,$0,$4000,$ff29	; face normal
	dc.w	3		; number of points
	dc.w	1		; material DARK GRAY LUSTER
	dc.w	59, $0000	; Point index, texture coordinates
	dc.w	69, $00ff	; Point index, texture coordinates
	dc.w	61, $ff00	; Point index, texture coordinates

;* Face 87
	dc.w	$e3d5,$32fa,$e578,$2c	; face normal
	dc.w	3		; number of points
	dc.w	1		; material DARK GRAY LUSTER
	dc.w	60, $0000	; Point index, texture coordinates
	dc.w	66, $00ff	; Point index, texture coordinates
	dc.w	69, $ff00	; Point index, texture coordinates

;* Face 88
	dc.w	$e10b,$c7fc,$0,$32	; face normal
	dc.w	4		; number of points
	dc.w	1		; material DARK GRAY LUSTER
	dc.w	61, $0000	; Point index, texture coordinates
	dc.w	66, $00ff	; Point index, texture coordinates
	dc.w	68, $ff00	; Point index, texture coordinates
	dc.w	69, $ffff	; Point index, texture coordinates

;* Face 89
	dc.w	$1ef5,$c7fc,$0,$32	; face normal
	dc.w	4		; number of points
	dc.w	1		; material DARK GRAY LUSTER
	dc.w	69, $0000	; Point index, texture coordinates
	dc.w	68, $00ff	; Point index, texture coordinates
	dc.w	65, $ff00	; Point index, texture coordinates
	dc.w	60, $ffff	; Point index, texture coordinates

;* Face 90
	dc.w	$d504,$0,$d095,$fff0	; face normal
	dc.w	4		; number of points
	dc.w	0		; material AQUA GLAZE
	dc.w	70, $0000	; Point index, texture coordinates
	dc.w	75, $00ff	; Point index, texture coordinates
	dc.w	76, $ff00	; Point index, texture coordinates
	dc.w	71, $ffff	; Point index, texture coordinates

;* Face 91
	dc.w	$c21b,$0,$104a,$ff73	; face normal
	dc.w	4		; number of points
	dc.w	0		; material AQUA GLAZE
	dc.w	71, $0000	; Point index, texture coordinates
	dc.w	76, $00ff	; Point index, texture coordinates
	dc.w	77, $ff00	; Point index, texture coordinates
	dc.w	72, $ffff	; Point index, texture coordinates

;* Face 92
	dc.w	$3de5,$0,$104a,$7	; face normal
	dc.w	4		; number of points
	dc.w	0		; material AQUA GLAZE
	dc.w	73, $0000	; Point index, texture coordinates
	dc.w	78, $00ff	; Point index, texture coordinates
	dc.w	79, $ff00	; Point index, texture coordinates
	dc.w	74, $ffff	; Point index, texture coordinates

;* Face 93
	dc.w	$2afc,$0,$d095,$57	; face normal
	dc.w	4		; number of points
	dc.w	0		; material AQUA GLAZE
	dc.w	74, $0000	; Point index, texture coordinates
	dc.w	79, $00ff	; Point index, texture coordinates
	dc.w	75, $ff00	; Point index, texture coordinates
	dc.w	70, $ffff	; Point index, texture coordinates

;* Face 94
	dc.w	$8d,$0,$3fff,$ff8c	; face normal
	dc.w	4		; number of points
	dc.w	0		; material AQUA GLAZE
	dc.w	83, $0000	; Point index, texture coordinates
	dc.w	88, $00ff	; Point index, texture coordinates
	dc.w	78, $ff00	; Point index, texture coordinates
	dc.w	73, $ffff	; Point index, texture coordinates

;* Face 95
	dc.w	$0,$c000,$0,$feda	; face normal
	dc.w	4		; number of points
	dc.w	0		; material AQUA GLAZE
	dc.w	74, $0000	; Point index, texture coordinates
	dc.w	84, $00ff	; Point index, texture coordinates
	dc.w	83, $ff00	; Point index, texture coordinates
	dc.w	73, $ffff	; Point index, texture coordinates

;* Face 96
	dc.w	$0,$c000,$0,$feda	; face normal
	dc.w	4		; number of points
	dc.w	0		; material AQUA GLAZE
	dc.w	70, $0000	; Point index, texture coordinates
	dc.w	80, $00ff	; Point index, texture coordinates
	dc.w	84, $ff00	; Point index, texture coordinates
	dc.w	74, $ffff	; Point index, texture coordinates

;* Face 97
	dc.w	$0,$c000,$0,$feda	; face normal
	dc.w	4		; number of points
	dc.w	0		; material AQUA GLAZE
	dc.w	80, $0000	; Point index, texture coordinates
	dc.w	70, $00ff	; Point index, texture coordinates
	dc.w	71, $ff00	; Point index, texture coordinates
	dc.w	81, $ffff	; Point index, texture coordinates

;* Face 98
	dc.w	$0,$c000,$0,$feda	; face normal
	dc.w	4		; number of points
	dc.w	0		; material AQUA GLAZE
	dc.w	81, $0000	; Point index, texture coordinates
	dc.w	71, $00ff	; Point index, texture coordinates
	dc.w	72, $ff00	; Point index, texture coordinates
	dc.w	82, $ffff	; Point index, texture coordinates

;* Face 99
	dc.w	$ff73,$0,$3fff,$ff8b	; face normal
	dc.w	4		; number of points
	dc.w	0		; material AQUA GLAZE
	dc.w	72, $0000	; Point index, texture coordinates
	dc.w	77, $00ff	; Point index, texture coordinates
	dc.w	87, $ff00	; Point index, texture coordinates
	dc.w	82, $ffff	; Point index, texture coordinates

;* Face 100
	dc.w	$12,$3f73,$85e,$109	; face normal
	dc.w	3		; number of points
	dc.w	0		; material AQUA GLAZE
	dc.w	88, $0000	; Point index, texture coordinates
	dc.w	79, $00ff	; Point index, texture coordinates
	dc.w	78, $ff00	; Point index, texture coordinates

;* Face 101
	dc.w	$1a7,$3f53,$91f,$108	; face normal
	dc.w	3		; number of points
	dc.w	0		; material AQUA GLAZE
	dc.w	79, $0000	; Point index, texture coordinates
	dc.w	88, $00ff	; Point index, texture coordinates
	dc.w	89, $ff00	; Point index, texture coordinates

;* Face 102
	dc.w	$3f0,$3c13,$15b7,$ea	; face normal
	dc.w	3		; number of points
	dc.w	0		; material AQUA GLAZE
	dc.w	89, $0000	; Point index, texture coordinates
	dc.w	75, $00ff	; Point index, texture coordinates
	dc.w	79, $ff00	; Point index, texture coordinates

;* Face 103
	dc.w	$1614,$3bd6,$552,$10b	; face normal
	dc.w	3		; number of points
	dc.w	0		; material AQUA GLAZE
	dc.w	75, $0000	; Point index, texture coordinates
	dc.w	89, $00ff	; Point index, texture coordinates
	dc.w	85, $ff00	; Point index, texture coordinates

;* Face 104
	dc.w	$fb94,$3b02,$1863,$d7	; face normal
	dc.w	3		; number of points
	dc.w	0		; material AQUA GLAZE
	dc.w	76, $0000	; Point index, texture coordinates
	dc.w	85, $00ff	; Point index, texture coordinates
	dc.w	86, $ff00	; Point index, texture coordinates

;* Face 105
	dc.w	$ecf8,$3cde,$569,$de	; face normal
	dc.w	3		; number of points
	dc.w	0		; material AQUA GLAZE
	dc.w	85, $0000	; Point index, texture coordinates
	dc.w	76, $00ff	; Point index, texture coordinates
	dc.w	75, $ff00	; Point index, texture coordinates

;* Face 106
	dc.w	$ffed,$3f66,$8c4,$108	; face normal
	dc.w	3		; number of points
	dc.w	0		; material AQUA GLAZE
	dc.w	77, $0000	; Point index, texture coordinates
	dc.w	86, $00ff	; Point index, texture coordinates
	dc.w	87, $ff00	; Point index, texture coordinates

;* Face 107
	dc.w	$fe6a,$3f61,$8c1,$105	; face normal
	dc.w	3		; number of points
	dc.w	0		; material AQUA GLAZE
	dc.w	86, $0000	; Point index, texture coordinates
	dc.w	77, $00ff	; Point index, texture coordinates
	dc.w	76, $ff00	; Point index, texture coordinates

;* Face 108
	dc.w	$0,$2ec0,$d44a,$f8	; face normal
	dc.w	4		; number of points
	dc.w	3		; material ORANGE MATTE
	dc.w	90, $0000	; Point index, texture coordinates
	dc.w	93, $00ff	; Point index, texture coordinates
	dc.w	92, $ff00	; Point index, texture coordinates
	dc.w	91, $ffff	; Point index, texture coordinates

;* Face 109
	dc.w	$3ea1,$d2d,$0,$18	; face normal
	dc.w	4		; number of points
	dc.w	3		; material ORANGE MATTE
	dc.w	91, $0000	; Point index, texture coordinates
	dc.w	92, $00ff	; Point index, texture coordinates
	dc.w	96, $ff00	; Point index, texture coordinates
	dc.w	95, $ffff	; Point index, texture coordinates

;* Face 110
	dc.w	$0,$c000,$0,$ff47	; face normal
	dc.w	4		; number of points
	dc.w	3		; material ORANGE MATTE
	dc.w	92, $0000	; Point index, texture coordinates
	dc.w	93, $00ff	; Point index, texture coordinates
	dc.w	97, $ff00	; Point index, texture coordinates
	dc.w	96, $ffff	; Point index, texture coordinates

;* Face 111
	dc.w	$c13c,$c80,$0,$1e	; face normal
	dc.w	4		; number of points
	dc.w	3		; material ORANGE MATTE
	dc.w	93, $0000	; Point index, texture coordinates
	dc.w	90, $00ff	; Point index, texture coordinates
	dc.w	94, $ff00	; Point index, texture coordinates
	dc.w	97, $ffff	; Point index, texture coordinates

;* Face 112
	dc.w	$0,$0,$4000,$fecb	; face normal
	dc.w	4		; number of points
	dc.w	3		; material ORANGE MATTE
	dc.w	94, $0000	; Point index, texture coordinates
	dc.w	95, $00ff	; Point index, texture coordinates
	dc.w	96, $ff00	; Point index, texture coordinates
	dc.w	97, $ffff	; Point index, texture coordinates

;* Face 113
	dc.w	$f6db,$2c2d,$2d66,$54	; face normal
	dc.w	3		; number of points
	dc.w	4		; material BLUE MARBLE
	dc.w	99, $0000	; Point index, texture coordinates
	dc.w	102, $00ff	; Point index, texture coordinates
	dc.w	98, $ff00	; Point index, texture coordinates

;* Face 114
	dc.w	$f707,$2d4b,$2c51,$59	; face normal
	dc.w	3		; number of points
	dc.w	4		; material BLUE MARBLE
	dc.w	100, $0000	; Point index, texture coordinates
	dc.w	102, $00ff	; Point index, texture coordinates
	dc.w	99, $ff00	; Point index, texture coordinates

;* Face 115
	dc.w	$efff,$2ac8,$2cd4,$2b	; face normal
	dc.w	3		; number of points
	dc.w	4		; material BLUE MARBLE
	dc.w	100, $0000	; Point index, texture coordinates
	dc.w	101, $00ff	; Point index, texture coordinates
	dc.w	102, $ff00	; Point index, texture coordinates

;* Face 116
	dc.w	$3172,$2407,$ed36,$13c	; face normal
	dc.w	4		; number of points
	dc.w	1		; material DARK GRAY LUSTER
	dc.w	98, $0000	; Point index, texture coordinates
	dc.w	103, $00ff	; Point index, texture coordinates
	dc.w	104, $ff00	; Point index, texture coordinates
	dc.w	99, $ffff	; Point index, texture coordinates

;* Face 117
	dc.w	$3cb6,$434,$13cf,$fe	; face normal
	dc.w	4		; number of points
	dc.w	1		; material DARK GRAY LUSTER
	dc.w	99, $0000	; Point index, texture coordinates
	dc.w	104, $00ff	; Point index, texture coordinates
	dc.w	105, $ff00	; Point index, texture coordinates
	dc.w	100, $ffff	; Point index, texture coordinates

;* Face 118
	dc.w	$e98,$d87a,$302d,$ff0f	; face normal
	dc.w	4		; number of points
	dc.w	1		; material DARK GRAY LUSTER
	dc.w	100, $0000	; Point index, texture coordinates
	dc.w	105, $00ff	; Point index, texture coordinates
	dc.w	106, $ff00	; Point index, texture coordinates
	dc.w	101, $ffff	; Point index, texture coordinates

;* Face 119
	dc.w	$c2e3,$ed9c,$fb39,$fe7b	; face normal
	dc.w	4		; number of points
	dc.w	1		; material DARK GRAY LUSTER
	dc.w	101, $0000	; Point index, texture coordinates
	dc.w	106, $00ff	; Point index, texture coordinates
	dc.w	107, $ff00	; Point index, texture coordinates
	dc.w	102, $ffff	; Point index, texture coordinates

;* Face 120
	dc.w	$e474,$2195,$d0ff,$ffd3	; face normal
	dc.w	4		; number of points
	dc.w	1		; material DARK GRAY LUSTER
	dc.w	102, $0000	; Point index, texture coordinates
	dc.w	107, $00ff	; Point index, texture coordinates
	dc.w	103, $ff00	; Point index, texture coordinates
	dc.w	98, $ffff	; Point index, texture coordinates

;* Face 121
	dc.w	$184e,$d2b5,$d9df,$ffd0	; face normal
	dc.w	3		; number of points
	dc.w	1		; material DARK GRAY LUSTER
	dc.w	107, $0000	; Point index, texture coordinates
	dc.w	104, $00ff	; Point index, texture coordinates
	dc.w	103, $ff00	; Point index, texture coordinates

;* Face 122
	dc.w	$187e,$d3c8,$d8bf,$ffd4	; face normal
	dc.w	3		; number of points
	dc.w	1		; material DARK GRAY LUSTER
	dc.w	107, $0000	; Point index, texture coordinates
	dc.w	105, $00ff	; Point index, texture coordinates
	dc.w	104, $ff00	; Point index, texture coordinates

;* Face 123
	dc.w	$11af,$d0ad,$d8b5,$ffa5	; face normal
	dc.w	3		; number of points
	dc.w	1		; material DARK GRAY LUSTER
	dc.w	106, $0000	; Point index, texture coordinates
	dc.w	105, $00ff	; Point index, texture coordinates
	dc.w	107, $ff00	; Point index, texture coordinates

;* Face 124
	dc.w	$f8fc,$398c,$e4e3,$fffb	; face normal
	dc.w	3		; number of points
	dc.w	4		; material BLUE MARBLE
	dc.w	112, $0000	; Point index, texture coordinates
	dc.w	109, $00ff	; Point index, texture coordinates
	dc.w	108, $ff00	; Point index, texture coordinates

;* Face 125
	dc.w	$f87c,$38d9,$e394,$fffe	; face normal
	dc.w	3		; number of points
	dc.w	4		; material BLUE MARBLE
	dc.w	112, $0000	; Point index, texture coordinates
	dc.w	110, $00ff	; Point index, texture coordinates
	dc.w	109, $ff00	; Point index, texture coordinates

;* Face 126
	dc.w	$fff0,$397e,$e3e1,$fff4	; face normal
	dc.w	3		; number of points
	dc.w	4		; material BLUE MARBLE
	dc.w	111, $0000	; Point index, texture coordinates
	dc.w	110, $00ff	; Point index, texture coordinates
	dc.w	112, $ff00	; Point index, texture coordinates

;* Face 127
	dc.w	$c5fd,$f2cb,$e86a,$b1	; face normal
	dc.w	4		; number of points
	dc.w	1		; material DARK GRAY LUSTER
	dc.w	114, $0000	; Point index, texture coordinates
	dc.w	113, $00ff	; Point index, texture coordinates
	dc.w	108, $ff00	; Point index, texture coordinates
	dc.w	109, $ffff	; Point index, texture coordinates

;* Face 128
	dc.w	$c4c4,$bed,$1518,$72	; face normal
	dc.w	4		; number of points
	dc.w	1		; material DARK GRAY LUSTER
	dc.w	115, $0000	; Point index, texture coordinates
	dc.w	114, $00ff	; Point index, texture coordinates
	dc.w	109, $ff00	; Point index, texture coordinates
	dc.w	110, $ffff	; Point index, texture coordinates

;* Face 129
	dc.w	$fde8,$1f5c,$37c0,$5a	; face normal
	dc.w	4		; number of points
	dc.w	1		; material DARK GRAY LUSTER
	dc.w	116, $0000	; Point index, texture coordinates
	dc.w	115, $00ff	; Point index, texture coordinates
	dc.w	110, $ff00	; Point index, texture coordinates
	dc.w	111, $ffff	; Point index, texture coordinates

;* Face 130
	dc.w	$3fdf,$fdf2,$fc77,$ffbe	; face normal
	dc.w	4		; number of points
	dc.w	1		; material DARK GRAY LUSTER
	dc.w	117, $0000	; Point index, texture coordinates
	dc.w	116, $00ff	; Point index, texture coordinates
	dc.w	111, $ff00	; Point index, texture coordinates
	dc.w	112, $ffff	; Point index, texture coordinates

;* Face 131
	dc.w	$103e,$e1a3,$ca0d,$58	; face normal
	dc.w	4		; number of points
	dc.w	1		; material DARK GRAY LUSTER
	dc.w	113, $0000	; Point index, texture coordinates
	dc.w	117, $00ff	; Point index, texture coordinates
	dc.w	112, $ff00	; Point index, texture coordinates
	dc.w	108, $ffff	; Point index, texture coordinates

;* Face 132
	dc.w	$f8df,$caf5,$2317,$30	; face normal
	dc.w	3		; number of points
	dc.w	1		; material DARK GRAY LUSTER
	dc.w	114, $0000	; Point index, texture coordinates
	dc.w	117, $00ff	; Point index, texture coordinates
	dc.w	113, $ff00	; Point index, texture coordinates

;* Face 133
	dc.w	$f85f,$ca33,$21d1,$34	; face normal
	dc.w	3		; number of points
	dc.w	1		; material DARK GRAY LUSTER
	dc.w	115, $0000	; Point index, texture coordinates
	dc.w	117, $00ff	; Point index, texture coordinates
	dc.w	114, $ff00	; Point index, texture coordinates

;* Face 134
	dc.w	$ffd2,$ca1d,$2287,$2a	; face normal
	dc.w	3		; number of points
	dc.w	1		; material DARK GRAY LUSTER
	dc.w	115, $0000	; Point index, texture coordinates
	dc.w	116, $00ff	; Point index, texture coordinates
	dc.w	117, $ff00	; Point index, texture coordinates

;* Face 135
	dc.w	$df,$3c8,$c01e,$ff4a	; face normal
	dc.w	3		; number of points
	dc.w	2		; material GOLD
	dc.w	122, $0000	; Point index, texture coordinates
	dc.w	118, $00ff	; Point index, texture coordinates
	dc.w	123, $ff00	; Point index, texture coordinates

;* Face 136
	dc.w	$0,$0,$c000,$ff4a	; face normal
	dc.w	3		; number of points
	dc.w	2		; material GOLD
	dc.w	122, $0000	; Point index, texture coordinates
	dc.w	119, $00ff	; Point index, texture coordinates
	dc.w	118, $ff00	; Point index, texture coordinates

;* Face 137
	dc.w	$0,$0,$c000,$ff4a	; face normal
	dc.w	4		; number of points
	dc.w	2		; material GOLD
	dc.w	121, $0000	; Point index, texture coordinates
	dc.w	120, $00ff	; Point index, texture coordinates
	dc.w	119, $ff00	; Point index, texture coordinates
	dc.w	122, $ffff	; Point index, texture coordinates

;* Face 138
	dc.w	$0,$c000,$0,$6c	; face normal
	dc.w	4		; number of points
	dc.w	2		; material GOLD
	dc.w	125, $0000	; Point index, texture coordinates
	dc.w	124, $00ff	; Point index, texture coordinates
	dc.w	118, $ff00	; Point index, texture coordinates
	dc.w	119, $ffff	; Point index, texture coordinates

;* Face 139
	dc.w	$3f68,$f74f,$0,$1c3	; face normal
	dc.w	4		; number of points
	dc.w	2		; material GOLD
	dc.w	126, $0000	; Point index, texture coordinates
	dc.w	125, $00ff	; Point index, texture coordinates
	dc.w	119, $ff00	; Point index, texture coordinates
	dc.w	120, $ffff	; Point index, texture coordinates

;* Face 140
	dc.w	$0,$c000,$0,$5d	; face normal
	dc.w	4		; number of points
	dc.w	2		; material GOLD
	dc.w	127, $0000	; Point index, texture coordinates
	dc.w	126, $00ff	; Point index, texture coordinates
	dc.w	120, $ff00	; Point index, texture coordinates
	dc.w	121, $ffff	; Point index, texture coordinates

;* Face 141
	dc.w	$c026,$460,$0,$fe31	; face normal
	dc.w	4		; number of points
	dc.w	2		; material GOLD
	dc.w	128, $0000	; Point index, texture coordinates
	dc.w	127, $00ff	; Point index, texture coordinates
	dc.w	121, $ff00	; Point index, texture coordinates
	dc.w	122, $ffff	; Point index, texture coordinates

;* Face 142
	dc.w	$c390,$150f,$0,$fe29	; face normal
	dc.w	3		; number of points
	dc.w	2		; material GOLD
	dc.w	128, $0000	; Point index, texture coordinates
	dc.w	122, $00ff	; Point index, texture coordinates
	dc.w	123, $ff00	; Point index, texture coordinates

;* Face 143
	dc.w	$4000,$0,$0,$187	; face normal
	dc.w	3		; number of points
	dc.w	2		; material GOLD
	dc.w	124, $0000	; Point index, texture coordinates
	dc.w	123, $00ff	; Point index, texture coordinates
	dc.w	118, $ff00	; Point index, texture coordinates

;* Face 144
	dc.w	$c5,$357,$3fe9,$9e	; face normal
	dc.w	3		; number of points
	dc.w	2		; material GOLD
	dc.w	124, $0000	; Point index, texture coordinates
	dc.w	128, $00ff	; Point index, texture coordinates
	dc.w	123, $ff00	; Point index, texture coordinates

;* Face 145
	dc.w	$0,$0,$4000,$9f	; face normal
	dc.w	3		; number of points
	dc.w	2		; material GOLD
	dc.w	125, $0000	; Point index, texture coordinates
	dc.w	128, $00ff	; Point index, texture coordinates
	dc.w	124, $ff00	; Point index, texture coordinates

;* Face 146
	dc.w	$0,$0,$4000,$9f	; face normal
	dc.w	4		; number of points
	dc.w	2		; material GOLD
	dc.w	125, $0000	; Point index, texture coordinates
	dc.w	126, $00ff	; Point index, texture coordinates
	dc.w	127, $ff00	; Point index, texture coordinates
	dc.w	128, $ffff	; Point index, texture coordinates

;* Face 147
	dc.w	$ff21,$fc38,$3fe2,$bb	; face normal
	dc.w	3		; number of points
	dc.w	2		; material GOLD
	dc.w	129, $0000	; Point index, texture coordinates
	dc.w	133, $00ff	; Point index, texture coordinates
	dc.w	134, $ff00	; Point index, texture coordinates

;* Face 148
	dc.w	$0,$0,$4000,$b6	; face normal
	dc.w	3		; number of points
	dc.w	2		; material GOLD
	dc.w	130, $0000	; Point index, texture coordinates
	dc.w	133, $00ff	; Point index, texture coordinates
	dc.w	129, $ff00	; Point index, texture coordinates

;* Face 149
	dc.w	$0,$0,$4000,$b6	; face normal
	dc.w	4		; number of points
	dc.w	2		; material GOLD
	dc.w	130, $0000	; Point index, texture coordinates
	dc.w	131, $00ff	; Point index, texture coordinates
	dc.w	132, $ff00	; Point index, texture coordinates
	dc.w	133, $ffff	; Point index, texture coordinates

;* Face 150
	dc.w	$0,$4000,$0,$ff94	; face normal
	dc.w	4		; number of points
	dc.w	2		; material GOLD
	dc.w	129, $0000	; Point index, texture coordinates
	dc.w	135, $00ff	; Point index, texture coordinates
	dc.w	136, $ff00	; Point index, texture coordinates
	dc.w	130, $ffff	; Point index, texture coordinates

;* Face 151
	dc.w	$c098,$8b1,$0,$ff8c	; face normal
	dc.w	4		; number of points
	dc.w	2		; material GOLD
	dc.w	130, $0000	; Point index, texture coordinates
	dc.w	136, $00ff	; Point index, texture coordinates
	dc.w	137, $ff00	; Point index, texture coordinates
	dc.w	131, $ffff	; Point index, texture coordinates

;* Face 152
	dc.w	$0,$4000,$0,$ffa3	; face normal
	dc.w	4		; number of points
	dc.w	2		; material GOLD
	dc.w	131, $0000	; Point index, texture coordinates
	dc.w	137, $00ff	; Point index, texture coordinates
	dc.w	138, $ff00	; Point index, texture coordinates
	dc.w	132, $ffff	; Point index, texture coordinates

;* Face 153
	dc.w	$3fda,$fba0,$0,$7d	; face normal
	dc.w	4		; number of points
	dc.w	2		; material GOLD
	dc.w	132, $0000	; Point index, texture coordinates
	dc.w	138, $00ff	; Point index, texture coordinates
	dc.w	139, $ff00	; Point index, texture coordinates
	dc.w	133, $ffff	; Point index, texture coordinates

;* Face 154
	dc.w	$3c70,$eaf1,$0,$97	; face normal
	dc.w	3		; number of points
	dc.w	2		; material GOLD
	dc.w	133, $0000	; Point index, texture coordinates
	dc.w	139, $00ff	; Point index, texture coordinates
	dc.w	134, $ff00	; Point index, texture coordinates

;* Face 155
	dc.w	$c000,$0,$0,$ffcb	; face normal
	dc.w	3		; number of points
	dc.w	2		; material GOLD
	dc.w	134, $0000	; Point index, texture coordinates
	dc.w	135, $00ff	; Point index, texture coordinates
	dc.w	129, $ff00	; Point index, texture coordinates

;* Face 156
	dc.w	$ff3b,$fca9,$c017,$ff66	; face normal
	dc.w	3		; number of points
	dc.w	2		; material GOLD
	dc.w	139, $0000	; Point index, texture coordinates
	dc.w	135, $00ff	; Point index, texture coordinates
	dc.w	134, $ff00	; Point index, texture coordinates

;* Face 157
	dc.w	$0,$0,$c000,$ff61	; face normal
	dc.w	3		; number of points
	dc.w	2		; material GOLD
	dc.w	139, $0000	; Point index, texture coordinates
	dc.w	136, $00ff	; Point index, texture coordinates
	dc.w	135, $ff00	; Point index, texture coordinates

;* Face 158
	dc.w	$0,$0,$c000,$ff61	; face normal
	dc.w	4		; number of points
	dc.w	2		; material GOLD
	dc.w	138, $0000	; Point index, texture coordinates
	dc.w	137, $00ff	; Point index, texture coordinates
	dc.w	136, $ff00	; Point index, texture coordinates
	dc.w	139, $ffff	; Point index, texture coordinates

;* Face 159
	dc.w	$cfde,$0,$d5d2,$edcc	; face normal
	dc.w	4		; number of points
	dc.w	7		; material Default Material
	dc.w	140, $0000	; Point index, texture coordinates
	dc.w	143, $00ff	; Point index, texture coordinates
	dc.w	142, $ff00	; Point index, texture coordinates
	dc.w	141, $ffff	; Point index, texture coordinates

;* Face 160
	dc.w	$0,$4000,$0,$fb2a	; face normal
	dc.w	4		; number of points
	dc.w	5		; material BUMPY METAL
	dc.w	140, $0000	; Point index, texture coordinates
	dc.w	141, $00ff	; Point index, texture coordinates
	dc.w	145, $ff00	; Point index, texture coordinates
	dc.w	144, $ffff	; Point index, texture coordinates

;* Face 161
	dc.w	$131d,$0,$c2ec,$f3ab	; face normal
	dc.w	4		; number of points
	dc.w	7		; material Default Material
	dc.w	141, $0000	; Point index, texture coordinates
	dc.w	142, $00ff	; Point index, texture coordinates
	dc.w	146, $ff00	; Point index, texture coordinates
	dc.w	145, $ffff	; Point index, texture coordinates

;* Face 162
	dc.w	$0,$c000,$0,$4c3	; face normal
	dc.w	4		; number of points
	dc.w	6		; material BUMPYWHITE STONE
	dc.w	142, $0000	; Point index, texture coordinates
	dc.w	143, $00ff	; Point index, texture coordinates
	dc.w	147, $ff00	; Point index, texture coordinates
	dc.w	146, $ffff	; Point index, texture coordinates

;* Face 163
	dc.w	$ece3,$0,$3d14,$fc1d	; face normal
	dc.w	4		; number of points
	dc.w	7		; material Default Material
	dc.w	143, $0000	; Point index, texture coordinates
	dc.w	140, $00ff	; Point index, texture coordinates
	dc.w	144, $ff00	; Point index, texture coordinates
	dc.w	147, $ffff	; Point index, texture coordinates

;* Face 164
	dc.w	$3022,$0,$2a2e,$f4c5	; face normal
	dc.w	4		; number of points
	dc.w	7		; material Default Material
	dc.w	144, $0000	; Point index, texture coordinates
	dc.w	145, $00ff	; Point index, texture coordinates
	dc.w	146, $ff00	; Point index, texture coordinates
	dc.w	147, $ffff	; Point index, texture coordinates

	.long
.vertlist_default:
;* Vertex 0
	dc.w	-135,-119,71	; coordinates
	dc.w	$c315,$ec9c,$02fc	; vertex normal

;* Vertex 1
	dc.w	-19,-87,-40	; coordinates
	dc.w	$e7d8,$ea40,$c8df	; vertex normal

;* Vertex 2
	dc.w	141,-119,-41	; coordinates
	dc.w	$2b59,$211a,$de84	; vertex normal

;* Vertex 3
	dc.w	91,-67,-35	; coordinates
	dc.w	$2e65,$0d4c,$d5f8	; vertex normal

;* Vertex 4
	dc.w	91,-7,-35	; coordinates
	dc.w	$2607,$158f,$d141	; vertex normal

;* Vertex 5
	dc.w	39,48,-35	; coordinates
	dc.w	$fd9a,$3252,$d887	; vertex normal

;* Vertex 6
	dc.w	-19,18,-40	; coordinates
	dc.w	$fbf3,$342c,$db27	; vertex normal

;* Vertex 7
	dc.w	-57,48,4	; coordinates
	dc.w	$d305,$29a7,$ed9f	; vertex normal

;* Vertex 8
	dc.w	-95,-7,40	; coordinates
	dc.w	$c0a0,$08eb,$0034	; vertex normal

;* Vertex 9
	dc.w	-95,-67,40	; coordinates
	dc.w	$c2cc,$11a8,$f9cd	; vertex normal

;* Vertex 10
	dc.w	-122,-119,103	; coordinates
	dc.w	$d4a7,$211a,$217c	; vertex normal

;* Vertex 11
	dc.w	38,-87,102	; coordinates
	dc.w	$0f25,$e424,$3797	; vertex normal

;* Vertex 12
	dc.w	154,-119,-9	; coordinates
	dc.w	$3ceb,$ec9d,$fd04	; vertex normal

;* Vertex 13
	dc.w	114,-67,22	; coordinates
	dc.w	$3c23,$0d8d,$1134	; vertex normal

;* Vertex 14
	dc.w	114,-7,22	; coordinates
	dc.w	$3f51,$094f,$ff73	; vertex normal

;* Vertex 15
	dc.w	76,48,58	; coordinates
	dc.w	$25c5,$3337,$06d4	; vertex normal

;* Vertex 16
	dc.w	38,18,102	; coordinates
	dc.w	$173e,$25ea,$2e06	; vertex normal

;* Vertex 17
	dc.w	-20,48,97	; coordinates
	dc.w	$0265,$3252,$2779	; vertex normal

;* Vertex 18
	dc.w	-72,-7,97	; coordinates
	dc.w	$d9f9,$158f,$2ebf	; vertex normal

;* Vertex 19
	dc.w	-72,-67,97	; coordinates
	dc.w	$d19b,$0d4c,$2a08	; vertex normal

;* Vertex 20
	dc.w	102,-97,-6	; coordinates
	dc.w	$321c,$2248,$ebc1	; vertex normal

;* Vertex 21
	dc.w	-83,-97,68	; coordinates
	dc.w	$cde4,$2248,$143f	; vertex normal

;* Vertex 22
	dc.w	-35,78,-75	; coordinates
	dc.w	$d352,$26a7,$e764	; vertex normal

;* Vertex 23
	dc.w	35,78,-75	; coordinates
	dc.w	$3677,$1e55,$f184	; vertex normal

;* Vertex 24
	dc.w	35,24,-75	; coordinates
	dc.w	$2fdb,$0000,$d581	; vertex normal

;* Vertex 25
	dc.w	-35,24,-75	; coordinates
	dc.w	$c3a1,$0000,$eac1	; vertex normal

;* Vertex 26
	dc.w	-35,78,19	; coordinates
	dc.w	$ca16,$1ed6,$0f72	; vertex normal

;* Vertex 27
	dc.w	35,78,19	; coordinates
	dc.w	$2ecd,$137f,$270f	; vertex normal

;* Vertex 28
	dc.w	35,24,19	; coordinates
	dc.w	$4000,$0000,$0000	; vertex normal

;* Vertex 29
	dc.w	-35,24,19	; coordinates
	dc.w	$dce4,$0000,$ca7d	; vertex normal

;* Vertex 30
	dc.w	0,-1,-94	; coordinates
	dc.w	$f45e,$0000,$c111	; vertex normal

;* Vertex 31
	dc.w	0,93,-94	; coordinates
	dc.w	$0997,$2438,$cc1d	; vertex normal

;* Vertex 32
	dc.w	0,93,34	; coordinates
	dc.w	$fff3,$3ec1,$f36d	; vertex normal

;* Vertex 33
	dc.w	0,-1,34	; coordinates
	dc.w	$0000,$0000,$4000	; vertex normal

;* Vertex 34
	dc.w	29,-132,-747	; coordinates
	dc.w	$130f,$da0f,$2fe3	; vertex normal

;* Vertex 35
	dc.w	-41,-132,-746	; coordinates
	dc.w	$ee95,$da16,$3088	; vertex normal

;* Vertex 36
	dc.w	-5,-68,-677	; coordinates
	dc.w	$0101,$e4f2,$39fe	; vertex normal

;* Vertex 37
	dc.w	-11,-119,-1008	; coordinates
	dc.w	$ff13,$1acd,$c5e4	; vertex normal

;* Vertex 38
	dc.w	-6,-119,-748	; coordinates
	dc.w	$00e6,$dbf9,$34e4	; vertex normal

;* Vertex 39
	dc.w	183,58,-191	; coordinates
	dc.w	$157a,$3c46,$fea2	; vertex normal

;* Vertex 40
	dc.w	97,32,-166	; coordinates
	dc.w	$d6a8,$1c6f,$d845	; vertex normal

;* Vertex 41
	dc.w	97,-58,48	; coordinates
	dc.w	$c4ac,$f978,$1719	; vertex normal

;* Vertex 42
	dc.w	111,-58,48	; coordinates
	dc.w	$3b6a,$f975,$16e0	; vertex normal

;* Vertex 43
	dc.w	183,-28,-212	; coordinates
	dc.w	$1344,$cd96,$dd9a	; vertex normal

;* Vertex 44
	dc.w	97,-17,-178	; coordinates
	dc.w	$d73d,$fa38,$cf00	; vertex normal

;* Vertex 45
	dc.w	164,11,-183	; coordinates
	dc.w	$1baf,$0dae,$c7f1	; vertex normal

;* Vertex 46
	dc.w	-146,-132,-747	; coordinates
	dc.w	$eea0,$25f1,$cf7a	; vertex normal

;* Vertex 47
	dc.w	-216,-132,-749	; coordinates
	dc.w	$131a,$25ea,$d01b	; vertex normal

;* Vertex 48
	dc.w	-182,-68,-679	; coordinates
	dc.w	$0106,$1b0e,$c602	; vertex normal

;* Vertex 49
	dc.w	-176,-119,-1009	; coordinates
	dc.w	$fee6,$e533,$3a1b	; vertex normal

;* Vertex 50
	dc.w	-181,-119,-749	; coordinates
	dc.w	$00f3,$2406,$cb1c	; vertex normal

;* Vertex 51
	dc.w	-8,164,-45	; coordinates
	dc.w	$ea86,$0f4d,$c5af	; vertex normal

;* Vertex 52
	dc.w	-93,147,-76	; coordinates
	dc.w	$2958,$e1a6,$d9b8	; vertex normal

;* Vertex 53
	dc.w	-93,-34,-222	; coordinates
	dc.w	$3b54,$1467,$0ca5	; vertex normal

;* Vertex 54
	dc.w	-80,-34,-222	; coordinates
	dc.w	$c496,$1430,$0c98	; vertex normal

;* Vertex 55
	dc.w	-8,208,-121	; coordinates
	dc.w	$ecbc,$d109,$26fb	; vertex normal

;* Vertex 56
	dc.w	-93,172,-120	; coordinates
	dc.w	$28c3,$cf4e,$f80d	; vertex normal

;* Vertex 57
	dc.w	-27,169,-93	; coordinates
	dc.w	$e451,$cde2,$e366	; vertex normal

;* Vertex 58
	dc.w	0,-42,215	; coordinates
	dc.w	$eeff,$c7bb,$1951	; vertex normal

;* Vertex 59
	dc.w	-38,-7,215	; coordinates
	dc.w	$dcf7,$fbdf,$3566	; vertex normal

;* Vertex 60
	dc.w	-28,42,215	; coordinates
	dc.w	$e363,$333b,$198c	; vertex normal

;* Vertex 61
	dc.w	27,42,215	; coordinates
	dc.w	$254c,$f4bd,$32c6	; vertex normal

;* Vertex 62
	dc.w	38,-7,215	; coordinates
	dc.w	$2ccc,$e78e,$269f	; vertex normal

;* Vertex 63
	dc.w	0,-42,148	; coordinates
	dc.w	$1283,$c2bc,$0000	; vertex normal

;* Vertex 64
	dc.w	-38,-7,157	; coordinates
	dc.w	$c7d2,$e157,$0000	; vertex normal

;* Vertex 65
	dc.w	-28,42,157	; coordinates
	dc.w	$c2bb,$ed80,$0000	; vertex normal

;* Vertex 66
	dc.w	27,42,157	; coordinates
	dc.w	$1bdd,$3995,$fdfa	; vertex normal

;* Vertex 67
	dc.w	38,-7,157	; coordinates
	dc.w	$3f8f,$f883,$0000	; vertex normal

;* Vertex 68
	dc.w	0,57,148	; coordinates
	dc.w	$de15,$cd79,$13cf	; vertex normal

;* Vertex 69
	dc.w	0,57,215	; coordinates
	dc.w	$118a,$e044,$34bd	; vertex normal

;* Vertex 70
	dc.w	-76,-294,48	; coordinates
	dc.w	$f4ab,$cd63,$da81	; vertex normal

;* Vertex 71
	dc.w	-122,-294,89	; coordinates
	dc.w	$d61a,$cfc4,$fc45	; vertex normal

;* Vertex 72
	dc.w	-115,-294,116	; coordinates
	dc.w	$ec21,$d7a0,$2d83	; vertex normal

;* Vertex 73
	dc.w	-38,-294,116	; coordinates
	dc.w	$2ed3,$e7e6,$245e	; vertex normal

;* Vertex 74
	dc.w	-31,-294,89	; coordinates
	dc.w	$2526,$cfc4,$ec44	; vertex normal

;* Vertex 75
	dc.w	-76,-261,48	; coordinates
	dc.w	$0eb7,$353c,$dfaa	; vertex normal

;* Vertex 76
	dc.w	-122,-279,89	; coordinates
	dc.w	$d49f,$2dfa,$f5f7	; vertex normal

;* Vertex 77
	dc.w	-115,-283,116	; coordinates
	dc.w	$d9f9,$2643,$226f	; vertex normal

;* Vertex 78
	dc.w	-38,-283,116	; coordinates
	dc.w	$16d0,$16f4,$3737	; vertex normal

;* Vertex 79
	dc.w	-31,-279,89	; coordinates
	dc.w	$2b35,$2ed2,$061b	; vertex normal

;* Vertex 80
	dc.w	-76,-294,56	; coordinates
	dc.w	$0000,$c000,$0000	; vertex normal

;* Vertex 81
	dc.w	-115,-294,90	; coordinates
	dc.w	$0000,$c000,$0000	; vertex normal

;* Vertex 82
	dc.w	-109,-294,116	; coordinates
	dc.w	$ff9c,$d2bf,$2d41	; vertex normal

;* Vertex 83
	dc.w	-44,-294,116	; coordinates
	dc.w	$0064,$d2bf,$2d41	; vertex normal

;* Vertex 84
	dc.w	-38,-294,90	; coordinates
	dc.w	$0000,$c000,$0000	; vertex normal

;* Vertex 85
	dc.w	-76,-262,56	; coordinates
	dc.w	$ff85,$3ecf,$0c46	; vertex normal

;* Vertex 86
	dc.w	-115,-279,90	; coordinates
	dc.w	$fdf5,$3e66,$0e13	; vertex normal

;* Vertex 87
	dc.w	-109,-283,116	; coordinates
	dc.w	$ff80,$1aea,$3a10	; vertex normal

;* Vertex 88
	dc.w	-44,-283,116	; coordinates
	dc.w	$00f7,$35d5,$229a	; vertex normal

;* Vertex 89
	dc.w	-38,-279,90	; coordinates
	dc.w	$0961,$3e1c,$0c42	; vertex normal

;* Vertex 90
	dc.w	3,-139,214	; coordinates
	dc.w	$e568,$2ce9,$daf6	; vertex normal

;* Vertex 91
	dc.w	5,-139,214	; coordinates
	dc.w	$34ed,$1ee3,$ed88	; vertex normal

;* Vertex 92
	dc.w	15,-185,165	; coordinates
	dc.w	$2490,$f38d,$ccf8	; vertex normal

;* Vertex 93
	dc.w	-6,-185,165	; coordinates
	dc.w	$c3a9,$03b9,$eafe	; vertex normal

;* Vertex 94
	dc.w	3,-139,309	; coordinates
	dc.w	$d39e,$08d7,$2d41	; vertex normal

;* Vertex 95
	dc.w	5,-139,309	; coordinates
	dc.w	$2c49,$0951,$2d41	; vertex normal

;* Vertex 96
	dc.w	15,-185,309	; coordinates
	dc.w	$2bce,$f2d5,$2cc3	; vertex normal

;* Vertex 97
	dc.w	-6,-185,309	; coordinates
	dc.w	$e486,$cd71,$1c04	; vertex normal

;* Vertex 98
	dc.w	-290,-170,-12	; coordinates
	dc.w	$17db,$3974,$f0f9	; vertex normal

;* Vertex 99
	dc.w	-260,-195,18	; coordinates
	dc.w	$2a46,$250f,$1e97	; vertex normal

;* Vertex 100
	dc.w	-292,-324,144	; coordinates
	dc.w	$1342,$03ed,$3ce8	; vertex normal

;* Vertex 101
	dc.w	-318,-333,144	; coordinates
	dc.w	$cc3e,$f1f8,$22ef	; vertex normal

;* Vertex 102
	dc.w	-348,-197,2	; coordinates
	dc.w	$d794,$30ae,$099d	; vertex normal

;* Vertex 103
	dc.w	-282,-192,-33	; coordinates
	dc.w	$0757,$16c6,$c4a4	; vertex normal

;* Vertex 104
	dc.w	-255,-209,5	; coordinates
	dc.w	$3a1f,$fc4e,$e577	; vertex normal

;* Vertex 105
	dc.w	-287,-338,130	; coordinates
	dc.w	$34ac,$dbbf,$02bc	; vertex normal

;* Vertex 106
	dc.w	-313,-348,130	; coordinates
	dc.w	$fa1a,$c410,$15a6	; vertex normal

;* Vertex 107
	dc.w	-337,-227,-26	; coordinates
	dc.w	$e995,$da51,$d161	; vertex normal

;* Vertex 108
	dc.w	137,72,105	; coordinates
	dc.w	$d70b,$004c,$ced2	; vertex normal

;* Vertex 109
	dc.w	157,55,63	; coordinates
	dc.w	$cb24,$229a,$f5c7	; vertex normal

;* Vertex 110
	dc.w	88,-28,-84	; coordinates
	dc.w	$eaf0,$3811,$1690	; vertex normal

;* Vertex 111
	dc.w	61,-29,-85	; coordinates
	dc.w	$3492,$2379,$089c	; vertex normal

;* Vertex 112
	dc.w	73,59,93	; coordinates
	dc.w	$15fc,$1d57,$cb8b	; vertex normal

;* Vertex 113
	dc.w	137,99,89	; coordinates
	dc.w	$f328,$ce10,$da17	; vertex normal

;* Vertex 114
	dc.w	157,73,53	; coordinates
	dc.w	$cb02,$de2a,$0bf2	; vertex normal

;* Vertex 115
	dc.w	88,-10,-94	; coordinates
	dc.w	$da0e,$f07d,$3126	; vertex normal

;* Vertex 116
	dc.w	61,-11,-95	; coordinates
	dc.w	$18a3,$02cf,$3b00	; vertex normal

;* Vertex 117
	dc.w	73,96,72	; coordinates
	dc.w	$22ba,$cb78,$0b6a	; vertex normal

;* Vertex 118
	dc.w	-391,108,-182	; coordinates
	dc.w	$15e2,$d618,$d4dc	; vertex normal

;* Vertex 119
	dc.w	-441,108,-182	; coordinates
	dc.w	$2141,$eaa9,$cda7	; vertex normal

;* Vertex 120
	dc.w	-443,93,-182	; coordinates
	dc.w	$18ca,$ca90,$e6fb	; vertex normal

;* Vertex 121
	dc.w	-458,93,-182	; coordinates
	dc.w	$d4c5,$ed4c,$d4ab	; vertex normal

;* Vertex 122
	dc.w	-456,123,-182	; coordinates
	dc.w	$dda9,$0821,$ca9c	; vertex normal

;* Vertex 123
	dc.w	-391,307,-170	; coordinates
	dc.w	$0b9e,$3ef0,$000f	; vertex normal

;* Vertex 124
	dc.w	-391,108,-159	; coordinates
	dc.w	$1aa0,$e710,$3496	; vertex normal

;* Vertex 125
	dc.w	-441,108,-159	; coordinates
	dc.w	$10a0,$dc28,$3259	; vertex normal

;* Vertex 126
	dc.w	-443,93,-159	; coordinates
	dc.w	$3193,$e02f,$1905	; vertex normal

;* Vertex 127
	dc.w	-458,93,-159	; coordinates
	dc.w	$ea63,$d627,$2b55	; vertex normal

;* Vertex 128
	dc.w	-456,123,-159	; coordinates
	dc.w	$d3a1,$07da,$2d73	; vertex normal

;* Vertex 129
	dc.w	-53,108,-182	; coordinates
	dc.w	$ea1e,$29e8,$2b24	; vertex normal

;* Vertex 130
	dc.w	-102,108,-182	; coordinates
	dc.w	$debf,$1557,$3259	; vertex normal

;* Vertex 131
	dc.w	-104,93,-182	; coordinates
	dc.w	$e736,$3570,$1905	; vertex normal

;* Vertex 132
	dc.w	-119,93,-182	; coordinates
	dc.w	$2b3b,$12b4,$2b55	; vertex normal

;* Vertex 133
	dc.w	-117,123,-182	; coordinates
	dc.w	$2257,$f7df,$3564	; vertex normal

;* Vertex 134
	dc.w	-53,307,-170	; coordinates
	dc.w	$f462,$c110,$fff1	; vertex normal

;* Vertex 135
	dc.w	-53,108,-159	; coordinates
	dc.w	$e560,$18f0,$cb6a	; vertex normal

;* Vertex 136
	dc.w	-102,108,-159	; coordinates
	dc.w	$ef60,$23d8,$cda7	; vertex normal

;* Vertex 137
	dc.w	-104,93,-159	; coordinates
	dc.w	$ce6d,$1fd1,$e6fb	; vertex normal

;* Vertex 138
	dc.w	-119,93,-159	; coordinates
	dc.w	$159d,$29d9,$d4ab	; vertex normal

;* Vertex 139
	dc.w	-117,123,-159	; coordinates
	dc.w	$2c5f,$f826,$d28d	; vertex normal

;* Vertex 140
	dc.w	-5580,1238,-704	; coordinates
	dc.w	$d589,$2f1c,$f76e	; vertex normal

;* Vertex 141
	dc.w	-2588,1238,-4118	; coordinates
	dc.w	$fc69,$1730,$c475	; vertex normal

;* Vertex 142
	dc.w	-2588,1219,-4118	; coordinates
	dc.w	$e853,$d8b8,$d35d	; vertex normal

;* Vertex 143
	dc.w	-5580,1219,-704	; coordinates
	dc.w	$d6bf,$e16e,$2634	; vertex normal

;* Vertex 144
	dc.w	2284,1238,1757	; coordinates
	dc.w	$1098,$124c,$3b0b	; vertex normal

;* Vertex 145
	dc.w	5275,1238,-1657	; coordinates
	dc.w	$1d84,$382e,$f7b5	; vertex normal

;* Vertex 146
	dc.w	5275,1219,-1657	; coordinates
	dc.w	$3804,$e558,$f042	; vertex normal

;* Vertex 147
	dc.w	2284,1219,1757	; coordinates
	dc.w	$0b1f,$cef2,$2793	; vertex normal


	.phrase
.matlist:

; Material 0: AQUA GLAZE
	dc.w	$0fa1, 0
	dc.l	0		; no texture

; Material 1: DARK GRAY LUSTER
	dc.w	$781c, 0
	dc.l	0		; no texture

; Material 2: GOLD
	dc.w	$c88c, 0
	dc.l	0		; no texture

; Material 3: ORANGE MATTE
	dc.w	$f8fe, 0
	dc.l	0		; no texture

; Material 4: BLUE MARBLE
	dc.w	$346c, 0
	dc.l	0		; no texture

; Material 5: BUMPY METAL
	dc.w	$78fe, 0
	dc.l	0		; no texture

; Material 6: BUMPYWHITE STONE
	dc.w	$78fe, 0
	dc.l	0		; no texture

; Material 7: Default Material
	dc.w	$7880, 0
	dc.l	0		; no texture


