# Documentación del Módulo whisper-transcriptor

## Visión General

El módulo **whisper-transcriptor** es una solución de PowerShell que automatiza la generación de subtítulos SRT a partir de archivos de video utilizando la tecnología Whisper de OpenAI. El módulo está diseñado para procesar múltiples archivos de video de forma recursiva y generar automáticamente archivos de subtítulos en español.

## Estructura del Módulo



### Archivos Principales

#### 1. whisper-transcriptor.psd1 (Manifiesto del Módulo)

**Propósito**: Define los metadatos y configuración del módulo

**Componentes clave**:

- **ModuleVersion**: 1.2.3
- **RootModule**: whisper-transcriptor.psm1
- **GUID**: Identificador único del módulo
- **Author**: [amillanaol](https://orcid.org/0009-0003-1768-7048)
- **PowerShellVersion**: Requiere PowerShell 5.1 o superior
- **FunctionsToExport**: `Invoke-whisper-transcriptor`
- **Tags**: Whisper, Subtitles, SRT, Video, Transcription

#### 2. whisper-transcriptor.psm1 (Módulo Principal)

**Propósito**: Contiene toda la lógica funcional del módulo

## Arquitectura del Sistema

### Componentes Funcionales

#### 1. Función Principal: `Invoke-whisper-transcriptor`

**Descripción**: Punto de entrada principal del módulo que coordina todo el proceso de transcripción.

**Parámetros**:

- **Directory** (`-d`): Directorio de archivos de video (por defecto: `./inputs`)
- **Model** (`-m`): Modelo de Whisper a utilizar (tiny, small, base, medium, turbo)
- **Extension** (`-e`): Extensión de archivos a procesar (mp4, mkv, webm)
- **Version** (`-v`): Muestra la versión del módulo
- **Help**: Muestra información de ayuda

**Funcionalidades**:

- Validación de parámetros de entrada
- Gestión de ayuda y versión
- Validación de existencia del directorio
- Coordinación de funciones auxiliares
- Control de flujo principal

#### 2. Funciones Auxiliares

##### `Test-VideoFileExists`

**Propósito**: Verificar la existencia de archivos de video en el directorio especificado

**Parámetros**:

- `$Path`: Ruta del directorio a verificar
- `$Extension`: Extensión de archivo a buscar

**Funcionalidad**:

- Búsqueda recursiva de archivos con la extensión especificada
- Retorna verdadero si encuentra al menos un archivo

##### `Test-SrtFileExists`

**Propósito**: Verificar la existencia de archivos SRT en el directorio

**Parámetros**:

- `$Path`: Ruta del directorio a verificar

**Funcionalidad**:

- Búsqueda recursiva de archivos .srt
- Retorna verdadero si encuentra al menos un archivo de subtítulos

##### `Invoke-VideoFiles`

**Propósito**: Procesar cada archivo de video encontrado y generar subtítulos

**Parámetros**:

- `$Path`: Ruta del directorio de videos
- `$Extension`: Extensión de archivos a procesar

**Funcionalidad**:

- Enumeración de todos los archivos de video
- Verificación de existencia de archivos SRT correspondientes
- Llamada al comando `whisper` para transcripción
- Gestión de mensajes informativos al usuario

## Flujo de Trabajo del Sistema

### 1. Inicialización

- El usuario ejecuta `Invoke-whisper-transcriptor` con parámetros opcionales
- Se validan los parámetros de entrada
- Se procesan las banderas especiales (Help, Version)

### 2. Validación de Entorno

- Verificación de existencia del directorio especificado
- Comprobación de archivos de video disponibles
- Detección de archivos SRT existentes

### 3. Procesamiento

- Iteración sobre cada archivo de video encontrado
- Para cada archivo:
  - Verificación de archivo SRT correspondiente
  - Si no existe SRT: ejecutar transcripción con Whisper
  - Si existe SRT: omitir procesamiento

### 4. Transcripción

- Ejecución del comando `whisper` con parámetros específicos:
  - `--fp16=False`: Desactiva precisión de 16 bits
  - `--language Spanish`: Especifica idioma español
  - `--model $Model`: Utiliza el modelo seleccionado
  - `--output_format srt`: Genera archivos en formato SRT
  - `--output_dir`: Guarda en el directorio del video original

### 5. Finalización

- Mensajes informativos sobre el proceso completado
- Indicación de ubicación de archivos generados

## Variables y Configuraciones

### Variables del Módulo

- **`$script:Version`**: Almacena la versión actual del módulo.

### Configuraciones por Defecto

- **Directorio**: `./inputs` (directorio inputs en la ubicación actual)
- **Modelo**: `tiny` (modelo más rápido de Whisper)
- **Extensión**: `mp4` (formato de video más común)
- **Idioma**: Español (hardcoded en la llamada a Whisper)

## Dependencias Externas

### Requisitos del Sistema

1. **PowerShell 5.1** o superior
2. **Whisper CLI** instalado y accesible desde PATH
3. **Python** y dependencias de Whisper configuradas

### Modelos de Whisper Soportados

- **tiny**: Más rápido, menor precisión
- **small**: Balance entre velocidad y precisión
- **base**: Modelo estándar
- **medium**: Mayor precisión, más lento
- **turbo**: Optimizado para velocidad

## Gestión de Errores

### Validaciones Implementadas

- Verificación de existencia de directorio
- Validación de parámetros con `ValidateSet`
- Manejo silencioso de errores con `ErrorAction SilentlyContinue`

### Mensajes de Usuario

- Informes de progreso durante transcripción
- Notificaciones de archivos ya procesados
- Mensajes de error claros y descriptivos

## Exportación y Accesibilidad

### Funciones Exportadas

- Únicamente `Invoke-whisper-transcriptor` es exportada como función pública
- Las funciones auxiliares permanecen privadas dentro del módulo

### Instalación Global

Para uso global del módulo, debe instalarse en una de las rutas de módulos de PowerShell:
- `$env:PSModulePath`
- Típicamente: `Documents\PowerShell\Modules\whisper-transcriptor\`

Esta documentación proporciona una base sólida para entender la arquitectura y funcionamiento del módulo whisper-transcriptor, facilitando futuras modificaciones.
