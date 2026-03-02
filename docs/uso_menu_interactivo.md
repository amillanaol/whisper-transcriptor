# Uso del Menu Interactivo

Guia completa de uso del menu interactivo de whisper-transcriptor.

## Inicio del Menu

### Ejecucion desde Raiz del Proyecto

```powershell
.\menu.ps1
```

### Ejecucion con Make

```powershell
make install
```

### Requisitos Previos

```powershell
# Habilitar ejecucion de scripts (solo primera vez)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
```

## Menu Principal

Al ejecutar `menu.ps1` se muestra el menu principal:

```
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║           WHISPER TRASCRIPTOR - MENU PRINCIPAL               ║
║                                                                ║
║         Generador de Subticulos SRT con Whisper AI            ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝

  MENU DE OPCIONES:
  ─────────────────────────────────────────────────────────────

  [1] 📦 Instalar whisper-transcriptor
  [2] 🔧 Instalar (modo avanzado - opciones personalizadas)
  [3] ✅ Verificar instalación actual
  [4] ▶️  Usar whisper-transcriptor (ejecutar módulo)
  [5] 📖 Ver documentación
  [6] 🗑️  Desinstalar whisper-transcriptor

  [0] 🚪 Salir
```

## Descripcion de Opciones

### Opcion 1: Instalar whisper-transcriptor

Ejecuta la instalacion estandar del modulo.

| Requisito | Descripcion |
| :--- | :--- |
| Permisos | Administrador |
| Accion | Copia archivos a `Documents\PowerShell\Modules\` |

### Opcion 2: Instalacion avanzada

Permite personalizar la instalacion con parametros:

| Opcion | Parametros Aplicados |
| :--- | :--- |
| 1 | `-SkipPythonCheck` |
| 2 | `-SkipWhisperCheck` |
| 3 | `-Force` |
| 4 | `-SkipPythonCheck -SkipWhisperCheck` |
| 5 | `-SkipPythonCheck -SkipWhisperCheck -Force` |
| 6 | Estandar (sin parametros) |

### Opcion 3: Verificar instalacion

Verifica el estado actual de la instalacion:

| Verificacion | Comando |
| :--- | :--- |
| Modulo instalado | `Get-Module -ListAvailable whisper-transcriptor` |
| Comando disponible | `Get-Command Invoke-whisper-transcriptor` |
| Python | `python --version` |
| Whisper | `Get-Command whisper` |
| FFmpeg | `Get-Command ffmpeg` |

### Opcion 4: Usar whisper-transcriptor

Submenu para ejecutar transcripciones:

| Opcion | Descripcion |
| :--- | :--- |
| 1 | Ejecutar con configuracion por defecto |
| 2 | Especificar directorio de videos |
| 3 | Seleccionar modelo de Whisper |
| 4 | Opciones avanzadas (todo personalizable) |
| 5 | Ver ayuda del modulo |
| 6 | Ejecutar con CUDA (GPU) |

### Opcion 5: Ver documentacion

Abre documentos de referencia:

| Opcion | Documento |
| :--- | :--- |
| 1 | README-WINDOWS.md |
| 2 | Descripcion tecnica del modulo |
| 3 | Repositorio GitHub |

### Opcion 6: Desinstalar

Elimina el modulo del sistema.

| Requisito | Descripcion |
| :--- | :--- |
| Permisos | Administrador |
| Confirmacion | Requiere confirmacion S/N |

## Flujo de Transcripcion

Despues de instalado, el flujo tipico es:

```
Menu > Opcion 4 > Seleccionar modelo > Directorio > Confirmar
```

### Seleccion de Modelo

| Opcion | Modelo | Velocidad | Precision |
| :--- | :--- | :--- | :--- |
| 1 | tiny | Muy rapida | Baja |
| 2 | base | Rapida | Media |
| 3 | small | Balanceada | Buena |
| 4 | medium | Lenta | Alta |
| 5 | turbo | Optimizada | Media-Alta |

## Atajos de Teclado

| Tecla | Accion |
| :--- | :--- |
| Enter | Confirmar seleccion |
| 0-6 | Seleccionar opcion directa |
| S/s | Confirmar |
| N/n | Cancelar |

## Salir del Menu

Seleccionar opcion `0` o presionar Enter cuando se solicite.

```
¡Gracias por usar whisper-transcriptor!
```
