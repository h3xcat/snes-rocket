.include "libsfx.i"
.include "../main.i"
.include "menu.i"

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

;JOY BIT MASKS
BUTTON_B        = $8000
BUTTON_Y        = $4000
BUTTON_SELECT   = $2000
BUTTON_START    = $1000
BUTTON_UP       = $0800
BUTTON_DOWN     = $0400
BUTTON_LEFT     = $0200
BUTTON_RIGHT    = $0100
BUTTON_A        = $0080
BUTTON_X        = $0040
BUTTON_L        = $0020
BUTTON_R        = $0010

GAMESTATE_START = $00
GAMESTATE_SCORE = $01
GAMESTATE_GAME  = $02
GAMESTATE_END   = $03

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

StatesMenuInit:
    RW_assume a8i16
    jsr LoadData
    jsr LoadAscii
	rts

StatesMenuLoop:
	RW a8i8
	
    jsr ProcessText

    VRAM_memcpy VRAM_BG3_MAP, SHADOW_BG3_MAP, $700

	rtl

;===============================================================================
;===============================================================================
LoadData:
    RW_assume a8i16
    
    ; Init shadow oam
    OAM_init SHADOW_OAM, $101, 0, 0

    ; Transfer and execute SPC file
    SMP_playspc SPC_STATE, SPC_IMAGE_LO, SPC_IMAGE_HI

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

    ;Set VBlank handler
    VBL_set StatesMenuLoop

    ;Turn on screen
    lda     #inidisp(ON, DISP_BRIGHTNESS_MAX)
    sta     SFX_inidisp
    VBL_on
:   wai
    bra     :-
    WRAM_memset SHADOW_BG3_MAP, $700, $00
    
    rts

;===============================================================================
;===============================================================================

;===============================================================================
;===============================================================================
ProcessText:
    RW_assume a8i8
    RW a16i16
    lda SFX_tick
    and #$000f
    adc #$80
    and #$ff
    ora #$2400
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
    ora #$2400
    sta SHADOW_BG3_MAP+4
    
    lda SFX_tick+1
    and #$000f
    adc #$80
    and #$ff
    ora #$2400
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
    ora #$2400
    sta SHADOW_BG3_MAP


    RW a8i8
    rts

;===============================================================================
;===============================================================================
.segment "RODATA"

TXT_TITLE: .asciiz    "Rocket Dodge"

