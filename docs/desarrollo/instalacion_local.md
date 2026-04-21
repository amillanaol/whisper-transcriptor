# Instalacion Local

Guia completa para instalar y configurar whisper-transcriptor en el entorno local.

## Requisitos del Sistema

| Componente | Version Minima | Notas |
| :--- | :--- | :--- |
| Windows | 10/11 (64-bit) | Requiere PowerShell 5.1+ |
| PowerShell | 5.1 | Incluido en Windows 10/11 |
| Python | 3.8+ | Necesario para Whisper CLI |
| FFmpeg | 5.x | Procesamiento de audio/video |
| Whisper CLI | Latest | `pip install openai-whisper` |

## Metodo 1: Menu Interactivo (Recomendado)

El metodo mas sencillo para usuarios nuevos.

### Pasos

```powershell
# 1. Habilitar ejecucion de scripts (solo primera vez)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process

# 2. Ejecutar menu interactivo desde la raiz del proyecto
.\menu.ps1

# 3. Seleccionar opcion [1] para instalar
```

### Opciones del Menu

| Opcion | Descripcion |
| :--- | :--- |
| 1 | Instalacion estandar |
| 2 | Instalacion avanzada con parametros |
| 3 | Verificar instalacion actual |
| 4 | Usar modulo de transcripcion |
| 5 | Ver documentacion |
| 6 | Desinstalar |

## Metodo 2: Instalacion Directa

Para usuarios avanzados que prefieren control total.

### Instalacion Estandar

```powershell
# Ejecutar como Administrador
.\src\windows\installer\install-windows.ps1
```

### Instalacion con Parametros

| Parametro | Descripcion |
| :--- | :--- |
| `-SkipPythonCheck` | Omite validacion de Python |
| `-SkipWhisperCheck` | Omite validacion de Whisper CLI |
| `-Force` | Sobrescribe instalacion existente |

```powershell
# Ejemplo: instalacion forzada sin verificaciones
.\src\windows\installer\install-windows.ps1 -SkipPythonCheck -SkipWhisperCheck -Force
```

## Verificacion de Instalacion

Despues de instalar, verificar con:

```powershell
# Verificar modulo instalado
Get-Module -ListAvailable whisper-transcriptor

# Verificar comando disponible
Get-Command Invoke-whisper-transcriptor

# Verificar dependencias
python --version
ffmpeg -version
whisper --version
```

## Uso Basico

```powershell
# Usar alias corto
wtranscriptor -d "C:\videos" -m tiny -e mp4

# O usar el comando completo
Invoke-whisper-transcriptor -Directory "C:\videos" -Model "tiny" -Extension "mp4"
```

## Parametros de Transcripcion

| Parametro | Alias | Default | Descripcion |
| :--- | :--- | :--- | :--- |
| `-Directory` | `-d` | Directorio actual | Ruta a archivos de video |
| `-Model` | `-m` | tiny | Modelo Whisper (tiny/base/small/medium/turbo) |
| `-Extension` | `-e` | mp4 | Extension de archivos (mp4/mkv/webm) |
| `-Device` | `-dev` | cpu | Dispositivo (cpu/cuda) |

## Modelos Disponibles

| Modelo | Velocidad | Precision | Uso Recomendado |
| :--- | :--- | :--- | :--- |
| tiny | Muy rapida | Baja | Pruebas |
| base | Rapida | Media | Uso general |
| small | Balanceada | Buena | Produccion |
| medium | Lenta | Alta | Precision maxima |
| turbo | Optimizada | Media-Alta | Velocidad prioritaria |

## Solucion de Problemas

Si la instalacion falla, consulta [docs/errores/general_resolucion.md](../errores/general_resolucion.md) para errores comunes.
