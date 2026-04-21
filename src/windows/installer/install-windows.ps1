<#
.SYNOPSIS
    Script de instalación completo para whisper-transcriptor en Windows
.DESCRIPTION
    Este script instala y configura automáticamente el módulo whisper-transcriptor,
    verificando dependencias y configurando el entorno correctamente.
.NOTES
    Versión: 1.0.0
    Autor: amillanaol
    Requiere: PowerShell 5.1 o superior
#>

[CmdletBinding()]
param(
    [switch]$SkipPythonCheck,
    [switch]$SkipWhisperCheck,
    [switch]$Force
)

# --- CONFIGURACIÓN DE COLORES ---
$ColorHeader = 'Cyan'
$ColorSuccess = 'Green'
$ColorWarning = 'Yellow'
$ColorError = 'Red'
$ColorInfo = 'White'

# --- FUNCIONES AUXILIARES ---
function Write-Header {
    param([string]$Message)
    Write-Host "`n╔════════════════════════════════════════════════════════════════╗" -ForegroundColor $ColorHeader
    Write-Host "║  $Message" -ForegroundColor $ColorHeader -NoNewline
    Write-Host "$(' ' * (62 - $Message.Length))║" -ForegroundColor $ColorHeader
    Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor $ColorHeader
    Write-Host ""
}

function Write-Success {
    param([string]$Message)
    Write-Host "✓ $Message" -ForegroundColor $ColorSuccess
}

function Write-Warning {
    param([string]$Message)
    Write-Host "⚠ $Message" -ForegroundColor $ColorWarning
}

function Write-Error {
    param([string]$Message)
    Write-Host "✗ $Message" -ForegroundColor $ColorError
}

function Write-Info {
    param([string]$Message)
    Write-Host "ℹ $Message" -ForegroundColor $ColorInfo
}

function Test-CommandExists {
    param([string]$Command)
    $null = Get-Command $Command -ErrorAction SilentlyContinue
    return $?
}

# --- VERIFICACIÓN INICIAL ---
Write-Header "whisper-transcriptor - Instalador para Windows"

# Verificar versión de PowerShell
Write-Info "Verificando versión de PowerShell..."
if ($PSVersionTable.PSVersion.Major -lt 5 -or ($PSVersionTable.PSVersion.Major -eq 5 -and $PSVersionTable.PSVersion.Minor -lt 1)) {
    Write-Error "Se requiere PowerShell 5.1 o superior. Versión actual: $($PSVersionTable.PSVersion)"
    Write-Info "Descarga PowerShell 7 desde: https://github.com/PowerShell/PowerShell/releases"
    exit 1
}
Write-Success "PowerShell $($PSVersionTable.PSVersion) - Compatible"

# --- VERIFICACIÓN DE DEPENDENCIAS ---
Write-Header "Verificación de Dependencias"

# 1. Verificar Python
if (-not $SkipPythonCheck) {
    Write-Info "Verificando instalación de Python..."
    if (Test-CommandExists "python") {
        $pythonVersion = python --version 2>&1
        Write-Success "Python encontrado: $pythonVersion"
    } elseif (Test-CommandExists "python3") {
        $pythonVersion = python3 --version 2>&1
        Write-Success "Python3 encontrado: $pythonVersion"
    } else {
        Write-Error "Python no está instalado o no está en el PATH"
        Write-Info "Por favor, instala Python desde: https://www.python.org/downloads/"
        Write-Info "Asegúrate de marcar 'Add Python to PATH' durante la instalación"
        
        $continue = Read-Host "¿Deseas continuar de todas formas? (S/N)"
        if ($continue -ne 'S' -and $continue -ne 's') {
            exit 1
        }
    }
} else {
    Write-Warning "Verificación de Python omitida (--SkipPythonCheck)"
}

