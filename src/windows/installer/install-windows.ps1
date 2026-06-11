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

# --- PRE-LIMPIEZA: eliminar instalaciones previas ---
Write-Header "Limpieza de Instalaciones Anteriores"

$ModuleName = "whisper-transcriptor"
$removedCount = 0

# Escanear todas las rutas en PSModulePath + rutas conocidas
$searchPaths = ($env:PSModulePath -split ';') + @(
    "$env:USERPROFILE\Documents\PowerShell\Modules",
    "$env:USERPROFILE\Documents\WindowsPowerShell\Modules",
    "C:\Program Files\PowerShell\Modules",
    "$env:ProgramFiles\PowerShell\Modules",
    "$env:ProgramFiles\WindowsPowerShell\Modules",
    "$env:ALLUSERSPROFILE\PowerShell\Modules",
    "$env:ALLUSERSPROFILE\WindowsPowerShell\Modules"
) | Select-Object -Unique

$oldPaths = @()
foreach ($base in $searchPaths) {
    $dir = Join-Path $base $ModuleName
    if (Test-Path $dir) { $oldPaths += $dir }
}
# También buscar WhisperTranslator (nombre antiguo)
foreach ($base in $searchPaths) {
    $dir = Join-Path $base "WhisperTranslator"
    if (Test-Path $dir) { $oldPaths += $dir }
}

# Remover de la sesión actual
Get-Module $ModuleName, WhisperTranslator -ErrorAction SilentlyContinue | Remove-Module -Force

# Eliminar directorios
foreach ($path in $oldPaths) {
    Write-Info "Eliminando instalación anterior: $path"
    try {
        Remove-Item -Path $path -Recurse -Force -ErrorAction Stop
        Write-Success "Eliminado"
        $removedCount++
    } catch {
        Write-Warning "No se pudo eliminar $path : $_"
    }
}

# Limpiar caché de análisis de módulos
$cache = "$env:LOCALAPPDATA\Microsoft\Windows\PowerShell\ModuleAnalysisCache"
if (Test-Path $cache) { try { Remove-Item $cache -Force } catch {} }
try { [System.Management.Automation.ModuleIntrinsics]::GetModuleCache().Clear() } catch {}

if ($removedCount -gt 0) {
    Write-Success "Se eliminaron $removedCount instalaciones anteriores"
} else {
    Write-Info "No se encontraron instalaciones previas"
}

# --- INSTALACIÓN DEL MÓDULO ---
Write-Header "Instalación del Módulo whisper-transcriptor"

# Definir rutas
$ScriptPath = $PSScriptRoot
# El script está en src/windows/installer, subir un nivel para llegar a src/windows
$WindowsPath = Split-Path -Path $ScriptPath -Parent
$ModuleSourcePath = Join-Path -Path $WindowsPath -ChildPath "module"

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

# Instalar a TODAS las rutas de módulos de usuario para compatibilidad PS5 y PS7
$ModulePaths = @(
    "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\$ModuleName"
    "$env:USERPROFILE\Documents\PowerShell\Modules\$ModuleName"
) | Select-Object -Unique

$installedAt = @()
foreach ($DestinationModulePath in $ModulePaths) {
    # Crear directorio de destino
    Write-Info "Instalando en: $DestinationModulePath"
    New-Item -Path $DestinationModulePath -ItemType Directory -Force | Out-Null
    
    # Copiar archivos
    try {
        Copy-Item -Path "$ModuleSourcePath\*" -Destination $DestinationModulePath -Recurse -Force
        $installedAt += $DestinationModulePath
        Write-Success "Instalado"
    } catch {
        Write-Warning "No se pudo instalar en $DestinationModulePath : $_"
    }
}

# Actualizar GUID en TODAS las copias
$NewGuid = [guid]::NewGuid().Guid
foreach ($path in $installedAt) {
    $manifestFile = Join-Path -Path $path -ChildPath "whisper-transcriptor.psd1"
    if (Test-Path $manifestFile) {
        $content = Get-Content -Path $manifestFile -Raw
        $content = $content -replace "GUID\s*=\s*['`"]([^'`"]+)['`"]", "GUID = '$NewGuid'"
        Set-Content -Path $manifestFile -Value $content -Force
    }
}
Write-Success "GUID unificado: $NewGuid"

# --- VERIFICACIÓN DE LA INSTALACIÓN ---
Write-Header "Verificación de la Instalación"

Write-Info "Importando el módulo para verificar..."
$imported = $false
foreach ($path in $installedAt) {
    try {
        Import-Module -Name $path -Force -ErrorAction Stop
        Write-Success "Módulo importado desde: $path"
        $imported = $true
        break
    } catch {
        Write-Warning "No se pudo importar desde $path"
    }
}

if ($imported) {
    $command = Get-Command Invoke-whisper-transcriptor -ErrorAction SilentlyContinue
    if ($command) {
        Write-Success "Comando 'Invoke-whisper-transcriptor' disponible"
    }
} else {
    Write-Error "Error al importar el módulo desde cualquier ubicación"
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

📁 Ubicaciones del módulo:
      $($installedAt -join "`n      ")
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
   Extensiones soportadas: mp4, mkv, webm, avi, mov, m4a

   Alias: wtranscriptor

"@ -ForegroundColor $ColorInfo

Write-Host "Para más información, visita: https://github.com/amillanaol/WhisperTraductor" -ForegroundColor $ColorSuccess
Write-Host ""
