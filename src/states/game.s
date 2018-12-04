.include "libsfx.i"
.include "game.i"
.include "../main.i"

.include "shared/sprites.i"
.include "shared/random.i"

;===============================================================================
;===============================================================================
;VRAM addresses
VRAM_BG1_TILES  = $0000
VRAM_BG2_TILES  = $2000
VRAM_BG3_TILES  = $4000

VRAM_BG1_MAP    = $5000
VRAM_BG2_MAP    = $5800
VRAM_BG3_MAP    = $6000

VRAM_OBJ_TILES  = $8000

;CGRAM addresses
CGRAM_BG        = $0000
CGRAM_OBJ       = $0080


.define ScreenTop       239
.define ScreenBottom    224

.define RocksN  32

.struct Sprite
    posX    .byte
    posY    .byte
    tile    .byte
    other   .byte
.endstruct



.define rocksIndex      4; Rocks must be alligned to 16 bytes(n*4 sprites)

.define Player1         SHADOW_OAM+0
.define player2         SHADOW_OAM+4
; 8 byte(2 sprite) padding
.define rocks           SHADOW_OAM+(rocksIndex*4) 

;===============================================================================
;===============================================================================
.segment "CODE"

StatesGameInit:
    RW a8i16

    ; Init shadow oam
    OAM_init SHADOW_OAM, $101, 0, 0


    ; Transfer Tiles
    LZ4_decompress DATA_BG_STARS1_TILES, EXRAM, y
    VRAM_memcpy VRAM_BG1_TILES, EXRAM, y

    LZ4_decompress DATA_BG_STARS2_TILES, EXRAM, y
    VRAM_memcpy VRAM_BG2_TILES, EXRAM, y

    LZ4_decompress DATA_BG_ASCII_TILES, EXRAM, y   
    VRAM_memcpy VRAM_BG3_TILES, EXRAM, y

    LZ4_decompress DATA_FG_SPRITES_TILES, EXRAM, y   
    VRAM_memcpy VRAM_OBJ_TILES, EXRAM, y


    ; Transfer Maps
    LZ4_decompress DATA_BG_STARS1_MAP, EXRAM, y
    VRAM_memcpy VRAM_BG1_MAP, EXRAM, y

    LZ4_decompress DATA_BG_STARS2_MAP, EXRAM, y
    VRAM_memcpy VRAM_BG2_MAP, EXRAM, y

    VRAM_memset VRAM_BG3_MAP, $0800, $00 ; Just fill with 0's

    ; Write palette data
    CGRAM_memcpy CGRAM_BG, DATA_BG_PALETTE, SIZE_BG_PALETTE
    CGRAM_memcpy CGRAM_OBJ, DATA_FG_PALETTE, SIZE_FG_PALETTE

    SpriteSetup SHADOW_OAM, 0, 256/2-16, 224/2-16, 0, 0, 0, 3, 0, 0, 1
    ; SpriteSetup SHADOW_OAM, 1, 256/2-16+$100, 224/2-16, 32, 0, 0, 3, 0, 0, 1
    ; .macro SpriteSetup Table, SpriteID, PosX, PosY, Tile, N, Palette, Priority, FlipH, FlipV, Size

    .repeat RocksN, I
        SpriteSetup SHADOW_OAM, (rocksIndex+I), .lobyte(I*24), ScreenBottom, $20+(I .mod 4)*2, 0, 0, 2, I .mod 2, 0, 1
    .endrepeat


    ;Set up screen mode
    lda     #bgmode(BG_MODE_1, BG3_PRIO_HIGH, BG_SIZE_8X8, BG_SIZE_8X8, BG_SIZE_8X8, 0)
    sta     BGMODE
    lda     #bgsc(VRAM_BG1_MAP, SC_SIZE_32X32)
    sta     BG1SC
    lda     #bgsc(VRAM_BG2_MAP, SC_SIZE_32X32)
    sta     BG2SC
    lda     #bgsc(VRAM_BG3_MAP, SC_SIZE_32X32)
    sta     BG3SC

    ldx     #bgnba(VRAM_BG1_TILES, VRAM_BG2_TILES, VRAM_BG3_TILES, 0)
    stx     BG12NBA

    lda     #objsel(VRAM_OBJ_TILES, OBJ_8x8_16x16, 0)
    sta     OBJSEL
    lda     #tm(ON, ON, ON, OFF, ON)
    sta     TM

    WRAM_memset SHADOW_BG3_MAP, $700, $00

    ldy #$0000
    sty GAME_SCORE_BCD 
    lda #$01
    sta GAME_LEVEL 
	rts

StatesGameLoop:
	RW a8i16
	
    jsr ProcessBackground
    jsr ProcessInput
    jsr ProcessRocks
    jsr ProcessScore
    jsr ProcessText

    OAM_memcpy SHADOW_OAM
    VRAM_memcpy VRAM_BG3_MAP, SHADOW_BG3_MAP, $700

	rts

;===============================================================================
;===============================================================================
ProcessScore:
    RW a16i16
    lda SFX_tick
    and #$000f
    cmp #$000f
    bne SkipScoreIncrease
    lda GAME_SCORE_BCD
    clc
    adc #$01
    sta GAME_SCORE_BCD
    and #$ffe0
    clc
    lsr
    lsr
    lsr
    lsr
    lsr
    
    clc
    adc #$01
    sta GAME_LEVEL

