# Arquitectura

## Implementación existente

Flujo implementado en P03:

`project.godot` → Autoload `Database` → `data/cartas.json` → diccionario por ID y señales de carga → `scenes/MainScreen.tscn` → vistas de ejemplo en `CardPreview.tscn`.

Godot 4.7.2, Compatibility. Database carga antes de la escena. MainScreen conecta señales y consulta el estado inicial; el botón de recarga usa el mismo cargador. Una carga fallida retira las vistas anteriores y muestra el diagnóstico. No se ejecutan efectos ni reglas.

P06 amplía el flujo: sobre v1 en cartas.json → catalog_validator.gd → definiciones, conteos/avisos y selección verificada → Database mediante copias profundas → vista inicial con texto_original/resumen y etiqueta de revisión. Definiciones e instancias se separan; el JSON no almacena propietario, zona o decisiones de partida. Contrato en [datos de cartas](datos-de-cartas.md).

Errores de forma/referencias/revisión rechazan todo; imagen pendiente permite sustituto con aviso. Una carta verificada no puede depender de un borrador. El motor futuro consumirá get_verified_definitions(), aplicando además sus propias reglas/pruebas: el estado verificada es declaración de revisión de contenido, no implementación de efectos. El catálogo actual devuelve cero definiciones verificadas.

## Organización prevista

Las carpetas `data/`, `scripts/`, `scenes/` y `assets/images/` ya tienen contenido. `tests/` contiene comprobaciones de arranque, conexión, estado, acciones, preparación y capturas; `tools/` contiene el lanzador PowerShell. `.tools/` guarda solo el motor local ignorado. El experimento de red vive en `scripts/network/`; `scripts/game/` contiene estado, invariantes, procesador de acciones, proyección y preparación estructural.

## Experimento de red de P04

`MainScreen` → botón Probar conexión → `ConnectionScreen` → Node `connection_probe.gd` → ENetMultiplayerPeer y paquetes JSON UTF-8 fiables. La sesión es dueña del peer y lo cierra al salir. La interfaz observa señales; no valida ni aplica el contador por su cuenta.

El anfitrión valida versión/clave/nombre y admite hasta tres invitados. Solo él incrementa el contador, controla secuencias por conexión y publica snapshots de nombres/IDs, contador y revisión. No se envían cartas privadas ni la clave en snapshots. Ningún cliente puede imponer un snapshot al anfitrión. Paquetes de máximo 2048 bytes, hasta 64 por frame; admisión con timeout de 10 segundos. No hay RPC ni deserialización de objetos de red.

Esta sesión no modela reglas ni plazas persistentes. Desconectar retira el participante y volver a entrar crea otra conexión; no satisface P15. ENet/anfitrión está elegido para el experimento (DEC-014), con prueba local y decisión final de acceso pendiente. [SPEC-004](specs/004-conexion-temprana/plan.md) conserva alternativas y [guía](prueba-de-conexion.md) los pasos de ensayo.

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

La [maqueta de P05](diseno-visual.md) vive en `scenes/BoardPreview.tscn` y `scripts/board/`: board_preview compone la vista, board_card representa cartas, board_style conserva estilos/atlas y board_samples el contenido ficticio. No se conecta a Database ni al prototipo de red. Las cartas se identifican por IDs de muestra y el movimiento a mesa es visual/reversible, sin ejecutar efectos. Se recupera el escalado de ventana al salir.

Alcance confirmado el 2026-10-27: competitivo 2–4, cooperativo 2–4 y solitario cooperativo 1. El diseño debe compartir motor y diferenciar preparación, objetivos legales, Target, paso rival y finales. El solitario usa el mismo motor en una instancia local; las sesiones de grupo añaden transporte.

El rival cooperativo necesita mazo/descarte, salud, casilla/cara de Dominación y adversarios con escudos persistentes. No requiere una IA estratégica que simule a un participante. Habrá secuencias pausables para elecciones y reacciones fuera del turno activo, incluidas Cloud y asignaciones colectivas. Estas necesidades derivan del reglamento. P07 ya representa rival y continuaciones; las ventanas y efectos reglamentarios se concretarán en P08/P09.

Ver [SPEC-002](specs/002-modos-y-cooperativo/spec.md) para aceptación, tareas y límites. La autoridad de reglas debe resolver también el mazo rival, en vez de dejar que cada cliente lo resuelva por separado.

