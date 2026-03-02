# Install-whisper-transcriptor.ps1
# Script de instalación y configuración automática de whisper-transcriptor

# --- CONFIGURACIÓN INICIAL ---
Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║      whisper-transcriptor - Script de Instalación Automática      ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# --- DEFINICIÓN DE RUTAS ---
$ScriptRoot = $PSScriptRoot
$SourceModulePath = $ScriptRoot
$ManifestFile = Join-Path -Path $SourceModulePath -ChildPath 'whisper-transcriptor.psd1'

# Define el nombre de la carpeta del módulo y la ruta de destino
$ModuleName = "whisper-transcriptor"
if ($PSVersionTable.PSVersion.Major -ge 6) {
    $UserModulesPath = Join-Path -Path $env:USERPROFILE -ChildPath "Documents\PowerShell\Modules"
} else {
    $UserModulesPath = Join-Path -Path $env:USERPROFILE -ChildPath "Documents\WindowsPowerShell\Modules"
}
$DestinationModulePath = Join-Path -Path $UserModulesPath -ChildPath $ModuleName

Write-Host "Ruta de origen del módulo: $SourceModulePath" -ForegroundColor Yellow
Write-Host "Ruta de destino de la instalación: $DestinationModulePath" -ForegroundColor Yellow
Write-Host ""

# --- INSTALACIÓN DEL MÓDULO ---
try {
    # 1. Crear el directorio de destino si no existe
    if (-not (Test-Path -Path $DestinationModulePath)) {
        Write-Host "Creando directorio de destino..." -ForegroundColor Cyan
        New-Item -Path $DestinationModulePath -ItemType Directory -Force | Out-Null
        Write-Host "✓ Directorio creado en $DestinationModulePath" -ForegroundColor Green
    }

    # 2. Copiar los archivos del módulo
    Write-Host "Copiando archivos del módulo..." -ForegroundColor Cyan
    Copy-Item -Path "$SourceModulePath\*" -Destination $DestinationModulePath -Recurse -Force
    Write-Host "✓ Archivos del módulo copiados correctamente." -ForegroundColor Green
    Write-Host ""

    # 3. Validar y corregir el GUID en el nuevo destino
    $DestinationManifestFile = Join-Path -Path $DestinationModulePath -ChildPath 'whisper-transcriptor.psd1'
    $ManifestContent = Get-Content -Path $DestinationManifestFile -Raw
    
    if ($ManifestContent -match "GUID\s*=\s*['`"]a1b2c3d4-e5f6-47a8-b9c0-d1e2f3a4b5c6['`"]") {
        Write-Host "Se detectó un GUID de ejemplo. Generando uno nuevo..." -ForegroundColor Yellow
        $NewGuid = [guid]::NewGuid().Guid
        $NewManifestContent = $ManifestContent -replace "GUID\s*=\s*['`"]([^'`"]+)['`"]", "GUID = '$NewGuid'"
        Set-Content -Path $DestinationManifestFile -Value $NewManifestContent -Force
        Write-Host "✓ Manifiesto actualizado con un nuevo GUID: $NewGuid" -ForegroundColor Green
    }

    # 4. Importar el módulo desde la nueva ubicación para verificar
    Write-Host "Importando el módulo desde la nueva ubicación..." -ForegroundColor Cyan
    Import-Module -Name $DestinationModulePath -Force -ErrorAction Stop
    
    Write-Host "✓ Módulo whisper-transcriptor importado y verificado correctamente." -ForegroundColor Green
}
catch {
    # Captura de errores durante el proceso
    $ErrorMessage = $_.Exception.Message
    Write-Host "✗ Error inesperado durante la instalación:" -ForegroundColor Red
    Write-Host $ErrorMessage -ForegroundColor Red
    Write-Host ""
    Write-Host "Por favor, consulta la documentación en: docs/troubleshooting/" -ForegroundColor Yellow
    exit 1
}

# --- VERIFICACIÓN FINAL Y PRÓXIMOS PASOS ---
Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║           Instalación Completada Correctamente                 ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "El módulo 'whisper-transcriptor' ha sido instalado en tu perfil de usuario." -ForegroundColor White
Write-Host "Ahora estará disponible automáticamente en tus futuras sesiones de PowerShell." -ForegroundColor White
Write-Host ""
Write-Host "Próximos pasos:" -ForegroundColor Cyan
Write-Host "  1. Cierra esta ventana de PowerShell."
Write-Host "  2. Abre una NUEVA ventana de PowerShell."
Write-Host "  3. Verifica la instalación con: Get-Module -ListAvailable whisper-transcriptor"
Write-Host "  4. Prueba el módulo ejecutando: Invoke-whisper-transcriptor -Help"
Write-Host ""
