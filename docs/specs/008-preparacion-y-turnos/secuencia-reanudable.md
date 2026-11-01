# T08.2e — Contrato técnico de secuencia reanudable

Fecha: 2026-11-01. Estado: contrato documental R2 completado con revisión independiente favorable. Próxima implementación: T08.2f. Este documento especifica comportamiento futuro; no modifica el código, el snapshot v1 ni el motor vigente `p08-atium-1/godot-4.7.2`.

Entradas: [puertas de entrada a limpieza](entrada-a-limpieza.md), [contrato P07](../007-estado-y-acciones/plan.md), [motor](../../../scripts/game/game_engine.gd), [validador](../../../scripts/game/state_validator.gd) y [proyección](../../../scripts/game/game_projection.gd). No interpreta nuevas reglas. Se mantienen las fuentes y límites de T08.2d, DUD-004/005/006, material aplazado y cierre externo P04.

## Aceptación documental

- **AC-23:** definir quién crea secuencias y un registro cerrado de programas/operaciones soportados; rechazar datos ejecutables, operaciones desconocidas y supuestas acreditaciones aportadas por clientes.
- **AC-24:** fijar pasos, contexto, estados válidos, pausas y respuestas suficientes para reconstruir una continuación sin variables efímeras ni repetir pasos.
- **AC-25:** concretar atomicidad por acción, RNG, reintentos y consumo único de cierre, distinguiendo rollback del segmento actual de segmentos ya confirmados.
- **AC-26:** fijar compatibilidad, validación al cargar y proyecciones privadas, incluido el identificador necesario para responder desde la vista autorizada.
- **AC-27:** definir casos futuros con operaciones ficticias y resultados observables en siete configuraciones, sin afirmar ejecución ni fidelidad de cartas.
- **AC-28:** dejar plan, responsables, tareas y dependencias verificables, con revisión independiente previa a implementación. La recuperación consulta siempre el estado publicado en GitHub y lo contrasta con trabajo local (SPEC-009 AC-09).

## Frontera de autoridad y registro cerrado

El futuro `SequenceResolver` será un servicio RefCounted, sin escena, reloj ni red. Sólo código fiable de autoridad podrá iniciar una secuencia. El cliente nunca envía pasos, operaciones, contexto, cursores, resultados ni marcas de combate/efectos completados. Un manejador validado de una intención concreta determina qué programa necesita; no habrá una acción genérica de producto para ejecutar programas.

El registro inmutable se fija al crear el motor junto a las definiciones congeladas. Cada programa tiene `program_id` versionado, lista ordenada y finita de pasos, esquema exacto del contexto y operaciones con parámetros tipados. Cada operación dispone de un validador y ejecutor local. No hay evaluación de texto, rutas de scripts ni Callables en snapshots. La carga y el comienzo verifican **todos** los pasos y parámetros, incluso los posteriores a una pausa. Una operación ausente o incompatible rechaza la secuencia entera; nunca se omite silenciosamente ni se aproxima con otra.

Cambiar el registro o la semántica de un programa requiere nueva versión de motor. Un programa de pruebas no puede registrarse en el adaptador de producto. El primer registro será exclusivamente ficticio y vivirá en `tests/`; no habilita combate, Target, efectos de carta, finales, entrenamiento ni transición a limpieza. El cierre de este programa certifica únicamente la terminación de ese programa, nunca las obligaciones de T08.2d.

## Forma propuesta del estado v2

La implementación cambiará `version_esquema` a **2** y `version_motor` a **p08-sequence-1/godot-4.7.2**. Son valores reservados para T08.2f; no se aplican a código ni datos ahora. No se migrarán snapshots anteriores de forma implícita, ni siquiera con `resolution=null`. Se mantiene versión de intención 1 porque su sobre y la respuesta conservan su forma; el adaptador futuro comprobará compatibilidad de motor antes de admitir clientes.

`resolution` será null o un objeto con claves exactas:

| Campo | Significado e invariante |
| --- | --- |
| `resolution_id` | ID opaco único, asignado por autoridad con `next_id`; no reutilizar tras cierre. |
| `program_id` | Programa versionado presente en el registro local exacto. |
| `source_id` | Instancia/definición existente o null sólo si el programa admite origen técnico. No confiere legalidad por sí solo. |
| `steps` | IDs únicos y ordenados, exactamente los del programa. Operaciones/parámetros estáticos proceden del registro, nunca se reconstruyen desde texto del cliente. |
| `cursor` | Índice del primer paso no completado; en snapshot activo debe ser menor que la longitud. El prefijo anterior es el único conjunto completado; no hay flags paralelos. |
| `context` | Contexto privado de esquema cerrado por programa, incluido `owner_id`, `turn_number`, `entry_phase` y `occurrence_id`; referencias existentes y compatibles con el turno. Sin mapas arbitrarios de efectos. |
| `recipients` | Plazas del alcance del programa; únicas y existentes. No equivalen a permiso para ver todos los datos. |
| `pending` | Ventana persistida descrita debajo. En un snapshot confirmado con resolución activa debe ser no nula. |