## Decisiones pendientes para jugar a distancia

- Plataforma acordada: aplicación para Windows; concretar compatibilidad y distribución.
- Godot 4.7.2 y ejecución local resueltos; distribución a los amigos pendiente de P18.
- Quién valida la partida final: anfitrión u otro servicio; el experimento P04 usa anfitrión como autoridad.
- Salas privadas sin cuentas acordadas; concretar invitación/código, conectividad y alojamiento.
- Visibilidad de manos, mazos y otra información privada según el reglamento.
- Reconexión a la misma plaza obligatoria; concretar pausa, reserva de plaza, abandono y pérdida del anfitrión.
- Necesidad de guardar o reanudar partidas.

Antes de elegir transporte o infraestructura, registrar estas necesidades y una decisión en [decisiones](decisiones.md). El desarrollo inicial puede avanzar con una partida local para validar las reglas, manteniendo la separación de responsabilidades.

El [plan por fases](plan-de-trabajo.md) incorpora una prueba temprana de acceso entre redes en P04, antes de construir todo el motor. La partida local completa llega en P10 y la sincronización del juego real en P14. La prueba técnica de P04 no equivale a implementar el multijugador definitivo.

La plataforma inicial es Windows. La maqueta de tablero 2D de P05 está aceptada como dirección visual inicial. Se ha fijado Godot 4.7.2; las pruebas usan GDScript sin framework externo. Transporte y servicio del producto siguen pendientes de P04; existe una sesión de ensayo funcional, sin partida.

## Criterios propuestos para la futura red

La sesión debe distinguir identidad temporal del jugador, conexión de transporte y plaza. Un cambio de conexión no implica crear otro jugador. La reconexión deberá recuperar la vista autorizada del estado y las elecciones pendientes, conservando los identificadores de acciones ya aplicadas para no repetirlas.

La recuperación requiere demostrar posesión de la sesión propia; diseñar un mecanismo temporal compatible con no tener cuentas. Mantenerlo separado del nombre mostrado y del código compartido de sala. La política de pausa y el tiempo de retención siguen pendientes; el cierre de P15 exige resolverlos y probarlos.

La autoridad elegida debería validar identidad, turno, recursos y legalidad de cada acción; los clientes deberían recibir solo el estado que les corresponde ver. El barajado y otros resultados aleatorios deberían resolverse de forma consistente para todos los participantes. Estos criterios aún no tienen implementación ni protocolo acordado.

## Núcleo local de P07 implementado

[SPEC-007](specs/007-estado-y-acciones/spec.md) y su [plan](specs/007-estado-y-acciones/plan.md) definen núcleo independiente de escenas/transporte: estado privado completo, instancias separadas del catálogo, invariantes, transacciones sobre copia, RNG propio y recibos por plaza estable. Las proyecciones se construirán por lista permitida; eventos, errores y recibos tampoco expondrán secretos. Zonas de visibilidad pendiente usan una restricción técnica provisional explícita.

T07.1/2 implementadas en scripts/game/: almacén privado RefCounted, invariantes, procesador transaccional con RNG y recibos, y proyecciones por jugador. 1.725 comprobaciones del estado y 102 del motor; contrato y evidencia en SPEC-007. get_authority_snapshot y load_authority_snapshot son solo para autoridad; los clientes reciben get_view y nunca el snapshot completo. Los manejadores registrados actualmente son exclusivamente fixtures de tests, no reglas de producto. El diseño no elige alojamiento ni convierte el prototipo de contador en salas; preparación y reglas concretas siguen en P08/P09.

## Preparación local de P08

`game_setup.gd` construye un snapshot validado desde un manifiesto físico completo y definiciones declaradas verificadas. El manifiesto sigue separado de Database y del snapshot; el adaptador futuro deberá derivarlo del catálogo contrastado. Se sortean personajes/misiones y primer jugador cooperativo, se barajan mazos, se revela mercado, se reparten manos y se aplican diferencias iniciales por modo. La pista de entrenamiento queda referenciada en cada jugador y la fase `inicio` espera su avance obligatorio. La versión del motor cambia a `p08-setup-1/godot-4.7.2`. T08.1a cuenta con 147 comprobaciones; sin catálogo real ni manejadores de entrenamiento/efectos, el constructor no produce una partida jugable del producto.
