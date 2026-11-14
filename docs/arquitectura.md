# Arquitectura

## Objetivos y permanente M2 — T08.1b20

[M2Play](../scripts/game/m2_play.gd) y [AllyTargets](../scripts/game/ally_targets.gd) admiten sólo M2/M5/M7 con aliados inertes de autoridad. P07 escoge una ruta: directa para automáticos/cimas o `m2_first_v1` para la primera llegada en 4/7/10. Gasto/llegada/normal se confirman hasta selección obligatoria; sin candidatos, cierre automático con grupo/ledger. La proyección `option_allies` es específica del destinatario. `GameEngine.get_view` aporta las definiciones congeladas a `GameProjection.project`; el argumento adicional de catálogo es opcional para conservar llamadas previas, no una entrada de cliente. El helper de objetivos se comparte entre oferta, traslado y proyección. Cada traslado va al descarte del propietario y mantiene RNG; delta protegido se recalcula antes del commit.

Snapshot 7/motor `p08-m2-defeat-1/godot-4.7.2`, sin migración desde 6. M2 deriva marca temporal por grupo liquidado e inicio interno aplica entrenamiento/+2 ataque/apertura juntos; M3 conserva monedas en su perfil. Presupuesto por todas las ramas/destinos y vistas, sin truncar opciones. No expone limpieza ni cartas/reacciones de producto. [Contrato](specs/008-preparacion-y-turnos/elecciones-m2.md) y [evidencia](specs/008-preparacion-y-turnos/verification.md#t081b20--implementación-de-objetivos-y-premios-m2). Los apartados inferiores conservan versiones históricas.

## Elecciones de misión — T08.1b16

Implementación verificada del [contrato M8](specs/008-preparacion-y-turnos/elecciones-m8.md). [m8_play.gd](../scripts/game/m8_play.gd) registra el perfil aislado M5/M7/M8 sobre el candidato compartido de misiones y un registro congelado. P07 selecciona una sola ruta DIRECT/SEQUENCE desde código de autoridad: la tercera cima termina por ruta directa; las llegadas no terminales con premio M8 realizan gasto y llegada en `s01` y pausan después para normal/extra. Las respuestas y el cierre conservan commits, recibos y ledger de P07.

El registro incorpora límite de opciones por programa (16 por defecto, 10.000 para M8), binding de resolución y predicado tipado `auto_empty`. Las ventanas vacías admitidas se liquidan internamente; una oferta inválida sigue siendo error. La proyección sólo da `option_cards` al destinatario para relacionar tokens con instancias propias de mano/descarte/juego. El perfil valida grupos pendientes contra cursor/llegada y recalcula el delta autorizado antes del commit; la restauración exige fuente tipada e instancia vacía. El presupuesto previo simula omisiones y reserva las respuestas/cierre restantes, también al cargar una pausa.

Snapshot 5/motor `p08-m8-choices-1/godot-4.7.2`, sin migración implícita desde 4. 15 suites/8.418 comprobaciones, revisión independiente favorable; [evidencia](specs/008-preparacion-y-turnos/verification.md#t081b16--implementación-de-elecciones-y-eliminación-m8). La guarda final valida el RNG ya sellado frente a la autoridad anterior, pues este perfil no consume azar. Las misiones son reales del lote; restantes cartas, pista y reservas son fixtures inertes. No incorpora entrada a limpieza, interfaz, producto ni modos con rival; las versiones inferiores son antecedentes.

## Permanentes de misión — T08.1b14

[permanents_play.gd](../scripts/game/permanents_play.gd) compone el perfil aislado M3/M4/M7 sobre el candidato compartido de misiones. Las entradas internas `start_turn` y `finish_cleanup` usan recibos P07 y namespaces reservados; la entrada pública conserva únicamente `avanzar_mision`. Inicio confirma entrenamiento, +2 de M3, marca privada y apertura de libre juntos. Limpieza deriva mano 5/6 de M4, conserva sus guardas y entrega inicio al siguiente vivo. No implementa entrada desde libre a limpieza.

Snapshot 4/motor `p08-permanents-1/godot-4.7.2`, sin migración implícita desde esquema 3. `authority.mission_permanents` conserva adquisición/última aplicación de M3; las vistas excluyen toda la autoridad privada. Catálogo v2 y perfil anterior M5/M6/M7 se conservan; componentes restantes, pista y reservas siguen siendo fixtures. [Contrato](specs/008-preparacion-y-turnos/permanentes-misiones.md) y [estado de verificación](specs/008-preparacion-y-turnos/verification.md#t081b14--implementación-de-permanentes-m3m4). Los apartados siguientes conservan versiones históricas.

## Misiones automáticas — T08.1b12

[mission_advance.gd](../scripts/game/mission_advance.gd) genera un candidato sobre copia: gasto neto unitario, primera llegada, premio normal/extra y final por tres misiones según DEC-034. [mission_play.gd](../scripts/game/mission_play.gd) registra sólo `avanzar_mision`, valida el catálogo v2 completo y descriptores confiables, y selecciona exclusivamente M5/M6/M7. P07 conserva el commit/recibo/RNG; no se relajan las guardas de secuencia. Training comparte núcleo entre la entrada de inicio y `advance_for_mission` en libre, sin cambiar temporalmente la fase. `restore_match` exige fuente tipada del último estado confirmado e instancia vacía; el llamador fiable serializa la autoridad. No existe entrada cliente para cargar un estado.

Esquema 3, motor `p08-missions-1/godot-4.7.2`: recurso temporal `mision`, primeras llegadas por casilla y resultado terminal. La proyección conserva la privacidad de mano/mazo y metadatos de autoridad. Catálogo de ocho misiones real, demás componentes y reservas del perfil son fixtures explícitos; no hay producto integrado ni generadores de puntos. [Contrato, límites y plan](specs/008-preparacion-y-turnos/avance-misiones.md). Permanentes de inicio y misiones con elecciones siguen pendientes.

## Adaptador Funding — T08.2h

[funding_play.gd](../scripts/game/funding_play.gd) extiende GameEngine y registra exclusivamente `jugar_funding`/`funding_play_v1`. Recibe catálogo P06 completo, ID Funding y mapa de descriptores inertes confiables; P06 valida estructura/revisión y el adaptador limita la semántica. Juega una instancia propia en `libre`, competitivo 2–4, con elección aplicar/omitir: mano→juego y +1/+0 recursos del turno. No abre fases ni conecta UI/red. Pruebas y revisión en [evidencia T08.2h](specs/008-preparacion-y-turnos/verification.md#t082h--implementación-de-funding).

`catalog_identity()` es la identidad técnica `funding_`+SHA-256 del catálogo completo canonicalizado, diferente de su `id_catalogo` editorial. Ordena claves, conserva orden de arrays y normaliza números integrales JSON; el perfil exige una única Funding y que todos los descriptores inertes coincidan exactamente con el contenido validado. Cambiar contenido impide cargar cierres antiguos aun manteniendo ID editorial. Las copias y recibos siguen en P07; callbacks del registro son estáticos con ID Funding escalar enlazado.

Rechaza marcas dinámicas no soportadas (contadores de turno, usos de jugador/instancia, flags y recompensas de misión), overflow y contenedores incompatibles con la escritura. Conserva esquema 2 y cambia versión a `p08-funding-1/godot-4.7.2`, sin migración implícita. Los componentes inertes y la definición que representa la regla son fixtures; no se ha incorporado catálogo español verificado. Las versiones y límites inferiores conservan el historial de las entregas anteriores.

## Contrato de Atium — T08.2c

Ampliación implementada, pruebas locales aprobadas; revisión independiente favorable: `persistent.atium` representa el total de fichas de Atium de la plaza, incluidas las usadas pendientes de devolución; debe ser igual al conteo de `metal=atium` en `metals`. No es una reserva adicional. Las disponibles son las no usadas. Toda futura ganancia/gasto debe actualizar agregado y fichas en la misma transacción. El subconjunto exige Atium no agotado, porque no admite Flaring; no generaliza excepciones de cartas no verificadas. Versión de motor `p08-atium-1/godot-4.7.2`, esquema v1, rechazo de versiones previas sin migración heurística.

`turn_cleanup.gd` retira sólo fichas de Atium usadas del activo y descontará igual cantidad del total dentro de su copia transaccional, antes de publicar cartas/fase/RNG; el fallo posterior revierte todo. No hay suministro global limitado. Este contrato sustituye la independencia saldo/fichas y guardia de Atium usado descritas históricamente en T08.2b; mantiene las otras guardias. [AC-15–18](specs/008-preparacion-y-turnos/spec.md#t082c--saldo-y-devolución-de-atium).

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

[Contrato de secuencias T08.2e/f](specs/008-preparacion-y-turnos/secuencia-reanudable.md): registro cerrado, ejecución hasta ventana/cierre, contexto privado y registro persistido de cierre por ocurrencia. T08.2f añade esquema v2 y motor `p08-sequence-1/godot-4.7.2`, sin migración de snapshots anteriores; implementación verificada y revisión independiente favorable. P07 controla el cierre y conserva historial/recibos/RNG atómicamente. Sólo el destinatario recibe el paso y opciones de la ventana; el cursor permanece privado. Los programas y operaciones concretos viven exclusivamente en tests; no hay transición de combate a limpieza. [API y compatibilidad](specs/007-estado-y-acciones/plan.md#extensión-v2-de-t082f).

[SPEC-007](specs/007-estado-y-acciones/spec.md) y su [plan](specs/007-estado-y-acciones/plan.md) definen núcleo independiente de escenas/transporte: estado privado completo, instancias separadas del catálogo, invariantes, transacciones sobre copia, RNG propio y recibos por plaza estable. Las proyecciones se construirán por lista permitida; eventos, errores y recibos tampoco expondrán secretos. Zonas de visibilidad pendiente usan una restricción técnica provisional explícita.

T07.1/2 implementadas en scripts/game/: almacén privado RefCounted, invariantes, procesador transaccional con RNG y recibos, y proyecciones por jugador. 1.725 comprobaciones del estado y 102 del motor; contrato y evidencia en SPEC-007. get_authority_snapshot y load_authority_snapshot son solo para autoridad; los clientes reciben get_view y nunca el snapshot completo. Los manejadores registrados actualmente son exclusivamente fixtures de tests, no reglas de producto. El diseño no elige alojamiento ni convierte el prototipo de contador en salas; preparación y reglas concretas siguen en P08/P09.

## Preparación local de P08

T08.2a añade `card_cycle.gd` como servicio interno de autoridad para robo/reciclado personal, descarte y limpieza de cartas conservando aliados. No registra acciones de cliente. El llamador aporta RNG transaccional y decide legalidad/momento; P07 debe envolver operaciones compuestas y persistir el RNG al commit. Errores no alteran snapshot ni RNG. T08.2i aplica DEC-032: al agotar mazo y descarte el robo finaliza con las cartas disponibles y se acepta incluso si no obtuvo ninguna. El servicio no cambia fases ni procesa entrenamiento, efectos, recursos o rival. Contrato, convenciones y evidencia en [SPEC-008](specs/008-preparacion-y-turnos/plan.md).

`game_setup.gd` construye un snapshot validado desde un manifiesto físico completo y definiciones declaradas verificadas. El manifiesto sigue separado de Database y del snapshot; el adaptador futuro deberá derivarlo del catálogo contrastado. Se sortean personajes/misiones y primer jugador cooperativo, se barajan mazos, se revela mercado, se reparten manos y se aplican diferencias iniciales por modo. La pista de entrenamiento queda referenciada en cada jugador y la fase `inicio` espera su avance obligatorio. La versión del motor cambia a `p08-setup-1/godot-4.7.2`. T08.1a cuenta con 147 comprobaciones; sin catálogo real ni manejadores de entrenamiento/efectos, el constructor no produce una partida jugable del producto.

T08.2b añade `turn_cleanup.gd`, servicio interno desde `limpieza` que compone descarte, resets temporales y robo de cinco antes de entregar `inicio` al siguiente superviviente competitivo o `rival` al mismo activo cooperativo/solo. La autoridad debe haber resuelto combate, Target, efectos y finales; el servicio no registra acciones públicas ni abre `libre`. Conserva agotamiento, persistentes y `burn_limit`; bloquea Atium usado hasta concretar su contabilidad y bloquea adversarios activos/flags/counters sin semántica. `ability_uses` propios se definen como usos temporales del turno propio. Contrato y verificación en [SPEC-008](specs/008-preparacion-y-turnos/spec.md#t082b--cierre-interno-de-limpieza-y-entrega-de-fase).
