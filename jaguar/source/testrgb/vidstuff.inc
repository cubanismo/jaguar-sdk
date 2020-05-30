bitmap_addr		.equ	$20000	; Buffer in main memory
BM_WIDTH		.equ	320	; Bitmap width in pixels
BM_HEIGHT		.equ	200	; Bitmap height in pixels
BM_DEPTH		.equ	16	; 16 bits per pixel
BM_PHRASES		.equ	((BM_WIDTH*BM_DEPTH)/64)	; phrase = 64 bits
BM_OFFSET	  	.equ    (2*8)	; Two Phrases = offset to bitmap object

MY_LISTSIZE	.equ	5	; List size in phrases:		
							; branch (1)
							; branch (1)
							; bitmap (2)
							; stop (1)
