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

.macro WriteAscii Target, PosX, PosY, Param, Text
    RW_push
    RW a8i16
    .repeat .strlen(Text), I
        ldx #( ((Param) << 8) + (.strat(Text,I)&$ff) )
        stx Target+(PosY)*(2*32)+((PosX)+I)*(2)
    .endrepeat
    RW_pull
.endmacro
;===============================================================================
;===============================================================================
.segment "CODE"

StatesMenuInit:
    RW a8i16
    jsr LoadData
    jsr LoadText
    rts

StatesMenuLoop:
    RW a8i16

	jsr ProcessInput
    jsr ProcessText
    VRAM_memcpy VRAM_BG3_MAP, SHADOW_BG3_MAP, $700

	rts

;===============================================================================
;===============================================================================
ProcessInput:
    RW a16i16
    
    lda MENU_SELECTION
    asl
    asl
    asl
    asl
    asl
    asl
    adc #(12*(32*2)+11*2) 
    tax

    lda #$2400
    sta SHADOW_BG3_MAP, x

InputCheckUp:
    ldy z:SFX_joy1trig
    cpy #BUTTON_UP
    bne InputCheckDown

    dec MENU_SELECTION
    jmp ProcessInputEnd

InputCheckDown:
    ldy z:SFX_joy1trig
    cpy #BUTTON_DOWN
    bne ProcessInputEnd

    inc MENU_SELECTION

ProcessInputEnd:
    lda MENU_SELECTION
    and #$0003
    sta MENU_SELECTION    
    asl
    asl
    asl
    asl
    asl
    asl
    adc #(12*(32*2)+11*2) 
    tax

    lda #$244e
    sta SHADOW_BG3_MAP, x


    ldy z:SFX_joy1trig
    cpy #BUTTON_B
    bne NoSwitch
    RW a8
    lda MENU_SELECTION
    sta GAME_STATE
NoSwitch:

    RW a8i16
    rts
;===============================================================================
;===============================================================================
LoadData:
    RW a8i16
    
    ; Init shadow oam
    ;OAM_init SHADOW_OAM, $101, 1, 1



    ; Transfer Tiles
    ;LZ4_decompress DATA_BG_STARS1_TILES, EXRAM, y
    ;VRAM_memcpy VRAM_BG1_TILES, EXRAM, y

    ;LZ4_decompress DATA_BG_STARS2_TILES, EXRAM, y
    ;VRAM_memcpy VRAM_BG2_TILES, EXRAM, y

    LZ4_decompress DATA_BG_ASCII_TILES, EXRAM, y   
    VRAM_memcpy VRAM_BG3_TILES, EXRAM, y

    ;LZ4_decompress DATA_FG_SPRITES_TILES, EXRAM, y   
    ;VRAM_memcpy VRAM_OBJ_TILES, EXRAM, y


    ; Transfer Maps
    ;LZ4_decompress DATA_BG_STARS1_MAP, EXRAM, y
    ;VRAM_memcpy VRAM_BG1_MAP, EXRAM, y

    ;LZ4_decompress DATA_BG_STARS2_MAP, EXRAM, y
    ;VRAM_memcpy VRAM_BG2_MAP, EXRAM, y

    VRAM_memset VRAM_BG3_MAP, $0800, $00 ; Just fill with 0's

    ; Write palette data
    CGRAM_memcpy CGRAM_BG, DATA_BG_PALETTE, SIZE_BG_PALETTE
    ;CGRAM_memcpy CGRAM_OBJ, DATA_FG_PALETTE, SIZE_FG_PALETTE

    ;Set up screen mode
    lda     #bgmode(BG_MODE_1, BG3_PRIO_HIGH, BG_SIZE_8X8, BG_SIZE_8X8, BG_SIZE_8X8, 0)
    sta     BGMODE
    ;lda     #bgsc(VRAM_BG1_MAP, SC_SIZE_32X32)
    ;sta     BG1SC
    ;lda     #bgsc(VRAM_BG2_MAP, SC_SIZE_32X32)
    ;sta     BG2SC
    lda     #bgsc(VRAM_BG3_MAP, SC_SIZE_32X32)
    sta     BG3SC

    ldx     #bgnba(0, 0, VRAM_BG3_TILES, 0)
    stx     BG12NBA

    lda     #objsel(VRAM_OBJ_TILES, OBJ_8x8_16x16, 0)
    sta     OBJSEL
    lda     #tm(OFF, OFF, ON, OFF, OFF)
    sta     TM    
    rts

;===============================================================================
;===============================================================================
LoadText:
    RW a8i16

    WRAM_memset SHADOW_BG3_MAP, $700, $00
    WRAM_memcpy SHADOW_BG3_MAP+( 8*(32*2)+10*2), (BG3_FRAME+(22*0)), 22
    WRAM_memcpy SHADOW_BG3_MAP+( 9*(32*2)+10*2), (BG3_FRAME+(22*1)), 22
    WRAM_memcpy SHADOW_BG3_MAP+(10*(32*2)+10*2), (BG3_FRAME+(22*2)), 22
    WRAM_memcpy SHADOW_BG3_MAP+(11*(32*2)+10*2), (BG3_FRAME+(22*3)), 22
    WRAM_memcpy SHADOW_BG3_MAP+(12*(32*2)+10*2), (BG3_FRAME+(22*4)), 22
    WRAM_memcpy SHADOW_BG3_MAP+(13*(32*2)+10*2), (BG3_FRAME+(22*5)), 22
    WRAM_memcpy SHADOW_BG3_MAP+(14*(32*2)+10*2), (BG3_FRAME+(22*6)), 22
    WRAM_memcpy SHADOW_BG3_MAP+(15*(32*2)+10*2), (BG3_FRAME+(22*7)), 22
    WRAM_memcpy SHADOW_BG3_MAP+(16*(32*2)+10*2), (BG3_FRAME+(22*8)), 22


    rts
;===============================================================================
;===============================================================================
ProcessText:
    RW a16i16
    lda SFX_tick
    and #$000f
    adc #$10
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
    adc #$10
    and #$ff
    ora #$2400
    sta SHADOW_BG3_MAP+4
    
    lda SFX_tick+1
    and #$000f
    adc #$10
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
    adc #$10
    and #$ff
    ora #$2400
    sta SHADOW_BG3_MAP


    RW a8i16
    rts

;===============================================================================
;===============================================================================
.segment "LORAM"
MENU_SELECTION:
    .res 1

.segment "RODATA"

BG3_FRAME:
.word $2450, $2451, $2451, $2451, $2451, $2451, $2451, $2451, $2451, $2451, $2452
.word $2460, $242b, $2442, $2436, $243e, $2438, $2447, $2400, $2467, $2400, $2462
.word $2460, $24cd, $2400, $2400, $2400, $241d, $2442, $2437, $243a, $2438, $2462
.word $2463, $2451, $245f, $2451, $2451, $2451, $2451, $2451, $2451, $2451, $2465
.word $2460, $244f, $2466, $242c, $2447, $2434, $2445, $2447, $2400, $2400, $2462
.word $2460, $244f, $2466, $242c, $2436, $2442, $2445, $2438, $2446, $2400, $2462
.word $2460, $244f, $2466, $241c, $2445, $2438, $2437, $243c, $2447, $2446, $2462
.word $2460, $244f, $2466, $241b, $2442, $2441, $2448, $2446, $2400, $2400, $2462
.word $2470, $2471, $247f, $2471, $2471, $2471, $2471, $2471, $2471, $2471, $2472