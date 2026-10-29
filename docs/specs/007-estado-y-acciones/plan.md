# Plan de SPEC-007

Ampliación de contrato en T08.2c: `persistent.atium` es el total exacto de fichas `metal=atium` de cada plaza, incluidas usadas hasta limpieza; no reserva adicional. Atium no agotado en el subconjunto sin Flaring. La nueva semántica usa motor `p08-atium-1/godot-4.7.2` con la misma forma de esquema v1 y rechazo de snapshots previos, sin migración. [Contrato y AC-15–18](../008-preparacion-y-turnos/spec.md#t082c--saldo-y-devolución-de-atium); [verificación de la ampliación](../008-preparacion-y-turnos/verification.md#t082c--saldo-y-devolución-de-atium). Las versiones citadas debajo son históricas.

Diseño técnico con T07.1 y T07.2 implementadas y verificadas localmente; la fase P07 conserva dependencia de P04 externa. Se elige núcleo RefCounted tipado, con acceso mediante copias profundas, frente a reglas dentro de nodos de UI o RPC. No añade dependencias ni cambia Godot 4.7.2.

## Estado interno v1

Separar version_esquema (formato), version_motor (reproducción), revision (commit de acción) e identidad de catálogo/conjunto de definiciones congeladas al crear el núcleo. Una recarga de Database no modifica partidas ya creadas. Los snapshots internos son completos y privados; nunca se envían directamente.

| Bloque | Contenido mínimo |
| --- | --- |
| Partida | match_id, modo competitivo/cooperativo/solitario, plazas y orden estable, estado de ciclo, revisión. |
| Jugador | player_id estable, nombre visible, eliminado, salud, personaje, recursos persistentes (Atium/Boxings), reservas del turno (recursos/ataque), entrenamiento y contadores de habilidad. |
| Metales | Estado por ficha: metal, agotada y usada_en_turno; cantidad quemada y límite del turno separados. Atium conserva identidad y uso aparte. No deducir agotamiento del uso. |
| Instancia | instance_id, definition_id, owner_id nullable para suministro/rival y estado mutable específico. El contenedor de zona es la única fuente de ubicación. |
| Zonas | ID, tipo, titular nullable y lista ordenada de instance_id; índice 0 es cima en mazos. Mano/mazo/descarte/juego por jugador; mazo/posiciones de mercado, eliminadas y zonas rivales compartidas. Un hueco de mercado no es una instancia. |
| Turno | Número, jugador activo nullable, fase técnica, contadores y marcas de uso. P08 definirá transiciones legales; no aceptar nombres de fases arbitrarios. |
| Misiones | Definición, progreso por jugador, recompensas recibidas y orden de llegada explícitos; sin deducir desempates de orden de diccionarios. |
| Rival | Null en competitivo; en solo/cooperativo: salud, zonas, cara/casilla/valor visible de Dominación y adversarios vinculados al jugador enfrentado. Escudos destruidos por índice, sin daño parcial inventado. |
| Resolución | resolution_id, pasos pendientes ordenados, cursor, origen, destinatarios y elección/reacción pendiente con opciones legales. Sin closures, objetos de escena ni código textual. |
| Autoridad | Estado RNG, siguiente ID, recibos de acciones aceptadas y contexto interno necesario para reanudar. Nunca datos de conexión o credenciales. |

Invariantes estructurales: referencias resueltas; instancias únicas y presentes exactamente una vez; propietarios/plazas válidos; recursos enteros no negativos; contadores e índices dentro de su dominio declarado; actor y destinatarios existentes. Salud cero puede coexistir con resolución pendiente de eliminación: P09 definirá la secuencia, sin inferir automáticamente victoria. Los límites reglamentarios se aplicarán en sus manejadores y no se extrapolan del catálogo incompleto. Un snapshot inválido no reemplaza el estado anterior.

La API de producción recibe solo definiciones verificadas y comprueba además soporte de las operaciones usadas antes de admitirlas. Los tests inyectan un conjunto ficticio directamente en el constructor del núcleo; no añaden un interruptor de «permitir muestras» a la interfaz ni marcan las dos cartas actuales como verificadas.

## Intención y transacción

Entrada: version_accion=1, match_id, action_id único por plaza durante la partida, expected_revision, tipo y payload de claves conocidas. actor_id llega por un parámetro separado desde un adaptador de confianza. No aceptar snapshots, resultados aleatorios, player_id suplente ni deltas arbitrarios del cliente.

Orden de proceso:

1. Validar formato, partida e identidad autorizada.
2. Buscar recibo por (player_id, action_id). Igual contenido canónico —incluida revisión original— devuelve el mismo acuse; contenido diferente produce id_reutilizado. Comparar estructura normalizada, sin depender del orden de claves.
3. Validar expected_revision y manejador admitido; después turno, permisos, costes y resolución pendiente según el manejador.
4. Duplicar estado y RNG. Aplicar todos los pasos de la acción candidata y comprobar invariantes.
5. Publicar copia candidata, incrementar revisión una vez y guardar recibo de aceptación. Ante cualquier fallo descartar todo lo candidato, incluidos eventos, IDs y RNG.

Resultado: ok, codigo y revision; acuse aceptado con action_id y revision_aplicada. Los reintentos devuelven ese acuse histórico; la vista actual se consulta separadamente. Los rechazos no se almacenan ni consumen el ID. Retener recibos aceptados durante toda la sesión; su persistencia entre días queda fuera de alcance. Códigos mínimos: formato_invalido, partida_incorrecta, identidad_no_autorizada, version_incompatible, revision_obsoleta, id_reutilizado, accion_no_soportada, accion_ilegal, eleccion_invalida y estado_invalido. Mensajes públicos no interpolan cartas ocultas ni parámetros internos.

El núcleo solo despacha manejadores explícitos. T07 usa manejadores de prueba para transferir una instancia, consumir un recurso y barajar una zona con precondiciones; no ofrece esas operaciones como acciones de jugador. Las acciones reglamentarias de P08/P09 se registrarán allí con fuente y prueba. Continuar una resolución conserva cursor y destinatarios; ninguna respuesta de cliente decide un resultado aleatorio o una lista de opciones legales.

RNG por partida, mediante RandomNumberGenerator con seed/state capturables: las pruebas fijan semilla y conservan estado tras cada transacción. Reproducción limitada a misma versión del motor y núcleo, sin prometer secuencias entre versiones. P07 no requiere un generador propio ni criptografía. Semilla y estado nunca entran en proyecciones públicas.

## Proyección v1 por lista permitida

Construir una vista nueva campo a campo, sin duplicar el snapshot y borrar secretos después. Autorización del destinatario antes de producirla; sin ruta de espectador implícita.

| Información | Vista propia | Otras plazas |
| --- | --- | --- |
| Mano | Identidad/definición y orden | Solo cantidad |
| Mazo de jugador, mercado o rival | Solo cantidad | Solo cantidad |
| Descarte propio | Cartas consultables | Solo cantidad por política provisional |
| Eliminadas | Cartas consultables, REG-011 | Igual |
| Mercado revelado y cartas boca arriba en juego | Identidad y estado visible | Igual |
| Descarte rival | Solo cantidad hasta confirmar visibilidad | Igual |
| Jugadores, turno, recursos visibles, misiones, Target y rival revelado | Campos visibles declarados | Igual |
| Elección pendiente | Opciones solo si destinatario; pueden contener información autorizada por su manejador | Solo bloqueo y destinatarios; sin opciones privadas |
| RNG, recibos, colas internas y cartas futuras | Ausentes | Ausentes |

No revelar IDs de instancias ocultas, orden ni definición a través de eventos, recibos o mensajes. Los eventos internos no se difunden; generar eventos autorizados por destinatario o limitar inicialmente la salida a acuses y snapshot proyectado. Las opciones de cada futuro manejador tendrán política explícita; no basta incluirlas en una elección propia para autorizar cartas ajenas. La proyección conservadora de descartes ajenos/rivales es una restricción técnica temporal pendiente de contraste, no una decisión del usuario.

## Archivos previstos y verificación

Implementados scripts/game/ para estado, invariantes, núcleo y proyección; tests/game_state_test.gd y game_engine_test.gd, y acciones test-state/test-engine en tools/godot.ps1. La continuación se almacena en el estado y la aplica un manejador registrado. No crear carpetas vacías ni reutilizar el contador P04 o el movimiento visual P05. Mantener intactos catálogo y escenas.

T07.1/2 se probaron en Godot headless mediante AC-01–09, incluyendo fallo después de consumir RNG y modificar varias zonas, duplicado tras acciones intermedias, cambio de actor y mutaciones de vistas. Comparar snapshots completos antes/después de rechazo. Probar privacidad mediante dos estados que solo difieran en secretos y deban producir la misma vista ajena.

Ejecutar test-state y regresión test-catalog/test al implementar. No se requiere captura por esta entrega de núcleo. La integración de transporte y la prueba externa se mantienen en sus fases; no sustituyen los tests locales ni quedan acreditadas por ellos.

## Contrato interno implementado en T07.1

- [game_state.gd](../../../scripts/game/game_state.gd): RefCounted construido con definiciones y catalog_id de confianza, congelados por copia. try_load(document) valida y reemplaza íntegramente el snapshot solo si es válido; devuelve ok/errors y emite aviso genérico en rechazo. get_snapshot/get_definition entregan copias profundas. No es una API de cliente ni ejecuta acciones; la admisión de contenido verificado/soportado corresponde al futuro núcleo T07.2. No hay opción de muestras en la UI.
- [state_validator.gd](../../../scripts/game/state_validator.gd): esquema interno v1, version_motor p07-engine-2/godot-4.7.2 (cambia tras incorporar acciones y recibos; no se promete reproducir snapshots de la versión anterior). Claves desconocidas y campos ausentes se rechazan. Tipado estricto: Dictionary/Array, String, bool, int64 y null donde se indica; no objetos, Callable, float ni StringName. Usar claves String explícitas al crear entradas. No se carga JSON de estado: puede perder precisión del RNG int64. El round-trip Variant es una prueba interna, no un protocolo ni formato de guardado aprobado.
- Raíz: version_esquema, version_motor, catalog_id, match_id, mode, revision, lifecycle, players, player_order, instances, zones, turn, missions, target_id, rival, resolution, authority. Los nombres de los modos son los documentados. lifecycle admite sin_preparar/en_curso/finalizada; turn.phase admite sin_iniciar/inicio/libre/combate/limpieza/rival/finalizada. P08 todavía debe validar sus transiciones; aceptar un snapshot no demuestra legalidad de su historia.
- Cada jugador contiene player_id, name, eliminated, health, character_id nullable, persistent (atium/boxings), turn_resources (recursos/ataque), training, ability_uses, metals, burned y burn_limit. Cada ficha tiene token_id (único dentro de la plaza), metal, exhausted y used_this_turn. Metales y recursos no se inicializan a valores de preparación oficiales. Los mapas de contadores pueden estar vacíos.
- Instancias indexadas por ID: instance_id, definition_id, owner_id nullable y state (ability_uses, flags booleanas). Cada zona contiene zone_id, kind, holder_id nullable y cards en orden; es la única fuente de ubicación. Son obligatorias las cuatro zonas personales por plaza y mazo_mercado/mercado/eliminadas compartidas. Las demás zonas rivales se referencian desde rival. No se admiten dos zonas del mismo tipo/titular. El mercado revelado es una lista ordenada de cartas, sin entradas null; la representación de sus reposiciones y posiciones reglamentarias se concretará en P08/P09.
- Las zonas personales exigen propietario coincidente; suministro y zonas rivales exigen owner_id null. Eliminadas permite conservar propietario o cartas del suministro. Una instancia no puede quedar huérfana, repetida o en dos posiciones. No se ofrecen métodos de movimiento de jugador: los tests sustituyen snapshots de autoridad para comprobar el modelo.
- Misiones indexadas por ID local: definition_id, progress/rewards por todas las plazas y arrival_order sin repetidos. El cero de progress es representación técnica de no haber avanzado; recompensas son IDs, sin deducir desempates ni condiciones de llegada. Rival: definition_id nullable, health, deck_zone/discard_zone/adversary_zone, domination (definition_id nullable, face/position/visible_value) y adversaries por instancia (facing_id, destroyed_shields). Escudos: índices únicos dentro de rasgos.escudos; el orden de destrucción reglamentario se ejecutará en P09. No se inventan valores de pistas faltantes.
- Resolución: resolution_id, source_id nullable (instancia o definición existente), steps como IDs únicos ordenados, cursor dentro de steps, recipients y pending nullable. Pending tiene kind eleccion/reaccion, recipients incluidos en la resolución, options como IDs únicos y min/max válidos. Almacena una continuación, sin resolverla ni comprobar legalidad de opciones contra reglas aún no implementadas.
- Authority conserva rng_seed/rng_state int64, next_id no negativo y receipts por plaza/acción. Cada recibo contiene canonical (representación ordenada de la intención admitida) y revision_aplicada; la versión de estado y las referencias se validan antes de cargar. El núcleo conserva todos los recibos aceptados durante la sesión; no hay persistencia entre días. Los límites de entrada son técnicos: profundidad 20, 10.000 elementos por contenedor, 50.000 nodos recorridos y 4.096 caracteres por texto; IDs hasta 128 caracteres válidos como identificador. No son límites de cartas/recursos del reglamento.

Pruebas en [game_state_test.gd](../../../tests/game_state_test.gd) con [fixtures ficticios](../../../tests/game_state_fixtures.gd). El lanzador de pruebas usa SceneTree como los anteriores; los componentes del estado solo dependen de RefCounted y parámetros, sin consultar árbol, Autoload o red. Ver [evidencia](verification.md). No se crean estados desde el catálogo actual ni se cambia su revisión.

## Contrato de T07.2 implementado

[game_engine.gd](../../../scripts/game/game_engine.gd) es RefCounted y recibe definiciones, catalog_id y un registro de manejadores locales fiables. En producción el adaptador deberá entregar únicamente `get_verified_definitions()` y registrar solo familias implementadas; aún no hay adaptador de producto. Los manejadores ficticios viven exclusivamente en `tests/` y no se registran en escenas ni en el catálogo. El motor no interpreta texto ni crea una acción genérica de cliente para mover cartas, gastar recursos o alterar snapshots.

`submit(actor_id, intent)` recibe el actor autenticado por separado. La intención v1 tiene exactamente version_accion, match_id, action_id, expected_revision, tipo y payload. Entra por una validación estricta con límites técnicos (profundidad 8, 256 nodos, cadena hasta 1.024 caracteres, representación canónica hasta 4.096); solo después se consulta un recibo por plaza+ID. Un duplicado idéntico devuelve la revisión original aun tras acciones posteriores; diferente contenido con mismo ID devuelve `id_reutilizado`. Rechazos no consumen ID ni RNG. El resultado contiene solo ok, codigo y revision, más action_id/revision_aplicada en éxito. Los códigos definidos están en spec.md y no incluyen texto de cartas ocultas.

Un manejador recibe una copia del estado y un RandomNumberGenerator con semilla y estado del snapshot; devuelve cadena vacía al tener éxito o código de error controlado. Antes del commit el núcleo valida la copia, conserva identidad/versión/catálogo/modo/orden/revisión, semilla y recibos, e impide retroceder next_id. Tras añadir un recibo, incrementa una revisión y publica la copia validada. La fuente RNG y los recibos son internos. Una resolución pendiente bloquea otras acciones; `responder` requiere resolution_id, step_id y opciones admitidas para una plaza destinataria, también si no es el turno activo. La aplicación de efectos y el avance correcto por reglas pertenecen al manejador que se implemente en P09; la respuesta de prueba usa un efecto ficticio explícito.

[game_projection.gd](../../../scripts/game/game_projection.gd) construye una vista nueva por lista permitida. Mano/descarte propios y zonas boca arriba revelan instance_id/definition_id; mano/descarte ajenos y todos los mazos solo cuentan cartas. Eliminadas son visibles. La resolución pública indica destinatarios y bloqueo; únicamente el destinatario recibe opciones. Nunca se copian instancias ocultas, orden de mazos, recibos, semilla ni RNG. `get_view` rechaza destinatarios desconocidos. Los datos visibles exactos de futuras cartas/efectos deberán revisarse al añadir sus manejadores; la ocultación provisional de descartes ajenos/rivales se mantiene expresamente como política técnica hasta contrastar el reglamento.

La prueba [game_engine_test.gd](../../../tests/game_engine_test.gd) usa [manejadores ficticios](../../../tests/game_engine_handlers.gd) para movimientos, gasto, barajado y continuación. Incluye fallo después de modificar varios campos y consumir RNG, reintentos tardíos/contradictorios, reanudación desde snapshot, reacción fuera del turno, privacidad por comparación de estados secretos y errores sin filtración. `test-engine` exige P07_ENGINE_OK y ausencia de ERROR/SCRIPT ERROR. Evidencia concreta en [verification.md](verification.md).
