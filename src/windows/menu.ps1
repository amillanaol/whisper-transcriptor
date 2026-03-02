#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Menú interactivo de instalación de whisper-transcriptor
.DESCRIPTION
    Script principal que presenta un menú interactivo para instalar,
    configurar y gestionar el módulo whisper-transcriptor en Windows.
.NOTES
    Versión: 1.0.0
    Autor: amillanaol
#>

[CmdletBinding()]
param()

# --- CONFIGURACIÓN ---
$ScriptVersion = "1.0.0"
# Obtener raíz del proyecto (2 niveles arriba desde src\windows)
$ProjectRoot = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
$InstallerPath = Join-Path -Path $ProjectRoot -ChildPath "src\windows\installer"
$ModulePath = Join-Path -Path $ProjectRoot -ChildPath "src\windows\module"

# --- COLORES ---
$ColorHeader = 'Cyan'
$ColorMenu = 'Yellow'
$ColorSuccess = 'Green'
$ColorWarning = 'Yellow'
$ColorError = 'Red'
$ColorInfo = 'White'

# --- FUNCIONES ---
function Show-Header {
    Clear-Host
    Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor $ColorHeader
    Write-Host "║                                                                ║" -ForegroundColor $ColorHeader
    Write-Host "║           🎬 WHISPER TRASCRIPTOR - MENÚ PRINCIPAL               ║" -ForegroundColor $ColorHeader
    Write-Host "║                                                                ║" -ForegroundColor $ColorHeader
    Write-Host "║         Generador de Subtítulos SRT con Whisper AI             ║" -ForegroundColor $ColorHeader
    Write-Host "║                                                                ║" -ForegroundColor $ColorHeader
    Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor $ColorHeader
    Write-Host ""
}

function Show-Menu {
    Write-Host "  MENÚ DE OPCIONES:" -ForegroundColor $ColorMenu
    Write-Host "  ─────────────────────────────────────────────────────────────" -ForegroundColor $ColorMenu
    Write-Host ""
    Write-Host "  [1] 📦 Instalar whisper-transcriptor" -ForegroundColor $ColorInfo
    Write-Host "  [2] 🔧 Instalar (modo avanzado - opciones personalizadas)" -ForegroundColor $ColorInfo
    Write-Host "  [3] ✅ Verificar instalación actual" -ForegroundColor $ColorInfo
    Write-Host "  [4] ▶️  Usar whisper-transcriptor (ejecutar módulo)" -ForegroundColor $ColorInfo
    Write-Host "  [5] 📖 Ver documentación" -ForegroundColor $ColorInfo
    Write-Host "  [6] 🗑️  Desinstalar whisper-transcriptor" -ForegroundColor $ColorInfo
    Write-Host ""
    Write-Host "  [0] 🚪 Salir" -ForegroundColor $ColorWarning
    Write-Host ""
    Write-Host "  ─────────────────────────────────────────────────────────────" -ForegroundColor $ColorMenu
}

function Read-Option {
    param([string]$Prompt = "Selecciona una opción")
    Write-Host ""
    $selection = Read-Host "  $Prompt (0-6)"
    return $selection
}

function Show-Progress {
    param([string]$Message)
    Write-Host ""
    Write-Host "  ⏳ $Message..." -ForegroundColor $ColorInfo
    Write-Host ""
}

function Pause-Screen {
    Write-Host ""
    Read-Host "  Presiona ENTER para continuar"
}

function Test-IsAdmin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Request-Admin {
    if (-not (Test-IsAdmin)) {
        Write-Warning "⚠️  Este script necesita ejecutarse como Administrador"
        Write-Host ""
        $elevate = Read-Host "  ¿Deseas reiniciar como Administrador? (S/N)"
        if ($elevate -eq 'S' -or $elevate -eq 's') {
            Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
            exit
        } else {
            return $false
        }
    }
    return $true
}

function Write-Success {
    param([string]$Message)
    Write-Host "  $Message" -ForegroundColor $ColorSuccess
}

function Write-Info {
    param([string]$Message)
    Write-Host "  $Message" -ForegroundColor $ColorInfo
}

# --- ACCIONES DEL MENÚ ---
function Invoke-Install {
    Show-Header
    Write-Host "  📦 INSTALACIÓN DE WHISPER TRASCRIPTOR" -ForegroundColor $ColorHeader
    Write-Host ""

    $installScript = Join-Path -Path $InstallerPath -ChildPath "install-windows.ps1"

    if (Test-Path $installScript) {
        Show-Progress "Iniciando instalación"
        & $installScript
        Pause-Screen
    } else {
        Write-Error "No se encontró el script de instalación en: $installScript"
        Pause-Screen
    }
}