La resolución automática avanza dentro de una transacción hasta la próxima ventana o el cierre; nunca persiste `resolution != null` con `pending=null`. Así no queda bloqueada esperando una respuesta que nadie puede enviar. Los estados intermedios sólo existen en la copia de trabajo, se verifican con invariantes de trabajo y no pasan por el cargador de snapshots hasta alcanzar una frontera válida.

Una resolución activa exige lifecycle `en_curso`, dueño vivo y contexto coincidente con jugador activo, número y fase actuales. No se continúa desde una partida finalizada ni se cambia de turno/fase mientras la secuencia ficticia está pausada. Las futuras eliminaciones/finales dentro de una resolución requieren ampliar este subconjunto explícitamente; no se infiere su tratamiento.

`pending` conserva claves exactas `kind`, `recipients`, `options`, `min`, `max`. `kind` es `eleccion` o `reaccion`; el primer subconjunto admite **un solo destinatario por ventana**, perteneciente al alcance de la resolución. Las opciones son IDs opacos únicos sin nombres ni IDs de cartas ocultas, con interpretación privada reconstruible por programa/contexto. Límites: `0 <= min <= max <= options.size()`, `max > 0`. Con `min=0`, la respuesta vacía es una declinación explícita; no se usan temporizadores ni aceptación automática por silencio.

El paso de ventana permanece en el cursor hasta responder válidamente. La respuesta lo completa y continúa por los pasos siguientes. En este subconjunto no hay bucles, saltos, ventanas anidadas ni resolución colectiva simultánea. Ventanas sucesivas tienen distintos `step_id`; una elección colectiva futura necesita un contrato de acumulación/legalidad por plaza y no se reduce a «la primera respuesta gana». No se establece un orden reglamentario para reacciones múltiples.

Se añade `authority.completed_sequences`, mapa privado de `resolution_id` a `{program_id, occurrence_id, owner_id, turn_number, revision_aplicada}`. Sólo el cierre del resolutor lo escribe; P07 lo sella con la revisión del commit. Invariantes: ID ausente de resolución activa, programa conocido, plaza válida, turno positivo no posterior al actual, revisión positiva no mayor que snapshot.revision y ocurrencia no repetida ni activa y completada a la vez. Recibos, ledger, RNG y contexto nunca salen en proyecciones.

La integración P07 conservará intactas todas las entradas anteriores del ledger y admitirá únicamente la nueva entrada emitida por el resolutor para la secuencia efectivamente terminada en esa transacción. El manejador no puede borrar cierres, reescribir su revisión ni devolver un cierre inventado como mutación libre de la copia. La solicitud interna de cierre se valida fuera del payload, y P07 añade/sella el registro al commit; la comprobación estructural del snapshot por sí sola no sustituye ese control de transición.

`occurrence_id` identifica un disparador lógico, no una conexión ni un intento de acción. El manejador de autoridad debe recuperar la misma ocurrencia en reintentos y rechazar una ya completada, aunque se use nuevo `action_id` o `resolution_id`. El primer fixture delimita una única ocurrencia `test_turn` por `(match_id, turn.number, turn.active_id)` y deriva su ID de esos datos; no permite elegirlo al cliente. Futuros disparadores repetibles requerirán asignación/consumo de ocurrencias en su propio contrato reglamentario; generar IDs nuevos no acredita una nueva oportunidad legal.

## Ejecución, pausas y cierre

1. **Comenzar:** el manejador de autoridad valida actor, lifecycle, fase y disparador soportado. Exige ausencia de resolución activa y de cierre para esa ocurrencia. Construye el contexto y ejecuta el programa en copia. No reinicia una secuencia por recibir otra intención.
2. **Avanzar:** ejecutar pasos automáticos en orden con el RNG de la transacción P07. Cada paso exitoso avanza cursor exactamente una posición. Las operaciones no hacen I/O, envían mensajes ni mutan datos externos. No se usa RNG global.
3. **Pausar:** construir pending a partir de autoridad y guardar el cursor en la ventana. El commit de P07 persiste juntos efectos previos, ventana, RNG, revisión y recibo. No queda un resultado de azar previo en memoria externa: queda reflejado en el estado/contexto tipado si es necesario para continuar.
4. **Responder:** `submit(actor_id, intent)` conserva identidad separada. Payload exacto `{resolution_id, step_id, options}`; IDs coinciden con resolución y paso actuales, actor con único destinatario y opciones con los límites/IDs ofertados sin duplicados. El resolutor revalida las precondiciones dinámicas antes de aplicar la respuesta. Una reacción puede proceder de otra plaza que la activa si esa ventana la autoriza; no cambia el dueño del turno.
5. **Cerrar:** al consumir el último paso, insertar el registro de cierre y poner resolution a null en **la misma transacción**. No se persiste un cursor al final ni se expone un token de cierre reutilizable al cliente. No hay API pública `finalizar_secuencia`. Un llamador posterior sólo puede consultar el cierre para el programa/ocurrencia exactos; no convertirlo en permiso genérico para limpiar o terminar el turno.

