# Tests

Documentacion detallada de ejecucion de tests del proyecto whisper-transcriptor.

## Comandos de Ejecucion

| Comando | Alcance | Requisitos |
| :--- | :--- | :--- |
| `Invoke-Pester tests/unit/` | Funciones del modulo | Modulo Pester instalado |
| `Invoke-Pester tests/integration/` | Scripts de instalacion | PowerShell 5.1+ |
| `Invoke-Pester -CodeCoverage src/` | Cobertura de codigo | PSScriptAnalyzer |

## Descripcion de Tests

### Tests Unitarios

Los tests unitarios verifican funciones individuales del modulo PowerShell:

- `Get-VideoDuration`: Validacion de duracion de videos
- `Invoke-whisper-transcriptor`: Verificacion de parametros
- `Test-VideoFileExists`: Deteccion de archivos de video
- `Test-SrtFileExists`: Verificacion de archivos SRT existentes

### Tests de Integracion

Los tests de integracion verifican el flujo completo de instalacion y ejecucion:

- Scripts de instalacion (`install-windows.ps1`)
- Scripts de desinstalacion (`uninstall-windows.ps1`)
- Menu interactivo (`menu.ps1`)

### Cobertura de Codigo

El analisis de cobertura verifica que las funciones principales tengan tests adecuados.

## Configuracion

### Instalar Pester (Framework de Tests)

```powershell
# Instalar Pester desde PowerShell Gallery
Install-Module -Name Pester -Force -SkipPublisherCheck

# Verificar instalacion
Get-Module -ListAvailable Pester
```

### Ejecutar Tests

```powershell
# Tests unitarios
Invoke-Pester tests/unit/ -Output Detailed

# Tests de integracion
Invoke-Pester tests/integration/ -Output Detailed

# Cobertura de codigo
Invoke-Pester -CodeCoverage src/windows/module/whisper-transcriptor.psm1 -Output Detailed
```

## Scripts de Test Disponibles

| Script | Proposito |
| :--- | :--- |
| `tests/unit/Test-ModuleFunctions.ps1` | Tests de funciones principales |
| `tests/unit/Test-TUIUtils.ps1` | Tests de utilidades TUI |
| `tests/integration/Test-Installation.ps1` | Tests de flujo de instalacion |

## Mejores Practicas

1. Ejecutar tests antes de cada commit
2. Verificar cobertura superior al 80%
3. Mantener tests independientes entre si
4. Usar mocks para dependencias externas (whisper, ffmpeg)
