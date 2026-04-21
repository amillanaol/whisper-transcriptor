# --- CODIFICACIÓN UTF-8 (necesario para Windows 10) ---
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# Variable para almacenar la versión del módulo
$script:Version = "1.2.3"

function Test-CudaAvailable {
    try {
        $result = python -c "import torch; print(torch.cuda.is_available())" 2>&1
        return ($result -eq "True")
    }
    catch {
        return $false
    }
}

$script:CudaAvailable = Test-CudaAvailable

function Get-VideoDuration {
    param (
        [string]$VideoPath
    )

    try {
        # Usar ffprobe para obtener la duración (redirigir stderr a null)
        $output = & ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$VideoPath" 2>&1 | Where-Object { $_ -is [string] }
        $durationSeconds = $output | Select-Object -First 1

        if ($durationSeconds -and $durationSeconds -match '^\d+\.?\d*$') {
            $seconds = [math]::Floor([double]$durationSeconds)
            $hours = [math]::Floor($seconds / 3600)
            $minutes = [math]::Floor(($seconds % 3600) / 60)
            $secs = $seconds % 60

            if ($hours -gt 0) {
                return $hours.ToString("00") + ":" + $minutes.ToString("00") + ":" + $secs.ToString("00")
            } else {
                return $minutes.ToString("00") + ":" + $secs.ToString("00")
            }
        } else {
            return "Desconocida"
        }
    }
    catch {
        return "Desconocida"
    }
}

function Get-VideoDurationSeconds {
    param (
        [string]$VideoPath
    )

    try {
        $output = & ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$VideoPath" 2>&1 | Where-Object { $_ -is [string] }
        $durationSeconds = $output | Select-Object -First 1

        if ($durationSeconds -and $durationSeconds -match '^\d+\.?\d*$') {
            return [double]$durationSeconds
        } else {
            return 0
        }
    }
    catch {
        return 0
    }
}

function Get-TranscriptionSpeedFactor {
    param (
        [string]$Model
    )
    
    # Factor de velocidad: tiempo de transcripción / duración del video
    # Valores aproximados basados en el rendimiento típico de cada modelo
    switch ($Model.ToLower()) {
        "tiny" { return 0.25 }
        "base" { return 0.35 }
        "small" { return 0.50 }
        "medium" { return 0.80 }
        "turbo" { return 0.20 }
        default { return 0.35 }
    }
}

