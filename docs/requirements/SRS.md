# SRS — Módulo Whisper Transcriptor (Transcripción PowerShell)

| Campo | Valor |
|-------|-------|
| Versión del documento | 1.0.0 |
| Versión del módulo documentado | 1.2.4 |
| Fuente de verdad | `src/windows/module/whisper-transcriptor.psm1` + `.psd1` (código, no documentación previa) |
| Enfoque | Espejo del comportamiento implementado; los defectos y desfases de documentación se listan como limitaciones (sección 7), no como requisitos |
| Fecha | 2026-10-20 |

## 1. Alcance

**Incluido:** la función principal de transcripción por lotes `Invoke-whisper-transcriptor` (alias `wtranscriptor`) del módulo PowerShell.

**Excluido (fuera de alcance, ver §8):** instalador/desinstalador Windows, instalador Linux, menú interactivo, utilidades TUI. El instalador Linux está roto (bug de ruta confirmado) y NO constituye requisito funcional.

## 2. Superficie pública

- Exporta **solo** la función `Invoke-whisper-transcriptor` y el alias `wtranscriptor` (psd1 `FunctionsToExport`/`AliasesToExport`; psm1 L794–797).
- PowerShell mínimo: 5.1 (psd1 L7).
- Al importar el módulo se configura consola UTF-8 (psm1 L1–3) y se evalúa disponibilidad CUDA (`torch.cuda.is_available()`, psm1 L50–60).

### 2.1 Parámetros

| Parámetro | Alias | Posición | Tipo | Valores | Default |
|-----------|-------|----------|------|---------|---------|
| `-Directory` | `-d` | 0 | string | ruta existente (directorio o archivo) | `(Get-Location).Path` |
| `-Model` | `-m` | 1 | string | `base\|tiny\|small\|medium\|turbo` | `tiny` |
| `-Extension` | `-e` | 2 | string | `mp4\|mkv\|webm\|avi\|mov\|m4a\|ogg` | `mp4` |
| `-Device` | `-dev` | — | string | `cpu\|cuda` | `cuda` si CUDA disponible al importar; si no `cpu` |
| `-Version` | `-v` | — | switch | — | — |
| `-Help` | *(sin alias `-h`)* | — | switch | — | — |

> `-OutputDirectory`/`-o` está declarado en el `param` block (psm1 L363–365) y anuncia en `-Help` (L401–402), pero **nunca se lee**: `Invoke-VideoFiles` se invoca con `-OutputDirectory $result.OutputDirectory`, donde `$result` viene de `Show-ProcessingSummary` (prompt interactivo, L294–311). El valor del parámetro de línea de comandos queda ignorado → limitación **L-09**, no input funcional. El flujo real de destino es: ENTER = carpeta del video; ruta no vacía (trim) = destino personalizado.

## 3. Requisitos funcionales

### 3.1 Arranque y atajos

- **RF-001** `-Version` imprime `whisper-transcriptor versión 1.2.4` y retorna sin procesar (psm1 L378–381; versión en L26).
- **RF-002** `-Help` imprime mensaje de uso con parámetros y ejemplo, y retorna sin procesar (L383–409). Ambos atajos se evalúan **antes** de validar dependencias.
- **RF-003** Cada invocación limpia la consola al inicio (`Clear-Host` tolerante a fallos, L21–23, L376).

### 3.2 Validaciones previas

- **RF-004** `Assert-Dependencies` verifica `python`, `ffprobe` y whisper (`Get-Command whisper` o fallback `python -m whisper --help`). Si falta alguna: imprime lista de faltantes + solución por dependencia y retorna **1** (L411–435).
- **RF-005** Si `-Directory` no existe (`Test-Path` falla): imprime error y retorna **1** (L437–448).
- **RF-006** Si `-Directory` apunta a un **archivo**: la extensión del archivo (minúsculas, sin punto) **sobreescribe** `-Extension`; el directorio de trabajo pasa a ser el padre del archivo (L450–457).

### 3.3 Descubrimiento y clasificación

- **RF-007** Búsqueda **recursiva** (`-Recurse`) de `*.<Extension>` bajo el directorio (L141, L613). Subcarpetas incluidas.
- **RF-008** Doble criterio de omitido (comportamiento real, ver §7 nota L-03):
  - En el **resumen interactivo**: se omite si existe `hermano.srt` en el **mismo directorio del video** (mismo basename) (L158–165).
  - En el **procesamiento**: se omite si existe `<basename>.srt` en el **destino resuelto por prompt** (carpeta del video si ENTER; ruta no vacía si el usuario la escribió) (L623–641). El parámetro `-o` no participa (L-09).
