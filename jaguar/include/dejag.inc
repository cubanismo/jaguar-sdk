;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; DEJAG.INC - Copyright (c)1994 Atari Corp.
;;             All Rights Reserved
;;
;; UNAUTHORIZED REPRODUCTION, ADAPTATION, DISTRIBUTION,
;; PERFORMANCE OR DISPLAY OF THIS COMPUTER PROGRAM OR
;; THE ASSOCIATED AUDIOVISUAL WORK IS STRICTLY PROHIBITED.
;;
;; Last Modification: 8/22/94 - Created (SDS)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DQ_Adr          EQU     $F03E00         ; Pointer to start of DQ??.ABS
In_Adr          EQU     $F03F40         ; Pointer to start of JAG data
Out_Adr         EQU     $F03F44         ; Pointer to start of output buffer
Dehuff_Adr      EQU     $F03F48         ; Pointer to start of DEHUFF.ABS
Out_Width       EQU     $F03F4C         ; Width of output area in blocks
Out_E_Width     EQU     $F03F50         ; Blitter Encoded Pixel Width (ex: WID320)
All_Done        EQU     $F03F54         ; Contains: 1 = in progress, 0 = done
