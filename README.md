# Whisper Transcriptor

Whisper Transcriptor es una solucion que automatiza la generacion de subtitulos SRT a partir de archivos multimedia utilizando la tecnologia Whisper de OpenAI. El modulo esta diseñado para procesar multiples archivos de audio y video de forma recursiva y generar automaticamente archivos de subtitulos.

Implementado como un menu interactivo con interfaz TUI, el sistema sigue una arquitectura modular con separacion clara entre la logica de transcripcion, utilidades y scripts de instalacion.

## Indice de la documentacion

| Necesidad                                    | Ubicacion                                                                    |
| :------------------------------------------- | :--------------------------------------------------------------------------- |
| Instalar y ejecutar localmente               | [docs/desarrollo/instalacion_local.md](docs/desarrollo/instalacion_local.md) |
| Configurar variables de entorno              | [docs/configuracion/env_puerto.md](docs/configuracion/env_puerto.md)         |
| Entender la arquitectura del modulo          | [docs/arquitectura/modulo_ps.md](docs/arquitectura/modulo_ps.md)             |
| Consultar funciones de transcripcion         | [docs/funciones/transcripcion.md](docs/funciones/transcripcion.md)           |
| Configurar instalacion del modulo PowerShell | [docs/instalacion/modulo_ps.md](docs/instalacion/modulo_ps.md)               |
| Desplegar con menu interactivo               | [docs/uso_menu_interactivo.md](docs/uso_menu_interactivo.md)                 |
| Utilidades TUI (Text User Interface)         | [docs/utilidades/tui.md](docs/utilidades/tui.md)                             |
| Patrones TUI avanzados                       | [docs/desarrollo/tui_patrones.md](docs/desarrollo/tui_patrones.md)           |
| Guia Linux (WSL/Ubuntu)                      | [docs/linux/instalacion_guia.md](docs/linux/instalacion_guia.md)             |
| Pipeline CI/CD                               | [docs/pipeline/ci_github.md](docs/pipeline/ci_github.md)                     |
| Ejecutar tests                               | [docs/desarrollo/tests_ejecucion.md](docs/desarrollo/tests_ejecucion.md)     |
| Resolucion de errores comunes                | [docs/errores/general_resolucion.md](docs/errores/general_resolucion.md)     |

## Stack Tecnico del proyecto

| Componente               | Tecnologia                | Version       |
| :----------------------- | :------------------------ | :------------ |
| Lenguaje Principal       | PowerShell                | 5.1+          |
| Modulo PowerShell        | whisper-transcriptor      | 1.2.1         |
| Motor de Transcripcion   | Whisper CLI (OpenAI)      | Latest        |
| Procesamiento Multimedia | FFmpeg                    | 5.x           |
| Runtime                  | Python                    | 3.8+          |
| Interfaz de Usuario      | Text User Interface (TUI) | Custom        |
| Build Tool               | Makefile                  | GNU Make      |
| Version de PowerShell 7  | pwsh                      | 7+ (opcional) |

# Estructura del Proyecto

