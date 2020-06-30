;*========================================
; 3D Library Data File
;*========================================


	.include	'jaguar.inc'

	.data
	.globl	_robotdata
_robotdata:
._default_data:
	dc.w	119		;Number of faces
	dc.w	124		;Number of points
	dc.w	6		;Number of materials
	dc.w	0		; reserved word
	dc.l	.facelist_default
	dc.l	.vertlist_default
	dc.l	.matlist
	.phrase
.facelist_default:
;* Face 0
	dc.w	$0,$c000,$0,$fe36	; face normal
	dc.w	4		; number of points
	dc.w	2		; material CHROME GIFMAP
	dc.w	2, $0000	; Point index, texture coordinates
	dc.w	3, $00ff	; Point index, texture coordinates
	dc.w	0, $ff00	; Point index, texture coordinates
	dc.w	1, $ffff	; Point index, texture coordinates

;* Face 1
	dc.w	$0,$0,$4000,$ff3c	; face normal
	dc.w	4		; number of points
	dc.w	2		; material CHROME GIFMAP
	dc.w	0, $0000	; Point index, texture coordinates
	dc.w	4, $00ff	; Point index, texture coordinates
	dc.w	5, $ff00	; Point index, texture coordinates
	dc.w	1, $ffff	; Point index, texture coordinates

;* Face 2
	dc.w	$4000,$0,$0,$5	; face normal
	dc.w	4		; number of points
	dc.w	2		; material CHROME GIFMAP
	dc.w	1, $0000	; Point index, texture coordinates
	dc.w	5, $00ff	; Point index, texture coordinates
	dc.w	6, $ff00	; Point index, texture coordinates
	dc.w	2, $ffff	; Point index, texture coordinates

;* Face 3
	dc.w	$0,$0,$c000,$92	; face normal
	dc.w	4		; number of points
	dc.w	2		; material CHROME GIFMAP
	dc.w	2, $0000	; Point index, texture coordinates
	dc.w	6, $00ff	; Point index, texture coordinates
	dc.w	7, $ff00	; Point index, texture coordinates
	dc.w	3, $ffff	; Point index, texture coordinates

;* Face 4
	dc.w	$c000,$0,$0,$ffc9	; face normal
	dc.w	4		; number of points
	dc.w	2		; material CHROME GIFMAP
	dc.w	3, $0000	; Point index, texture coordinates
	dc.w	7, $00ff	; Point index, texture coordinates
	dc.w	4, $ff00	; Point index, texture coordinates
	dc.w	0, $ffff	; Point index, texture coordinates

;* Face 5
	dc.w	$0,$4000,$0,$ff8d	; face normal
	dc.w	4		; number of points
	dc.w	2		; material CHROME GIFMAP
	dc.w	4, $0000	; Point index, texture coordinates
	dc.w	7, $00ff	; Point index, texture coordinates
	dc.w	6, $ff00	; Point index, texture coordinates
	dc.w	5, $ffff	; Point index, texture coordinates

;* Face 6
	dc.w	$0,$0,$c000,$1d1	; face normal
	dc.w	3		; number of points
	dc.w	2		; material CHROME GIFMAP
	dc.w	10, $0000	; Point index, texture coordinates
	dc.w	8, $00ff	; Point index, texture coordinates
	dc.w	9, $ff00	; Point index, texture coordinates

;* Face 7
	dc.w	$0,$0,$c000,$1d1	; face normal
	dc.w	3		; number of points
	dc.w	2		; material CHROME GIFMAP
	dc.w	13, $0000	; Point index, texture coordinates
	dc.w	11, $00ff	; Point index, texture coordinates
	dc.w	12, $ff00	; Point index, texture coordinates

;* Face 8
	dc.w	$0,$0,$c000,$1d1	; face normal
	dc.w	3		; number of points
	dc.w	2		; material CHROME GIFMAP
	dc.w	10, $0000	; Point index, texture coordinates
	dc.w	15, $00ff	; Point index, texture coordinates
	dc.w	8, $ff00	; Point index, texture coordinates

;* Face 9
	dc.w	$0,$0,$c000,$1d1	; face normal
	dc.w	3		; number of points
	dc.w	2		; material CHROME GIFMAP
	dc.w	14, $0000	; Point index, texture coordinates
	dc.w	11, $00ff	; Point index, texture coordinates
	dc.w	13, $ff00	; Point index, texture coordinates

;* Face 10
	dc.w	$0,$0,$c000,$1d1	; face normal
	dc.w	4		; number of points
	dc.w	2		; material CHROME GIFMAP
	dc.w	10, $0000	; Point index, texture coordinates
	dc.w	11, $00ff	; Point index, texture coordinates
	dc.w	14, $ff00	; Point index, texture coordinates
	dc.w	15, $ffff	; Point index, texture coordinates

;* Face 11
	dc.w	$0,$c000,$0,$fdc6	; face normal
	dc.w	4		; number of points
	dc.w	2		; material CHROME GIFMAP
	dc.w	8, $0000	; Point index, texture coordinates
	dc.w	16, $00ff	; Point index, texture coordinates
	dc.w	17, $ff00	; Point index, texture coordinates
	dc.w	9, $ffff	; Point index, texture coordinates

;* Face 12
	dc.w	$4000,$0,$0,$50	; face normal
	dc.w	4		; number of points
	dc.w	2		; material CHROME GIFMAP
	dc.w	9, $0000	; Point index, texture coordinates
	dc.w	17, $00ff	; Point index, texture coordinates
	dc.w	18, $ff00	; Point index, texture coordinates
	dc.w	10, $ffff	; Point index, texture coordinates

;* Face 13
	dc.w	$0,$c000,$0,$fe16	; face normal
	dc.w	4		; number of points
	dc.w	2		; material CHROME GIFMAP
	dc.w	10, $0000	; Point index, texture coordinates
	dc.w	18, $00ff	; Point index, texture coordinates
	dc.w	19, $ff00	; Point index, texture coordinates
	dc.w	11, $ffff	; Point index, texture coordinates

;* Face 14
	dc.w	$c000,$0,$0,$0	; face normal
	dc.w	4		; number of points
	dc.w	2		; material CHROME GIFMAP
	dc.w	11, $0000	; Point index, texture coordinates
	dc.w	19, $00ff	; Point index, texture coordinates
	dc.w	20, $ff00	; Point index, texture coordinates
	dc.w	12, $ffff	; Point index, texture coordinates

;* Face 15
	dc.w	$0,$c000,$0,$fdc6	; face normal
	dc.w	4		; number of points
	dc.w	2		; material CHROME GIFMAP
	dc.w	12, $0000	; Point index, texture coordinates
	dc.w	20, $00ff	; Point index, texture coordinates
	dc.w	21, $ff00	; Point index, texture coordinates
	dc.w	13, $ffff	; Point index, texture coordinates

;* Face 16
	dc.w	$4000,$0,$0,$ffd8	; face normal
	dc.w	4		; number of points
	dc.w	2		; material CHROME GIFMAP
	dc.w	13, $0000	; Point index, texture coordinates
	dc.w	21, $00ff	; Point index, texture coordinates
	dc.w	22, $ff00	; Point index, texture coordinates
	dc.w	14, $ffff	; Point index, texture coordinates

;* Face 17
	dc.w	$0,$4000,$0,$1cc	; face normal
	dc.w	4		; number of points
	dc.w	2		; material CHROME GIFMAP
	dc.w	14, $0000	; Point index, texture coordinates
	dc.w	22, $00ff	; Point index, texture coordinates
	dc.w	23, $ff00	; Point index, texture coordinates
	dc.w	15, $ffff	; Point index, texture coordinates

;* Face 18
	dc.w	$c000,$0,$0,$ff88	; face normal
	dc.w	4		; number of points
	dc.w	2		; material CHROME GIFMAP
	dc.w	15, $0000	; Point index, texture coordinates
	dc.w	23, $00ff	; Point index, texture coordinates
	dc.w	16, $ff00	; Point index, texture coordinates
	dc.w	8, $ffff	; Point index, texture coordinates

