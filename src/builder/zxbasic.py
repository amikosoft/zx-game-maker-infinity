# import os
# import subprocess
# import array

from pathlib import Path

def prepareTilesWithOutMirror(tiles):
    result = []
    counter = 0
    for i in range(0, 48):
        result.append(tiles[counter])
        counter += 1

    return result
    

def getSpritesBas(tiles, outFolder):
    # if len(tiles) == 32:
    #     tiles = prepareTiles(tiles)
    # else:
    tiles = prepareTilesWithOutMirror(tiles)

    # with open('boriel/lib/sprites.bas', "w") as f:
    #     f.write("'REM --SPRITE SECTION--\n\n")
    #     f.write("asm\n\n")
    #     f.write("SPRITE_BUFFER:\n")
        
    #     for sprite in tiles:
    #         f.write("\tDEFB " + str(sprite).replace("[", "").replace("]", "") + '\n')
        
    #     f.write("SPRITE_INDEX:\n")
        
    #     spriteIndex = 0
    #     for sprite in tiles:
    #         f.write("\tDEFW (SPRITE_BUFFER + " + str(spriteIndex) + ")\n")

    #         spriteIndex += 32
        
    #     f.write("SPRITE_COUNT:\n")
    #     f.write("\tDEFB " + str(len(tiles)) + "\n")

    #     f.write("end asm\n")
           
    #     f.write("\n")

def getTilesBas(inFile, outFolder, extra=False):
    with open(inFile, 'r') as f:
        lines = f.readlines()

    lines = lines[2:]

    # Separar las líneas de bits y las líneas de colores
    total_lines = 48
    if extra:
        bit_lines = lines[:56]
        total_lines = 56
    else:
        bit_lines = lines[:48]

    tiles = []
    # convertir el array de bits en tiles de 8x8 de spectrum
    for i in range(0, total_lines, 8):
        for j in range(0, 256, 8):
            tile = []
            for k in range(8):
                tile.append(int(bit_lines[i + k][j:j + 8], 2))
            tiles.append(tile)
    
    #setear el primer tile a 0s
    tiles[0] = [0] * 8

    # Guardar tiles en fichero bin para cargarlo desde basic
    with open(str(Path(outFolder + "/tiles.bin")), "wb+") as f:
        for tile in tiles:
            f.write(bytearray(tile))

    attrs = []
    
    # guardar en color_lineas de la linea 52 a la 57
    color_lines = lines[49:56]
    if total_lines == 56:
        color_lines = lines[57:65]
    
    # convertir cada valor de cada una de esas lineas que estan separados por un espacio de hexadecimal a decimal y guardarlo todo en el array attrs
    for line in color_lines:
        for color in line.strip().split(" "):
            if color:
                attrs.append(int(color, 16))
            
    # Guardar array de enteros de una dimension attrs en fichero binario para cargarlo desde basic
    attrs = [int(attr) for attr in attrs]

    with open(str(Path(outFolder + "/attrs.bin")), "wb+") as f:
        for attr in attrs:
            f.write(attr.to_bytes(1, byteorder='big'))