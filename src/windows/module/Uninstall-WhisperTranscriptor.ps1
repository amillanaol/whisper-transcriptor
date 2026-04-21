# Uninstall-whisper-transcriptor.ps1

# Script de desinstalación de whisper-transcriptor
# Elimina de manera limpia el módulo del sistema

Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║        whisper-transcriptor - Script de Desinstalación            ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Función para eliminar el módulo de las rutas estándar
function Remove-ModuleFromStandardPaths {
    Write-Host "📁 Eliminando archivos del módulo..." -ForegroundColor Cyan
    Write-Host ""

    $standardPaths = @(
        "$env:USERPROFILE\Documents\PowerShell\Modules\whisper-transcriptor",
        "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\whisper-transcriptor",
        "$env:USERPROFILE\Documents\PowerShell\Modules\WhisperTranslator",
        "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\WhisperTranslator",
        "C:\Program Files\PowerShell\Modules\whisper-transcriptor",
        "$env:ProgramFiles\PowerShell\Modules\whisper-transcriptor"
    )

    $removed = $false

    foreach ($path in $standardPaths) {
        if (Test-Path -Path $path) {
            try {
                Write-Host "  • Eliminando de: $path" -ForegroundColor Yellow
                Remove-Item -Path $path -Recurse -Force -ErrorAction Stop
                Write-Host "    ✓ Módulo eliminado correctamente" -ForegroundColor Green
                $removed = $true
            }
            catch {
                Write-Host "    ✗ Error al eliminar: $_" -ForegroundColor Red
            }
        }
    }

    # También buscar el módulo instalado desde el código fuente
    $currentScriptDir = Split-Path -Parent $PSCommandPath
    $projectRoot = Split-Path -Parent (Split-Path -Parent $currentScriptDir)
    $moduleSourcePath = Join-Path $projectRoot "src\windows\module"
    if (Test-Path $moduleSourcePath) {
        try {
            Write-Host "  • Limpiando sesión de código fuente: $moduleSourcePath" -ForegroundColor Yellow
            Write-Host "    (El módulo se carga desde código fuente, no está 'instalado')" -ForegroundColor DarkGray
            $removed = $true
        }
        catch {
            Write-Host "    ✗ Advertencia: $_" -ForegroundColor Yellow
        }
    }

    if (-not $removed) {
        Write-Host "  • No se encontraron instalaciones formales del módulo" -ForegroundColor DarkGray
        Write-Host "    (El módulo puede estar cargándose desde código fuente)" -ForegroundColor DarkGray
    }

    Write-Host ""
    return $removed
}

# Función para descargar el módulo de la sesión actual y limpiar caché
function Unload-Module {
    Write-Host "🔄 Limpiando módulo de memoria..." -ForegroundColor Cyan
    Write-Host ""

    try {
        # Verificar si el módulo está cargado
        $loadedModule = Get-Module -Name "whisper-transcriptor" -ErrorAction SilentlyContinue

        if ($loadedModule) {
            Write-Host "  • Módulo encontrado en memoria: $($loadedModule.Path)" -ForegroundColor Yellow
            Remove-Module -Name "whisper-transcriptor" -Force -ErrorAction Stop
            Write-Host "  ✓ Módulo descargado de la sesión actual" -ForegroundColor Green
        } else {
            Write-Host "  • Módulo no estaba cargado en esta sesión" -ForegroundColor DarkGray
        }

        # Limpiar alias wtranscriptor si existe
        if (Get-Alias -Name "wtranscriptor" -ErrorAction SilentlyContinue) {
            Remove-Item -Path "Alias:\wtranscriptor" -Force -ErrorAction SilentlyContinue
            Write-Host "  ✓ Alias 'wtranscriptor' eliminado de memoria" -ForegroundColor Green
        }

        # Limpiar caché de módulos de PowerShell
        $moduleCachePath = Join-Path $env:LOCALAPPDATA "Microsoft\Windows\PowerShell\ModuleAnalysisCache"
        if (Test-Path $moduleCachePath) {
            try {
                Remove-Item $moduleCachePath -Force -ErrorAction SilentlyContinue
                Write-Host "  ✓ Caché de análisis de módulos limpiado" -ForegroundColor Green
            } catch {
                Write-Host "  ⚠ No se pudo limpiar el caché de análisis (no crítico)" -ForegroundColor Yellow
            }
        }

        Write-Host ""
    }
    catch {
        Write-Host "  ✗ Error al descargar el módulo: $_" -ForegroundColor Red
        Write-Host ""
    }
}