;* Face 19
	dc.w	$0,$0,$4000,$fdcb	; face normal
	dc.w	3		; number of points
	dc.w	2		; material CHROME GIFMAP
	dc.w	16, $0000	; Point index, texture coordinates
	dc.w	18, $00ff	; Point index, texture coordinates
	dc.w	17, $ff00	; Point index, texture coordinates

;* Face 20
	dc.w	$0,$0,$4000,$fdcb	; face normal
	dc.w	3		; number of points
	dc.w	2		; material CHROME GIFMAP
	dc.w	19, $0000	; Point index, texture coordinates
	dc.w	21, $00ff	; Point index, texture coordinates
	dc.w	20, $ff00	; Point index, texture coordinates

;* Face 21
	dc.w	$0,$0,$4000,$fdcb	; face normal
	dc.w	3		; number of points
	dc.w	2		; material CHROME GIFMAP
	dc.w	23, $0000	; Point index, texture coordinates
	dc.w	18, $00ff	; Point index, texture coordinates
	dc.w	16, $ff00	; Point index, texture coordinates

;* Face 22
	dc.w	$0,$0,$4000,$fdcb	; face normal
	dc.w	3		; number of points
	dc.w	2		; material CHROME GIFMAP
	dc.w	19, $0000	; Point index, texture coordinates
	dc.w	22, $00ff	; Point index, texture coordinates
	dc.w	21, $ff00	; Point index, texture coordinates

;* Face 23
	dc.w	$0,$0,$4000,$fdcb	; face normal
	dc.w	4		; number of points
	dc.w	2		; material CHROME GIFMAP
	dc.w	22, $0000	; Point index, texture coordinates
	dc.w	19, $00ff	; Point index, texture coordinates
	dc.w	18, $ff00	; Point index, texture coordinates
	dc.w	23, $ffff	; Point index, texture coordinates

;* Face 24
	dc.w	$0,$0,$c000,$5a	; face normal
	dc.w	4		; number of points
	dc.w	0		; material CREAM PLASTIC
	dc.w	24, $0000	; Point index, texture coordinates
	dc.w	27, $00ff	; Point index, texture coordinates
	dc.w	26, $ff00	; Point index, texture coordinates
	dc.w	25, $ffff	; Point index, texture coordinates

;* Face 25
	dc.w	$0,$4000,$0,$17c	; face normal
	dc.w	4		; number of points
	dc.w	0		; material CREAM PLASTIC
	dc.w	24, $0000	; Point index, texture coordinates
	dc.w	25, $00ff	; Point index, texture coordinates
	dc.w	29, $ff00	; Point index, texture coordinates
	dc.w	28, $ffff	; Point index, texture coordinates

;* Face 26
	dc.w	$4000,$0,$0,$0	; face normal
	dc.w	4		; number of points
	dc.w	0		; material CREAM PLASTIC
	dc.w	25, $0000	; Point index, texture coordinates
	dc.w	26, $00ff	; Point index, texture coordinates
	dc.w	30, $ff00	; Point index, texture coordinates
	dc.w	29, $ffff	; Point index, texture coordinates

;* Face 27
	dc.w	$0,$c000,$0,$fe34	; face normal
	dc.w	4		; number of points
	dc.w	0		; material CREAM PLASTIC
	dc.w	26, $0000	; Point index, texture coordinates
	dc.w	27, $00ff	; Point index, texture coordinates
	dc.w	31, $ff00	; Point index, texture coordinates
	dc.w	30, $ffff	; Point index, texture coordinates

;* Face 28
	dc.w	$c000,$0,$0,$ffb0	; face normal
	dc.w	4		; number of points
	dc.w	0		; material CREAM PLASTIC
	dc.w	27, $0000	; Point index, texture coordinates
	dc.w	24, $00ff	; Point index, texture coordinates
	dc.w	28, $ff00	; Point index, texture coordinates
	dc.w	31, $ffff	; Point index, texture coordinates

;* Face 29
	dc.w	$0,$0,$4000,$fd12	; face normal
	dc.w	4		; number of points
	dc.w	0		; material CREAM PLASTIC
	dc.w	28, $0000	; Point index, texture coordinates
	dc.w	29, $00ff	; Point index, texture coordinates
	dc.w	30, $ff00	; Point index, texture coordinates
	dc.w	31, $ffff	; Point index, texture coordinates

;* Face 30
	dc.w	$0,$0,$4000,$fe8e	; face normal
	dc.w	4		; number of points
	dc.w	2		; material CHROME GIFMAP
	dc.w	34, $0000	; Point index, texture coordinates
	dc.w	35, $00ff	; Point index, texture coordinates
	dc.w	32, $ff00	; Point index, texture coordinates
	dc.w	33, $ffff	; Point index, texture coordinates

;* Face 31
	dc.w	$0,$4000,$0,$3b	; face normal
	dc.w	4		; number of points
	dc.w	2		; material CHROME GIFMAP
	dc.w	32, $0000	; Point index, texture coordinates
	dc.w	36, $00ff	; Point index, texture coordinates
	dc.w	37, $ff00	; Point index, texture coordinates
	dc.w	33, $ffff	; Point index, texture coordinates

;* Face 32
	dc.w	$4000,$0,$0,$10	; face normal
	dc.w	4		; number of points
	dc.w	2		; material CHROME GIFMAP
	dc.w	33, $0000	; Point index, texture coordinates
	dc.w	37, $00ff	; Point index, texture coordinates
	dc.w	38, $ff00	; Point index, texture coordinates
	dc.w	34, $ffff	; Point index, texture coordinates

;* Face 33
	dc.w	$0,$c000,$0,$ff93	; face normal
	dc.w	4		; number of points
	dc.w	2		; material CHROME GIFMAP
	dc.w	34, $0000	; Point index, texture coordinates
	dc.w	38, $00ff	; Point index, texture coordinates
	dc.w	39, $ff00	; Point index, texture coordinates
	dc.w	35, $ffff	; Point index, texture coordinates

;* Face 34
	dc.w	$c000,$0,$0,$ffbe	; face normal
	dc.w	4		; number of points
	dc.w	2		; material CHROME GIFMAP
	dc.w	35, $0000	; Point index, texture coordinates
	dc.w	39, $00ff	; Point index, texture coordinates
	dc.w	36, $ff00	; Point index, texture coordinates
	dc.w	32, $ffff	; Point index, texture coordinates

;* Face 35
	dc.w	$0,$0,$c000,$ff35	; face normal
	dc.w	4		; number of points
	dc.w	2		; material CHROME GIFMAP
	dc.w	36, $0000	; Point index, texture coordinates
	dc.w	39, $00ff	; Point index, texture coordinates
	dc.w	38, $ff00	; Point index, texture coordinates
	dc.w	37, $ffff	; Point index, texture coordinates

;* Face 36
	dc.w	$0,$4000,$0,$fecf	; face normal
	dc.w	3		; number of points
	dc.w	5		; material BRASS GIFMAP
	dc.w	42, $0000	; Point index, texture coordinates
	dc.w	40, $00ff	; Point index, texture coordinates
	dc.w	41, $ff00	; Point index, texture coordinates

;* Face 37
	dc.w	$0,$4000,$0,$fecf	; face normal
	dc.w	3		; number of points
	dc.w	5		; material BRASS GIFMAP
	dc.w	45, $0000	; Point index, texture coordinates
	dc.w	43, $00ff	; Point index, texture coordinates
	dc.w	44, $ff00	; Point index, texture coordinates

;* Face 38
	dc.w	$0,$4000,$0,$fecf	; face normal
	dc.w	3		; number of points
	dc.w	5		; material BRASS GIFMAP
	dc.w	42, $0000	; Point index, texture coordinates
	dc.w	47, $00ff	; Point index, texture coordinates
	dc.w	40, $ff00	; Point index, texture coordinates

;* Face 39
	dc.w	$0,$4000,$0,$fecf	; face normal
	dc.w	3		; number of points
	dc.w	5		; material BRASS GIFMAP
	dc.w	46, $0000	; Point index, texture coordinates
	dc.w	43, $00ff	; Point index, texture coordinates
	dc.w	45, $ff00	; Point index, texture coordinates

;* Face 40
	dc.w	$0,$4000,$0,$fecf	; face normal
	dc.w	4		; number of points
	dc.w	5		; material BRASS GIFMAP
	dc.w	42, $0000	; Point index, texture coordinates
	dc.w	43, $00ff	; Point index, texture coordinates
	dc.w	46, $ff00	; Point index, texture coordinates
	dc.w	47, $ffff	; Point index, texture coordinates

