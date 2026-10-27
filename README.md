# Mistborn Deckbuilder

Adaptación digital en Godot/GDScript para jugar con amigos a distancia. Idioma español y aplicación para Windows.

Alcance: competitivo de 2–4, cooperativo de 2–4 y cooperativo en solitario. Las partidas de grupo usarán salas privadas sin cuentas y permitirán reconectarse.

## Estado

P03 completada: proyecto Godot ejecutable, pantalla inicial con dos cartas de prueba, recarga del catálogo y manejo de errores. P04 añade un ensayo de conexión con anfitrión, hasta cuatro participantes y contador compartido, verificado entre procesos en este PC; falta prueba entre redes. Todavía no hay partida jugable. El contenido de ejemplo no es un catálogo oficial.

P05 incorpora una maqueta interactiva aceptada como base visual: **Ver tablero** desde el inicio, o `-Action board` en el lanzador. Cartas ampliables, mercado, mano, misiones y estados de muestra. [Diseño y controles](docs/diseno-visual.md).

P06 incorpora [contrato v1 y validación](docs/datos-de-cartas.md); dos muestras migradas y cero cartas oficiales verificadas. `-Action test-catalog` comprueba el contrato. [Capturar cartas por lotes desde Android](docs/captura-de-cartas.md). Próximo trabajo: especificar P07, estado y acciones de partida.

## Probar en este equipo

Desde la carpeta del repositorio:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/godot.ps1 -Action run
```

Godot 4.7.2 estable se ha preparado localmente en .tools/godot/; el motor no se incluye en Git. Para otro equipo, consulta [preparación y comandos](docs/desarrollo-local.md).

## Documentación

- [Instrucciones de trabajo](AGENTS.md)
- [Índice y recuperación de contexto](docs/README.md)
- [Estado actual](docs/estado-actual.md)
- [Continuar en otro PC con Codex](docs/continuar-en-otro-pc.md)
- [Plan por fases](docs/plan-de-trabajo.md)
- [Backlog](docs/gestion/backlog.md) y [flujo SDD](docs/gestion/desarrollo.md)
- [Reglas y fuentes](docs/reglas-del-juego.md)
- [Verificación de P03](docs/specs/003-arranque-godot/verification.md)
- [Probar la conexión con dos ventanas](docs/prueba-de-conexion.md)

La raíz Git es esta carpeta, mistborn-deck-builder/, dentro del espacio mistborn-deckbuilder/. La documentación acompaña al código para recuperar el contexto en futuras sesiones.
