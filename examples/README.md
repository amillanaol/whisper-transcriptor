# Ejemplos de Uso

Este directorio contiene ejemplos de cómo usar las diferentes funcionalidades del proyecto.

## TUI Demo

**Archivo**: `tui-demo.ps1`

Demostración completa de las capacidades del módulo TUI-Utils.

### Ejecutar

```powershell
.\examples\tui-demo.ps1
```

### Qué incluye

1. **Barras de Progreso**: Diferentes estilos y formatos
2. **Spinners Animados**: 4 estilos diferentes (dots, line, arrow, box)
3. **Cajas de Información**: Formateo de datos estructurados
4. **Separadores**: Líneas decorativas
5. **Parseo de Progreso**: Extracción de porcentajes y timestamps
6. **Actualización en Tiempo Real**: Refresh de pantalla sin parpadeo
7. **Ejemplo Integrado**: Simulación de procesamiento de múltiples archivos

### Vista Previa

```
╔════════════════════════════════════════════════════════════╗
║           DEMO DEL MÓDULO TUI-UTILS                       ║
╚════════════════════════════════════════════════════════════╝

1️⃣  BARRAS DE PROGRESO

  Progreso con valores:
  [██████████░░░░░░░░░░░░░░░░░░░░] 25% (25/100)
  [████████████████████░░░░░░░░░░] 50% (50/100)

  Progreso con porcentaje:
  [█████████████░░░░░░░░░░░░░░░░░] 33%
```

## Documentación Relacionada

- [Patrones TUI](../docs/desarrollo/tui_patrones.md) - Guía completa de patrones y mejores prácticas
- [Módulo TUI-Utils](../src/windows/module/TUI-Utils.psm1) - Código fuente del módulo

## Crear Nuevos Ejemplos

Para agregar un nuevo ejemplo:

1. Crea un archivo `.ps1` en este directorio
2. Importa el módulo necesario:
   ```powershell
   Import-Module ..\src\windows\module\TUI-Utils.psm1
   ```
3. Documenta con comentarios Help:
   ```powershell
   <#
   .SYNOPSIS
       Breve descripción

   .DESCRIPTION
       Descripción detallada

   .EXAMPLE
       .\examples\tu-ejemplo.ps1
   #>
   ```
4. Actualiza este README con tu nuevo ejemplo
