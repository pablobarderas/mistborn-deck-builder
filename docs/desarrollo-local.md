# Ejecutar el proyecto en Windows

## Entorno fijado

- Godot **4.7.2 estable**, versión estándar con GDScript, registrada en `.godot-version`.
- Renderizador Compatibility; pantalla de referencia 1280×800, ventana mínima provisional 1024×640. No son todavía los requisitos finales de hardware o accesibilidad.
- PowerShell de Windows para el lanzador. No se necesitan paquetes de Python/Node ni un framework de tests.

La ubicación portátil prevista es `.tools/godot/`, excluida de Git y presente en este PC al verificar T08.2f el 2026-11-10. Un clon no incluye el motor: descargar la [versión oficial](https://godotengine.org/download/archive/4.7.2-stable/), descomprimir allí los ejecutables estándar de Windows x86_64 o indicar su ruta con `-GodotPath`. El lanzador rechaza una versión distinta; no sustituirla silenciosamente por una más reciente.

## Comandos

Desde la raíz del repositorio (la carpeta que contiene project.godot):

```powershell
# Ejecutar la pantalla inicial.
powershell -NoProfile -ExecutionPolicy Bypass -File tools/godot.ps1 -Action run

# Abrir el editor; F6 ejecuta la escena seleccionada y F5 el proyecto.
powershell -NoProfile -ExecutionPolicy Bypass -File tools/godot.ps1 -Action editor

# Importar y comprobar arranque, carga, errores y recuperación.
powershell -NoProfile -ExecutionPolicy Bypass -File tools/godot.ps1 -Action test

# Renderizar una captura y salir mediante el botón de la escena.
powershell -NoProfile -ExecutionPolicy Bypass -File tools/godot.ps1 -Action preview
```

`-ExecutionPolicy Bypass` solo afecta a ese proceso; no cambia la política global del equipo. También se puede abrir project.godot directamente desde Godot 4.7.2.

Si el ejecutable está en otra ubicación, añadir por ejemplo `-GodotPath 'D:/Herramientas/Godot_v4.7.2-stable_win64_console.exe'` o definir `GODOT_BIN` para la sesión. Preferir el ejecutable `_console.exe` para conservar los diagnósticos.

## Qué debe verse

Pantalla en español con dos cartas identificadas como ejemplos, sus nombres y cifras, el estado de carga, Comprobar catálogo y Salir. Las ilustraciones de las cartas todavía no existen; la vista muestra un sustituto. El botón de comprobación recarga el archivo original y no duplica tarjetas.

Las cifras y descripciones de esos ejemplos no son un catálogo oficial ni ejecutan efectos. La pantalla no ofrece todavía una partida o una sala funcional.

## Pruebas y diagnóstico

`-Action test-cycle` importa el proyecto y ejecuta `tests/card_cycle_test.gd`; exige `P08_CYCLE_OK`, código 0 y ausencia de errores de script. Cubre T08.2a: robo/reciclado personal, descarte, limpieza de cartas y composición transaccional con contenido ficticio en siete configuraciones. No ejecuta turnos completos, efectos ni el mazo rival. Como el resto de acciones, admite `-GodotPath`.

La acción `test` importa primero el proyecto y ejecuta `tests/startup_test.gd` sin interfaz gráfica. Debe finalizar con `P03_STARTUP_OK` y código 0. Se prueban archivo ausente, JSON inválido, raíz incorrecta, entrada no objeto, IDs ausentes/no textuales/vacíos/duplicados y recuperación de la pantalla. Los ocho mensajes `ERROR` precedidos por `FALLO ESPERADO` forman parte de esos casos negativos; una comprobación fallida produce código distinto de cero.

La captura requiere sesión gráfica y renderizador; queda en `tmp/screenshots/main-screen.png`. Logs por acción en `tmp/godot/`. Los archivos de entrada de las pruebas quedan en `tmp/test-fixtures/`. El lanzador crea `tmp/.gdignore` para no importar esos intermedios como recursos del juego.

Godot crea sus datos normales de aplicación en el perfil de Windows. En herramientas restringidas puede requerir permiso de ejecución para escribir ahí. En T08.2f, redirigir APPDATA a una carpeta temporal no resolvió `Safe save failed` durante importación; las pruebas finales usaron ejecución fuera del sandbox con el perfil normal, sin cambiar ajustes globales. El lanzador rechaza errores de importación o de script incluso con salida nativa cero y contempla la conversión de stderr a ErrorRecord en Windows PowerShell.

Para revisar una copia limpia, copiar solo `.godot-version`, project.godot y las carpetas scripts, scenes, assets, data, tests y tools a una carpeta nueva sin `.godot/`; ejecutar `test` allí indicando la ruta absoluta del motor con `-GodotPath`.

La evidencia concreta de esta fase está en [SPEC-003](specs/003-arranque-godot/verification.md). La distribución de un ejecutable a los amigos corresponde a P18.

## Ensayo de conexión de P04

Desde el inicio, pulsar **Probar conexión**. También se puede abrir directamente con `-Action network`; `-Action test-network` ejecuta el ensayo con procesos independientes y `-Action preview-network` captura la interfaz. Usan el mismo lanzador y versión de motor.

Pasos para dos ventanas y futura prueba entre redes: [guía de conexión](prueba-de-conexion.md). La prueba local no acredita conectividad externa ni recuperación de partida.

## Maqueta del tablero de P05

**Ver tablero** desde el inicio o `-Action board` en el lanzador. `-Action preview-board` ejecuta la verificación visual con Godot, guarda seis capturas y debe terminar con `P05_BOARD_OK`. Requiere sesión gráfica; no usa red. [Diseño, controles y resoluciones](diseno-visual.md).

## Contrato del catálogo de P06

`-Action test-catalog` ejecuta 220 comprobaciones de estructura, referencias, revisión, recursos y recuperación, con marca P06_CATALOG_OK. Dos fallos de carga se anuncian como esperados; un SCRIPT ERROR siempre hace fallar el lanzador, aunque Godot devuelva código cero. Logs en tmp/godot/test-catalog.log. [Contrato](contrato-catalogo-v1.md) y [captura por lotes](captura-de-cartas.md).

## Estado estructural de P07

`-Action test-state` importa y ejecuta tests/game_state_test.gd: exige P07_STATE_OK y rechaza ERROR/SCRIPT ERROR incluso con código 0. Actualmente son 2.004 comprobaciones tras T08.2f (1.725 al cierre local de P07) sobre fixtures ficticios: siete configuraciones, referencias/zonas, rival, resoluciones pendientes, copias profundas y entradas malformadas. Un WARNING anunciado corresponde al rechazo esperado de un snapshot. No ejecuta reglas ni acciones, no abre una partida y no prueba privacidad de clientes. Logs en tmp/godot/test-state.log; contrato y evidencia en [SPEC-007](specs/007-estado-y-acciones/verification.md).

En este equipo (2026-10-28) el motor está en Descargas y se indica mediante -GodotPath; no se presupone que .tools/godot exista en todos los clones. La ruta local exacta se conserva solo en la evidencia, no se incrusta en el lanzador.

## Núcleo de acciones de P07

`-Action test-engine` importa y ejecuta `tests/game_engine_test.gd`, exige `P07_ENGINE_OK` y rechaza ERROR/SCRIPT ERROR. Son 102 comprobaciones con manejadores ficticios: transacción atómica, revisiones, RNG reproducible, recibos, reintentos, resolución pausada, vistas propias/ajenas y entradas inválidas. Los WARNING provienen de candidatos rechazados esperadamente. No hay aún acciones de cartas reales ni interfaz de partida. Evidencia y límites en [SPEC-007](specs/007-estado-y-acciones/verification.md).

## Preparación estructural de P08

`-Action test-setup` importa y ejecuta `tests/game_setup_test.gd`, exige `P08_SETUP_OK` y rechaza ERROR/SCRIPT ERROR. Son 147 comprobaciones en Godot 4.7.2 sobre siete configuraciones, manifiestos, existencias, reparto, orden, bonificaciones y rival. El fixture marca definiciones ficticias como verificadas solo para aislar el contrato técnico; el catálogo real sigue sin una definición verificada. No hay pantalla ni prueba manual asociada a P08 todavía. [Evidencia y límites](specs/008-preparacion-y-turnos/verification.md).

### Limpieza interna de turno (T08.2b)

`-Action test-cleanup` ejecuta `tests/turn_cleanup_test.gd` y exige la marca `P08_CLEANUP_OK`. Es una API interna con fixtures ficticios; no ofrece un turno jugable. Parte de una fase limpieza autorizada y comprueba cierre atómico, guardias y entrega a inicio/rival. T08.2c añade devolución de Atium usado; los efectos aún no modelados siguen bloqueados. [Contrato y evidencia](specs/008-preparacion-y-turnos/verification.md#t082b--cierre-interno-de-limpieza).

### Secuencias reanudables (T08.2f)

`-Action test-sequence` ejecuta `tests/sequence_test.gd` y exige `P08_SEQUENCE_OK`, código 0 y ausencia de errores de script. Comprueba registro cerrado, pausa/carga/respuesta, rollback, RNG, cierres únicos, reintentos, proyecciones y límites con programas ficticios. El estado usa esquema 2/motor `p08-sequence-1/godot-4.7.2`; rechaza snapshots previos sin migración. No implementa cartas oficiales ni un turno jugable. Resultados y comandos finales en [evidencia T08.2f](specs/008-preparacion-y-turnos/verification.md#t082f--implementación-de-secuencias-reanudables).

### Primer efecto de carta (T08.2h)

`-Action test-funding` ejecuta `tests/funding_play_test.gd`, exige `P08_FUNDING_OK` y rechaza ERROR/SCRIPT ERROR incluso con código 0. Comprueba juego Funding con aplicar/omitir, perfil completo, rechazos, recibos/carga, límites y privacidad en competitivo 2–4. El fixture sitúa `libre` expresamente; no ejecuta entrenamiento ni turno completo. Su versión original fue `p08-funding-1/godot-4.7.2`. La versión vigente figura en el apartado de inicio competitivo. [Evidencia y límites](specs/008-preparacion-y-turnos/verification.md#t082h--implementación-de-funding).

### Avance de entrenamiento competitivo

`-Action test-training` importa y ejecuta `tests/training_advance_test.gd`, exige `P08_TRAINING_OK` y rechaza errores de Godot. Recorre la pista competitiva de 2 a 4 plazas, comprueba los límites, niveles y Atium, y verifica el rechazo atómico y la conservación de cierres Funding. Usa un perfil técnico aislado y un fixture. [Evidencia T08.1b2](specs/008-preparacion-y-turnos/verification.md#t081b2--operación-interna-de-avance-competitivo).

En este PC el ejecutable estándar se comprobó en `C:/Users/pablo/Downloads/godot/Godot_v4.7.2-stable_win64_console.exe`. Si falta `.tools/godot/`, indicar la ruta local con `-GodotPath`.

### Inicio competitivo aislado

`-Action test-start` ejecuta `tests/competitive_start_test.gd` y exige `P08_START_OK`. Cubre los escenarios INI-01–05 del [contrato de inicio](specs/008-preparacion-y-turnos/inicio-competitivo.md) con contenido de prueba. La versión de motor de los snapshots es `p08-start-1/godot-4.7.2`, con esquema 2. Las versiones anteriores requieren una migración explícita para ser admitidas.

### Catálogo de misiones

La carga de arranque usa `data/cartas.json`. Para comprobar aparte las ocho misiones españolas con Godot 4.7.2, usa la carpeta de SRC-005 que contiene los dos PNG originales.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/prepare-mission-sources.ps1 -SourceDirectory 'C:/Users/pablo/Documents/Digitalizaciones/Digitalizaciones/cartas_personajes/misiones'
powershell -NoProfile -ExecutionPolicy Bypass -File tools/godot.ps1 -Action test-missions
```

El preparador comprueba ambas huellas, conserva las copias idénticas y señala los destinos discordantes. Las copias de `evidencia_local/` quedan fuera de Git y de la importación de recursos. `test-missions` carga explícitamente `data/misiones.json` y contrasta cada premio, localizador y fuente. [Contrato y alcance](specs/008-preparacion-y-turnos/catalogo-misiones.md).

### Avance automático de misiones (T08.1b12)

`-Action test-mission-advance` ejecuta `tests/mission_advance_test.gd` y exige `P08_MISSION_ADVANCE_OK`, código 0 y ausencia de errores de script. Requiere las fuentes locales de misiones preparadas mediante el comando del apartado anterior. Usa las definiciones reales M5/M6/M7 y componentes/reservas netas ficticios de autoridad; verifica gasto, primeros, premios, rollback, recibos, restauración y victoria antes de premios. Su versión original fue `p08-missions-1/godot-4.7.2`, esquema 3; T08.1b14 actualiza el motor compartido a esquema 4. No abre UI ni un turno completo de producto. [Evidencia y límites](specs/008-preparacion-y-turnos/verification.md#t081b12--resolutor-automático-de-misiones-m5m6m7).

### Permanentes de misión (T08.1b14)

`-Action test-permanents` importa y ejecuta `tests/permanents_test.gd`, exige `P08_PERMANENTS_OK` y rechaza ERROR/SCRIPT ERROR aunque el proceso termine con cero. Usa el mismo lote local de fuentes de misiones, perfil M3/M4/M7, pista/componentes y reservas ficticias. Comprueba llegadas, inicio único con M3, mano nueva 5/6 con M4, rechazos atómicos, recibos, carga, finales y privacidad. Snapshot 4/motor `p08-permanents-1/godot-4.7.2`, sin migración implícita desde esquema 3. Los estados de limpieza proceden de una fuente fixture fiable; no prueban combate, Target, transición desde libre ni una partida completa. [Resultados y revisión](specs/008-preparacion-y-turnos/verification.md#t081b14--implementación-de-permanentes-m3m4).