function Show-ProcessingSummary {
    param (
        [string]$Directory,
        [string]$Model,
        [string]$Extension,
        [string]$Device = "cpu"
    )

    # Limpiar la consola para una mejor experiencia visual
    Clear-Host

    # Obtener archivos de video (sin recurse para evitar subcarpetas)
    $videoFiles = Get-ChildItem -Path $Directory -Filter "*.$Extension" -ErrorAction SilentlyContinue

    if ($videoFiles.Count -eq 0) {
        Write-Host ""
        Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Red
        Write-Host "║                    NO SE ENCONTRARON ARCHIVOS                  ║" -ForegroundColor Red
        Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Red
        Write-Host ""
        Write-Host "  No se encontraron archivos .$Extension en: $Directory" -ForegroundColor Yellow
        Write-Host ""
        return [PSCustomObject]@{ Proceed = $false; Device = $Device }
    }

    # Clasificar archivos
    $filesToProcess = @()
    $filesWithSrt = @()

    foreach ($videoFile in $videoFiles) {
        $srtFile = Join-Path -Path $videoFile.DirectoryName -ChildPath ($videoFile.BaseName + ".srt")
        if (Test-Path -Path $srtFile) {
            $filesWithSrt += $videoFile
        } else {
            $filesToProcess += $videoFile
        }
    }

    # Mostrar resumen
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║            WHISPER TRASCRIPTOR - RESUMEN DE OPERACIÓN           ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""

    # Configuración
    Write-Host "  📋 CONFIGURACIÓN:" -ForegroundColor Yellow
    Write-Host "  ─────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host "    📁 Directorio    : " -NoNewline -ForegroundColor White
    Write-Host "$Directory" -ForegroundColor Cyan
    Write-Host "    🤖 Modelo Whisper: " -NoNewline -ForegroundColor White
    Write-Host "$Model" -ForegroundColor Cyan
    Write-Host "    🎬 Extensión     : " -NoNewline -ForegroundColor White
    Write-Host "*.$Extension" -ForegroundColor Cyan
    Write-Host "    ⚡ Dispositivo   : " -NoNewline -ForegroundColor White
    $deviceColor = if ($Device -eq 'cuda') { 'Green' } else { 'Cyan' }
    $deviceLabel = if ($Device -eq 'cuda') { 'cuda (GPU)' } else { 'cpu' }
    Write-Host "$deviceLabel" -ForegroundColor $deviceColor
    Write-Host ""

    # Estadísticas
    Write-Host "  📊 ESTADÍSTICAS:" -ForegroundColor Yellow
    Write-Host "  ─────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host "    📦 Total de archivos encontrados: " -NoNewline -ForegroundColor White
    Write-Host "$($videoFiles.Count)" -ForegroundColor Cyan
    Write-Host "    ✅ Ya tienen subtítulos (.srt)  : " -NoNewline -ForegroundColor White
    Write-Host "$($filesWithSrt.Count)" -ForegroundColor Green
    Write-Host "    ⏳ Se procesarán                : " -NoNewline -ForegroundColor White
    Write-Host "$($filesToProcess.Count)" -ForegroundColor Yellow
    Write-Host ""

    # Archivos a procesar
    if ($filesToProcess.Count -gt 0) {
        Write-Host "  🎯 ARCHIVOS A PROCESAR:" -ForegroundColor Yellow
        Write-Host "  ─────────────────────────────────────────────────────────────" -ForegroundColor DarkGray

        $maxDisplay = 10
        $filesToShow = $filesToProcess
        $hasMore = $false

        if ($filesToProcess.Count -gt $maxDisplay) {
            $filesToShow = $filesToProcess | Select-Object -First $maxDisplay
            $hasMore = $true
        }

        $index = 1
        foreach ($file in $filesToShow) {
            $sizeInMB = [math]::Round($file.Length / 1MB, 2)
            Write-Host "    [$index] " -NoNewline -ForegroundColor DarkGray
            Write-Host "$($file.Name)" -NoNewline -ForegroundColor White
            Write-Host " ($sizeInMB MB)" -ForegroundColor DarkGray
            $index++
        }

        if ($hasMore) {
            $remaining = $filesToProcess.Count - $maxDisplay
            Write-Host "    " -NoNewline
            Write-Host "... y $remaining archivo(s) más" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "    💡 " -NoNewline -ForegroundColor Cyan
            Write-Host "Mostrando primeros $maxDisplay de $($filesToProcess.Count) archivos" -ForegroundColor DarkGray
        }

        Write-Host ""
    }

    # Archivos omitidos
    if ($filesWithSrt.Count -gt 0) {
        Write-Host "  ⏭️  ARCHIVOS OMITIDOS (ya tienen .srt):" -ForegroundColor Yellow
        Write-Host "  ─────────────────────────────────────────────────────────────" -ForegroundColor DarkGray

        $maxDisplaySkipped = 5
        $filesToShow = $filesWithSrt
        $hasMore = $false

        if ($filesWithSrt.Count -gt $maxDisplaySkipped) {
            $filesToShow = $filesWithSrt | Select-Object -First $maxDisplaySkipped
            $hasMore = $true
        }

        foreach ($file in $filesToShow) {
            Write-Host "    • " -NoNewline -ForegroundColor DarkGray
            Write-Host "$($file.Name)" -ForegroundColor DarkGray
        }

        if ($hasMore) {
            $remaining = $filesWithSrt.Count - $maxDisplaySkipped
            Write-Host "    • " -NoNewline -ForegroundColor DarkGray
            Write-Host "... y $remaining archivo(s) más omitidos" -ForegroundColor DarkGray
        }

        Write-Host ""
    }

    # Si no hay archivos para procesar
    if ($filesToProcess.Count -eq 0) {
        Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
        Write-Host "║              TODOS LOS ARCHIVOS YA ESTÁN PROCESADOS            ║" -ForegroundColor Green
        Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
        Write-Host ""
        return [PSCustomObject]@{ Proceed = $false; Device = $Device }
    }

    # Selección de dispositivo (solo si CUDA está disponible)
    $selectedDevice = $Device
    if ($script:CudaAvailable) {
        Write-Host "  ─────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
        Write-Host ""
        Write-Host "  ⚡ Dispositivo de procesamiento:" -ForegroundColor Yellow
        Write-Host "    [1] cpu  - Procesamiento estándar (CPU)" -ForegroundColor White
        Write-Host "    [2] cuda - GPU acelerado (NVIDIA CUDA)" -ForegroundColor White
        Write-Host ""
        $defaultLabel = if ($Device -eq 'cuda') { '2' } else { '1' }
        Write-Host "  Selecciona (1-2, Enter para " -NoNewline -ForegroundColor Yellow
        Write-Host "$Device" -NoNewline -ForegroundColor Cyan
        Write-Host "): " -NoNewline -ForegroundColor Yellow
        $deviceChoice = Read-Host

        $selectedDevice = switch ($deviceChoice) {
            '1' { 'cpu' }
            '2' { 'cuda' }
            default { $Device }
        }
    }

    # siempre preguntar directorio de salida (útil para archivos individuales)
    Write-Host ""
    Write-Host "  📂 DIRECTORIO DE SALIDA:" -ForegroundColor Yellow
    if ($filesToProcess.Count -eq 1) {
        Write-Host "    Los subtítulos se guardarán en: " -NoNewline -ForegroundColor White
        Write-Host "$($filesToProcess[0].DirectoryName)" -ForegroundColor Cyan
    } else {
        Write-Host "    Los subtítulos se guardarán junto a los videos" -ForegroundColor Cyan
    }
    Write-Host ""
    Write-Host "  Escribe la ruta (o ENTER para usar el directorio por defecto): " -NoNewline -ForegroundColor Yellow
    $outputDirInput = Read-Host

    if ($outputDirInput.Trim() -ne '') {
        $script:CustomOutputDirectory = $outputDirInput.Trim()
    } else {
        $script:CustomOutputDirectory = $null
    }

    # Confirmación
    Write-Host ""
    Write-Host "  ─────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  ¿Deseas continuar con el procesamiento? " -NoNewline -ForegroundColor Yellow
    Write-Host "[S/n]: " -NoNewline -ForegroundColor Cyan
    $confirmation = Read-Host

    if ($confirmation -eq '' -or $confirmation -eq 'S' -or $confirmation -eq 's' -or $confirmation -eq 'Y' -or $confirmation -eq 'y') {
        # Limpiar consola antes de comenzar el procesamiento
        Clear-Host
        Write-Host ""
        Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
        Write-Host "║                  INICIANDO PROCESAMIENTO...                    ║" -ForegroundColor Green
        Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
        Write-Host ""
        $customOutputDir = $script:CustomOutputDirectory
        $script:CustomOutputDirectory = $null
        return [PSCustomObject]@{ Proceed = $true; Device = $selectedDevice; OutputDirectory = $customOutputDir }
    } else {
        Write-Host ""
        Write-Host "╔════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Red
        Write-Host "║                  OPERACIÓN CANCELADA POR EL USUARIO            ║" -ForegroundColor Red
        Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Red
        Write-Host ""
        return [PSCustomObject]@{ Proceed = $false; Device = $selectedDevice; OutputDirectory = $null }
    }
}

