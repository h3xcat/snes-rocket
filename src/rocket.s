; Hello
; David Lindecrantz <optiroc@gmail.com>
;
; Example using the Mouse package to control two animated sprites
; using either mouse or joypad in either port

.include "libSFX.i"
.include "Sprites.i"
.include "RandomGen.i"

;VRAM addresses
VRAM_BG1_MAP    = $1000
VRAM_BG1_TILES  = $2000
VRAM_BG2_MAP    = $3000
VRAM_BG2_TILES  = $4000
VRAM_BG3_MAP    = $5000
VRAM_BG3_TILES  = $6000

VRAM_OBJ_TILES  = $8000 ; OAM 1

;CGRAM addresses
CGRAM_BG1       = $0000
CGRAM_BG2       = $0010
CGRAM_BG3       = $0020
CGRAM_OBJ       = $0040

;LORAM addresses


;JOY BIT MASKS
BUTTON_B         = $8000
BUTTON_Y         = $4000
BUTTON_SELECT    = $2000
BUTTON_START     = $1000
BUTTON_UP        = $0800
BUTTON_DOWN      = $0400
BUTTON_LEFT      = $0200
BUTTON_RIGHT     = $0100
BUTTON_A         = $0080
BUTTON_X         = $0040
BUTTON_L         = $0020
BUTTON_R         = $0010


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
.segment "CODE"
Main:
    RW a8i16

    ;Init shadow oam
    OAM_init SHADOW_OAM, $101, 0, 0

    ;Transfer and execute SPC file
    SMP_playspc SPC_STATE, SPC_IMAGE_LO, SPC_IMAGE_HI

    ; Unload Background 1
    LZ4_decompress DATA_BG1_TILES, EXRAM, y
    VRAM_memcpy VRAM_BG1_TILES, EXRAM, y

    LZ4_decompress DATA_BG1_MAP, EXRAM, y
    VRAM_memcpy VRAM_BG1_MAP, EXRAM, y

    CGRAM_memcpy CGRAM_BG1, DATA_BG1_PALETTE, SIZE_BG1_PALETTE

    ; Unload Background 2
    LZ4_decompress DATA_BG2_TILES, EXRAM, y
    VRAM_memcpy VRAM_BG2_TILES, EXRAM, y

    LZ4_decompress DATA_BG2_MAP, EXRAM, y
    VRAM_memcpy VRAM_BG2_MAP, EXRAM, y
    
    CGRAM_memcpy CGRAM_BG2, DATA_BG2_PALETTE, SIZE_BG2_PALETTE

    ; Unload Background 3
    LZ4_decompress DATA_BG3_TILES, EXRAM, y   
    VRAM_memcpy VRAM_BG3_TILES, EXRAM, y

    VRAM_memset VRAM_BG3_MAP, $1000, $00 ; Just fill with 0's

    CGRAM_memcpy CGRAM_BG3, DATA_BG3_PALETTE, SIZE_BG3_PALETTE

    ; Unload Sprites
    LZ4_decompress DATA_OBJ_TILES, EXRAM, y   
    VRAM_memcpy VRAM_OBJ_TILES, EXRAM, y

    CGRAM_memcpy CGRAM_OBJ, DATA_OBJ_PALETTE, SIZE_OBJ_PALETTE


    ; SpriteSetup Table, SpriteID, PosX, PosY, Tile, N, Palette, Priority, FlipH, FlipV, Size
    SpriteSetup SHADOW_OAM, 0, 256/2-16, 224/2-16, 0, 0, 0, 3, 0, 0, 1
    ;SpriteSetup SHADOW_OAM, 1, 256/2-16+$100, 224/2-16, 32, 0, 0, 3, 0, 0, 1

    .repeat RocksN, I
        SpriteSetup SHADOW_OAM, (rocksIndex+I), .lobyte(I*24), ScreenBottom, $20+(I .mod 4)*2, 0, 0, I, I .mod 2, 0, 1
    .endrepeat


    ;Set up screen mode
    lda     #bgmode(BG_MODE_1, BG3_PRIO_NORMAL, BG_SIZE_8X8, BG_SIZE_8X8, BG_SIZE_8X8, 0)
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


    ;Set VBlank handler
    VBL_set VerticalBlank

    ;Turn on screen
    lda     #inidisp(ON, DISP_BRIGHTNESS_MAX)
    sta     SFX_inidisp
    VBL_on
