import os
import sys
from pathlib import Path
import time
sys.path.append(str(Path(__file__).resolve().parent / 'src'))

# from builder.Builder import Builder 
from builder.helper import *
from builder.TilesGenerator import TilesGenerator
from builder.SpritesGenerator import SpritesGenerator

if os.getenv('VIRTUAL_ENV') is None:
    print("Please activate the virtual environment before running this script.")
    sys.exit(1)

verbose = False

totalExecutionTime = 0

python_executable = str(Path(sys.executable)) + " "

def buildingFilesAndConfig():
    TilesGenerator().execute()
    SpritesGenerator().execute()

def removeTempFiles():
    for file in os.listdir("output"):
        if file.endswith(".zx0") or file.endswith(".bin") or file.endswith(".tap") or file.endswith(".bas"):
            os.remove(os.path.join("output", file))

def build():
    global totalExecutionTime
    totalExecutionTime = 0

    print("============================================")
    print("=          ZXGM - Infinity                 =")
    print("============================================")

    executeFunction(buildingFilesAndConfig, "Building files and config")
    
    print("\nTotal execution time: " + f"{totalExecutionTime:.2f}s")

def executeFunction(function, message):
    global totalExecutionTime

    print(message, end="", flush=True)  # Forzar el vaciado del búfer
    start_time = time.time()
    result = function()
    end_time = time.time()
    elapsed_time = end_time - start_time
    totalExecutionTime += elapsed_time
    padding = 33 - len(message)

    elapsedTimeLenght = len(f"{elapsed_time:.2f}s")

    paddingElapsed = 8 - elapsedTimeLenght

    print("." * padding + "OK!" + " " * paddingElapsed + f"{elapsed_time:.2f}s", flush=True)  # Forzar el vaciado del búfer

    return result

def main():
    global verbose
    import argparse

    build()

if __name__ == "__main__":
    main()
