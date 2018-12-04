.include "libSFX.i"
.include "main.i"
.include "states/menu.i"
.include "states/game.i"

;===============================================================================
.segment "CODE"
Main:
    RW a8i16

    ; Transfer and execute SPC file
    SMP_playspc SPC_STATE, SPC_IMAGE_LO, SPC_IMAGE_HI

    lda #$ff
    sta GAME_STATE_LAST

    lda #GAMESTATE_MENU
    sta GAME_STATE

    VBL_set VerticalBlank
    VBL_on

VerticalBlank:
    RW a8i16
    ; Check is state changed
    lda GAME_STATE
    cmp GAME_STATE_LAST
    beq RunStateLoop
    jsr SwitchGameState
RunStateLoop:

    lda GAME_STATE

LoopCheckStateGame:
    cmp #GAMESTATE_GAME
    bne LoopCheckStateScore
    jsr StatesGameLoop
    jmp LoopCheckEnd
LoopCheckStateScore:
    cmp #GAMESTATE_SCORE
    bne LoopCheckStateCredits
    jsr StatesMenuLoop
    jmp LoopCheckEnd
LoopCheckStateCredits:
    cmp #GAMESTATE_CREDITS
    bne LoopCheckStateBonus
    jsr StatesMenuLoop
    jmp LoopCheckEnd
LoopCheckStateBonus:
    cmp #GAMESTATE_BONUS
    bne LoopCheckStateMenu
    jsr StatesMenuLoop
    jmp LoopCheckEnd
LoopCheckStateMenu:
    cmp #GAMESTATE_MENU
    bne LoopCheckEnd
    jsr StatesMenuLoop
    jmp LoopCheckEnd
LoopCheckEnd:

    rtl

;===============================================================================
SwitchGameState:
    RW a8i16

    VBL_off



    lda GAME_STATE
    sta GAME_STATE_LAST

InitCheckStateGame:
    cmp #GAMESTATE_GAME
    bne InitCheckStateScore
    jsr StatesGameInit
    jmp InitCheckEnd
InitCheckStateScore:
    cmp #GAMESTATE_SCORE
    bne InitCheckStateCredits
    jsr StatesMenuInit
    jmp InitCheckEnd
InitCheckStateCredits:
    cmp #GAMESTATE_CREDITS
    bne InitCheckStateBonus
    jsr StatesMenuInit
    jmp InitCheckEnd
InitCheckStateBonus:
    cmp #GAMESTATE_BONUS
    bne InitCheckStateMenu
    jsr StatesMenuInit
    jmp InitCheckEnd
InitCheckStateMenu:
    cmp #GAMESTATE_MENU
    bne InitCheckEnd
    jsr StatesMenuInit
    jmp InitCheckEnd
InitCheckEnd:



    VBL_on

    lda     #inidisp(ON, DISP_BRIGHTNESS_MAX)
    sta     SFX_inidisp
:   wai
    bra     :-
    

    rts
;===============================================================================
.segment "LORAM"
GAME_STATE:    
    .res $1
GAME_STATE_LAST:    
    .res $1
SHADOW_OAM:    
    .res $220
SHADOW_BG3_MAP:
    .res $700
JUMP_TABLE_PTR:
    .res $2

;===============================================================================
;===============================================================================
.segment "RODATA"
;Import music
.define SPC_FILE "data/music_main.spc"

SPC_STATE:
    SPC_incbin_state SPC_FILE

;Import graphics

DATA_BG_STARS1_TILES:   .incbin  "data/bg_stars1.png.tiles.lz4"
DATA_BG_STARS2_TILES:   .incbin  "data/bg_stars2.png.tiles.lz4"
DATA_BG_ASCII_TILES:    .incbin  "data/bg_ascii.png.tiles.lz4"
DATA_FG_SPRITES_TILES:  .incbin  "data/fg_sprites.png.tiles.lz4"

DATA_BG_STARS1_MAP: 	.incbin  "data/bg_stars1.png.map.lz4"
DATA_BG_STARS2_MAP: 	.incbin  "data/bg_stars2.png.map.lz4"

DATA_BG_PALETTE:    	.incbin  "data/bg_stars1.png.palette"
DATA_FG_PALETTE:   		.incbin  "data/fg_sprites.png.palette"

SIZE_BG_PALETTE     	= .sizeof(DATA_BG_PALETTE)
SIZE_FG_PALETTE     	= .sizeof(DATA_FG_PALETTE)

.segment "ROM2"
SPC_IMAGE_LO:
    SPC_incbin_lo SPC_FILE

.segment "ROM3"
SPC_IMAGE_HI:
    SPC_incbin_hi SPC_FILE

.segment "ROM3"
