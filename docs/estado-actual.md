# Estado actual

Última revisión: 2026-10-27.

## Resumen

El proyecto está en fase inicial de datos y carga. No hay una aplicación ejecutable ni una implementación de las reglas del juego.

## Inventario verificado

| Elemento | Estado observado |
| --- | --- |
| `scripts/Database.gd` | Nodo que lee `res://data/cartas.json` en `_ready()` e indexa las entradas por `id` en un `Dictionary`. |
| `data/cartas.json` | Array con dos cartas de prueba: `moneda_de_cobre` y `kelsier`. |
| `data/instrucciones.md` | Ubicación original de las pautas; ahora remite al `AGENTS.md` principal. |
| `.gitignore` | Excluye caché de Godot, compilación Android, configuración de exportación, traducciones generadas y algunos archivos del sistema. |
| `AGENTS.md`, `README.md`, `docs/` | Instrucciones, orientación y memoria documental incorporadas en esta revisión. |
| `docs/gestion/`, `docs/specs/`, `docs/referencias/` | Flujo SDD, backlog, dos especificaciones en borrador, fuente SRC-001, 67 reglas documentadas, componentes y dudas; sin implementación de reglas. |
| `.github/ISSUE_TEMPLATE/`, `.github/pull_request_template.md` | Plantillas de tarea, error, investigación y PR incluidas en la entrega documental; GitHub las toma de la rama principal publicada. |

El repositorio Git está en `mistborn-deck-builder/`, no en su carpeta contenedora. Al iniciar la revisión estaba limpio, en la rama `main`, con dos commits; el último era `3806537` (ficheros de prueba de base de datos y cartas).

## Lo que falta

- `project.godot`, escena principal y configuración de inicio.
- Escenas, imágenes y demás recursos visuales.
- Conexión del cargador a una escena o configuración como Autoload.
- Motor de reglas, estado de partida, turnos, zonas de cartas y victoria.
- Interfaz de partida, salas y comunicaciones entre jugadores.
- Pruebas automatizadas, integración continua e instrucciones de ejecución comprobadas.

## Hallazgos del código y los datos

1. El cargador maneja errores de apertura, parseo y raíz distinta de array, pero no valida que cada entrada sea un objeto con campos y tipos válidos.
2. No detecta IDs duplicados: una entrada posterior puede sobrescribir una anterior en el diccionario.
3. No limpia el diccionario antes de cargar. No existe todavía una API de recarga; habrá que definir ese comportamiento si se añade.
4. El tipado estático es parcial; la pauta existente pide ampliarlo donde sea posible.
5. Las rutas de imagen apuntan a `res://assets/cartas/`, mientras la convención original proponía `assets/images/`. Ninguna de esas imágenes existe.
6. `efecto` es texto descriptivo. El cargador no ejecuta efectos ni implementa reglas.
7. El contenido de las dos cartas no se ha contrastado con cartas oficiales; SRC-001 confirma que el contrato de datos es insuficiente para los tipos y efectos reales.

## Verificación y límites

Se inspeccionaron todos los archivos de contenido originales, el historial breve y el estado de Git. Se comprobó la estructura básica del JSON y los enlaces locales de la documentación al cerrar la tarea.

No se ejecutó Godot. No se encontró `godot` ni `godot4` en el `PATH` de esta sesión; esto no demuestra que no estén instalados en otra ubicación. Además, falta `project.godot`.

## Planificación y producto

El plan tiene P00–P18 con dependencias y cierre. P00 y el inventario inicial de P01 están completados documentalmente. No está resuelto todo el catálogo ni toda duda de reglas. El usuario confirma idioma español, máximo cuatro humanos y modos competitivo 2–4, cooperativo 2–4 y cooperativo en solitario. Busca fidelidad y un resultado visual cuidado.

El PDF recibido es inglés: Mistborn: The Deckbuilding Game, Brotherwise Games, 1.ª edición/1.ª impresión, 2024, 20 páginas. Se extrajo texto y se revisaron visualmente todas las páginas; pypdf omitía bloques que pdfplumber sí recuperó. Ruta, tamaño y SHA-256 están en [fuentes](referencias/README.md). El original sigue fuera de la raíz Git, sin modificar ni subir.

Se documentaron REG-001 a REG-067, componentes y siete dudas. El PDF no incluye el catálogo completo de cartas/pistas y falta contraste con la localización española. [SPEC-002](specs/002-modos-y-cooperativo/spec.md) añade rival, Dominación, escudos, edictos y siete configuraciones de prueba. Backlog ampliado a 43 tareas; T01.1 y T01.2 son avance documental, no implementación.

Windows es la plataforma inicial confirmada: el usuario indica que todos tienen Windows. El tablero 2D sigue como propuesta visual. Versión mínima, hardware y resoluciones se concretarán en P03/P05; acceso/desconexión y catálogo detallado siguen pendientes. El solitario comparte reglas con el cooperativo.

Remoto: `pablobarderas/mistborn-deck-builder`, público, rama principal `main`. La consulta de issues del 2026-10-26 no devolvió ninguna. El 2026-10-27 el usuario autoriza commit y push de las bases documentales a `origin/main`; la sincronización se comprueba comparando `HEAD` y la revisión remota tras publicar. Esta entrega no crea issues, etiquetas, hitos ni PR.

Siguiente trabajo: T02.1 del [backlog](gestion/backlog.md), concretar acceso y desconexión; incorporar cartas/pistas españolas por lotes para completar el catálogo y resolver dudas. No volver a preguntar sistema operativo, participantes ni inclusión de cooperativo: ya están confirmados.
