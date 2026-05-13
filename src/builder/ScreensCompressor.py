from pathlib import Path
import shutil
from builder.helper import *

class ScreensCompressor:
    def execute(self, screenList, gameLanguage, consoleMode):

        for screenName in screenList:
            if consoleMode:
                if screenExists(screenName + "_" + gameLanguage + "_console"):
                    self.__compressScreen(screenName + "_" + gameLanguage + "_console", screenName)
                else:
                    if screenExists(screenName + "_console"):
                        self.__compressScreen(screenName + "_console", screenName)
                    else:
                        if screenExists(screenName + "_" + gameLanguage):
                            self.__compressScreen(screenName + "_" + gameLanguage, screenName)
                        else:
                            self.__compressScreen(screenName, screenName)
            else:
                if screenExists(screenName + "_" + gameLanguage):
                    self.__compressScreen(screenName + "_" + gameLanguage, screenName)
                else:
                    self.__compressScreen(screenName, screenName)

        # self.__compressScreen("title")
        # self.__compressScreen("ending")
        # self.__compressScreen("hud")

        # if introScreenExists:
        #     self.__compressScreen("intro")
        # if gameoverScreenExists:
        #     self.__compressScreen("gameover")
        # if gamemapScreenExists:
        #     self.__compressScreen("gamemap")
        # if creditsScreenExists:
        #     self.__compressScreen("credits")
        # if redefineScreenExists:
        #     self.__compressScreen("redefine")
        # if instructionsScreenExists:
        #     self.__compressScreen("instructions")
        # if hud2ScreenExists:
        #     self.__compressScreen("hud2")
        # if adventuretextsScreenExists:
        #     self.__compressScreen("adventuretexts")

        shutil.copy(SCREENS_FOLDER + "loading.scr", OUTPUT_FOLDER + "loading.bin")

    def __compressScreen(self, screen_name, screen_output_name):
        runCommand(BIN_FOLDER + getZx0() + " " + SCREENS_FOLDER + screen_name + ".scr " + OUTPUT_FOLDER + screen_output_name + ".scr.zx0")