function Invoke-whisper-transcriptor {
    param (
        [Parameter(Mandatory=$false,Position=0)]
        [Alias("d")]
        [string]$Directory = (Get-Location).Path,

        [Parameter(Mandatory=$false,Position=1)]
        [Alias("m")]
        [ValidateSet("base", "tiny", "small", "medium", "turbo")]
        [string]$Model = "tiny",

        [Parameter(Mandatory=$false,Position=2)]
        [Alias("e")]
        [ValidateSet("mp4", "mkv", "webm", "avi", "mov")]
        [string]$Extension = "mp4",

        [Parameter(Mandatory=$false)]
        [Alias("dev")]
        [ValidateSet("cpu", "cuda")]
        [string]$Device = $(if ($script:CudaAvailable) { "cuda" } else { "cpu" }),

        [Parameter(Mandatory=$false)]
        [Alias("o")]
        [string]$OutputDirectory,

        [Parameter(Mandatory=$false)]
        [Alias("v")]
        [switch]$Version,

        [Parameter(Mandatory=$false)]
        [switch]$Help
    )

    # Limpiar la consola al inicio para mejor experiencia visual
    Clear-Host

    if ($Version) {
        Write-Host "whisper-transcriptor versión $script:Version"
        return
    }

    if ($Help) {
        Write-Host "Uso: Invoke-whisper-transcriptor [-Directory|-d <ruta>] [-Model|-m <modelo>] [-Extension|-e <extensión>] [-Version|-v] [-Help]"
        Write-Host ""
        Write-Host "Descripción:"
        Write-Host "    Este comando procesa archivos de video en un directorio y genera subtítulos SRT usando Whisper."
        Write-Host ""
        Write-Host "Parámetros:"
        Write-Host "    -Directory, -d    Ruta al directorio que contiene los archivos de video"
        Write-Host "                     (por defecto: directorio actual)"
        Write-Host "    -Model, -m       Modelo de Whisper a utilizar"
        Write-Host "                     Valores permitidos: base, tiny, small, medium, turbo"
        Write-Host "                     (por defecto: tiny)"
        Write-Host "    -Extension, -e   Extensión de los archivos a procesar"
        Write-Host "                     Valores permitidos: mp4, mkv, webm"
        Write-Host "                     (por defecto: mp4)"
        Write-Host "    -Device, -dev    Dispositivo de procesamiento"
        Write-Host "                     Valores permitidos: cpu, cuda"
        Write-Host "                     (por defecto: auto-detectado)"
        Write-Host "    -OutputDirectory, -o Directorio donde guardar los archivos SRT"
        Write-Host "                     (por defecto: mismo directorio del video)"
        Write-Host "    -Version, -v     Muestra la versión actual del módulo"
        Write-Host "    -Help            Muestra este mensaje de ayuda"
        Write-Host ""
        Write-Host "Ejemplo:"
        Write-Host "    Invoke-whisper-transcriptor -Directory '.\inputs' -e 'mp4' -Model 'tiny'"
        return
    }

    if (-not (Test-Path -Path $Directory)) {
        Write-Host ""
        Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Red
        Write-Host "║                         ERROR                                  ║" -ForegroundColor Red
        Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Red
        Write-Host ""
        Write-Host "  El directorio especificado no existe: $Directory" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "  Use -Help para ver las instrucciones de uso" -ForegroundColor Cyan
        Write-Host ""
        return 1
    }

    $item = Get-Item -Path $Directory -ErrorAction SilentlyContinue
    if ($item -and -not $item.PSIsContainer) {
        $detectedExtension = $item.Extension.TrimStart(".").ToLower()
        if ($Extension -ne $detectedExtension) {
            $Extension = $detectedExtension
        }
        $Directory = $item.DirectoryName
    }

    # Mostrar resumen y pedir confirmación
    $result = Show-ProcessingSummary -Directory $Directory -Model $Model -Extension $Extension -Device $Device

    if (-not $result.Proceed) {
        return 0
    }

    # Procesar archivos con el dispositivo elegido en el diálogo
    Invoke-VideoFiles -Path $Directory -Extension $Extension -Model $Model -Device $result.Device -OutputDirectory $result.OutputDirectory
}