:   wai
    bra     :-
;===============================================================================





;-------------------------------------------------------------------------------
VerticalBlank:
    RW a8i8

    jsr ProcessBackground
    jsr ProcessPlayer
    jsr ProcessRocks
    jsr ProcessText

    ;lda SFX_tick
    ;ora #$0f
    ;sta MOSAIC

    ;Copy shadow OAM
    OAM_memcpy SHADOW_OAM
    VRAM_memcpy VRAM_BG3_MAP, SHADOW_BG3_MAP, 128
    rtl

;-------------------------------------------------------------------------------    
ProcessText:
    RW_assume a8i8
    RW a16i16
    lda SFX_tick
    and #$000f
    adc #$80
    and #$ff
    ;ora #$2000
    sta SHADOW_BG3_MAP+6
    
    lda SFX_tick
    and #$00f0
    sec
    lsr
    lsr
    lsr
    lsr
    adc #$80
    and #$ff
    ;ora #$2000
    sta SHADOW_BG3_MAP+4
    
    lda SFX_tick+1
    and #$000f
    adc #$80
    and #$ff
    ;ora #$2000
    sta SHADOW_BG3_MAP+2
    
    lda SFX_tick+1
    and #$00f0
    sec
    lsr
    lsr
    lsr
    lsr
    adc #$80
    and #$ff
    ;ora #$2000
    sta SHADOW_BG3_MAP


    RW a8i8
    rts
;-------------------------------------------------------------------------------    
ProcessBackground:
    RW_assume a8i8

    RW a16
    lda SFX_tick
    lsr
    tay
    lsr
    RW a8
    
    eor #$ff
    sta BG2VOFS
    lda #$00
    sta BG2VOFS

    tya
    eor #$ff
    lda #$00
    sta BG1VOFS
    lda #$00
    sta BG1VOFS


    rts

;-------------------------------------------------------------------------------
ProcessRocks:
    RW_assume a8i8

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
    inc
    sta SHADOW_OAM+Sprite::posY, y
    clc

    ;;;; Check Collision
    ;---------- Check Y
    sbc Player1+Sprite::posY

    bpl :+
    eor #$ff
:

    sbc #16
    bpl CollisionCheckEnd ; Doesn't collide on Y

    ;---------- Check X
    lda SHADOW_OAM+Sprite::posX, y
    sbc Player1+Sprite::posX

    bpl :+
    eor #$ff
:

    sbc #16
    bpl CollisionCheckEnd    
Collision:
    lda SHADOW_OAM+Sprite::posY, y
    sta Player1+Sprite::posY
    lda SHADOW_OAM+Sprite::posX, y
    sta Player1+Sprite::posX
CollisionCheckEnd:

    RW a16
RockLoopContinue:
    inx
    cpx #(rocksIndex+RocksN)
    bne RockLoop 

    RW a8i8
    rts

;-------------------------------------------------------------------------------
ProcessPlayer:
    RW_assume a8i8

    ldy     Player1+Sprite::tile

    RW a16i16
    lda     z:SFX_joy1cont

CheckKeyUp:
    bit     #BUTTON_UP
    beq     CheckKeyDown
    ldy     #0
    RW a8
    dec     Player1+Sprite::posY
    jmp     FinishPlayerProcess

