;============================================================================
.include "libSFX.i"
.include "Sprites.i"

;	SpriteCollide
;	>:in:  	a		First Sprite
;	>:in:  	x		Seccond Sprite
;
;	>:out:  z       

;
;SpriteCollide:
;	RW_assume a8i8
;
;	sta SPRITES_SPRITE1
;	stx SPRITES_SPRITE2
;
;	;---------- Check X
;	lda SPRITES_SPRITE1+0
;	sbc SPRITES_SPRITE2+0
;
;	bpl :+
;	eor #$ff
;:
;	
;	sbc #16
;	bpl nocollision
;
;	;---------- Check Y
;	lda SPRITES_SPRITE1+1
;	sbc SPRITES_SPRITE2+1
;
;	bpl :+
;    eor #$ff
;:
;
;	sbc #16
;	bpl nocollision
;
;    
;collision:
;	sep #$02
;	jmp end
;nocollision:
;	rep #$02
;end:
;	rts
;