function Test-VideoFileExists {
    param (
        [string]$Path,
        [string]$Extension
    )
    $videoFiles = Get-ChildItem -Path $Path -Recurse -Filter "*.$Extension" -ErrorAction SilentlyContinue
    return $videoFiles.Count -gt 0
}

function Test-SrtFileExists {
    param (
        [string]$Path
    )
    $srtFiles = Get-ChildItem -Path $Path -Recurse -Filter *.srt -ErrorAction SilentlyContinue
    return $srtFiles.Count -gt 0
}

function Show-ProgressBar {
    param (
        [int]$Current,
        [int]$Total,
        [int]$BarWidth = 40
    )
    
    $percent = [math]::Floor(($Current / $Total) * 100)
    $filled = [math]::Floor(($Current / $Total) * $BarWidth)
    $empty = $BarWidth - $filled
    
    $bar = "█" * $filled + "░" * $empty
    
    return "[$bar] $percent% ($Current/$Total)"
}

function Show-FileProgressBar {
    param (
        [int]$Percent,
        [int]$BarWidth = 40
    )
    
    $filled = [math]::Floor(($Percent / 100) * $BarWidth)
    $empty = $BarWidth - $filled
    
    $bar = "█" * $filled + "░" * $empty
    
    return "[$bar] $Percent%"
}