- **RF-009** 0 archivos encontrados → mensaje «NO SE ENCONTRARON ARCHIVOS», retorna **0** (L143–151).
- **RF-010** Todos los archivos ya clasificados como omitidos → mensaje «TODOS LOS ARCHIVOS YA ESTÁN PROCESADOS», retorna **0** (L264–270).

### 3.4 Interacción del resumen (Show-ProcessingSummary)

- **RF-011** Muestra panel de configuración (directorio, modelo, extensión, dispositivo) y estadísticas (total, con .srt, a procesar).
- **RF-012** Lista de archivos a procesar: máximo **10** en pantalla + indicador «… y N archivo(s) más» (L205–230). Lista de omitidos: máximo **5** + indicador (L240–258).
- **RF-013** Selector de dispositivo **solo se muestra si CUDA está disponible**: `[1] cpu` / `[2] cuda`; Enter conserva el default (L272–292). Sin CUDA no hay selector.
- **RF-014** **Siempre** pregunta directorio de salida personalizado; ENTER = por defecto; valor no vacío (trim) = destino personalizado (L294–311).
- **RF-015** Confirmación final `[S/n]`: vacío, `S`, `s`, `Y`, `y` → continúa; **cualquier otra entrada** → «OPERACIÓN CANCELADA» y retorna **0** (L317–338).

### 3.5 Procesamiento por lote (Invoke-VideoFiles)

- **RF-016** Por cada archivo (sin .srt en destino):
  1. Duración vía `ffprobe` (formato `HH:MM:SS` o `MM:SS`; «Desconocida» si falla) (L62–110).
  2. ETA estimado = duración × factor de modelo: tiny .25, base .35, small .50, medium .80, turbo .20, default .35 (L112–127). **Cálculo interno** (`$estimatedTranscriptionTime`, L654): se usa únicamente para estimar, **no se muestra** ni se expone en consola ni en la caja de estado (§7, L-10).
  3. Barra de progreso general y caja de estado de 3 líneas (archivo/modelo/duración/tamaño).
  4. Test de escritura en destino (archivo temporal `.test_write_<rand>.srt`); si falla → fallback a `$HOME\Documents\whisper-output` (creado si no existe) (L674–695).
- **RF-017** Invocación exacta de whisper (L700):
  ```
  whisper <archivo> --fp16=False --language Spanish --model <modelo> --output_format srt --output_dir <destino> --device <dispositivo>
  ```
  Comando resuelto: binario `whisper` si está en PATH; si no, `python -m whisper` (L619–620). Idioma, fp16 y formato SRT están **hardcodeados** (§7, nota L-01).
- **RF-018** Si whisper termina con exit ≠ 0: incrementa contador de errores, muestra mensaje con código, **continúa con el siguiente archivo** (no aborta el lote) (L708–724).
- **RF-019** Verificación post-proceso: si el SRT quedó en la carpeta del video y el destino difiere (con permiso de escritura), se **copia** al destino (L726–744).
- **RF-020** Pausa de **800 ms** entre archivos cuando quedan pendientes (L762–765).
- **RF-021** Resumen final: procesados OK / con errores / omitidos (ya tenían .srt) (L772–790).

### 3.6 Códigos de retorno (comportamiento real)

| Código | Condición |
|--------|-----------|
| `1` | Dependencias faltantes (RF-004) o directorio inexistente (RF-005) |
| `0` | Cancelado por usuario (RF-015), sin archivos (RF-009), todos procesados (RF-010) |
| `*` (impredecible) | `-Version`/`-Help`: `return` bare (L380, L408) → valor de pipeline `$null`; el código de salida efectivo en consola **no es 0** (hereda `$LASTEXITCODE` del proceso prevo; ver §9) |
| `0` (implícito, último pipeline) | Fallos per-file de whisper (RF-018) **NO** se propagan; si el último pipeline fue `$null` (p.ej. todos omitidos tras procesar), código efectivo impredecible (§9) |

### 3.7 Efectos secundarios (side-channels)

- **RF-022** `Show-ProcessingBox` appenda SIEMPRE trazas a `$env:TEMP\wt_debug.log` (sin gating) (L534–540).
- **RF-023** `trap` global del módulo registra en `$env:TEMP\wt_trace.log` únicamente errores RuntimeException cuyo mensaje matchea `"times"` (L6–19).