;* Face 41
	dc.w	$0,$0,$c000,$feca	; face normal
	dc.w	4		; number of points
	dc.w	5		; material BRASS GIFMAP
	dc.w	40, $0000	; Point index, texture coordinates
	dc.w	48, $00ff	; Point index, texture coordinates
	dc.w	49, $ff00	; Point index, texture coordinates
	dc.w	41, $ffff	; Point index, texture coordinates

;* Face 42
	dc.w	$4000,$0,$0,$50	; face normal
	dc.w	4		; number of points
	dc.w	5		; material BRASS GIFMAP
	dc.w	41, $0000	; Point index, texture coordinates
	dc.w	49, $00ff	; Point index, texture coordinates
	dc.w	50, $ff00	; Point index, texture coordinates
	dc.w	42, $ffff	; Point index, texture coordinates

;* Face 43
	dc.w	$0,$0,$c000,$ff1a	; face normal
	dc.w	4		; number of points
	dc.w	5		; material BRASS GIFMAP
	dc.w	42, $0000	; Point index, texture coordinates
	dc.w	50, $00ff	; Point index, texture coordinates
	dc.w	51, $ff00	; Point index, texture coordinates
	dc.w	43, $ffff	; Point index, texture coordinates

;* Face 44
	dc.w	$c000,$0,$0,$0	; face normal
	dc.w	4		; number of points
	dc.w	5		; material BRASS GIFMAP
	dc.w	43, $0000	; Point index, texture coordinates
	dc.w	51, $00ff	; Point index, texture coordinates
	dc.w	52, $ff00	; Point index, texture coordinates
	dc.w	44, $ffff	; Point index, texture coordinates

;* Face 45
	dc.w	$0,$0,$c000,$feca	; face normal
	dc.w	4		; number of points
	dc.w	5		; material BRASS GIFMAP
	dc.w	44, $0000	; Point index, texture coordinates
	dc.w	52, $00ff	; Point index, texture coordinates
	dc.w	53, $ff00	; Point index, texture coordinates
	dc.w	45, $ffff	; Point index, texture coordinates

;* Face 46
	dc.w	$4000,$0,$0,$ffd8	; face normal
	dc.w	4		; number of points
	dc.w	5		; material BRASS GIFMAP
	dc.w	45, $0000	; Point index, texture coordinates
	dc.w	53, $00ff	; Point index, texture coordinates
	dc.w	54, $ff00	; Point index, texture coordinates
	dc.w	46, $ffff	; Point index, texture coordinates

;* Face 47
	dc.w	$0,$0,$4000,$c8	; face normal
	dc.w	4		; number of points
	dc.w	5		; material BRASS GIFMAP
	dc.w	46, $0000	; Point index, texture coordinates
	dc.w	54, $00ff	; Point index, texture coordinates
	dc.w	55, $ff00	; Point index, texture coordinates
	dc.w	47, $ffff	; Point index, texture coordinates

;* Face 48
	dc.w	$c000,$0,$0,$ff88	; face normal
	dc.w	4		; number of points
	dc.w	5		; material BRASS GIFMAP
	dc.w	47, $0000	; Point index, texture coordinates
	dc.w	55, $00ff	; Point index, texture coordinates
	dc.w	48, $ff00	; Point index, texture coordinates
	dc.w	40, $ffff	; Point index, texture coordinates

;* Face 49
	dc.w	$0,$c000,$0,$cd	; face normal
	dc.w	3		; number of points
	dc.w	5		; material BRASS GIFMAP
	dc.w	48, $0000	; Point index, texture coordinates
	dc.w	50, $00ff	; Point index, texture coordinates
	dc.w	49, $ff00	; Point index, texture coordinates

;* Face 50
	dc.w	$0,$c000,$0,$cd	; face normal
	dc.w	3		; number of points
	dc.w	5		; material BRASS GIFMAP
	dc.w	51, $0000	; Point index, texture coordinates
	dc.w	53, $00ff	; Point index, texture coordinates
	dc.w	52, $ff00	; Point index, texture coordinates

;* Face 51
	dc.w	$0,$c000,$0,$cd	; face normal
	dc.w	3		; number of points
	dc.w	5		; material BRASS GIFMAP
	dc.w	55, $0000	; Point index, texture coordinates
	dc.w	50, $00ff	; Point index, texture coordinates
	dc.w	48, $ff00	; Point index, texture coordinates

;* Face 52
	dc.w	$0,$c000,$0,$cd	; face normal
	dc.w	3		; number of points
	dc.w	5		; material BRASS GIFMAP
	dc.w	51, $0000	; Point index, texture coordinates
	dc.w	54, $00ff	; Point index, texture coordinates
	dc.w	53, $ff00	; Point index, texture coordinates

;* Face 53
	dc.w	$0,$c000,$0,$cd	; face normal
	dc.w	4		; number of points
	dc.w	5		; material BRASS GIFMAP
	dc.w	54, $0000	; Point index, texture coordinates
	dc.w	51, $00ff	; Point index, texture coordinates
	dc.w	50, $ff00	; Point index, texture coordinates
	dc.w	55, $ffff	; Point index, texture coordinates

;* Face 54
	dc.w	$0,$4000,$0,$ff07	; face normal
	dc.w	3		; number of points
	dc.w	1		; material GOLD
	dc.w	58, $0000	; Point index, texture coordinates
	dc.w	56, $00ff	; Point index, texture coordinates
	dc.w	57, $ff00	; Point index, texture coordinates

;* Face 55
	dc.w	$0,$4000,$0,$ff07	; face normal
	dc.w	3		; number of points
	dc.w	1		; material GOLD
	dc.w	60, $0000	; Point index, texture coordinates
	dc.w	58, $00ff	; Point index, texture coordinates
	dc.w	59, $ff00	; Point index, texture coordinates

;* Face 56
	dc.w	$0,$4000,$0,$ff07	; face normal
	dc.w	3		; number of points
	dc.w	1		; material GOLD
	dc.w	62, $0000	; Point index, texture coordinates
	dc.w	60, $00ff	; Point index, texture coordinates
	dc.w	61, $ff00	; Point index, texture coordinates

;* Face 57
	dc.w	$0,$4000,$0,$ff07	; face normal
	dc.w	3		; number of points
	dc.w	1		; material GOLD
	dc.w	56, $0000	; Point index, texture coordinates
	dc.w	62, $00ff	; Point index, texture coordinates
	dc.w	63, $ff00	; Point index, texture coordinates

;* Face 58
	dc.w	$0,$4000,$0,$ff07	; face normal
	dc.w	4		; number of points
	dc.w	1		; material GOLD
	dc.w	60, $0000	; Point index, texture coordinates
	dc.w	62, $00ff	; Point index, texture coordinates
	dc.w	56, $ff00	; Point index, texture coordinates
	dc.w	58, $ffff	; Point index, texture coordinates

;* Face 59
	dc.w	$39ec,$f322,$17fe,$ffbc	; face normal
	dc.w	4		; number of points
	dc.w	1		; material GOLD
	dc.w	56, $0000	; Point index, texture coordinates
	dc.w	64, $00ff	; Point index, texture coordinates
	dc.w	65, $ff00	; Point index, texture coordinates
	dc.w	57, $ffff	; Point index, texture coordinates

;* Face 60
	dc.w	$17fe,$f322,$39ec,$ff9e	; face normal
	dc.w	4		; number of points
	dc.w	1		; material GOLD
	dc.w	57, $0000	; Point index, texture coordinates
	dc.w	65, $00ff	; Point index, texture coordinates
	dc.w	66, $ff00	; Point index, texture coordinates
	dc.w	58, $ffff	; Point index, texture coordinates

;* Face 61
	dc.w	$e802,$f322,$39ec,$ff87	; face normal
	dc.w	4		; number of points
	dc.w	1		; material GOLD
	dc.w	58, $0000	; Point index, texture coordinates
	dc.w	66, $00ff	; Point index, texture coordinates
	dc.w	67, $ff00	; Point index, texture coordinates
	dc.w	59, $ffff	; Point index, texture coordinates

