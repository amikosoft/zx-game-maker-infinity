@echo off
:: Cambiar al directorio del script
cd /d "%~dp0\src"

pip install Pillow

:: Ejecutar el script de Python
py launcher.py