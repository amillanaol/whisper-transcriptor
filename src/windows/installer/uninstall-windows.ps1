<#
.SYNOPSIS
    Script de desinstalación de whisper-transcriptor para Windows
.DESCRIPTION
    Este script elimina completamente el módulo whisper-transcriptor del sistema,
    incluyendo archivos de configuración y directorios de trabajo opcionalmente.
.NOTES
    Versión: 1.0.0
    Autor: amillanaol
    Requiere: PowerShell 5.1 o superior
#>

[CmdletBinding(SupportsShouldProcess=$true)]
param(
    [switch]$RemoveData,
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

# --- FUNCIÓN PARA BUSCAR Y ELIMINAR EL MÓDULO ---
function Remove-ModuleFromAllPaths {
    # Buscar tanto "whisper-transcriptor" como "WhisperTranslator"
    $ModuleNames = @("whisper-transcriptor", "WhisperTranslator")
    $allPaths = @()

    foreach ($ModuleName in $ModuleNames) {
        $allPaths += @(
            "$env:USERPROFILE\Documents\PowerShell\Modules\$ModuleName",
            "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\$ModuleName",
            "C:\Program Files\PowerShell\Modules\$ModuleName",
            "$env:ProgramFiles\PowerShell\Modules\$ModuleName"
        )
    }

    $standardPaths = $allPaths

    $removed = $false
    $foundLocations = @()

    foreach ($path in $standardPaths) {
        if (Test-Path -Path $path) {
            $foundLocations += $path
        }
    }

    if ($foundLocations.Count -eq 0) {
        Write-Warning "El módulo whisper-transcriptor/WhisperTranslator no está instalado en ninguna ubicación estándar"
        return $false
    }

    Write-Info "Se encontró el módulo en las siguientes ubicaciones:"
    foreach ($location in $foundLocations) {
        Write-Host "  • $location" -ForegroundColor $ColorInfo
    }
    Write-Host ""

    # Primero, remover los módulos de la sesión actual si están cargados
    foreach ($ModuleName in $ModuleNames) {
        $loadedModule = Get-Module -Name $ModuleName
        if ($loadedModule) {
            Write-Info "Removiendo módulo '$ModuleName' de la sesión actual..."
            Remove-Module -Name $ModuleName -Force -ErrorAction SilentlyContinue
            Write-Success "Módulo removido de la sesión"
        }
    }

    foreach ($path in $foundLocations) {
        try {
            Write-Info "Eliminando módulo de: $path"
            Remove-Item -Path $path -Recurse -Force -ErrorAction Stop
            Write-Success "Módulo eliminado correctamente de $path"
            $removed = $true
        }
        catch {
            Write-Error "Error al eliminar de $path : $_"
        }
    }

    return $removed
}

# --- INICIO ---
Write-Header "whisper-transcriptor - Desinstalador para Windows"

$ModuleNames = @("whisper-transcriptor", "WhisperTranslator")
$WorkingDirectory = Join-Path -Path $env:USERPROFILE -ChildPath "whisper-transcriptor"

# Confirmación
if (-not $Force) {
    Write-Host "`nSe eliminará el módulo whisper-transcriptor del sistema." -ForegroundColor $ColorWarning

    if ($RemoveData) {
        Write-Host "Esto incluye:" -ForegroundColor $ColorWarning
        Write-Host "  • Archivos del módulo" -ForegroundColor $ColorWarning
        Write-Host "  • Directorio de trabajo y todos los datos en: $WorkingDirectory" -ForegroundColor $ColorError
    } else {
        Write-Host "Esto incluye:" -ForegroundColor $ColorWarning
        Write-Host "  • Archivos del módulo" -ForegroundColor $ColorWarning
    }

    Write-Host ""
    $confirm = Read-Host "¿Estás seguro de que deseas continuar? (Escribe 'DESINSTALAR' para confirmar)"

    if ($confirm -ne 'DESINSTALAR') {
        Write-Info "Desinstalación cancelada"
        exit 0
    }
}

# --- DESINSTALACIÓN DEL MÓDULO ---
Write-Header "Eliminando Módulo"

# Eliminar archivos del módulo de todas las ubicaciones posibles
# (La función Remove-ModuleFromAllPaths ya maneja la remoción de la sesión)
$moduleRemoved = Remove-ModuleFromAllPaths

if (-not $moduleRemoved) {
    Write-Warning "No se pudo eliminar el módulo o no se encontró"
    exit 0
}

# --- ELIMINACIÓN DE DATOS (OPCIONAL) ---
if ($RemoveData) {
    Write-Header "Eliminando Datos del Usuario"
    
    if (Test-Path -Path $WorkingDirectory) {
        Write-Info "Eliminando directorio de trabajo: $WorkingDirectory"
        Write-Warning "¡Esto eliminará todos los videos y subtítulos generados!"
        
        if (-not $Force) {
            $confirmData = Read-Host "¿Estás seguro? Esta acción NO se puede deshacer (S/N)"
            if ($confirmData -ne 'S' -and $confirmData -ne 's') {
                Write-Info "Eliminación de datos cancelada"
            } else {
                try {
                    Remove-Item -Path $WorkingDirectory -Recurse -Force
                    Write-Success "Directorio de trabajo eliminado"
                } catch {
                    Write-Error "Error al eliminar datos: $_"
                }
            }
        } else {
            try {
                Remove-Item -Path $WorkingDirectory -Recurse -Force
                Write-Success "Directorio de trabajo eliminado"
            } catch {
                Write-Error "Error al eliminar datos: $_"
            }
        }
    } else {
        Write-Info "No se encontró directorio de trabajo"
    }
} else {
    Write-Info "Datos del usuario preservados en: $WorkingDirectory"
    Write-Info "Para eliminarlos manualmente, usa: Remove-Item '$WorkingDirectory' -Recurse -Force"
}

# --- VERIFICACIÓN ---
Write-Header "Verificación"

$remainingModules = @()
foreach ($ModuleName in $ModuleNames) {
    $found = Get-Module -ListAvailable -Name $ModuleName
    if ($found) {
        $remainingModules += $found
    }
}

if ($remainingModules.Count -gt 0) {
    Write-Warning "El módulo aún aparece como disponible. Es posible que esté instalado en otra ubicación."
    Write-Info "Ubicaciones encontradas:"
    $remainingModules | ForEach-Object { Write-Host "  - $($_.ModuleBase)" -ForegroundColor $ColorInfo }
} else {
    Write-Success "Módulo desinstalado correctamente"
}

# --- RESUMEN ---
Write-Header "Desinstalación Completada"

Write-Host @"

El módulo whisper-transcriptor ha sido eliminado del sistema.

✓ Archivos del módulo eliminados
"@ -ForegroundColor $ColorSuccess

if (-not $RemoveData) {
    Write-Host "ℹ Datos del usuario preservados en: $WorkingDirectory" -ForegroundColor $ColorInfo
}

Write-Host "`nPara reinstalar el módulo en el futuro, ejecuta:" -ForegroundColor $ColorInfo
Write-Host "  .\install-windows.ps1" -ForegroundColor $ColorSuccess
Write-Host ""
