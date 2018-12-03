# Name
name		:= main
debug		:= 1

# Use packages
libsfx_packages := LZ4

# Set source directories
obj_dir		:= .build
src			:= $(call rwildcard, src/, *.c *.h)
src_smp		:= $(call rwildcard, src/, %.s700)
src_gsu		:= $(call rwildcard, src/, %.sgs)
headers		:= $(call rwildcard, src/, %.i) $(call rwildcard, src/, %.i700)

# Palettes
derived_files	:= data/bg_stars1.png.palette
derived_files	+= data/bg_stars2.png.palette
derived_files	+= data/bg_ascii.png.palette
derived_files	+= data/fg_sprites.png.palette

# Tiles
derived_files	+= data/bg_stars1.png.tiles data/bg_stars1.png.tiles.lz4
derived_files	+= data/bg_stars2.png.tiles data/bg_stars2.png.tiles.lz4
derived_files	+= data/bg_ascii.png.tiles data/bg_ascii.png.tiles.lz4
derived_files	+= data/fg_sprites.png.tiles data/fg_sprites.png.tiles.lz4

# Maps
derived_files	+= data/bg_stars1.png.map data/bg_stars1.png.map.lz4
derived_files	+= data/bg_stars2.png.map data/bg_stars2.png.map.lz4


# Since the palette is shared between all these 3 images, don't remap
data/bg_stars1.png.palette: palette_flags = -v --no-remap 
data/bg_stars2.png.palette: palette_flags = -v --no-remap 
data/bg_ascii.png.palette: palette_flags = -v --no-remap 

data/bg_stars1.png.tiles: tiles_flags = -v --bpp 4 --tile-width 16 --tile-height 16
data/bg_stars2.png.tiles: tiles_flags = -v --bpp 4 --tile-width 16 --tile-height 16
data/bg_ascii.png.tiles: tiles_flags = -v --no-discard --no-flip --bpp 2 --tile-width 8 --tile-height 8
data/fg_sprites.png.tiles: tiles_flags = -v --no-discard

data/bg_stars1.png.map: map_flags = -v --map-width 32 --map-height 32
data/bg_stars2.png.map: map_flags = -v --map-width 32 --map-height 32


# Include libSFX.make
libsfx_dir	:= ../libSFX

include $(libsfx_dir)/libSFX.make

run2: $(rom)
	no\$$sns $(rom)