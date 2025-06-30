import sys

with open("output/map.txt", "r") as file:
    lines = file.readlines()
    last_line = lines[-1]

memoryAddress = last_line.split(":")[0]

print("")
if int(memoryAddress, 16) > 0xC000:
    print("========================================================")
    print("ERROR: Memory address " + memoryAddress + " is greater than $C000")
    print("Try to disable some features in the map configuration")
    print("========================================================")
    print("")
    sys.exit(1)
else:
    print("MEMORY PRINT: " + memoryAddress)