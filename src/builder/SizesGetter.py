import os
from pathlib import Path
from builder.Sizes import Sizes
from builder.helper import ASSETS_FOLDER, BIN_FOLDER, OUTPUT_FOLDER, musicExists, screenExists


class SizesGetter:
    def __init__(self, outputFolder, useBreakableTile, enableAdventureTexts, musicEnabled, screenAttrs, gameLanguage='en'):
        self.outputFolder = outputFolder
        self.useBreakableTile = useBreakableTile
        self.adventureTexts = enableAdventureTexts
        self.musicEnabled = musicEnabled
        self.screenAttrs = screenAttrs
        self.gameLanguage = gameLanguage

    def execute(self):
        sizes = Sizes()

        sizes.BEEP_FX = self.__getFileSize(ASSETS_FOLDER + "fx/fx.tap")
        sizes.TITLE_SCREEN = self.__getOutputFileSize("title.scr.zx0")
        sizes.ENDING_SCREEN = self.__getOutputFileSize("ending.scr.zx0")
        sizes.HUD_SCREEN = self.__getOutputFileSize("hud.scr.zx0")
        sizes.ENEMIES_DATA = self.__getOutputFileSize("enemies.bin.zx0")
        sizes.TILESET_DATA = self.__getOutputFileSize("tiles.bin")
        sizes.ATTR_DATA = self.__getOutputFileSize("tiles_attrs.bin")
        sizes.DARKTILESET_DATA = self.__getOutputFileSize("darktiles.bin")
        sizes.DARKATTR_DATA = self.__getOutputFileSize("darktiles_attrs.bin")
        sizes.SCREEN_OBJECTS_INITIAL_DATA = self.__getOutputFileSize("objectsInScreen.bin")
        sizes.SCREEN_OFFSETS_DATA = self.__getOutputFileSize("screenOffsets.bin")
        sizes.ENEMIES_IN_SCREEN_OFFSETS_DATA = self.__getOutputFileSize("enemiesInScreenOffsets.bin")
        sizes.ANIMATED_TILES_IN_SCREEN_DATA = self.__getOutputFileSize("animatedTilesInScreen.bin")
        sizes.DAMAGE_TILES_DATA = self.__getOutputFileSize("damageTiles.bin")
        sizes.ENEMIES_PER_SCREEN_INITIAL_DATA = self.__getOutputFileSize("enemiesPerScreen.bin")
        sizes.SCREEN_OBJECTS_DATA = self.__getOutputFileSize("screenObjects.bin")
        sizes.SCREENS_WON_DATA = self.__getOutputFileSize("screensStatus.bin")
        sizes.DECOMPRESSED_ENEMIES_SCREEN_DATA = self.__getOutputFileSize("decompressedEnemiesScreen.bin")
        
        sizes.ENEMIES_INITIAL_LIFE_DATA = self.__getOutputFileSize("enemiesInitialLife.bin") if os.path.isfile(OUTPUT_FOLDER + "enemiesInitialLife.bin") else 0
        
        sizes.ENEMIES_SHOOT_DATA = self.__getOutputFileSize("enemyBullets.bin")
        
        sizes.MAPS_DATA = self.__getOutputFileSize("map.bin.zx0")
        
        if self.adventureTexts:
            sizes.TEXTS_COORD_DATA = self.__getOutputFileSize("textsCoord.bin")
            sizes.TEXTS_DATA = self.__getOutputFileSize("texts.bin")
        
        if self.useBreakableTile:
            sizes.BROKEN_TILES_DATA = self.__getOutputFileSize("brokenTiles.bin")
        
        if self.screenAttrs:
            sizes.SCREEN_ATTRS_DATA = self.__getOutputFileSize("screenAttributes.bin")
        
        if Path(OUTPUT_FOLDER + "customFont.fnt").exists():
            sizes.CUSTOM_FONT = self.__getOutputFileSize("customFont.fnt")
        else:
            sizes.CUSTOM_FONT = 0
        
        sizes.VTPLAYER = self.__getFileSize(BIN_FOLDER + "vtplayer.tap")
        sizes.MUSIC = self.__getFileSize(OUTPUT_FOLDER + "music.tap")
        sizes.MUSIC_TITLE = self.__getFileSize(OUTPUT_FOLDER + "music-title.tap") if musicExists("title") else 0
        sizes.MUSIC_2 = self.__getFileSize(OUTPUT_FOLDER + "music2.tap") if musicExists("music2") else 0
        sizes.MUSIC_3 = self.__getFileSize(OUTPUT_FOLDER + "music3.tap") if musicExists("music3") else 0
        sizes.MUSIC_ENDING = self.__getFileSize(OUTPUT_FOLDER + "music-ending.tap") if musicExists("ending") else 0
        sizes.MUSIC_GAMEOVER = self.__getFileSize(OUTPUT_FOLDER + "music-gameover.tap") if musicExists("gameover") else 0
        
        sizes.INTRO_SCREEN = self.__getOutputFileSize("intro.scr.zx0") if screenExists("intro") or screenExists("intro_" + self.gameLanguage) else 0
        sizes.GAMEOVER_SCREEN = self.__getOutputFileSize("gameover.scr.zx0") if screenExists("gameover") or screenExists("gameover_" + self.gameLanguage) else 0
        sizes.GAMEMAP_SCREEN = self.__getOutputFileSize("gamemap.scr.zx0") if screenExists("gamemap") or screenExists("gamemap_" + self.gameLanguage) else 0
        sizes.CREDITS_SCREEN = self.__getOutputFileSize("credits.scr.zx0") if screenExists("credits") or screenExists("credits_" + self.gameLanguage) else 0
        sizes.REDEFINE_SCREEN = self.__getOutputFileSize("redefine.scr.zx0") if screenExists("redefine") or screenExists("redefine_" + self.gameLanguage) else 0
        sizes.INSTRUCTIONS_SCREEN = self.__getOutputFileSize("instructions.scr.zx0") if screenExists("instructions") or screenExists("instructions_" + self.gameLanguage) else 0
        sizes.HUD2_SCREEN = self.__getOutputFileSize("hud2.scr.zx0") if screenExists("hud2") or screenExists("hud2_" + self.gameLanguage) else 0
        sizes.ADVENTURETEXTS_SCREEN = self.__getOutputFileSize("adventuretexts.scr.zx0") if screenExists("adventuretexts") or screenExists("adventuretexts_" + self.gameLanguage) else 0
            
        return sizes
    
    def __getFileSize(self, file):
        if os.path.isfile(Path(file)):
            return os.path.getsize(Path(file))
        return 0

    def __getOutputFileSize(self, file):
        return self.__getFileSize(self.outputFolder + file)