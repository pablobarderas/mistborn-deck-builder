# E3 — Registro de admisión y cobertura

## Componentes y procedencia

Este registro complementa el [inventario cerrado](../008-preparacion-y-turnos/inventario-competitivo-final.md#lista-cerrada-que-debe-resolver-el-manifiesto) y el [contrato de admisión](../008-preparacion-y-turnos/admision-contenido-final.md#registro-por-componente). Las agrupaciones de la tabla se resuelven por ID en sus registros de origen. En E1 y misiones, cada entrada aporta tipo, cantidad y localizador en `cartas[].fuentes`; `fuentes[]` aporta la huella de la fuente. En mercado, cada ID se cruza con la entrada por hoja, fila y posición, y con la huella y orientación de la copia E3.2. Así se conservan las referencias individuales sin duplicar caras ni mezclar copias cotejadas con originales históricos.

| Componente e identificación | Cantidad física | Fidelidad y ejecución disponibles | Carencias de admisión |
| --- | --- | --- | --- |
| Personajes. Cuatro IDs de tipo `personaje` en [E1](../../../data/inicio_competitivo.json). | 4 | [Cotejo E1](../008-preparacion-y-turnos/verification.md#cotejo-humano-e1-y-consulta-de-misiones--registro-previo) de la edición española por el propietario; definiciones en borrador y ensayos de niveles. | Revisión de definiciones finales, referencias y habilidades con el catálogo candidato. |
| Entrenamientos. Dieciséis IDs de tipo `entrenamiento` en [E1](../../../data/inicio_competitivo.json). | 16 | Cotejo E1 por agrupación de personaje y ensayo de activación. | Revisar la definición final de cada ID y ejecutar las rutas de activación y uso de metal con el candidato. |
| `financiacion` en [E1](../../../data/inicio_competitivo.json). | 24 | Cotejo E1 y prueba en perfil de inicio con definición activada para el ensayo. | Revisar la definición final y repetir el ciclo con el candidato. |
| `pista_entrenamiento` en [E1](../../../data/inicio_competitivo.json). | 4 | Cotejo E1 y avance en ensayo. | Revisar la representación final, referencias y premios con el candidato. |
| `mision_m1` a `mision_m8` en [misiones](../../../data/misiones.json). | 8 | [Cotejo por el propietario](../008-preparacion-y-turnos/verification.md#confirmación-humana-de-misiones-m1m8--registro-previo). Definiciones declaradas verificadas y ejecución en perfil aislado. | Vincular cada referencia a su contraparte candidata y verificar las rutas con las acciones y componentes del lote. |
| 65 IDs en [inventario de mercado](mercado-inventario.json). | 82 | [Cotejo por diseño](cotejo-mercado.md) y [huellas de E3.2](verification.md#copia-identificada-para-e32). `mercado_03_f01_derecha` corresponde al [borrador Perseguir](../../../data/perseguir.json), con ejecución en ensayo aislado. | El borrador requiere revisión y ejecución integrada. Para los otros 64 IDs todavía falta el vínculo con una definición de ejecución. Cotejo y huellas acreditan la lectura de fuente. |
| Metales ordinarios, diales de salud y marcadores de entrenamiento y misión. | 32, 4, 4 y 12, respectivamente | [Contraste de recursos y marcadores](#contraste-de-recursos-y-marcadores). | Identidad, representación final y actualización con el candidato. |
| Fichas de Atium, Boxings y Target. | 16, 14 y 1, respectivamente | [Contraste de recursos y marcadores](#contraste-de-recursos-y-marcadores). | Identidad, representación final y uso con el candidato en cada tamaño de mesa aplicable. |

**Distribución.** Las ocho filas siguen con evidencia pendiente por material. Cada inclusión futura debe identificar el texto, icono, ilustración o recurso, su procedencia y la base y alcance de inclusión. Se resolverá contra el paquete real en A6. Ni el estado de revisión de las definiciones ni las huellas cubren esta evidencia.

## Cruce de rutas con código y pruebas

La columna de pruebas identifica comprobaciones versionadas. Su alcance se limita a los datos y al perfil que carga cada suite. La familia cubierta por una prueba ficticia sigue pendiente de la vinculación por ID y ruta al candidato.

| Ruta | Resolutor, servicio o perfil existente | Prueba y alcance | Falta en el candidato |
| --- | --- | --- | --- |
| Preparación para 2–4 plazas, inicio, entrenamiento y Financiación | [GameSetup](../../../scripts/game/game_setup.gd), [CompetitiveStart](../../../scripts/game/competitive_start.gd), [TrainingAdvance](../../../scripts/game/training_advance.gd), [FundingPlay](../../../scripts/game/funding_play.gd) y [perfil E1](../../../scripts/game/initial_competitive_play.gd). | `test-setup` (estructural con fixtures), `test-initial-play` (acción inicial y parte de las habilidades). | Inventario cerrado y arranque con la identidad fijada para los tres tamaños. |
| Compra, activación y uso de metal en el mercado | [Perfil local E2](../../../scripts/game/local_competitive_play.gd) y [perfil de Perseguir](../../../scripts/game/perseguir_play.gd). | `test-local-competitive` (mercado ficticio) y `test-perseguir-play` (activación aislada). En la última ejecución documentada de este último faltó la fuente con la huella exigida por el perfil. [Evidencia](verification.md#ensayo-de-finalización). | Cobertura por definición y por ruta alcanzable en todo el mercado. |
| Avance, premios y elecciones de misiones | [IntegratedMissionsPlay](../../../scripts/game/integrated_missions_play.gd). | `test-integrated-missions` verifica la selección y rutas M1–M8 con componentes de ensayo. | Referencias y premios ejercitados con el conjunto integrado, incluidas las condiciones que dependen de otras cartas. |
| Recursos y zonas | [TurnResourceExchange](../../../scripts/game/turn_resource_exchange.gd) y [CardCycle](../../../scripts/game/card_cycle.gd). | [Intercambio](verification.md#intercambio-de-recursos), [traslado](verification.md#traslado-de-mano-a-descarte) y `test-cycle`. Casos de éxito y reversión en programas de prueba. | Vincular operaciones, parámetros y casos adversos a las definiciones que las invocan. |
| Selección privada, alternativas y efectos encadenados | [SequenceResolver](../../../scripts/game/sequence_resolver.gd) y [registro de prueba integrado](../../../tests/integrated_trial_registry.gd). | [Selección](verification.md#selección-privada-verificada-en-el-motor), [alternativas](verification.md#alternativas-y-efectos-encadenados-verificados) y `test-integrated-trial`, con pruebas de restauración y privacidad en escenarios ficticios. | Vincular ofertas, objetivos y resultados a componentes candidatos. |
| Limpieza, efectos diferidos y reacciones | [TurnCleanup](../../../scripts/game/turn_cleanup.gd) y [autoridad del ensayo integrado](../../../tests/integrated_trial_engine.gd). | `test-cleanup`, `test-deferred` y `test-integrated-trial`. El ensayo verifica el relevo y una obligación ficticia. | Verificar eventos y ventanas alcanzables, incluido el relevo con cuatro plazas. |
| Combate, Target y finales | [Perfil E2](../../../scripts/game/local_competitive_play.gd) y [GameEngine](../../../scripts/game/game_engine.gd) para confirmación de secuencias. | [E2](../010-primera-partida-local/verification.md) verifica dos finales locales y rutas de Target con fixtures. [FIN](verification.md#ensayo-de-finalización) verifica un cierre atómico ficticio. | Ejecutar las tres vías de cierre del [lote](lote-integracion.md#recorridos-con-el-candidato). Confrontación queda pendiente del recorrido completo. |
| Carga y restauración | [RuntimeCatalogLoader](../../../scripts/catalog/runtime_catalog_loader.gd), [manifiesto b29](../../../scripts/catalog/runtime_catalog_manifest.gd) y restauración aislada del perfil de ensayo. | `test-runtime-catalog`, `test-runtime-authoring` y `test-integrated-trial` para identidades y perfiles de ensayo. | Identidad del catálogo candidato, rechazo íntegro y restauración con el mismo artefacto en A4–A5. |

## Bloqueos de construcción

1. Cerrar los vínculos entre IDs, definiciones y evidencia de fidelidad de cada componente del inventario. Falta definir también la representación de piezas auxiliares.
2. Completar la cobertura de las rutas que queden sin resolutor o prueba al cruzar cada definición con su perfil. Las primitivas y regresiones existentes sirven de base para ensayos con contenido original de prueba.
3. Completar la evidencia de inclusión por material antes de empaquetar. Las pruebas A1–A6 permanecen pendientes con el artefacto candidato.

## Contraste individual de personajes E1

Las cuatro fichas de [autoría E1](../../../data/inicio_competitivo.json) señalan `src_005_personajes`, una hoja española de [SRC-005](../../referencias/README.md#src-005--escaneos-españoles-de-personajes-misiones-y-mercado). La huella de la copia local coincide con la declarada en autoría y en el registro de SRC-005. El [propietario confirmó](../008-preparacion-y-turnos/verification.md#cotejo-humano-e1-y-consulta-de-misiones--registro-previo) las cuatro fichas y sus tres niveles el 2026-11-24 para E1. La tabla conserva ese cotejo y el estado de autoría. Se comprobó el vínculo en ambos sentidos con los cuatro entrenamientos propios de cada ficha usando [InitialCompetitiveBindings](../../../scripts/catalog/initial_competitive_bindings.gd) como referencia.

| ID | Cantidad y localizador | Cobertura individual en E1 |
| --- | --- | --- |
| `kelsier` | 1, superior izquierda | Niveles I y III. Casos adicionales de capacidad inicial y bloqueo de III. |
| `marsh` | 1, inferior derecha | Niveles I y III. Casos adicionales de activación antes del desbloqueo. |
| `shan` | 1, inferior izquierda | Niveles I y III. |
| `vin` | 1, superior derecha | Niveles I y III. Caso adicional de límite de salud en I. |

En las cuatro definiciones, `revision.estado` permanece en `borrador` y `nivel_ii` contiene un efecto pendiente. [test-initial-content](../../../tests/initial_content_catalog_test.gd) valida estructura y vínculos y rechaza asociaciones incorrectas. [test-initial-play](../../../tests/initial_competitive_play_test.gd) promueve copias en memoria y excluye el nivel II. En cada ID comprueba la activación de I, la de III con Atium de prueba y el rechazo de una segunda activación de cada nivel. [test-local-competitive](../../../tests/local_competitive_play_test.gd) comprueba el nivel I para los cuatro IDs y tiene aserciones globales de uso de los niveles II y III en E2, sin exigir esos dos niveles por cada ID. La evidencia E2 usa mercado ficticio.

Para cada uno de los cuatro IDs queda pendiente revisar la definición final, resolver el descriptor II y verificar los tres niveles con la identidad del candidato. Cada ID necesita un registro de procedencia y base de inclusión para el texto, los iconos y la ilustración que se elijan.

## Contraste de entrenamientos, Financiación y pista E1

Se cruzaron los 18 IDs de [autoría E1](../../../data/inicio_competitivo.json) con el [cotejo humano del 2026-11-24](../008-preparacion-y-turnos/verification.md#cotejo-humano-e1-y-consulta-de-misiones--registro-previo) y el [registro de SRC-004](../../referencias/entrenamiento-competitivo.md). Las cinco huellas de los archivos locales coinciden con las publicadas y con el catálogo. El cotejo cubre la lectura de la edición española. Para Financiación y pista, la cantidad documentada corresponde a la dotación física, y el localizador identifica el ejemplar o panel visible en el escaneo.

| Fuente | IDs y localizadores | Cantidad |
| --- | --- | --- |
| `src_004_kelsier` | `kelsier_estano`, `kelsier_cobre`, `kelsier_cinc`, `kelsier_acero`, filas 1–4 en ese orden. | 1 de cada ID |
| `src_004_marsh` | `marsh_bronce`, `marsh_hierro`, `marsh_peltre`, `marsh_laton`, filas 1–4 en ese orden. | 1 de cada ID |
| `src_004_shan` | `shan_cinc`, `shan_estano`, `shan_cobre`, `shan_acero`, filas 1–4 en ese orden. | 1 de cada ID |
| `src_004_vin` | `vin_bronce`, `vin_hierro`, `vin_laton`, `vin_peltre`, filas 1–4 de la columna izquierda en ese orden. | 1 de cada ID |
| `src_004_vin` | `financiacion`, parte superior de la columna derecha, S17/40. | 24 |
| `src_004_panel` | `pista_entrenamiento`, 21 huecos desde la flecha. | 4 |

| Grupo | Cobertura de ensayo | Pendiente para la admisión |
| --- | --- | --- |
| 16 entrenamientos | [test-initial-content](../../../tests/initial_content_catalog_test.gd) verifica los vínculos recíprocos con los cuatro personajes. [test-initial-play](../../../tests/initial_competitive_play_test.gd) ejecuta la primaria de cada ID y comprueba movimiento, uso de metal, reenvío y rechazo de un segundo intento con otro identificador. La omisión se prueba en un caso dirigido. | Revisar cada definición final y cruzar todas sus rutas con preparación, activación y vuelta al ciclo personal con el catálogo candidato. |
| Financiación | `test-initial-play` comprueba el reparto inicial y los casos de aplicar u omitir. [test-local-competitive](../../../tests/local_competitive_play_test.gd) recorre el ciclo de compra y limpieza con un mercado de prueba. | Vincular la definición final al manifiesto y verificar su activación, descarte y reciclado en el mismo candidato. |
| Pista | `test-initial-play` comprueba inicio y premios seleccionados. El ensayo sustituye los efectos de las casillas en la copia de catálogo y el avance usa el perfil fijo de `TrainingAdvance.PANEL`. [test-training](../../../tests/training_advance_test.gd) recorre el perfil de prueba con 2, 3 y 4 plazas y verifica avance, desbloqueos y recompensas. | Resolver la representación y los descriptores de autoría pendientes. Probar las referencias de la pista y su recorrido con el manifiesto candidato. |

Las 18 definiciones permanecen en `borrador`. Para cada ID queda pendiente documentar la procedencia y base de inclusión del material usado en el candidato. Con los cuatro registros de personaje queda completo el contraste documental de los 22 IDs de E1. Véase el siguiente [contraste de las ocho misiones](#contraste-de-las-ocho-misiones).

## Contraste de las ocho misiones

Los ocho IDs del [catálogo de autoría](../../../data/misiones.json) tienen una copia cada uno y estado `verificada` en el catálogo v2. Sus nombres, cantidades y localizadores se cruzaron con la [tabla confirmada por el propietario el 2026-11-24](../008-preparacion-y-turnos/verification.md#confirmación-humana-de-misiones-m1m8--registro-previo). Las dos hojas de [SRC-005](../../referencias/README.md#src-005--escaneos-españoles-de-personajes-misiones-y-mercado) coinciden por SHA-256 con autoría y el registro de fuentes.

| ID | Hoja y posición | Ruta ejercitada en el perfil aislado | Dependencia por probar con el candidato |
| --- | --- | --- | --- |
| `mision_m1` | 1, superior izquierda | Refresco, elección de fichas y capacidad de quema. | Fichas agotadas por cartas y acciones del lote, y uso posterior de la capacidad. |
| `mision_m2` | 1, inferior izquierda | Combate, selección y traslado del aliado derrotado, falta de objetivos y beneficio de inicio. | Aliados del mercado con Defensor, efectos de derrota y reacciones en el turno integrado. |
| `mision_m3` | 1, superior derecha | Monedas en la reserva del turno, adquisición y aplicación del permanente en el inicio. | Compra con el mercado del lote y reinicio de la reserva en el turno completo. |
| `mision_m4` | 2, superior derecha | Robo inmediato, reciclado y aumento de mano en limpieza interna. | Limpieza pública y reciclado con el mazo del lote. |
| `mision_m5` | 2, inferior izquierda | Monedas, combate, curación y adquisición de Atium. | Identidad y uso de las fichas de Atium, compras y combate con el lote. |
| `mision_m6` | 1, inferior derecha | Avance de entrenamiento y umbrales con una pista de prueba. | Pista de E1, recompensas, desbloqueos y obtención de Atium al final de la pista según la errata. |
| `mision_m7` | 2, superior izquierda | Curación en las aserciones de avance. | Salud y marcadores del lote en un turno con daño y curación. |
| `mision_m8` | 2, inferior derecha | Elección u omisión de eliminaciones propias, incluido un aliado derrotado por M2 y trasladado al descarte. | Ofertas con cartas del lote, su propiedad, el destino y las referencias a eliminadas. |

La [suite de catálogo](../../../tests/mission_catalog_test.gd) comprueba nombres, localizadores y premios normales, del primero y permanentes en las 96 casillas. La [suite de integración](../../../tests/integrated_missions_test.gd) carga las ocho definiciones de autoría. Admite las 56 ternas por tamaño de mesa y ejecuta un recorrido por ID, para primeras llegadas y llegadas posteriores, en 2–4 plazas. Incluye casos dirigidos de elecciones, permanentes, fin al completar la tercera misión y rechazos. Sus estados, cartas auxiliares, pista y transiciones usan [datos de ensayo](../../../tests/integrated_missions_fixtures.gd). El sorteo de tres misiones y la composición con el catálogo candidato quedan pendientes.

El contraste aplica la [trazabilidad de reglas de misiones](../../referencias/misiones-competitivas.md#lectura-de-los-símbolos-y-reglas-aplicables) para SRC-001 pp. 5, 14 y 17 y [SRC-002](../../referencias/README.md#src-002--faq-y-erratas-del-editor), en particular la reserva sin retroceso de casillas, monedas del turno, eliminación opcional y avance al final de entrenamiento. Rigen las decisiones de la edición española ya registradas. La fidelidad de lectura y la ejecución aislada se consignan por separado de la base de inclusión de texto, iconos y arte, que sigue pendiente por material para los ocho IDs.

## Contraste de recursos y marcadores

El recuento procede de SRC-001 pp. 3 y 5. Los 12 marcadores de misión corresponden a tres por plaza en mesa de cuatro según el montaje de p. 5. Las posiciones de partida y los recursos se cruzan abajo con las representaciones de los ensayos. [Fuentes SRC-001/002](../../referencias/README.md) · [Matriz REG](../../referencias/matriz-reglas.md).

| Componente | Cantidad y preparación competitiva | Estado y cobertura comprobable | Dependencia del candidato |
| --- | --- | --- | --- |
| Metales ordinarios | 32 en caja. Ocho por plaza, 16/24/32 en mesas de 2/3/4. SRC-001 pp. 3, 5 y 7–8, REG-001 y REG-012–018. | `players[].metals` registra identidad, metal y marcas de uso y agotamiento. `burn_limit` empieza en 1. Preparación verifica ocho fichas por plaza. E2 alcanza quema, fulguración y refresco con contenido de ensayo. Limpieza comprueba el reinicio de uso y la conservación del agotamiento. | Vincular las fichas a las definiciones de mercado que las consumen y verificar límites y persistencia con el lote. |
| Diales de salud | Cuatro en caja, uno por plaza. Salud por orden 36/38/40/40 según las plazas presentes. SRC-001 pp. 3, 5, 13 y 15–16 y REG-001/002/035. | `players[].health` y `eliminated` representan dial y eliminación. Preparación verifica las bonificaciones y E2 ejecuta daño y cierre por supervivencia. | Verificar curación, reducción, eliminación y sus efectos sobre cartas y marcadores con las rutas de combate y misión del lote. |
| Pistas y marcadores de entrenamiento | Cuatro pistas y un marcador por plaza. La preparación parte de la primera casilla, representada por la posición 0. El panel español cotejado tiene 21 casillas. SRC-001 pp. 3, 5 y 12, SRC-004 y REG-028/029. | `training_track_id` y `training` enlazan la definición de pista y su posición. El perfil aislado prueba umbrales, capacidad y la ganancia de Atium con avances posteriores al final conforme a SRC-002, errata 2. [Pista E1](#contraste-de-entrenamientos-financiación-y-pista-e1) · [Prueba de avance](../../../tests/training_advance_test.gd). | Verificar avances por inicio, cartas y misiones con las referencias y la pista del lote. |
| Marcadores de misión | Tres por plaza, 6/9/12 en mesas de 2/3/4. Empiezan fuera de la pista de cada una de las tres misiones seleccionadas. SRC-001 pp. 5 y 14–15, SRC-002 «Miscellaneous» y REG-004/032–035. | `missions[mission_id].progress[player_id]` guarda la posición, inicialmente 0. Cada misión también registra premios y orden de llegada. Preparación cubre la estructura y el perfil M1–M8 cubre avance y premios con auxiliares de ensayo. [Contraste por misión](#contraste-de-las-ocho-misiones). | Comprobar estados de posición, empates, primera llegada y conservación de posiciones al eliminar una plaza con cartas del lote. |
| Atium | 16 fichas físicas en suministro común. Las plazas empiezan con saldo 0. SRC-001 pp. 3, 5 y 8. La p. 8 permite sustitutos al agotar las fichas. REG-019/020. | `persistent.atium` coincide con el número de fichas de Atium en `metals`. Limpieza comprueba que salen las usadas y se conservan las demás. E2 recorre quema de Atium y nivel III con fixtures. | Probar fuentes de ganancia y usos del lote, incluido comodín, límite de quema y Confrontación. |
| Boxings | 14 fichas físicas en suministro común. La cuarta plaza empieza con una en mesa de cuatro. SRC-001 pp. 3, 5 y 16. La p. 16 permite sustitutos. SRC-002, «Miscellaneous», distingue la ficha de las monedas. REG-002/043/075. | `persistent.boxings` se conserva al limpiar, separado de las monedas en `turn_resources.recursos`. E2 prueba compra por dos monedas, persistencia y canje por una. | Repetir asignación, compra y canje con el candidato. |
| Target | Una figura. Se asigna a la última plaza al preparar mesa de 3 o 4 y se retira al quedar dos supervivientes. SRC-001 pp. 3, 5 y 15–17, SRC-002 «Combat» y REG-006/039–041. | `target_id` guarda la plaza portadora o un valor nulo. La preparación verifica la asignación inicial y E2 recorre el relevo y la retirada en mesas de 3 y 4. | Probar daño efectivo, protección por aliados, reasignación y daño remanente con el contenido del lote. |

[Preparación y pruebas](../../../tests/game_setup_test.gd) · [Invariantes de estado](../../../scripts/game/state_validator.gd) · [Limpieza](../../../tests/turn_cleanup_test.gd) · [Combate y recursos de E2](../../../tests/local_competitive_play_test.gd).

El registro identifica las representaciones que ya pueden probarse. La identidad de las piezas y su representación final se comprobarán en A1–A3 con el manifiesto y los recorridos del candidato. La procedencia y autorización de los materiales visuales que se incluyan se comprobarán en A6 con el paquete real. [Pruebas de admisión](lote-integracion.md#pruebas-de-admisión-propuestas).
