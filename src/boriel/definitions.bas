#include "../output/config.bas"

#define arrayBasePtr(x) (PEEK(Uinteger, @x + 2))

' #ifdef ENABLED_128k
'     Dim isAmstrad As Ubyte = 0
'     If Peek(23312) = 1
'         isAmstrad = 1
'     End If
' #endif
Const SCREEN_ADJUSTMENT As Ubyte = 1
Const PROTA_SPRITE As Ubyte = 5
Const BULLET_SPRITE_RIGHT_ID As Ubyte = 49
Const BULLET_SPRITE_LEFT_ID As Ubyte = 50

#ifdef BULLET_ANIMATION
    ' Const BULLET_SPRITE_RIGHT_2_ID As Ubyte = 51
    ' Const BULLET_SPRITE_LEFT_2_ID As Ubyte = 52   
    #ifdef BULLET_ENEMIES
        Const BULLET_SPRITE_ENEMY_ID As Ubyte = 51
    #endif
#else
    Const BULLET_SPRITE_UP_ID As Ubyte = 51
    Const BULLET_SPRITE_DOWN_ID As Ubyte = 52

    #ifdef BULLET_ENEMIES
        Const BULLET_SPRITE_ENEMY_ID As Ubyte = 53
    #endif
#endif

' Const STEPS_TILE_INIT As Ubyte = 64
' Const STEPS_TILE_END As Ubyte = 67

' const MAX_SCREEN_LEFT as ubyte = 2
' const MAX_SCREEN_TOP as ubyte = 2
' const MAX_SCREEN_RIGHT as ubyte = 60
' const MAX_SCREEN_BOTTOM as ubyte = 40

' const MAX_GENERIC_TILE as ubyte = 188

const BULLET_DIRECTION_LEFT = 0
const BULLET_DIRECTION_RIGHT = 1
const BULLET_DIRECTION_UP = 8
const BULLET_DIRECTION_DOWN = 2

#ifdef BULLET_BOOMERANG
    const BULLET_DIRECTION_BOOMERANG = 10
#endif

#ifdef BULLET_ENEMIES
    Dim enemyBullets(MAX_ENEMIES_PER_SCREEN, 2) As Byte
#endif

#ifdef SHOOTING_ENABLED
    dim bulletPositionX as byte = 0
    dim bulletPositionY as byte = 0
    dim bulletDirection as byte = 0
    dim bulletDirectionVertical as byte = 0
    dim bulletEndPositionX as byte = 0
    dim bulletEndPositionY as byte = 0
#endif

Dim protaLastFrame As Ubyte

Const LEFT As Ubyte = 0
Const RIGHT As Ubyte = 1
Const UP As Ubyte = 2
Const DOWN As Ubyte = 3
Const FIRE As Ubyte = 4

Dim currentLife As Ubyte = 100

#ifdef ENERGY_ENABLED
Dim currentEnergy As Ubyte = INITIAL_ENERGY
#endif

#ifdef KEYS_ENABLED
Dim currentKeys As Ubyte = 0
#EndIf

Dim moveScreen As Ubyte
Dim currentScreen As Ubyte = 0
Dim currentBulletSpriteId As Ubyte
Dim enemiesScreen as Ubyte = 0

Dim protaFrame As Ubyte = 0
dim enemiesFrame as ubyte = 0

Dim kempston As Ubyte
Dim keyOption As String

#ifdef BUTTON_PAUSE_ENABLED
Const PAUSE_BUTTON As Ubyte = 5
dim isPaused as ubyte = 1

    #ifdef BUTTON_QUIT_ENABLED
        Const QUIT_BUTTON As Ubyte = 6
        Dim keyArray(6) As Uinteger
    #else
        Dim keyArray(5) As Uinteger
    #endif
#else
    Dim keyArray(4) As Uinteger
#endif

Dim framec As Ubyte AT 23672

' #ifdef NEW_BEEPER_PLAYER
'     Const BEEP_PERIOD As Ubyte = 1
'     Dim lastFrameBeep As Ubyte = 0
' #endif

' Dim lastFrameProta As Ubyte = 0
' Dim lastFrameEnemies As Ubyte = 0

Const INVINCIBLE_FRAMES As Ubyte = 25
Dim invincible As Ubyte = 0

Dim protaX As Ubyte
Dim protaY As Ubyte
Dim protaDirection As Ubyte
Dim protaTile As Ubyte

Dim protaLin As Ubyte
Dim protaCol As Ubyte

Const PROTA_FRAME_RIGHT as ubyte = 0
Const PROTA_FRAME_LEFT as ubyte = 2

