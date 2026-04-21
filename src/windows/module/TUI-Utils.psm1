<#
.SYNOPSIS
    Utilidades para crear Text User Interfaces (TUI) en PowerShell

.DESCRIPTION
    Módulo con funciones reutilizables para crear interfaces de texto
    interactivas con barras de progreso, spinners, cajas y más.

.NOTES
    Basado en patrones aprendidos del proyecto whisper-transcriptor
#>

#region Barras de Progreso

<#
.SYNOPSIS
    Muestra una barra de progreso horizontal

.PARAMETER Current
    Valor actual del progreso

.PARAMETER Total
    Valor total (100%)

.PARAMETER BarLength
    Longitud de la barra en caracteres (default: 40)

.PARAMETER FilledChar
    Carácter para la parte llena (default: █)

.PARAMETER EmptyChar
    Carácter para la parte vacía (default: ░)

.EXAMPLE
    Show-ProgressBar -Current 25 -Total 100
    [██████████░░░░░░░░░░░░░░░░░░░░] 25% (25/100)
#>
function Show-ProgressBar {
    param(
        [Parameter(Mandatory)]
        [int]$Current,

        [Parameter(Mandatory)]
        [int]$Total,

        [int]$BarLength = 40,

        [string]$FilledChar = "█",

        [string]$EmptyChar = "░"
    )

    if ($Total -eq 0) { $Total = 1 }
    $percent = [math]::Min(100, [math]::Floor(($Current / $Total) * 100))
    $filled = [math]::Floor(($percent / 100) * $BarLength)
    $empty = $BarLength - $filled

    $bar = "[" + ($FilledChar * $filled) + ($EmptyChar * $empty) + "]"
    return "$bar $percent% ($Current/$Total)"
}

<#
.SYNOPSIS
    Muestra una barra de progreso basada en porcentaje

.PARAMETER Percent
    Porcentaje de progreso (0-100)

.PARAMETER BarLength
    Longitud de la barra en caracteres (default: 40)

.EXAMPLE
    Show-FileProgressBar -Percent 75
    [██████████████████████████████░░░░░░░░░░] 75%
#>
function Show-FileProgressBar {
    param(
        [Parameter(Mandatory)]
        [int]$Percent,

        [int]$BarLength = 40
    )

    $percent = [math]::Max(0, [math]::Min(100, $Percent))
    $filled = [math]::Floor(($percent / 100) * $BarLength)
    $empty = $BarLength - $filled

    $bar = "[" + ("█" * $filled) + ("░" * $empty) + "]"
    return "$bar $percent%"
}

#endregion

#region Spinners

<#
.SYNOPSIS
    Muestra un frame del spinner animado

.PARAMETER Frame
    Número de frame (se usa módulo para loop infinito)

.PARAMETER Style
    Estilo del spinner: 'dots', 'line', 'arrow', 'box'

.EXAMPLE
    $frame = 0
    while ($processing) {
        $spinner = Show-SpinnerFrame -Frame $frame
        Write-Host "  $spinner Processing..." -ForegroundColor Yellow
        $frame++
        Start-Sleep -Milliseconds 200
    }
#>
function Show-SpinnerFrame {
    param(
        [Parameter(Mandatory)]
        [int]$Frame,

        [ValidateSet('dots', 'line', 'arrow', 'box')]
        [string]$Style = 'dots'
    )

    $spinners = @{
        'dots'  = @("⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏")
        'line'  = @("-", "\\", "|", "/")
        'arrow' = @("←", "↖", "↑", "↗", "→", "↘", "↓", "↙")
        'box'   = @("◰", "◳", "◲", "◱")
    }

    $frames = $spinners[$Style]
    return $frames[$Frame % $frames.Count]
}

#endregion

#region Cajas y Bordes

<#
.SYNOPSIS
    Muestra una caja de información con título y campos

.PARAMETER Title
    Título de la caja

.PARAMETER Fields
    Hashtable con campos a mostrar (clave = valor)

.PARAMETER Width
    Ancho de la caja en caracteres (default: 64)

.EXAMPLE
    Show-InfoBox -Title "ESTADO DEL PROCESO" -Fields @{
        "Archivo" = "video.mp4"
        "Estado" = "Procesando"
        "Duración" = "05:30"
    }
