@echo off
setlocal

:: Cambiar al directorio donde está este script
cd /d "%~dp0"

echo Verificando Python...
python --version >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo Error: Python no esta instalado o no esta en PATH.
    pause
    exit /b 1
)

echo Verificando pip...
python -m pip --version >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo Error: pip no esta disponible en esta instalacion de Python.
    pause
    exit /b 1
)

IF NOT EXIST src\requirements.txt (
    echo Error: No se encuentra src\requirements.txt
    pause
    exit /b 1
)

echo.
echo ================================
echo  Creando entorno virtual (venv)
echo ================================

IF NOT EXIST src\venv (
    python -m venv src\venv
    IF %ERRORLEVEL% NEQ 0 (
        echo Error al crear el entorno virtual.
        pause
        exit /b 1
    )
    echo Entorno virtual creado.
) ELSE (
    echo El entorno virtual ya existe.
)

echo.
echo ================================
echo  Activando entorno virtual
echo ================================

call src\venv\Scripts\activate.bat
IF %ERRORLEVEL% NEQ 0 (
    echo Error: No se pudo activar el entorno virtual.
    pause
    exit /b 1
)

echo Entorno virtual activado.

echo.
echo ================================
echo  Instalando dependencias
echo ================================

python -m pip install --upgrade pip
python -m pip install -r src\requirements.txt

echo.
echo Instalacion completada dentro del entorno virtual.
echo.

