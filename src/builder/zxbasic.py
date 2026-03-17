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
        bit_lines = lines[:64]
        total_lines = 64
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
    with open(str(Path(outFolder + ".bin")), "wb+") as f:
        for tile in tiles:
            f.write(bytearray(tile))

    attrs = []
    
    # guardar en color_lineas de la linea 52 a la 57
    color_lines = lines[49:56]
    ula_line = None

    if total_lines == 64:
        color_lines = lines[65:73]

        if len(lines) > 73:
            ula_line = lines[73]
    else:
        if len(lines) > 56:
            ula_line = lines[56]
    
    if ula_line != None:
        # print(ula_line)
        ula_colors = []

        for ulacolor in ula_line.strip().split(" "):
            ula_colors.append(int(ulacolor, 16))

        # print(ula_colors)
        with open(str(Path(outFolder + "_ulacolors.bas")), "w") as f:
            f.write("OUT 48955,64: OUT 65339,0\n")
            f.write("PAUSE 1\n")
            f.write("if IN 65339 = 0 then\n")
            f.write("FOR F=0 TO 63: READ A: OUT 48955, F: OUT 65339, A: NEXT F: DATA " + ",".join([str(ula_colors) for ula_colors in ula_colors]))
            f.write("\nend if")
    else:
        with open(str(Path(outFolder + "_ulacolors.bas")), "w") as f:
            f.write("'ULA NOT CONFIGURED'\n")

    # convertir cada valor de cada una de esas lineas que estan separados por un espacio de hexadecimal a decimal y guardarlo todo en el array attrs
    for line in color_lines:
        for color in line.strip().split(" "):
            if color:
                attrs.append(int(color, 16))

    # Guardar array de enteros de una dimension attrs en fichero binario para cargarlo desde basic
    attrs = [int(attr) for attr in attrs]

    with open(str(Path(outFolder + "_attrs.bin")), "wb+") as f:
        for attr in attrs:
            f.write(attr.to_bytes(1, byteorder='big'))