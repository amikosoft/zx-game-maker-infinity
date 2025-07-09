#!/usr/bin/env python3

import array
import json
import math
from collections import defaultdict
import os
from pprint import pprint
import subprocess
import sys

def exitWithErrorMessage(message):
    print('\n\n=====================================================================================')
    sys.exit('ERROR: ' + message + '\n=====================================================================================\n\n')

outputDir = 'output/'

f = open(outputDir + 'maps.json')

data = json.load(f)

# Screens count per row
screenWidth = data['editorsettings']['chunksize']['width']
screenHeight = data['editorsettings']['chunksize']['height']
cellsPerScreen = screenWidth * screenHeight

tileHeight = data['tileheight']
tileWidth = data['tilewidth']

screenPixelsWidth = screenWidth * tileWidth
screenPixelsHeight = screenHeight * tileHeight

spriteTileOffset = 0

maxEnemiesPerScreen = 3
maxAnimatedTilesPerScreen = 6

damageTiles = []
animatedTilesIds = []
screenAnimatedTiles = defaultdict(dict)
ammoTile = 0
keyTile = 0
itemTile = 0
doorTile = 0
lifeTile = 0

for tileset in data['tilesets']:
    if tileset['name'] == 'tiles':
        for tile in tileset['tiles']:
            if tile['type'] == 'ammo':
                ammoTile = str(tile['id'])
            if tile['type'] == 'key':
                keyTile = str(tile['id'])
            if tile['type'] == 'item':
                itemTile = str(tile['id'])
            if tile['type'] == 'door':
                doorTile = str(tile['id'])
            if tile['type'] == 'life':
                lifeTile = str(tile['id'])
            if tile['type'] == 'animated':
                animatedTilesIds.append(tile['id'])
            if tile['type'] == 'damage':
                damageTiles.append(tile['id'])
            if tile['type'] == 'animated-damage':
                animatedTilesIds.append(tile['id'])
                damageTiles.append(tile['id'])
    elif tileset['name'] == 'sprites':
        spriteTileOffset = tileset['firstgid']

if spriteTileOffset == 0:
    print('ERROR: Sprite tileset should be called "sprites"')
    exit

# Global properties

gameName = 'Game Name'
initialLife = 40
goalItems = 2
damageAmount = 5
lifeAmount = 5
bulletDistance = 0
enemiesRespawn = 0
shooting = 1
shouldKillEnemies = 0
enabled128K = 0
hiScore = 0

initialScreen = 2
initialMainCharacterX = 8
initialMainCharacterY = 8

spritesMergeModeXor = 0
spritesWithColors = 0

backgroundAttribute = 7

animatePeriodMain = 3
animatePeriodEnemy = 3
animatePeriodTile = 10

password = ""

gameView = 'side'

jumpOnEnemies = 0
killJumpingOnTop = 0

ammo = -1
ammoIncrement = 10

musicEnabled = 0

ink = 7
paper = 0
border = 0

keysEnabled = 1
itemsEnabled = 1

itemsCountdown = 0

useBreakableTile = 0

waitPressKeyAfterLoad = 0

newBeeperPlayer = 1

redefineKeysEnabled = 0

mainCharacterExtraFrame = 1

idleTime = 0

arcadeMode = 0
levelsMode = 0

jetPackFuel = 0

gravitySpeed = 2
jumpArrayCount = 6
jumpArray = "{-2, -2, -2, -2, -2, 0}"

livesMode = 0

enemiesShoot = 0
enemiesShootDirection = 'all'
enemiesBulletCollision = True
enemiesPursuitCollide = True
enemiesShootSpeed = 2
enemiesShootingLookAtPlayer = False
enemiesShootOnlyLookingPlayer = False
bulletAnimation = 0
bulletsCollisionWithBullets = False
messagesEnabled = 0
enemiesAlertDistance = 10
bulletType = 'bullet'
bulletDisableCollisions = False
platformMoveable = False
adventureTexts = False
adventureTextsLength = 30
adventureTextsClearScreen = False