#>
function Show-InfoBox {
    param(
        [Parameter(Mandatory)]
        [string]$Title,

        [Parameter(Mandatory)]
        [hashtable]$Fields,

        [int]$Width = 64
    )

    $topBorder = "╔" + ("═" * ($Width - 2)) + "╗"
    $midBorder = "╠" + ("═" * ($Width - 2)) + "╣"
    $botBorder = "╚" + ("═" * ($Width - 2)) + "╝"

    # Título
    $titlePadding = " " * ($Width - 4 - $Title.Length)
    Write-Host $topBorder -ForegroundColor Cyan
    Write-Host "║  $Title$titlePadding║" -ForegroundColor Cyan
    Write-Host $midBorder -ForegroundColor Cyan

    # Campos
    foreach ($key in $Fields.Keys) {
        $line = "$key`: $($Fields[$key])"
        $linePadding = " " * ($Width - 6 - $line.Length)
        Write-Host "║  $line$linePadding║" -ForegroundColor Cyan
    }

    Write-Host $botBorder -ForegroundColor Cyan
}

<#
.SYNOPSIS
    Muestra una caja procesando con archivo, estado y detalle

.PARAMETER FileName
    Nombre del archivo

.PARAMETER Status
    Estado actual

.PARAMETER Detail
    Detalle adicional

.EXAMPLE
    Show-ProcessingBox -FileName "video.mp4" -Status "Transcribiendo..." -Detail "Duración: 05:30"
#>
function Show-ProcessingBox {
    param(
        [Parameter(Mandatory)]
        [string]$FileName,

        [Parameter(Mandatory)]
        [string]$Status,

        [string]$Detail = ""
    )

    $width = 64
    $topBorder = "╔" + ("═" * ($width - 2)) + "╗"
    $midBorder = "╠" + ("═" * ($width - 2)) + "╣"
    $botBorder = "╚" + ("═" * ($width - 2)) + "╝"

    Write-Host $topBorder
    Write-Host "║  📋 ESTADO DEL PROCESO" + (" " * ($width - 23)) + "║"
    Write-Host $midBorder

    # Archivo
    $fileText = "📹 Archivo: $FileName"
    if ($fileText.Length -gt $width - 6) {
        $fileText = $fileText.Substring(0, $width - 9) + "..."
    }
    $filePadding = " " * ($width - 4 - $fileText.Length)
    Write-Host "║  $fileText$filePadding║"

    # Estado
    $statusText = "⏳ Estado: $Status"
    if ($statusText.Length -gt $width - 6) {
        $statusText = $statusText.Substring(0, $width - 9) + "..."
    }
    $statusPadding = " " * ($width - 4 - $statusText.Length)
    Write-Host "║  $statusText$statusPadding║"

    # Detalle
    if ($Detail) {
        $detailText = "📝 $Detail"
        if ($detailText.Length -gt $width - 6) {
            $detailText = $detailText.Substring(0, $width - 9) + "..."
        }
        $detailPadding = " " * ($width - 4 - $detailText.Length)
        Write-Host "║  $detailText$detailPadding║"
    }

    Write-Host $botBorder
}

<#
.SYNOPSIS
    Muestra un separador decorativo

.PARAMETER Width
    Ancho del separador (default: 59)

.PARAMETER Char
    Carácter a usar (default: ═)

.EXAMPLE
    Show-Separator
    ═══════════════════════════════════════════════════════════
#>
function Show-Separator {
    param(
        [int]$Width = 59,
        [string]$Char = "═"
    )

    return ($Char * $Width)
}

#endregion

#region Parseo de Progreso

<#
.SYNOPSIS
    Extrae porcentaje de progreso de una línea de texto

.PARAMETER Line
    Línea de texto a parsear

.OUTPUTS
    Porcentaje encontrado (0-100) o -1 si no se encontró

.EXAMPLE
    Get-ProgressFromLine "Processing: 75% complete"
    # Returns: 75
#>
function Get-ProgressFromLine {
    param(
        [Parameter(Mandatory)]
        [string]$Line
    )

    # Buscar porcentaje directo: "50%", "|50%", "100%|"
    if ($Line -match '(\d{1,3})%') {
        return [int]$matches[1]
    }

    # Buscar ratio: "123/456"
    if ($Line -match '(\d+)/(\d+)') {
        $current = [int]$matches[1]
        $total = [int]$matches[2]
        if ($total -gt 0) {
            return [math]::Floor(($current / $total) * 100)
        }
    }

    return -1
}