## 4. Reglas de negocio

- RB-01: Un video con `<basename>.srt` en su destino nunca se re-transcribe (idempotencia por omisión, no regeneración).
- RB-02: El lote es tolerante a fallos por archivo: un archivo corrupto no detiene el lote.
- RB-03: La detección de CUDA se congela al importar el módulo (`$script:CudaAvailable`); no se re-evalúa por invocación.

## 5. Requisitos no funcionales

- **NFR-001** Compatible con PowerShell ≥ 5.1 en Windows.
- **NFR-002** Salida de consola UTF-8 (L1–3).
- **NFR-003** Interfaz de usuario en español (mensajes, paneles, confirmación `[S/n]`).

## 6. Trazabilidad a features Gherkin

Fuente: `docs/features/transcripcion_lote.feature`. Cada escenario declara tags Gherkin explícitos `@RF-xxx`; la tabla referencia los **títulos exactos** de los escenarios (sin numeración posicional).

| Requisito | Escenario(s) exacto(s) en `transcripcion_lote.feature` |
|-----------|--------------------------------------------------------|
| RF-001 | «Consultar versión del módulo» |
| RF-002 | «Consultar ayuda del módulo» |
| RF-003 | «Limpiar la consola al inicio de cada invocación» |
| RF-004 | «Abortar por dependencias faltantes» |
| RF-005 | «Abortar por directorio inexistente» |
| RF-006 | «Ajustar la extensión efectiva al pasar un archivo directo» |
| RF-007 | «Incluir videos de subcarpetas (búsqueda recursiva)»; «Procesar un archivo .ogg» |
| RF-008 | «Detectar videos ya procesados por .srt hermano» (criterio del resumen); «Omitir video con .srt existente en el destino (criterio de procesamiento)» |
| RF-009 | «Cancelar cuando no hay archivos de la extensión indicada» |
| RF-010 | «Detectar videos ya procesados por .srt hermano» (mensaje «TODOS LOS ARCHIVOS YA ESTÁN PROCESADOS», retorno 0) |
| RF-011 | «Mostrar panel de configuración y estadísticas del resumen» |
| RF-012 | «Truncar la lista de archivos a procesar a 10»; «Truncar la lista de archivos omitidos a 5» |
| RF-013 | «Seleccionar dispositivo cuando CUDA está disponible»; «Conservar el dispositivo por defecto con Enter en el selector»; «No mostrar selector de dispositivo sin CUDA» |
| RF-014 | «Confirmar directorio de salida personalizado»; «Aceptar el directorio de salida por defecto con Enter» |
| RF-015 | «Cancelar el procesamiento en la confirmación» |
| RF-016.2 | «Calcular ETA interno sin mostrarlo» |
| RF-016.4 | «Reubicar SRT cuando el destino no tiene permisos de escritura» (test de escritura + fallback) |
| RF-017 | «Generar subtítulo SRT junto al video por defecto» (invocación exacta de whisper; el SRT es producto de la invocación) |
| RF-018 | «Continuar el lote cuando un archivo falla en whisper» |
| RF-019 | «Copiar SRT generado junto al video hacia el directorio de salida» (verificación/copia post-proceso) |
| RF-020 | «Pausar 800 ms entre archivos cuando quedan pendientes» |
| RF-021 | «Resumen final del lote»; «Continuar el lote cuando un archivo falla en whisper» (conteo de errores en el resumen) |
| RF-022 | «Registro de trazas de depuración» |
| RF-023 | «Registro de traza del trap global en wt_trace.log» |

Notas de cobertura:
- RF-004, RF-005, RF-009 y RF-016.4 **sí tienen escenario dedicado** (validado; el antiguo mapeo posicional los omitía).
- RF-016.1 (duración vía `ffprobe`) y RF-016.3 (barra de progreso y caja de estado) **no tienen escenario dedicado**: se ejercitan implícitamente dentro de los escenarios de procesamiento.

## 7. Limitaciones y defectos conocidos (NO son requisitos)