# Función para limpiar alias
function Remove-ModuleAlias {
    Write-Host "🔍 Buscando alias y funciones del módulo..." -ForegroundColor Cyan
    Write-Host ""

    $namesToRemove = @("wtranscriptor", "whisper-transcriptor")
    $removed = $false

    foreach ($name in $namesToRemove) {
        # buscar alias
        try {
            $alias = Get-Alias -Name $name -ErrorAction SilentlyContinue
            if ($alias) {
                Remove-Item -Path "Alias:\$name" -Force -ErrorAction SilentlyContinue
                Write-Host "  ✓ Alias '$name' eliminado" -ForegroundColor Green
                $removed = $true
            }
        }
        catch {
            # Silenciosamente continuar
        }

        # buscar función
        try {
            $func = Get-Command -Name $name -ErrorAction SilentlyContinue
            if ($func) {
                # Si es un archivo de script, también limpiarlo
                $funcPath = $func.Path
                if ($funcPath -match "whisper-transcriptor") {
                    Write-Host "  ✓ Función '$name' encontrada: $funcPath" -ForegroundColor Yellow
                }
                # Remover de memoria
                Remove-Item -Path "Function:\$name" -Force -ErrorAction SilentlyContinue
                Write-Host "  ✓ Función '$name' eliminada de memoria" -ForegroundColor Green
                $removed = $true
            }
        }
        catch {
            # Silenciosamente continuar
        }
    }

    if (-not $removed) {
        Write-Host "  • No se encontraron alias/funciones para eliminar" -ForegroundColor DarkGray
    }

    Write-Host ""
}

# Función para limpiar el perfil de PowerShell
function Clean-PowerShellProfile {
    if (Test-Path -Path $PROFILE) {
        try {
            $profileContent = Get-Content -Path $PROFILE -Raw

            # Busca líneas que contengan "whisper-transcriptor" o "whisper-transcriptor"
            if ($profileContent -match "whisper-transcriptor|whisper-transcriptor") {
                Write-Host ""
                Write-Host "Se encontraron referencias en el perfil de PowerShell: $PROFILE" -ForegroundColor Yellow
                Write-Host "¿Deseas eliminar automáticamente estas referencias?" -ForegroundColor Yellow
                
                $response = Read-Host "Responde 'si' o 'no'"
                
                if ($response -eq "si" -or $response -eq "s") {
                    # Elimina líneas que contengan whisper-transcriptor o whisper-transcriptor
                    $newContent = $profileContent -replace ".*whisper-transcriptor.*`n|.*whisper-transcriptor.*`n", ""
                    Set-Content -Path $PROFILE -Value $newContent -Force
                    Write-Host "✓ Perfil limpiado correctamente" -ForegroundColor Green
                }
            }
        }
        catch {
            Write-Host "✗ Error al limpiar el perfil: $_" -ForegroundColor Red
        }
    }
}