# 2. Verificar Whisper
if (-not $SkipWhisperCheck) {
    Write-Info "Verificando instalación de Whisper..."
    if (Test-CommandExists "whisper") {
        Write-Success "Whisper CLI encontrado en el PATH"
    } else {
        Write-Warning "Whisper CLI no está instalado o no está en el PATH"
        Write-Info "Para instalar Whisper, ejecuta: pip install openai-whisper"
        Write-Info "O visita: https://github.com/openai/whisper#setup"
        
        $installWhisper = Read-Host "¿Deseas intentar instalar Whisper automáticamente? (S/N)"
        if ($installWhisper -eq 'S' -or $installWhisper -eq 's') {
            Write-Info "Instalando Whisper..."
            try {
                python -m pip install openai-whisper
                if (Test-CommandExists "whisper") {
                    Write-Success "Whisper instalado correctamente"
                } else {
                    Write-Warning "Whisper se instaló pero no está en el PATH. Reinicia PowerShell e intenta de nuevo."
                }
            } catch {
                Write-Error "Error al instalar Whisper: $_"
            }
        }
    }
} else {
    Write-Warning "Verificación de Whisper omitida (--SkipWhisperCheck)"
}

# 3. Verificar FFmpeg
Write-Info "Verificando instalación de FFmpeg..."
if (Test-CommandExists "ffmpeg") {
    $ffmpegVersion = ffmpeg -version 2>&1 | Select-Object -First 1
    Write-Success "FFmpeg encontrado: $ffmpegVersion"
} else {
    Write-Warning "FFmpeg no está instalado o no está en el PATH"
    Write-Info "FFmpeg es necesario para procesar archivos de audio/video"
    Write-Info "Descarga FFmpeg desde: https://ffmpeg.org/download.html#build-windows"
    Write-Info "O usa winget: winget install Gyan.FFmpeg"
}

# --- INSTALACIÓN DEL MÓDULO ---
Write-Header "Instalación del Módulo whisper-transcriptor"

# Definir rutas
$ScriptPath = $PSScriptRoot
# El script está en src/windows/installer, subir un nivel para llegar a src/windows
$WindowsPath = Split-Path -Path $ScriptPath -Parent
$ModuleSourcePath = Join-Path -Path $WindowsPath -ChildPath "module"
$ModuleName = "whisper-transcriptor"

# Verificar que existen los archivos del módulo
if (-not (Test-Path -Path $ModuleSourcePath)) {
    Write-Error "No se encontró el directorio del módulo en: $ModuleSourcePath"
    Write-Info "Asegúrate de ejecutar este script desde el directorio raíz del repositorio"
    exit 1
}

$ManifestFile = Join-Path -Path $ModuleSourcePath -ChildPath "whisper-transcriptor.psd1"
if (-not (Test-Path -Path $ManifestFile)) {
    Write-Error "No se encontró el archivo de manifiesto: $ManifestFile"
    exit 1
}

Write-Success "Archivos del módulo encontrados"

# Determinar ruta de destino según versión de PowerShell
if ($PSVersionTable.PSVersion.Major -ge 6) {
    $UserModulesPath = Join-Path -Path $env:USERPROFILE -ChildPath "Documents\PowerShell\Modules"
} else {
    $UserModulesPath = Join-Path -Path $env:USERPROFILE -ChildPath "Documents\WindowsPowerShell\Modules"
}
$DestinationModulePath = Join-Path -Path $UserModulesPath -ChildPath $ModuleName

# Verificar si ya existe una instalación previa
if (Test-Path -Path $DestinationModulePath) {
    if (-not $Force) {
        Write-Warning "El módulo ya está instalado en: $DestinationModulePath"
        $overwrite = Read-Host "¿Deseas sobrescribir la instalación existente? (S/N)"
        if ($overwrite -ne 'S' -and $overwrite -ne 's') {
            Write-Info "Instalación cancelada por el usuario"
            exit 0
        }
    }
    Write-Info "Eliminando instalación anterior..."
    Remove-Item -Path $DestinationModulePath -Recurse -Force
}

# Crear directorio de destino
Write-Info "Creando directorio de destino..."
New-Item -Path $DestinationModulePath -ItemType Directory -Force | Out-Null
Write-Success "Directorio creado: $DestinationModulePath"

