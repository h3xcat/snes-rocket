.ifndef ::__SPRITES__
::__SPRITES__ = 1
.global SpritesInit


;============================================================================
; Structs
;============================================================================
.struct SpriteObject
	xcoord	.byte
	ycoord	.byte
	tile	.byte
	status	.byte
.endstruct
;============================================================================
; Macros
;============================================================================
.macro SpriteEnable Table, SpriteID
	RW_assume a8i16
	; set X-MSB to 0
	lda Table+512+((SpriteID)/4)
	and #.lobyte( ($01 << (( (SpriteID) *2) .mod 8)) ^ $ff )
	sta Table+512+((SpriteID)/4)
.endmacro

.macro SpriteEnabled Table, SpriteID
	RW_assume a8i16
	lda Table+512+((SpriteID)/4)
	bit #($01 << (((SpriteID)*2) .mod 8))
.endmacro

.macro SpriteDisable Table, SpriteID
	; set X-MSB to 1
	RW_assume a8
	lda Table+512+((SpriteID)/4)
	ora #($01 << (((SpriteID)*2) .mod 8))
	sta Table+512+((SpriteID)/4)
.endmacro

.macro SpriteSetup Table, SpriteID, PosX, PosY, Tile, N, Palette, Priority, FlipH, FlipV, Size
	RW_push set:a8
	lda #.lobyte(PosX)
	sta Table+(SpriteID)*4
	lda #.lobyte(PosY)
	sta Table+(SpriteID)*4 + 1
	lda #.lobyte(Tile)
	sta Table+(SpriteID)*4 + 2
	lda #.lobyte(FlipV<<7 + FlipH<<6 +  Priority<<4 + (((Palette)<<1)& $07) + N)
	sta Table+(SpriteID)*4 + 3
	; Size
	lda Table+512+((SpriteID)/4)
	and #.lobyte(( %11 << (((SpriteID)*2) .mod 8)) ^ $ff)
	ora #.lobyte(( ((Size)<<1) | .hibyte((PosX)&$100) ) << (((SpriteID)*2) .mod 8))
	sta Table+512+((SpriteID)/4)
	RW_pull
.endmacro

.endif; __SPRITES__