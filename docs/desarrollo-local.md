# Ejecutar el proyecto en Windows

## Entorno fijado

- Godot **4.7.2 estable**, versión estándar con GDScript, registrada en `.godot-version`.
- Renderizador Compatibility; pantalla de referencia 1280×800, ventana mínima provisional 1024×640. No son todavía los requisitos finales de hardware o accesibilidad.
- PowerShell de Windows para el lanzador. No se necesitan paquetes de Python/Node ni un framework de tests.

En este equipo se ha preparado una copia portátil en `.tools/godot/`, excluida de Git. Un clon no incluye el motor: descargar la [versión oficial](https://godotengine.org/download/archive/4.7.2-stable/), descomprimir allí los ejecutables estándar de Windows x86_64 o indicar su ruta con `-GodotPath`. El lanzador rechaza una versión distinta; no sustituirla silenciosamente por una más reciente.

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

La acción `test` importa primero el proyecto y ejecuta `tests/startup_test.gd` sin interfaz gráfica. Debe finalizar con `P03_STARTUP_OK` y código 0. Se prueban archivo ausente, JSON inválido, raíz incorrecta, entrada no objeto, IDs ausentes/no textuales/vacíos/duplicados y recuperación de la pantalla. Los ocho mensajes `ERROR` precedidos por `FALLO ESPERADO` forman parte de esos casos negativos; una comprobación fallida produce código distinto de cero.

La captura requiere sesión gráfica y renderizador; queda en `tmp/screenshots/main-screen.png`. Logs por acción en `tmp/godot/`. Los archivos de entrada de las pruebas quedan en `tmp/test-fixtures/`. El lanzador crea `tmp/.gdignore` para no importar esos intermedios como recursos del juego.

Godot crea sus datos normales de aplicación en el perfil de Windows. En un entorno de herramientas restringido puede requerir permiso de ejecución para escribir ahí; eso no es un fallo de las reglas del proyecto.

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

`-Action test-state` importa y ejecuta tests/game_state_test.gd: exige P07_STATE_OK y rechaza ERROR/SCRIPT ERROR incluso con código 0. Actualmente son 1.741 comprobaciones tras añadir `training_track_id` en P08 (1.725 al cierre local de P07) sobre fixtures ficticios: siete configuraciones, referencias/zonas, rival, resoluciones pendientes, copias profundas y entradas malformadas. Un WARNING anunciado corresponde al rechazo esperado de un snapshot. No ejecuta reglas ni acciones, no abre una partida y no prueba privacidad de clientes. Logs en tmp/godot/test-state.log; contrato y evidencia en [SPEC-007](specs/007-estado-y-acciones/verification.md).

En este equipo (2026-10-28) el motor está en Descargas y se indica mediante -GodotPath; no se presupone que .tools/godot exista en todos los clones. La ruta local exacta se conserva solo en la evidencia, no se incrusta en el lanzador.

## Núcleo de acciones de P07

`-Action test-engine` importa y ejecuta `tests/game_engine_test.gd`, exige `P07_ENGINE_OK` y rechaza ERROR/SCRIPT ERROR. Son 102 comprobaciones con manejadores ficticios: transacción atómica, revisiones, RNG reproducible, recibos, reintentos, resolución pausada, vistas propias/ajenas y entradas inválidas. Dos WARNING provienen de candidatos rechazados esperadamente. No hay aún acciones de cartas reales ni interfaz de partida. Evidencia y límites en [SPEC-007](specs/007-estado-y-acciones/verification.md).

## Preparación estructural de P08

`-Action test-setup` importa y ejecuta `tests/game_setup_test.gd`, exige `P08_SETUP_OK` y rechaza ERROR/SCRIPT ERROR. Son 147 comprobaciones en Godot 4.7.2 sobre siete configuraciones, manifiestos, existencias, reparto, orden, bonificaciones y rival. El fixture marca definiciones ficticias como verificadas solo para aislar el contrato técnico; el catálogo real sigue sin una definición verificada. No hay pantalla ni prueba manual asociada a P08 todavía. [Evidencia y límites](specs/008-preparacion-y-turnos/verification.md).
