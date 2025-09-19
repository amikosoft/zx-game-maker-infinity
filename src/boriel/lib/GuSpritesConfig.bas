'CONFIG DEFINES

'Please, enable/define in your Boriel ZX Basic source code some of the following parameters
'in order to choose the features of this library that you want to use.

'Enabling this parameter tells the library that you have defined all needed parameters
'before you included the library. If this parameter is not enabled/defined, the library
'will define some parameters with standard values (such as 4 for ONSCREEN_1x2_SPRITES).
'These standard values were loaded by default into the parameters till August 2025.
'
#define ALL_NEEDED_PARAMETERS_ALREADY_DEFINED

'Enabling this define tells the library to store unshifted sprites in SPRITE_BUFFER,
'that is, each 1x1,1x2,2x2 sprite in 8,16,32 bytes. Therefore, the library will use
'much less memory, but will be slower.
'If not enabled, the library will store shifted sprites in SPRITE_BUFFER, which is
'the default behavior: each 1x1,1x2,2x2 sprite in 48,72,120 bytes.
'
'#define STORE_UNSHIFTED_SPRITES

'Enabling this define tells the library that we are going to use precomputed sprites.
'Using precomputed sprites will help to reduce the library's memory footprint when
'your program is going to use a single sprite set.
'To generate the precomputed sprites I recommend to use the ResourceDesigner program
'that you will find in my Github repository (https://github.com/gusmanb/ResourceDesigner).
'
#define PRECOMPUTED_SPRITES

'When PRECOMPUTED_SPRITES is enabled, sprites are included into library at compile
'time via including a file. Next parameter defines the name of this sprite file.
'Please, choose a file whose contents are compatible with value of STORE_UNSHIFTED_SPRITES:
'If STORE_UNSHIFTED_SPRITES is   defined, use a unshifted sprites file, e.g., "sprites.bas".
'If STORE_UNSHIFTED_SPRITES is undefined, use a   shifted sprites file, e.g., "Sprites.zxbas".
'

'Enabling this define tells the library that sprite X,Y coordinates
'are measured in pixels, i.e., X can range from 0 to almost 250,
'and Y from 0 to almost 190 (0-240 and 0-176 for a 2x2 sprite).
'Coordinates for tiles are measured in characters, as usual.
'When enabled, unshifted sprites MUST be used.
'
'#define SPRITE_XY_IN_PIXELS

'Enabling this define changes the merge of the sprites and tiles to be a XOR instead of an OR
'#define MERGE_WITH_XOR

'Enabling this define activates the fast print routines
'#define ENABLE_PRINT

'The value of this parameter should be 256 bytes less than actual address
'for ROM character set (see https://skoolkid.github.io/rom/asm/3D00.html).
'You can use your own character set by setting this parameter appropriately;
'moreover, you can use 256 different characters if you define them.
'Requires ENABLE_PRINT
'#define ROM_CHARSET 3C00h

'When one of next 3 defines is not enabled, the corresponding size of sprite will not be used,
'and value of corresponding TOTAL and ONSCREEN parameters will be set to zero automatically.
#define ENABLE_1x1_SPRITES
'#define ENABLE_1x2_SPRITES
#define ENABLE_2x2_SPRITES

'Total number of 1x1 defined sprites
'Total number of 1x1 defined sprites
#ifdef BULLET_BOOMERANG
    #ifdef BULLET_ENEMIES
        #define TOTAL_1x1_SPRITES 3
    #else
        #define TOTAL_1x1_SPRITES 2
    #endif
#else
    #ifdef SIDE_VIEW
        #ifdef BULLET_ANIMATION
            #ifdef BULLET_ENEMIES
                #define TOTAL_1x1_SPRITES 5
            #else
                #define TOTAL_1x1_SPRITES 4
            #endif
        #else
            #ifdef BULLET_ENEMIES
                #define TOTAL_1x1_SPRITES 3
            #else
                #define TOTAL_1x1_SPRITES 2
            #endif
        #endif
    #else
        #ifdef BULLET_ENEMIES
            #define TOTAL_1x1_SPRITES 5
        #else
            #define TOTAL_1x1_SPRITES 4
        #endif
    #endif
#endif

'Total number of 1x2 defined sprites
'#define TOTAL_1x2_SPRITES 4
'Total number of 2x2 defined sprites
#define TOTAL_2x2_SPRITES 48

'Maximum on-screen 1x1 sprites
#ifdef BULLET_ENEMIES
    #define ONSCREEN_1x1_SPRITES 2
#Else
    #define ONSCREEN_1x1_SPRITES 1
#endif

'Maximum on-screen 1x2 sprites
'#define ONSCREEN_1x2_SPRITES 4
'Maximum on-screen 2x2 sprites
'#define ONSCREEN_2x2_SPRITES 4

'If defined enables the tile system in its basic mode (tiles erased when sprite enters on it)
#define ENABLE_TILES

'If defined tiles are merged with OR instead of erased
'Requires ENABLE_TILES
#define MERGE_TILES

'If defined, this amount of tiles can be changed each gameloop to perform an animation
'Requires ENABLE_TILES
' tiled-build
' #define MAX_ANIMATED_TILES_PER_SCREEN 10

'The lib by default disables interrupts, enabling this option
'will reactivate them after each call to the lib
' #define ENABLE_INTERRUPTS

'END CONFIG DEFINES