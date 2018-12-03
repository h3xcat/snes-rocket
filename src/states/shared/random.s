.include "libsfx.i"
.include "random.i"

.segment "CODE"

RandomByteSub:
	RW_assume a8i8
	wdm 0
	; Get index
	ldy rnd_index

	; Incrament index
	inc rnd_index

	; Load random value 
	lda last_val
	lda RandomData, y
	sta last_val

	rts


;============================================================================
; Random Data
;============================================================================

.segment "LORAM"
rnd_index:	.res 1
last_val:	.res 1

.segment "RODATA"
RandomData:
.byte $47, $4c, $6a, $72, $9b, $f8, $b0, $da, $da, $35, $57, $9c, $c1, $df, $98, $bf
.byte $c6, $e9, $45, $94, $96, $42, $87, $04, $48, $33, $46, $16, $8c, $32, $fd, $c3
.byte $3c, $bf, $23, $b5, $5b, $11, $a8, $9a, $a3, $6a, $a7, $de, $cc, $25, $7c, $05
.byte $55, $b0, $31, $ff, $8f, $17, $3f, $7e, $b1, $19, $d3, $09, $e8, $a9, $af, $5f
.byte $fb, $16, $cd, $b7, $80, $73, $91, $c6, $ae, $5c, $01, $10, $f5, $56, $57, $f1
.byte $de, $cc, $50, $2e, $88, $98, $b6, $75, $d0, $ca, $9c, $f1, $0a, $ef, $aa, $1b
.byte $35, $af, $56, $b7, $64, $8e, $37, $6a, $58, $09, $ba, $d6, $d9, $3d, $1f, $52
.byte $03, $23, $39, $36, $33, $d7, $3b, $0f, $5b, $08, $25, $ff, $cc, $61, $14, $33
.byte $0f, $f5, $90, $57, $3d, $2a, $8a, $75, $a5, $a2, $62, $9b, $6f, $d5, $a3, $49
.byte $91, $87, $fe, $ca, $18, $a2, $13, $11, $9b, $96, $e8, $36, $52, $73, $d2, $fb
.byte $5c, $85, $50, $08, $a4, $c7, $78, $bd, $87, $bc, $02, $f6, $2e, $9a, $f6, $52
.byte $e3, $cb, $43, $bb, $2a, $0a, $fb, $65, $be, $9a, $61, $ca, $fe, $e1, $45, $2d
.byte $db, $2f, $94, $1e, $7c, $70, $4a, $e3, $7d, $97, $a7, $75, $81, $ad, $91, $0f
.byte $31, $15, $86, $d5, $72, $ab, $a3, $af, $d8, $92, $21, $4c, $31, $e6, $3b, $a2
.byte $73, $48, $4f, $e3, $d6, $8e, $c0, $0f, $5a, $c2, $f1, $bf, $18, $7f, $3f, $91
.byte $67, $f3, $9e, $70, $05, $9d, $8c, $00, $22, $25, $da, $3e, $92, $83, $77, $77