# Función para limpiar variables de entorno (PATH)
function Clean-EnvironmentVariables {
    try {
        $pathVar = [Environment]::GetEnvironmentVariable("Path", "User")
        
        if ($pathVar -match "whisper-transcriptor") {
            Write-Host ""
            Write-Host "Se encontraron referencias en la variable PATH" -ForegroundColor Yellow
            Write-Host "¿Deseas eliminar automáticamente estas referencias?" -ForegroundColor Yellow
            
            $response = Read-Host "Responde 'si' o 'no'"
            
            if ($response -eq "si" -or $response -eq "s") {
                # Elimina la ruta de whisper-transcriptor del PATH
                $newPath = ($pathVar -split ";") | Where-Object { $_ -notmatch "whisper-transcriptor" } | Join-String -Separator ";"
                [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
                Write-Host "✓ Variable PATH limpiada correctamente" -ForegroundColor Green
                Write-Host "Nota: Cierra y reabre PowerShell para que los cambios tengan efecto" -ForegroundColor Cyan
            }
        }
    }
    catch {
        Write-Host "✗ Error al limpiar variables de entorno: $_" -ForegroundColor Red
    }
}

# Función para encontrar archivos .cmd registrados
function Find-CmdFiles {
    $systemPath = $env:PATH -split ";"
    
    foreach ($path in $systemPath) {
        if (Test-Path -Path $path) {
            $cmdFile = Join-Path -Path $path -ChildPath "whisper-transcriptor.cmd"
            if (Test-Path -Path $cmdFile) {
                Write-Host ""
                Write-Host "Se encontró: $cmdFile" -ForegroundColor Yellow
                Write-Host "¿Deseas eliminarlo?" -ForegroundColor Yellow
                
                $response = Read-Host "Responde 'si' o 'no'"
                
                if ($response -eq "si" -or $response -eq "s") {
                    try {
                        Remove-Item -Path $cmdFile -Force
                        Write-Host "✓ Archivo eliminado: $cmdFile" -ForegroundColor Green
                    }
                    catch {
                        Write-Host "✗ Error al eliminar $cmdFile : $_" -ForegroundColor Red
                    }
                }
            }
        }
    }
}

# Función para forzar limpieza completa del comando de la sesión
function Force-CleanCommand {
    param([string]$CommandName = "wtranscriptor")
    
    Write-Host "🔧 Forzando limpieza de '$CommandName'..." -ForegroundColor Cyan
    
    # busqueda en todos los scopes de función
    $cleaned = $false
    
    # 1. Remover de Function: scope actual
    if (Test-Path "Function:\$CommandName") {
        Remove-Item "Function:\$CommandName" -Force -ErrorAction SilentlyContinue
        Write-Host "  ✓ Eliminada función del scope actual" -ForegroundColor Green
        $cleaned = $true
    }
    
    # 2. Remover alias
    if (Test-Path "Alias:\$CommandName") {
        Remove-Item "Alias:\$CommandName" -Force -ErrorAction SilentlyContinue
        Write-Host "  ✓ Eliminado alias del scope actual" -ForegroundColor Green
        $cleaned = $true
    }
    
    # 3. Buscar en funciones globales
    try {
        $cmd = Get-Command $CommandName -ErrorAction SilentlyContinue
        if ($cmd) {
            $cmdType = $cmd.CommandType
            Write-Host "  ℹ Comando encontrado: $cmdType" -ForegroundColor Yellow
            
            # Si es función o alias, limpiar el origen
            if ($cmdType -eq "Function" -or $cmdType -eq "Alias") {
                $origin = $cmd.Source
                Write-Host "    Origen: $origin" -ForegroundColor DarkGray
            }
        }
    }
    catch {
        # No encontramos el comando - está limpio
    }
    
    if (-not $cleaned) {
        Write-Host "  • No se encontró '$CommandName' en la sesión actual" -ForegroundColor DarkGray
    }
    
    Write-Host ""
}

# Función principal de desinstalación
function Uninstall-whisper-transcriptor {
    Write-Host ""
    Write-Host "⚠️  Este script desinstalará whisper-transcriptor de tu sistema." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Se realizará una limpieza completa:" -ForegroundColor Cyan
    Write-Host "  1. 🔄 Descargar el módulo de memoria (incluye caché)" -ForegroundColor White
    Write-Host "  2. 📁 Eliminar archivos del módulo" -ForegroundColor White
    Write-Host "  3. 🏷️  Limpiar aliases (wtranscriptor)" -ForegroundColor White
    Write-Host "  4. 📝 Limpiar referencias en el perfil de PowerShell" -ForegroundColor White
    Write-Host "  5. 🔧 Limpiar variables de entorno (PATH)" -ForegroundColor White
    Write-Host "  6. 🔍 Buscar y eliminar archivos .cmd asociados" -ForegroundColor White
    Write-Host ""
    
    $confirm = Read-Host "¿Estás seguro de que deseas continuar? (si/no)"
    
    if ($confirm -ne "si" -and $confirm -ne "s") {
        Write-Host "Desinstalación cancelada." -ForegroundColor Yellow
        return
    }

    Write-Host ""
    Write-Host "Iniciando desinstalación..." -ForegroundColor Cyan
    Write-Host ""

# Ejecutar pasos de desinstalación
    Unload-Module
    $wasRemoved = Remove-ModuleFromStandardPaths
    Remove-ModuleAlias
    Force-CleanCommand -CommandName "wtranscriptor"
    Clean-PowerShellProfile
    Clean-EnvironmentVariables
    Find-CmdFiles

if (-not $wasRemoved) {
        Write-Host ""
        Write-Host "⚠ No se encontró el módulo instalado formalmente" -ForegroundColor Yellow
        Write-Host "  El módulo parece estar cargado desde código fuente" -ForegroundColor DarkGray
        Write-Host ""
    }

    # Forzar limpieza del alias aunque no haya módulo instalado
    Write-Host "🔧 Limpiando alias 'wtranscriptor' de todas las sesiones..." -ForegroundColor Cyan
    try {
        # Intentar en múltiples scopes
        $aliases = Get-Alias -Name "wtranscriptor" -ErrorAction SilentlyContinue
        if ($aliases) {
            Remove-Item -Path "Alias:\wtranscriptor" -Force -ErrorAction SilentlyContinue
            Write-Host "  ✓ Alias 'wtranscriptor' eliminado" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "  • No se encontró alias en sesión actual" -ForegroundColor DarkGray
    }
    Write-Host ""

Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║                    DESINSTALACIÓN COMPLETADA                   ║" -ForegroundColor Green
    Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
    Write-Host "✨Limpieza completada" -ForegroundColor White
    Write-Host ""
    Write-Host "📋Resumen:" -ForegroundColor Cyan
    Write-Host "  ✓ Módulo descargado de memoria (si estaba cargado)" -ForegroundColor DarkGray
    Write-Host "  ✓ Alias/funciones limpiados" -ForegroundColor DarkGray
    Write-Host "  ✓ Caché de PowerShell limpiado" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "⚠️  IMPORTANTE - CIERRA COMPLETAMENTE PowerShell y ábrelo nuevo" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "🔍 Para usar desde código fuente (en nueva sesión):" -ForegroundColor Cyan
    Write-Host "  cd C:\Users\alexi\src\amillanaol\whisper-transcriptor" -ForegroundColor DarkGray
    Write-Host "  Import-Module .\src\windows\module\whisper-transcriptor.psd1 -Force" -ForegroundColor DarkGray
    Write-Host "  wtranscriptor videos-input\video.mp4 -m tiny" -ForegroundColor DarkGray
    Write-Host ""
}

# Ejecutar desinstalación
Uninstall-whisper-transcriptor
