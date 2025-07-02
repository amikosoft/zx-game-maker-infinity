#include "../output/config.bas"

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

#ifdef OVERHEAD_VIEW
    Const BULLET_SPRITE_UP_ID As Ubyte = 51
    Const BULLET_SPRITE_DOWN_ID As Ubyte = 52

    #ifdef BULLET_ENEMIES
        Const BULLET_SPRITE_ENEMY_ID As Ubyte = 53
    #endif
#Else
    #ifdef BULLET_ANIMATION
        Const BULLET_SPRITE_RIGHT_2_ID As Ubyte = 51
        Const BULLET_SPRITE_LEFT_2_ID As Ubyte = 52
        
        #ifdef BULLET_ENEMIES
            Const BULLET_SPRITE_ENEMY_ID As Ubyte = 53
        #endif
    #else 
        #ifdef BULLET_ENEMIES
            Const BULLET_SPRITE_ENEMY_ID As Ubyte = 51
        #endif
    #endif
#endif

const MAX_SCREEEN_RIGHT as ubyte = 60
const MAX_SCREEN_LEFT as ubyte = 2
const MAX_SCREEN_BOTTOM as ubyte = 40
const MAX_SCREEN_TOP as ubyte = 2

const BULLET_DIRECTION_LEFT = 0
const BULLET_DIRECTION_RIGHT = 1
const BULLET_DIRECTION_UP = 8
const BULLET_DIRECTION_DOWN = 2

#ifdef BULLET_ENEMIES
    dim enemyBulletPositionX as ubyte = 0
    dim enemyBulletPositionY as ubyte = 0
    dim enemyBulletDirection as ubyte = 0
#endif

#ifdef SHOOTING_ENABLED
    dim bulletPositionX as ubyte = 0
    dim bulletPositionY as ubyte = 0
    dim bulletDirection as ubyte = 0
    dim bulletEndPositionX as ubyte = 0
    dim bulletEndPositionY as ubyte = 0
#endif

Dim protaLastFrame As Ubyte

Const LEFT As Ubyte = 0
Const RIGHT As Ubyte = 1
Const UP As Ubyte = 2
Const DOWN As Ubyte = 3
Const FIRE As Ubyte = 4

Dim currentLife As Ubyte = 100
Dim currentKeys As Ubyte = 0
Dim moveScreen As Ubyte
Dim currentScreen As Ubyte = 0
Dim currentBulletSpriteId As Ubyte
Dim enemiesScreen as Ubyte = 0

Dim protaFrame As Ubyte = 0
Dim enemFrame As Ubyte = 0

Dim kempston As Ubyte
Dim keyOption As String
Dim keyArray(4) As Uinteger

Dim framec As Ubyte AT 23672

#ifdef NEW_BEEPER_PLAYER
    Const BEEP_PERIOD As Ubyte = 1
    Dim lastFrameBeep As Ubyte = 0
#endif

Dim lastFrameProta As Ubyte = 0
Dim lastFrameEnemies As Ubyte = 0
Dim lastFrameTiles As Ubyte = 0

Const INVINCIBLE_FRAMES As Ubyte = 25
Dim invincible As Ubyte = 0

Dim protaX As Ubyte
Dim protaY As Ubyte
Dim protaDirection As Ubyte
Dim protaTile As Ubyte

#ifdef LIVES_MODE_ENABLED
    dim protaXRespawn as ubyte
    dim protaYRespawn as ubyte
#endif

Dim animatedFrame As Ubyte = 0

Dim inMenu As Ubyte = 1

#ifdef IDLE_ENABLED
    Dim protaLoopCounter As Ubyte = 0
#endif

#ifdef SHOOTING_ENABLED
    Dim noKeyPressedForShoot As Ubyte = 1
#endif
#ifdef ENABLED_128k
    #define DATA_BANK 4
    #define MUSIC_BANK 3
#endif

#ifdef SIDE_VIEW
    Dim tileSet(192, 7) As Ubyte at TILESET_DATA_ADDRESS
#Else
    Dim tileSet(194, 7) As Ubyte at TILESET_DATA_ADDRESS
#endif
Dim attrSet(191) As Ubyte at ATTR_DATA_ADDRESS
' Dim sprites(47, 31) As Ubyte at SPRITES_DATA_ADDRESS
Dim screenObjectsInitial(SCREENS_COUNT, 4) As Ubyte at SCREEN_OBJECTS_INITIAL_DATA_ADDRESS
Dim screensOffsets(SCREENS_COUNT) As Uinteger at SCREEN_OFFSETS_DATA_ADDRESS
Dim enemiesInScreenOffsets(SCREENS_COUNT) As Uinteger at ENEMIES_IN_SCREEN_OFFSETS_DATA_ADDRESS
Dim animatedTilesInScreen(SCREENS_COUNT, MAX_ANIMATED_TILES_PER_SCREEN, 2) As Ubyte at ANIMATED_TILES_IN_SCREEN_DATA_ADDRESS
Dim damageTiles(DAMAGE_TILES_COUNT) As Ubyte at DAMAGE_TILES_DATA_ADDRESS
Dim enemiesPerScreen(SCREENS_COUNT) As byte at ENEMIES_PER_SCREEN_DATA_ADDRESS
Dim enemiesPerScreenInitial(SCREENS_COUNT) As byte at ENEMIES_PER_SCREEN_INITIAL_DATA_ADDRESS
Dim screenObjects(SCREENS_COUNT, 4) As Ubyte at SCREEN_OBJECTS_DATA_ADDRESS
Dim screensWon(SCREENS_COUNT) As Ubyte at SCREENS_WON_DATA_ADDRESS
Dim decompressedEnemiesScreen(MAX_ENEMIES_PER_SCREEN, 11) As Byte at DECOMPRESSED_ENEMIES_SCREEN_DATA_ADDRESS

#ifdef USE_BREAKABLE_TILE
    Dim brokenTiles(SCREENS_COUNT) As Ubyte at BROKEN_TILES_DATA_ADDRESS
#endif

Dim spritesSet(51) As Ubyte
Dim spriteAddressIndex As Uinteger = 0

Dim bullet(7) As Ubyte

Const FIRST_RUNNING_PROTA_SPRITE_RIGHT As Ubyte = 1
Const FIRST_RUNNING_PROTA_SPRITE_LEFT As Ubyte = 5

'Dim spritesLinColTileAndFrame(MAX_ENEMIES_PER_SCREEN, 4) As Ubyte
Dim enemySpriteTempTile(MAX_ENEMIES_PER_SCREEN) As Ubyte

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

#ifdef ARCADE_MODE
    Dim currentScreenKeyX As Ubyte
    Dim currentScreenKeyY As Ubyte
#endif

#ifdef LEVELS_MODE
    Dim currentLevel As Ubyte = 0
#endif

Const ENEMY_DOOR_TILE As Ubyte = 63