| ID | Tipo | Descripción | Evidencia |
|----|------|-------------|-----------|
| L-01 | Decisión a confirmar | Idioma `--language Spanish`, `--fp16=False` y formato **solo SRT** hardcodeados; sin parámetro para variarlos | psm1 L700 |
| L-02 | Defecto menor | Clasificación del resumen (RF-008, criterio resumen) ignora `-OutputDirectory`: solo mira `.srt` hermano del video; el procesamiento sí mira el destino → inconsistencia | L158–165 vs L623–641 |
| L-03 | Comentario erróneo | Comentario «sin recurse para evitar subcarpetas» junto a `-Recurse` real (README sí lo documenta recursivo — correcto) | L140–141 |
| L-04 | No documentado | `wt_debug.log` siempre activo en `%TEMP%` (volumen potencial en lotes grandes) | L534–540 |
| L-05 | Diseño | Fallo per-file no altera código de salida de la función (imposible detectar desde caller sin parsear salida) | §3.6 |
| L-06 | Docs desfasados | Versiones 1.2.1/1.2.3 en docs vs 1.2.4 real; `-OutputDirectory` ausente en `docs/funciones/transcripcion.md`; default `-Device` documentado «cpu» vs auto-detect real; alias `-h` documentado — no existe; códigos «>1 error Whisper CLI» no implementados | docs/** vs psm1 |
| L-07 | Docs desfasados | `tests/` (unit/integration) y `.github/workflows` documentados en docs pero **inexistentes** en el repo | `docs/desarrollo/tests_ejecucion.md` |
| L-08 | Fuera de alcance | Instalador/desinstalador/menú: `-Force` del instalador es no-op; elevación admin definida nunca invocada; opción Docs del menú con ruta README incorrecta | §8 |
| L-09 | Parámetro muerto | `-OutputDirectory`/`-o` declarado y anunciado en `-Help` pero **nunca leído**: el destino real viene del prompt interactivo de `Show-ProcessingSummary`; pasar `-o` no tiene efecto funcional | psm1 L363–365 (param) vs L401–402 (help) vs L467 (`Invoke-VideoFiles -OutputDirectory $result.OutputDirectory`); nunca se referencia `$OutputDirectory` del param block |
| L-10 | UX / no mostrado | `$estimatedTranscriptionTime` (duración × factor de modelo) se calcula pero no se imprime ni se expone; ETA es cálculo interno invisible al usuario | L654 (`$estimatedTranscriptionTime = ...`) — sin `Write-Host` posterior |
| L-11 | Semántica de retorno | `-Version` y `-Help` usan `return` sin valor → pipeline emite `$null`; `$LASTEXITCODE` (y código de salida efectivo de la invocación) queda heredado del proceso prevo, **no es 0** | L380 y L408 (`return` bare) |
| L-12 | No verificable (sin runner) | Hechos espejo-leídos del psm1 v1.2.4 pero no ejecutados en runtime: exactos mensajes de consola, códigos `$LASTEXITCODE` efectivos (L-11), valores de factor ETA, y comportamiento Gherkin de los features. El repo no tiene runner BDD/Gherkin ni tests; todo en §3 y `transcripcion_lote.feature` es **espejo estático** de la fuente, no observación empírica | repo sin `tests/` ni runner (ver L-07); sin ejecución de `Invoke-whisper-transcriptor` en esta auditoría |

## 8. Fuera de alcance

- **Instalador Windows** (`install-windows.ps1`, `uninstall-windows.ps1` y variantes legacy).
- **Instalador Linux** (`src/linux/install_modules.py`): **ROTO** — bug de ruta confirmado (`modules_dir` resuelve a `src/linux/src/windows/module`, inexistente → siempre exit 1). No es requisito funcional; cualquier reparación es change separado.
- **Menú interactivo** (`src/windows/menu.ps1`) y submenús.
- **TUI-Utils.psm1** (solo consumido por `examples/tui-demo.ps1`).
- **Infraestructura de tests/CI** (no existe; crearla es change separado — ver §7 L-07).

## 9. Supuestos y claims pendientes de confirmación

1. Idioma/fp16/SRT hardcodeados: ¿decisión intencional (audiencia hispanohablante) o defecto? Affects L-01.
2. ¿Los defectos L-02…L-05 se corrigen en change futuro o permanecen como limitación documentada?
3. ¿Los features se migrarán a `tests/features/` cuando exista runner (Behave/Gherkin-PS)?
4. ¿Crear tests/CI reales o eliminar la documentación fantasma de tests (L-07)?
5. **Códigos de salida de `-Version`/`-Help` (L-11)**: `return` bare produce `$null` y el código efectivo no es 0 (hereda `$LASTEXITCODE` prevo). No se pudo medir el valor exacto en esta auditoría (sin ejecución, L-12). Si se quiere garantizar `0`, el código debe usar `return 0` (change de código separado, fuera de este alcance de docs).
