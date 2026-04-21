# Utilidades TUI

Documentacion de las utilidades de interfaz de usuario de texto (TUI).

## Introduccion

El proyecto incluye un conjunto de funciones para crear interfaces de texto atractivas en PowerShell. Estas funciones se encuentran en `TUI-Utils.psm1` y son utilizadas por el menu interactivo y el modulo de transcripcion.

## Funciones Disponibles

### Show-ProgressBar

Muestra una barra de progreso textual con porcentaje.

```powershell
Show-ProgressBar -Current 5 -Total 10 -BarWidth 40
# Resultado: [████████░░░░░░░░░░░░░░░░░░░░] 50% (5/10)
```

| Parametro | Tipo | Descripcion |
| :--- | :--- | :--- |
| `-Current` | int | Numero actual |
| `-Total` | int | Numero total |
| `-BarWidth` | int | Ancho de la barra (default: 40) |

### Show-FileProgressBar

Muestra progreso de un archivo individual.

```powershell
Show-FileProgressBar -Percent 75 -BarWidth 40
# Resultado: [████████████████████████░░░░░░░] 75%
```

### Show-SpinnerFrame

Retorna un frame de animacion de spinner.

```powershell
Show-SpinnerFrame -Frame 3
# Resultado: ⠸
```

Secuencia completa: `⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏`

### Show-ProcessingBox

Muestra una caja de estado formateada.

```powershell
Show-ProcessingBox -FileName "video.mp4" -Status "Transcribiendo" -Detail "Duracion: 01:30"
```

Produce:

```
╔════════════════════════════════════════════════════════════════╗
║  📋 ESTADO DEL PROCESO                                         ║
╠════════════════════════════════════════════════════════════════╣
║  📹 Archivo: video.mp4                                         ║
║  ⏳ Estado: Transcribiendo                                     ║
║  📝 Duracion: 01:30                                           ║
╚════════════════════════════════════════════════════════════════╝
```

## Colores Soportados

PowerShell soporta los siguientes colores:

| Color | Uso Recomendado |
| :--- | :--- |
| Black | Texto normal |
| White | Texto informativo |
| Cyan | Encabezados |
| Green | Exito |
| Yellow | Advertencias |
| Red | Errores |
| DarkGray | Texto secundario |

## Uso en Scripts

### Ejemplo: Barra de Progreso

```powershell
for ($i = 1; $i -le 10; $i++) {
    $progress = Show-ProgressBar -Current $i -Total 10
    Write-Host $progress -ForegroundColor Cyan
    Start-Sleep -Milliseconds 500
}
```

### Ejemplo: Spinner

```powershell
$frame = 0
for ($i = 0; $i -lt 20; $i++) {
    $spinner = Show-SpinnerFrame -Frame $frame
    Write-Host "`rProcesando... $spinner" -NoNewline
    Start-Sleep -Milliseconds 100
    $frame++
}
Write-Host ""
```

## Integracion con Menu

El archivo `menu.ps1` utiliza estas funciones para crear la interfaz interactiva:

```powershell
# Colores configurables
$ColorHeader = 'Cyan'
$ColorMenu = 'Yellow'
$ColorSuccess = 'Green'
$ColorWarning = 'Yellow'
$ColorError = 'Red'
$ColorInfo = 'White'
```

## Demo

Ver archivo de ejemplo:

```powershell
# Ejecutar demo de TUI
.\examples\tui-demo.ps1
```