function Invoke-InstallAdvanced {
    Show-Header
    Write-Host "  🔧 INSTALACIÓN AVANZADA" -ForegroundColor $ColorHeader
    Write-Host ""

    Write-Host "  Opciones disponibles:" -ForegroundColor $ColorInfo
    Write-Host ""
    Write-Host "  [1] Omitir verificación de Python" -ForegroundColor $ColorInfo
    Write-Host "  [2] Omitir verificación de Whisper" -ForegroundColor $ColorInfo
    Write-Host "  [3] Forzar sobrescritura (si existe instalación previa)" -ForegroundColor $ColorInfo
    Write-Host "  [4] Combinar opciones 1 y 2" -ForegroundColor $ColorInfo
    Write-Host "  [5] Todas las opciones (modo forzado)" -ForegroundColor $ColorInfo
    Write-Host "  [6] Instalación estándar (sin opciones)" -ForegroundColor $ColorInfo
    Write-Host ""
    
    $opt = Read-Host "  Selecciona una opción (1-6)"
    
    $args = @()
    switch ($opt) {
        '1' { $args += "-SkipPythonCheck" }
        '2' { $args += "-SkipWhisperCheck" }
        '3' { $args += "-Force" }
        '4' { $args += @("-SkipPythonCheck", "-SkipWhisperCheck") }
        '5' { $args += @("-SkipPythonCheck", "-SkipWhisperCheck", "-Force") }
        '6' { $args = @() }
        default { 
            Write-Warning "Opción no válida, usando instalación estándar"
            $args = @()
        }
    }
    
    $installScript = Join-Path -Path $InstallerPath -ChildPath "install-windows.ps1"

    if (Test-Path $installScript) {
        Show-Progress "Iniciando instalación avanzada"
        & $installScript @args
        Pause-Screen
    } else {
        Write-Error "No se encontró el script de instalación"
        Pause-Screen
    }
}

function Invoke-Verify {
    Show-Header
    Write-Host "  ✅ VERIFICACIÓN DE LA INSTALACIÓN" -ForegroundColor $ColorHeader
    Write-Host ""
    
    Write-Host "  Verificando módulo instalado..." -ForegroundColor $ColorInfo
    Write-Host ""
    
    $module = Get-Module -ListAvailable -Name "whisper-transcriptor"
    
    if ($module) {
        Write-Success "✓ Módulo encontrado"
        Write-Host ""
        Write-Host "  Información del módulo:" -ForegroundColor $ColorInfo
        Write-Host "    • Nombre: $($module.Name)" -ForegroundColor $ColorInfo
        Write-Host "    • Versión: $($module.Version)" -ForegroundColor $ColorInfo
        Write-Host "    • Ubicación: $($module.ModuleBase)" -ForegroundColor $ColorInfo
        Write-Host "    • Autor: $($module.Author)" -ForegroundColor $ColorInfo
        Write-Host ""
        
        # Verificar comando
        $command = Get-Command Invoke-whisper-transcriptor -ErrorAction SilentlyContinue
        if ($command) {
            Write-Success "✓ Comando 'Invoke-whisper-transcriptor' disponible"
        } else {
            Write-Warning "⚠ Comando no encontrado. Reinicia PowerShell."
        }
        
        Write-Host ""
        Write-Host "  Dependencias:" -ForegroundColor $ColorInfo
        
        # Python
        if (Get-Command python -ErrorAction SilentlyContinue) {
            $pyVersion = python --version 2>&1
            Write-Success "✓ Python: $pyVersion"
        } else {
            Write-Error "✗ Python no encontrado"
        }
        
        # Whisper
        if (Get-Command whisper -ErrorAction SilentlyContinue) {
            Write-Success "✓ Whisper CLI: Disponible"
        } else {
            Write-Error "✗ Whisper CLI no encontrado"
        }
        
        # FFmpeg
        if (Get-Command ffmpeg -ErrorAction SilentlyContinue) {
            Write-Success "✓ FFmpeg: Disponible"
        } else {
            Write-Error "✗ FFmpeg no encontrado"
        }
        
    } else {
        Write-Error "✗ El módulo whisper-transcriptor no está instalado"
        Write-Host ""
        Write-Host "  Para instalarlo, selecciona la opción [1] del menú principal." -ForegroundColor $ColorInfo
    }
    
    Pause-Screen
}

