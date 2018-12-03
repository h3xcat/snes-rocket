.include "libSFX.i"
.include "main.i"
.include "states/menu.i"
.include "states/game.i"

;===============================================================================
.segment "CODE"
Main:
    RW a8i16
    jsr StatesMenuInit
    rtl

;===============================================================================
.segment "LORAM"
SHADOW_OAM:    
    .res $220
SHADOW_BG3_MAP:
    .res $700

;===============================================================================
;===============================================================================
.segment "RODATA"

;Import music
.define SPC_FILE "data/music_main.spc"

.segment "RODATA"
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
