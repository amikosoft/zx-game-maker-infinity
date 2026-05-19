@echo off

:: Cambiar al directorio donde está este script
cd /d "%~dp0"

:: Verificar que el entorno virtual existe
if not exist "src\venv" (
    echo Error: El entorno virtual no existe en src\venv
    echo Por favor, ejecuta install.windows.bat primero para configurar el entorno.
    pause
    exit /b 1
)

if not exist "src\venv\Scripts\python.exe" (
    echo Error: Python no encontrado en el entorno virtual.
    echo Por favor, ejecuta install.windows.bat para reinstalar el entorno.
    pause
    exit /b 1
)

:: Ejecutar el script de Python
src\venv\Scripts\python.exe zxsgm-infinity.py