from pathlib import Path
import shutil
from builder.helper import *

class ScreensCompressor:
    def execute(self, is128k, introScreenExists, gameoverScreenExists, gamemapScreenExists, creditsScreenExists, redefineScreenExists, instructionsScreenExists, hud2ScreenExists, adventuretextsScreenExists):
        self.__compressScreen("title")
        self.__compressScreen("ending")
        self.__compressScreen("hud")

        if is128k:
            if introScreenExists:
                self.__compressScreen("intro")
            if gameoverScreenExists:
                self.__compressScreen("gameover")
            if gamemapScreenExists:
                self.__compressScreen("gamemap")
            if creditsScreenExists:
                self.__compressScreen("credits")
            if redefineScreenExists:
                self.__compressScreen("redefine")
            if instructionsScreenExists:
                self.__compressScreen("instructions")
            if hud2ScreenExists:
                self.__compressScreen("hud2")
            if adventuretextsScreenExists:
                self.__compressScreen("adventuretexts")

        shutil.copy(SCREENS_FOLDER + "loading.scr", OUTPUT_FOLDER + "loading.bin")

    def __compressScreen(self, screen_name):
        runCommand(BIN_FOLDER + getZx0() + " " + SCREENS_FOLDER + screen_name + ".scr " + OUTPUT_FOLDER + screen_name + ".scr.zx0")