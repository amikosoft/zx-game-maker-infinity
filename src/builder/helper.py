import os
import sys
from pathlib import Path
import json
import subprocess

# create function to get os separator
def getOsSeparator():
    if os.name == "nt":
        return "\\"
    else:
        return "/"

ASSETS_FOLDER = str(Path("../assets/")) + getOsSeparator()
BIN_FOLDER = str(Path("../src/bin/")) + getOsSeparator()
OUTPUT_FOLDER = str(Path("output/")) + getOsSeparator()
SCREENS_FOLDER = str(Path(ASSETS_FOLDER + "screens/")) + getOsSeparator()
MAP_FOLDER = str(Path(ASSETS_FOLDER + "map/")) + getOsSeparator()
MAPS_FILE = str(Path(ASSETS_FOLDER + "map/maps.tmx"))
MAPS_PROJECT = str(Path(ASSETS_FOLDER + "map/maps.tiled-project"))
DIST_FOLDER = str(Path("../dist/")) + getOsSeparator()

if not os.path.exists(DIST_FOLDER):
    os.makedirs(DIST_FOLDER)

INITIAL_ADDRESS = 49152
MEMORY_BANK_SIZE = 16384

def getZx0():
    if os.name == "nt":
        return "salvador.exe"
    else:
        return "salvador"

verbose = False

def setVerbose(value):
    global verbose
    verbose = value

def runCommand(command):
    global verbose
    if verbose:
        result = subprocess.call(command, shell=True)
    else:
        result = subprocess.call(command, shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    if result != 0:
        print("Error executing command: " + command)
        sys.exit(1)

def getPythonExecutable():
    return str(Path(sys.executable)) + " "

def runPythonScript(script):
    global verbose
    # Accept either a string (legacy) or a list/tuple of args to avoid shell quoting
    # issues on Windows. If a sequence is provided, call subprocess directly
    # with shell=False so paths with backslashes/spaces are handled correctly.
    if isinstance(script, (list, tuple)):
        cmd = [str(Path(sys.executable))] + list(script)
        if verbose:
            result = subprocess.call(cmd)
        else:
            result = subprocess.call(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        if result != 0:
            print("Error executing python command: " + " ".join(cmd))
            sys.exit(1)
    else:
        runCommand(getPythonExecutable() + script)

def getTiledExportCommand():
    if os.name == "nt":
        program_files = os.environ["ProgramFiles"]
        return "\"" + program_files + "\\Tiled\\tiled.exe\" --export-map json " + MAPS_FILE + " " + str(Path("output/maps.json"))
    else:
        return "tiled --export-map json " + MAPS_FILE + " " + str(Path("output/maps.json"))

def tiledExport():
    runCommand(getTiledExportCommand())

def getProjectName():
    with open(str(Path("output/maps.json")), "r") as f:
        maps_json = json.load(f)
    project_name = next((prop["value"] for prop in maps_json["properties"] if prop["name"] == "gameName"), "Game Name")
    return project_name

def getProjectFileName():
    return getProjectName().replace(" ", "-")

def getEnabled128K():
    # with open(OUTPUT_FOLDER + "maps.json", "r") as f:
    #     maps_json = json.load(f)
    # return any(prop["name"] == "128Kenabled" and prop["value"] for prop in maps_json["properties"])
    return True

def getGameView():
    with open(OUTPUT_FOLDER + "maps.json", "r") as f:
        maps_json = json.load(f)
    return next((prop["value"] for prop in maps_json["properties"] if prop["name"] == "gameView"), 'side')

def getGameLanguage():
    with open(OUTPUT_FOLDER + "maps.json", "r") as f:
        maps_json = json.load(f)
    return next((prop["value"] for prop in maps_json["properties"] if prop["name"] == "gameLanguage"), 'en')

def getConsoleMode():
    with open(OUTPUT_FOLDER + "maps.json", "r") as f:
        maps_json = json.load(f)
    return next((prop["value"] for prop in maps_json["properties"] if prop["name"] == "consoleMode"), 'No')

def getMusicEnabled():
    with open(OUTPUT_FOLDER + "maps.json", "r") as f:
        maps_json = json.load(f)
    return any(prop["name"] == "musicEnabled" and prop["value"] for prop in maps_json["properties"])

def getUseBreakableTile():
    with open(OUTPUT_FOLDER + "maps.json", "r") as f:
        maps_json = json.load(f)
    return any(prop["name"] == "useBreakableTile" and prop["value"] for prop in maps_json["properties"])

def getAttrsEnabled():
    with open(OUTPUT_FOLDER + "maps.json", "r") as f:
        maps_json = json.load(f)
    return any(prop["name"] == "screenAttributes" and prop["value"] for prop in maps_json["properties"])

def getAdventureTexts():
    with open(OUTPUT_FOLDER + "maps.json", "r") as f:
        maps_json = json.load(f)
    return any(prop["name"] == "adventureTexts" and prop["value"] for prop in maps_json["properties"])

def getEnemiesShoot():
    with open(OUTPUT_FOLDER + "maps.json", "r") as f:
        maps_json = json.load(f)
    return any(prop["name"] == "enemiesShoot" and prop["value"] for prop in maps_json["properties"])

def getBulletAnimation():
    with open(OUTPUT_FOLDER + "maps.json", "r") as f:
        maps_json = json.load(f)
    return any(prop["name"] == "bulletAnimation" and prop["value"] for prop in maps_json["properties"])

def getBoomerangEnabled():
    with open(OUTPUT_FOLDER + "maps.json", "r") as f:
        maps_json = json.load(f)
    return next((prop["value"] for prop in maps_json["properties"] if prop["name"] == "bulletType"), 'boomerang')

def getBulletDisableCollisions():
    with open(OUTPUT_FOLDER + "maps.json", "r") as f:
        maps_json = json.load(f)
    return any(prop["name"] == "bulletDisableCollisions" and prop["value"] for prop in maps_json["properties"])

def getBulletType():
    with open(OUTPUT_FOLDER + "maps.json", "r") as f:
        maps_json = json.load(f)
    return next((prop["value"] for prop in maps_json["properties"] if prop["name"] == "bulletType"), 'bullet')

def concatenateFiles(output_file, input_files):
    with open(output_file, "wb") as out_file:
        for file in input_files:
            with open(file, "rb") as in_file:
                out_file.write(in_file.read())

def screenExists(screen_name):  
    return os.path.isfile(SCREENS_FOLDER + screen_name + ".scr")

def musicExists(music_name):
    return os.path.isfile(ASSETS_FOLDER + "music/" + music_name + ".tap")