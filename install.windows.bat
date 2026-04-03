@echo off

:: Verify Python installation
python --version >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo Error: Python is not installed or not added to PATH.
    echo Please install Python and try again.
    pause
    exit /b 1
)

:: Verify pip installation
pip --version >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo Error: pip is not installed or not added to PATH.
    echo Please install pip and try again.
    pause
    exit /b 1
)

echo Python and pip found. Installing dependencies...

pip install Pillow
pip install watchdog
pip install zxp2gus

echo Done!
pause