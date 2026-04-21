<#
.SYNOPSIS
    Demo de las capacidades del módulo TUI-Utils

.DESCRIPTION
    Script de demostración que muestra cómo usar las funciones
    del módulo TUI-Utils para crear interfaces de texto interactivas.

.EXAMPLE
    .\examples\tui-demo.ps1
#>

# Importar módulo
$modulePath = Join-Path $PSScriptRoot "..\src\windows\module\TUI-Utils.psm1"
Import-Module $modulePath -Force

Clear-Host

Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║           DEMO DEL MÓDULO TUI-UTILS                       ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Demo 1: Barras de Progreso
Write-Host "1️⃣  BARRAS DE PROGRESO" -ForegroundColor Yellow
Write-Host ""

Write-Host "  Progreso con valores:" -ForegroundColor Gray
Write-Host "  $(Show-ProgressBar -Current 0 -Total 100)" -ForegroundColor Green
Start-Sleep -Milliseconds 500
Write-Host "  $(Show-ProgressBar -Current 25 -Total 100)" -ForegroundColor Green
Start-Sleep -Milliseconds 500
Write-Host "  $(Show-ProgressBar -Current 50 -Total 100)" -ForegroundColor Green
Start-Sleep -Milliseconds 500
Write-Host "  $(Show-ProgressBar -Current 75 -Total 100)" -ForegroundColor Green
Start-Sleep -Milliseconds 500
Write-Host "  $(Show-ProgressBar -Current 100 -Total 100)" -ForegroundColor Green

Write-Host ""
Write-Host "  Progreso con porcentaje:" -ForegroundColor Gray
Write-Host "  $(Show-FileProgressBar -Percent 33)" -ForegroundColor Magenta
Write-Host "  $(Show-FileProgressBar -Percent 66)" -ForegroundColor Magenta
Write-Host "  $(Show-FileProgressBar -Percent 100)" -ForegroundColor Magenta

Start-Sleep -Seconds 2

# Demo 2: Spinner Animado
Clear-Host
Write-Host "2️⃣  SPINNER ANIMADO" -ForegroundColor Yellow
Write-Host ""

$cursorTop = [Console]::CursorTop
for ($i = 0; $i -lt 30; $i++) {
    [Console]::SetCursorPosition(0, $cursorTop)
    $spinner = Show-SpinnerFrame -Frame $i -Style 'dots'
    Write-Host "  $spinner Procesando... (estilo: dots)" -ForegroundColor Cyan

    $spinner = Show-SpinnerFrame -Frame $i -Style 'line'
    Write-Host "  $spinner Procesando... (estilo: line)" -ForegroundColor Green

    $spinner = Show-SpinnerFrame -Frame $i -Style 'arrow'
    Write-Host "  $spinner Procesando... (estilo: arrow)" -ForegroundColor Magenta

    $spinner = Show-SpinnerFrame -Frame $i -Style 'box'
    Write-Host "  $spinner Procesando... (estilo: box)" -ForegroundColor Yellow

    Start-Sleep -Milliseconds 100
}

Start-Sleep -Seconds 1

# Demo 3: Cajas de Información
Clear-Host
Write-Host "3️⃣  CAJAS DE INFORMACIÓN" -ForegroundColor Yellow
Write-Host ""

Show-InfoBox -Title "INFORMACIÓN DEL SISTEMA" -Fields @{
    "Sistema Operativo" = "Windows 11"
    "PowerShell"        = $PSVersionTable.PSVersion.ToString()
    "Fecha"             = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    "Usuario"           = $env:USERNAME
}

Write-Host ""
Start-Sleep -Seconds 2

Show-ProcessingBox -FileName "ejemplo-video.mp4" `
    -Status "Transcribiendo con modelo 'base'..." `
    -Detail "Duración: 05:30 | Tamaño: 45.2 MB"

Start-Sleep -Seconds 2

# Demo 4: Separadores
Clear-Host
Write-Host "4️⃣  SEPARADORES" -ForegroundColor Yellow
Write-Host ""

Write-Host "  $(Show-Separator -Width 50 -Char '─')" -ForegroundColor DarkGray
Write-Host "  Contenido entre separadores"
Write-Host "  $(Show-Separator -Width 50 -Char '═')" -ForegroundColor Cyan
Write-Host "  Más contenido"
Write-Host "  $(Show-Separator -Width 50 -Char '•')" -ForegroundColor Yellow

Start-Sleep -Seconds 2

# Demo 5: Parseo de Progreso
Clear-Host
Write-Host "5️⃣  PARSEO DE PROGRESO" -ForegroundColor Yellow
Write-Host ""

