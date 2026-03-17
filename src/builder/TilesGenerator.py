import os
from pathlib import Path
from builder.helper import MAP_FOLDER, OUTPUT_FOLDER
from . import zxp2gus

class TilesGenerator:
    def execute(self):
        tilesPath = str(Path(MAP_FOLDER + "tiles.zxp"))
        darkTilesPath = str(Path(MAP_FOLDER + "tiles_dark.zxp"))

        # os.system("zxp2gus -t tiles -i " + tilesPath + " -o " + MAP_FOLDER + " -f png")
        # os.system("zxp2gus -t tiles -i " + tilesPath + " -o output -f bin")
        zxp2gus.generate("tiles",tilesPath, MAP_FOLDER + '/tiles', "png", True)
        zxp2gus.generate("tiles",tilesPath, OUTPUT_FOLDER + '/tiles', "bin", True)


        zxp2gus.generate("tiles",darkTilesPath, MAP_FOLDER + '/darktiles', "png", True)
        zxp2gus.generate("tiles",darkTilesPath, OUTPUT_FOLDER + '/darktiles', "bin", True)

        # tilesExtraPath = str(Path(MAP_FOLDER + "tiles_extra.zxp"))
        # zxp2gus.generate("tiles",tilesExtraPath, MAP_FOLDER, "png", True)