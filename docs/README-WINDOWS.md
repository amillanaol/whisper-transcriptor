| Necesidad del Usuario | Ubicación |
| :--- | :--- |
| Instalación completa del sistema | `src/windows/installer/install-windows.ps1` |
| Desinstalación del sistema | `src/windows/installer/uninstall-windows.ps1` |
| Interfaz de menú interactivo | `menu.ps1` |
| Instalación del módulo PowerShell | `src/windows/module/Install-whisper-transcriptor.ps1` |
| Función de transcripción | `src/windows/module/whisper-transcriptor.psm1` |
| Manifiesto del módulo | `src/windows/module/whisper-transcriptor.psd1` |
| Desinstalación del módulo | `src/windows/module/Uninstall-whisper-transcriptor.ps1` |
| Documentación técnica | `docs/arquitectura/modulo_descripcion.md` |

## Requisitos del Sistema

| Componente | Versión Mínima | Ubicación de Instalación |
| :--- | :--- | :--- |
| Windows | 10/11 (64-bit) | `C:\Windows\System32` |
| PowerShell | 5.1 | `$PSHOME` |
| Python | 3.8+ | `C:\Users\<user>\AppData\Local\Programs\Python` |
| FFmpeg | N/A | PATH del sistema |
| Whisper CLI | N/A | `pip install openai-whisper` |

## Instalación

### Método 1: Menú Interactivo (Recomendado)

| Paso | Comando | Requiere Admin |
| :--- | :--- | :--- |
| 1 | `Set-ExecutionPolicy RemoteSigned -Scope Process` | No |
| 2 | `cd <ruta-repositorio>` | No |
| 3 | `.\menu.ps1` | Sí |

### Método 2: Instalación Directa

| Escenario | Comando |
| :--- | :--- |
| Instalación estándar | `src/windows/installer/install-windows.ps1` |
| Instalación forzada | `src/windows/installer/install-windows.ps1 -Force` |
| Sin verificar Python | `src/windows/installer/install-windows.ps1 -SkipPythonCheck` |
| Sin verificar Whisper | `src/windows/installer/install-windows.ps1 -SkipWhisperCheck` |
| Todas las opciones | `src/windows/installer/install-windows.ps1 -SkipPythonCheck -SkipWhisperCheck -Force` |

### Parámetros de Instalación

| Parámetro | Tipo | Descripción |
| :--- | :--- | :--- |
| `-SkipPythonCheck` | Switch | Omite validación de Python en el sistema |
| `-SkipWhisperCheck` | Switch | Omite validación de Whisper CLI |
| `-Force` | Switch | Sobrescribe instalación existente sin confirmación |

## Estructura del Proyecto

```
whisper-transcriptor/
├── menu.ps1                              # Punto de entrada principal
├── src/
│   └── windows/
│       ├── installer/
│       │   ├── install-windows.ps1       # Instalador con verificaciones
│       │   └── uninstall-windows.ps1     # Desinstalador del sistema
│       └── module/
│           ├── Install-whisper-transcriptor.ps1
│           ├── Uninstall-whisper-transcriptor.ps1
│           ├── whisper-transcriptor.psd1    # ModuleVersion: 1.2.1
│           ├── whisper-transcriptor.psm1
│           └── Descripcion.md              # Movido a docs/arquitectura/
└── .agents/skills/technical-writer/
    └── SKILL.md                          # Protocolo de documentación
```

## Funciones del Módulo

| Función | Descripción | Parámetros Principales |
| :--- | :--- | :--- |
| `Invoke-whisper-transcriptor` | Punto de entrada para transcripción | `-Directory`, `-Model`, `-Extension` |
| `Test-VideoFileExists` | Valida existencia de archivos de video | `$Path`, `$Extension` |
| `Test-SrtFileExists` | Verifica archivos SRT previos | `$Path` |
| `Invoke-VideoFiles` | Procesa videos y genera subtítulos | `$Path`, `$Extension` |

### Parámetros de `Invoke-whisper-transcriptor`

| Parámetro | Alias | Valor por Defecto | Opciones Válidas |
| :--- | :--- | :--- | :--- |
| `-Directory` | `-d` | directorio actual | Cualquier ruta accesible |
| `-Model` | `-m` | `tiny` | `tiny`, `base`, `small`, `medium`, `turbo` |
| `-Extension` | `-e` | `mp4` | `mp4`, `mkv`, `webm` |
| `-Device` | `-dev` | `cpu` | `cpu`, `cuda` |

