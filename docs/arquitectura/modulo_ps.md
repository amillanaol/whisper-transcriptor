# Arquitectura del Modulo PowerShell

Descripcion tecnica de la arquitectura del modulo whisper-transcriptor.

## Vision General

El proyecto sigue una arquitectura modular de PowerShell con separation clara entre:

- **Presentacion**: Menu interactivo (TUI)
- **Logica de Negocio**: Funciones de transcripcion
- **Infraestructura**: Scripts de instalacion/desinstalacion

## Componentes Principales

### 1. Modulo PowerShell (`whisper-transcriptor.psm1`)

Archivo principal que contiene toda la logica de transcripcion.

| Funcion | Proposito |
| :--- | :--- |
| `Invoke-whisper-transcriptor` | Punto de entrada principal |
| `Invoke-VideoFiles` | Procesamiento de archivos |
| `Get-VideoDuration` | Obtencion de duracion de video |
| `Show-ProcessingSummary` | Interfaz de resumen TUI |
| `Show-ProcessingBox` | Visualizacion de progreso |

### 2. Manifiesto del Modulo (`whisper-transcriptor.psd1`)

Archivo de metadatos del modulo PowerShell:

```powershell
@{
    ModuleVersion = '1.2.1'
    GUID = 'a1b2c3d4-e5f6-47a8-b9c0-d1e2f3a4b5c6'
    FunctionsToExport = @('Invoke-whisper-transcriptor')
    AliasesToExport = @('wtranscriptor')
}
```

### 3. Utilidades TUI (`TUI-Utils.psm1`)

Funciones auxiliares para interfaz de texto:

| Funcion | Proposito |
| :--- | :--- |
| `Show-ProgressBar` | Barra de progreso textual |
| `Show-FileProgressBar` | Progreso de archivo individual |
| `Show-SpinnerFrame` | Animacion de espera |
| `Show-ProcessingBox` | Caja de estado visual |

### 4. Menu Interactivo (`menu.ps1`)

Interfaz de usuario textual que orchestina todas las operaciones:

```
Menu Principal
├── [1] Instalar whisper-transcriptor
├── [2] Instalacion avanzada
├── [3] Verificar instalacion
├── [4] Usar modulo
├── [5] Documentacion
└── [6] Desinstalar
```

## Flujo de Ejecucion

<div align="center">
    <img src="https://raw.githubusercontent.com/amillanaol/whisper-transcriptor/refs/heads/main/docs/arquitectura/assets/Pasted%20image%2020260422214121.png"
        alt="IGV "
        width="700" />
</div>

## Estructura de Archivos

```
src/windows/
├── module/
│   ├── whisper-transcriptor.psm1   # Logica principal
│   ├── whisper-transcriptor.psd1   # Manifiesto
│   ├── TUI-Utils.psm1             # Utilidades TUI
│   └── Descripcion.md             # Docs tecnicas (movido a docs/arquitectura/)
├── installer/
│   ├── install-windows.ps1         # Instalador
│   └── uninstall-windows.ps1       # Desinstalador
└── menu.ps1                       # Menu interactivo
```

## Alias y Comandos

| Alias | Comando Completo | Descripcion |
| :--- | :--- | :--- |
| `wtranscriptor` | `Invoke-whisper-transcriptor` | Comando corto |

## Versionado

El modulo sigue versionamiento semantico (SemVer):

- **1.2.1**: Version actual
- **1.2.0**: Nuevas funciones
- **1.0.0**: Primera version estable