function Show-SpinnerFrame {
    param (
        [int]$Frame
    )
    $spinner = @('⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏')
    return $spinner[$Frame % $spinner.Length]
}

function Show-ProcessingBox {
    param (
        [string]$FileName,
        [string]$Status,
        [string]$Detail
    )
    
    Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║  📋 ESTADO DEL PROCESO                                         ║" -ForegroundColor Cyan
    Write-Host "╠════════════════════════════════════════════════════════════════╣" -ForegroundColor Cyan
    
    # Línea 1: Archivo
    $line1 = "║  📹 Archivo: $FileName"
    $padding1 = " " * (63 - $line1.Length)
    if ($line1.Length -gt 63) {
        $line1 = $line1.Substring(0, 60) + "..."
        $padding1 = ""
    }
    Write-Host "$line1$padding1║" -ForegroundColor White
    
    # Línea 2: Estado
    $line2 = "║  ⏳ Estado: $Status"
    $padding2 = " " * (63 - $line2.Length)
    Write-Host "$line2$padding2║" -ForegroundColor Yellow
    
    # Línea 3: Detalle
    $line3 = "║  📝 $Detail"
    $padding3 = " " * (63 - $line3.Length)
    if ($line3.Length -gt 63) {
        $line3 = $line3.Substring(0, 60) + "..."
        $padding3 = ""
    }
    Write-Host "$line3$padding3║" -ForegroundColor Cyan
    
    Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
}

