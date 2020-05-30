
;******************************************************************************
; (C) Copyright 1992-1994, SuperMac Technology, Inc.
; All rights reserved.
;
; This source code and any compilation or derivative thereof is the sole
; property of SuperMac Technology, Inc. and is provided pursuant to a
; Software License Agreement.  This code is the proprietary information
; of SuperMac Technology and is confidential in nature.  Its use and
; dissemination by any party other than SuperMac Technology are strictly
; limited by the confidential information provisions of the Agreement
; referenced above.
;
; Revision 1.1  04/25/94  15:30:35  jpe
; Moved CINEPAK_DATA from $30000 to $34000.
;
; Revision 1.0  04/08/94  13:56:20  jpe
; Initial revision.
;******************************************************************************

SCREEN_BASE	equ		$10000			; Display buffer
CINEPAK_DATA	equ		$34000			; Codebooks (uses $3000)
FILM_BASE		equ		$38000			; Permanent location of chunk table
ROM_BASE		equ		$800000			; Base of ROM