if 'properties' in data:
    for property in data['properties']:
        if property['name'] == 'gameName':
            gameName = property['value']
        elif property['name'] == 'goalItems':
            goalItems = property['value']
        elif property['name'] == 'damageAmount':
            damageAmount = property['value']
        elif property['name'] == 'lifeAmount':
            lifeAmount = property['value']
        elif property['name'] == 'initialLife':
            initialLife = property['value']
        elif property['name'] == 'bulletDistance':
            bulletDistance = property['value']
        elif property['name'] == 'enemiesRespawn':
            enemiesRespawn = 1 if property['value'] else 0
        elif property['name'] == 'shooting':
            shooting = 1 if property['value'] else 0
        elif property['name'] == 'shouldKillEnemies':
            shouldKillEnemies = 1 if property['value'] else 0
        elif property['name'] == '128Kenabled':
            enabled128K = 1 if property['value'] else 0
        elif property['name'] == 'hiScore':
            hiScore = 1 if property['value'] else 0
        elif property['name'] == 'maxEnemiesPerScreen':
            if property['value'] < 7:
                maxEnemiesPerScreen = property['value']
            else:
                maxEnemiesPerScreen = 6
        elif property['name'] == 'spritesMergeModeXor':
            spritesMergeModeXor = 1 if property['value'] else 0
        elif property['name'] == 'spritesWithColors':
            spritesWithColors = 1 if property['value'] else 0
        elif property['name'] == 'backgroundAttribute':
            backgroundAttribute = property['value']
        elif property['name'] == 'animatePeriodMain':
            animatePeriodMain = property['value']
        elif property['name'] == 'animatePeriodEnemy':
            animatePeriodEnemy = property['value']
        elif property['name'] == 'animatePeriodTile':
            animatePeriodTile = property['value']
        elif property['name'] == 'password':
            password = property['value']
        elif property['name'] == 'gameView':
            gameView = property['value']
        elif property['name'] == 'jumpOnEnemies':
            jumpOnEnemies = 1 if property['value'] else 0
        elif property['name'] == 'killJumpingOnTop':
            killJumpingOnTop = 1 if property['value'] else 0
        elif property['name'] == 'ammo':
            ammo = property['value']
        elif property['name'] == 'ammoIncrement':
            ammoIncrement = property['value']
        elif property['name'] == 'musicEnabled':
            musicEnabled = 1 if property['value'] else 0
        elif property['name'] == 'ink':
            ink = property['value']
        elif property['name'] == 'paper':
            paper = property['value']
        elif property['name'] == 'border':
            border = property['value']
        elif property['name'] == 'waitPressKeyAfterLoad':
            waitPressKeyAfterLoad = 1 if property['value'] else 0
        elif property['name'] == 'keysEnabled':
            keysEnabled = 1 if property['value'] else 0
        elif property['name'] == 'itemsEnabled':
            itemsEnabled = 1 if property['value'] else 0
        elif property['name'] == 'itemsCountdown':
            itemsCountdown = 1 if property['value'] else 0
        elif property['name'] == 'useBreakableTile':
            useBreakableTile = 1 if property['value'] else 0
        elif property['name'] == 'maxAnimatedTilesPerScreen':
            maxAnimatedTilesPerScreen = property['value']
        elif property['name'] == 'newBeeperPlayer':
            newBeeperPlayer = 1 if property['value'] else 0
        elif property['name'] == 'redefineKeysEnabled':
            redefineKeysEnabled = 1 if property['value'] else 0
        elif property['name'] == 'mainCharacterExtraFrame':
            mainCharacterExtraFrame = 1 if property['value'] else 0
        elif property['name'] == 'idleTime':
            idleTime = property['value']
        elif property['name'] == 'arcadeMode':
            arcadeMode = 1 if property['value'] else 0
        elif property['name'] == 'levelsMode':
            levelsMode = 1 if property['value'] else 0
        elif property['name'] == 'jetPackFuel':
            jetPackFuel = property['value'] 
        elif property['name'] == 'jumpType':
            if property['value'] == 'accelerated':
                jumpArrayCount = 8
                jumpArray = "{-2, -2, -2, -2, -2, 0, 0, 0}"
            elif property['value'] == 'smooth':
                jumpArrayCount = 8
                jumpArray = "{-2, -2, -2, -2, -1, -1, 0, 0}"
        elif property['name'] == 'livesMode':
            if property['value'] == 'instant respawn':
                livesMode = 1
            elif property['value'] == 'show graveyard':
                livesMode = 2
        elif property['name'] == 'messagesEnabled':
            messagesEnabled = 1 if property['value'] else 0
        elif property['name'] == 'enemiesAlertDistance':
            if property['value'] == 'near':
                enemiesAlertDistance = 10
            elif property['value'] == 'medium':
                enemiesAlertDistance = 20
            elif property['value'] == 'far':
                enemiesAlertDistance = 30
        elif property['name'] == 'bulletAnimation':
            bulletAnimation = 1 if property['value'] else 0
        elif property['name'] == 'enemiesShoot':
            enemiesShoot = property['value']
        elif property['name'] == 'enemiesShootDirection':
            enemiesShootDirection = property['value']
        elif property['name'] == 'enemiesBulletCollision':
            enemiesBulletCollision = property['value']
        elif property['name'] == 'enemiesPursuitCollide':
            enemiesPursuitCollide = property['value']
        elif property['name'] == 'enemiesShootSpeed':
            if property['value'] == 'slow':
                enemiesShootSpeed = 1
            else:
                enemiesShootSpeed = 2
        elif property['name'] == 'enemiesShootingLookAtPlayer':
            enemiesShootingLookAtPlayer = property['value']
        elif property['name'] == 'enemiesShootOnlyLookingPlayer':
            enemiesShootOnlyLookingPlayer = property['value']
        elif property['name'] == 'bulletsCollisionWithBullets':
            bulletsCollisionWithBullets = property['value']
        elif property['name'] == 'bulletType':
            bulletType = property['value']
        elif property['name'] == 'bulletDisableCollisions':
            bulletDisableCollisions = property['value']    
        elif property['name'] == 'platformMoveable':
            platformMoveable = property['value']    
        elif property['name'] == 'adventureTexts':
            adventureTexts = property['value']
        elif property['name'] == 'adventureTextsLength':
            adventureTextsLength = int(property['value'])
        elif property['name'] == 'adventureTextsClearScreen':
            adventureTextsClearScreen = property['value']
        
if len(damageTiles) == 0:
    damageTiles.append('0')
 
damageTilesCount = len(damageTiles) - 1 if len(damageTiles) > 0 else 0
animatedTilesIdsCount = len(animatedTilesIds) - 1 if len(animatedTilesIds) > 0 else 0

configStr = "const MAX_ENEMIES_PER_SCREEN as ubyte = " + str(maxEnemiesPerScreen) + "\n"
configStr += "const MAX_ANIMATED_TILES_PER_SCREEN as ubyte = " + str(maxAnimatedTilesPerScreen - 1) + "\n"
configStr += "const screenWidth as ubyte = " + str(screenWidth) + "\n"
configStr += "const screenHeight as ubyte = " + str(screenHeight) + "\n"
configStr += "const INITIAL_LIFE as ubyte = " + str(initialLife) + "\n"
configStr += "const MAX_LINE as ubyte = " + str(screenHeight * 2 - 4) + "\n"

