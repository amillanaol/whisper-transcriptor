# Configuracion de Entorno

Guide for configuring environment variables and system settings.

## Variables de Entorno del Sistema

| Variable | Descripcion | Valor por Defecto |
| :--- | :--- | :--- |
| `PATH` | Directorios ejecutables del sistema | Sistema |
| `PYTHONPATH` | Rutas de modulos Python | Vacio |
| `USERPROFILE` | Directorio del usuario | Windows |

## Configuracion de Puertos

El proyecto whisper-transcriptor no requiere configuracion de puertos ya que es una herramienta CLI que no levanta servidores.

## Rutas de Instalacion

### PowerShell 5.1 (Windows PowerShell)

```
Documents\WindowsPowerShell\Modules\whisper-transcriptor
```

### PowerShell 7+ (PowerShell Core)

```
Documents\PowerShell\Modules\whisper-transcriptor
```

## Directorios de Trabajo

| Directorio | Ruta | Proposito |
| :--- | :--- | :--- |
| Raiz | `C:\Users\<user>\whisper-transcriptor` | Directorio principal |
| Inputs | `C:\Users\<user>\whisper-transcriptor\inputs` | Archivos de video a procesar |
| Outputs | Mismo que input | Archivos SRT generados |

## Configuracion de Python

### Verificar Instalacion

```powershell
python --version
python -m pip --version
```

### Instalar Dependencias

```powershell
# Whisper CLI
python -m pip install openai-whisper

# FFmpeg (Windows)
winget install Gyan.FFmpeg
```

## Configuracion de GPU (Opcional)

Para acelerar transcripciones con GPU NVIDIA:

```powershell
# Instalar PyTorch con soporte CUDA
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124
```

Verificar con:
```powershell
nvidia-smi
```

## Permisos de Ejecucion

PowerShell restringe la ejecucion de scripts por seguridad.

### Verificar Politica Actual

```powershell
Get-ExecutionPolicy
```

### Cambiar Politica (Usuario Actual)

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Cambiar Politica (Sistema)

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine
```

Esto requiere permisos de administrador.
