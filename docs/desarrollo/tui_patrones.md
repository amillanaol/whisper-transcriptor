# Patrones de TUI (Text User Interface) en PowerShell

## Lecciones Aprendidas

Este documento captura los patrones y mejores prácticas aprendidas al construir interfaces de texto interactivas en PowerShell.

## 1. Captura de Salida de Procesos

### ❌ Anti-patrón: Intentar capturar salida de TTY complejas

```powershell
# NO FUNCIONA BIEN con programas que usan barras de progreso interactivas (tqdm, etc.)
$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.RedirectStandardOutput = $true
$psi.RedirectStandardError = $true
$process.Start()
$process.BeginOutputReadLine()  # Las barras de progreso no se capturan bien
```

**Problema**: Programas como Whisper usan técnicas especiales de terminal (caracteres de control, ANSI escape codes) que no se capturan bien con redirección estándar.

### ✅ Solución: Dejar que el programa muestre su salida directamente

```powershell
# FUNCIONA: Deja que el programa use la consola directamente
& whisper "archivo.mp4" --argumentos
```

**Ventajas**:
- Muestra barras de progreso animadas correctamente
- Mantiene colores y formato
- Mucho más simple y confiable

### 🔄 Alternativa: Solo cuando el programa escribe archivos incrementalmente

```powershell
# Si el programa escribe resultados a un archivo mientras trabaja
$process = Start-Process -PassThru -WindowStyle Hidden
while (-not $process.HasExited) {
    # Leer archivo de salida si existe y ha crecido
    if (Test-Path $outputFile) {
        $content = Get-Content $outputFile
        # Parsear y mostrar progreso
    }
    Start-Sleep -Milliseconds 200
}
```

## 2. Actualización de Pantalla en Tiempo Real

### Patrón básico: SetCursorPosition

```powershell
$cursorTop = [Console]::CursorTop  # Guardar posición inicial

while ($condition) {
    # Volver a la posición guardada
    [Console]::SetCursorPosition(0, $cursorTop)

    # Dibujar contenido actualizado
    Write-Host "  Progreso: $percent%" -ForegroundColor Green

    Start-Sleep -Milliseconds 200
}
```

**Importante**:
- Guardar `$cursorTop` ANTES del bucle
- Usar `SetCursorPosition(0, $cursorTop)` en CADA iteración
- Mantener el mismo número de líneas para evitar parpadeo

## 3. Componentes Visuales Reutilizables

### Barra de Progreso

```powershell
function Show-ProgressBar {
    param(
        [int]$Current,
        [int]$Total,
        [int]$BarLength = 40
    )

    $percent = [math]::Floor(($Current / $Total) * 100)
    $filled = [math]::Floor(($percent / 100) * $BarLength)
    $empty = $BarLength - $filled

    $bar = "[" + ("█" * $filled) + ("░" * $empty) + "]"
    return "$bar $percent% ($Current/$Total)"
}
```

### Spinner Animado

```powershell
function Show-SpinnerFrame {
    param([int]$Frame)
    $spinners = @("⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏")
    return $spinners[$Frame % $spinners.Count]
}

# Uso en bucle
$frame = 0
while ($processing) {
    $spinner = Show-SpinnerFrame -Frame $frame
    Write-Host "  $spinner Procesando..." -ForegroundColor Yellow
    $frame++
    Start-Sleep -Milliseconds 200
}
```

### Caja de Información

```powershell
function Show-InfoBox {
    param(
        [string]$Title,
        [hashtable]$Fields,
        [int]$Width = 64
    )

    $topBorder = "╔" + ("═" * ($Width - 2)) + "╗"
    $midBorder = "╠" + ("═" * ($Width - 2)) + "╣"
    $botBorder = "╚" + ("═" * ($Width - 2)) + "╝"

    Write-Host $topBorder -ForegroundColor Cyan
    Write-Host "║  $Title" + (" " * ($Width - 4 - $Title.Length)) + "║" -ForegroundColor Cyan
    Write-Host $midBorder -ForegroundColor Cyan

    foreach ($key in $Fields.Keys) {
        $line = "  $($key): $($Fields[$key])"
        $padding = " " * ($Width - 4 - $line.Length)
        Write-Host "║  $line$padding║" -ForegroundColor Cyan
    }

    Write-Host $botBorder -ForegroundColor Cyan
}
```