Const PROTA_TILE_RIGHT as ubyte = 1
Const PROTA_TILE_LEFT as ubyte = 3
Const PROTA_TILE_UP as ubyte = 5
Const PROTA_TILE_DOWN as ubyte = 7

Const PROTA_FRAME_JUMP_RIGHT as ubyte = 11
Const PROTA_FRAME_JUMP_LEFT as ubyte = 12

Const FIRST_RUNNING_PROTA_SPRITE_RIGHT As Ubyte = 1
Const FIRST_RUNNING_PROTA_SPRITE_LEFT As Ubyte = 3

#ifdef LIVES_MODE_ENABLED
    dim protaXRespawn as ubyte
    dim protaYRespawn as ubyte
    
    #ifdef CHECKPOINTS_ENABLED
        dim protaScreenRespawn as ubyte
    #endif
#endif

Dim animatedFrame As Ubyte = 1

#ifdef IDLE_ENABLED
    Dim protaLoopCounter As Ubyte = 0
#endif

#ifdef PREVENT_JUMP_ON_FIRE
    Dim shootPressed As Ubyte = 0
#endif

Dim verticalAxisKeyPressed as byte
Dim horizontalAxisKeyPressed as byte

#ifdef PLATFORM_MOVEABLE
    Dim isOnPlatform as Ubyte = 0
#endif

Const gameBank As Ubyte = 0

#ifdef ENABLED_128k
    Dim textsBank As Ubyte = 3
    Dim screensBank As Ubyte = 7 '3
    Dim musicBank As Ubyte = 4
    Dim fxBank As Ubyte = 6
    If Peek(23312) = 1 Then ' Amstrad
        textsBank = 4
        screensBank = 7
        musicBank = 3
        fxBank = 1
    End If
#endif

Dim tileSet(255, 7) As Ubyte at TILESET_DATA_ADDRESS
Dim attrSet(255) As Ubyte at ATTR_DATA_ADDRESS

Dim darkTileSet(255, 7) As Ubyte at DARKTILESET_DATA_ADDRESS
Dim darkAttrSet(255) As Ubyte at DARKATTR_DATA_ADDRESS

' Dim sprites(47, 31) As Ubyte at SPRITES_DATA_ADDRESS
Dim screenObjectsInitial(SCREENS_COUNT, 4) As Ubyte at SCREEN_OBJECTS_INITIAL_DATA_ADDRESS
Dim enemiesInScreenOffsets(SCREENS_COUNT) As Uinteger at ENEMIES_IN_SCREEN_OFFSETS_DATA_ADDRESS
Dim damageTiles(DAMAGE_TILES_COUNT) As Ubyte at DAMAGE_TILES_DATA_ADDRESS
Dim enemiesPerScreen(SCREENS_COUNT) As byte at ENEMIES_PER_SCREEN_INITIAL_DATA_ADDRESS
Dim screenObjects(SCREENS_COUNT, 4) As Ubyte at SCREEN_OBJECTS_DATA_ADDRESS
Dim screensStatus(SCREENS_COUNT) As Ubyte at SCREENS_WON_DATA_ADDRESS
Dim decompressedEnemiesScreen(MAX_ENEMIES_PER_SCREEN, ENEMIES_ATTRIBUTES_TOTAL) As Byte at DECOMPRESSED_ENEMIES_SCREEN_DATA_ADDRESS
Dim screensOffsets(SCREENS_COUNT) As Uinteger at SCREEN_OFFSETS_DATA_ADDRESS

dim decompressedMap(SCREEN_LENGTH) as ubyte

dim firstTimeEnemiesScreen as ubyte = 1

Const SCREEN_STATUS_VISITED as ubyte = 0
Const SCREEN_STATUS_NOT_VISITED as ubyte = 1
Const SCREEN_STATUS_COMPLETED as ubyte = 3

#ifdef ENEMIES_RESPAWN_IN_SCREEN_ENABLED
    Dim enemiesInitialLife(MAX_ENEMIES_PER_SCREEN) As Byte
#endif

' Dim animatedTilesInScreen(SCREENS_COUNT, MAX_ANIMATED_TILES_PER_SCREEN, 2) As Ubyte at ANIMATED_TILES_IN_SCREEN_DATA_ADDRESS

#ifdef ANIMATED_TILES_ENABLED
    Dim animatedTilesPerScreen(ANIMATED_TILES_TOTAL, 3) As Ubyte at ANIMATED_TILES_IN_SCREEN_DATA_ADDRESS
    dim firstTileInScreen as integer = 0
    Dim lastFrameTiles As Ubyte = 0

    #ifdef ANIMATED_ALL_HIDDEN 
        dim tileMustHide as ubyte = 0
    #else
        #ifdef ANIMATED_SOLID_HIDDEN
            dim tileMustHide as ubyte = 0
        #endif
    #endif