<#
.SYNOPSIS
    Extrae timestamp de una línea de formato SRT

.PARAMETER Line
    Línea de texto con timestamp SRT

.OUTPUTS
    Hashtable con horas, minutos, segundos, o $null si no se encontró

.EXAMPLE
    Get-TimestampFromSRT "00:01:23,456 --> 00:01:28,789"
    # Returns: @{ Hours = 0; Minutes = 1; Seconds = 23; TotalSeconds = 83 }
#>
function Get-TimestampFromSRT {
    param(
        [Parameter(Mandatory)]
        [string]$Line
    )

    if ($Line -match '^(\d{2}):(\d{2}):(\d{2}),\d{3}\s*-->\s*') {
        return @{
            Hours        = [int]$matches[1]
            Minutes      = [int]$matches[2]
            Seconds      = [int]$matches[3]
            TotalSeconds = ([int]$matches[1] * 3600) + ([int]$matches[2] * 60) + [int]$matches[3]
        }
    }

    return $null
}

#endregion

#region Utilidades de Pantalla

<#
.SYNOPSIS
    Actualiza una región de la pantalla sin parpadeo

.PARAMETER StartLine
    Línea donde empieza la región a actualizar

.PARAMETER ScriptBlock
    Código que dibuja el contenido

.EXAMPLE
    Update-ScreenRegion -StartLine $cursorTop -ScriptBlock {
        Write-Host "  Processing: $percent%"
        Write-Host "  Files: $current/$total"
    }
#>
function Update-ScreenRegion {
    param(
        [Parameter(Mandatory)]
        [int]$StartLine,

        [Parameter(Mandatory)]
        [scriptblock]$ScriptBlock
    )

    [Console]::SetCursorPosition(0, $StartLine)
    & $ScriptBlock
}

<#
.SYNOPSIS
    Limpia N líneas desde la posición actual del cursor

.PARAMETER LineCount
    Número de líneas a limpiar

.EXAMPLE
    Clear-Lines -LineCount 5
#>
function Clear-Lines {
    param(
        [Parameter(Mandatory)]
        [int]$LineCount
    )

    for ($i = 0; $i -lt $LineCount; $i++) {
        Write-Host (" " * [Console]::WindowWidth)
    }
}

#endregion

#region Ejecución de Procesos con UI

<#
.SYNOPSIS
    Ejecuta un programa mostrando su salida directamente con UI mejorada

.PARAMETER FilePath
    Ruta del ejecutable

.PARAMETER Arguments
    Argumentos del programa

.PARAMETER Title
    Título para mostrar

.EXAMPLE
    Invoke-ProcessWithUI -FilePath "whisper" -Arguments "video.mp4 --model base" -Title "Transcribiendo"
#>
function Invoke-ProcessWithUI {
    param(
        [Parameter(Mandatory)]
        [string]$FilePath,

        [string]$Arguments = "",

        [string]$Title = "PROCESANDO"
    )

    Write-Host ""
    Write-Host "  🎯 $Title" -ForegroundColor Green
    Write-Host "  $(Show-Separator)" -ForegroundColor DarkGray
    Write-Host ""

    $startTime = Get-Date

    if ($Arguments) {
        & $FilePath $Arguments
    }
    else {
        & $FilePath
    }

    $elapsed = ((Get-Date) - $startTime).TotalSeconds

    Write-Host ""
    Write-Host "  $(Show-Separator)" -ForegroundColor DarkGray
    Write-Host "  ✓ Completado en $([math]::Floor($elapsed))s" -ForegroundColor Green
    Write-Host ""
}

#endregion

# Exportar funciones
Export-ModuleMember -Function @(
    'Show-ProgressBar',
    'Show-FileProgressBar',
    'Show-SpinnerFrame',
    'Show-InfoBox',
    'Show-ProcessingBox',
    'Show-Separator',
    'Get-ProgressFromLine',
    'Get-TimestampFromSRT',
    'Update-ScreenRegion',
    'Clear-Lines',
    'Invoke-ProcessWithUI'
)
