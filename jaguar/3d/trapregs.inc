;
; REGISTER DEFINITIONS FOR BANK 0
; (mostly used by the trapezoid renderer)
;
atemp0		.equr	r0,0		; temporary registers
atemp1		.equr	r1,0
atemp2		.equr	r2,0

bcmdval		.equr	r3,0		; value for B_CMD
bcount		.equr	r4,0		; value for bcount
ay		.equr	r5,0		; Y value
anumlines 	.equr	r6,0		; number of lines to draw

rightx		.equr	r7,0		; 16.16 value for right X
rightxstep	.equr	r8,0		; step value for right X
leftx		.equr	r9,0		; 16.16 value for left X
leftxstep	.equr	r10,0		; left X step value
leftz		.equr	r11,0		; 16.16 value for Z
leftzstep	.equr	r12,0		; Z step value
lefti		.equr	r13,0
leftistep	.equr	r14,0

leftu		.equr	r15,0
leftustep	.equr	r16,0
leftv		.equr	r17,0
leftvstep	.equr	r18,0

traploop	.equr	r19,0		; address of trapezoid loop
trapdone	.equr	r20,0		; address to break out of trapezoid loop

destflags	.equr	r21,0		; blitter flags for destination bitmap
destaddr	.equr	r22,0		; destination bitmap address
srcflags	.equr	r23,0		; blitter flags for source bitmap
srcaddr		.equr	r24,0		; source bitmap address

b_zinc		.equr	r25,0		; Z increment (needed for phrase mode calculations)
b_iinc		.equr	r26,0		; I increment
b_color		.equr	r27,0

;
; if you need to run with interrupts enabled, don't use the
; next 4 registers, and change all references to them to do
; movei instructions into a temporary register first
;
bcmd_ptr	.equr	r28,0		; address of B_CMD
a1_ptr		.equr	r29,0		; address of A1_PIXEL
a2_ptr		.equr	r30,0		; address of A2_PIXEL
bz3_ptr		.equr	r31,0		; address of B_Z3

; b_uinc and b_vinc can co-exist with traploop and trapdone, since they're stored into
; A1_INC and A1_FINC before we get to the trapezoid loop

b_uinc		.equr	traploop
b_vinc		.equr	trapdone


;
; during trapezoid rendering, certain registers in bank 1 are available
; for use by the renderer...
;

traptemp0	.equr	r4,1
traptemp1	.equr	r5,1
traptemp2	.equr	r6,1
traptemp3	.equr	r7,1
traptemp4	.equr	r8,1
traptemp5	.equr	r9,1