;* Face 62
	dc.w	$c614,$f322,$17fe,$ff85	; face normal
	dc.w	4		; number of points
	dc.w	1		; material GOLD
	dc.w	59, $0000	; Point index, texture coordinates
	dc.w	67, $00ff	; Point index, texture coordinates
	dc.w	68, $ff00	; Point index, texture coordinates
	dc.w	60, $ffff	; Point index, texture coordinates

;* Face 63
	dc.w	$c614,$f322,$e802,$ff99	; face normal
	dc.w	4		; number of points
	dc.w	1		; material GOLD
	dc.w	60, $0000	; Point index, texture coordinates
	dc.w	68, $00ff	; Point index, texture coordinates
	dc.w	69, $ff00	; Point index, texture coordinates
	dc.w	61, $ffff	; Point index, texture coordinates

;* Face 64
	dc.w	$e802,$f322,$c614,$ffb7	; face normal
	dc.w	4		; number of points
	dc.w	1		; material GOLD
	dc.w	61, $0000	; Point index, texture coordinates
	dc.w	69, $00ff	; Point index, texture coordinates
	dc.w	70, $ff00	; Point index, texture coordinates
	dc.w	62, $ffff	; Point index, texture coordinates

;* Face 65
	dc.w	$17fe,$f322,$c614,$ffce	; face normal
	dc.w	4		; number of points
	dc.w	1		; material GOLD
	dc.w	62, $0000	; Point index, texture coordinates
	dc.w	70, $00ff	; Point index, texture coordinates
	dc.w	71, $ff00	; Point index, texture coordinates
	dc.w	63, $ffff	; Point index, texture coordinates

;* Face 66
	dc.w	$39ec,$f322,$e802,$ffd0	; face normal
	dc.w	4		; number of points
	dc.w	1		; material GOLD
	dc.w	63, $0000	; Point index, texture coordinates
	dc.w	71, $00ff	; Point index, texture coordinates
	dc.w	64, $ff00	; Point index, texture coordinates
	dc.w	56, $ffff	; Point index, texture coordinates

;* Face 67
	dc.w	$3a05,$f3ab,$1808,$ffba	; face normal
	dc.w	4		; number of points
	dc.w	1		; material GOLD
	dc.w	64, $0000	; Point index, texture coordinates
	dc.w	72, $00ff	; Point index, texture coordinates
	dc.w	73, $ff00	; Point index, texture coordinates
	dc.w	65, $ffff	; Point index, texture coordinates

;* Face 68
	dc.w	$1808,$f3ab,$3a05,$ff9c	; face normal
	dc.w	4		; number of points
	dc.w	1		; material GOLD
	dc.w	65, $0000	; Point index, texture coordinates
	dc.w	73, $00ff	; Point index, texture coordinates
	dc.w	74, $ff00	; Point index, texture coordinates
	dc.w	66, $ffff	; Point index, texture coordinates

;* Face 69
	dc.w	$e7f8,$f3ab,$3a05,$ff85	; face normal
	dc.w	4		; number of points
	dc.w	1		; material GOLD
	dc.w	66, $0000	; Point index, texture coordinates
	dc.w	74, $00ff	; Point index, texture coordinates
	dc.w	75, $ff00	; Point index, texture coordinates
	dc.w	67, $ffff	; Point index, texture coordinates

;* Face 70
	dc.w	$c5fb,$f3ab,$1808,$ff83	; face normal
	dc.w	4		; number of points
	dc.w	1		; material GOLD
	dc.w	67, $0000	; Point index, texture coordinates
	dc.w	75, $00ff	; Point index, texture coordinates
	dc.w	76, $ff00	; Point index, texture coordinates
	dc.w	68, $ffff	; Point index, texture coordinates

;* Face 71
	dc.w	$c5fb,$f3ab,$e7f8,$ff97	; face normal
	dc.w	4		; number of points
	dc.w	1		; material GOLD
	dc.w	68, $0000	; Point index, texture coordinates
	dc.w	76, $00ff	; Point index, texture coordinates
	dc.w	77, $ff00	; Point index, texture coordinates
	dc.w	69, $ffff	; Point index, texture coordinates

;* Face 72
	dc.w	$e7f8,$f3ab,$c5fb,$ffb5	; face normal
	dc.w	4		; number of points
	dc.w	1		; material GOLD
	dc.w	69, $0000	; Point index, texture coordinates
	dc.w	77, $00ff	; Point index, texture coordinates
	dc.w	78, $ff00	; Point index, texture coordinates
	dc.w	70, $ffff	; Point index, texture coordinates

;* Face 73
	dc.w	$1808,$f3ab,$c5fb,$ffcc	; face normal
	dc.w	4		; number of points
	dc.w	1		; material GOLD
	dc.w	70, $0000	; Point index, texture coordinates
	dc.w	78, $00ff	; Point index, texture coordinates
	dc.w	79, $ff00	; Point index, texture coordinates
	dc.w	71, $ffff	; Point index, texture coordinates

;* Face 74
	dc.w	$3a05,$f3ab,$e7f8,$ffce	; face normal
	dc.w	4		; number of points
	dc.w	1		; material GOLD
	dc.w	71, $0000	; Point index, texture coordinates
	dc.w	79, $00ff	; Point index, texture coordinates
	dc.w	72, $ff00	; Point index, texture coordinates
	dc.w	64, $ffff	; Point index, texture coordinates

;* Face 75
	dc.w	$3a7c,$f698,$183a,$ffb7	; face normal
	dc.w	4		; number of points
	dc.w	1		; material GOLD
	dc.w	72, $0000	; Point index, texture coordinates
	dc.w	80, $00ff	; Point index, texture coordinates
	dc.w	81, $ff00	; Point index, texture coordinates
	dc.w	73, $ffff	; Point index, texture coordinates

;* Face 76
	dc.w	$183a,$f698,$3a7c,$ff98	; face normal
	dc.w	4		; number of points
	dc.w	1		; material GOLD
	dc.w	73, $0000	; Point index, texture coordinates
	dc.w	81, $00ff	; Point index, texture coordinates
	dc.w	82, $ff00	; Point index, texture coordinates
	dc.w	74, $ffff	; Point index, texture coordinates

;* Face 77
	dc.w	$e7c6,$f698,$3a7c,$ff81	; face normal
	dc.w	4		; number of points
	dc.w	1		; material GOLD
	dc.w	74, $0000	; Point index, texture coordinates
	dc.w	82, $00ff	; Point index, texture coordinates
	dc.w	83, $ff00	; Point index, texture coordinates
	dc.w	75, $ffff	; Point index, texture coordinates

;* Face 78
	dc.w	$c584,$f698,$183a,$ff7f	; face normal
	dc.w	4		; number of points
	dc.w	1		; material GOLD
	dc.w	75, $0000	; Point index, texture coordinates
	dc.w	83, $00ff	; Point index, texture coordinates
	dc.w	84, $ff00	; Point index, texture coordinates
	dc.w	76, $ffff	; Point index, texture coordinates

;* Face 79
	dc.w	$c584,$f698,$e7c6,$ff93	; face normal
	dc.w	4		; number of points
	dc.w	1		; material GOLD
	dc.w	76, $0000	; Point index, texture coordinates
	dc.w	84, $00ff	; Point index, texture coordinates
	dc.w	85, $ff00	; Point index, texture coordinates
	dc.w	77, $ffff	; Point index, texture coordinates

;* Face 80
	dc.w	$e7c6,$f698,$c584,$ffb2	; face normal
	dc.w	4		; number of points
	dc.w	1		; material GOLD
	dc.w	77, $0000	; Point index, texture coordinates
	dc.w	85, $00ff	; Point index, texture coordinates
	dc.w	86, $ff00	; Point index, texture coordinates
	dc.w	78, $ffff	; Point index, texture coordinates

;* Face 81
	dc.w	$183a,$f698,$c584,$ffc9	; face normal
	dc.w	4		; number of points
	dc.w	1		; material GOLD
	dc.w	78, $0000	; Point index, texture coordinates
	dc.w	86, $00ff	; Point index, texture coordinates
	dc.w	87, $ff00	; Point index, texture coordinates
	dc.w	79, $ffff	; Point index, texture coordinates

