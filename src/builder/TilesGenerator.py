import os
from pathlib import Path
from builder.helper import MAP_FOLDER
from . import zxp2gus

class TilesGenerator:
    def execute(self):
        tilesPath = str(Path(MAP_FOLDER + "tiles.zxp"))

        # os.system("zxp2gus -t tiles -i " + tilesPath + " -o " + MAP_FOLDER + " -f png")
        # os.system("zxp2gus -t tiles -i " + tilesPath + " -o output -f bin")
        zxp2gus.generate("tiles",tilesPath, MAP_FOLDER, "png")
        zxp2gus.generate("tiles",tilesPath, "output", "bin")

        # tilesExtraPath = str(Path(MAP_FOLDER + "tiles_extra.zxp"))
        # zxp2gus.generate("tiles",tilesExtraPath, MAP_FOLDER, "png", True)