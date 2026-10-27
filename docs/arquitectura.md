# Arquitectura

## Implementación existente

Flujo implementado en P03:

`project.godot` → Autoload `Database` → `data/cartas.json` → diccionario por ID y señales de carga → `scenes/MainScreen.tscn` → vistas de ejemplo en `CardPreview.tscn`.

Godot 4.7.2, Compatibility. Database carga antes de la escena. MainScreen conecta señales y consulta el estado inicial; el botón de recarga usa el mismo cargador. Una carga fallida retira las vistas anteriores y muestra el diagnóstico. No se ejecutan efectos ni reglas.

## Organización prevista

Las carpetas `data/`, `scripts/`, `scenes/` y `assets/images/` ya tienen contenido. `tests/` contiene comprobación de arranque y captura gráfica; `tools/` contiene el lanzador PowerShell. `.tools/` guarda solo el motor local ignorado. No se crean aún clases para sistemas de reglas o red inexistentes.

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

- Plataforma acordada: aplicación para Windows; concretar compatibilidad y distribución.
- Godot 4.7.2 y ejecución local resueltos; distribución a los amigos pendiente de P18.
- Quién valida la partida: anfitrión u otro servicio.
- Salas privadas sin cuentas acordadas; concretar invitación/código, conectividad y alojamiento.
- Visibilidad de manos, mazos y otra información privada según el reglamento.
- Reconexión a la misma plaza obligatoria; concretar pausa, reserva de plaza, abandono y pérdida del anfitrión.
- Necesidad de guardar o reanudar partidas.

Antes de elegir transporte o infraestructura, registrar estas necesidades y una decisión en [decisiones](decisiones.md). El desarrollo inicial puede avanzar con una partida local para validar las reglas, manteniendo la separación de responsabilidades.

El [plan por fases](plan-de-trabajo.md) incorpora una prueba temprana de acceso entre redes en P04, antes de construir todo el motor. La partida local completa llega en P10 y la sincronización del juego real en P14. La prueba técnica de P04 no equivale a implementar el multijugador definitivo.

La plataforma inicial es Windows. Tablero 2D sigue como propuesta visual de P05. Se ha fijado Godot 4.7.2; las pruebas de P03 se ejecutan en GDScript sin framework externo. Transporte y servicio siguen pendientes de P04; la escena actual es una base de desarrollo, no una sala funcional.

## Criterios propuestos para la futura red

La sesión debe distinguir identidad temporal del jugador, conexión de transporte y plaza. Un cambio de conexión no implica crear otro jugador. La reconexión deberá recuperar la vista autorizada del estado y las elecciones pendientes, conservando los identificadores de acciones ya aplicadas para no repetirlas.

La recuperación requiere demostrar posesión de la sesión propia; diseñar un mecanismo temporal compatible con no tener cuentas. Mantenerlo separado del nombre mostrado y del código compartido de sala. La política de pausa y el tiempo de retención siguen pendientes; el cierre de P15 exige resolverlos y probarlos.

La autoridad elegida debería validar identidad, turno, recursos y legalidad de cada acción; los clientes deberían recibir solo el estado que les corresponde ver. El barajado y otros resultados aleatorios deberían resolverse de forma consistente para todos los participantes. Estos criterios aún no tienen implementación ni protocolo acordado.
