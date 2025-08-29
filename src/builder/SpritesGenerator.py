import os
from pathlib import Path
from builder.helper import MAP_FOLDER
from . import zxp2gus

class SpritesGenerator:
    def execute(self):
        spritesPath = str(Path(MAP_FOLDER + "/sprites.zxp"))

        # os.system("zxp2gus -t sprites -i " + spritesPath + " -o " + MAP_FOLDER + " -f png")
        # os.system("zxp2gus -t sprites -i " + spritesPath + " -o output -f bin")
        zxp2gus.generate("sprites",spritesPath, MAP_FOLDER, "png")
        # zxp2gus.generate("sprites",spritesPath, "output", "bin")