;* Face 82
	dc.w	$3a7c,$f698,$e7c6,$ffcb	; face normal
	dc.w	4		; number of points
	dc.w	1		; material GOLD
	dc.w	79, $0000	; Point index, texture coordinates
	dc.w	87, $00ff	; Point index, texture coordinates
	dc.w	80, $ff00	; Point index, texture coordinates
	dc.w	72, $ffff	; Point index, texture coordinates

;* Face 83
	dc.w	$3aee,$fac3,$1869,$ffb8	; face normal
	dc.w	4		; number of points
	dc.w	1		; material GOLD
	dc.w	80, $0000	; Point index, texture coordinates
	dc.w	88, $00ff	; Point index, texture coordinates
	dc.w	89, $ff00	; Point index, texture coordinates
	dc.w	81, $ffff	; Point index, texture coordinates

;* Face 84
	dc.w	$1869,$fac3,$3aee,$ff99	; face normal
	dc.w	4		; number of points
	dc.w	1		; material GOLD
	dc.w	81, $0000	; Point index, texture coordinates
	dc.w	89, $00ff	; Point index, texture coordinates
	dc.w	90, $ff00	; Point index, texture coordinates
	dc.w	82, $ffff	; Point index, texture coordinates

;* Face 85
	dc.w	$e797,$fac3,$3aee,$ff82	; face normal
	dc.w	4		; number of points
	dc.w	1		; material GOLD
	dc.w	82, $0000	; Point index, texture coordinates
	dc.w	90, $00ff	; Point index, texture coordinates
	dc.w	91, $ff00	; Point index, texture coordinates
	dc.w	83, $ffff	; Point index, texture coordinates

;* Face 86
	dc.w	$c512,$fac3,$1869,$ff80	; face normal
	dc.w	4		; number of points
	dc.w	1		; material GOLD
	dc.w	83, $0000	; Point index, texture coordinates
	dc.w	91, $00ff	; Point index, texture coordinates
	dc.w	92, $ff00	; Point index, texture coordinates
	dc.w	84, $ffff	; Point index, texture coordinates

;* Face 87
	dc.w	$c512,$fac3,$e797,$ff94	; face normal
	dc.w	4		; number of points
	dc.w	1		; material GOLD
	dc.w	84, $0000	; Point index, texture coordinates
	dc.w	92, $00ff	; Point index, texture coordinates
	dc.w	93, $ff00	; Point index, texture coordinates
	dc.w	85, $ffff	; Point index, texture coordinates

;* Face 88
	dc.w	$e797,$fac3,$c512,$ffb3	; face normal
	dc.w	4		; number of points
	dc.w	1		; material GOLD
	dc.w	85, $0000	; Point index, texture coordinates
	dc.w	93, $00ff	; Point index, texture coordinates
	dc.w	94, $ff00	; Point index, texture coordinates
	dc.w	86, $ffff	; Point index, texture coordinates

;* Face 89
	dc.w	$1869,$fac3,$c512,$ffca	; face normal
	dc.w	4		; number of points
	dc.w	1		; material GOLD
	dc.w	86, $0000	; Point index, texture coordinates
	dc.w	94, $00ff	; Point index, texture coordinates
	dc.w	95, $ff00	; Point index, texture coordinates
	dc.w	87, $ffff	; Point index, texture coordinates

;* Face 90
	dc.w	$3aee,$fac3,$e797,$ffcc	; face normal
	dc.w	4		; number of points
	dc.w	1		; material GOLD
	dc.w	87, $0000	; Point index, texture coordinates
	dc.w	95, $00ff	; Point index, texture coordinates
	dc.w	88, $ff00	; Point index, texture coordinates
	dc.w	80, $ffff	; Point index, texture coordinates

;* Face 91
	dc.w	$3b00,$fbc7,$1870,$ffba	; face normal
	dc.w	4		; number of points
	dc.w	1		; material GOLD
	dc.w	88, $0000	; Point index, texture coordinates
	dc.w	96, $00ff	; Point index, texture coordinates
	dc.w	97, $ff00	; Point index, texture coordinates
	dc.w	89, $ffff	; Point index, texture coordinates

;* Face 92
	dc.w	$1870,$fbc7,$3b00,$ff9b	; face normal
	dc.w	4		; number of points
	dc.w	1		; material GOLD
	dc.w	89, $0000	; Point index, texture coordinates
	dc.w	97, $00ff	; Point index, texture coordinates
	dc.w	98, $ff00	; Point index, texture coordinates
	dc.w	90, $ffff	; Point index, texture coordinates

;* Face 93
	dc.w	$e790,$fbc7,$3b00,$ff84	; face normal
	dc.w	4		; number of points
	dc.w	1		; material GOLD
	dc.w	90, $0000	; Point index, texture coordinates
	dc.w	98, $00ff	; Point index, texture coordinates
	dc.w	99, $ff00	; Point index, texture coordinates
	dc.w	91, $ffff	; Point index, texture coordinates

;* Face 94
	dc.w	$c500,$fbc7,$1870,$ff82	; face normal
	dc.w	4		; number of points
	dc.w	1		; material GOLD
	dc.w	91, $0000	; Point index, texture coordinates
	dc.w	99, $00ff	; Point index, texture coordinates
	dc.w	100, $ff00	; Point index, texture coordinates
	dc.w	92, $ffff	; Point index, texture coordinates

;* Face 95
	dc.w	$c500,$fbc7,$e790,$ff96	; face normal
	dc.w	4		; number of points
	dc.w	1		; material GOLD
	dc.w	92, $0000	; Point index, texture coordinates
	dc.w	100, $00ff	; Point index, texture coordinates
	dc.w	101, $ff00	; Point index, texture coordinates
	dc.w	93, $ffff	; Point index, texture coordinates

;* Face 96
	dc.w	$e790,$fbc7,$c500,$ffb5	; face normal
	dc.w	4		; number of points
	dc.w	1		; material GOLD
	dc.w	93, $0000	; Point index, texture coordinates
	dc.w	101, $00ff	; Point index, texture coordinates
	dc.w	102, $ff00	; Point index, texture coordinates
	dc.w	94, $ffff	; Point index, texture coordinates

;* Face 97
	dc.w	$1870,$fbc7,$c500,$ffcc	; face normal
	dc.w	4		; number of points
	dc.w	1		; material GOLD
	dc.w	94, $0000	; Point index, texture coordinates
	dc.w	102, $00ff	; Point index, texture coordinates
	dc.w	103, $ff00	; Point index, texture coordinates
	dc.w	95, $ffff	; Point index, texture coordinates

;* Face 98
	dc.w	$3b00,$fbc7,$e790,$ffce	; face normal
	dc.w	4		; number of points
	dc.w	1		; material GOLD
	dc.w	95, $0000	; Point index, texture coordinates
	dc.w	103, $00ff	; Point index, texture coordinates
	dc.w	96, $ff00	; Point index, texture coordinates
	dc.w	88, $ffff	; Point index, texture coordinates

;* Face 99
	dc.w	$3b08,$fc55,$1874,$ffbb	; face normal
	dc.w	4		; number of points
	dc.w	1		; material GOLD
	dc.w	96, $0000	; Point index, texture coordinates
	dc.w	104, $00ff	; Point index, texture coordinates
	dc.w	105, $ff00	; Point index, texture coordinates
	dc.w	97, $ffff	; Point index, texture coordinates

;* Face 100
	dc.w	$1874,$fc55,$3b08,$ff9d	; face normal
	dc.w	4		; number of points
	dc.w	1		; material GOLD
	dc.w	97, $0000	; Point index, texture coordinates
	dc.w	105, $00ff	; Point index, texture coordinates
	dc.w	106, $ff00	; Point index, texture coordinates
	dc.w	98, $ffff	; Point index, texture coordinates

;* Face 101
	dc.w	$e78c,$fc55,$3b08,$ff86	; face normal
	dc.w	4		; number of points
	dc.w	1		; material GOLD
	dc.w	98, $0000	; Point index, texture coordinates
	dc.w	106, $00ff	; Point index, texture coordinates
	dc.w	107, $ff00	; Point index, texture coordinates
	dc.w	99, $ffff	; Point index, texture coordinates