function Invoke-RunModule {
    Show-Header
    Write-Host "  ▶️  USAR WHISPER TRASCRIPTOR" -ForegroundColor $ColorHeader
    Write-Host ""
    
    # Verificar si el módulo está disponible
    $module = Get-Module -ListAvailable -Name "whisper-transcriptor"
    
    if (-not $module) {
        Write-Error "El módulo no está instalado. Instálalo primero (opción [1])."
        Pause-Screen
        return
    }
    
    # Importar módulo
    Import-Module whisper-transcriptor -Force
    
    Write-Host "  Opciones de ejecución:" -ForegroundColor $ColorInfo
    Write-Host ""
    Write-Host "  [1] Ejecutar con configuración por defecto" -ForegroundColor $ColorInfo
    Write-Host "  [2] Especificar directorio de videos" -ForegroundColor $ColorInfo
    Write-Host "  [3] Seleccionar modelo de Whisper" -ForegroundColor $ColorInfo
    Write-Host "  [4] Opciones avanzadas (personalizar todo)" -ForegroundColor $ColorInfo
    Write-Host "  [5] Ver ayuda del módulo" -ForegroundColor $ColorInfo
    Write-Host "  [6] ⚡ Ejecutar con CUDA (GPU acelerado)" -ForegroundColor $ColorInfo
    Write-Host ""

    $runOpt = Read-Host "  Selecciona una opción (1-6)"
    
    switch ($runOpt) {
        '1' {
            Invoke-whisper-transcriptor
        }
        '2' {
            $dir = Read-Host "  Ingresa la ruta del directorio de videos"
            if (Test-Path $dir) {
                Invoke-whisper-transcriptor -Directory $dir
            } else {
                Write-Error "El directorio no existe: $dir"
            }
        }
        '3' {
            Write-Host ""
            Write-Host "  Modelos disponibles:" -ForegroundColor $ColorInfo
            Write-Host "    [1] tiny  - Muy rápido, menor precisión" -ForegroundColor $ColorInfo
            Write-Host "    [2] base  - Rápido, precisión media" -ForegroundColor $ColorInfo
            Write-Host "    [3] small - Balance velocidad/precisión" -ForegroundColor $ColorInfo
            Write-Host "    [4] medium - Lento, alta precisión" -ForegroundColor $ColorInfo
            Write-Host "    [5] turbo - Optimizado para velocidad" -ForegroundColor $ColorInfo
            Write-Host ""
            $modelOpt = Read-Host "  Selecciona modelo (1-5)"
            
            $model = switch ($modelOpt) {
                '1' { 'tiny' }
                '2' { 'base' }
                '3' { 'small' }
                '4' { 'medium' }
                '5' { 'turbo' }
                default { 'tiny' }
            }
            
            Invoke-whisper-transcriptor -Model $model
        }
        '4' {
            $dir = Read-Host "  Directorio de videos (Enter para ./inputs)"
            if ([string]::IsNullOrWhiteSpace($dir)) { $dir = "./inputs" }

            Write-Host "  Modelos: tiny, base, small, medium, turbo" -ForegroundColor $ColorInfo
            $model = Read-Host "  Modelo (Enter para tiny)"
            if ([string]::IsNullOrWhiteSpace($model)) { $model = "tiny" }

            Write-Host "  Extensiones: mp4, mkv, webm, avi, mov" -ForegroundColor $ColorInfo
            $ext = Read-Host "  Extensión (Enter para mp4)"
            if ([string]::IsNullOrWhiteSpace($ext)) { $ext = "mp4" }

            Write-Host "  Dispositivo: cpu, cuda" -ForegroundColor $ColorInfo
            $device = Read-Host "  Dispositivo (Enter para cpu)"
            if ([string]::IsNullOrWhiteSpace($device)) { $device = "cpu" }

            Invoke-whisper-transcriptor -Directory $dir -Model $model -Extension $ext -Device $device
        }
        '5' {
            Invoke-whisper-transcriptor -Help
        }
        '6' {
            Write-Host ""
            Write-Host "  ⚡ CUDA - Modelos disponibles:" -ForegroundColor $ColorInfo
            Write-Host "    [1] tiny   - Muy rápido, menor precisión" -ForegroundColor $ColorInfo
            Write-Host "    [2] base   - Rápido, precisión media" -ForegroundColor $ColorInfo
            Write-Host "    [3] small  - Balance velocidad/precisión" -ForegroundColor $ColorInfo
            Write-Host "    [4] medium - Lento, alta precisión" -ForegroundColor $ColorInfo
            Write-Host "    [5] turbo  - Optimizado para velocidad" -ForegroundColor $ColorInfo
            Write-Host ""
            $modelOpt = Read-Host "  Selecciona modelo (1-5, Enter para tiny)"

            $model = switch ($modelOpt) {
                '1' { 'tiny' }
                '2' { 'base' }
                '3' { 'small' }
                '4' { 'medium' }
                '5' { 'turbo' }
                default { 'tiny' }
            }

            Invoke-whisper-transcriptor -Model $model -Device cuda
        }
        default {
            Write-Warning "Opción no válida"
        }
    }
    
    Pause-Screen
}

