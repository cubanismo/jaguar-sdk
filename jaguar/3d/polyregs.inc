;
; REGISTER DEFINITIONS FOR USE DURING
; POLYGON SCAN CONVERSION (NON-TRIANGLE
; FORM)
;
; Bank 0 registers

atemp0		.equr	r0,0
atemp1		.equr	r1,0
atemp2		.equr	r2,0

leftx		.equr	r3,0		; 16.16 value for left X
leftxstep	.equr	r4,0
leftz		.equr	r5,0		; 16.16 value for Z
lefti		.equr	r6,0
leftu		.equr	r7,0
leftv		.equr	r8,0

rightx		.equr	r9,0		; 16.16 value for right X
rightxstep	.equr	r10,0		; step value for right X
rightz		.equr	r11,0
righti		.equr	r12,0
rightu		.equr	r13,0
rightv		.equr	r14,0

bcmdval		.equr	r15,0		; value for B_CMD
bcount		.equr	r16,0		; value for bcount
ay		.equr	r17,0		; Y value
anumlines 	.equr	r18,0		; number of lines to draw

destflags	.equr	r19,0		; blitter flags for destination bitmap
destaddr	.equr	r20,0		; destination bitmap address
srcflags	.equr	r21,0		; blitter flags for source bitmap
srcaddr		.equr	r22,0		; source bitmap address

a1_ptr		.equr	r23,0		; address of A1_PIXEL
a2_ptr		.equr	r24,0		; address of A2_PIXEL
bz3_ptr		.equr	r25,0		; address of B_Z3
bcmd_ptr	.equr	r26,0		; address of B_CMD

b_zinc		.equr	r27,0		; Z increment (needed for phrase mode calculations)
b_iinc		.equr	r28,0		; I increment

b_uinc		.equr	r29,0		; U increment
b_vinc		.equr	r30,0		; V increment

b_color		.equr	r31,0		; b_color isn't used once rendering starts


;
; Bank 1 registers
;

leftzstep	.equr	r15,1
leftistep	.equr	r16,1
leftustep	.equr	r17,1
leftvstep	.equr	r18,1
rightzstep	.equr	r19,1
rightistep	.equr	r20,1
rightustep	.equr	r21,1
rightvstep	.equr	r22,1