CheckKeyDown:
    RW a16
    bit     #BUTTON_DOWN
    beq     CheckKeyLeft
    ldy     #6
    RW a8
    inc     Player1+Sprite::posY
    jmp     FinishPlayerProcess

CheckKeyLeft:
    RW a16
    bit     #BUTTON_LEFT
    beq     SkipLeft
    ldy     #4
    RW a8
    dec     Player1+Sprite::posX
    jmp     FinishPlayerProcess

SkipLeft:
    RW a16
    bit     #BUTTON_RIGHT
    beq     FinishPlayerProcess
    ldy     #2
    RW a8
    inc     Player1+Sprite::posX

FinishPlayerProcess:
    RW a8i8

    sty     Player1+Sprite::tile

    rts
;===============================================================================
;===============================================================================


.segment "LORAM"
SHADOW_OAM:    
    .res 512+32
SHADOW_BG3_MAP:
    .res 512

;-------------------------------------------------------------------------------
.segment "RODATA"

font_lookup:
    .byt $00    ;   ' '
    .byt $02    ;   '0'
    .byt $04    ;   '1'
    .byt $06    ;   '2'
    .byt $08    ;   '3'
    .byt $0a    ;   '4'
    .byt $0c    ;   '5'
    .byt $0e    ;   '6'
    .byt $20    ;   '7'
    .byt $22    ;   '8'
    .byt $24    ;   '9'
    .byt $26    ;   'A'
    .byt $28    ;   'B'
    .byt $2a    ;   'C'
    .byt $2c    ;   'D'
    .byt $2e    ;   'E'
    .byt $40    ;   'F'
    .byt $42    ;   'G'
    .byt $44    ;   'H'
    .byt $46    ;   'I'
    .byt $48    ;   'J'
    .byt $4a    ;   'K'
    .byt $4c    ;   'L'
    .byt $4e    ;   'M'
    .byt $60    ;   'N'
    .byt $62    ;   'O'
    .byt $64    ;   'P'
    .byt $66    ;   'Q'
    .byt $68    ;   'R'
    .byt $6a    ;   'S'
    .byt $6c    ;   'T'
    .byt $6e    ;   'U'
    .byt $80    ;   'V'
    .byt $82    ;   'X'
    .byt $84    ;   'Y'
    .byt $86    ;   'Z'
    
;Import music
.define SPC_FILE "data/music.spc"

.segment "RODATA"
SPC_STATE:
    SPC_incbin_state SPC_FILE

;Import graphics

DATA_BG1_TILES:     .incbin  "data/background_1.png.tiles.lz4"
DATA_BG1_MAP:       .incbin  "data/background_1.png.map.lz4"
DATA_BG1_PALETTE:   .incbin  "data/background_1.png.palette"

DATA_BG2_TILES:     .incbin  "data/background_2.png.tiles.lz4"
DATA_BG2_MAP:       .incbin  "data/background_2.png.map.lz4"
DATA_BG2_PALETTE:   .incbin  "data/background_2.png.palette"

DATA_BG3_TILES:     .incbin  "data/font_ascii.png.tiles.lz4"
DATA_BG3_PALETTE:   .incbin  "data/font_ascii.png.palette"

DATA_OBJ_TILES:     .incbin  "data/rocket_sprites.png.tiles.lz4"
DATA_OBJ_PALETTE:   .incbin  "data/rocket_sprites.png.palette"

SIZE_BG1_PALETTE = .sizeof(DATA_BG1_PALETTE)
SIZE_BG2_PALETTE = .sizeof(DATA_BG2_PALETTE)
SIZE_BG3_PALETTE = .sizeof(DATA_BG3_PALETTE)
SIZE_OBJ_PALETTE = .sizeof(DATA_OBJ_PALETTE)

.segment "ROM2"
SPC_IMAGE_LO: 
    SPC_incbin_lo SPC_FILE

.segment "ROM3"
SPC_IMAGE_HI:
    SPC_incbin_hi SPC_FILE

.segment "ROM3"