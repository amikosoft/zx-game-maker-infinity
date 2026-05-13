from builder.ConvertZXPToGuSprites import ConvertZXPToGuSprites
from builder.ScreensCompressor import ScreensCompressor
from builder.TilesGenerator import TilesGenerator
from builder.SpritesGenerator import SpritesGenerator
from builder.BinaryFilesToTapMerger import BinaryFilesToTapMerger
from builder.SizesGetter import SizesGetter
from builder.ChartGenerator import ChartGenerator
from builder.ConfigWriter import ConfigWriter
from builder.helper import *
from builder.MusicSetup import MusicSetup

class Builder:
    def execute(self):
        is128K = True
        useBreakableTile = getUseBreakableTile() and not getBulletDisableCollisions()
        enableAdventureTexts = getAdventureTexts()
        musicEnabled = getMusicEnabled()
        gameLanguage = getGameLanguage()
        consoleMode = getConsoleMode()

        # attrsEnabled = getAttrsEnabled()

        screenList = [
            "title",
            "ending",
            "hud",
            "intro",
            "gameover",
            "gamemap",
            "credits",
            "redefine",
            "instructions",
            "hud2",
            "adventuretexts"
        ]
        ScreensCompressor().execute(screenList, gameLanguage, consoleMode != "No")
        TilesGenerator().execute()
        SpritesGenerator().execute()
        MusicSetup().splitSongs()
        ConvertZXPToGuSprites.convert()
        BinaryFilesToTapMerger().execute(is128K, useBreakableTile, enableAdventureTexts, musicEnabled, True)
        sizes = SizesGetter(OUTPUT_FOLDER, useBreakableTile, enableAdventureTexts, musicEnabled, True, gameLanguage).execute()
        ChartGenerator().execute(sizes, is128K, enableAdventureTexts, musicEnabled, useBreakableTile, True)
        ConfigWriter(OUTPUT_FOLDER + "config.bas", INITIAL_ADDRESS, sizes).execute()

        return sizes