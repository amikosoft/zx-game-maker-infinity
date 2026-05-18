#!/bin/bash

# Verificar que el entorno virtual existe
if [ ! -d "./src/venv" ]; then
    echo "Error: El entorno virtual no existe en ./src/venv"
    echo "Por favor, ejecuta ./install.sh primero para configurar el entorno."
    exit 1
fi

if [ ! -f "./src/venv/bin/python3" ]; then
    echo "Error: Python no encontrado en el entorno virtual."
    echo "Por favor, ejecuta ./install.sh para reinstalar el entorno."
    exit 1
fi

./src/venv/bin/python3 zxsgm-infinity.py