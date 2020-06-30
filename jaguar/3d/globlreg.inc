;
; Global register defines for triangle renderer
;
; Registers are split up as follows:
;
; Bank 0:
; All registers are reserved for trapezoid renderer
; We can use some of the registers as temporary outside
; of trapezoid rendering, though.
;
; Bank 1:
; r0-r22 inclusive are reserved for subroutines
; r23-r31 inclusive are for the main code
;
;
; definitions common for all subroutines
;
temp0		.equr	r0,1		; temporary registers
temp1		.equr	r1,1
temp2		.equr	r2,1
return		.equr	r3,1		; return address from subroutine

;
; global registers

pgon		.equr	r23,1		; pointer to polygon
altpgon		.equr	r24,1		; alternate polygon pointer (for clipping)
subr		.equr	r25,1		; address of subroutine we're using right now
andclips	.equr	r26,1
orclips		.equr	r27,1
tri		.equr	r28,1		; pointer to current triangle
tricount	.equr	r29,1		; number of triangles left
cam		.equr	r30,1		; pointer to output bitmap data


;
; Bank 0 temporary registers
; atemp0-atemp2 are used for spilling registers
; r21-r31 are fixed
;

altmatrl	.equr	r3,0		; temporary storage for material
altskip		.equr	r4,0		; address of "skipface" routine
altgmtxa	.equr	r5,0		; address of G_MTXA
altlmodel	.equr	r6,0		; address of lighting model
