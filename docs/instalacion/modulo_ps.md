# Instalacion del Modulo PowerShell

Guia detallada para instalar y configurar el modulo whisper-transcriptor en PowerShell.

## Requisitos Previos

| Requisito | Verificacion | Instalacion |
| :--- | :--- | :--- |
| PowerShell 5.1+ | `$PSVersionTable.PSVersion` | Windows 10/11 incluye PS 5.1 |
| Python 3.8+ | `python --version` | python.org/downloads |
| FFmpeg | `ffmpeg -version` | winget install Gyan.FFmpeg |
| Whisper CLI | `whisper --version` | pip install openai-whisper |

## Metodo 1: Instalacion via Menu

### Paso 1: Habilitar Ejecucion de Scripts

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
```

### Paso 2: Ejecutar Menu Interactivo

```powershell
.\menu.ps1
```

### Paso 3: Seleccionar Opcion de Instalacion

| Opcion | Descripcion |
| :--- | :--- |
| 1 | Instalacion estandar |
| 2 | Instalacion avanzada |

## Metodo 2: Instalacion Directa

### Script de Instalacion

```powershell
# Desde la raiz del proyecto
.\src\windows\installer\install-windows.ps1
```

### Parametros Disponibles

| Parametro | Tipo | Descripcion |
| :--- | :--- | :--- |
| `-SkipPythonCheck` | switch | Omitir verificacion de Python |
| `-SkipWhisperCheck` | switch | Omitir verificacion de Whisper |
| `-Force` | switch | Sobrescribir instalacion existente |

### Ejemplos de Instalacion

```powershell
# Estandar
.\src\windows\installer\install-windows.ps1

# Sin verificaciones
.\src\windows\installer\install-windows.ps1 -SkipPythonCheck -SkipWhisperCheck

# Forzada
.\src\windows\installer\install-windows.ps1 -Force
```

## Rutas de Instalacion

### PowerShell 5.1 (Windows PowerShell)

```
C:\Users\<usuario>\Documents\WindowsPowerShell\Modules\whisper-transcriptor\
```

### PowerShell 7+ (PowerShell Core)

```
C:\Users\<usuario>\Documents\PowerShell\Modules\whisper-transcriptor\
```

## Proceso de Instalacion

### 1. Verificacion de Dependencias

El instalador verifica:

- Version de PowerShell (5.1+)
- Python instalado y en PATH
- Whisper CLI instalado
- FFmpeg instalado

### 2. Copia de Archivos

Archivos copiados al directorio de modulos:

```
whisper-transcriptor/
├── whisper-transcriptor.psm1    # Modulo principal
├── whisper-transcriptor.psd1   # Manifiesto
├── TUI-Utils.psm1             # Utilidades TUI
├── Install-WhisperTranscriptor.ps1
└── Uninstall-WhisperTranscriptor.ps1
```

### 3. Generacion de GUID

El instalador genera un nuevo GUID unico para el modulo si detecta el GUID placeholder.

### 4. Creacion de Directorios

Se crean automaticamente:

```
C:\Users\<usuario>\whisper-transcriptor\
└── inputs\                    # Directorio para videos
```

## Verificacion Post-Instalacion

```powershell
# Verificar modulo disponible
Get-Module -ListAvailable whisper-transcriptor

# Verificar comando
Get-Command Invoke-whisper-transcriptor

# Importar modulo
Import-Module whisper-transcriptor
```

## Solucion de Problemas

### El modulo no aparece

- Cerrar y abrir nueva sesion de PowerShell
- Verificar que la instalacion fue exitosa

### Comando no reconocido

```powershell
# Importar explicitamente
Import-Module whisper-transcriptor -Force

# Verificar funciones exportadas
Get-Command -Module whisper-transcriptor
```

Consulte [docs/errores/general_resolucion.md](../errores/general_resolucion.md) para mas soluciones.
