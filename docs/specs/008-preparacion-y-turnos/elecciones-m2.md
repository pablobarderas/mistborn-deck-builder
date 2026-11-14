# Contrato de objetivos y premios de M2

T08.1b19, entrega documental R2 para competitivo de 2–4 plazas. DUD-010 resuelta por DEC-039, respuesta humana del 2026-11-14. Contrato completado documentalmente y revisado favorablemente, M2-DOC-01–04 satisfechos. T08.1b20 implementa y verifica el piloto aislado M2/M5/M7: **snapshot 7 / `p08-m2-defeat-1/godot-4.7.2`**, 17 suites/11.712 comprobaciones. Revisión independiente favorable sin hallazgos residuales; T08.1b20 completada localmente. [Evidencia vigente](verification.md#t081b20--implementación-de-objetivos-y-premios-m2). No acredita producto ni Defender/Cloud reales. [Registro previo](tasks.md#t081b19--contrato-de-objetivos-y-premios-m2).

Fuentes: [SRC-001](../../referencias/README.md#src-001--reglamento-aportado-por-el-usuario), pp.9–11 y 14–17; [SRC-002, FAQ oficial](https://www.brotherwisegames.com/mistborn-deckbuilding-game-faq), secciones «Combat», «Action cards», «Player abilities & allies», «Missions» y «Solo & Co-op mode»; [SRC-005, M2](../../referencias/misiones-competitivas.md), hoja `misiones.1.png`, inferior izquierda. REG-025/033/036–038/051/054/058, DEC-031/034 y [DEC-039](../../decisiones.md#dec-039--objetivos-y-obligatoriedad-del-premio-m2). SRC-002 consultada el 2026-11-14; contraste y revisión del borrador registrados en la evidencia. El [catálogo v2](catalogo-misiones.md) representa `derrotar_aliado_en_juego`; un descriptor válido no ejecuta ni aclara sus objetivos.

## Premios confirmados

| Llegada M2 | Normal o permanente | Extra de la primera plaza |
| --- | --- | --- |
| 4 | +1 combate a la reserva propia | Derrotar un Aliado en juego |
| 7 | +2 combate a la reserva propia | Derrotar un Aliado en juego |
| 10 | +3 combate a la reserva propia | Derrotar un Aliado en juego |
| 12, primera o segunda misión completada | Instalar +2 combate por turno y aplicarlo al llegar | +1 combate adicional |
| 12, tercera misión completada | Victoria inmediata antes del permanente | Sin premios |

El combate aumenta `turn_resources.ataque`; no causa daño inmediato ni obliga a consumir esa reserva. El premio de derrota directa no paga defensa con combate ni reduce la reserva concedida por el normal. No implementar combate ordinario para simular ese efecto. Normal antes de extra, primeras llegadas persistentes y tercera cima antes de premios conservan DEC-034. La derrota envía la instancia al descarte de su propietario; no al del actor, a eliminadas ni al mercado. No reciclar ni consumir RNG por ese traslado.

## Permanente e inicio

La posesión deriva de definición exacta M2, progreso 12 y grupo `p12_permanente` liquidado. Al llegar sin final, sumar 2 a ataque, instalar grupo y crear marca privada `{acquired_turn, last_applied_turn}` al turno global actual juntos; el primero suma después 1 adicional. Llegadas posteriores conceden 2, no 3. Tercera cima M2 no instala grupo ni marca ni concede combate; permanentes previos sobreviven al final sin reaplicarse.

En cada inicio propio posterior, después del entrenamiento y antes de `libre`, sumar 2 una vez y actualizar `last_applied_turn` en la misma transacción de inicio. No crear acción pública para cobrarlo. Carga/reenvío no ejecutan premios ni reconstruyen marcas perdidas; conservar adquisición y exigir correspondencia biunívoca entre marca y grupo, incluso para plazas eliminadas. No aplicar en turnos ajenos ni volver a sumar en el turno de adquisición. Las restricciones temporales de [M3](permanentes-misiones.md#estado-previsto-y-compatibilidad) se aplican a la marca M2 identificada por su misión, sin confundir recursos.

Discrepancia técnica: `permanents_play.gd._start` añade actualmente `recursos` para todas sus marcas porque sólo admite M3. Extender ese bucle sin despacho por definición concedería monedas en lugar de combate a M2. La futura implementación deberá derivar recurso/cantidad de la misión congelada y conservar la admisión de perfiles anteriores; no basta con aceptar otra clave en `mission_permanents`.

## Objetivos y decisión aceptada

El texto español «Derrota a 1 Aliado en juego» no explicita propio/ajeno ni omisión. SRC-001 p.11 describe Defender como restricción de selección por oponentes; SRC-002 no aclara expresamente su aplicación a M2. La respuesta humana «si» del 2026-11-14 a las tres reglas conjuntas resuelve [DUD-010](../../referencias/dudas.md) mediante DEC-039: permitir propios y rivales, exigir seleccionar cuando hay objetivo y liquidar sin efecto cuando no hay ninguno, respetando Defender por rival. Es adaptación aceptada; no una errata del editor ni una extensión de DEC-037 de M1.

Son candidatos los aliados en zonas `juego` de plazas vivas admitidas. Excluir acciones, personajes, aliados de mano/descarte/mercado y adversarios del rival. Para cada propietario rival, si controla uno o varios Defender, sólo sus Defender son candidatos; los aliados de otro rival sin Defender siguen siendo elegibles. Los propios son elegibles aunque el actor controle Defender: la restricción es para oponentes. Las defensas numéricas no son un coste de derrota directa. Con candidatos se elige exactamente uno, incluso cuando sólo hay uno; `[]` no permite omitir. Sin candidatos se liquida automáticamente sin efecto, ventana vacía ni deuda futura. Elegir un objetivo y protegerlo son hechos distintos: una protección no autoriza volver a elegir otro objetivo salvo fuente expresa.

Cloud depende del texto de la carta. Una reducción de daño al jugador no cancela por sí sola una derrota directa de aliado; sólo admitir una reacción cuyo texto verificado cubra esa derrota. La reacción de fuera de turno de una carta no exige quemar su metal y lleva su coste de descarte, conforme a SRC-001 pp.10/16; coste, destinatarios y alcance exactos deberán contrastarse para la carta admitida. No anunciar una reacción ficticia ni asumir protección ilimitada por el nombre de una palabra clave. El inventario de mercado no acredita esas reglas.

T08.1b20 implementa el piloto que selecciona **M2/M5/M7**, con las ocho misiones reales congeladas y aliados fixture de autoridad sin habilidades, Defender ni reacciones; resto de contenido inerte explícito, sin Funding activo. Es una prueba del traslado/selección y permanente, no M2 de producto. No admitir un catálogo con Cloud, Defender o disparadores fuera del contrato, incluso si el cliente promete no usarlos. El contrato de reacciones y catálogo real se completarán antes de ampliar ese piloto. Su exclusión explícita no permite ignorarlos al integrar producto ni eludir una decisión reglamentaria que afecta al diseño general.

## Autoridad, restauración y privacidad

Al integrar producto, retirar los efectos continuos del aliado cuando deje juego, sin revertir beneficios ya concedidos. Las obligaciones persistentes específicas, como la carta reservada por Guardadora, requieren su contrato y no se borran por asumir que toda obligación desaparece con la derrota. El piloto con aliados inertes no acredita ninguno de estos casos.

Conservar intención exacta `avanzar_mision` con `{mission_id}` y guardas del [avance](avance-misiones.md). El cliente no indica cantidad, primer puesto, defensa, grupo ni efecto. La autoridad decide ruta directa o secuencia y congela catálogo, registro y perfil. Antes de gastar se debe conocer el soporte completo del premio y su presupuesto hasta cierre; rechazar sin mutación todo contenido con obligaciones no soportadas, aunque no estén en juego en ese instante.

Cada segmento hasta pausa/cierre es atómico: fallo antes de la primera ventana revierte gasto, llegada y normal; fallo en una respuesta revierte sólo ese segmento y conserva lo ya confirmado. Revalidar objetivo por `instance_id`, propietario, zona actual y definición; nunca seleccionar sólo por nombre o ID de diseño. Reenvíos y cierres usan recibos/ocurrencias estables de P07. Ningún efecto de M2 exige azar; validar RNG real inalterado antes del commit.

La futura selección de objetivo y, si procede, la reacción del defensor son ventanas distintas. `SequenceRegistry.valid_pending` sólo admite un destinatario por ventana; `context.owner_id` sigue siendo el actor activo. No cambiar dueño/turno para permitir responder al defensor ni aceptar callbacks enviados por cliente. No copiar un programa M1/M8 como si ya resolviera una reacción de otra plaza: requiere contexto y validación propios. No hay anidamiento genérico ni contrato de reacciones de aliados implementados actualmente.

Las identidades de aliados en `juego` ya son públicas. Mostrar al destinatario únicamente correspondencias opacas suficientes para elegir un objetivo o una respuesta admitida; terceros conservan bloqueo público y zonas autorizadas. Una carta derrotada que entra en descarte ajeno deja de aparecer en la lista pública de esa zona: mantener el conteo autorizado, sin enviar el descarte completo ni manos, RNG, recibos o diagnósticos. La información observada antes no justifica ampliar la proyección posterior.

Al restaurar desde fuente tipada fiable en motor vacío, comprobar versión/perfil, catálogo/registro, cursor, objetivo y destinatario, oferta completa, grupos/ledger, marcas y presupuesto de la vista actual y del cierre. No reaplicar llegada, normal, descarte ni permanente. Grupos intermedios previstos `p04_normal/primero`, `p07_normal/primero`, `p10_normal/primero`; cima `p12_permanente/primero`. Sólo una pausa coherente de la llegada actual puede justificar grupos pendientes; no ocultar deudas ajenas. Rechazar una resolución asociada a cima, cuya recompensa es automática.

## Aceptación documental

| AC | Evidencia exigida |
| --- | --- |
| M2-DOC-01 | Premios, objetivos, derrota/reacciones y excepciones contrastados con SRC-001/002/005; incertidumbres separadas de reglas confirmadas y decisiones humanas. |
| M2-DOC-02 | Contrato técnico contra APIs reales: segmentos, grupos, marcas, carga, privacidad, admisión y límites; sin ejecutar interpretaciones pendientes. |
| M2-DOC-03 | Plan y escenarios futuros trazables; dependencias y compatibilidad explícitas, sin atribuir pruebas no ejecutadas. |
| M2-DOC-04 | Enlaces/anclas y diff válidos, contraste de reglas, revisión independiente, hallazgos resueltos y traspaso actualizado; ninguna dispensa inferida. |

## Plan de implementación T08.1b20

DEC-039 cierra propiedad, obligatoriedad/vacío y Defender. La implementación cubre el piloto cerrado sin habilidades ni reacciones; la ampliación de producto conserva sus dependencias. T08.1b20 usa **snapshot 7 / `p08-m2-defeat-1/godot-4.7.2`**, catálogo v2 e intención v1. Snapshot 6 corresponde al antecedente M1. Sin migración implícita ni reparación de snapshots antiguos al cargar. Ajustar constructores, versiones y fixtures compartidos explícitamente, conservando las restricciones semánticas de perfiles anteriores.

Un implementador poseerá código/pruebas/lanzador y el coordinador documentación/integración/ejecución Godot en serie. La implementación necesita este contrato revisado y revisión independiente R2 de su código final; no extender automáticamente los perfiles M1/M8/permanentes ni introducir entrada a limpieza. Sin UI/transporte, revisión visual y ensayo de red no aplican a esta entrega documental. Competitivo prioritario no elimina cooperativo/solitario: la sustitución de derrota por pérdida de escudo y sus excepciones exigen contrato del rival, fuera de M2 competitiva. P04 externa y P08 completa siguen abiertas.

## Escenarios de verificación

T08.1b20 ejecuta M2-01–07 y el rechazo de admisión de M2-08 en 2/3/4 plazas; resultados en su [evidencia](verification.md#t081b20--implementación-de-objetivos-y-premios-m2). Los casos de selección del piloto aplican DEC-039. Los de Defender y protección real pertenecen a la ampliación de producto, no se acreditan con fixtures inertes; en el piloto se comprueba su rechazo de admisión.

| AC de T08.1b20 | Resultado exigido |
| --- | --- |
| M2-01 · Premios | Llegadas 4/7/10 añaden 1/2/3 ataque; sólo el primero recibe derrota directa. Normal antes del extra; posteriores sin secuencia de objetivo. Reservas previas se conservan; no conceder monedas ni gastar combate como defensa. |
| M2-02 · Objetivos | Cero/uno/varios aliados elegibles; propios y rivales según DEC-039, dos instancias del mismo diseño diferenciadas; excluir zonas/tipos/plazas inválidos. Oferta completa desde autoridad, selección opaca y rechazo de opción ajena, repetida, antigua o payload extra. Exigir una selección incluso con un candidato y rechazar omisión; cero candidatos liquida sin efecto ni ventana. Admitir y cargar el cierre automático sin deuda. |
| M2-03 · Derrota | Instancia seleccionada pasa de juego al final del descarte de su propietario una vez. No cambia propiedad, salud, ataque ni cartas ajenas; no hay daño parcial, eliminación ni RNG. Fallo después del traslado revierte segmento. |
| M2-04 · Permanentes | Primera cima no terminal +3 ataque, posterior +2; adquisición y marca juntas. Inicio propio posterior: entrenamiento y +2 antes de libre en un commit. Reenvío/restauración/nuevo ID no duplican; M3 sigue dando monedas y M2 nunca se despacha como M3. |
| M2-05 · Final | Tercera cima M2 termina antes de premios, grupo o marca; tercera cima M5/M7 conserva M2 previa. Primera/segunda no terminan. Duplicado ganador devuelve recibo; nueva acción posterior rechazada. |
| M2-06 · Pausas y carga | Cargar selección produce mismo resultado que continuidad; grupos/cursor/objetivo/fuente/programa/destinatario/ledger falsos se rechazan sin sustituir estado. Marca perdida, huérfana, futura o reaplicada se rechaza. Pausa en cima automática inválida; RNG y estado completos conservados ante rechazo. |
| M2-07 · Límites y privacidad | Más de 16 objetivos no se truncan: declarar techo por programa y presupuestar oferta/vista/recibos/cierre antes de gasto y al cargar. Presupuesto insuficiente rechaza íntegro. Dueño elige desde su vista, terceros sin opciones/secretos y descartes ajenos sólo con conteo. |
| M2-08 · Producto condicionado | Defender por rival y varias copias según DEC-039, sin restringir propios ni proteger otro rival; cartas de protección específicas con aplicar/pasar, coste, éxito/fallo y restauración en reacción; protección no retargetea ni cobra daño. Rechazar aliado/protección no admitidos en piloto; no contabilizar estos casos como superados por el fixture inerte. |

Plan: (1) snapshot 7, identidad y admisión de perfil exacto M2/M5/M7; (2) candidato compartido de selección/traslado, programa y proyección descritos debajo; (3) marcas M2 e inicio interno atómico sin conceder monedas por error; (4) suite `tests/m2_test.gd` con fixtures explícitos y acción nueva prevista `test-m2`; (5) ejecutar M2-01–07 y rechazo de admisión de M2-08, más regresiones M1, M8, misiones automáticas/permanentes, secuencia, estado/motor, preparación, entrenamiento/inicio, ciclo/limpieza, Funding y catálogos. Confirmar nombres reales en `tools/godot.ps1`; se ha añadido `test-m2`. Revisión independiente del código final antes de declarar T08.1b20 completada. Los casos ejecutados Defender/Cloud de M2-08 son una puerta futura de producto y quedan fuera del cierre del piloto.

## Programa y oferta del piloto

Adaptador [m2_play.gd](../../../scripts/game/m2_play.gd), con catálogo/pista/registro congelados. Sólo admite competitivo 2–4, M2/M5/M7 exactas, fases `inicio` y `libre` sin final y el final por tres misiones; ninguna resolución en `inicio`. Resto de definiciones/instancias sólo fixtures inertes reconocidos de autoridad. No admite perfiles combinados con M1/M3/M4/M6/M8 ni cartas con obligaciones desconocidas, aunque salieran de juego. No expone jugar cartas, quema, combate, limpieza ni cobro público. El permanente M2 es la única misión con entradas en `authority.mission_permanents` del piloto.

Ruta directa para casillas sin premio, llegadas posteriores a 4/7/10, las dos primeras cimas M2 y las llegadas M5/M7. En la cima M2 confirmar permanente/+2/marca y extra +1 del primero juntos, sin secuencia. La tercera cima siempre conserva la ruta terminal ya definida: llegada/primer puesto/resultado antes de premios, grupos o ledger de esa cima. No crear una ventana para cobrar combate.

Sólo la primera llegada M2 a 4/7/10 usa el programa cerrado `m2_first_v1`, `source_id: mision_m2`, destinatarios `[owner_id]`, contexto exacto `{owner_id, turn_number, entry_phase, occurrence_id, mission_id, position}`; `entry_phase` es `libre`. La ocurrencia se deriva de `(match_id, owner_id, mission_id, position)` como en `MissionAdvance.occurrence`, nunca del intento o conexión. No añadir un objetivo mutable al contexto: se reconstruye la oferta y la respuesta de `s02` lo selecciona y derrota en el mismo segmento, sin pausa de reacción en este piloto.

| Paso | Operación y frontera |
| --- | --- |
| `s01` automático | Gastar un punto, registrar llegada/primer puesto, sumar normal +1/+2/+3 y liquidar `p04_normal`, `p07_normal` o `p10_normal`, según posición. No publicar un snapshot a mitad de este paso. |
| `s02` elección | Derrotar exactamente un aliado seleccionado y liquidar el grupo correspondiente `p04_primero`, `p07_primero` o `p10_primero`. Sin candidatos, `auto_empty` ejecuta internamente `[]`, liquida grupo y cierra sin ventana. |

La única pausa confirmada tiene cursor 1: llegó a la posición, actor es el primero, normal liquidado y extra pendiente; ninguna otra plaza/grupo queda pendiente. En el candidato previo a `s01`, cursor 0 sólo es estado de trabajo: progreso anterior a la casilla, primera llegada libre, punto disponible y grupos ausentes. Al cierre ambos grupos quedan liquidados y se registra una sola ocurrencia en ledger. Una primera llegada sin aliados también conserva cierre/ledger, aunque todo termine en la intención inicial; no se convierte en ruta directa para borrar evidencia.

Ofertar en orden de `player_order` y, para cada plaza, orden de cartas de su única zona `juego`. Una opción opaca ordinal por instancia, vinculada a resolución/paso. Proyección específica `option_allies` sólo para el destinatario del programa M2, array exacto `{option_id, instance_id, definition_id, owner_id, zone_id}` en el mismo orden; no reutilizar la correspondencia M8 que sólo contempla cartas propias. La respuesta sigue siendo `responder` con payload exacto `{resolution_id, step_id, options}`. Con candidatos, `kind: eleccion`, `recipients: [owner_id]` y `min=max=1`, incluso uno; una oferta errónea nunca equivale a vacía. Revalidar oferta completa antes del traslado, destino descarte de ese propietario y delta permitido. No admitir cartas arbitrarias enviadas por el cliente.

## Límites, reserva y comienzo de turno

Aplicación técnica verificada T08.1b20: se valida cada destino y se simula un representante por propietario. En el catálogo inerte, seleccionar otra instancia del mismo propietario sólo traslada una referencia y produce cierre/vistas con igual número de nodos; no introduce habilidades ni reacciones que rompan esa equivalencia. No extender esta cota al producto sin nuevo contraste. La prueba de descarte con 10.000 instancias únicas excede por sí misma el límite de 50.000 nodos privados: se acredita rechazo estructural y guarda aislada del segundo destino, no una partida restaurable con ese descarte. La frontera de vista 50.001 sí parte de snapshot válido y de un cierre que cabe; se rechaza la vista actual antes del gasto/carga.

`MissionAdvance.occurrence` conserva la tupla de identidad, pero su implementación actual elige prefijo M1/M8 según perfil. Al integrar M2, definir su prefijo de programa de forma explícita sin cambiar IDs/semántica de perfiles previos ni derivarlo de una conexión o un intento.

El programa declarará techo técnico de **10.000 opciones** porque `pending.options` es un contenedor con ese máximo global. No es un límite físico de aliados: si el conjunto legal excede el techo, rechazar antes de gastar sin truncar ni excluir objetivos para hacerlo caber. Mantener además 50.000 nodos, profundidad 20, 64 pasos y límites de intención/IDs. Programas anteriores conservan su techo propio, 16 por defecto. El piloto no abre cartas con reacciones para eludir límites ni las reemplaza por respuestas automáticas.

Antes del gasto y al restaurar, reservar presupuesto de llegada, normal/extra, oferta completa y su proyección actual, recibos/revisiones/IDs, traslado y cierre/ledger. Probar cota suficiente para **todos** los objetivos ofertados, no sólo el primero: distintos propietarios implican distintos descartes y vistas. Un descarte destino lleno o una vista/cierre sin capacidad causa rechazo íntegro, no exclusión silenciosa de ese objetivo ni fallo inevitable tras confirmar normal. Puede usarse comprobación de cotas equivalente en lugar de simular todas las ramas, pero debe demostrar que toda elección legal puede cerrar. Validar desbordamiento de ataque antes de llegada/normal y permanente; fallo en una respuesta conserva normal ya confirmado. Revalidar delta/RNG real antes de publicar, incluidas rutas directas y callbacks maliciosos.

El adaptador sólo expone `start_turn` a autoridad fiable, con payload interno exacto `{turn_number}` e ID estable de ocurrencia de inicio. Rechazar el namespace interno desde `submit` antes de consultar recibos, como en el contrato de permanentes. Confirmar entrenamiento, +2 ataque si corresponde, marca y apertura de `libre` en un commit. Falla de entrenamiento, overflow, presupuesto o marca revierte todo, incluido RNG/recibos. Conservar usos de metales y reglas de entrenamiento; no permitir sumar recursos para falsear la fase.

No se implementará `finish_cleanup` en el nuevo piloto ni transición `libre -> limpieza`. Probar inicios posteriores desde snapshots fixture de una fuente de autoridad fiable que acredite la entrega previa de turno: no cambiar el snapshot cliente ni exponer un setter para saltar a `inicio`. Esos fixtures no acreditan un ciclo completo ni una partida. Marcas M2 conservan adquisición y última aplicación en turno global; no son contadores libres ni se admiten huérfanas, futuras o de inicio parcialmente aplicado. Perfiles previos mantienen sus validaciones y servicio de limpieza sin admitir M2 accidentalmente.
