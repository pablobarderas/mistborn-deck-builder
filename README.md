# Mistborn Deckbuilder

Adaptación digital en Godot/GDScript para jugar con amigos a distancia. Idioma español y aplicación para Windows.

Alcance: competitivo de 2–4, cooperativo de 2–4 y cooperativo en solitario. Las partidas de grupo usarán salas privadas sin cuentas y permitirán reconectarse.

## Estado

P03 completada: proyecto Godot ejecutable, pantalla inicial con dos cartas de prueba, recarga del catálogo y manejo de errores. Todavía no hay partida jugable ni salas. El contenido de ejemplo no es un catálogo oficial.

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

La raíz Git es esta carpeta, mistborn-deck-builder/, dentro del espacio mistborn-deckbuilder/. La documentación acompaña al código para recuperar el contexto en futuras sesiones.
