# Contrato de objetivos y premios de M2

T08.1b19, entrega documental R2 para competitivo de 2–4 plazas. Borrador y traspaso provisional revisados favorablemente; pendiente de decisiones DUD-010 y concreción posterior. No autoriza implementar una interpretación pendiente. Motor vigente **snapshot 6 / `p08-m1-refresh-1/godot-4.7.2`** sin cambios. M2 no está admitida en ningún perfil ejecutable actual. [Registro previo](tasks.md#t081b19--contrato-de-objetivos-y-premios-m2).

Fuentes: [SRC-001](../../referencias/README.md#src-001--reglamento-aportado-por-el-usuario), pp.9–11 y 14–17; [SRC-002, FAQ oficial](https://www.brotherwisegames.com/mistborn-deckbuilding-game-faq), secciones «Combat», «Action cards», «Player abilities & allies», «Missions» y «Solo & Co-op mode»; [SRC-005, M2](../../referencias/misiones-competitivas.md), hoja `misiones.1.png`, inferior izquierda. REG-025/033/036–038/051/054/058, DEC-031/034. SRC-002 consultada el 2026-11-14; contraste y revisión del borrador registrados en la evidencia. El [catálogo v2](catalogo-misiones.md) representa `derrotar_aliado_en_juego`; un descriptor válido no ejecuta ni aclara sus objetivos.

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

## Objetivos y decisiones pendientes

El texto español «Derrota a 1 Aliado en juego» no explicita propio/ajeno ni omisión. SRC-001 p.11 describe Defender como restricción de selección por oponentes; no basta con su descripción de daño de p.9 para concluir que la derrota directa lo ignora. SRC-002 no resuelve expresamente estos casos de M2. [DUD-010](../../referencias/dudas.md) recoge tres cuestiones consultadas al usuario: permitir aliados propios además de rivales; obligatoriedad con objetivo y cierre sin efecto sin objetivo; aplicar Defender a este premio. **Pendientes: no convertir ninguna opción en decisión aceptada por silencio.** DEC-037 es exclusiva de M1 y no resuelve M2.

La futura oferta se deriva de aliados en zonas `juego` de plazas vivas admitidas, excluyendo acciones, personajes, aliados de mano/descarte/mercado y adversarios del rival. Debe respetar la decisión pendiente de propiedad y Defender. Las defensas numéricas no son un coste de derrota directa. Un aliado propio, si se admite, no queda restringido por una protección que sólo prohíbe a oponentes seleccionarlo; no reinterpretar Defender como protección universal de aliados de todas las plazas. Elegir un objetivo y protegerlo son hechos distintos: una protección no autoriza volver a elegir otro objetivo salvo fuente expresa.

Cloud depende del texto de la carta. Una reducción de daño al jugador no cancela por sí sola una derrota directa de aliado; sólo admitir una reacción cuyo texto verificado cubra esa derrota. La reacción de fuera de turno de una carta no exige quemar su metal y lleva su coste de descarte, conforme a SRC-001 pp.10/16; coste, destinatarios y alcance exactos deberán contrastarse para la carta admitida. No anunciar una reacción ficticia ni asumir protección ilimitada por el nombre de una palabra clave. El inventario de mercado no acredita esas reglas.

El piloto propuesto selecciona **M2/M5/M7**, con las ocho misiones reales congeladas y aliados fixture de autoridad sin habilidades, Defender ni reacciones; resto de contenido inerte explícito, sin Funding activo. Es una prueba del traslado/selección y permanente, no M2 de producto. No admitir un catálogo con Cloud, Defender o disparadores fuera del contrato, incluso si el cliente promete no usarlos. El contrato de reacciones y catálogo real se completarán antes de ampliar ese piloto. Su exclusión explícita no permite ignorarlos al integrar producto ni eludir una decisión reglamentaria que afecta al diseño general.

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

## Plan de implementación pendiente

Primero cerrar objetivos, opcionalidad y reacciones a partir del contraste y de cualquier decisión humana necesaria. Sólo entonces fijar un perfil piloto y su contrato cerrado de aliados; ningún fixture inerte acredita Cloud, Defender o habilidades reales. Versionar explícitamente snapshot/motor al introducir semántica ejecutable M2: la siguiente versión libre tras snapshot 6 es 7, aún propuesta, sin migración implícita ni admisión de snapshots anteriores reparados al cargar.

Un implementador poseerá código/pruebas/lanzador y el coordinador documentación/integración/ejecución Godot en serie. La implementación necesita contraste reglamentario resuelto y revisión independiente R2; no extender automáticamente los perfiles M1/M8/permanentes ni introducir entrada a limpieza. Sin UI/transporte, revisión visual y ensayo de red no aplican a esta entrega documental. Competitivo prioritario no elimina cooperativo/solitario: la sustitución de derrota por pérdida de escudo y sus excepciones exigen contrato del rival, fuera de M2 competitiva. P04 externa y P08 completa siguen abiertas.

## Escenarios futuros

No se han ejecutado: constituyen aceptación de la futura implementación en 2/3/4 plazas. Los casos condicionados se concretarán al resolver DUD-010; los de protección real pertenecen a la ampliación de producto, no se acreditan con fixtures inertes.

| AC futuro | Resultado exigido |
| --- | --- |
| M2-01 · Premios | Llegadas 4/7/10 añaden 1/2/3 ataque; sólo el primero recibe derrota directa. Normal antes del extra; posteriores sin secuencia de objetivo. Reservas previas se conservan; no conceder monedas ni gastar combate como defensa. |
| M2-02 · Objetivos | Cero/uno/varios aliados elegibles; propios/rivales según resolución expresa, dos instancias del mismo diseño diferenciadas; excluir zonas/tipos/plazas inválidos. Oferta completa desde autoridad, selección opaca y rechazo de opción ajena, repetida, antigua o payload extra. Omitir o exigir selección y resolver oferta vacía según DUD-010. |
| M2-03 · Derrota | Instancia seleccionada pasa de juego al final del descarte de su propietario una vez. No cambia propiedad, salud, ataque ni cartas ajenas; no hay daño parcial, eliminación ni RNG. Fallo después del traslado revierte segmento. |
| M2-04 · Permanentes | Primera cima no terminal +3 ataque, posterior +2; adquisición y marca juntas. Inicio propio posterior: entrenamiento y +2 antes de libre en un commit. Reenvío/restauración/nuevo ID no duplican; M3 sigue dando monedas y M2 nunca se despacha como M3. |
| M2-05 · Final | Tercera cima M2 termina antes de premios, grupo o marca; tercera cima M5/M7 conserva M2 previa. Primera/segunda no terminan. Duplicado ganador devuelve recibo; nueva acción posterior rechazada. |
| M2-06 · Pausas y carga | Cargar selección produce mismo resultado que continuidad; grupos/cursor/objetivo/fuente/programa/destinatario/ledger falsos se rechazan sin sustituir estado. Marca perdida, huérfana, futura o reaplicada se rechaza. Pausa en cima automática inválida; RNG y estado completos conservados ante rechazo. |
| M2-07 · Límites y privacidad | Más de 16 objetivos no se truncan: declarar techo por programa y presupuestar oferta/vista/recibos/cierre antes de gasto y al cargar. Presupuesto insuficiente rechaza íntegro. Dueño elige desde su vista, terceros sin opciones/secretos y descartes ajenos sólo con conteo. |
| M2-08 · Producto condicionado | Defender por rival y varias copias según decisión expresa; cartas de protección específicas con aplicar/pasar, coste, éxito/fallo y restauración en reacción; protección no retargetea ni cobra daño. Rechazar aliado/protección no admitidos en piloto; no contabilizar estos casos como superados por el fixture inerte. |

Después de cerrar DUD-010: detallar programas, contexto exacto y cardinalidades del piloto; derivar límites propios sin copiar 10.000 de M1/M8 por comodidad; extender marcas/inicio por definición y registrar adaptador aislado. Implementar suite M2 y regresiones M1, M8, misiones automáticas/permanentes, secuencia, estado/motor, preparación, entrenamiento/inicio, ciclo/limpieza, Funding y catálogos. Confirmar nombres reales en `tools/godot.ps1`; no existe aún una acción `test-m2`. Revisión independiente del código final antes de declarar esa futura entrega completada.