```
whisper-transcriptor/
├── menu.ps1                          # Punto de entrada: menu interactivo principal
├── Makefile                          # Comando make install para ejecutar menu
├── README.md                         # Documentacion principal del proyecto
│
├── src/
│   ├── windows/                      # Componentes especificos de Windows
│   │   ├── installer/                 # Scripts de instalacion y desinstalacion
│   │   │   ├── install-windows.ps1   # Instalador principal con verificaciones
│   │   │   └── uninstall-windows.ps1 # Desinstalador del sistema
│   │   │
│   │   ├── module/                   # Modulo PowerShell principal
│   │   │   ├── whisper-transcriptor.psd1   # Manifiesto del modulo (v1.2.1)
│   │   │   ├── whisper-transcriptor.psm1   # Logica de transcripcion principal
│   │   │   ├── TUI-Utils.psm1       # Utilidades para interfaces de texto
│   │   │   ├── Install-WhisperTranscriptor.ps1 # Instalacion del modulo
│   │   │   ├── Uninstall-WhisperTranscriptor.ps1 # Desinstalacion
│   │   │   └── Descripcion.md        # Documentacion tecnica del modulo (movido a docs/)
│   │   │
│   │   └── menu.ps1                  # Menu interactivo para Windows
│   │
│   └── linux/                        # Componentes para Linux (scripts Python)
│       └── install_modules.py        # Instalador de modulos
│
├── docs/                             # Documentacion detallada
│   ├── desarrollo/
│   │   ├── instalacion_local.md      # Guia de instalacion local
│   │   ├── tests_ejecucion.md       # Documentacion de tests
│   │   └── tui_patrones.md          # Patrones TUI avanzados
│   ├── configuracion/
│   │   └── env_puerto.md             # Variables de entorno
│   ├── arquitectura/
│   │   └── modulo_ps.md              # Arquitectura del modulo
│   ├── funciones/
│   │   └── transcripcion.md          # Funciones de transcripcion
│   ├── instalacion/
│   │   └── modulo_ps.md              # Instalacion del modulo PowerShell
│   ├── pipeline/
│   │   └── ci_github.md             # Pipeline CI/CD
│   ├── utilidades/
│   │   └── tui.md                   # Utilidades TUI
│   ├── linux/
│   │   └── instalacion_guia.md      # Guia de uso en Linux
│   └── errores/
│       └── general_resolucion.md     # Resolucion de errores
│
├── examples/                         # Ejemplos de uso
│   ├── tui-demo.ps1                  # Demo de interfaz TUI
│   └── README.md
│
└── tests/                           # Tests del proyecto
    ├── unit/                        # Tests unitarios
    └── integration/                 # Tests de integracion
```

## Inicio Rapido

```bash
# 1. Habilitar ejecucion de scripts (solo primera vez)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process

# 2. Ejecutar menu interactivo (recomendado)
powershell -ExecutionPolicy Bypass -File menu.ps1

# 3. O usar make (si esta disponible)
make install

# 4. O ejecutar directamente el modulo ya instalado
wtranscriptor -d ./videos -m medium -e mp4
```

Despues de instalado, usa el comando `wtranscriptor` o `Invoke-whisper-transcriptor` desde cualquier ubicacion.

## Ejecucion de Tests

| Comando                   | Alcance                         | Requisitos              |
| :------------------------ | :------------------------------ | :---------------------- |
| Pester tests/unit/        | Funciones del modulo PowerShell | Modulo Pester instalado |
| Pester tests/integration/ | Scripts de instalacion          | PowerShell 5.1+         |
| Analisis estatico         | Code linting                    | PSScriptAnalyzer        |

**NOTA:** La ejecucion de tests se detalla en [docs/desarrollo/tests_ejecucion.md](docs/desarrollo/tests_ejecucion.md)

## Resolucion de Errores

| Sintoma                                 | Causa Raiz                            | Solucion Tecnica                                                   |
| :-------------------------------------- | :------------------------------------ | :----------------------------------------------------------------- |
| "Ejecucion de scripts deshabilitada"    | Politica de ejecucion restrictiva     | `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process` |
| "Python no esta en el PATH"             | Python instalado sin opcion PATH      | Reinstalar Python marcando "Add Python to PATH"                    |
| "Whisper CLI no encontrado"             | Whisper no instalado                  | `python -m pip install openai-whisper`                             |
| "FFmpeg no encontrado"                  | FFmpeg no instalado                   | `winget install Gyan.FFmpeg`                                       |
| "Modulo no aparece despues de instalar" | Sesion de PowerShell no actualizada   | Cerrar y reabrir PowerShell                                        |
| Caracteres corruptos (ð)                | Archivos .ps1/.psm1 sin BOM en PS 5.1 | Guardar archivos como UTF-8 con BOM                                |

**NOTA:** La resolucion detallada de errores se encuentra en [docs/errores/general_resolucion.md](docs/errores/general_resolucion.md)

## Control de versiones

| Campo                    | Valor                                             |
| :----------------------- | :------------------------------------------------ |
| **Mantenedor**           | amillanaol(https://orcid.org/0009-0003-1768-7048) |
| **Estado**               | Final                                             |
| **Ultima Actualizacion** | 2026-03-02                                        |