# Copiar archivos
Write-Info "Copiando archivos del módulo..."
try {
    Copy-Item -Path "$ModuleSourcePath\*" -Destination $DestinationModulePath -Recurse -Force
    Write-Success "Archivos copiados correctamente"
} catch {
    Write-Error "Error al copiar archivos: $_"
    exit 1
}

# Actualizar GUID si es necesario
$DestinationManifestFile = Join-Path -Path $DestinationModulePath -ChildPath "whisper-transcriptor.psd1"
$ManifestContent = Get-Content -Path $DestinationManifestFile -Raw

if ($ManifestContent -match "GUID\s*=\s*['`"]a1b2c3d4-e5f6-47a8-b9c0-d1e2f3a4b5c6['`"]") {
    Write-Info "Generando nuevo GUID para el módulo..."
    $NewGuid = [guid]::NewGuid().Guid
    $NewManifestContent = $ManifestContent -replace "GUID\s*=\s*['`"]([^'`"]+)['`"]", "GUID = '$NewGuid'"
    Set-Content -Path $DestinationManifestFile -Value $NewManifestContent -Force
    Write-Success "GUID actualizado: $NewGuid"
}

# --- VERIFICACIÓN DE LA INSTALACIÓN ---
Write-Header "Verificación de la Instalación"

Write-Info "Importando el módulo para verificar..."
try {
    Import-Module -Name $DestinationModulePath -Force -ErrorAction Stop
    Write-Success "Módulo importado correctamente"
    
    # Verificar función exportada
    $command = Get-Command Invoke-whisper-transcriptor -ErrorAction SilentlyContinue
    if ($command) {
        Write-Success "Comando 'Invoke-whisper-transcriptor' disponible"
    }
} catch {
    Write-Error "Error al importar el módulo: $_"
    exit 1
}

# --- CREACIÓN DE DIRECTORIO DE TRABAJO ---
Write-Header "Configuración del Entorno"

$WorkingDirectory = Join-Path -Path $env:USERPROFILE -ChildPath "whisper-transcriptor"
if (-not (Test-Path -Path $WorkingDirectory)) {
    Write-Info "Creando directorio de trabajo..."
    New-Item -Path $WorkingDirectory -ItemType Directory -Force | Out-Null
    Write-Success "Directorio creado: $WorkingDirectory"
} else {
    Write-Info "Directorio de trabajo ya existe: $WorkingDirectory"
}

# Crear subdirectorio de inputs
$InputsDirectory = Join-Path -Path $WorkingDirectory -ChildPath "inputs"
if (-not (Test-Path -Path $InputsDirectory)) {
    New-Item -Path $InputsDirectory -ItemType Directory -Force | Out-Null
    Write-Success "Directorio de inputs creado: $InputsDirectory"
}

# --- RESUMEN FINAL ---
Write-Header "¡Instalación Completada!"

Write-Host @"

El módulo whisper-transcriptor ha sido instalado exitosamente.

📁 Ubicación del módulo: $DestinationModulePath
📂 Directorio de trabajo: $WorkingDirectory
📥 Directorio de inputs: $InputsDirectory

🚀 PRÓXIMOS PASOS:

1. Cierra esta ventana de PowerShell
2. Abre una NUEVA ventana de PowerShell
3. Verifica la instalación:
      Get-Module -ListAvailable whisper-transcriptor

4. Consulta la ayuda del módulo:
      Invoke-whisper-transcriptor -Help

5. Procesa tus primeros videos:
      Coloca archivos .mp4 en: $InputsDirectory
      Ejecuta: Invoke-whisper-transcriptor -Directory "$InputsDirectory"

📚 COMANDOS DISPONIBLES:

   Invoke-whisper-transcriptor [-Directory <path>] [-Model <modelo>] [-Extension <ext>]
   
   Modelos disponibles: tiny, base, small, medium, turbo
   Extensiones soportadas: mp4, mkv, webm, avi, mov

   Alias: wtranscriptor

"@ -ForegroundColor $ColorInfo

Write-Host "Para más información, visita: https://github.com/amillanaol/WhisperTraductor" -ForegroundColor $ColorSuccess
Write-Host ""
