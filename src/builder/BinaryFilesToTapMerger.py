from pathlib import Path
import os
from builder.helper import *

class BinaryFilesToTapMerger:
    def execute(self, is128k, useBreakableTile, enableAdventureTexts, musicEnabled, screenAttrs):
        output_file = OUTPUT_FOLDER + "files.bin"

        if os.path.isfile(output_file):
            os.remove(output_file)

        tapAddress = INITIAL_ADDRESS
        input_files = []

        input_files += [
            OUTPUT_FOLDER + "enemies.bin.zx0",
            # OUTPUT_FOLDER + "sprites.bin",
            OUTPUT_FOLDER + "tiles.bin",
            OUTPUT_FOLDER + "tiles_attrs.bin",
            OUTPUT_FOLDER + "darktiles.bin",
            OUTPUT_FOLDER + "darktiles_attrs.bin",
            OUTPUT_FOLDER + "objectsInScreen.bin",
            OUTPUT_FOLDER + "screenOffsets.bin",
            OUTPUT_FOLDER + "enemiesInScreenOffsets.bin",
            OUTPUT_FOLDER + "animatedTilesInScreen.bin",
            OUTPUT_FOLDER + "damageTiles.bin",
            OUTPUT_FOLDER + "enemiesPerScreen.bin",
            OUTPUT_FOLDER + "screenObjects.bin",
            OUTPUT_FOLDER + "screensStatus.bin",
            OUTPUT_FOLDER + "decompressedEnemiesScreen.bin",
            # OUTPUT_FOLDER + "map.bin.zx0",
            # OUTPUT_FOLDER + "decompressedMap.bin"
        ]

        if os.path.isfile(OUTPUT_FOLDER + "enemiesInitialLife.bin"):
            input_files.append(OUTPUT_FOLDER + "enemiesInitialLife.bin")
        
        if os.path.isfile(OUTPUT_FOLDER + "enemyBullets.bin"):
            input_files.append(OUTPUT_FOLDER + "enemyBullets.bin")
            
        if enableAdventureTexts and os.path.isfile(OUTPUT_FOLDER + "textsCoord.bin"):
            input_files.append(OUTPUT_FOLDER + "textsCoord.bin")
            # if not is128k:
            #     input_files.append(OUTPUT_FOLDER + "texts.bin")

        # if is128k and musicEnabled:
        #     input_files.append(OUTPUT_FOLDER + "screenMusic.bin")

        if screenAttrs:
            input_files.append(OUTPUT_FOLDER + "screenAttributes.bin")

        if useBreakableTile:
            input_files.append(OUTPUT_FOLDER + "brokenTiles.bin")

        if os.path.isfile(OUTPUT_FOLDER + "customFont.fnt"):
            input_files.append(OUTPUT_FOLDER + "customFont.fnt")

        concatenateFiles(output_file, input_files)

        runCommand("bin2tap " + output_file + " " + OUTPUT_FOLDER + "files.tap " + str(tapAddress))
