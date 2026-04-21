# Funciones de Transcripcion

Referencia detallada de todas las funciones de transcripcion del modulo.

## Funcion Principal

### Invoke-whisper-transcriptor

Punto de entrada para la transcripcion de videos.

```powershell
Invoke-whisper-transcriptor [[-Directory] <string>] [[-Model] <string>] 
                            [[-Extension] <string>] [[-Device] <string>] 
                            [-Version] [-Help]
```

#### Parametros

| Parametro | Tipo | Alias | Default | Descripcion |
| :--- | :--- | :--- | :--- | :--- |
| `-Directory` | string | d | (actual) | Ruta al directorio con videos |
| `-Model` | string | m | tiny | Modelo de Whisper |
| `-Extension` | string | e | mp4 | Extension de archivos |
| `-Device` | string | dev | cpu | Dispositivo (cpu/cuda) |
| `-Version` | switch | v | - | Mostrar version |
| `-Help` | switch | h | - | Mostrar ayuda |

#### Ejemplos

```powershell
# Uso basico
wtranscriptor -d "C:\videos" -m tiny -e mp4

# Con GPU NVIDIA
wtranscriptor -d ".\inputs" -m small -dev cuda

# Ver ayuda
wtranscriptor -Help
```

## Funciones Auxiliares

### Test-VideoFileExists

Verifica si existen archivos de video en un directorio.

```powershell
Test-VideoFileExists -Path <string> -Extension <string>
```

### Test-SrtFileExists

Verifica si existen archivos SRT en un directorio.

```powershell
Test-SrtFileExists -Path <string>
```

### Get-VideoDuration

Obtiene la duracion de un video en formato legible.

```powershell
Get-VideoDuration -VideoPath <string>
# Retorna: "01:23:45" o "23:45"
```

### Get-VideoDurationSeconds

Obtiene la duracion de un video en segundos.

```powershell
Get-VideoDurationSeconds -VideoPath <string>
# Retorna: 5025 (segundos)
```

### Get-TranscriptionSpeedFactor

Calcula el factor de velocidad estimado para un modelo.

```powershell
Get-TranscriptionSpeedFactor -Model <string>
# Retorna: 0.35 (factor de velocidad)
```

| Modelo | Factor |
| :--- | :--- |
| tiny | 0.25 |
| base | 0.35 |
| small | 0.50 |
| medium | 0.80 |
| turbo | 0.20 |

## Funciones de Interfaz

### Show-ProcessingSummary

Muestra el resumen de procesamiento antes de ejecutar.

```powershell
Show-ProcessingSummary -Directory <string> -Model <string> 
                       -Extension <string> -Device <string>
```

### Show-ProcessingBox

Muestra una caja de estado con informacion del procesamiento.

```powershell
Show-ProcessingBox -FileName <string> -Status <string> -Detail <string>
```

### Show-ProgressBar

Muestra barra de progreso textual.

```powershell
Show-ProgressBar -Current <int> -Total <int> -BarWidth <int>
```

### Show-FileProgressBar

Muestra progreso de un archivo individual.

```powershell
Show-FileProgressBar -Percent <int> -BarWidth <int>
```

### Show-SpinnerFrame

Retorna un frame de animacion de spinner.

```powershell
Show-SpinnerFrame -Frame <int>
# Retorna: "⠋", "⠙", "⠹", etc.
```

## Flujo de Procesamiento

```
1. Invoke-whisper-transcriptor recibe parametros
           │
           ▼
2. Validar directorio existe
           │
           ▼
3. Show-ProcessingSummary muestra resumen
           │
           ▼
4. Usuario confirma procesamiento
           │
           ▼
5. Invoke-VideoFiles itera sobre archivos
           │
           ├── Para cada archivo:
           │   ├── Verificar SRT no existe
           │   ├── Obtener duracion
           │   ├── Ejecutar whisper CLI
           │   └── Verificar exito
           │
           ▼
6. Mostrar resumen final
```

## Codigos de Salida

| Codigo | Significado |
| :--- | :--- |
| 0 | Ejecucion exitosa |
| 1 | Error en parametros o directorio |
| >1 | Error de Whisper CLI |