### Alias Disponibles

| Alias | Función Base | Descripción |
| :--- | :--- | :--- |
| `wtranscriptor` | `Invoke-whisper-transcriptor` | Comando corto para ejecución |

## Desinstalación

| Método | Comando | Elimina Datos de Usuario |
| :--- | :--- | :--- |
| Estándar | `src/windows/installer/uninstall-windows.ps1` | No |
| Completa | `src/windows/installer/uninstall-windows.ps1 -RemoveData` | Sí |
| Forzada | `src/windows/installer/uninstall-windows.ps1 -Force` | No |
| Completa Forzada | `src/windows/installer/uninstall-windows.ps1 -RemoveData -Force` | Sí |

## Rutas de Instalación

| Componente | Ruta (PowerShell 5.1) | Ruta (PowerShell 7+) |
| :--- | :--- | :--- |
| Módulo PowerShell | `Documents\WindowsPowerShell\Modules\whisper-transcriptor` | `Documents\PowerShell\Modules\whisper-transcriptor` |
| Directorio de trabajo | `C:\Users\<user>\whisper-transcriptor` | `C:\Users\<user>\whisper-transcriptor` |
| Directorio de inputs | `C:\Users\<user>\whisper-transcriptor\inputs` | `C:\Users\<user>\whisper-transcriptor\inputs` |
| Manifiesto del módulo | `<ModulePath>\whisper-transcriptor.psd1` | `<ModulePath>\whisper-transcriptor.psd1` |

> El instalador detecta automáticamente la versión de PowerShell en ejecución y usa la ruta correcta.

## Aceleración GPU (CUDA)

Whisper puede usar la GPU NVIDIA para acelerar significativamente la transcripción.

### Requisitos

| Requisito | Descripción |
| :--- | :--- |
| GPU NVIDIA | Con soporte CUDA (serie GTX 10xx o superior) |
| Drivers NVIDIA | Actualizados (incluyen CUDA runtime) |
| PyTorch con CUDA | Instalación específica requerida (ver abajo) |

### Instalación de PyTorch con soporte CUDA

La instalación estándar de `openai-whisper` incluye PyTorch sin soporte CUDA. Para habilitarlo hay que reinstalarlo con el índice oficial de PyTorch:

| Versión CUDA | Comando de instalación |
| :--- | :--- |
| CUDA 12.4 (recomendado) | `pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124` |
| CUDA 11.8 | `pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118` |

> Para verificar qué versión de CUDA tiene el equipo: `nvidia-smi` (columna "CUDA Version" en la esquina superior derecha).

### Uso

| Método | Comando |
| :--- | :--- |
| Parámetro directo | `wtranscriptor -dev cuda` |
| Opción en diálogo interactivo | Al correr `wtranscriptor`, seleccionar `[2] cuda` en el paso de dispositivo |
| Menú → Usar whisper-transcriptor → opción 6 | Ejecutar con CUDA (pide modelo) |

## Modelos de Whisper

| Modelo | Precisión | Velocidad | Caso de Uso |
| :--- | :--- | :--- | :--- |
| `tiny` | Baja | Muy Rápida | Pruebas y prototipos |
| `base` | Media | Rápida | Uso general básico |
| `small` | Buena | Balanceada | Producción estándar |
| `medium` | Alta | Lenta | Máxima precisión requerida |
| `turbo` | Media-Alta | Optimizada | Velocidad prioritaria |

## Resolución de Errores