;* Face 102
	dc.w	$c4f8,$fc55,$1874,$ff84	; face normal
	dc.w	4		; number of points
	dc.w	1		; material GOLD
	dc.w	99, $0000	; Point index, texture coordinates
	dc.w	107, $00ff	; Point index, texture coordinates
	dc.w	108, $ff00	; Point index, texture coordinates
	dc.w	100, $ffff	; Point index, texture coordinates

;* Face 103
	dc.w	$c4f8,$fc55,$e78c,$ff98	; face normal
	dc.w	4		; number of points
	dc.w	1		; material GOLD
	dc.w	100, $0000	; Point index, texture coordinates
	dc.w	108, $00ff	; Point index, texture coordinates
	dc.w	109, $ff00	; Point index, texture coordinates
	dc.w	101, $ffff	; Point index, texture coordinates

;* Face 104
	dc.w	$e78c,$fc55,$c4f8,$ffb6	; face normal
	dc.w	4		; number of points
	dc.w	1		; material GOLD
	dc.w	101, $0000	; Point index, texture coordinates
	dc.w	109, $00ff	; Point index, texture coordinates
	dc.w	110, $ff00	; Point index, texture coordinates
	dc.w	102, $ffff	; Point index, texture coordinates

;* Face 105
	dc.w	$1874,$fc55,$c4f8,$ffce	; face normal
	dc.w	4		; number of points
	dc.w	1		; material GOLD
	dc.w	102, $0000	; Point index, texture coordinates
	dc.w	110, $00ff	; Point index, texture coordinates
	dc.w	111, $ff00	; Point index, texture coordinates
	dc.w	103, $ffff	; Point index, texture coordinates

;* Face 106
	dc.w	$3b08,$fc55,$e78c,$ffd0	; face normal
	dc.w	4		; number of points
	dc.w	1		; material GOLD
	dc.w	103, $0000	; Point index, texture coordinates
	dc.w	111, $00ff	; Point index, texture coordinates
	dc.w	104, $ff00	; Point index, texture coordinates
	dc.w	96, $ffff	; Point index, texture coordinates

;* Face 107
	dc.w	$0,$c000,$0,$fed3	; face normal
	dc.w	3		; number of points
	dc.w	1		; material GOLD
	dc.w	104, $0000	; Point index, texture coordinates
	dc.w	106, $00ff	; Point index, texture coordinates
	dc.w	105, $ff00	; Point index, texture coordinates

;* Face 108
	dc.w	$0,$c000,$0,$fed3	; face normal
	dc.w	3		; number of points
	dc.w	1		; material GOLD
	dc.w	106, $0000	; Point index, texture coordinates
	dc.w	108, $00ff	; Point index, texture coordinates
	dc.w	107, $ff00	; Point index, texture coordinates

;* Face 109
	dc.w	$0,$c000,$0,$fed3	; face normal
	dc.w	3		; number of points
	dc.w	1		; material GOLD
	dc.w	108, $0000	; Point index, texture coordinates
	dc.w	110, $00ff	; Point index, texture coordinates
	dc.w	109, $ff00	; Point index, texture coordinates

;* Face 110
	dc.w	$0,$c000,$0,$fed3	; face normal
	dc.w	3		; number of points
	dc.w	1		; material GOLD
	dc.w	110, $0000	; Point index, texture coordinates
	dc.w	104, $00ff	; Point index, texture coordinates
	dc.w	111, $ff00	; Point index, texture coordinates

;* Face 111
	dc.w	$0,$c000,$0,$fed3	; face normal
	dc.w	4		; number of points
	dc.w	1		; material GOLD
	dc.w	104, $0000	; Point index, texture coordinates
	dc.w	110, $00ff	; Point index, texture coordinates
	dc.w	108, $ff00	; Point index, texture coordinates
	dc.w	106, $ffff	; Point index, texture coordinates

;* Face 112
	dc.w	$0,$0,$4000,$4bf	; face normal
	dc.w	4		; number of points
	dc.w	3		; material GRAY SEMIGLOSS
	dc.w	112, $0000	; Point index, texture coordinates
	dc.w	115, $00ff	; Point index, texture coordinates
	dc.w	114, $ff00	; Point index, texture coordinates
	dc.w	113, $ffff	; Point index, texture coordinates

;* Face 113
	dc.w	$0,$0,$4000,$162	; face normal
	dc.w	4		; number of points
	dc.w	4		; material RED GLASS
	dc.w	116, $0000	; Point index, texture coordinates
	dc.w	119, $00ff	; Point index, texture coordinates
	dc.w	118, $ff00	; Point index, texture coordinates
	dc.w	117, $ffff	; Point index, texture coordinates

;* Face 114
	dc.w	$0,$c000,$0,$ffd5	; face normal
	dc.w	4		; number of points
	dc.w	4		; material RED GLASS
	dc.w	116, $0000	; Point index, texture coordinates
	dc.w	117, $00ff	; Point index, texture coordinates
	dc.w	121, $ff00	; Point index, texture coordinates
	dc.w	120, $ffff	; Point index, texture coordinates

;* Face 115
	dc.w	$4000,$0,$0,$0	; face normal
	dc.w	4		; number of points
	dc.w	4		; material RED GLASS
	dc.w	117, $0000	; Point index, texture coordinates
	dc.w	118, $00ff	; Point index, texture coordinates
	dc.w	122, $ff00	; Point index, texture coordinates
	dc.w	121, $ffff	; Point index, texture coordinates

;* Face 116
	dc.w	$0,$4000,$0,$ffd5	; face normal
	dc.w	4		; number of points
	dc.w	4		; material RED GLASS
	dc.w	118, $0000	; Point index, texture coordinates
	dc.w	119, $00ff	; Point index, texture coordinates
	dc.w	123, $ff00	; Point index, texture coordinates
	dc.w	122, $ffff	; Point index, texture coordinates

;* Face 117
	dc.w	$c000,$0,$0,$ffb1	; face normal
	dc.w	4		; number of points
	dc.w	4		; material RED GLASS
	dc.w	119, $0000	; Point index, texture coordinates
	dc.w	116, $00ff	; Point index, texture coordinates
	dc.w	120, $ff00	; Point index, texture coordinates
	dc.w	123, $ffff	; Point index, texture coordinates

;* Face 118
	dc.w	$0,$0,$c000,$fdd2	; face normal
	dc.w	4		; number of points
	dc.w	4		; material RED GLASS
	dc.w	120, $0000	; Point index, texture coordinates
	dc.w	121, $00ff	; Point index, texture coordinates
	dc.w	122, $ff00	; Point index, texture coordinates
	dc.w	123, $ffff	; Point index, texture coordinates

	.long
.vertlist_default:
;* Vertex 0
	dc.w	-55,-458,196	; coordinates
	dc.w	$eaab,$d555,$2aab	; vertex normal

;* Vertex 1
	dc.w	-5,-458,196	; coordinates
	dc.w	$3441,$e5df,$1a21	; vertex normal

;* Vertex 2
	dc.w	-5,-458,146	; coordinates
	dc.w	$1555,$d555,$d555	; vertex normal

;* Vertex 3
	dc.w	-55,-458,146	; coordinates
	dc.w	$cbbf,$e5df,$e5df	; vertex normal

;* Vertex 4
	dc.w	-55,115,196	; coordinates
	dc.w	$d555,$2aab,$1555	; vertex normal

;* Vertex 5
	dc.w	-5,115,196	; coordinates
	dc.w	$1a21,$1a21,$3441	; vertex normal

;* Vertex 6
	dc.w	-5,115,146	; coordinates
	dc.w	$2aab,$2aab,$eaab	; vertex normal

;* Vertex 7
	dc.w	-55,115,146	; coordinates
	dc.w	$e5df,$1a21,$cbbf	; vertex normal

;* Vertex 8
	dc.w	-120,-570,465	; coordinates
	dc.w	$eaab,$d555,$d555	; vertex normal

;* Vertex 9
	dc.w	-80,-570,465	; coordinates
	dc.w	$3441,$e5df,$e5df	; vertex normal

;* Vertex 10
	dc.w	-80,-490,465	; coordinates
	dc.w	$0df7,$e411,$c823	; vertex normal