if livesMode == 1:
    configStr += "#DEFINE LIVES_MODE_ENABLED\n"
    configStr += "#DEFINE LIVES_MODE_RESPAWN\n"
elif livesMode == 2:
    configStr += "#DEFINE LIVES_MODE_ENABLED\n"
    configStr += "#DEFINE LIVES_MODE_GRAVEYARD\n"
else:
    configStr += "const DAMAGE_AMOUNT as ubyte = " + str(damageAmount) + "\n"

configStr += "const LIFE_AMOUNT as ubyte = " + str(lifeAmount) + "\n"
configStr += "const BULLET_DISTANCE as ubyte = " + str(bulletDistance) + "\n"
configStr += "const SHOULD_KILL_ENEMIES as ubyte = " + str(shouldKillEnemies) + "\n"
configStr += "const KEY_TILE as ubyte = " + keyTile + "\n"
configStr += "const ITEM_TILE as ubyte = " + itemTile + "\n"
configStr += "const DOOR_TILE as ubyte = " + doorTile + "\n"
configStr += "const LIFE_TILE as ubyte = " + lifeTile + "\n"
configStr += "const ANIMATE_PERIOD_MAIN as ubyte = " + str(animatePeriodMain) + "\n"
configStr += "const ANIMATE_PERIOD_ENEMY as ubyte = " + str(animatePeriodEnemy) + "\n"
configStr += "const ANIMATE_PERIOD_TILE as ubyte = " + str(animatePeriodTile) + "\n\n"

configStr += "const ITEMS_COUNTDOWN as ubyte = " + str(itemsCountdown) + "\n"
configStr += "dim itemsToFind as ubyte = " + str(goalItems) + "\n"
if itemsCountdown == 1 and not arcadeMode:
    configStr += "const ITEMS_INCREMENT as ubyte = -1\n"
    configStr += "const GOAL_ITEMS as ubyte = 0 \n"
    configStr += "dim currentItems as ubyte = " + str(goalItems) + "\n"
else:
    configStr += "const ITEMS_INCREMENT as ubyte = 1\n"
    configStr += "const GOAL_ITEMS as ubyte = " + str(goalItems) + "\n"
    configStr += "dim currentItems as ubyte = 0\n\n"


# save damage tiles in file .bin instead variable
with open("output/damageTiles.bin", "wb") as f:
    f.write(bytearray(damageTiles))


configStr += "#define ONSCREEN_2x2_SPRITES " + str(maxEnemiesPerScreen) + "\n"

configStr += "const DAMAGE_TILES_COUNT as ubyte = " + str(damageTilesCount) + "\n"

if shooting == 1:
    configStr += "#DEFINE SHOOTING_ENABLED\n"

if newBeeperPlayer == 1:
    configStr += "#DEFINE NEW_BEEPER_PLAYER\n"

if keysEnabled == 1:
    configStr += "#DEFINE KEYS_ENABLED\n"

if itemsEnabled == 1:
    configStr += "#DEFINE ITEMS_ENABLED\n"

configStr += "const BACKGROUND_ATTRIBUTE as ubyte = " + str(backgroundAttribute) + "\n"

if arcadeMode == 1:
    configStr += "#DEFINE ARCADE_MODE\n"

if levelsMode == 1:
    configStr += "#DEFINE LEVELS_MODE\n"

if messagesEnabled == 1:
    configStr += "#DEFINE MESSAGES_ENABLED\n"
    configStr += "Dim messageLoopCounter As Ubyte = 0\n"
    configStr += "#Define MESSAGE_LOOPS_VISIBLE 30\n"

if enabled128K == 1:
    configStr += "#DEFINE ENABLED_128k\n"

if hiScore == 1:
    configStr += "#DEFINE HISCORE_ENABLED\n\n"
    configStr += "dim score as uinteger = 0\n"
    configStr += "dim hiScore as uinteger = 0\n"

if spritesMergeModeXor == 1:
    configStr += "#DEFINE MERGE_WITH_XOR\n"

if spritesWithColors == 1:
    configStr += "#DEFINE SPRITES_WITH_COLORS\n"

if len(password) > 0:
    configStr += "#DEFINE PASSWORD_ENABLED\n"
    # configStr += "const password as string = \"" + str(password) + "\"\n"

    configStr += "const passwordLen as ubyte = " + str(len(password)) + "\n"
    configStr += "dim password(" + str(len(password)-1) + ") as ubyte => {"

    for c in range(len(password)):
        if c > 0:
            configStr += ", "
        configStr += str(ord(password[c]))

    configStr += "}\n"

if gameView == 'overhead':
    configStr += "#DEFINE OVERHEAD_VIEW\n"
else:
    configStr += "#DEFINE SIDE_VIEW\n"

if jumpOnEnemies == 1:
    configStr += "#DEFINE JUMP_ON_ENEMIES\n"

if killJumpingOnTop == 1:
    if jumpOnEnemies == 0:
        configStr += "#DEFINE JUMP_ON_ENEMIES\n"
    configStr += "#DEFINE KILL_JUMPING_ON_TOP\n"

