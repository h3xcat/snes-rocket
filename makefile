# Name
name		:= rocket
debug		:= 1

# Use packages
libsfx_packages := LZ4

# Set source directories
obj_dir		:= .build
src			:= $(call rwildcard, src/, *.c *.h)
src_smp		:= $(call rwildcard, src/, %.s700)
src_gsu		:= $(call rwildcard, src/, %.sgs)
headers		:= $(call rwildcard, src/, %.i) $(call rwildcard, src/, %.i700)

# Derived data files
derived_files	:= data/background_1.png.palette data/background_1.png.tiles data/background_1.png.map
derived_files	+= data/background_1.png.tiles.lz4 data/background_1.png.map.lz4

derived_files	+= data/background_2.png.palette data/background_2.png.tiles data/background_2.png.map
derived_files	+= data/background_2.png.tiles.lz4 data/background_2.png.map.lz4

derived_files	+= data/rocket_sprites.png.palette data/rocket_sprites.png.tiles
derived_files	+= data/rocket_sprites.png.tiles.lz4

derived_files	+= data/font_ascii.png.palette data/font_ascii.png.tiles
derived_files	+= data/font_ascii.png.tiles.lz4

# Use --no-discard option for sprite sheets
data/rocket_sprites.png.tiles: tiles_flags = -v --no-discard
data/font_ascii.png.tiles: tiles_flags = -v --no-discard --no-flip --bpp 2 --tile-width 8 --tile-height 8

# Include libSFX.make
libsfx_dir	:= ../libSFX

include $(libsfx_dir)/libSFX.make
