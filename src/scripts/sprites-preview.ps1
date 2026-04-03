$pythonCommands = @("py", "python", "python3")
$pythonExe = $null

foreach ($cmd in $pythonCommands) {
    if (Get-Command $cmd -ErrorAction SilentlyContinue) {
        $pythonExe = $cmd
        break
    }
}

if ($null -eq $pythonExe) {
    Write-Host "Python no está instalado. Por favor, instala Python antes de continuar (se recomienda el Launcher de Python 'py')." -ForegroundColor Red
    Read-Host "Pulse una tecla para cerrar..."
    exit 1
}

# Accurate Version Check
try {
    $vStr = & $pythonExe -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')"
    $pythonVersion = [double]$vStr
} catch {
    Write-Host "Error al detectar la versión de Python." -ForegroundColor Red
    Read-Host "Pulse una tecla para cerrar..."
    exit 1
}

if ($pythonVersion -lt 3.12) {
    Write-Host "La versión de Python encontrada ($vStr) es menor que 3.12. Por favor, instala Python 3.12 o superior." -ForegroundColor Red
    Read-Host "Pulse una tecla para cerrar..."
    exit 1
}

# Resolve Paths Relative to Script
$scriptRoot = $PSScriptRoot
if ([string]::IsNullOrEmpty($scriptRoot)) { $scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition }
$parentDir = Split-Path $scriptRoot -Parent
$venvPath = Join-Path $parentDir "venv"
$spritesBuildFile = Join-Path $parentDir "sprites-preview.py"

# Venv Management
if (-not (Test-Path $venvPath)) {
    Write-Host "Creando entorno virtual venv..." -ForegroundColor Yellow
    & $pythonExe -m venv $venvPath
}

# Venv Activation (Must dot-source to affect current session)
if (-not $env:VIRTUAL_ENV) {
    $activateScript = Join-Path $venvPath "Scripts\Activate.ps1"
    if (Test-Path $activateScript) {
        Write-Host "Activando entorno virtual venv..." -ForegroundColor Yellow
        try {
            . $activateScript
        } catch {
            Write-Warning "No se pudo activar el entorno virtual automáticamente. Es posible que necesites ejecutar: Set-ExecutionPolicy RemoteSigned -Scope CurrentUser"
        }
    }
}

# Check sprites-preview.py
if (-not (Test-Path $spritesBuildFile)) {
    Write-Host "No se encontró el archivo lib sprites-preview.py en $spritesBuildFile" -ForegroundColor Red
    Read-Host "Pulse una tecla para cerrar..."
    exit 1
}

# Ensure execution directory is the src/ root to handle relative python imports correctly
Set-Location -Path $parentDir

Write-Host "Ejecutando vista previa de sprites..." -ForegroundColor Cyan
& python $spritesBuildFile $args

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error durante la ejecución del script." -ForegroundColor Red
} else {
    Write-Host "Ejecución finalizada con éxito." -ForegroundColor Green
}

Read-Host "Pulse una tecla para cerrar..."