function Show-Documentation {
    Show-Header
    Write-Host "  📖 DOCUMENTACIÓN" -ForegroundColor $ColorHeader
    Write-Host ""
    
    Write-Host "  Documentos disponibles:" -ForegroundColor $ColorInfo
    Write-Host ""
    Write-Host "  [1] 📄 Guía de instalación y uso (README-WINDOWS.md)" -ForegroundColor $ColorInfo
    Write-Host "  [2] 📘 Descripción técnica del módulo" -ForegroundColor $ColorInfo
    Write-Host "  [3] 🌐 Abrir repositorio en GitHub" -ForegroundColor $ColorInfo
    Write-Host ""
    
    $docOpt = Read-Host "  Selecciona una opción (1-3)"
    
    switch ($docOpt) {
        '1' {
            $readmePath = Join-Path -Path $PSScriptRoot -ChildPath "README-WINDOWS.md"
            if (Test-Path $readmePath) {
                Start-Process notepad.exe -ArgumentList $readmePath
                Write-Success "Abriendo documentación..."
            } else {
                Write-Error "No se encontró el archivo README-WINDOWS.md"
            }
        }
        '2' {
            $descPath = Join-Path -Path $ModulePath -ChildPath "Descripcion.md"
            if (Test-Path $descPath) {
                Start-Process notepad.exe -ArgumentList $descPath
                Write-Success "Abriendo descripción técnica..."
            } else {
                Write-Error "No se encontró el archivo Descripcion.md"
            }
        }
        '3' {
            Start-Process "https://github.com/amillanaol/WhisperTraductor"
            Write-Success "Abriendo navegador..."
        }
        default {
            Write-Warning "Opción no válida"
        }
    }
    
    Pause-Screen
}

function Invoke-Uninstall {
    Show-Header
    Write-Host "  🗑️  DESINSTALACIÓN" -ForegroundColor $ColorHeader
    Write-Host ""

    Write-Host "  ⚠️  Esta acción eliminará el módulo whisper-transcriptor del sistema." -ForegroundColor $ColorWarning
    Write-Host ""

    $confirm = Read-Host "  ¿Confirmas la desinstalación? (S/N)"

    if ($confirm -ne 'S' -and $confirm -ne 's') {
        Write-Info "Desinstalación cancelada"
        Pause-Screen
        return
    }

    $uninstallScript = Join-Path -Path $InstallerPath -ChildPath "uninstall-windows.ps1"

    if (-not (Test-Path $uninstallScript)) {
        Write-Error "No se encontró el script de desinstalación"
        Pause-Screen
        return
    }

    Show-Progress "Iniciando desinstalación"
    & $uninstallScript
    Pause-Screen
}

# --- BUCLE PRINCIPAL ---
$running = $true

while ($running) {
    Show-Header
    Show-Menu
    
    $option = Read-Option
    
    switch ($option) {
        '1' { Invoke-Install }
        '2' { Invoke-InstallAdvanced }
        '3' { Invoke-Verify }
        '4' { Invoke-RunModule }
        '5' { Show-Documentation }
        '6' { Invoke-Uninstall }
        '0' {
            $running = $false
            Show-Header
            Write-Host "  ¡Gracias por usar whisper-transcriptor! 👋" -ForegroundColor $ColorSuccess
            Write-Host ""
        }
        default {
            Write-Warning "  Opción no válida. Intenta de nuevo."
            Start-Sleep -Seconds 1
        }
    }
}
