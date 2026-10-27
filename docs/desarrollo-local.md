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