;* Vertex 11
	dc.w	0,-490,465	; coordinates
	dc.w	$ddca,$eee5,$ccb0	; vertex normal

;* Vertex 12
	dc.w	0,-570,465	; coordinates
	dc.w	$e5df,$cbbf,$e5df	; vertex normal

;* Vertex 13
	dc.w	40,-570,465	; coordinates
	dc.w	$2aab,$eaab,$d555	; vertex normal

;* Vertex 14
	dc.w	40,-460,465	; coordinates
	dc.w	$111b,$2236,$ccb0	; vertex normal

;* Vertex 15
	dc.w	-120,-460,465	; coordinates
	dc.w	$d555,$1555,$d555	; vertex normal

;* Vertex 16
	dc.w	-120,-570,565	; coordinates
	dc.w	$d555,$eaab,$2aab	; vertex normal

;* Vertex 17
	dc.w	-80,-570,565	; coordinates
	dc.w	$1a21,$cbbf,$1a21	; vertex normal

;* Vertex 18
	dc.w	-80,-490,565	; coordinates
	dc.w	$1bef,$f209,$37dd	; vertex normal

;* Vertex 19
	dc.w	0,-490,565	; coordinates
	dc.w	$eee5,$ddca,$3350	; vertex normal

;* Vertex 20
	dc.w	0,-570,565	; coordinates
	dc.w	$cbbf,$e5df,$1a21	; vertex normal

;* Vertex 21
	dc.w	40,-570,565	; coordinates
	dc.w	$1555,$d555,$2aab	; vertex normal

;* Vertex 22
	dc.w	40,-460,565	; coordinates
	dc.w	$2236,$111b,$3350	; vertex normal

;* Vertex 23
	dc.w	-120,-460,565	; coordinates
	dc.w	$eaab,$2aab,$2aab	; vertex normal

;* Vertex 24
	dc.w	-80,-380,90	; coordinates
	dc.w	$eaab,$2aab,$d555	; vertex normal

;* Vertex 25
	dc.w	0,-380,90	; coordinates
	dc.w	$3441,$1a21,$e5df	; vertex normal

;* Vertex 26
	dc.w	0,-460,90	; coordinates
	dc.w	$1555,$d555,$d555	; vertex normal

;* Vertex 27
	dc.w	-80,-460,90	; coordinates
	dc.w	$cbbf,$e5df,$e5df	; vertex normal

;* Vertex 28
	dc.w	-80,-380,750	; coordinates
	dc.w	$d555,$1555,$2aab	; vertex normal

;* Vertex 29
	dc.w	0,-380,750	; coordinates
	dc.w	$1a21,$3441,$1a21	; vertex normal

;* Vertex 30
	dc.w	0,-460,750	; coordinates
	dc.w	$2aab,$eaab,$2aab	; vertex normal

;* Vertex 31
	dc.w	-80,-460,750	; coordinates
	dc.w	$e5df,$cbbf,$1a21	; vertex normal

;* Vertex 32
	dc.w	-66,-59,370	; coordinates
	dc.w	$eaab,$2aab,$2aab	; vertex normal

;* Vertex 33
	dc.w	-16,-59,370	; coordinates
	dc.w	$3441,$1a21,$1a21	; vertex normal

;* Vertex 34
	dc.w	-16,-109,370	; coordinates
	dc.w	$1555,$d555,$2aab	; vertex normal

;* Vertex 35
	dc.w	-66,-109,370	; coordinates
	dc.w	$cbbf,$e5df,$1a21	; vertex normal

;* Vertex 36
	dc.w	-66,-59,-203	; coordinates
	dc.w	$d555,$1555,$d555	; vertex normal

;* Vertex 37
	dc.w	-16,-59,-203	; coordinates
	dc.w	$1a21,$3441,$e5df	; vertex normal

;* Vertex 38
	dc.w	-16,-109,-203	; coordinates
	dc.w	$2aab,$eaab,$d555	; vertex normal

;* Vertex 39
	dc.w	-66,-109,-203	; coordinates
	dc.w	$e5df,$cbbf,$e5df	; vertex normal

;* Vertex 40
	dc.w	-120,305,-310	; coordinates
	dc.w	$eaab,$2aab,$d555	; vertex normal

;* Vertex 41
	dc.w	-80,305,-310	; coordinates
	dc.w	$3441,$1a21,$e5df	; vertex normal

;* Vertex 42
	dc.w	-80,305,-230	; coordinates
	dc.w	$0df7,$37dd,$e411	; vertex normal

;* Vertex 43
	dc.w	0,305,-230	; coordinates
	dc.w	$ddca,$3350,$eee5	; vertex normal

;* Vertex 44
	dc.w	0,305,-310	; coordinates
	dc.w	$e5df,$1a21,$cbbf	; vertex normal

;* Vertex 45
	dc.w	40,305,-310	; coordinates
	dc.w	$2aab,$2aab,$eaab	; vertex normal

;* Vertex 46
	dc.w	40,305,-200	; coordinates
	dc.w	$111b,$3350,$2236	; vertex normal

;* Vertex 47
	dc.w	-120,305,-200	; coordinates
	dc.w	$d555,$2aab,$1555	; vertex normal

;* Vertex 48
	dc.w	-120,205,-310	; coordinates
	dc.w	$d555,$d555,$eaab	; vertex normal

;* Vertex 49
	dc.w	-80,205,-310	; coordinates
	dc.w	$1a21,$e5df,$cbbf	; vertex normal

;* Vertex 50
	dc.w	-80,205,-230	; coordinates
	dc.w	$1bef,$c823,$f209	; vertex normal

;* Vertex 51
	dc.w	0,205,-230	; coordinates
	dc.w	$eee5,$ccb0,$ddca	; vertex normal

;* Vertex 52
	dc.w	0,205,-310	; coordinates
	dc.w	$cbbf,$e5df,$e5df	; vertex normal

;* Vertex 53
	dc.w	40,205,-310	; coordinates
	dc.w	$1555,$d555,$d555	; vertex normal

;* Vertex 54
	dc.w	40,205,-200	; coordinates
	dc.w	$2236,$ccb0,$111b	; vertex normal

;* Vertex 55
	dc.w	-120,205,-200	; coordinates
	dc.w	$eaab,$d555,$2aab	; vertex normal

;* Vertex 56
	dc.w	120,249,26	; coordinates
	dc.w	$27d0,$31cf,$057f	; vertex normal

;* Vertex 57
	dc.w	76,249,133	; coordinates
	dc.w	$263e,$092b,$327e	; vertex normal

;* Vertex 58
	dc.w	-30,249,176	; coordinates
	dc.w	$f969,$2a21,$2fb9	; vertex normal

;* Vertex 59
	dc.w	-136,249,133	; coordinates
	dc.w	$cd82,$092b,$263e	; vertex normal

;* Vertex 60
	dc.w	-180,249,26	; coordinates
	dc.w	$d830,$31cf,$fa81	; vertex normal

;* Vertex 61
	dc.w	-136,249,-80	; coordinates
	dc.w	$d9c2,$092b,$cd82	; vertex normal

;* Vertex 62
	dc.w	-30,249,-124	; coordinates
	dc.w	$0697,$2a21,$d047	; vertex normal

;* Vertex 63
	dc.w	76,249,-80	; coordinates
	dc.w	$327e,$092b,$d9c2	; vertex normal

;* Vertex 64
	dc.w	99,157,26	; coordinates
	dc.w	$3e8a,$f268,$0002	; vertex normal

;* Vertex 65
	dc.w	61,157,118	; coordinates
	dc.w	$2c38,$f268,$2c3a	; vertex normal

;* Vertex 66
	dc.w	-30,157,156	; coordinates
	dc.w	$fffe,$f268,$3e8a	; vertex normal

;* Vertex 67
	dc.w	-122,157,118	; coordinates
	dc.w	$d3c6,$f268,$2c38	; vertex normal

;* Vertex 68
	dc.w	-160,157,26	; coordinates
	dc.w	$c176,$f268,$fffe	; vertex normal

;* Vertex 69
	dc.w	-122,157,-65	; coordinates
	dc.w	$d3c8,$f268,$d3c6	; vertex normal

