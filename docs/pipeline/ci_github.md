# Pipeline CI/CD

Configuracion de integracion continua para el proyecto whisper-transcriptor.

## Vision General

El proyecto utiliza GitHub Actions para automatizar:

- Validacion de codigo PowerShell
- Analisis estatico con PSScriptAnalyzer
- Tests automaticos

## Workflows Disponibles

### Workflow Principal

Ubicacion: `.github/workflows/`

```yaml
name: PowerShell CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]
```

## Jobs de CI

### 1. Linting

Ejecuta analisis estatico del codigo PowerShell.

```powershell
# Instalacion de PSScriptAnalyzer
Install-Module -Name PSScriptAnalyzer -Force

# Ejecucion de analisis
Invoke-ScriptAnalyzer -Path ./src -Recurse -Severity Error
```

### 2. Tests

Ejecuta tests unitarios con Pester.

```powershell
# Instalacion de Pester
Install-Module -Name Pester -Force -SkipPublisherCheck

# Ejecucion de tests
Invoke-Pester -Path ./tests -Output Detailed
```

## Configuracion de GitHub Actions

### Variables de Entorno

| Variable | Descripcion |
| :--- | :--- |
| `POWERSHELL_VERSION` | Version de PowerShell a probar |

### Matriz de Pruebas

| Sistema Operativo | PowerShell |
| :--- | :--- |
| windows-latest | 5.1, 7.x |
| ubuntu-latest | 7.x |
| macos-latest | 7.x |

## Comandos Locales

### Ejecutar Linting

```powershell
# Instalar PSScriptAnalyzer
Install-Module -Name PSScriptAnalyzer -Force

# Analizar codigo
Invoke-ScriptAnalyzer -Path src/windows/module -Recurse
```

### Ejecutar Tests

```powershell
# Instalar Pester
Install-Module -Name Pester -Force -SkipPublisherCheck

# Ejecutar tests
Invoke-Pester -Path tests/unit
```

## Integracion con IDE

### VS Code

Extensiones recomendadas:

- PowerShell
- PSScriptAnalyzer
- Pester

### Configuracion de VS Code

```json
{
    "powershell.codeFormatting.preset": "OTBS",
    "powershell.scriptAnalysis.enable": true
}
```

## Buenas Practicas

1. Ejecutar linting antes de cada commit
2. Mantener tests unitarios actualizados
3. No introducir errores de analisis estatico
4. Verificar compatibilidad con PS 5.1 y 7+