| Síntoma | Causa Raíz | Solución Técnica |
| :--- | :--- | :--- |
| "Ejecución de scripts deshabilitada" | Política de ejecución restrictiva | `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process` |
| "Python no está en el PATH" | Python instalado sin opción PATH | Reinstalar Python marcando "Add Python to PATH" o usar `-SkipPythonCheck` |
| "Whisper CLI no encontrado" | Whisper no instalado | `python -m pip install openai-whisper` |
| "FFmpeg no encontrado" | FFmpeg no instalado | `winget install Gyan.FFmpeg` |
| "Módulo no aparece después de instalar" | Sesión de PowerShell no actualizada | Cerrar y reabrir todas las ventanas de PowerShell |
| "Error de permisos al instalar" | PowerShell sin privilegios de Administrador | Ejecutar PowerShell como Administrador |
| "GUID de ejemplo detectado" | Manifiesto con GUID placeholder | El instalador genera automáticamente un nuevo GUID |
| Caracteres corruptos en pantalla (`ðŸ'‹`, `â•'`) | Archivos `.ps1`/`.psm1` sin BOM en PowerShell 5.1 | Los archivos deben estar guardados como UTF-8 con BOM (`EF BB BF`) |
| `Invoke-whisper-transcriptor` no reconocido tras instalar | Módulo instalado en ruta de PS7 pero se usa PS5.1 | Mover `Documents\PowerShell\Modules\whisper-transcriptor` a `Documents\WindowsPowerShell\Modules\` |
| `make: command not found` | `make` no viene incluido en Windows | `scoop install make` (requiere Scoop: https://scoop.sh) o `scoop install avr-gcc` |
| `python` abre el Microsoft Store | Alias de Python del Store activo | Desactivar en Configuración → Aplicaciones → Alias de ejecución de aplicaciones, luego instalar: `choco install python313` |
| `ModuleNotFoundError: No module named 'torch'` | PyTorch instalado sin soporte CUDA | `pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124` |

## Metadatos del Módulo

| Atributo | Valor |
| :--- | :--- |
| ModuleVersion | 1.2.1 |
| GUID | a1b2c3d4-e5f6-47a8-b9c0-d1e2f3a4b5c6 (placeholder) |
| Author | amillanaol |
| PowerShellVersion | 5.1 |
| FunctionsToExport | `Invoke-whisper-transcriptor` |
| AliasesToExport | `wtranscriptor` |
| ProjectUri | https://github.com/amillanaol/WhisperTraductor |

## Menú Interactivo

El archivo `menu.ps1` proporciona una interfaz de línea de comandos con las siguientes opciones:

### Menú principal

| Opción | Descripción | Script Invocado |
| :--- | :--- | :--- |
| 1 | Instalación estándar | `install-windows.ps1` |
| 2 | Instalación avanzada con parámetros | `install-windows.ps1` con flags |
| 3 | Verificación de instalación | Comandos de verificación nativos |
| 4 | Usar whisper-transcriptor (submenú de ejecución) | `Invoke-whisper-transcriptor` |
| 5 | Documentación | Abre archivos .md o navegador |
| 6 | Desinstalación | `uninstall-windows.ps1` |
| 0 | Salir | N/A |

### Submenú de ejecución (opción 4 del menú principal)

| Opción | Descripción |
| :--- | :--- |
| 1 | Ejecutar con configuración por defecto |
| 2 | Especificar directorio de videos |
| 3 | Seleccionar modelo de Whisper |
| 4 | Opciones avanzadas (directorio, modelo, extensión y dispositivo) |
| 5 | Ver ayuda del módulo |
| 6 | Ejecutar con CUDA (GPU acelerado, pide modelo) |

## Dependencias Externas

| Paquete | Comando de Instalación | Propósito |
| :--- | :--- | :--- |
| PowerShell 7 | `winget install Microsoft.PowerShell` | Shell moderno (opcional) |
| Python 3.13 | `winget install Python.Python.3.13` o `choco install python313` | Runtime de Python |
| FFmpeg | `winget install Gyan.FFmpeg` | Procesamiento de audio/video |
| openai-whisper | `pip install openai-whisper` | Motor de transcripción (CPU) |
| PyTorch + CUDA | `pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124` | Motor de transcripción (GPU NVIDIA) |
| make | `scoop install make` | Herramienta de build (requerida por Makefile) |

## Flujo de Procesamiento

| Etapa | Función Invocada | Archivo de Código |
| :--- | :--- | :--- |
| 1. Validación | `Invoke-whisper-transcriptor` | whisper-transcriptor.psm1 |
| 2. Búsqueda de videos | `Test-VideoFileExists` | whisper-transcriptor.psm1 |
| 3. Verificación SRT | `Test-SrtFileExists` | whisper-transcriptor.psm1 |
| 4. Procesamiento | `Invoke-VideoFiles` | whisper-transcriptor.psm1 |
| 5. Transcripción | Comando `whisper` CLI | Sistema externo |

| Campo | Valor |
| :--- | :--- |
| **Mantenedor** | amillanaol([https://orcid.org/0009-0003-1768-7048](https://orcid.org/0009-0003-1768-7048)) |
| **Estado** | Final |
| **Última Actualización** | 2026-02-25 |