$testLines = @(
    "Processing: 45% complete",
    "Progress: 123/456 files",
    "Status: 78%|███████░░░| remaining",
    "00:01:23,456 --> 00:01:28,789"
)

foreach ($line in $testLines) {
    Write-Host "  Línea: " -NoNewline -ForegroundColor Gray
    Write-Host $line -ForegroundColor White

    $progress = Get-ProgressFromLine -Line $line
    if ($progress -ge 0) {
        Write-Host "  ➜ Progreso detectado: " -NoNewline -ForegroundColor Green
        Write-Host "$progress%" -ForegroundColor Cyan
    }

    $timestamp = Get-TimestampFromSRT -Line $line
    if ($timestamp) {
        Write-Host "  ➜ Timestamp detectado: " -NoNewline -ForegroundColor Green
        Write-Host "$($timestamp.Hours):$($timestamp.Minutes):$($timestamp.Seconds) ($($timestamp.TotalSeconds)s)" -ForegroundColor Cyan
    }

    Write-Host ""
}

Start-Sleep -Seconds 3

# Demo 6: Actualización en Tiempo Real
Clear-Host
Write-Host "6️⃣  ACTUALIZACIÓN EN TIEMPO REAL" -ForegroundColor Yellow
Write-Host ""
Write-Host "  Simulando proceso con actualización de progreso..." -ForegroundColor Gray
Write-Host ""

$cursorTop = [Console]::CursorTop
for ($i = 0; $i -le 100; $i += 2) {
    Update-ScreenRegion -StartLine $cursorTop -ScriptBlock {
        $spinner = Show-SpinnerFrame -Frame $i
        $bar = Show-FileProgressBar -Percent $i
        Write-Host "  $spinner $bar" -ForegroundColor Magenta
        Write-Host ""
        Write-Host "  📝 Estado: Procesando archivo $i de 100..." -ForegroundColor Yellow
        Write-Host "  ⏱️  Tiempo estimado: $([math]::Max(0, 100 - $i))s restantes" -ForegroundColor Cyan
    }
    Start-Sleep -Milliseconds 50
}

Write-Host ""
Write-Host "  ✓ Proceso completado!" -ForegroundColor Green

Start-Sleep -Seconds 2

# Demo 7: Ejemplo Completo Integrado
Clear-Host
Write-Host "7️⃣  EJEMPLO INTEGRADO COMPLETO" -ForegroundColor Yellow
Write-Host ""

# Simular procesamiento de múltiples archivos
$files = @("video1.mp4", "video2.mp4", "video3.mp4")
$totalFiles = $files.Count

for ($fileIndex = 0; $fileIndex -lt $totalFiles; $fileIndex++) {
    Clear-Host

    # Progreso general
    Write-Host "  🎯 PROGRESO GENERAL" -ForegroundColor Green
    Write-Host "  $(Show-ProgressBar -Current ($fileIndex + 1) -Total $totalFiles)" -ForegroundColor Cyan
    Write-Host ""

    # Información del archivo actual
    Show-ProcessingBox -FileName $files[$fileIndex] `
        -Status "Transcribiendo con modelo 'base'..." `
        -Detail "Duración: 0$(Get-Random -Minimum 3 -Maximum 9):$(Get-Random -Minimum 10 -Maximum 59) | Tamaño: $(Get-Random -Minimum 20 -Maximum 100).$(Get-Random -Minimum 10 -Maximum 99) MB"

    Write-Host ""
    Write-Host "  📊 PROGRESO DEL ARCHIVO" -ForegroundColor Magenta

    # Progreso del archivo actual
    $cursorTop = [Console]::CursorTop
    for ($progress = 0; $progress -le 100; $progress += 5) {
        Update-ScreenRegion -StartLine $cursorTop -ScriptBlock {
            $spinner = Show-SpinnerFrame -Frame $progress
            $bar = Show-FileProgressBar -Percent $progress
            Write-Host "  $spinner $bar" -ForegroundColor Magenta
            Write-Host ""
            Write-Host "  ⏱️  Procesando: $progress% completado" -ForegroundColor Cyan
        }
        Start-Sleep -Milliseconds 100
    }

    Write-Host ""
    Write-Host "  ✓ Archivo completado!" -ForegroundColor Green
    Start-Sleep -Seconds 1
}

# Resumen final
Clear-Host
Write-Host ""
Write-Host "  ╔════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "  ║                   ✓ DEMO COMPLETADO                        ║" -ForegroundColor Green
Write-Host "  ╚════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "  📚 Documentación completa en: docs/desarrollo/tui_patrones.md" -ForegroundColor Cyan
Write-Host "  🔧 Código del módulo en: src/windows/module/TUI-Utils.psm1" -ForegroundColor Cyan
Write-Host ""
