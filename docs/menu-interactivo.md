| Necesidad del Usuario | Ubicación |
| :--- | :--- |
| Ejecutar menú interactivo | `menu.ps1` |
| Instalar whisper-transcriptor | Opción 1 del menú |
| Instalación con opciones personalizadas | Opción 2 del menú |
| Verificar estado de instalación | Opción 3 del menú |
| Ejecutar transcripción de videos | Opción 4 del menú |
| Consultar documentación | Opción 5 del menú |
| Desinstalar sistema | Opción 6 del menú |

## Especificaciones Técnicas

| Atributo | Valor |
| :--- | :--- |
| ScriptVersion | 1.0.0 |
| PowerShell Requerido | 5.1 o superior |
| Ubicación | `menu.ps1` (raíz del repositorio) |
| Dependencias | `src/windows/installer/*.ps1`, `src/windows/module/*.ps1` |

## Variables de Configuración

| Variable | Valor | Descripción |
| :--- | :--- | :--- |
| `$ScriptVersion` | "1.0.0" | Versión del menú |
| `$InstallerPath` | `$PSScriptRoot\src\windows\installer` | Ruta a instaladores |
| `$ModulePath` | `$PSScriptRoot\src\windows\module` | Ruta al módulo |
| `$ColorHeader` | 'Cyan' | Color de encabezados |
| `$ColorMenu` | 'Yellow' | Color de menú |
| `$ColorSuccess` | 'Green' | Color de éxito |
| `$ColorWarning` | 'Yellow' | Color de advertencias |
| `$ColorError` | 'Red' | Color de errores |
| `$ColorInfo` | 'White' | Color de información |

## Funciones del Menú

| Función | Propósito | Ubicación en Código |
| :--- | :--- | :--- |
| `Show-Header` | Limpia pantalla y muestra encabezado | Líneas 33-45 |
| `Show-Menu` | Presenta opciones disponibles | Líneas 47-61 |
| `Read-Option` | Captura selección del usuario | Líneas 63-67 |
| `Show-Progress` | Muestra mensaje de progreso | Líneas 69-73 |
| `Pause-Screen` | Pausa esperando ENTER | Líneas 75-78 |
| `Test-IsAdmin` | Verifica privilegios de administrador | Líneas 80-85 |
| `Request-Admin` | Solicita elevación de privilegios | Líneas 87-101 |

## Opciones del Menú Principal

| Número | Opción | Función Invocada | Requiere Admin |
| :--- | :--- | :--- | :--- |
| 1 | Instalar whisper-transcriptor | `Invoke-Install` | Sí |
| 2 | Instalación avanzada | `Invoke-InstallAdvanced` | Sí |
| 3 | Verificar instalación | `Invoke-Verify` | No |
| 4 | Usar whisper-transcriptor | `Invoke-RunModule` | No |
| 5 | Ver documentación | `Show-Documentation` | No |
| 6 | Desinstalar | `Invoke-Uninstall` | Sí |
| 0 | Salir | N/A | No |

## Submenú de Instalación Avanzada (Opción 2)

| Selección | Parámetros Aplicados | Descripción |
| :--- | :--- | :--- |
| 1 | `-SkipPythonCheck` | Omite verificación de Python |
| 2 | `-SkipWhisperCheck` | Omite verificación de Whisper |
| 3 | `-Force` | Sobrescribe instalación existente |
| 4 | `-SkipPythonCheck -SkipWhisperCheck` | Omite ambas verificaciones |
| 5 | `-SkipPythonCheck -SkipWhisperCheck -Force` | Modo forzado completo |
| 6 | Ninguno | Instalación estándar |

## Submenú de Ejecución (Opción 4)

| Selección | Parámetros Solicitados | Comando Generado |
| :--- | :--- | :--- |
| 1 | Ninguno | `Invoke-whisper-transcriptor` |
| 2 | Directorio | `Invoke-whisper-transcriptor -Directory <ruta>` |
| 3 | Modelo | `Invoke-whisper-transcriptor -Model <modelo>` |
| 4 | Directorio, Modelo, Extensión | `Invoke-whisper-transcriptor -Directory <ruta> -Model <modelo> -Extension <ext>` |
| 5 | Ninguno | `Invoke-whisper-transcriptor -Help` |

### Modelos Disponibles en Submenú

| Opción | Modelo | Características |
| :--- | :--- | :--- |
| 1 | `tiny` | Muy rápido, menor precisión |
| 2 | `base` | Rápido, precisión media |
| 3 | `small` | Balance velocidad/precisión |
| 4 | `medium` | Lento, alta precisión |
| 5 | `turbo` | Optimizado para velocidad |

## Desinstalación (Opción 6)

| Campo | Detalle |
| :--- | :--- |
| Flujo | Muestra advertencia, solicita confirmación S/N y ejecuta `uninstall-windows.ps1` directamente |
| Datos de usuario | No se eliminan |
| Cancelación | Responder N (o cualquier valor distinto de S/s) |

## Submenú de Documentación (Opción 5)

| Selección | Documento | Ubicación |
| :--- | :--- | :--- |
| 1 | Guía de instalación | `README-WINDOWS.md` |
| 2 | Descripción técnica | `docs/arquitectura/modulo_descripcion.md` |
| 3 | Repositorio GitHub | https://github.com/amillanaol/WhisperTraductor |

## Flujo de Verificación (Opción 3)

| Verificación | Comando Utilizado | Mensaje Éxito | Mensaje Error |
| :--- | :--- | :--- | :--- |
| Módulo instalado | `Get-Module -ListAvailable whisper-transcriptor` | Módulo encontrado | No instalado |
| Comando disponible | `Get-Command Invoke-whisper-transcriptor` | Comando disponible | Reiniciar PowerShell |
| Python | `python --version` | Versión detectada | No encontrado |
| Whisper | `Get-Command whisper` | Disponible | No encontrado |
| FFmpeg | `Get-Command ffmpeg` | Disponible | No encontrado |

## Resolución de Errores

| Síntoma | Causa Raíz | Solución Técnica |
| :--- | :--- | :--- |
| "No se encontró el script de instalación" | Ejecución desde directorio incorrecto | Ejecutar desde raíz del repositorio |
| "Requiere privilegios de Administrador" | PowerShell sin elevación | Menú solicita reinicio con elevación automática |
| "El directorio no existe" (ejecución) | Ruta inválida proporcionada | Verificar ruta antes de confirmar |
| "Opción no válida" | Entrada fuera de rango 0-6 | Seleccionar número entre 0 y 6 |

## Dependencias de Funciones

| Función | Dependencias Externas | Scripts Invocados |
| :--- | :--- | :--- |
| `Invoke-Install` | Privilegios Admin | `install-windows.ps1` |
| `Invoke-InstallAdvanced` | Privilegios Admin | `install-windows.ps1` con parámetros |
| `Invoke-Verify` | Módulo instalado | Comandos nativos de PowerShell |
| `Invoke-RunModule` | Módulo cargado | `Invoke-whisper-transcriptor` |
| `Show-Documentation` | Navegador/Notepad | Ninguno |
| `Invoke-Uninstall` | Privilegios Admin | `uninstall-windows.ps1` |

| Campo | Valor |
| :--- | :--- |
| **Mantenedor** | amillanaol([https://orcid.org/0009-0003-1768-7048](https://orcid.org/0009-0003-1768-7048)) |
| **Estado** | Final |
| **Última Actualización** | 2026-02-12 |
