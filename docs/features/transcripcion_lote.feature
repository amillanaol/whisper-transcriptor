# language: es
Característica: Transcripción por lotes a subtítulos SRT
  Como usuario del módulo PowerShell whisper-transcriptor
  Quiero transcribir archivos de video de un directorio a formato SRT usando Whisper
  Para obtener subtítulos en español sin intervención manual por archivo

  Nota: estos escenarios espejan el comportamiento IMPLEMENTADO en
  src/windows/module/whisper-transcriptor.psm1 v1.2.4 (ver docs/requirements/SRS.md).
  Los defectos y desfases de documentación se listan en el SRS §7, no aquí.
  Nota de verificación (SRS L-12): el repo no tiene runner BDD/Gherkin; estos
  escenarios NO se ejecutaron. Son un espejo estático de la fuente, no
  observación empírica de runtime. Trazabilidad RF↔escenario: SRS §6
  (cada escenario declara tags Gherkin explícitos @RF-xxx).

  # ── Arranque y atajos ─────────────────────────────────────────────
  @RF-001
  Escenario: Consultar versión del módulo
    Dado que el módulo whisper-transcriptor está importado
    Cuando el usuario ejecuta "Invoke-whisper-transcriptor -Version"
    Entonces se imprime "whisper-transcriptor versión 1.2.4"
    Y no se realiza ninguna transcripción
    Y la función no emite un valor de retorno explícito (RF-001, L-11)

  @RF-002
  Escenario: Consultar ayuda del módulo
    Dado que el módulo whisper-transcriptor está importado
    Cuando el usuario ejecuta "Invoke-whisper-transcriptor -Help"
    Entonces se imprime el mensaje de uso con parámetros y ejemplo
    Y la función no emite un valor de retorno explícito (RF-002, L-11)

  @RF-003
  Escenario: Limpiar la consola al inicio de cada invocación
    Dado que el módulo whisper-transcriptor está importado
    Cuando el usuario ejecuta "Invoke-whisper-transcriptor -d 'C:\videos'"
    Entonces se limpia la consola antes de mostrar cualquier salida (RF-003)
    Y el fallo de "Clear-Host" no interrumpe la ejecución (tolerante a fallos)

  # ── Validaciones previas ──────────────────────────────────────────
  @RF-004
  Escenario: Abortar por dependencias faltantes
    Dado que falta "ffprobe" en el PATH del sistema
    Cuando el usuario ejecuta "Invoke-whisper-transcriptor -d 'C:\videos'"
    Entonces se lista "FFmpeg (ffprobe)" como dependencia faltante (RF-004)
    Y se muestra la solución "winget install Gyan.FFmpeg"
    Y la función retorna el código 1

  @RF-005
  Escenario: Abortar por directorio inexistente
    Dado que todas las dependencias están disponibles
    Y que no existe el directorio "C:\no_existe"
    Cuando el usuario ejecuta "Invoke-whisper-transcriptor -d 'C:\no_existe'"
    Entonces se imprime "El directorio especificado no existe" (RF-005)
    Y la función retorna el código 1

  # ── Descubrimiento y clasificación ────────────────────────────────
  @RF-006
  Escenario: Ajustar la extensión efectiva al pasar un archivo directo
    Dado que todas las dependencias están disponibles
    Y existe el archivo "C:\videos\clase.mkv"
    Cuando el usuario ejecuta "Invoke-whisper-transcriptor -d 'C:\videos\clase.mkv'"
    Entonces la extensión efectiva se ajusta automáticamente a "mkv" (RF-006)
    Y el directorio de trabajo se establece en "C:\videos"
    Y se muestra el resumen de operación para procesar "clase.mkv"

  @RF-009
  Escenario: Cancelar cuando no hay archivos de la extensión indicada
    Dado que todas las dependencias están disponibles
    Y el directorio "C:\videos" no contiene archivos "*.mp4"
    Cuando el usuario ejecuta "Invoke-whisper-transcriptor -d 'C:\videos'"
    Entonces se muestra el mensaje "NO SE ENCONTRARON ARCHIVOS" (RF-009)
    Y la función retorna el código 0

  @RF-008 @RF-010
  Escenario: Detectar videos ya procesados por .srt hermano
    Dado que todas las dependencias están disponibles
    Y existe el archivo "C:\videos\clase.mp4"
    Y existe el archivo "C:\videos\clase.srt"
    Cuando el usuario ejecuta "Invoke-whisper-transcriptor -d 'C:\videos'"
    Entonces "clase.mp4" se clasifica como omitido por tener subtítulos (criterio del resumen, RF-008)
    Y se muestra el mensaje "TODOS LOS ARCHIVOS YA ESTÁN PROCESADOS" (RF-010)
    Y la función retorna el código 0

  @RF-008
  Escenario: Omitir video con .srt existente en el destino (criterio de procesamiento)
    Dado que todas las dependencias están disponibles
    Y existe el archivo "C:\videos\clase.mp4"
    Y existe el archivo "D:\subtitulos\clase.srt" en el destino personalizado
    Cuando el usuario ejecuta "Invoke-whisper-transcriptor -d 'C:\videos'"
    Y acepta "D:\subtitulos" como directorio de salida
    Y confirma con "S"
    Entonces "clase.mp4" se omite en el procesamiento por existir "<basename>.srt" en el destino (RF-008)
    Y no se invoca whisper para "clase.mp4"
    Y el resumen final cuenta "clase.mp4" como omitido (ya tenía .srt en destino)

  @RF-007
  Escenario: Incluir videos de subcarpetas (búsqueda recursiva)
    Dado que todas las dependencias están disponibles
    Y existe el archivo "C:\videos\curso\parte1.mp4"
    Cuando el usuario ejecuta "Invoke-whisper-transcriptor -d 'C:\videos'"
    Entonces "parte1.mp4" aparece en la lista de archivos a procesar (RF-007)

  @RF-007
  Escenario: Procesar un archivo .ogg
    Dado que todas las dependencias están disponibles
    Y existe el archivo "C:\videos\clase.ogg"
    Cuando el usuario ejecuta "Invoke-whisper-transcriptor -d 'C:\videos' -e 'ogg'"
    Entonces "clase.ogg" aparece en la lista de archivos a procesar (RF-007)

  # ── Interacción del resumen (Show-ProcessingSummary) ──────────────
  @RF-011
  Escenario: Mostrar panel de configuración y estadísticas del resumen
    Dado que todas las dependencias están disponibles
    Y el directorio contiene videos "*.mp4" con y sin subtítulos
    Cuando el usuario ejecuta "Invoke-whisper-transcriptor -d 'C:\videos' -m tiny"
    Entonces se muestra el panel de CONFIGURACIÓN con directorio, modelo, extensión y dispositivo (RF-011)
    Y se muestran las estadísticas: total de archivos, los que ya tienen .srt y los que se procesarán (RF-011)

  @RF-012
  Escenario: Truncar la lista de archivos a procesar a 10
    Dado que todas las dependencias están disponibles
    Y el directorio contiene 12 archivos "*.mp4" sin subtítulos
    Cuando el usuario ejecuta "Invoke-whisper-transcriptor -d 'C:\videos'"
    Entonces se muestran como máximo 10 archivos en la lista "ARCHIVOS A PROCESAR" (RF-012)
    Y se indica "... y 2 archivo(s) más"

  @RF-012
  Escenario: Truncar la lista de archivos omitidos a 5
    Dado que todas las dependencias están disponibles
    Y el directorio contiene 8 archivos "*.mp4" con subtítulos ya presentes
    Cuando el usuario ejecuta "Invoke-whisper-transcriptor -d 'C:\videos'"
    Entonces se muestran como máximo 5 archivos en la lista "ARCHIVOS OMITIDOS" (RF-012)
    Y se indica "... y 3 archivo(s) más omitidos"

  @RF-013
  Escenario: Seleccionar dispositivo cuando CUDA está disponible
    Dado que todas las dependencias están disponibles
    Y CUDA está disponible en el equipo
    Y el directorio contiene videos "*.mp4" sin subtítulos
    Cuando el usuario ejecuta "Invoke-whisper-transcriptor -d 'C:\videos'"
    Y se muestra el selector "[1] cpu" y "[2] cuda" (RF-013)
    Y el usuario elige "2"
    Entonces el dispositivo efectivo es "cuda"

  @RF-013
  Escenario: Conservar el dispositivo por defecto con Enter en el selector
    Dado que todas las dependencias están disponibles
    Y CUDA está disponible en el equipo
    Y el directorio contiene videos "*.mp4" sin subtítulos
    Cuando el usuario ejecuta "Invoke-whisper-transcriptor -d 'C:\videos'"
    Y se muestra el selector de dispositivo (RF-013)
    Y el usuario presiona Enter sin escribir nada
    Entonces se conserva el dispositivo por defecto (cuda si CUDA disponible)

  @RF-013
  Escenario: No mostrar selector de dispositivo sin CUDA
    Dado que todas las dependencias están disponibles
    Y CUDA NO está disponible en el equipo
    Y el directorio contiene videos "*.mp4" sin subtítulos
    Cuando el usuario ejecuta "Invoke-whisper-transcriptor -d 'C:\videos'"
    Entonces NO se muestra el selector de dispositivo (RF-013)

  @RF-014
  Escenario: Confirmar directorio de salida personalizado
    Dado que todas las dependencias están disponibles
    Y el directorio contiene videos "*.mp4" sin subtítulos
    Cuando el usuario ejecuta "Invoke-whisper-transcriptor -d 'C:\videos'"
    Y siempre se pregunta el directorio de salida (RF-014)
    Y el usuario escribe "D:\subtitulos"
    Y confirma el procesamiento con "S"
    Entonces los archivos SRT se generan en "D:\subtitulos"

  @RF-014
  Escenario: Aceptar el directorio de salida por defecto con Enter
    Dado que todas las dependencias están disponibles
    Y el directorio contiene videos "*.mp4" sin subtítulos
    Cuando el usuario ejecuta "Invoke-whisper-transcriptor -d 'C:\videos'"
    Y se pregunta el directorio de salida (RF-014)
    Y el usuario presiona Enter
    Entonces los archivos SRT se generan junto a cada video (carpeta del video por defecto)

  @RF-015
  Escenario: Cancelar el procesamiento en la confirmación
    Dado que todas las dependencias están disponibles
    Y el directorio contiene videos "*.mp4" sin subtítulos
    Cuando el usuario ejecuta "Invoke-whisper-transcriptor -d 'C:\videos'"
    Y se muestra la confirmación final "[S/n]" (RF-015)
    Y el usuario responde "n"
    Entonces se muestra el mensaje "OPERACIÓN CANCELADA POR EL USUARIO"
    Y la función retorna el código 0
    Y no se invoca whisper

  # ── Procesamiento por lote (Invoke-VideoFiles) ────────────────────
  @RF-017
  Escenario: Generar subtítulo SRT junto al video por defecto
    Dado que todas las dependencias están disponibles
    Y existe el archivo "C:\videos\clase.mp4" sin subtítulos
    Cuando el usuario acepta el directorio de salida por defecto con Enter
    Y el usuario confirma con "S"
    Y el dispositivo efectivo es "cuda"
    Y whisper termina con código de salida 0
    Entonces se invoca whisper con "clase.mp4" y flags hardcodeados "--fp16=False --language Spanish --output_format srt" (RF-017)
    Y el "--output_dir" apunta a la carpeta del video "C:\videos"
    Y se genera el archivo "C:\videos\clase.srt" (producto de la invocación, RF-017)
    Y la función no emite un valor de retorno explícito (sin código 0 explícito)

  @RF-018 @RF-021
  Escenario: Continuar el lote cuando un archivo falla en whisper
    Dado que todas las dependencias están disponibles
    Y existen los archivos "C:\videos\a.mp4" y "C:\videos\b.mp4" sin subtítulos
    Y el usuario confirma con "S"
    Cuando whisper termina con código de salida 1 al procesar "a.mp4" (RF-018)
    Entonces se muestra "ERROR AL PROCESAR ARCHIVO" con el código 1
    Y el procesamiento continúa con "b.mp4" (RF-018)
    Y el resumen final cuenta "a.mp4" como error y "b.mp4" como procesado correctamente (RF-021)
    Y el fallo no altera el código de salida de la función (L-05, §3.6)

  @RF-016
  Escenario: Reubicar SRT cuando el destino no tiene permisos de escritura
    Dado que todas las dependencias están disponibles
    Y existe el archivo "C:\videos\clase.mp4" sin subtítulos
    Y el directorio de destino no permite escritura
    Cuando el usuario confirma con "S"
    Entonces se muestra el aviso "SIN PERMISOS DE ESCRITURA"
    Y el directorio de salida alternativo es "$HOME\Documents\whisper-output" (creado si no existe) (RF-016.4)
    Y el subtítulo se guarda en ese directorio alternativo

  @RF-019
  Escenario: Copiar SRT generado junto al video hacia el directorio de salida
    Dado que todas las dependencias están disponibles
    Y existe el archivo "C:\videos\clase.mp4" sin subtítulos
    Y el usuario especifica "D:\subtitulos" como directorio de salida
    Y el usuario confirma con "S"
    Cuando whisper genera "C:\videos\clase.srt" en la carpeta del video
    Entonces el archivo se copia a "D:\subtitulos\clase.srt" (RF-019)
    Y se imprime "Copiado a: D:\subtitulos"

  @RF-016
  Escenario: Calcular ETA interno sin mostrarlo
    Dado que todas las dependencias están disponibles
    Y existe el archivo "C:\videos\clase.mp4" sin subtítulos
    Y el usuario confirma con "S"
    Cuando se procesa "clase.mp4" con el modelo "tiny"
    Entonces se calcula un ETA interno igual a "duración × factor del modelo" (RF-016.2)
    Y el ETA NO se muestra en la consola ni en la caja de estado (cálculo interno, L-10)

  @RF-020
  Escenario: Pausar 800 ms entre archivos cuando quedan pendientes
    Dado que todas las dependencias están disponibles
    Y existen los archivos "C:\videos\a.mp4" y "C:\videos\b.mp4" sin subtítulos
    Y el usuario confirma con "S"
    Cuando finaliza el procesamiento de "a.mp4" con "b.mp4" aún pendiente
    Entonces se pausa 800 milisegundos antes de continuar (RF-020)

  @RF-021
  Escenario: Resumen final del lote
    Dado que todas las dependencias están disponibles
    Y el directorio contiene 3 videos sin subtítulos y 1 con subtítulos
    Y el usuario confirma con "S"
    Cuando finaliza el procesamiento del lote
    Entonces se muestra "PROCESAMIENTO COMPLETADO"
    Y se reportan los conteos de procesados, errores y omitidos (RF-021)

  # ── Efectos secundarios (side-channels) ───────────────────────────
  @RF-022
  Escenario: Registro de trazas de depuración
    Dado que todas las dependencias están disponibles
    Y el directorio contiene videos "*.mp4" sin subtítulos
    Y el usuario confirma con "S"
    Cuando se muestra la caja de estado de un archivo (Show-ProcessingBox)
    Entonces se appende una línea de traza en "$env:TEMP\wt_debug.log" siempre, sin gating (RF-022)

  @RF-023
  Escenario: Registro de traza del trap global en wt_trace.log
    Dado que el módulo whisper-transcriptor está importado
    Cuando ocurre una RuntimeException cuyo mensaje matchea "times"
    Entonces el trap global appenda la traza en "$env:TEMP\wt_trace.log" (RF-023)
    Y la traza incluye timestamp, mensaje, stack trace y ubicación del error
