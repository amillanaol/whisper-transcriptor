# Resolucion de Errores

Guia de solucion de errores comunes en whisper-transcriptor.

## Errores de Ejecucion

### Error: Ejecucion de scripts deshabilitada

| Atributo | Valor |
| :--- | :--- |
| Sintoma | "no se puede cargar porque la ejecucion de scripts esta deshabilitada" |
| Causa Raiz | Politica de ejecucion de PowerShell es Restringida |
| Solucion Tecnica | `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process` |

### Error: Modulo no aparece despues de instalar

| Atributo | Valor |
| :--- | :--- |
| Sintoma | `Get-Module -ListAvailable whisper-transcriptor` no muestra el modulo |
| Causa Raiz | Sesion de PowerShell no actualizada |
| Solucion Tecnica | Cerrar y reabrir PowerShell, o ejecutar `$env:PSModulePath = [Environment]::GetEnvironmentVariable("PSModulePath","Machine")` |

### Error: Comando no reconocido

| Atributo | Valor |
| :--- | :--- |
| Sintoma | `wtranscriptor` o `Invoke-whisper-transcriptor` no se reconoce |
| Causa Raiz | Modulo no importado o instalado en ruta incorrecta |
| Solucion Tecnica | Importar explicitamente: `Import-Module whisper-transcriptor -Force` |

## Errores de Dependencias

### Error: Python no encontrado

| Atributo | Valor |
| :--- | :--- |
| Sintoma | "Python no esta instalado o no esta en el PATH" |
| Causa Raiz | Python no instalado o no agregado al PATH |
| Solucion Tecnica | Reinstalar Python marcando "Add Python to PATH" o verificar con `python --version` |

### Error: Whisper CLI no encontrado

| Atributo | Valor |
| :--- | :--- |
| Sintoma | "Whisper CLI no encontrado" |
| Causa Raiz | Whisper no instalado via pip |
| Solucion Tecnica | `python -m pip install openai-whisper` |

### Error: FFmpeg no encontrado

| Atributo | Valor |
| :--- | :--- |
| Sintoma | "FFmpeg no encontrado" |
| Causa Raiz | FFmpeg no instalado o no en PATH |
| Solucion Tecnica | `winget install Gyan.FFmpeg` o descargar desde ffmpeg.org |

### Error: PyTorch sin soporte CUDA

| Atributo | Valor |
| :--- | :--- |
| Sintoma | "ModuleNotFoundError: No module named 'torch'" |
| Causa Raiz | PyTorch instalado sin soporte GPU |
| Solucion Tecnica | `pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124` |

## Errores de Archivos

### Error: Caracteres corruptos en pantalla

| Atributo | Valor |
| :--- | :--- |
| Sintoma | Simbolos raros como `ð`, `â`, caracteres chinos |
| Causa Raiz | Archivos .ps1/.psm1 guardados sin BOM en PowerShell 5.1 |
| Solucion Tecnica | Guardar archivos como UTF-8 with BOM (EF BB BF) |

### Error: Directorio no existe

| Atributo | Valor |
| :--- | :--- |
| Sintoma | "El directorio especificado no existe" |
| Causa Raiz | Ruta de directorio invalida |
| Solucion Tecnica | Verificar ruta: `Test-Path "C:\ruta\directorio"` |

## Errores de Permisos

### Error: Requiere privilegios de Administrador

| Atributo | Valor |
| :--- | :--- |
| Sintoma | "Este script necesita ejecutarse como Administrador" |
| Causa Raiz | Instalacion requiere permisos elevados |
| Solucion Tecnica | Ejecutar PowerShell como Administrador |

### Error: GUID placeholder detectado

| Atributo | Valor |
| :--- | :--- |
| Sintoma | Advertencia sobre GUID placeholder en manifiesto |
| Causa Raiz | Manifiesto con GUID de ejemplo |
| Solucion Tecnica | El instalador genera automaticamente un nuevo GUID |

## Errores de Instalacion

### Error: PowerShell 5.1 vs 7 rutas

| Atributo | Valor |
| :--- | :--- |
| Sintoma | Modulo instalado en PS7 no disponible en PS5.1 |
| Causa Raiz | Rutas de modulos diferentes entre versiones |
| Solucion Tecnica | Copiar manualmente a `Documents\WindowsPowerShell\Modules\` |

### Error: make no encontrado

| Atributo | Valor |
| :--- | :--- |
| Sintoma | "make: command not found" |
| Causa Raiz | make no instalado en Windows |
| Solucion Tecnica | `scoop install make` o ejecutar directamente `.\menu.ps1` |

### Error: Python abre Microsoft Store

| Atributo | Valor |
| :--- | :--- |
| Sintoma | Ejecutar `python` abre Microsoft Store |
| Causa Raiz | Alias de Python del Store activo |
| Solucion Tecnica | Desactivar en Configuracion > Aplicaciones > Alias de ejecucion |

## Tabla Resumen Rapido

| Sintoma | Solucion Rapida |
| :--- | :--- |
| Scripts deshabilitados | `Set-ExecutionPolicy RemoteSigned -Scope Process` |
| Modulo no aparece | Cerrar y abrir PowerShell |
| Python no encontrado | Instalar Python y agregar a PATH |
| Whisper no encontrado | `pip install openai-whisper` |
| FFmpeg no encontrado | `winget install Gyan.FFmpeg` |
| Caracteres raros | Guardar archivos UTF-8 con BOM |
