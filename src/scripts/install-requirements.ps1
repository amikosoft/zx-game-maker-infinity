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
$srcDir = Split-Path $scriptRoot -Parent
$venvPath = Join-Path $srcDir "venv"
$requirementsFile = Join-Path $srcDir "requirements.txt"

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
        # Try to dot-source. If it fails due to execution policy, warn the user.
        try {
            . $activateScript
        } catch {
            Write-Warning "No se pudo activar el entorno virtual automáticamente. Es posible que necesites ejecutar: Set-ExecutionPolicy RemoteSigned -Scope CurrentUser"
        }
    }
}

# Check requirements
if (-not (Test-Path $requirementsFile)) {
    Write-Host "No se encontró el archivo requirements.txt en $requirementsFile" -ForegroundColor Red
    Read-Host "Pulse una tecla para cerrar..."
    exit 1
}

Write-Host "Comprobando dependencias..." -ForegroundColor Cyan
$requirements = Get-Content $requirementsFile | Where-Object { $_ -match '\S' -and $_ -notmatch '^#' }
$installed_packages = & pip freeze
$installed_package_names = $installed_packages -replace '[=<>!].*', ''

$all_installed = $true
foreach ($requirement in $requirements) {
    $reqName = ($requirement -replace '[=<>!].*', '').Trim()
    if ($null -ne $reqName -and $reqName -ne "" -and -not ($installed_package_names -contains $reqName)) {
        Write-Host "Falta: $reqName" -ForegroundColor Yellow
        $all_installed = $false
    }
}

if (-not $all_installed) {
    Write-Host "Instalando requerimientos..." -ForegroundColor Yellow
    & pip install -r $requirementsFile
} else {
    Write-Host "Todos los requerimientos ya están instalados." -ForegroundColor Green
}