SkipScoreIncrease:

    RW a8i16
    rts
;===============================================================================
;===============================================================================
ProcessText:
    RW a16i16
    lda GAME_SCORE_BCD
    and #$000f
    adc #$10
    and #$ff
    ora #$2400
    sta SHADOW_BG3_MAP+6
    
    lda GAME_SCORE_BCD
    and #$00f0
    sec
    lsr
    lsr
    lsr
    lsr
    adc #$10
    and #$ff
    ora #$2400
    sta SHADOW_BG3_MAP+4
    
    lda GAME_SCORE_BCD+1
    and #$000f
    adc #$10
    and #$ff
    ora #$2400
    sta SHADOW_BG3_MAP+2
    
    lda GAME_SCORE_BCD+1
    and #$00f0
    sec
    lsr
    lsr
    lsr
    lsr
    adc #$10
    and #$ff
    ora #$2400
    sta SHADOW_BG3_MAP


    RW a8i16
    rts
;-------------------------------------------------------------------------------    
ProcessBackground:
    RW a8i8

    lda BG_OFFSET
    sec
    sbc GAME_LEVEL
    sta BG_OFFSET


    lsr
    sta BG2VOFS
    lda #$00
    sta BG2VOFS

    lda BG_OFFSET
    sta BG1VOFS
    lda #$00
    sta BG1VOFS

    RW a8i16
    rts

;-------------------------------------------------------------------------------
ProcessRocks:
    RW a16i16

    
    ldx #rocksIndex
RockLoop:
    ;;;; Check if sprite is enabled ;;;;

    ; calculate tbl1 offset (x*4)
    txa
    asl
    asl
    tay

    ; Move the sprite
    lda SHADOW_OAM+Sprite::posY, y
    and #$ff

    cmp #ScreenBottom
    bcc RockEnabled
    cmp #ScreenTop
    bcs RockEnabled

RockDisabled:
    ;;;; Check if we should enable it
    lda SFX_tick
    and #$000F
    cmp #$000F
    bne RockLoopContinue    
    RandomByte
    and #$000f ; 1/8
    bne RockLoopContinue

EnableRock:
    RW a8
    lda #ScreenTop
    sta SHADOW_OAM+Sprite::posY, y
    RW a16

    jmp RockLoopContinue
RockEnabled:
    RW a8

    ; Incrament position
    clc
    adc GAME_LEVEL
    sta SHADOW_OAM+Sprite::posY, y
    clc

    ;;;; Check Collision
    ;---------- Check Y
    sbc Player1+Sprite::posY

    bpl :+
    eor #$ff
:

    sbc #12
    bpl CollisionCheckEnd ; Doesn't collide on Y

    ;---------- Check X
    lda SHADOW_OAM+Sprite::posX, y
    sbc Player1+Sprite::posX

    bpl :+
    eor #$ff
:

    sbc #12
    bpl CollisionCheckEnd    
Collision:
    lda #GAMESTATE_MENU
    sta GAME_STATE
CollisionCheckEnd:

    RW a16
RockLoopContinue:
    inx
    cpx #(rocksIndex+RocksN)
    bne RockLoop 

    RW a8i8
    rts

;-------------------------------------------------------------------------------
ProcessInput:
    RW a8i8

    ldy     Player1+Sprite::tile

    RW a16i16
    lda     z:SFX_joy1cont

    ldx     #0 ; Boost

CheckKeyB:
    bit     #BUTTON_B
    beq     CheckKeyUp
    ldx     #1

CheckKeyUp:
    bit     #BUTTON_UP
    beq     CheckKeyDown
    ldy     #0
    RW a8     
    dec     Player1+Sprite::posY
    cpx     #1
    bne     FinishPlayerProcess
    dec     Player1+Sprite::posY
    jmp     FinishPlayerProcess

CheckKeyDown:
    RW a16
    bit     #BUTTON_DOWN
    beq     CheckKeyLeft
    ldy     #6
    RW a8
    inc     Player1+Sprite::posY
    cpx     #1
    bne     FinishPlayerProcess
    inc     Player1+Sprite::posY
    jmp     FinishPlayerProcess

CheckKeyLeft:
    RW a16
    bit     #BUTTON_LEFT
    beq     SkipLeft
    ldy     #4
    RW a8
    dec     Player1+Sprite::posX
    cpx     #1
    bne     FinishPlayerProcess
    dec     Player1+Sprite::posX
    jmp     FinishPlayerProcess

SkipLeft:
    RW a16
    bit     #BUTTON_RIGHT
    beq     FinishPlayerProcess
    ldy     #2
    RW a8
    inc     Player1+Sprite::posX
    cpx     #1
    bne     FinishPlayerProcess
    inc     Player1+Sprite::posX

FinishPlayerProcess:
    RW a8i8

    sty     Player1+Sprite::tile

    RW a8i16
    rts

;===============================================================================
;===============================================================================
.segment "LORAM"
GAME_SCORE_BCD:
    .res 2

GAME_LEVEL:
    .res 1

SOMETHING:
    .res 1
BG_OFFSET:
    .res 1