;* Vertex 70
	dc.w	-30,157,-103	; coordinates
	dc.w	$0002,$f268,$c176	; vertex normal

;* Vertex 71
	dc.w	61,157,-65	; coordinates
	dc.w	$2c3a,$f268,$d3c8	; vertex normal

;* Vertex 72
	dc.w	80,65,26	; coordinates
	dc.w	$3eea,$f443,$0009	; vertex normal

;* Vertex 73
	dc.w	48,65,104	; coordinates
	dc.w	$2c76,$f443,$2c83	; vertex normal

;* Vertex 74
	dc.w	-30,65,137	; coordinates
	dc.w	$fff7,$f443,$3eea	; vertex normal

;* Vertex 75
	dc.w	-108,65,104	; coordinates
	dc.w	$d37d,$f443,$2c76	; vertex normal

;* Vertex 76
	dc.w	-140,65,26	; coordinates
	dc.w	$c116,$f443,$fff7	; vertex normal

;* Vertex 77
	dc.w	-108,65,-51	; coordinates
	dc.w	$d38a,$f443,$d37d	; vertex normal

;* Vertex 78
	dc.w	-30,65,-84	; coordinates
	dc.w	$0009,$f443,$c116	; vertex normal

;* Vertex 79
	dc.w	48,65,-51	; coordinates
	dc.w	$2c83,$f443,$d38a	; vertex normal

;* Vertex 80
	dc.w	65,-26,26	; coordinates
	dc.w	$3f82,$f814,$0008	; vertex normal

;* Vertex 81
	dc.w	37,-26,94	; coordinates
	dc.w	$2ce2,$f814,$2cee	; vertex normal

;* Vertex 82
	dc.w	-30,-26,122	; coordinates
	dc.w	$fff8,$f814,$3f82	; vertex normal

;* Vertex 83
	dc.w	-98,-26,94	; coordinates
	dc.w	$d312,$f814,$2ce2	; vertex normal

;* Vertex 84
	dc.w	-126,-26,26	; coordinates
	dc.w	$c07e,$f814,$fff8	; vertex normal

;* Vertex 85
	dc.w	-98,-26,-41	; coordinates
	dc.w	$d31e,$f814,$d312	; vertex normal

;* Vertex 86
	dc.w	-30,-26,-69	; coordinates
	dc.w	$0008,$f814,$c07e	; vertex normal

;* Vertex 87
	dc.w	37,-26,-41	; coordinates
	dc.w	$2cee,$f814,$d31e	; vertex normal

;* Vertex 88
	dc.w	57,-118,26	; coordinates
	dc.w	$3fcc,$fae2,$0001	; vertex normal

;* Vertex 89
	dc.w	31,-118,88	; coordinates
	dc.w	$2d1b,$fae2,$2d1d	; vertex normal

;* Vertex 90
	dc.w	-30,-118,114	; coordinates
	dc.w	$ffff,$fae2,$3fcc	; vertex normal

;* Vertex 91
	dc.w	-92,-118,88	; coordinates
	dc.w	$d2e3,$fae2,$2d1b	; vertex normal

;* Vertex 92
	dc.w	-118,-118,26	; coordinates
	dc.w	$c034,$fae2,$ffff	; vertex normal

;* Vertex 93
	dc.w	-92,-118,-35	; coordinates
	dc.w	$d2e5,$fae2,$d2e3	; vertex normal

;* Vertex 94
	dc.w	-30,-118,-61	; coordinates
	dc.w	$0001,$fae2,$c034	; vertex normal

;* Vertex 95
	dc.w	31,-118,-35	; coordinates
	dc.w	$2d1d,$fae2,$d2e5	; vertex normal

;* Vertex 96
	dc.w	50,-210,26	; coordinates
	dc.w	$3fdb,$fbbb,$0001	; vertex normal

;* Vertex 97
	dc.w	27,-210,84	; coordinates
	dc.w	$2d27,$fbbb,$2d28	; vertex normal

;* Vertex 98
	dc.w	-30,-210,107	; coordinates
	dc.w	$ffff,$fbbb,$3fdb	; vertex normal

;* Vertex 99
	dc.w	-87,-210,84	; coordinates
	dc.w	$d2d8,$fbbb,$2d27	; vertex normal

;* Vertex 100
	dc.w	-111,-210,26	; coordinates
	dc.w	$c025,$fbbb,$ffff	; vertex normal

;* Vertex 101
	dc.w	-87,-210,-31	; coordinates
	dc.w	$d2d9,$fbbb,$d2d8	; vertex normal

;* Vertex 102
	dc.w	-30,-210,-54	; coordinates
	dc.w	$0001,$fbbb,$c025	; vertex normal

;* Vertex 103
	dc.w	27,-210,-31	; coordinates
	dc.w	$2d28,$fbbb,$d2d9	; vertex normal

;* Vertex 104
	dc.w	45,-301,26	; coordinates
	dc.w	$2346,$cad2,$fb21	; vertex normal

;* Vertex 105
	dc.w	23,-301,80	; coordinates
	dc.w	$2f0c,$e73d,$23a1	; vertex normal

;* Vertex 106
	dc.w	-30,-301,101	; coordinates
	dc.w	$05c9,$cff8,$29e6	; vertex normal

;* Vertex 107
	dc.w	-83,-301,80	; coordinates
	dc.w	$dc5f,$e73d,$2f0c	; vertex normal

;* Vertex 108
	dc.w	-105,-301,26	; coordinates
	dc.w	$dcba,$cad2,$04df	; vertex normal

;* Vertex 109
	dc.w	-83,-301,-27	; coordinates
	dc.w	$d0f4,$e73d,$dc5f	; vertex normal

;* Vertex 110
	dc.w	-30,-301,-49	; coordinates
	dc.w	$fa37,$cff8,$d61a	; vertex normal

;* Vertex 111
	dc.w	23,-301,-27	; coordinates
	dc.w	$23a1,$e73d,$d0f4	; vertex normal

;* Vertex 112
	dc.w	-12867,-11800,-1215	; coordinates
	dc.w	$0000,$0000,$4000	; vertex normal

;* Vertex 113
	dc.w	12858,-11800,-1215	; coordinates
	dc.w	$0000,$0000,$4000	; vertex normal

;* Vertex 114
	dc.w	12858,11800,-1215	; coordinates
	dc.w	$0000,$0000,$4000	; vertex normal

;* Vertex 115
	dc.w	-12867,11800,-1215	; coordinates
	dc.w	$0000,$0000,$4000	; vertex normal

;* Vertex 116
	dc.w	-79,-43,-354	; coordinates
	dc.w	$eaab,$d555,$2aab	; vertex normal

;* Vertex 117
	dc.w	0,-43,-354	; coordinates
	dc.w	$3441,$e5df,$1a21	; vertex normal

;* Vertex 118
	dc.w	0,43,-354	; coordinates
	dc.w	$1555,$2aab,$2aab	; vertex normal

;* Vertex 119
	dc.w	-79,43,-354	; coordinates
	dc.w	$cbbf,$1a21,$1a21	; vertex normal

;* Vertex 120
	dc.w	-79,-43,-558	; coordinates
	dc.w	$d555,$eaab,$d555	; vertex normal

;* Vertex 121
	dc.w	0,-43,-558	; coordinates
	dc.w	$1a21,$cbbf,$e5df	; vertex normal

;* Vertex 122
	dc.w	0,43,-558	; coordinates
	dc.w	$2aab,$1555,$d555	; vertex normal

;* Vertex 123
	dc.w	-79,43,-558	; coordinates
	dc.w	$e5df,$3441,$e5df	; vertex normal


	.phrase
.matlist:

; Material 0: CREAM PLASTIC
	dc.w	$a9c4, 0
	dc.l	0		; no texture

; Material 1: GOLD
	dc.w	$c88c, 0
	dc.l	0		; no texture

; Material 2: CHROME GIFMAP
	dc.w	$0000, 0
	dc.l	0		; no texture

; Material 3: GRAY SEMIGLOSS
	dc.w	$78a8, 0
	dc.l	0		; no texture

; Material 4: RED GLASS
	dc.w	$d4b9, 0
	dc.l	0		; no texture

; Material 5: BRASS GIFMAP
	dc.w	$d993, 0
	dc.l	0		; no texture


