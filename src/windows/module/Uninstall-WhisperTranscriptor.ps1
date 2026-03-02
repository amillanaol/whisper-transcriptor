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

    if (-not $removed) {
        Write-Host "  • No se encontraron instalaciones del módulo" -ForegroundColor DarkGray
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
    Write-Host "🔍 Buscando alias del módulo..." -ForegroundColor Cyan
    Write-Host ""

    $aliasesToRemove = @("wtranscriptor", "whisper-transcriptor")
    $removed = $false

    foreach ($aliasName in $aliasesToRemove) {
        try {
            if (Get-Alias -Name $aliasName -ErrorAction SilentlyContinue) {
                Remove-Item -Path "Alias:\$aliasName" -Force
                Write-Host "  ✓ Alias '$aliasName' eliminado" -ForegroundColor Green
                $removed = $true
            }
        }
        catch {
            # Silenciosamente continuar si falla
        }
    }

    if (-not $removed) {
        Write-Host "  • No se encontraron alias para eliminar" -ForegroundColor DarkGray
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
    Clean-PowerShellProfile
    Clean-EnvironmentVariables
    Find-CmdFiles

    if (-not $wasRemoved) {
        Write-Host ""
        Write-Host "⚠ No se encontró el módulo instalado en las ubicaciones estándar" -ForegroundColor Yellow
        Write-Host ""
    }

    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║                    DESINSTALACIÓN COMPLETADA                   ║" -ForegroundColor Green
    Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
    Write-Host "✨ El módulo whisper-transcriptor ha sido eliminado completamente" -ForegroundColor White
    Write-Host ""
    Write-Host "📋 Limpieza realizada:" -ForegroundColor Cyan
    Write-Host "  ✓ Módulo descargado de memoria" -ForegroundColor DarkGray
    Write-Host "  ✓ Archivos del módulo eliminados" -ForegroundColor DarkGray
    Write-Host "  ✓ Alias limpiados (wtranscriptor)" -ForegroundColor DarkGray
    Write-Host "  ✓ Caché de PowerShell limpiado" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "⚠️  IMPORTANTE:" -ForegroundColor Yellow
    Write-Host "  • Cierra COMPLETAMENTE todas las ventanas de PowerShell" -ForegroundColor White
    Write-Host "  • Abre una nueva ventana para confirmar la desinstalación" -ForegroundColor White
    Write-Host ""
    Write-Host "🔍 Para verificar:" -ForegroundColor Cyan
    Write-Host "  Get-Module -ListAvailable whisper-transcriptor" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "🔄 Para reinstalar:" -ForegroundColor Cyan
    Write-Host "  .\src\windows\module\Install-WhisperTranslator.ps1" -ForegroundColor DarkGray
    Write-Host ""
}

# Ejecutar desinstalación
Uninstall-whisper-transcriptor
