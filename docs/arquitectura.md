# Arquitectura

## Implementación existente

El único flujo implementado es:

`data/cartas.json` → `scripts/Database.gd._ready()` → diccionario `cartas`, indexado por ID.

No existe `project.godot`; tampoco hay evidencia de que `Database.gd` esté conectado a una escena o declarado como Autoload.

## Organización prevista

Las carpetas base siguen las instrucciones originales: `data/`, `scripts/`, `scenes/` y `assets/images/`. Solo las dos primeras tienen contenido hoy. No se fijan aún nombres de clases o subcarpetas para sistemas inexistentes.

Separar responsabilidades a medida que se implementen:

| Área | Responsabilidad |
| --- | --- |
| Catálogo | Cargar y validar definiciones estáticas de cartas. |
| Estado de partida | Jugadores, zonas, recursos, turno y demás valores de una partida concreta. |
| Reglas | Validar acciones y producir cambios de estado conforme al reglamento confirmado. |
| Presentación | Mostrar el estado visible y recoger acciones del jugador. |
| Red | Transportar acciones y actualizaciones, identificar participantes y gestionar conexión. |

La estructura anterior es una guía de separación de responsabilidades; no describe componentes ya construidos. Una definición del catálogo y una instancia de carta en una partida deberán distinguirse para no modificar accidentalmente el contenido compartido.

## Modos y rival del juego

Alcance confirmado el 2026-10-27: competitivo 2–4, cooperativo 2–4 y solitario cooperativo 1. El diseño debe compartir motor y diferenciar preparación, objetivos legales, Target, paso rival y finales. El solitario usa el mismo motor en una instancia local; las sesiones de grupo añaden transporte.

El rival cooperativo necesita mazo/descarte, salud, casilla/cara de Dominación y adversarios con escudos persistentes. No requiere una IA estratégica que simule a un participante. Habrá secuencias pausables para elecciones y reacciones fuera del turno activo, incluidas Cloud y asignaciones colectivas. Estas son necesidades derivadas del reglamento; sus contratos técnicos aún se diseñarán en P06/P07.

Ver [SPEC-002](specs/002-modos-y-cooperativo/spec.md) para aceptación, tareas y límites. La autoridad de reglas debe resolver también el mazo rival, en vez de dejar que cada cliente lo resuelva por separado.

## Decisiones pendientes para jugar a distancia

- Plataforma de los jugadores: escritorio, navegador u otra combinación.
- Versión exacta de Godot y forma de distribuir o ejecutar el juego.
- Quién valida la partida: anfitrión u otro servicio.
- Forma de crear y unirse a salas, requisitos de conectividad y alojamiento.
- Visibilidad de manos, mazos y otra información privada según el reglamento.
- Comportamiento ante desconexión, abandono, reconexión y cierre del anfitrión.
- Necesidad de guardar o reanudar partidas.

Antes de elegir transporte o infraestructura, registrar estas necesidades y una decisión en [decisiones](decisiones.md). El desarrollo inicial puede avanzar con una partida local para validar las reglas, manteniendo la separación de responsabilidades.

El [plan por fases](plan-de-trabajo.md) incorpora una prueba temprana de acceso entre redes en P04, antes de construir todo el motor. La partida local completa llega en P10 y la sincronización del juego real en P14. La prueba técnica de P04 no equivale a implementar el multijugador definitivo.

La plataforma inicial es una aplicación Windows: todos los participantes tienen ese sistema, confirmado el 2026-10-27. Tablero 2D sigue como propuesta visual de P05. Exportación y compatibilidad se concretarán para Windows; transporte y servicio siguen pendientes de P04. La versión exacta de Godot y la herramienta de pruebas se decidirán en P03.

## Criterios propuestos para la futura red

La autoridad elegida debería validar identidad, turno, recursos y legalidad de cada acción; los clientes deberían recibir solo el estado que les corresponde ver. El barajado y otros resultados aleatorios deberían resolverse de forma consistente para todos los participantes. Estos criterios aún no tienen implementación ni protocolo acordado.