if ammo > -1:
    configStr += "const AMMO_TILE as ubyte = " + str(ammoTile) + "\n"
    configStr += "#DEFINE AMMO_ENABLED\n"
    configStr += "const INITIAL_AMMO as ubyte = " + str(ammo) + "\n"
    configStr += "dim currentAmmo as ubyte = " + str(ammo) + "\n"
    configStr += "const AMMO_INCREMENT as ubyte = " + str(ammoIncrement) + "\n"

if musicEnabled == 1:
    configStr += "#DEFINE MUSIC_ENABLED\n"

configStr += "const INK_VALUE as ubyte = " + str(ink) + "\n"
configStr += "const PAPER_VALUE as ubyte = " + str(paper) + "\n"
configStr += "const BORDER_VALUE as ubyte = " + str(border) + "\n"

if waitPressKeyAfterLoad == 1:
    configStr += "#DEFINE WAIT_PRESS_KEY_AFTER_LOAD\n"
    configStr += "dim firstLoad as ubyte = 1\n"

if redefineKeysEnabled == 1:
    configStr += "#DEFINE REDEFINE_KEYS_ENABLED\n"

if jetPackFuel > 0:
    configStr += "#DEFINE JETPACK_FUEL "  + str(jetPackFuel) + "\n"

if mainCharacterExtraFrame == 1:
    configStr += "#DEFINE MAIN_CHARACTER_EXTRA_FRAME\n"

if idleTime > 0:
    configStr += "#DEFINE IDLE_ENABLED\n"
    configStr += "const IDLE_TIME as ubyte = " + str(idleTime) + "\n"

for layer in data['layers']:
    if layer['type'] == 'tilelayer':
        screensCount = len(layer['chunks'])
        mapRows = layer['height']//screenHeight
        mapCols = layer['width']//screenWidth

        screens = []
        screenObjects = defaultdict(dict)

        for idx, screen in enumerate(layer['chunks']):
            screens.append(array.array('B', screen['data']))

            screenObjects[idx]['ammo'] = 0
            screenObjects[idx]['key'] = 0
            screenObjects[idx]['item'] = 0
            screenObjects[idx]['door'] = 0
            screenObjects[idx]['life'] = 0

            screenAnimatedTiles[idx] = []

            for jdx, cell in enumerate(screen['data']):
                mapX = jdx % screen['width']
                mapY = jdx // screen['width']

                tile = str(cell - 1)

                # screens[idx][mapY][mapX % screenWidth] = tile

                if int(tile) in animatedTilesIds and len(screenAnimatedTiles[idx]) < maxAnimatedTilesPerScreen:
                    screenAnimatedTiles[idx].append([tile, mapX, mapY])

                if tile == keyTile:
                    screenObjects[idx]['key'] = 1
                elif tile == itemTile:
                    screenObjects[idx]['item'] = 1
                elif tile == doorTile:
                    screenObjects[idx]['door'] = 1
                elif tile == lifeTile:
                    screenObjects[idx]['life'] = 1
                elif tile == ammoTile:
                    screenObjects[idx]['ammo'] = 1
                
configStr += "const MAP_SCREENS_WIDTH_COUNT as ubyte = " + str(mapCols) + "\n"
configStr += "const SCREEN_OBJECT_ITEM_INDEX as ubyte = 0 \n"
configStr += "const SCREEN_OBJECT_KEY_INDEX as ubyte = 1 \n"
configStr += "const SCREEN_OBJECT_DOOR_INDEX as ubyte = 2 \n"
configStr += "const SCREEN_OBJECT_LIFE_INDEX as ubyte = 3 \n"
configStr += "const SCREEN_OBJECT_AMMO_INDEX as ubyte = 4 \n"
configStr += "const SCREENS_COUNT as ubyte = " + str(screensCount - 1) + "\n\n"

configStr += "#ifdef SIDE_VIEW\n"
configStr += "  Const jumpStopValue As Ubyte = 255\n"
configStr += "  Dim landed As Ubyte = 1\n"
configStr += "  Dim jumpCurrentKey As Ubyte = jumpStopValue\n"
configStr += "  #ifndef JETPACK_FUEL\n"
configStr += "    Const jumpStepsCount As Ubyte = " + str(jumpArrayCount) + "\n"
configStr += "    Dim jumpArray(jumpStepsCount - 1) As Byte = " + jumpArray + "\n"
configStr += "  #else\n"
configStr += "    Const jumpStepsCount As Ubyte = JETPACK_FUEL\n"
configStr += "    Dim jumpEnergy As Ubyte = jumpStepsCount\n"
configStr += "  #endif\n"
configStr += "#endif\n"

if bulletAnimation == 1:
    configStr += "#define BULLET_ANIMATION\n"

if bulletType == 'boomerang':
    configStr += "#define BULLET_BOOMERANG\n"

if bulletDisableCollisions == True:
    useBreakableTile = 0
else:
    configStr += "#define BULLET_COLLISIONS\n"

if platformMoveable == True:
    configStr += "#define PLATFORM_MOVEABLE\n"

if enemiesShoot > 0:
    configStr += "#define BULLET_ENEMIES\n"
    configStr += "const BULLET_ENEMIES_RANGE as ubyte = " + str((enemiesShoot*2)) + "\n"
    configStr += "const BULLET_ENEMIES_SPEED as ubyte = " + str(enemiesShootSpeed) + "\n"
    
    if enemiesShootingLookAtPlayer == True:
        configStr += "#define BULLET_ENEMIES_LOOK_AT\n"

    if enemiesShootOnlyLookingPlayer == True:
        configStr += "#define BULLET_ENEMIES_MUST_LOOK\n"

    if bulletsCollisionWithBullets == True:
        configStr += "#define BULLET_COLLIDE_BULLET\n"

    if enemiesBulletCollision == True:
        configStr += "#define BULLET_ENEMIES_COLLIDE\n"

    if enemiesShootDirection == "all":
        configStr += "#define BULLET_ENEMIES_DIRECTION_HORIZONTAL\n"
        configStr += "#define BULLET_ENEMIES_DIRECTION_VERTICAL\n"
    elif enemiesShootDirection == "horizontal":
        configStr += "#define BULLET_ENEMIES_DIRECTION_HORIZONTAL\n"
    elif enemiesShootDirection == "vertical":
        configStr += "#define BULLET_ENEMIES_DIRECTION_VERTICAL\n"

