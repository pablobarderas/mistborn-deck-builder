# Plan de SPEC-008

## T08.1b17 — Contrato M1

Completada documentalmente, revisión independiente favorable: [contrato, M1-DOC-01–04 y plan T08.1b18](elecciones-m1.md#aceptación-documental-y-plan-de-implementación). DEC-037 resuelve la omisión: selección obligatoria en 5/9, cima directa con total automático. T08.1b18 implementará el perfil aislado M1/M5/M7, capacidad derivada y selecciones sobre snapshot 6 previsto; siguiente objetivo propuesto, con contrato ya revisado. [Evidencia y traspaso](verification.md#t081b17--contrato-de-selección-y-premios-m1). Motor actual snapshot 5 sin cambios.

## T08.1b16 — Implementación M8

Implementada y verificada localmente, revisión independiente favorable: [M8-01–08 y plan ejecutado](elecciones-m8.md#aceptación-y-plan-de-implementación), perfil aislado M5/M7/M8 y snapshot 5. 15 suites/8.418 comprobaciones; sin entrada a limpieza/producto ni publicación. [Evidencia y traspaso](verification.md#t081b16--implementación-de-elecciones-y-eliminación-m8). Siguiente propuesto T08.1b17: especificar selección de fichas agotadas y premios M1 antes de implementarlos. Las secciones inferiores conservan antecedentes.

## T08.1b15 — Elecciones M8

[Contrato y plan T08.1b16](elecciones-m8.md#aceptación-y-plan-de-implementación) completado documentalmente con revisión independiente favorable: perfil aislado M5/M7/M8, ampliaciones explícitas de ventana, grupos pendientes y correspondencias privadas. No se ha iniciado implementación. T08.1b14 está publicada en `d5d6403`; las notas sin publicación siguientes son antecedentes. [Evidencia vigente](verification.md#t081b15--contrato-de-elecciones-y-eliminación-m8).

## T08.1b13 y T08.1b14 — Permanentes M3/M4

T08.1b13 publicada y revisada favorablemente. T08.1b14 completada localmente según [contrato, PERM-01–06 y plan](permanentes-misiones.md): perfil aislado M3/M4/M7 con inicio y cierre internos, marca privada M3 y nueva mano derivada de M4. Snapshot 4, 14 suites/7.904 comprobaciones y revisión independiente favorable. No se habilita entrada a limpieza ni producto. Siguiente propuesto T08.1b15: contrato de elecciones/eliminación opcional M8. [Evidencia y traspaso](verification.md#t081b14--implementación-de-permanentes-m3m4).

## T08.1b11 y T08.1b12 — Avance de misiones

T08.1b12 completada localmente, 13 suites/5.418 comprobaciones y revisión independiente favorable. Siguiente T08.1b13: contrato de permanentes M3/M4 para inicio/limpieza.

[Contrato, MIS-01–06 y plan del piloto](avance-misiones.md). T08.1b11 fija gasto unitario, primeras llegadas, premios, prioridad terminal DEC-034 y compatibilidad propuesta de snapshot 3. T08.1b12 implementa el perfil automático M5/M6/M7 con Training compartido; ver [verificación y estado de revisión](verification.md#t081b12--resolutor-automático-de-misiones-m5m6m7). las elecciones y permanentes de otras misiones conservan sus puertas propias. T08.1b11 no cambió código; T08.1b12 usa esquema 3/motor `p08-missions-1/godot-4.7.2`.

## T08.1b9 y T08.1b10 — Catálogo de misiones

T08.1b9 especifica el [contrato y las pruebas de catálogo](catalogo-misiones.md#aceptación-y-plan-de-implementación) sobre la transcripción publicada. T08.1b10 implementará la validación v2, la preparación local de las dos fuentes y la comprobación del JSON M1–M8 en una carga explícita. Las pruebas de resolución y admisión de producto se mantienen en la integración posterior.

## T08.2i — Robo personal con mazo y descarte agotados

[Registro R2](tasks.md#t082i--robo-personal-con-mazo-y-descarte-agotados) y [ROBO-01–03](spec.md#t082i--robo-personal-con-mazo-y-descarte-agotados). Acotar el robo después de validar la entrada y conservar el reciclado y el commit de la copia candidata. `TurnCleanup` usa el mismo resultado aceptado para cerrar con una mano corta. Mantener esquema 2, cambiar versión de motor y comprobar rechazo de la versión previa. Ejecutar suites de ciclo, limpieza y regresiones; revisión independiente del diff. El resolutor de habilidades y el paso rival mantienen sus tareas propias.

## T08.1b7 — Desbloqueo tardío, robo y finales del rival

[Registro R2](tasks.md#t081b7--desbloqueo-tardío-robo-y-finales-del-rival) y [casos acordados](spec.md#t081b7--reglas-acordadas-para-desbloqueo-robo-y-finales). El resolutor de habilidades debe aplicar el desbloqueo tardío; T08.2 debe sustituir la guardia de agotamiento personal y actualizar las pruebas de ciclo, limpieza, RNG y rollback; T08.3 debe aplicar el orden del paso del rival y sus finales. El siguiente lote de contenido sigue siendo M1–M8.

## T08.1b5 — Perfil competitivo de producto

[Registros R2 de delimitación](tasks.md#t081b5--delimitación-del-perfil-competitivo-de-producto) y [resolución de reglas](tasks.md#t081b6--resoluciones-de-reglas-del-perfil-competitivo). Tras el contraste del manifiesto y la incorporación de DEC-031, preparar el lote de misiones M1–M8 y revisar las ampliaciones de catálogo y reglas que requieran sus premios. Los casos [PERF-01–06](perfil-competitivo-producto.md#comprobaciones-para-la-integración-posterior) pertenecen a la integración futura.

## T08.1b3/b4 — Inicio único competitivo

[Contrato](inicio-competitivo.md) e INI-01–05 para ENT-AC-04. T08.1b3 contrasta fuentes y APIs y entrega el diseño revisado. T08.1b4 implementará y probará el perfil aislado. Antes de editar código, asignar un propietario para la entrada interna, el adaptador, el versionado y las pruebas.

1. Separar entradas pública e interna sobre el commit compartido de P07. Reservar tipo e IDs de inicio, verificar su separación antes de los recibos y comprobar el número de turno antes de ejecutar el manejador.
2. Construir la admisión del perfil y las comprobaciones de obligaciones y final. Componer T08.1b2 en el candidato de autoridad, cambiar sólo la fase y validar el delta y el candidato. Reutilizar el registro Funding si el perfil lo admite.
3. Versionar la admisión del snapshot para distinguir la semántica del nuevo perfil. Usar una versión coherente en preparación, validación de estado, entrenamiento y Funding o limpieza si se reutilizan. `StateValidator` compara hoy una constante compartida. No reetiquetar snapshots anteriores. Serializar las entradas y comprobar que sólo un motor vacío recibe el último estado confirmado de la fuente de autoridad.
4. Ejecutar INI-01–05 y regresiones de entrenamiento, preparación, estado, motor, Funding, secuencias y limpieza. Revisar de forma independiente. La entrada de producto depende del catálogo verificado, las obligaciones y finales aplicables y su integración.

## T08.1b1/b2 — Avance de entrenamiento competitivo

[Contrato](avance-entrenamiento.md), ENT-AC-01 a 04, R2. T08.1b1 fija las recompensas, el perfil y la frontera entre la operación interna y la integración de inicio. T08.1b2 aplica ENT-AC-01 a 03 en `training_advance.gd` con un descriptor técnico externo a P06 que liga catálogo, ID, definición y marcas ordenadas. La operación devuelve un candidato validado con el registro de secuencias de la autoridad. Responsables y verificación en [tareas](tasks.md#t081b2--operación-interna-de-avance-competitivo).

Verificar con `test-training` y las regresiones de preparación, estado, secuencias, Funding y limpieza. El módulo aislado usa el esquema 2 y el registro vigente de la autoridad. Revisar el versionado cuando se integre el inicio y cambie la semántica del snapshot. Pruebas de ENT-AC-04, integración de inicio, perfil de producto y demás modos quedan en tareas posteriores.

## T08.2g/h — Contrato e implementación de Funding

T08.2g entrega únicamente el [contrato](primer-resolutor-competitivo.md), AC-35–38, tras inspeccionar P07/T08.2f y contrastar SRC-001/002. Riesgo R2; coordinador autor documental, `resolver_rules` sdd_rules Sol/high en lectura y revisión final independiente sdd_reviewer Sol/high. Registro previo en tasks.md; ninguna dispensa. Escaneos del otro PC ausentes aquí: la regla inglesa del PDF puede especificarse, pero no se incorpora ni verifica su localización española.

Plan de T08.2h (pendiente, no ejecutado):

1. Revisar contrato y concretar perfil cerrado de contenido inerte de prueba más Funding; comprobar descriptores completos y condiciones dinámicas admitidas. Crear definición de prueba trazada a REG-027/069/070/075, sin modificar las muestras de producto ni atribuir fidelidad al catálogo completo.
2. Un propietario implementará `scripts/game/funding_play.gd` y su UID: fábrica/validador de perfil, adaptador `jugar_funding` y registro `funding_play_v1` con callback estático. Un paso atómico mueve mano→juego y aplica +1/+0 según elección. IDs derivados de autoridad, sin nueva operación genérica accesible al jugador. Alternativa descartada: empezar por combate exigiría ampliar terminales, reacciones y fase antes de verificar una primera regla de carta.
3. Añadir `tests/funding_play_test.gd` y fixture de perfil bajo tests, sus UID y acción `test-funding` en `tools/godot.ps1`. Versionar motor a `p08-funding-1/godot-4.7.2` en validador y fixtures pertinentes, conservando esquema 2 y sin migración automática. No alterar las protecciones de P07. Todos estos archivos tendrán un único propietario; coordinador documentación y ejecución serial de Godot.
4. Verificar FUND-01–08, incluido aplicar/omitir, instancias distintas, rechazos sin mutación, recibos/carga, overflow y perfil desconocido. Prueba aislada en `libre` explícita: no afirmar que el constructor de preparación llega allí. Ejecutar `test-funding` y regresiones `test-sequence`, `test-state`, `test-engine`, `test-setup`, `test-cycle`, `test-cleanup`, `test-catalog` y `test`, secuencialmente con el lanzador documentado. Revisar marcas, código 0 y ausencia de SCRIPT ERROR.
5. Revisión independiente R2 del diff final y evidencia; corregir hallazgos y actualizar memoria una vez. Sin cambios de UI/transporte, no corresponden capturas o pruebas nuevas de red. No cerrar P04/P07/P08 ni declarar cartas españolas verificadas por pasar fixtures.

Compatibilidad: la fábrica debe conservar copias de los descriptores, validar la identidad del catálogo/perfil al cargar y usar sólo enlaces escalares en callbacks del registro. El cliente únicamente elige instancia y booleano; el origen de efectos/cantidades pertenece a autoridad. Perfil desconocido o no soportado bloquea; nunca se descartan habilidades adicionales por conveniencia.

Concreción técnica previa a implementación T08.2h: `funding_play.gd` será un adaptador que extiende GameEngine, recibe documento P06 completo, ID Funding y descriptores inertes completos confiables de autoridad. P06 valida el sobre y el adaptador valida la semántica soportada; igualdad completa y ausencia explícita de efectos en componentes inertes. No basta la palabra «inerte». Mantiene `submit`/recibos del núcleo; restringe inicio mediante starter y carga mediante perfil.

La identidad del snapshot se obtiene con `catalog_identity()`: prefijo `funding_` y SHA-256 del documento/perfil canonicalizado por claves ordenadas (arrays conservan orden). Distinguirla de `id_catalogo` editorial P06; no modifica el sobre P06 ni los snapshots del resto del motor. Motivo: el mismo ID editorial con una definición cambiada no puede recuperar cierres de otro perfil. Pruebas: reordenar claves conserva identidad/carga, cambiar descriptor con mismo ID editorial rechaza carga; no usar hash de proceso ni mutar las entradas. Este detalle cumple la compatibilidad de T08.2g y no añade semántica reglamentaria.

Corrección de revisión T08.2h: la compatibilidad del perfil dinámico (usos, flags, counters y recompensas desconocidos) se exige también al admitir un snapshot, después de validar estructura y antes de publicarlo. Rechazar carga conservando autoridad previa; no permitir que marcas en cartas ocultas determinen después aceptación/rechazo de una acción de otro jugador. Mantener guardas defensivas durante ejecución. Regresión A/B con vistas iguales y flags distintos en mano ajena; no equivale a validar el historial reglamentario de un snapshot.

La comparación completa de descriptores usa igualdad recursiva por forma/tipos, aceptando sólo el mismo valor numérico integral validado por P06 entre Variant y JSON; no trunca fracciones. La admisión comprueba además que cada cierre `resolution_N` de Funding tenga ocurrencia `funding_play_N`, evitando cargar un cierre que consuma una ocurrencia futura. Mantiene rechazo atómico y no añade nuevos campos al snapshot.

## Encargo 2026-11-09 — T08.2f, implementación de secuencias

Cierre 2026-11-10: implementación, 253 comprobaciones de secuencia y regresiones (3.353 en total), revisión independiente final favorable de sequence_review_final. Coordinador completó las correcciones tras la interrupción y ejecutó las siete suites en serie con importación limpia. [Evidencia y traspaso](verification.md#t082f--implementación-de-secuencias-reanudables); ninguna dispensa, sin commit/push. Las notas de reanudación siguientes son históricas.

Segunda reanudación 2026-11-10 por «sigue»: fetch vuelve a confirmar `7a9f25c`. El desarrollador se interrumpió por límite de uso tras escribir la implementación y obtener 219 comprobaciones de secuencia; importación con error de permisos pendiente, por lo que no se acepta aún la verificación completa. No quedan subagentes activos. El coordinador asume la propiedad de código/tests/lanzador para integración y pruebas; se solicitará un revisor independiente final nuevo. Conservar hallazgos previos sobre diccionarios tipados y aridad de callbacks, ya corregidos y pendientes de contraste final. La delegación adicional es necesaria por la interrupción y no sustituye controles.

Reanudación 2026-11-10 por «continua»: fetch confirma HEAD/origin/main en 7a9f25c. Solo quedaron los tres documentos de planificación modificados; no hay cambios de código ni pruebas nuevas. El subagente anterior ya no está activo y se reasigna su propiedad a sequence_impl_resume, con el mismo perfil/alcance. Se conserva el trabajo documental y la revisión independiente posterior obligatoria.

Autorización: tras publicar el inventario, el usuario elige expresamente «Continuar el motor (T08.2f)». Recuperación: main/origin/main en 7a9f25c8eee44364b09c624178d0fd9aaf57e35c, fetch y estado publicado comprobados, árbol limpio. El encargo anterior de commit/push queda satisfecho; esta implementación se entregará localmente sin inferir nueva autorización de publicación.

Objetivo verificable: implementar el contrato de [secuencias reanudables](secuencia-reanudable.md), AC-29–34 y SEQ-01–10, mediante registro de programas ficticios exclusivamente en tests. Riesgo R2: estado, transacciones/RNG, autoridad y privacidad. No interpreta reglas nuevas ni habilita combate, limpieza de entrada, entrenamiento, rival o acciones de producto. La prioridad competitiva DEC-027 se mantiene; las siete configuraciones prueban compatibilidad estructural existente, no desarrollan el Lord Legislador.

Plan previo: registro cerrado y validación íntegra; esquema v2 y versión p08-sequence-1/godot-4.7.2; servicio de ejecución/ventanas; integración transaccional con cierre protegido; proyección por destinatario; fixtures adversos y regresiones; revisión independiente, correcciones y memoria final. Evitar migraciones implícitas y cambios en contrato de intención v1.

Propietarios: sequence_impl/sdd_developer Sol high, único escritor de scripts/game/, tests/ y tools/godot.ps1; coordinador único escritor de documentación e integrador; sdd_reviewer Sol high posterior, solo lectura. Perfiles transmitidos por instrucciones conforme a .codex/agents; sin descendientes, como máximo dos subagentes y ninguna dispensa metodológica. El usuario ha solicitado expresamente continuar tras publicar en esta sesión. Desarrollador puede ejecutar Godot en exclusiva durante implementación; coordinador lo hará tras su entrega, sin ejecuciones simultáneas.

Verificación prevista: test-sequence SEQ-01–10, test-state, test-engine, test-setup, test-cycle, test-cleanup y test (arranque) en Godot 4.7.2, marcas finales/código cero/sin SCRIPT ERROR. Inspección de payloads, carga, reintentos y ledger; enlaces y diff. UI/red no aplican porque no se añade presentación/transporte; P04 externa sigue pendiente y no se cierra P08. Revisión independiente obligatoria antes de aceptar esta entrega.

## Encargo 2026-11-01 — T08.2e, contrato de secuencia reanudable

Autorización: «Vamos a avanzar con el siguiente paso», precisada por «Asegura el siguiente paso SIEMPRE desde el documento de estado del proyecto github ya que hubo cambios desde otro pc». Recuperación: `git fetch origin` correcto y lectura de `origin/main:docs/estado-actual.md` en `6caed87`; copia local limpia atrasada once commits, actualizada mediante fast-forward de `16b8247` a `6caed87`. No se escribió la P07 ya terminada. El estado remoto y T08.2d señalan como siguiente objetivo el contrato de secuencia reanudable, antes de implementarlo.

Objetivo/aceptación previa: redactar un contrato técnico implementable de operaciones soportadas, pasos/contexto, pausas, cierre único, persistencia, compatibilidad y privacidad, con escenarios de fixtures expresamente futuros (AC-23–28). Integrar la comprobación obligatoria de GitHub al recuperar contexto, preservando trabajo local y sin inferir permisos de publicación. Riesgo R2 por autoridad/estado privado y modificación de controles de recuperación; no es una nueva interpretación reglamentaria.

Plan: inspeccionar P07 y puertas de T08.2d; definir el contrato y su relación con transacciones/proyecciones existentes; concretar tareas de implementación y pruebas; alinear protocolo/guía de reanudación con la instrucción humana; comprobar enlaces, coherencia y diff; revisión independiente antes de cerrar. Coordinador único escritor de documentación; apoyo sdd_planner Sol/high sólo de lectura para contrastar el diseño, y sdd_reviewer Sol/high para dictamen final independiente. Perfiles transmitidos por instrucciones al no existir selector de perfil en esta herramienta. Sin descendientes ni dispensas, máximo dos subagentes. No se cambia código, datos ni configuración; Godot, revisión visual y ensayo de red no aplican a esta entrega documental. Las pruebas ejecutables se reservan para la implementación posterior, sin presentar escenarios como evidencia. No se implementan combate, limpieza de entrada, efectos ni finales ni se modifica el snapshot vigente. Sin autorización de commit/push.

## Encargo activo 2026-10-30 — Entrada a limpieza tras T08.2c

Autorización: «vamos con el siguiente paso». Recuperación contrastada: main/f3fbf54, árbol limpio; T08.2c publicada. Objetivo verificable: concretar las puertas previas a limpieza y determinar qué segmento se puede implementar con las reglas y el modelo disponibles. Riesgo R2 por secuencia reglamentaria, Target, efectos y finales. Antes de escribir código se fijarán AC y alcance tras el contraste; no se aceptará una marca aportada por el cliente como prueba de haber resuelto combate o efectos.

Plan: contrastar SRC-001/002 y el estado actual; especificar orden, precondiciones y dependencias por modo; implementar únicamente un segmento con contrato completo, si lo hay; verificarlo y solicitar revisión independiente del resultado. Si la entrada depende de resolutores ausentes, entregar el contrato y desglose con esas dependencias explícitas, sin habilitar un salto de fase. Responsables: coordinador, único escritor/integrador; cleanup_entry_rules/sdd_rules Sol high, lectura y contraste previo; sdd_reviewer Sol high para revisión independiente. Sin descendientes ni dispensas. Verificación prevista: trazabilidad fuente/puerta, coherencia con APIs y snapshot, enlaces locales y diff; si hay código, pruebas adversas de orden/fase/actor, rollback y regresiones afectadas en Godot 4.7.2. Sin cambios de UI o transporte previstos. No hay autorización de commit/push.

## Encargo activo 2026-10-30 — T08.2c, contabilidad de Atium

Autorización: «vamos con el siguiente paso». Recuperación: main, HEAD c370d0f, árbol limpio; T08.2b publicada. Objetivo verificable: fijar la relación entre persistent.atium y fichas y devolver exclusivamente el Atium usado durante la limpieza, con rechazo atómico de estados incoherentes. Riesgo R2 por contrato de estado y regla REG-019. El contrato definitivo y AC se registrarán tras contraste SRC-001/002, antes de modificar código. No incluye ganar/quemar/refrescar metales, efectos, entrenamiento, combate, finales ni resolver dudas aplazadas.

Responsables: coordinador único escritor documental e integrador; atium_rules/sdd_rules Sol high contrasta fuentes en lectura; implementación con propietario único tras cerrar contrato; sdd_reviewer Sol high revisará el diff final. Sin descendientes ni dispensas; sin autorización de commit/push. Verificación prevista: invariantes saldo/fichas, usados/no usados, siete configuraciones, conservación ajena, rollback/RNG, composición y reintentos P07; regresiones de estado, motor, preparación, ciclo y limpieza. Comprobar enlaces y diff. Sin cambios visuales o transporte, por lo que no requiere revisión visual ni nueva prueba de red de esta API. P04/P08 siguen abiertas.

Contrato cerrado tras atium_rules: saldo total igual a conteo exacto de fichas, incluidas usadas hasta limpieza; ninguna reserva virtual. Atium no agotado en este subconjunto (Flaring es la única fuente modelada). Al limpiar se retiran usadas y se decrementa saldo en igual cantidad sobre la copia transaccional, conservando no usadas. AC-15–18 en spec.md. Cambio semántico incompatible: version_motor p08-atium-1/godot-4.7.2; sin migración automática, esquema v1 conserva forma. Las futuras operaciones que ganen/gasten Atium actualizarán ambas representaciones atómicamente y contarán disponibles por used_this_turn; no se implementan ahora.

Propiedad de implementación asignada a atium_impl/sdd_developer: scripts/game/state_validator.gd, scripts/game/turn_cleanup.gd, tests/game_state_fixtures.gd, tests/game_state_test.gd y tests/turn_cleanup_test.gd. Coordinador conserva toda documentación y ejecuta Godot en serie; desarrollador no ejecuta motor simultáneamente. Revisor independiente posterior. Contraste previo: SRC-001 p.8 inspeccionada visualmente con skill PDF y FAQ oficial consultada en vivo 2026-10-30; reglas comunes a los tres modos, sin aclaraciones nuevas de DUD ni cartas ausentes.

## Encargo activo 2026-10-29 — T08.2a, ciclo personal de cartas

Reanudación autorizada por «vamos a continuar con el desarrollo». Git inicial limpio, `main`, HEAD `7b75181`. Objetivo verificable: operaciones internas de autoridad para robo con reciclado y descarte personal, con limpieza exclusivamente de cartas. Riesgo R2: modifica zonas privadas y RNG y aplica REG-009/010/025. No incluye finalización completa de turno, entrenamiento, recursos/metales, efectos, rival ni resolución de DUD-006; T08.2 permanece agrupador abierto.

Plan y propietarios: coordinador especifica e integra y es único escritor de documentación; `sdd_rules` contrasta SRC-001/002 antes del código; un desarrollador será propietario exclusivo del módulo de ciclo, sus pruebas y el comando de ejecución; `sdd_reviewer` revisará el diff final independientemente. Sin delegación descendente ni dispensas. No se requiere revisión visual: API sin escena ni presentación. Pruebas Godot en serie por el coordinador, versión 4.7.2 encontrada en Downloads mediante `-GodotPath`; la ruta portátil documentada no existe en este clon.

Verificación prevista: orden de robo, reciclado solo ante necesidad, determinismo y conservación RNG, identidad/cantidad/propiedad, aliados persistentes, agotamiento sin mutación parcial ni RNG consumido, siete configuraciones, validador de estado y regresiones de preparación/motor/estado. Comprobar enlaces y diff y conservar revisión/hallazgos/traspaso en verification.md. Ningún permiso de commit/push de entregas anteriores se extiende a ésta.

Contrato técnico: `card_cycle.gd` se construye con definiciones y catálogo; `draw(snapshot, player_id, count, rng)`, `discard(snapshot, player_id, instance_ids)` y `cleanup_cards(snapshot, player_id)` devuelven `{ok, codigo}` sin identidades privadas. Cada operación valida y prepara una copia antes de aceptar cambios. `draw` copia el RNG recibido y solo avanza el original en éxito; no persiste `authority.rng_state`: el commit de `GameEngine` lo hace. Un llamador directo debe persistir ese RNG al guardar. Componer limpieza y robo requiere la transacción exterior P07 para que un fallo posterior también deshaga la limpieza.

Convenciones técnicas reproducibles, no reglas impresas: parte superior al final del array, Fisher–Yates descendente con RNG explícito, descarte explícito en orden de selección, limpieza primero mano y después no aliados en el orden de juego. No cambia esquema ni versión del snapshot al añadir este servicio sin registro de acciones de producto. Se prefiere un servicio personal a generalizar el reciclado: mercado y rival tienen reglas diferentes.

Contraste previo `rules_deck` (perfil nativo `sdd_rules`, Sol/high): SRC-001 pp.6 (Deckbuilding 5–7), 17 (Turn Structure 5–6), 19–20 y SRC-002 FAQ oficial consultada 2026-10-29. Confirma REG-009/010/025 y límites REG-055/056/068; no encuentra aclaración expresa de DUD-006. Aliados en mano sí se descartan; solo los ya en juego permanecen. Ninguna interpretación de agotamiento ni excepción de carta sin contenido verificado.

## T08.1a — Preparación estructural

`game_setup.gd` recibe definiciones verificadas, ID de catálogo, modo, plazas horarias, primer jugador competitivo, manifiesto y semilla. Comprueba forma, cantidades y tipos antes de crear estado. Usa un único RNG local para sorteo y barajados; conserva su estado en `authority`. Construye IDs de instancia locales y zonas por jugador. No hay llamada a `Database`, escena, red ni reloj.

El manifiesto es un contrato de entrada de autoridad, no un archivo de catálogo: `characters` contiene cuatro entradas `{character_id, starters}` con cuatro IDs; `funding_id`; `training_track_id`; `market_cards` con 82 IDs, repetidos según cantidad física; `missions` con ocho IDs distintos; `rival` es null en competitivo o `{definition_id, domination_id, cards}` con 36 IDs en los otros modos. Todas las definiciones referidas exigen estado `verificada` y cantidad positiva; las copias usadas no pueden exceder la cantidad declarada. Al completar el catálogo se construirá desde sus cantidades y relaciones contrastadas. Las pruebas usan definiciones mínimas ficticias marcadas verificadas únicamente como fixture; no aprueban cartas oficiales.

La pista de entrenamiento se registra en cada jugador porque la reanudación desde snapshot no debe depender de una configuración externa desaparecida. Por ello se amplía el esquema P07 y su versión de motor, actualizando fixtures y regresiones. `training=0` representa el primer espacio de la pista; `turn.phase=inicio` impide considerar realizado el avance inicial.

## Trabajo posterior

T08.1b implementará avance de entrenamiento y sus recompensas con pista verificada; después comenzará `libre`. T08.2 implementará acciones/puertas de fase, limpieza, robo y reciclado, incluida la decisión expresa sobre agotamiento total. T08.3 separará preparación/ronda rival y reglas por modo. No abrir el turno saltándose efectos aún no modelados.

## Verificación

Godot 4.7.2: prueba de preparación con siete configuraciones, cantidades, errores y determinismo; regresión de estado y motor. Comprobar ausencia de mutaciones en entrada y estado fallido. Los tests de preparación no son pruebas manuales de interfaz ni validación del catálogo real.

## Encargo activo 2026-10-29 — T08.2b, cierre interno de limpieza

Autorización: «seguimos con el siguiente desarrollo». Recuperación contrastada: rama main, HEAD 9e46660, árbol limpio; T08.2a está publicada y no requiere repetirse. Objetivo: especificar e implementar el segmento confirmado de cierre de limpieza y sus puertas, sin abrir libre ni omitir entrenamiento/combate/Target/efectos/rival. Riesgo R2 por reglas, estado privado, fases y RNG. El contrato y AC se concretarán tras contraste previo de SRC-001/002, antes de escribir código.

Responsables: coordinador único escritor de documentación e integrador; turn_rules (perfil nativo sdd_rules, Sol/high) contrasta reglas en solo lectura; un desarrollador tendrá propiedad de módulo/tests/lanzador cuando se cierre el contrato; revisor independiente sdd_reviewer Sol/high examinará resultado final. Máximo dos subagentes, sin descendientes ni dispensas. Verificación prevista: siete configuraciones, puertas de fase/actor/resolución, conservación de persistentes y ajenos, limpieza y robo atómicos/RNG, rechazo DUD-006 y reintentos P07; regresiones de ciclo/preparación/motor/estado, enlaces y diff. Sin cambios visuales ni red: no requieren capturas ni ensayo de red de esta API. P04/P08 permanecen abiertas. Sin autorización de commit/push.

Contrato T08.2b cerrado tras contraste turn_rules: `turn_cleanup.gd`, constructor (definitions, catalog_id), `finish_cleanup(snapshot, player_id, rng) -> {ok,codigo}`. Valida y prepara copia+RNG; compone CardCycle; valida resultado y sólo entonces publica ambos. No guarda authority.rng_state (P07 lo persiste). No registra handlers públicos ni permite un payload decidir fases o cantidades. Entradas con counters/flags propios no vacíos, adversarios del activo o Atium usado bloqueadas; burn_limit se conserva. Se define ability_uses de jugador/instancias como usos temporales del turno propio para esta API, sin semántica de efectos nuevos. Guardar agotamiento y fases sin atajos. Pruebas incluyen que limpieza no se repite después de pasar a inicio/rival.

Propiedad de implementación: desarrollador exclusivamente scripts/game/turn_cleanup.gd y .uid, tests/turn_cleanup_test.gd y .uid, tools/godot.ps1 (acción test-cleanup). Coordinador mantiene documentación y ejecuta Godot en serie al terminar; revisión independiente posterior. Alcance definitivo AC-11–14: cierre seguro del subconjunto, no limpieza completa con Atium usado ni efectos desconocidos. El registro inicial se abrió el 2026-10-29; continuación el 2026-10-30 según fecha local del usuario.

Contraste previo turn_rules (sdd_rules nativo Sol/high), completado: PDF pp.6–8/11–13/15–17/19–20 y FAQ oficial Player abilities & allies / Metal tokens & atium consultados para este encargo. Confirma orden combate→Target→descarte→robo, agotamiento Flaring persistente y Atium no usado conservado. La relación saldo/ficha de Atium no está definida en P07: se bloquea el caso usado y se conserva pendiente, sin elegir silenciosamente una contabilidad. Los mapas ability_uses se declaran temporales; flags/counters desconocidos se bloquean. No garantiza finales ni efectos ya resueltos sólo por entrar en limpieza. La autoridad llamadora conserva esa obligación.