P07 conserva el único commit de estado/revisión/recibo/RNG por intención aceptada. El servicio devuelve un resultado interno tipado (pausada/cerrada o error); el manejador lo traduce al contrato de cadenas existente y el resultado público sigue siendo `{ok,codigo,revision,...}` sin detalles de pasos. Errores del programa/precondiciones se traducen a `accion_ilegal`; respuesta inválida a `eleccion_invalida`; incompatibilidad/corrupción a `estado_invalido`. No introducir códigos privados en el resultado público ni crear recibos de rechazo.

Una operación fallida revierte **todo el segmento desde la última intención aceptada**, incluidos pasos previos del mismo segmento, ventana, IDs, cierre, recibo y RNG. Un fallo tras una respuesta deja intacto el snapshot pausado previo y permite reintentar; no deshace efectos de segmentos ya confirmados antes de la pausa. Si un futuro efecto necesita atomicidad a través de varias respuestas, requerirá diseño explícito de reservas/commit; este contrato no la promete. No se deshacen elecciones ya confirmadas cargando un snapshot antiguo.

Un duplicado idéntico de intención aceptada devuelve su recibo original incluso tras cerrar; distinto contenido con igual ID se rechaza. Un nuevo ID que responde a una ventana consumida se rechaza por revisión/paso/resolución sin reaplicar efectos. Un nuevo intento de comenzar la ocurrencia cerrada también se rechaza. Ledger y recibos se conservan durante toda la partida; no se recortan para eludir límites ni se promete recuperación de disco/caída de autoridad.

## Carga, límites y privacidad

`load_authority_snapshot` seguirá siendo exclusivo de autoridad y pruebas. Validar versión, catálogo, registro completo, igualdad de pasos con el programa, contexto/referencias, cursor/ventana y ledger antes de reemplazar estado. La estructura acredita coherencia; no demuestra que una copia externa haya ejecutado honestamente pasos. No existe importación de snapshots aportados por clientes ni comprobación criptográfica de procedencia en esta entrega.

La persistencia mínima es exportar una copia profunda y cargarla en otro motor con el mismo catálogo/registro/versiones, conservando enteros int64 de RNG. No convertir RNG a float ni usar JSON sin un contrato de codificación exacta. Guardado entre días, archivos, migraciones y recuperación de plaza siguen fuera de alcance.

Límites técnicos iniciales: 64 pasos por programa, 16 opciones por ventana, cuatro plazas de alcance, los límites globales de P07 (50.000 nodos, 10.000 elementos por contenedor, profundidad 20) y los límites del sobre de intención. El programa completo es finito y cada segmento avanza; no se añade un comando cliente «continuar» ni se corta silenciosamente el procesamiento para otro frame. Si estado/ledger/recibo crece más allá de límites, rechazar atómicamente con diagnóstico técnico de autoridad; no es un final reglamentario. Ampliar límites requiere pruebas y una revisión futura.

La proyección se construye por lista permitida. Para todos los jugadores conocidos: resolution null o `{resolution_id, recipients, kind, pending_recipients}` con identidades opacas y bloqueo. Se retira el cursor público para no divulgar cantidad/posición de pasos privados. **Sólo el destinatario** recibe además `step_id`, `options`, `min`, `max`, suficientes para construir su respuesta. No copiar programa, steps, contexto, source_id, ledger, recibos, semillas, RNG ni opciones de terceros. IDs opacos de resolución/paso no codifican definición, nombre o contenido secreto. La selección de destinatario no revela por sí misma una carta; cualquier visibilidad adicional futura requiere contrato específico.

## Registro ficticio y escenarios futuros

T08.2f registrará programas fijos únicamente en tests. Operaciones mínimas: `fixture_add` añade un recurso de turno al dueño; `fixture_roll` obtiene un entero 0–9 del RNG y añade ese valor al mismo recurso; `fixture_wait` ofrece una ventana con opciones opacas `accept`/`decline`; `fixture_fail` modifica un recurso, consume RNG y devuelve fallo deliberado. En las ventanas de prueba `accept` añade uno al recurso del destinatario y `decline` o selección vacía no añade; no afecta salud, cartas ni fases. Todo ello es semántica ficticia de prueba, sin atribución a cartas/reglas. Programas alternativos y kind/destinatario se fijan desde el registro del test, no desde payloads de cliente.

