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
derived_files	:= data/background_1.png.palette
derived_files	+= data/background_2.png.palette
derived_files	+= data/background_3.png.palette
derived_files	+= data/rocket_sprites.png.palette

derived_files	+= data/background_1.png.tiles data/background_1.png.tiles.lz4
derived_files	+= data/background_2.png.tiles data/background_2.png.tiles.lz4
derived_files	+= data/background_3.png.tiles data/background_3.png.tiles.lz4
derived_files	+= data/rocket_sprites.png.tiles data/rocket_sprites.png.tiles.lz4


derived_files	+= data/background_1.png.map data/background_1.png.map.lz4
derived_files	+= data/background_2.png.map data/background_2.png.map.lz4



data/background_1.png.palette: palette_flags = -v --no-remap 
data/background_2.png.palette: palette_flags = -v --no-remap 
data/background_3.png.palette: palette_flags = -v --no-remap 

data/background_1.png.tiles: tiles_flags = -v --bpp 4 --tile-width 16 --tile-height 16
data/background_2.png.tiles: tiles_flags = -v --bpp 4 --tile-width 16 --tile-height 16
data/background_3.png.tiles: tiles_flags = -v --no-discard --no-flip --bpp 2 --tile-width 8 --tile-height 8
data/rocket_sprites.png.tiles: tiles_flags = -v --no-discard

data/background_1.png.map: map_flags = -v --map-width 32 --map-height 32
data/background_1.png.map: map_flags = -v --map-width 32 --map-height 32



# Include libSFX.make
libsfx_dir	:= ../libSFX

include $(libsfx_dir)/libSFX.make