with open("output/screenObjects.bin", "wb") as f:
    for screen in screenObjects:
        f.write(bytearray([screenObjects[screen]['item'], screenObjects[screen]['key'], screenObjects[screen]['door'], screenObjects[screen]['life'], screenObjects[screen]['ammo']]))

with open("output/objectsInScreen.bin", "wb") as f:
    for screen in screenObjects:
        f.write(bytearray([screenObjects[screen]['item'], screenObjects[screen]['key'], screenObjects[screen]['door'], screenObjects[screen]['life'], screenObjects[screen]['ammo']]))

for screen in screenAnimatedTiles:
    for i in range(maxAnimatedTilesPerScreen - len(screenAnimatedTiles[screen])):
        screenAnimatedTiles[screen].append([0, 0, 0])

with open("output/animatedTilesInScreen.bin", "wb") as f:
    for screen in screenAnimatedTiles:
        for tile in screenAnimatedTiles[screen]:
            f.write(bytearray([int(tile[0]), int(tile[1]), int(tile[2])]))

# configStr += "dim screenObjectsInitial(" + str(screensCount - 1) + ", 3) as ubyte = { _\n"
# for screen in screenObjects:
#     configStr += '\t{' + str(screenObjects[screen]['item']) + ', ' + str(screenObjects[screen]['key']) + ', ' + str(screenObjects[screen]['door']) + ', ' + str(screenObjects[screen]['life']) + '}, _\n'
# configStr = configStr[:-4]
# configStr += " _\n}\n\n"

configStr += "const SCREEN_LENGTH as uinteger = " + str(len(screens[0]) - 1) + "\n"
configStr += "dim decompressedMap(SCREEN_LENGTH) as ubyte\n"

currentOffset = 0
screenOffsets = []
screenOffsets.append(currentOffset)

if shouldKillEnemies == 1:
    configStr += "#DEFINE SHOULD_KILL_ENEMIES_ENABLED\n"

if enemiesRespawn == 0:
    configStr += "#DEFINE ENEMIES_NOT_RESPAWN_ENABLED\n"

with open("output/screensWon.bin", "wb") as f:
    f.write(bytearray([0] * screensCount))

if useBreakableTile == 1:
    configStr += "#DEFINE USE_BREAKABLE_TILE\n"
    with open("output/brokenTiles.bin", "wb") as f:
        f.write(bytearray([0] * screensCount))

for idx, screen in enumerate(screens):
    label = 'screen' + str(idx).zfill(3)
    with open(outputDir + label + '.bin', 'wb') as f:
        screen.tofile(f)
    subprocess.run(['bin/zx0', '-f', outputDir + label + '.bin', outputDir + label + '.bin.zx0'])
    currentOffset += os.path.getsize(outputDir + label + '.bin.zx0')
    screenOffsets.append(currentOffset)

with open(outputDir + "screenOffsets.bin", "wb") as f:
    for offset in screenOffsets:
        f.write(offset.to_bytes(2, byteorder='little'))

# Construct enemies
enemiesPursuit = 0
enemiesAlert = 0
enemiesOneDirection = 0
enemiesClockwise = 0
enemiesAnticlockwise = 0

objects = {}
keys = {}
items = {}

texts = []
isAdventure = False
maxAdventureState = 0

# musics
musicsSelected = [False,False,False,False,False,False,]

musics = {}