function Invoke-VideoFiles {
    param (
        [string]$Path,
        [string]$Extension,
        [string]$Model,
        [string]$Device = "cpu",
        [string]$OutputDirectory
    )

    $videoFiles = Get-ChildItem -Path $Path -Recurse -Filter "*.$Extension" -ErrorAction SilentlyContinue
    $processedCount = 0
    $skippedCount = 0
    $failedCount = 0
    $totalToProcess = 0

    # Contar archivos a procesar
    foreach ($videoFile in $videoFiles) {
        if ([string]::IsNullOrWhiteSpace($OutputDirectory)) {
            $srtFile = Join-Path -Path $videoFile.DirectoryName -ChildPath ($videoFile.BaseName + ".srt")
        } else {
            $srtFile = Join-Path -Path $OutputDirectory -ChildPath ($videoFile.BaseName + ".srt")
        }
        if (-not (Test-Path -Path $srtFile)) {
            $totalToProcess++
        }
    }

    foreach ($videoFile in $videoFiles) {
        if ([string]::IsNullOrWhiteSpace($OutputDirectory)) {
            $srtFile = Join-Path -Path $videoFile.DirectoryName -ChildPath ($videoFile.BaseName + ".srt")
        } else {
            $srtFile = Join-Path -Path $OutputDirectory -ChildPath ($videoFile.BaseName + ".srt")
        }

        if (-not (Test-Path -Path $srtFile)) {
            $processedCount++

            # Limpiar consola antes de cada procesamiento
            Clear-Host

            # Obtener duración del video
            $duration = Get-VideoDuration -VideoPath $videoFile.FullName
            $durationSeconds = Get-VideoDurationSeconds -VideoPath $videoFile.FullName
            $sizeInMB = [math]::Round($videoFile.Length / 1MB, 2)

            # Calcular tiempo estimado de transcripción
            $speedFactor = Get-TranscriptionSpeedFactor -Model $Model
            $estimatedTranscriptionTime = $durationSeconds * $speedFactor
            
            # Mostrar barra de progreso general (aún no ha terminado este archivo)
            Write-Host ""
            Write-Host "  🎯 PROGRESO GENERAL" -ForegroundColor Green
            Write-Host "  $(Show-ProgressBar -Current ($processedCount - 1) -Total $totalToProcess)" -ForegroundColor Cyan
            Write-Host ""

            # Mostrar caja de 3 líneas con información del proceso
            $deviceInfo = if ($Device -eq 'cuda') { " [⚡ CUDA]" } else { "" }
            $statusText = "Transcribiendo con modelo '$Model'$deviceInfo..."
            $detailText = "Duración: $duration | Tamaño: $sizeInMB MB"
            Show-ProcessingBox -FileName $videoFile.Name -Status $statusText -Detail $detailText

            Write-Host ""
            Write-Host "  ═══════════════════════════════════════════════════════════" -ForegroundColor DarkGray
            Write-Host "  📺 WHISPER EJECUTÁNDOSE (salida en tiempo real):" -ForegroundColor Cyan
            Write-Host "  ═══════════════════════════════════════════════════════════" -ForegroundColor DarkGray
            Write-Host ""

            # Ejecutar Whisper sin ocultar - mostrará su salida directamente
            $startTime = Get-Date
            & whisper "$($videoFile.FullName)" --fp16=False --language Spanish --model $Model --output_format srt --output_dir "$($videoFile.DirectoryName)" --device $Device
            $whisperExitCode = $LASTEXITCODE
            $elapsedTime = ((Get-Date) - $startTime).TotalSeconds

            Write-Host ""
            Write-Host "  ═══════════════════════════════════════════════════════════" -ForegroundColor DarkGray

            # Verificar si whisper falló
            if ($whisperExitCode -ne 0) {
                $failedCount++
                $processedCount--
                Write-Host "  ✗ Whisper terminó con error (código: $whisperExitCode)" -ForegroundColor Red
                Write-Host "  ═══════════════════════════════════════════════════════════" -ForegroundColor DarkGray
                Write-Host ""
                Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Red
                Write-Host "║                    ERROR AL PROCESAR ARCHIVO                   ║" -ForegroundColor Red
                Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Red
                Write-Host ""
                Write-Host "  Archivo : $($videoFile.Name)" -ForegroundColor Yellow
                Write-Host "  Código  : $whisperExitCode" -ForegroundColor Yellow
                Write-Host ""
                Write-Host "  El traceback de Python se muestra más arriba." -ForegroundColor White
                Write-Host "  Desplaza la pantalla hacia arriba para verlo completo." -ForegroundColor DarkGray
                Write-Host ""
                Read-Host "  Presiona ENTER para continuar con el siguiente archivo"
                continue
            }

            Write-Host "  ✓ Completado en $([math]::Floor($elapsedTime)) segundos" -ForegroundColor Green
            Write-Host "  ═══════════════════════════════════════════════════════════" -ForegroundColor DarkGray
            Write-Host ""

            # Limpiar y mostrar completado
            Clear-Host
            Write-Host ""
            Write-Host "  🎯 PROGRESO GENERAL" -ForegroundColor Green
            Write-Host "  $(Show-ProgressBar -Current $processedCount -Total $totalToProcess)" -ForegroundColor Cyan
            Write-Host ""

            Show-ProcessingBox -FileName $videoFile.Name -Status "✅ Completado" -Detail "Subtítulos generados correctamente"

            Write-Host ""
            Write-Host "  💾 Guardado en: $($videoFile.DirectoryName)" -ForegroundColor Green
            Write-Host ""

            # Pequeña pausa para que el usuario vea el resultado
            if ($processedCount -lt $totalToProcess) {
                Write-Host "  Continuando con el siguiente archivo..." -ForegroundColor DarkGray
                Start-Sleep -Milliseconds 800
            }
        } else {
            # Solo contar, no mostrar
            $skippedCount++
        }
    }

    # Resumen final
    Write-Host ""
    $summaryColor = if ($failedCount -gt 0) { 'Yellow' } else { 'Green' }
    Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor $summaryColor
    Write-Host "║              PROCESAMIENTO COMPLETADO                          ║" -ForegroundColor $summaryColor
    Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor $summaryColor
    Write-Host ""
    Write-Host "  📊 Procesados correctamente: " -NoNewline -ForegroundColor White
    Write-Host "$processedCount de $totalToProcess" -ForegroundColor Cyan

    if ($failedCount -gt 0) {
        Write-Host "  ✗  Con errores            : " -NoNewline -ForegroundColor White
        Write-Host "$failedCount" -ForegroundColor Red
    }

    if ($skippedCount -gt 0) {
        Write-Host "  ⏭️  Omitidos (ya tenían .srt): " -NoNewline -ForegroundColor White
        Write-Host "$skippedCount" -ForegroundColor DarkGray
    }

    Write-Host ""
}

# Crear alias para la función principal
New-Alias -Name wtranscriptor -Value Invoke-whisper-transcriptor

# Exportar la función principal y el alias
Export-ModuleMember -Function Invoke-whisper-transcriptor -Alias wtranscriptor