#endif

#ifdef FADE_TILES_ENABLED
    const FADE_TILE as UByte = 32
    const FADE_TILE_END as UByte = 33
    Dim maxFadeTile as ubyte = 0
    dim fadeTileStatus(FADE_TILE_TOTAL, 2) as ubyte 
#endif

#ifdef GLUE_TILE_ENABLED
    Dim isOnGlue as ubyte = 0
#endif

#ifdef IN_GAME_TEXT_ENABLED
    dim textsCoord(AVAILABLE_ADVENTURES, 5) as ubyte at TEXTS_COORD_DATA_ADDRESS
    'dim textToDisplay(AVAILABLE_TEXTS, TEXTS_SIZE) as ubyte at TEXTS_DATA_ADDRESS
    ' const TEXTS_DATA_ADDRESS2 as uinteger = 49152
    SetBank(fxBank)
    dim textToDisplay(AVAILABLE_TEXTS, TEXTS_SIZE) as ubyte at TEXTS_DATA_ADDRESS
    SetBank(gameBank)
    dim currentAdventureState as ubyte = 0
    dim currentScreenFirstText as ubyte = 0
#endif

dim isActionPerformed as ubyte = 0

#ifdef ENABLED_128k
#ifdef MUSIC_ENABLED
    Dim musicPlayed as Ubyte = 0
            
    #ifdef MUSIC_TOGGLE_ENABLED
        Dim isMusicEnabled as Ubyte = 1
    #endif
#endif
#endif

#ifdef SCREEN_ATTRIBUTES
    #ifdef TELEPORT_ENABLED
    Dim currentTeleportTo as ubyte = 0
    #endif
    Dim screenAttributes(SCREENS_COUNT, SCREEN_ATTRIBUTES_TOTAL) As Ubyte at SCREEN_ATTRS_DATA_ADDRESS
    Dim currentScreenBackground as ubyte = 0
    Dim currentTileBackground as ubyte = 0

    #ifdef SCREEN_DARK_ENABLED
    Dim screenIsDark as ubyte = 0
    #endif

    #ifdef SCREEN_TERRAIN_ENABLED
    Dim screenIsTerrain as ubyte = 0
    #endif

    #ifdef HUD2_SCREEN_ENABLED
        #ifdef SCREEN_HUD2_ENABLED
            Dim screenHud as ubyte = 0
            Dim currentHud as ubyte = 0
        #endif
    #endif
#endif

#ifdef USE_BREAKABLE_TILE
    Dim brokenTiles(SCREENS_COUNT) As Ubyte at BROKEN_TILES_DATA_ADDRESS
#endif

Const ENEMY_TILE As Ubyte = 0
Const ENEMY_LIN_INI As Ubyte = 1
Const ENEMY_COL_INI As Ubyte = 2
Const ENEMY_LIN_END As Ubyte = 3
Const ENEMY_COL_END As Ubyte = 4
Const ENEMY_HORIZONTAL_DIRECTION As Ubyte = 5
Const ENEMY_CURRENT_LIN As Ubyte = 6
Const ENEMY_CURRENT_COL As Ubyte = 7
Const ENEMY_ALIVE As Ubyte = 8
Const ENEMY_MODE As Ubyte = 9
Const ENEMY_VERTICAL_DIRECTION As Ubyte = 10
Const ENEMY_SPEED As Ubyte = 11
Const ENEMY_COLOR As Ubyte = 12

Const ENEMY_MODE_NORMAL = 0
Const ENEMY_MODE_ALERT = 1
Const ENEMY_MODE_PURSUIT = 2
Const ENEMY_MODE_ONEDIRECTION = 4
Const ENEMY_MODE_ANTICLOCKWISE = 5
Const ENEMY_MODE_CLOCKWISE = 6

Const ENEMY_MODE_TRAP_ALL = 10
Const ENEMY_MODE_TRAP_VERTICAL = 11
Const ENEMY_MODE_TRAP_HORIZONAL = 12

#ifdef ARCADE_MODE
    Dim currentScreenKeyX As Ubyte
    Dim currentScreenKeyY As Ubyte
#endif

#ifdef LEVELS_MODE
    Dim currentLevel As Ubyte = 0
#endif

' Const BREAKABLE_TILE As Ubyte = 62
' Const ENEMY_DOOR_TILE As Ubyte = 63