for layer in data['layers']:
    if layer['type'] == 'objectgroup':
        for object in layer['objects']:
            if 'gid' in object:
                xScreenPosition = math.ceil(object['x'] / screenPixelsWidth) - 1
                yScreenPosition = math.ceil(object['y'] / screenPixelsHeight) - 1
                screenId = xScreenPosition + (yScreenPosition * mapCols)
                objects[str(object['id'])] = {
                    'name': object['name'],
                    'screenId': screenId,
                    'linIni': str(int((object['y'] % (tileHeight * screenHeight))) // 4),
                    'linEnd': str(int((object['y'] % (tileHeight * screenHeight))) // 4),
                    'colIni': str(int((object['x'] % (tileWidth * screenWidth))) // 4),
                    'colEnd': str(int((object['x'] % (tileWidth * screenWidth))) // 4),
                    'tile': str(object['gid'] - spriteTileOffset),
                    'life': '1',
                    'speed': '3',
                    'mode': '0'
                }

                if 'properties' in object and len(object['properties']) > 0:
                    for property in object['properties']:
                        if property['name'] == 'life':
                            if property['value'] == 99:
                                objects[str(object['id'])]['life'] = "-100"
                            else:
                                objects[str(object['id'])]['life'] = str(property['value'])
                        elif property['name'] == 'speed':
                            if property['value'] in [0, 1, 2]:
                                objects[str(object['id'])]['speed'] = str(property['value'] + 1)
                        elif property['name'] == 'mode':
                            if property['value'] == 'alert':
                                objects[str(object['id'])]['mode'] = '1'
                                enemiesPursuit = 1
                                enemiesAlert = 1
                            elif property['value'] == 'pursuit':
                                objects[str(object['id'])]['mode'] = '2'
                                enemiesPursuit = 1
                            elif property['value'] == 'one direction':
                                objects[str(object['id'])]['mode'] = '4'
                                enemiesOneDirection = 1
                            elif property['value'] == 'anticlockwise':
                                objects[str(object['id'])]['mode'] = '5'
                                enemiesAnticlockwise = 1
                            elif property['value'] == 'clockwise':
                                objects[str(object['id'])]['mode'] = '6'
                                enemiesClockwise = 1

if enemiesPursuit == 1:
    configStr += "#DEFINE ENEMIES_PURSUIT_ENABLED\n"
    if enemiesPursuitCollide == True:
        configStr += "#DEFINE ENEMIES_PURSUIT_COLLIDE\n"

if enemiesAlert == 1:
    configStr += "#DEFINE ENEMIES_ALERT_ENABLED\n"
    configStr += "#DEFINE ENEMIES_ALERT_DISTANCE " + str(enemiesAlertDistance) + "\n"

if enemiesOneDirection == 1:
    configStr += "#DEFINE ENEMIES_ONE_DIRECTION_ENABLED\n"

if enemiesAnticlockwise == 1:
    configStr += "#DEFINE ENEMIES_ANTICLOCKWISE_ENABLED\n"

if enemiesClockwise == 1:
    configStr += "#DEFINE ENEMIES_CLOCKWISE_ENABLED\n"

for layer in data['layers']:
    if layer['type'] == 'objectgroup':
        for object in layer['objects']:
            if 'point' in object and object['point'] == True:
                xScreenPosition = math.ceil(object['x'] / screenPixelsWidth) - 1
                yScreenPosition = math.ceil(object['y'] / screenPixelsHeight) - 1
                screenId = xScreenPosition + (yScreenPosition * mapCols)
                    
                if object['type'] == '' and 'properties' in object:
                    objects[str(object['properties'][0]['value'])]['linEnd'] = str(int((object['y'] % (tileHeight * screenHeight))) // 4)
                    objects[str(object['properties'][0]['value'])]['colEnd'] = str(int((object['x'] % (tileWidth * screenWidth))) // 4)

                    # la posicion final no puede estar por encima de la inicial
                    if objects[str(object['properties'][0]['value'])]['mode'] == '5' or objects[str(object['properties'][0]['value'])]['mode'] == '6':
                        if int(objects[str(object['properties'][0]['value'])]['colEnd']) < int(objects[str(object['properties'][0]['value'])]['colIni']):
                            colIni = objects[str(object['properties'][0]['value'])]['colEnd']
                            colEnd = objects[str(object['properties'][0]['value'])]['colIni'] 
                            objects[str(object['properties'][0]['value'])]['colEnd'] = colEnd
                            objects[str(object['properties'][0]['value'])]['colIni'] = colIni

                        if int(objects[str(object['properties'][0]['value'])]['linEnd']) < int(objects[str(object['properties'][0]['value'])]['linIni']):
                            linIni = objects[str(object['properties'][0]['value'])]['linEnd']
                            linEnd = objects[str(object['properties'][0]['value'])]['linIni'] 
                            objects[str(object['properties'][0]['value'])]['linEnd'] = linEnd
                            objects[str(object['properties'][0]['value'])]['linIni'] = linIni

                elif object['type'] == 'mainCharacter':
                    initialScreen = screenId
                    initialMainCharacterX = str(int((object['x'] % (tileWidth * screenWidth))) // 4)
                    initialMainCharacterY = str(int((object['y'] % (tileHeight * screenHeight))) // 4)

                    if int(initialMainCharacterX) < 2 or int(initialMainCharacterX) > 60 or int(initialMainCharacterY) < 0 or int(initialMainCharacterY) > 38:
                        exitWithErrorMessage('Main character initial position is out of bounds. X: ' + initialMainCharacterX + ', Y: ' + initialMainCharacterY)
                    
                    if arcadeMode == 1: # Voy guardando en un array cuyo indice sea la pantalla y el valor sea la posición de inicio
                        keys[str(screenId)] = [int(initialMainCharacterX), int(initialMainCharacterY)]
                elif object['type'] == 'text':
                    if adventureTexts == True:
                        xScreenPosition = int((object['x'] % (tileWidth * screenWidth))) // 4
                        yScreenPosition = int((object['y'] % (tileHeight * screenHeight))) // 4

                        # print(object['properties'])

                        adventureState = 0
                        adventureItem = 0
                        adventureText = ''
                        for prop in range(len(object['properties'])):
                            if object['properties'][prop]['name'] == 'es' or object['properties'][prop]['name'] == 'en':
                                adventureText = object['properties'][prop]['value']
                            elif object['properties'][prop]['name'] == 'itemAction':
                                adventureItem = object['properties'][prop]['value']
                            elif object['properties'][prop]['name'] == 'adventureState':
                                isAdventure = True
                                adventureState = object['properties'][prop]['value']

                                if adventureState > maxAdventureState:
                                    maxAdventureState = adventureState

                        if len(adventureText) >0:
                            if adventureItem == 1 and adventureState == 0:
                                print(adventureItem)
                                print(adventureState)
                                print(object['properties'])
                                exitWithErrorMessage('Cannot set an item to text without adventure state')
                            texts.append([str(screenId), str(xScreenPosition), str(yScreenPosition), adventureText, adventureItem, adventureState])

                            if len(texts) > 250:
                                exitWithErrorMessage('Total text messages cannot be higher than 250')
                elif object['type'] == 'music1':
                    musics[screenId] = [1]
                    musicsSelected[0] = True
                elif object['type'] == 'music2':
                    musics[screenId] = [2]
                    musicsSelected[1] = True
                elif object['type'] == 'music3':
                    musics[screenId] = [3]
                    musicsSelected[2] = True
                elif object['type'] == 'title':
                    musics[screenId] = [4]
                    musicsSelected[3] = True
                elif object['type'] == 'ending':
                    musics[screenId] = [5]
                    musicsSelected[4] = True
                elif object['type'] == 'gameover':
                    musics[screenId] = [6]
                    musicsSelected[5] = True
                else:
                    exitWithErrorMessage('Unknown object type. Only "enemy", "text", "music2", "music3" or "mainCharacter" are allowed')   

# CONTROL DE MUSICAS
# if someMusicSelected == True:
# configStr += "#DEFINE MUSIC_SELECTED\n"
if musicEnabled == 1:
    if musicsSelected[0] == True:
        configStr += "#DEFINE MUSIC_1_SELECTED\n"
    if musicsSelected[1] == True:
        configStr += "#DEFINE MUSIC_2_SELECTED\n"
    if musicsSelected[2] == True:
        configStr += "#DEFINE MUSIC_3_SELECTED\n"
    if musicsSelected[3] == True:
        configStr += "#DEFINE MUSIC_4_SELECTED\n"
    if musicsSelected[4] == True:
        configStr += "#DEFINE MUSIC_5_SELECTED\n"
    if musicsSelected[5] == True:
        configStr += "#DEFINE MUSIC_6_SELECTED\n"

    with open("output/screenMusic.bin", "wb") as f:
        for screenId in range(screensCount):
            if screenId in musics:
                f.write(bytearray(musics[screenId]))
            else:
                f.write(bytearray([0]))

if adventureTexts and len(texts) > 0:
    configStr += "#DEFINE IN_GAME_TEXT_ENABLED\n"

    configStr += "const TEXTS_SIZE as ubyte = " + str(adventureTextsLength) + "\n"
    
    if adventureTextsClearScreen == True:
        configStr += "#DEFINE FULLSCREEN_TEXTS\n"
    
    if isAdventure:
        if maxAdventureState < 2:
            exitWithErrorMessage('Max adventure state must be higher than 1. Current: ' + str(maxAdventureState))
        
        configStr += "#DEFINE IS_TEXT_ADVENTURE\n"
        configStr += "const MAX_ADVENTURE_STATE as ubyte = " + str(maxAdventureState) + "\n"

    allTexts = []

    with open("output/textsCoord.bin", "wb") as f:
        sortedTexts = sorted(texts, key=lambda texto: texto[0])
        for i in range(len(sortedTexts)):
            print("=========================")
            itemText = sortedTexts[i]
            print(itemText)
            print("texto: " + itemText[3])
            if len(itemText[3]) > 0:
                textoFinal = itemText[3]
                # Truncar texto mayor de 60 caracteres
                if len(textoFinal) > adventureTextsLength:
                    print("texto truncado")
                    textoFinal = itemText[3][0:adventureTextsLength]

                posicion = -1

                for p, string in enumerate(allTexts):
                    if string == textoFinal:
                        print("texto existente "+ string + " en posicion " + str(p))
                        posicion = p
                        break
                
                if posicion == -1:
                    # Verificar que no exista ya el texto
                    allTexts.append(textoFinal)
                    posicion = int(len(allTexts)) - 1
                    print("texto nuevo "+ textoFinal + " en posicion " + str(posicion))
                
                print(textoFinal)
                f.write(bytearray([int(itemText[0]), int(itemText[1]), int(itemText[2]), posicion, int(itemText[4]), int(itemText[5])]))

    print("ALL TEXTS")
    with open("output/texts.bin", "wb") as f:
        for i in allTexts:
            print(i)
            # if len(i > 20)
            f.write(i.ljust(adventureTextsLength, ' ').encode('ascii'))
            f.write(b'\x00')

    configStr += "const AVAILABLE_ADVENTURES as ubyte = " + str(len(texts) - 1) + "\n"
    configStr += "const AVAILABLE_TEXTS as ubyte = " + str(len(allTexts) - 1) + "\n"

    print("ALL ADVENTURES LENGTH "+ str(len(texts)))
    print("ALL TEXTS LENGTH "+ str(len(allTexts)))

# OPTIMIZAR
if arcadeMode == 1: # Defino el array de posiciones iniciales del personaje principal
    configStr += "dim mainCharactersArray(" + str(screensCount - 1) + ", 1) as ubyte = { _\n"
    for key in keys:
        configStr += '\t{' + str(keys[key][0]) + ', ' + str(keys[key][1]) + '}, _\n'
    configStr = configStr[:-4]
    configStr += " _\n}\n\n"

screenEnemies = defaultdict(dict)

for enemyId in objects:
    enemy = objects[enemyId]
    if len(screenEnemies[enemy['screenId']]) == 0:
        screenEnemies[enemy['screenId']] = []
    screenEnemies[enemy['screenId']].append(enemy)

enemiesPerScreen = []

configStr += "const INITIAL_SCREEN as ubyte = " + str(initialScreen) + "\n"
configStr += "const INITIAL_MAIN_CHARACTER_X as ubyte = " + str(initialMainCharacterX) + "\n"
configStr += "const INITIAL_MAIN_CHARACTER_Y as ubyte = " + str(initialMainCharacterY) + "\n"

# configStr += "\n\ntextsData:\n"
# for i in allTexts:
#     configStr += "DATA \"" + i + "\"\n"

configStr += "\n\n"

enemiesArray = []

for layer in data['layers']:
    if layer['type'] == 'tilelayer':
        for idx, screen in enumerate(layer['chunks']):
            arrayBuffer = []
            if idx in screenEnemies:
                screen = screenEnemies[idx]
                enemiesPerScreen.append(0)
                for i in range(maxEnemiesPerScreen):
                    if i <= len(screen) - 1:
                        enemy = screen[i]
                        if enemy['mode'] == '0' or enemy['mode'] == '1' or enemy['mode'] == '2':
                            if (int(enemy['colIni']) < int(enemy['colEnd'])):
                                horizontalDirection = '-1'
                            elif (int(enemy['colIni']) > int(enemy['colEnd'])):
                                horizontalDirection = '1'
                            else:
                                horizontalDirection = '0'

                            if int(enemy['linIni']) < int(enemy['linEnd']):
                                verticalDirection = '-1'
                            elif int(enemy['linIni']) > int(enemy['linEnd']):
                                verticalDirection = '1'
                            else:
                                verticalDirection = '0'
                        elif enemy['mode'] == '5' or enemy['mode'] == '6':
                            horizontalDirection = '0'
                            verticalDirection = '0'
                        else:
                            if (int(enemy['colIni']) < int(enemy['colEnd'])):
                                horizontalDirection = '1'
                            elif (int(enemy['colIni']) > int(enemy['colEnd'])):
                                horizontalDirection = '-1'
                            else:
                                horizontalDirection = '0'

                            if int(enemy['linIni']) < int(enemy['linEnd']):
                                verticalDirection = '1'
                            elif int(enemy['linIni']) > int(enemy['linEnd']):
                                verticalDirection = '-1'
                            else:
                                verticalDirection = '0'

                        enemiesPerScreen[idx] = enemiesPerScreen[idx] + 1
                        arrayBuffer.append(int(enemy['tile']))
                        arrayBuffer.append(int(enemy['linIni']))
                        arrayBuffer.append(int(enemy['colIni']))
                        arrayBuffer.append(int(enemy['linEnd']))
                        arrayBuffer.append(int(enemy['colEnd']))
                        arrayBuffer.append(int(horizontalDirection))
                        arrayBuffer.append(int(enemy['linIni']))
                        arrayBuffer.append(int(enemy['colIni']))
                        arrayBuffer.append(int(enemy['life']))
                        arrayBuffer.append(int(enemy['mode']))
                        arrayBuffer.append(int(verticalDirection))                  
                        arrayBuffer.append(int(enemy['speed']))                  
                    else:
                        arrayBuffer.append(0)
                        arrayBuffer.append(0)
                        arrayBuffer.append(0)
                        arrayBuffer.append(0)
                        arrayBuffer.append(0)
                        arrayBuffer.append(0)
                        arrayBuffer.append(0)
                        arrayBuffer.append(0)
                        arrayBuffer.append(0)
                        arrayBuffer.append(0)
                        arrayBuffer.append(0) 
                        arrayBuffer.append(0)
            else:
                for i in range(maxEnemiesPerScreen):
                    arrayBuffer.append(0)
                    arrayBuffer.append(0)
                    arrayBuffer.append(0)
                    arrayBuffer.append(0)
                    arrayBuffer.append(0)
                    arrayBuffer.append(0)
                    arrayBuffer.append(0)
                    arrayBuffer.append(0)
                    arrayBuffer.append(0)
                    arrayBuffer.append(1)
                    arrayBuffer.append(0)
                    arrayBuffer.append(0)
                enemiesPerScreen.append(0)
            enemiesArray.append(array.array('b', arrayBuffer))

enemiesInScreenOffsets = []
enemiesInScreenOffsets.append(0)
currentOffset = 0
for idx, enemiesScreen in enumerate(enemiesArray):
    label = 'enemiesInScreen' + str(idx).zfill(3)
    with open(outputDir + label + '.bin', 'wb') as f:
        enemiesScreen.tofile(f)
    subprocess.run(['bin/zx0', '-f', outputDir + label + '.bin', outputDir + label + '.bin.zx0'])
    currentOffset += os.path.getsize(outputDir + label + '.bin.zx0')
    enemiesInScreenOffsets.append(currentOffset)

with open(outputDir + "enemiesInScreenOffsets.bin", "wb") as f:
    for offset in enemiesInScreenOffsets:
        f.write(offset.to_bytes(2, byteorder='little'))

with open("output/enemiesPerScreen.bin", "wb") as f:
    f.write(bytearray(enemiesPerScreen))

with open("output/decompressedEnemiesScreen.bin", "wb") as f:
    for i in range(maxEnemiesPerScreen):
        f.write(bytearray([0] * 12))

with open(outputDir + "config.bas", "w") as text_file:
    print(configStr, file=text_file)

with open(outputDir + 'map.bin.zx0', 'wb') as outfile:
    for idx in range(screensCount):
        label = 'screen' + str(idx).zfill(3)
        with open(outputDir + label + '.bin.zx0', 'rb') as infile:
            outfile.write(infile.read())

with open(outputDir + 'enemies.bin.zx0', 'wb') as outfile:
    for idx in range(screensCount):
        label = 'enemiesInScreen' + str(idx).zfill(3)
        with open(outputDir + label + '.bin.zx0', 'rb') as infile:
            outfile.write(infile.read())