## 4. Parseo de Salida para Progreso

### Patrones comunes a buscar

```powershell
# Porcentajes: "50%", "100%|", "|50%"
if ($line -match '(\d{1,3})%') {
    $progress = [int]$matches[1]
}

# Ratios: "123/456"
if ($line -match '(\d+)/(\d+)') {
    $current = [int]$matches[1]
    $total = [int]$matches[2]
    $progress = [math]::Floor(($current / $total) * 100)
}

# Timestamps SRT: "00:01:23,456 --> 00:01:28,789"
if ($line -match '^(\d{2}):(\d{2}):(\d{2}),\d{3}\s*-->\s*') {
    $minutes = [int]$matches[2]
    $seconds = [int]$matches[3]
    $currentTime = ($minutes * 60) + $seconds
}
```

## 5. Manejo de Eventos Asincrónicos

### ⚠️ Cuidado con eventos en PowerShell

```powershell
# Los eventos pueden NO capturar salida de programas con TTY interactivo
$outputEvent = Register-ObjectEvent -InputObject $process `
    -EventName OutputDataReceived `
    -Action { /* ... */ }
```

**Problema**: Los eventos asincrónicos tienen problemas de sincronización y pueden no capturar salida de programas que escriben directamente a TTY.

**Solución**: Usar solo cuando el programa escribe a stdout/stderr de manera tradicional (sin caracteres de control).

## 6. Diseño Híbrido Efectivo

### Patrón recomendado

```powershell
# 1. Mostrar encabezado con información estática
Write-Host "╔════════════════════════════════════╗"
Write-Host "║  PROCESANDO ARCHIVO                ║"
Write-Host "╚════════════════════════════════════╝"

# 2. Ejecutar programa mostrando SU salida
Write-Host ""
Write-Host "═══ SALIDA DEL PROGRAMA ═══" -ForegroundColor Cyan
Write-Host ""

& programa.exe --argumentos  # Muestra su propia salida

Write-Host ""
Write-Host "═══ COMPLETADO ═══" -ForegroundColor Green
```

## 7. Mejores Prácticas

### ✅ DO

- Usar caracteres Unicode para cajas y barras (`█`, `░`, `═`, `║`, etc.)
- Mantener intervalos de actualización entre 150-300ms
- Guardar posición del cursor antes de bucles
- Rellenar con espacios para evitar texto residual
- Permitir que programas complejos muestren su propia salida

### ❌ DON'T

- No intentar capturar salida de programas con barras de progreso interactivas
- No actualizar demasiado rápido (<100ms) - causa parpadeo
- No asumir que eventos asincrónicos capturarán todo
- No olvidar limpiar archivos temporales
- No usar `Write-Progress` de PowerShell si quieres control fino

## 8. Ejemplo Completo

```powershell
function Invoke-ProcessWithUI {
    param(
        [string]$FilePath,
        [string]$Arguments
    )

    # Encabezado
    Write-Host ""
    Write-Host "  🎯 PROCESANDO" -ForegroundColor Green
    Write-Host "  ═══════════════════════════════════" -ForegroundColor DarkGray
    Write-Host ""

    # Ejecutar y mostrar salida directa
    $startTime = Get-Date
    & $FilePath $Arguments
    $elapsed = ((Get-Date) - $startTime).TotalSeconds

    # Resumen
    Write-Host ""
    Write-Host "  ═══════════════════════════════════" -ForegroundColor DarkGray
    Write-Host "  ✓ Completado en $([math]::Floor($elapsed))s" -ForegroundColor Green
    Write-Host ""
}
```

## 9. Recursos Útiles

- Caracteres Unicode para barras: `█ ▓ ▒ ░`
- Caracteres de caja: `╔ ╗ ╚ ╝ ║ ═ ╠ ╣`
- Spinners: `⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏`
- Emojis: `🎯 📊 ✓ ⏱️ 📝 💬 📺`

## 10. Conclusión

La lección más importante: **No sobre-ingenierizar**. Si un programa ya muestra progreso bien, déjalo hacer su trabajo. Solo captura y parsea cuando realmente lo necesites y sea factible.