Cada ventana ficticia usa `max=1`; `min=1` por defecto y `min=0` sólo en el programa dedicado a declinación vacía. No hay interpretación de seleccionar ambas opciones. Su contexto tiene únicamente los campos de vinculación de turno/ocurrencia y destinatario fijados por el programa; el resultado de azar se refleja en el recurso, sin variables ocultas necesarias para continuar.

| Caso futuro | Resultado que debe observarse |
| --- | --- |
| SEQ-01: programa automático, misma semilla/entrada | Snapshot/RNG iguales; cursor consumido, un cierre, una revisión y recibo; fase/turno conservados. |
| SEQ-02: añadir, azar, pausa, respuesta y cierre | Efectos previos confirmados una vez; cargar pausa en motor nuevo y responder produce mismo snapshot/RNG que seguir en el original. |
| SEQ-03: dos ventanas; reacción por otra plaza | Una ventana cada vez; vieja respuesta con nuevo ID falla; sólo destinatario actual puede responder; ninguna acción ordinaria intercalada. |
| SEQ-04: fallo antes de pausa / después de responder | Antes: estado original íntegro; después: snapshot pausado íntegro. Incluir RNG, next_id, recibos y ledger, no sólo recursos. |
| SEQ-05: reintento idéntico / ID contradictorio / ocurrencia cerrada | Recibo original sin cambios / rechazo / rechazo incluso con IDs nuevos. Cargar después del cierre conserva esas garantías. |
| SEQ-06: programa/operación/versión desconocidos, paso alterado, cursor imposible | Rechazo de inicio o carga sin sustituir el estado válido; desconocido tras una pausa también se detecta antes de iniciar. |
| SEQ-07: actor/revisión/resolución/paso/opciones inválidos | Rechazo sin consumo; duplicados/opciones ajenas/cantidad fuera de rango/tipos/clave extra rechazados; vacío sólo si min=0. |
| SEQ-08: comparación de proyecciones | Estados con distintos mazos/contextos/programas privados pero misma información autorizada producen la misma vista ajena. Destinatario responde usando exclusivamente su vista; tercero no recibe step_id/opciones. Errores/recibos no filtran. |
| SEQ-09: corrupción de ledger/contexto o sustitución de registro | Carga rechazada; activo/cerrado repetidos, revisión futura, referencia inexistente o contexto ajeno fallan; mutar una copia no modifica autoridad. Probar también manejadores deliberadamente defectuosos que borran/reescriben cierres o inventan uno: P07 rechaza el commit aunque el candidato sea estructuralmente válido, conservando estado/RNG/recibos. |
| SEQ-10: límites y siete configuraciones | Cubrir competitivo/cooperativo 2/3/4 y solo 1; límites de pasos/opciones y desbordamiento contable/ledger/IDs; fallo atómico sin truncado. Reacción ajena sólo donde hay otra plaza. |

Son casos planificados, **no ejecutados** en T08.2e. No acreditan combate, final de turno, turno rival ni P15. Los ocho escenarios reglamentarios de T08.2d siguen pendientes hasta disponer de sus resolutores.

## Plan de implementación posterior y puertas

T08.2f tendrá riesgo R2 y nueva revisión independiente. Un único propietario modificará validador/estado, motor/proyección, resolver, fixtures/tests y lanzador en una entrega coherente: primero forma v2 y validación de registro, después ejecución/ventanas/cierre, integración P07 y suites. Coordinador integra y actualiza memoria; no se paralelizan escritores de esos archivos. Actualizar SPEC-007 y preparación/fixtures a v2; ningún cambio de versión sin pruebas de rechazo del esquema anterior.

Verificación prevista: nuevo `test-sequence` con SEQ-01–10 y regresiones `test-state`, `test-engine`, `test-setup`, `test-cycle`, `test-cleanup` y arranque. Godot 4.7.2, marcas finales/código cero y ningún SCRIPT ERROR; comprobar payloads y diffs. La implementación decidirá rutas concretas de tests/lanzador dentro de ese plan; el comando nuevo todavía no existe. No requiere captura ni red porque no integra UI/transporte; no sustituye esas puertas futuras.

Después del núcleo ficticio verificado, especificar resolutores reales por fuentes/contenido y sólo entonces habilitar obligaciones/transiciones de T08.2d. Un catálogo con cero definiciones verificadas y dudas aplazadas sigue sin permitir una partida real. P04, P07 y P08 conservan sus dependencias de cierre.
