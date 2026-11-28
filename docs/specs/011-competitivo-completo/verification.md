# E3.1 — Verificación y traspaso

2026-11-24. Riesgo R2; [objetivo, aceptación, plan y responsables](tasks.md) registrados antes de editar. Rama `main`, HEAD/origin/main de partida `5cb60011410d855304a0c2616487cee92a91aada`, árbol limpio. El inventario de autoría en `docs/specs/` contiene 65 diseños y 82 copias con 17 duplicados, distribuidos en 40 acciones de color, 21 aliados y 4 Atium. Cada entrada tiene ID por localizador, fuente y huella SHA-256, y las tres puertas pendientes. Nueve escaneos siguen fuera de Git; el runtime no carga este JSON.

Comprobaciones: `python tools/market_inventory.py --source-root <carpeta-local>` y `python tests/market_inventory_test.py --source-root <carpeta-local>` correctos: 10 casos, incluidos IDs invariables al reordenar filas y rechazos de ID/cantidad/fuente/huella/estado/tipos alterados. En este PC, `<carpeta-local>` es `C:/Users/pbard/Pictures/Digitalizaciones/cartas_mercado`; los nueve archivos deben existir con sus huellas para reproducir la prueba. `python -m py_compile` correcto; 458 enlaces locales de documentos afectados comprobados sin ausencias; `git diff --cached --check` correcto. Revisión independiente `sdd_reviewer` Sol/high favorable tras corregir dos hallazgos P2: igualdad laxa entre tipos JSON y reasignación de IDs por orden de fila. El revisor contrastó independientemente las 65 filas, 82 copias, grupos 10/10/10/10/21/4 y nueve huellas; confirmó rechazo de fuente ausente y bytes cambiados, y ausencia de PNG versionados. No se modificó ni probó Godot: el registro no está conectado al runtime.

Cumplimiento: aceptación, fuentes, plan, pruebas adversas y revisión independiente realizados; ninguna dispensa. La fidelidad de caras, edición/idioma y revisión humana por componente, efectos, referencias y base de distribución permanecen pendientes. No se ha construido manifiesto, catálogo jugable ni paquete. E1 conserva su cotejo humano. Siguiente paso: cotejar individualmente las caras de mercado y del lote inicial con una persona, registrar los campos faltantes de T08.1b30 y agrupar después las familias de efectos para E3. No regenerar los IDs como números de fila ni promover por la huella sola.

## E3.2 — Preparación del cotejo

2026-11-26. Se recuperó el estado publicado de `main` en `741dfc8946083e45e141ecec89d54e8930d8ee29`, idéntico a HEAD y con árbol inicial limpio. El [primer lote](cotejo-mercado.md) coincide con el inventario en ID, fila, posición, nombre, tipo y cantidad: ocho diseños y doce copias declaradas. El verificador del inventario comprobó las nueve huellas locales y su suite pasó los diez casos. La ficha usa los datos del inventario y requiere el cotejo de caras y copias por el propietario. Godot queda fuera de esta preparación documental.

### Confirmación del primer lote

2026-11-27. El propietario confirmó la lectura de las ocho caras de `mercado.1.png`. Se conserva el [resumen confirmado](cotejo-mercado.md#lectura-confirmada) por posición física e ID del inventario. El propietario recordó que entregó las cantidades al digitalizar la caja. La [auditoría](../../referencias/auditoria-escaneos-2026-11-09.md#fuentes-y-método) conserva dicha declaración. La comparación por fuente, fila y posición dio 65 coincidencias de nombre, grupo y cantidad, con 17 diseños dobles, 82 copias totales y 12 correspondientes a la primera hoja.

Quedan pendientes el contraste de referencias, la lectura de las ocho hojas posteriores y la revisión independiente del registro completo. E3.2 continúa abierta según sus [criterios](tasks.md#e32--cotejo-humano-del-mercado), sin dispensa ni publicación. Siguiente hoja: `mercado.2.png`.

### Confirmación del segundo lote

2026-11-27. El propietario confirmó las ocho interpretaciones de `mercado.2.png`, incluido Encender. La [ficha](cotejo-mercado.md) coincide con el inventario en ocho IDs, títulos y nueve copias de este lote. Dos hojas confirmadas, 16 diseños y 21 copias conforme al recuento previo. E3.2 sigue abierta por las siete hojas restantes, el contraste de referencias y la revisión independiente final. Siguiente hoja: `mercado.3.png`.

### Confirmación del tercer lote

2026-11-27. El propietario confirmó las ocho interpretaciones de `mercado.3.png`. La [ficha](cotejo-mercado.md) coincide con el inventario en ocho IDs, títulos y once copias de este lote. Tres hojas confirmadas, 24 diseños y 32 copias conforme al recuento previo. E3.2 sigue abierta por seis hojas, el contraste de referencias y la revisión independiente final. Siguiente hoja: `mercado.4.png`.

### Confirmación del cuarto lote

2026-11-27. El propietario confirmó las ocho interpretaciones de `mercado.4.png`. La [ficha](cotejo-mercado.md) coincide con el inventario en ocho IDs, títulos y once copias de este lote. El acumulado de las cuatro hojas confirmadas es de 32 diseños y 43 copias conforme al recuento previo. E3.2 sigue abierta por cinco hojas, el contraste de referencias y la revisión independiente final. Siguiente hoja: `mercado.5.png`.

### Confirmación del quinto lote

2026-11-27. El propietario confirmó las ocho interpretaciones de `mercado.5.png` y ratificó expresamente la conversión de puntos sin gastar de Dominar. La [ficha](cotejo-mercado.md) coincide con el inventario en ocho IDs, títulos y nueve copias del lote. El acumulado es de 40 diseños y 52 copias. E3.2 sigue abierta por las cuatro hojas restantes, el contraste de referencias y la revisión independiente final. Siguiente hoja: `mercado.6.png`.

### Confirmación del sexto lote

2026-11-27. El propietario confirmó las ocho interpretaciones de `mercado.6.png`. La [ficha](cotejo-mercado.md) coincide con el inventario en IDs, títulos y diez copias del lote. El acumulado es de 48 diseños y 62 copias. E3.2 sigue abierta por tres hojas, el contraste de referencias y la revisión independiente final. Siguiente hoja: `mercado.7.png`.

### Confirmación del séptimo lote

2026-11-27. El propietario confirmó las ocho interpretaciones de `mercado.7.png`. La [ficha](cotejo-mercado.md) coincide con el inventario en IDs, títulos y ocho copias del lote. El acumulado es de 56 diseños y 70 copias. E3.2 sigue abierta por dos hojas, el contraste de referencias y la revisión independiente final. Siguiente hoja: `mercado8.png`.

### Confirmación del octavo lote

2026-11-27. El propietario confirmó las ocho interpretaciones de `mercado8.png`. La [ficha](cotejo-mercado.md) coincide con el inventario en IDs, títulos y diez copias del lote. El acumulado es de 64 diseños y 80 copias. E3.2 sigue abierta por la última hoja, el contraste de referencias y la revisión independiente final. Siguiente hoja: `mercado9.png`.

### Confirmación del noveno lote

2026-11-27. El propietario confirmó la interpretación de Tirón de hierro en `mercado9.png`. Se comprobó que la [ficha de los nueve lotes](cotejo-mercado.md) coincide con el inventario en los 65 identificadores, títulos y cantidades, con 82 copias. La confirmación del propietario cubre la lectura de las nueve hojas. E3.2 sigue abierta por el contraste de referencias con SRC-001/002 y la revisión independiente. Ninguna dispensa ni publicación.

### Contraste de fuentes y procedencia

2026-11-27. HEAD y referencia recién obtenida de GitHub coincidieron en `741dfc8946083e45e141ecec89d54e8930d8ee29`. Se contrastaron las familias del [registro](cotejo-mercado.md#contraste-de-referencias) con SRC-001 y SRC-002. El especialista de reglas corroboró el contraste y los [cuatro casos inicialmente abiertos](cotejo-mercado.md#casos-sin-respuesta-expresa).

En esta revalidación, el verificador de E3.1 rechazó la carpeta local. El cálculo individual dio huellas distintas de las declaradas para `mercado.1.png` a `mercado.4.png`, `mercado.6.png`, `mercado.7.png` y `mercado9.png`. Coinciden `mercado.5.png` y `mercado8.png`. La causa queda por determinar. Se conservan las huellas del inventario y el alcance de la lectura humana de las hojas presentadas. Para cerrar procedencia, recuperar los archivos correspondientes a las huellas originales o justificar y registrar una nueva fuente identificada con el cotejo que corresponda.

La revisión independiente confirmó la coincidencia de los 65 identificadores, títulos y cantidades (82 copias y 17 diseños dobles), la trazabilidad de los enlaces y los cuatro casos sin resolución oficial expresa. Reprodujo el fallo de huellas y mantiene la procedencia como condición de cierre. La comprobación local de las 65 filas, las referencias REG y el diff pasó. E3.2 permanece abierta, sin dispensa ni publicación.

### Decisión sobre Confrontación

2026-11-27. La respuesta afirmativa del propietario al caso 1 establece [DEC-051](../../decisiones.md#dec-051--confrontación-con-la-pila-de-eliminadas-vacía). Prueba futura de aceptación: con la pila de eliminadas vacía, uno a tres atiums asignados a Confrontación no terminan la partida. Con cuatro, al resolver la secundaria, gana la plaza en competitivo o el equipo en cooperativo/solitario. Tener cuatro atiums disponibles sigue siendo insuficiente. La revisión independiente del cambio documental fue favorable y las comprobaciones de enlaces y diff pasaron. Quedan tres casos abiertos y la procedencia local.

### Decisión sobre Perforar

2026-11-27. El propietario indicó que la secundaria queda sin efecto con una sola Acción elegible. [DEC-052](../../decisiones.md#dec-052--perforar-con-una-sola-acción-elegible). Prueba futura: tras resolver la primaria, llegar a la secundaria con una sola Acción de coste 6 o menos y comprobar que la secundaria no copia ninguna, incluso si el resto del Mercado contiene aliados o Acciones de coste superior. Los efectos de la primaria ya resueltos se conservan. Revisión independiente favorable y comprobaciones de enlaces y diff correctas. Quedan dos casos abiertos y la procedencia local.

### Decisión sobre Defensor

2026-11-27. El propietario confirmó que la restricción de objetivos impresa en Defensor se aplica a Asesinar y Lanzamonedas. [DEC-053](../../decisiones.md#dec-053--defensor-ante-asesinar-y-lanzamonedas). Prueba futura con cada carta: ante un oponente con dos Defensores y otro aliado, ambos Defensores son elegibles y el otro aliado está protegido. El aliado de un oponente distinto sin Defensores sigue siendo elegible. Revisión independiente favorable y comprobaciones de enlaces y diff correctas. Quedan Esconderse y la procedencia local.

### Decisión sobre Esconderse

2026-11-27. El propietario respondió afirmativamente al cuarto caso. [DEC-054](../../decisiones.md#dec-054--esconderse-ante-derrota-directa). Pruebas futuras: impedir una derrota directa por Asesinar y por Lanzamonedas sin alterar la reserva de combate, y salvar a un aliado de Vorágine mientras se resuelven las demás derrotas y el efecto de Mercado. Revisión independiente favorable, enlaces y diff correctos. Con esto quedan decididos los cuatro casos planteados. Se reprodujeron las mismas siete discrepancias de huella, por lo que E3.2 sigue abierta por procedencia.

### Copia identificada para E3.2

2026-11-27. El propietario confirmó que los archivos de este equipo son una copia de los mismos escaneos que trasladó del otro PC. Se identifica la copia local de `cartas_mercado` cotejada en E3.2 y se conservan las huellas históricas en el [inventario E3.1](mercado-inventario.json). Una copia del mismo escaneo puede tener bytes distintos. La declaración acredita su procedencia y la lectura cotejada, sin afirmar igualdad binaria ni atribuir todos los cambios a una causa concreta.

La orientación de varias hojas cambia. El giro de esta tabla es visual y se aplica a la hoja entera para recuperar la cuadrícula del inventario. Se comprobó la correspondencia por títulos. Las posiciones e IDs de E3.1 se conservan. La versión actual de la hoja 1 tiene una huella diferente de la observada en la primera revalidación. Se volvió a leer y conserva las ocho caras confirmadas, en la orientación que recoge la tabla.

| Hoja | SHA-256 de la copia local identificada | Giro para leer por posición del inventario |
| --- | --- | --- |
| `mercado.1.png` | `35c4713909ffc7c1eeae558c04db814bd63f3742237a9cd3a4ecb70d497d10fd` | 90° a la derecha |
| `mercado.2.png` | `6d8ce834869d676512bf0de32e55b86e63327f37969f781e88ab341a08c90187` | Sin giro |
| `mercado.3.png` | `5979a3e95f984a8c9f41480cc7651da83bd548b924c7d99087c935301eafb6a6` | 90° a la izquierda |
| `mercado.4.png` | `53de6a72823ea8d3213df78ef94e5a75d9b7ef10e41367c354ac639215cf44dc` | 90° a la izquierda |
| `mercado.5.png` | `28ff8c3acbda27158525a162067c9384a2d81fd17e114be53e237044e9cb9573` | Sin giro |
| `mercado.6.png` | `fc75c5b3335f988727091c25c0cebb518c9b651591c27dd3f2a6f9fcf81e7854` | 90° a la izquierda |
| `mercado.7.png` | `c97c955f6b0452dfdbdf47f914204a799699ba87780c9148013976597d4e449b` | 90° a la izquierda |
| `mercado8.png` | `a33a249dee3271fbd88c2426e7eea72053990ccf8658c33fa448e84c17b5ee1d` | Sin giro |
| `mercado9.png` | `e49ea83d8e35656d085b8f92901bdd23812c789e2d6abae4f1ef0e87c6015ce5` | Carta única |

La comprobación histórica de E3.1 sigue requiriendo las huellas de ese inventario. E3.2 usa el registro de esta copia para reproducir el cotejo. Los PNG siguen fuera del repositorio y del paquete. El alcance es documental y no acredita ejecución ni distribución.

Revisión independiente final favorable. Verificó las nueve huellas de la copia y los ocho títulos y localizadores de la hoja 1 tras corregir la orientación. Se comprobaron 65 IDs y 82 copias, enlaces y diff. E3.2 queda cerrada en alcance documental, con aceptación, fuentes, comprobaciones y revisión completas. Ninguna dispensa. Publicación documental según DEC-049.

## Verificación de la matriz técnica de efectos

La [matriz propuesta](familias-de-efectos.md) contiene seis familias y un caso positivo y adverso por familia. Se comprobó la correspondencia de las referencias al motor, resolutor y suites existentes, y el alcance de la autoridad por segmento. La finalización desde una secuencia y la persistencia de obligaciones entre turnos o fases requieren contrato propio antes de implementarse. Las pruebas descritas quedan propuestas para futuras entregas. Esta comprobación documental no ejecutó Godot.

Revisión independiente favorable tras delimitar las transiciones que el resolutor actual protege. Se comprobaron los enlaces, las seis filas y el diff. Los tres criterios de la tarea se completaron en alcance documental. Ninguna dispensa. Publicación según DEC-049.

## Intercambio de recursos

2026-11-27. [Operación](../../../scripts/game/turn_resource_exchange.gd) integrada en un programa ficticio de [secuencias](../../../tests/sequence_fixtures.gd). Se verificaron débito y crédito del mismo actor, un único avance de revisión, reenvío con el mismo recibo, saldo insuficiente, desbordamiento, límite entero exacto y entradas inválidas. En los rechazos del motor se comparó el snapshot completo; el éxito mantuvo el RNG y los datos de la otra plaza. El programa solo se registra en pruebas.

Godot 4.7.2: importación correcta, 269 comprobaciones de secuencias, 102 de motor y 2075 de estado, código 0. Revisión independiente favorable y diff y enlaces correctos. Ninguna dispensa. Publicación según DEC-049. Siguiente paso técnico propuesto: concretar el contrato de movimiento entre zonas y reutilizar las operaciones de ciclo existentes donde apliquen.

## Contrato de movimiento entre zonas

2026-11-27. [MOV-01–03](tasks.md#contrato-de-movimiento-entre-zonas) satisfechos en alcance documental. Se comprobó contra el código el orden de `CardCycle.discard`, las invariantes de zonas del validador, la validación de contexto del registro, el rechazo y reenvío del motor y la visibilidad de mano y descarte por plaza. Enlaces locales, anclas y control de espacios correctos.

R2. Una revisión independiente con el perfil `sdd_reviewer` (GPT-6.1 Sol, esfuerzo high) contrastó los criterios con las interfaces. Dictamen favorable. Se incorporó su precisión sobre el tipo `id` en el contexto ficticio para que el caso de instancia ausente alcance la operación. El mismo revisor verificó esa corrección en una segunda pasada acotada. Sin dispensa. Tokens por tarea no disponibles.

La entrega especifica un programa ficticio. Los casos funcionales quedan pendientes de implementación y Godot no se ejecutó para esta revisión documental. Al retomar, implementar el [traslado](movimiento-entre-zonas.md) y ejecutar MOV-03. E3 sigue abierta. Publicación del documento según DEC-049.

## Traslado de mano a descarte

2026-11-27. [MOV-01–03](movimiento-entre-zonas.md) aprobados en alcance de operación interna y [programas ficticios](../../../tests/sequence_fixtures.gd). [CardCycle](../../../scripts/game/card_cycle.gd) comparte validación y traslado con el descarte existente. La nueva entrada exige que toda la selección esté en la mano. Las pruebas comparan el candidato completo para el orden y los rechazos, y verifican recibo y cierre únicos, reversión del saldo y RNG, igualdad de errores públicos y privacidad de las vistas.

Godot 4.7.2. Importación correcta y suites `test-sequence` (294), `test-cycle` (269), `test-engine` (102) y `test-state` (2075), todos con código 0 y sin `SCRIPT ERROR`. El primer ensayo detectó claves `StringName` en el fixture. Se cambiaron por claves `String` y se repitió la ejecución. Registro local final en `%TEMP%/mistborn-mov-impl-recheck.txt`.

R2. Una revisión independiente por `sdd_reviewer` (GPT-6.1 Sol, esfuerzo high) contrastó contrato, código, corrección del fixture y evidencia. Dictamen favorable sin bloqueantes. Ninguna dispensa. Tokens por tarea no disponibles. Controles de espacios y enlaces correctos. Publicación según DEC-049.

El registro del programa pertenece a las pruebas. E3 sigue abierta. El siguiente contrato propuesto combina la selección privada de una instancia con la reanudación del traslado.

## Selección privada y reanudación del traslado

2026-11-27. SEL-01–03 comprobados en alcance documental. Se contrastaron el registro, la proyección, los controles de respuesta, la revalidación de la oferta al cargar y el traslado. El contrato utiliza tokens por posición, una huella privada de la mano y la transacción existente de respuesta. [Contrato](seleccion-privada.md).

Revisión R2 independiente favorable por `sdd_reviewer` (GPT-6.1 Sol, esfuerzo high), sin hallazgos pendientes ni dispensas. La revisión detectó que el ciclo validaba la mano modificada contra la oferta anterior y rechazaba la respuesta. Se corrigió el contrato para ejecutar el ciclo en una copia auxiliar y reintegrar solo las dos listas de cartas. El SHA-256 del contrato revisado es `d02e840f71868d3c57dffc7c00edd3b0feea5b74a2f37eebdb5b6563d35c3d4e`.

Godot 4.7.2 reprodujo el rechazo inicial y confirmó el adaptador mediante dos scripts temporales. Ambos terminaron con código 0. La variante corregida movió la instancia elegida, cerró en revisión 2 y preservó el RNG. La restauración dio el mismo snapshot y recibo. El reenvío devolvió el recibo existente. Scripts y logs locales en `tmp/review-sel-private/`, excluidos de la publicación. Enlaces, anclas y formato del cambio comprobados.

Quedan pendientes el programa versionado, la matriz completa SEL-03 y las regresiones de secuencias, ciclo, motor y estado. E3 sigue abierta. Publicación documental según DEC-049.

## Selección privada verificada en el motor

2026-11-27. SEL-01–03 cumplidos en el [registro ficticio](../../../tests/sequence_fixtures.gd) y las [pruebas de secuencias](../../../tests/sequence_test.gd). Dos copias de una definición se distinguen por posición, la vista ajena conserva solo los datos públicos y el motor reconstituye la oferta al restaurar y responder. Se probaron los límites 0/1/16/17, las respuestas inválidas y tres modificaciones de una pausa. Una respuesta aceptada conserva el recibo al reenviarla y produce el mismo snapshot tras restaurar.

El traslado reutiliza CardCycle en una copia auxiliar. Se comprobó la conservación del historial con zonas renombradas. Un observador en la variante de fallo confirmó que la carta ya estaba en descarte y que el paso posterior consumió RNG y modificó recursos antes de fallar. El motor conservó el snapshot pausado completo, incluidos el saldo y el RNG anteriores al intento y el efecto ya confirmado al abrir la ventana.

Godot 4.7.2. Importación correcta y cuatro suites con código 0. Secuencias 346, ciclo 269, motor 102 y estado 2075 comprobaciones. Logs locales en `tmp/e3-seleccion-privada/`. Revisión independiente favorable por `sdd_reviewer` (GPT-6.1 Sol, esfuerzo high), sin hallazgos ni dispensas. Se verificaron enlaces, formato y alcance de publicación.

El programa se registra en pruebas. E3 queda abierta. El siguiente paso técnico propuesto es definir el contrato de alternativas y efectos encadenados. Publicación de esta entrega según DEC-049.

## Contrato de alternativas y efectos encadenados

2026-11-27. ALT-01–03 comprobados en alcance documental. El [contrato](alternativas-y-encadenamiento.md) usa el ejecutor de una ventana existente para despachar dos alternativas ficticias y encadenar dos intercambios sobre el candidato de P07. El contraste del registro, el resolutor, la respuesta, la proyección y el validador confirma el encaje con una sola ventana y una confirmación por segmento. Se comprobaron los saldos de éxito, el desbordamiento del segundo intercambio y el reintento desde la pausa conservada.

R2. El coordinador redactó el contrato y verificó enlaces, anclas y formato. Un contraste por `sdd_rules` (GPT-6.1 Sol, high) verificó SRC-001 p. 17 y SRC-002, Action cards, y delimitó la elección y el orden a un programa ficticio sin inferir reglas de omisión, umbrales o modos. Una revisión independiente por `sdd_reviewer` (GPT-6.1 Sol, high) comprobó ALT-01–03 y detectó una imprecisión en el código de rechazo de identidades desconocidas. Se corrigió y la revisión final fue favorable, sin hallazgos pendientes. SHA-256 del contrato revisado: `cfa4259ce2070bf6008a3c84ccd28e26292b31dd722885c097804bda4f4e9ddf`. Dos delegaciones, ninguna dispensa. Tiempo y tokens por tarea no disponibles.

El cambio es documental. La matriz ALT-03, la importación y las regresiones de secuencias, motor y estado corresponden a la siguiente implementación ficticia. E3 sigue abierta. Publicación documental según DEC-049.

## Alternativas y efectos encadenados verificados

ALT-01–03 ejecutados desde las entradas de autoridad con un [registro aislado de pruebas](../../../tests/sequence_fixtures.gd) y la [suite de secuencias](../../../tests/sequence_test.gd). El programa `alternatives_v1` usa el catálogo de ensayo `test_alternatives_v1` como segunda frontera de compatibilidad. El motor base y los programas del registro anterior conservan sus versiones.

La plaza activa recibió la oferta ordenada y la otra recibió el bloqueo sin los tokens. La carga rechazó ofertas reordenadas o sustituidas, y ambas ramas produjeron exactamente el mismo snapshot y recibo tras restaurar una pausa válida. Los rechazos preservaron el snapshot completo. El desborde del segundo intercambio mantuvo la unidad confirmada al abrir la ventana y permitió elegir la otra rama. Cada confirmación añadió una revisión, un recibo y un cierre, sin consumir RNG. El reenvío devolvió el recibo previo.

Godot 4.7.2. Importación correcta. Secuencias 390, motor 102 y estado 2075 comprobaciones, con código 0 y sin errores de script en los logs de `tmp/e3-alternativas/`.

Revisión R2 por `sdd_reviewer` (GPT-6.1 Sol, high). El revisor pidió precisar el contrato de compatibilidad. Se fijó la identidad del catálogo en el constructor del ensayo, se aclaró el aislamiento del registro en ALT-02 y se añadió un caso de rechazo por versión del motor. Delta revisado favorablemente, sin hallazgos pendientes ni dispensas. Se reutilizó el contraste de SRC-001/002 del contrato. Comprobados los enlaces y el alcance de publicación.

E3 sigue abierta. El siguiente paso técnico propuesto es especificar el ensayo de efectos diferidos y reacciones. Publicación de esta entrega según DEC-049.

## Contrato de efectos diferidos y reacciones

2026-11-27. DIF-01–03 completados en alcance documental. El [contrato](efectos-diferidos-y-reacciones.md) fija una obligación privada que atraviesa limpieza e inicio, una reacción durante el turno de otra plaza y la liquidación en la misma confirmación que cierra la secuencia. Se contrastaron la forma cerrada del snapshot, el bloqueo por ventana, el vínculo de programa, la lista permitida de proyección y el orden de comprobación de recibos. Se comprobaron los enlaces nuevos, las anclas y el formato.

R2. `sdd_rules` (GPT-6.1 Sol, high) contrastó SRC-001 p. 10, REG-024, la sección «Player abilities & allies» de SRC-002 y DEC-054. La persistencia del ejemplo de la FAQ y el momento de descarte de una reacción real tienen alcance específico. `sdd_reviewer` (GPT-6.1 Sol, high) revisó DIF-01–03. Se añadieron la propagación del perfil a los consumidores del validador y el caso de desbordamiento de la primera operación en ambas ramas. Dictamen final favorable sobre el delta. Dos delegaciones y un seguimiento al mismo revisor, ninguna dispensa. SHA-256 del contrato revisado: `ea369de448f1bcd4cce0a1ab7579cee2a8b0898fabb19c1aa64729a6d486f649`.

La base recuperada fue `main` limpio, alineado con GitHub en `519d8b60df206ed4d6b8feff1f86b0b329eec8ef`. Esta entrega cambia únicamente documentación y se publica conforme a DEC-049. Comprobaciones y referencia remota en `tmp/e3-contrato-diferidos/` (ignorado por Git). La introducción documental conserva referencias históricas al mercado; la situación vigente de su cotejo consta en el estado y evidencia de E3.2.

E3 sigue abierta. Primer paso de implementación: introducir el perfil aislado y la validación de la obligación en la ruta de cambio de turno. Después, registrar la ventana y ejecutar DIF-03 con importación, `test-sequence`, `test-engine`, `test-state`, `test-start` y `test-cleanup`. Godot y los recorridos dinámicos quedan pendientes de esa implementación.

## Ensayo de efectos diferidos y reacciones verificado

2026-11-27. La autoridad del ensayo selecciona el catálogo ficticio y el registro en [el controlador local](../../../tests/deferred_reaction_engine.gd). El esquema 9 y el motor `e3-deferred-fixture-1/godot-4.7.2` se aplican exclusivamente a este perfil. El registro acompaña la validación del estado, la limpieza, el ciclo de cartas y el avance de inicio. El esquema normal sigue en 8. El ensayo queda fuera de las rutas de cartas, interfaz y red del producto.

| Criterio | Resultado observado |
| --- | --- |
| DIF-01 | El turno 1 admite una sola obligación. Se conserva en combate, limpieza, inicio y libre del turno 2. El despacho interno tiene su propia revisión y recibo. Se rechazan cambios de actor, fase, payload y prefijos reservados desde la entrada pública. La acción ordinaria espera al despacho. |
| DIF-02 | A puede activar o pasar y B conserva su turno. Ambas ramas dejan 3 recursos en B y sólo activar eleva la salud de A de 10 a 11. Las vistas muestran el bloqueo y reservan la oferta a A. La respuesta confirma juntos saldos, eliminación de la obligación y de la ventana, recibo y cierre único. El despacho y la respuesta conservan el RNG. |
| DIF-03 | Restauración en seis fronteras con comparación de snapshots completos, recibos y vistas por plaza. Los rechazos conservan el snapshot completo, incluidos los tres casos de desbordamiento. Se recuperan los recibos tras el cierre y se rechazan los reenvíos alterados, las cargas cruzadas y los campos incompatibles. |

Godot 4.7.2 estable. Importación correcta. `test-deferred` 185, `test-sequence` 390, `test-engine` 102, `test-state` 2075, `test-start` 199, `test-training` 295, `test-cycle` 269 y `test-cleanup` 561 comprobaciones, todas con salida 0. Evidencia local en `tmp/e3-diferidos/`, fuera de Git.

También pasaron `test-initial-play` (370), `test-local-competitive` (4078) y `test-integrated-missions` (5932). Las primeras ejecuciones de E1/E2 se detuvieron en la admisión por seis originales que faltaban en la carpeta local. Se localizaron y verificaron por SHA-256 con el preparador existente, se copiaron a la carpeta ignorada y ambas suites completas pasaron al repetirlas. La revisión independiente examinó las pruebas requeridas antes de estas ejecuciones adicionales.

R2 por esquema, autoridad y privacidad. El coordinador implementó, integró y ejecutó las pruebas. El perfil `sdd_reviewer` (GPT-6.1 Sol, high) revisó el cambio y la evidencia de las pruebas requeridas con dictamen favorable y sin hallazgos bloqueantes. Una delegación, ninguna dispensa. Se reutilizó el contraste de fuentes del contrato documental. Las puertas de reglas nuevas, interfaz, red y distribución de contenido quedan fuera del ensayo.

La base recuperada fue `main` limpio y alineado con GitHub en `5d53290e5f6a8f60d259617bbec5cd963f34dfa4`. Publicación conforme a DEC-049. E3 sigue abierta. El siguiente paso técnico propuesto es especificar la operación terminal ficticia y su ruta de autoridad conforme a la [matriz de efectos](familias-de-efectos.md).

## Contrato del ensayo de finalización

2026-11-27. FIN-01–03 completados en alcance documental. El [contrato](finalizacion.md) fija una ventana ficticia y la confirmación conjunta de avance, resultado terminal, cierre y recibo. Especifica los casos de restauración, reenvío, rechazo, reversión y carga cruzada. Se comprobó la coherencia con el motor, el validador, la proyección y la primitiva de llegada, además de rutas, anclas y formato del cambio.

R2. `sdd_rules` (GPT-6.1 Sol, high) contrastó SRC-001 pp. 17 y 19–20, REG-044/064, DEC-034 y la FAQ oficial, incluidos «Missions», «Action cards» y «Solo & Co-op mode». Confirmó el alcance del resultado `tres_misiones` y mantuvo pendientes las prioridades de las interacciones reales. `sdd_reviewer` (GPT-6.1 Sol, high) emitió dictamen favorable sobre FIN-01–03. Dos delegaciones y ninguna dispensa. SHA-256 del contrato revisado: `4dd7111fd305a0b02fffa497a20717e84e9303bb376f53b56fdb34862029ee2a`.

La base recuperada fue `main` limpio y alineado con GitHub en `d0a09b8ac9731bbd844f00c7f7344cab887af781`. Publicación documental conforme a DEC-049. Comprobaciones y referencia remota en `tmp/e3-contrato-finalizacion/`, fuera de Git. E3 sigue abierta. El primer paso de implementación es conectar el perfil aislado a la ruta de cierre de autoridad y después ejecutar FIN-03 en Godot.

## Ensayo de finalización

2026-11-27. Base recuperada en `main` limpio, alineado tras consultar GitHub en `0cce4a18b9380158917fd1c58839b2d4d35cc773`. Se conservó el esquema de estado y se usaron un catálogo y una versión de motor propios del ensayo. El perfil vive en `tests/`.

- FIN-01. La autoridad abre la elección privada sobre las posiciones 12/12/11. El paso confirma el token y el cierre reutiliza la primitiva de llegada. La tercera cima consume un punto, conserva premios previos y registra `tres_misiones`.
- FIN-02. La transacción confirma resultado, turno terminal, revisión, cierre y recibo. El cierre puede devolver un fallo antes de publicar la copia. El perfil valida el historial canónico de recibos junto a la ventana o el resultado, y rechaza la carga incoherente sin sustituir el estado previo.
- FIN-03. `test-finalization`, 159 comprobaciones en Godot 4.7.2, código 0. Incluye vistas por plaza, restauración inicial, en pausa y terminal, reenvíos, acciones posteriores, fallo inyectado tras el avance, mutaciones directas de resultado/fase/ciclo de vida y carga incompatible. Evidencia de ejecución en `tmp/e3-finalizacion/`, fuera de Git.

Pasaron la importación y las seis regresiones exigidas. Secuencias 390, diferidos 185, motor 102, estado 2075, avance de misiones 878 y misiones integradas 5932. La regresión adicional de partida competitiva local pasó 4078 comprobaciones.

El coordinador implementó y verificó. Una delegación a `sdd_reviewer` (GPT-6.1 Sol, high) detectó que borrar la ventana de una pausa dejaba un recibo de inicio restaurable. Se corrigió al exigir un recibo canónico por revisión, con el inicio y la respuesta ligados a las fronteras que confirman. El revisor comprobó el delta y emitió dictamen favorable sobre el código y FIN-03. El coordinador confirmó después el resultado satisfactorio de la regresión integrada que quedaba en ejecución. Contraste SRC-001/002 reutilizado del contrato. Ninguna dispensa. Tokens por tarea no disponibles.

La regresión adicional `test-perseguir-play` falla al admitir la fuente de ese perfil tanto en este árbol como en una copia limpia de la base. Falta el original local con la huella exigida. Las dos ejecuciones quedan en la carpeta de evidencia local.

Publicación conforme a DEC-049. Se comprobaron 569 enlaces locales de 10 documentos, las anclas nuevas, el alcance preparado y el formato del diff.

E3 sigue abierta. El siguiente paso propuesto es delimitar un primer lote de integración, trazar cada ruta a una operación verificada o a una excepción pendiente y definir las pruebas del lote. Siguen pendientes la ejecución del catálogo final y su admisión.

## Contrato del primer ensayo integrado

2026-11-28. Base publicada y local: `6b48927cf4ecea1896ac832603840df11e5017ab`, rama `main` con árbol limpio tras la recuperación. [Contrato](primer-ensayo-integrado.md) · [Tarea](tasks.md#contrato-del-primer-ensayo-integrado).

| Criterio | Evidencia documental |
| --- | --- |
| INT-E3-01 | Recorrido de dos plazas con valores iniciales, ramas conservar y donar, cambio de turno, reacción y cierre. Cada tramo enlaza su evidencia aislada. Las operaciones nuevas y sus puntos de composición quedan identificados. |
| INT-E3-02 | Matriz de opciones inválidas, plaza incorrecta, evento fuera de orden, desbordamiento, fallo terminal, restauración, instantáneas adulteradas, reenvío y vistas por plaza. Distingue la reversión de un segmento de las fronteras ya confirmadas. |
| INT-E3-03 | Plan de prueba dirigida, importación y cinco regresiones existentes. Se contrastó con las interfaces de estado, secuencia, intercambio, limpieza y cierre. Se comprobaron enlaces, anclas y formato. |

Revisión independiente favorable de `sdd_reviewer` (GPT-6.1 Sol, high) tras precisar los campos de saldo, el punto que consume la llegada y el formato terminal exigido por el validador. El revisor comprobó 15 enlaces del contrato. Ninguna dispensa. Los controles y la referencia de publicación se conservan en `tmp/e3-primer-ensayo-integrado/`, fuera de Git. Godot y el recorrido integrado quedan pendientes de la implementación.

Traspaso: contrato documental cerrado. E3 sigue abierta. Siguiente paso técnico: preparar el perfil ficticio versionado y el estado inicial del ensayo, y conectar la primera secuencia hasta la alternativa. La integración del catálogo necesita su propia entrega.

## Primer ensayo integrado verificado

2026-11-28. Base publicada y local b3fd5c03ed60249e2f6cf25c776365970b1e9bb9 en main, árbol limpio al recuperar. Riesgo R2 por composición de ventanas, persistencia y cierre atómico. [Contrato](primer-ensayo-integrado.md) · [Tarea](tasks.md#implementación-del-primer-ensayo-integrado).

| Criterio | Evidencia |
| --- | --- |
| INT-E3-01 | Dos plazas, tres fichas, dos ventanas de A y dos ramas. Donar registra la obligación, la limpieza la conserva y B canjea en su reacción. El cierre de autoridad liquida la obligación, consume el punto de llegada y confirma resultado y recibo en una revisión. |
| INT-E3-02 | Comparación del estado completo tras rechazos, desbordamiento y fallo terminal inyectado. Restauración de siete fronteras, replay de recibos y comparación de ambas vistas. Se rechazan cargas sin ventana u obligación, recibos terminales alterados y versiones ajenas. |
| INT-E3-03 | Perfil versionado, registro cerrado y lanzador local test-integrated-trial. El perfil valida las instantáneas reconstruyendo el recorrido determinista desde sus recibos y comparando el estado completo. El descarte, el intercambio, el canje y la limpieza reutilizan operaciones del motor. La transferencia entre plazas es propia del ensayo. |

Godot 4.7.2, importación y prueba dirigida correctas, con 230 comprobaciones. Se repitió la prueba dirigida al reutilizar las primitivas de descarte e intercambio sin cambios compartidos. Regresiones del contrato: secuencias 390, motor 102, estado 2075, diferidos 185 y finalización 159 comprobaciones. Logs locales en `tmp/godot/`. La primera ejecución dirigida detectó una colisión de nombre con la clase nativa Engine; se corrigió el alias en el script de prueba.

Coordinador para el recorrido, lanzador y verificación. Se delegaron los dos archivos de perfil y autoridad a `sdd_developer` (GPT-6.1 Sol, medium) por propiedad separable, y la revisión a `sdd_reviewer` (GPT-6.1 Sol, high). Godot se ejecutó desde un único responsable y las suites existentes se reutilizaron como evidencia. Implementación aislada en tests y su lanzador. Ninguna dispensa. Tiempo por tarea y consumo de tokens no disponibles.

Revisión independiente favorable para INT-E3-01–03, incluido el ajuste de reutilización de primitivas. Se contrastaron la carga, los recibos, la privacidad, la reversión, los logs y la sintaxis del lanzador. Once enlaces y anclas modificados comprobados sin errores. Publicación conforme a DEC-049.

Traspaso: perfil limitado al recorrido ficticio de dos plazas. E3 sigue abierta. El siguiente paso del plan es delimitar el lote de integración y sus pruebas de admisión. Quedan pendientes la admisión del mercado, las rutas de tres y cuatro plazas, la interfaz y la red.

## Delimitación del lote verificada

2026-11-28. [Tarea](tasks.md#delimitación-del-lote-de-integración-y-admisión) y [contrato](lote-integracion.md) contrastados con el estado publicado en `f7011a861ac6d45762c61f1058a1ae0a49970f72`. Rama `main` y árbol inicial limpio.

| Criterio | Evidencia documental |
| --- | --- |
| ADM-E3-01 | Perímetro vinculado a T08.1b31, revisión de las dependencias por componente y comprobación de 65 IDs únicos, 82 copias y 17 duplicados en el registro del mercado. |
| ADM-E3-02 | Seis pruebas propuestas que cubren inventario, procedencia, resolutores, identidad, restauración y paquete. Contraste con T08.1b30 y el manifiesto fijo del ensayo b29. |
| ADM-E3-03 | Recorridos de 2, 3 y 4 plazas con una identidad común, tres vías de cierre, restauración y vistas por plaza. Contraste con los límites de E2 y del primer ensayo integrado. |

R2 documental. El coordinador redactó el contrato, verificó inventario, enlaces y diff e integró el dictamen favorable de `sdd_reviewer` (GPT-6.1 Sol, high). El revisor sugirió precisar la vía de cierre de cuatro plazas y se asignó Confrontación. Ninguna dispensa. Tiempo y tokens por tarea no disponibles. Se reutilizó la evidencia de ensayos publicados. Esta entrega documental no construye el candidato ni ejecuta Godot, pruebas de admisión o revisión visual.

Traspaso: completar el registro de admisión por componente y contrastar las rutas alcanzables con sus resolutores y pruebas. Resolver las carencias antes de construir el candidato. E3 sigue abierta, con interfaz, ejecución del candidato y admisión pendientes.

## Registro de admisión verificado

2026-11-28. Rama principal limpia al recuperar `114ff0514eedb92b861eda86486154043ab63abf` de GitHub. [Tarea](tasks.md#registro-de-componentes-y-cobertura-de-e3) · [Registro](registro-admision.md).

| Criterio | Evidencia documental |
| --- | --- |
| REG-E3-01 | Ocho grupos del inventario cerrado. Cruce de 22 IDs de E1 y 8 de misiones con sus fuentes, huellas registradas, localizadores y estados. Los 65 IDs de mercado coinciden por cantidad con el cotejo y suman 82 copias; se comprobó el vínculo del borrador aislado. |
| REG-E3-02 | Ocho rutas cruzadas con código y evidencia de ensayo. Se comprobó la correspondencia de 11 acciones del lanzador con sus scripts. Se conserva el bloqueo de la última ejecución documentada del perfil aislado de mercado. |
| REG-E3-03 | Comprobados enlaces, anclas y diff. Los bloqueos de definición, pruebas y distribución se conservan explícitos. |

R2 documental. El coordinador preparó y comprobó el registro. `sdd_reviewer` (GPT-6.1 Sol, high) contrastó de forma independiente el inventario, el código, las pruebas referenciadas y el ajuste final. Dictamen favorable, ninguna dispensa. Tiempo y tokens por tarea no disponibles. Se reutilizaron resultados publicados; Godot y A1–A6 quedan sin ejecutar en esta entrega documental.

Traspaso: contrastar los cuatro registros de personaje E1 por ID y localizar sus carencias de admisión. El registro de E3 permite identificar dependencias, con candidato, interfaz y recorridos aún pendientes.

## Personajes E1 contrastados

2026-11-28. Base local y publicada `85a8b678f374a9ef489abf9c74a77beb004a05a4`, árbol inicial limpio. [Tarea](tasks.md#contraste-individual-de-personajes-e1) · [Registro](registro-admision.md#contraste-individual-de-personajes-e1).

| Criterio | Comprobación |
| --- | --- |
| PER-E3-01 | Cuatro IDs y cuatro localizadores exactos, una copia por ficha y 16 vínculos recíprocos únicos. SHA-256 de la hoja local coincidente con el catálogo de autoría y SRC-005. |
| PER-E3-02 | Tres descriptores por ficha. I y III tienen pruebas por ID en E1. II sigue pendiente en los cuatro borradores. E2 prueba cuatro firmas I y exige uso de II y III mediante aserciones globales. |
| PER-E3-03 | Pendientes por ID registrados para definición, ejecución y distribución. Datos de autoría intactos. Enlaces, anclas y diff comprobados. |

R2 documental. El coordinador comprobó datos, huella y código de pruebas. `sdd_reviewer` (GPT-6.1 Sol, high) contrastó el resultado y el ajuste de redacción de forma independiente. Dictamen favorable. Sin dispensa. No se repitió Godot: se reutilizó la evidencia publicada de E1 y E2. Tiempo y tokens por tarea no disponibles.

Traspaso: reunir el contraste de los 16 entrenamientos, Financiación y pista en una sola tarea documental de E1. La admisión del candidato E3 continúa pendiente.

## Entrenamientos, Financiación y pista E1 contrastados

2026-11-28. Base local y publicada `c9cfcc0c40cc7cf55a7db553a020c6e78988dfe3`, árbol inicial limpio. [Tarea](tasks.md#contraste-de-entrenamientos-financiación-y-pista-e1) · [Registro](registro-admision.md#contraste-de-entrenamientos-financiación-y-pista-e1).

| Criterio | Comprobación |
| --- | --- |
| INI-E3-01 | 16 IDs y localizadores de entrenamiento, con una copia y vínculo recíproco por ID. Financiación con 24 copias y pista con cuatro copias y 21 casillas. Cinco archivos locales con SHA-256 coincidente con autoría y SRC-004. |
| INI-E3-02 | Cruce con suites publicadas de catálogo, primarias, ciclo y avance. Se documentó el alcance del perfil fijo para la pista y las carencias de definición, ejecución y distribución. Los 18 IDs siguen en borrador. |
| INI-E3-03 | Revisión independiente favorable y comprobación de enlaces, anclas, alcance del diff y publicación conforme a DEC-049. |

R2 documental. El coordinador comprobó datos, fuentes y alcance de las suites. `sdd_reviewer` (GPT-6.1 Sol, high) reprodujo las comprobaciones de huellas y revisó los tres criterios sin hallazgos pendientes. Sin dispensa. Se reutilizó la evidencia publicada de Godot, sin nuevas ejecuciones ni pruebas del candidato. Tiempo y tokens por tarea no disponibles.

Traspaso: con los personajes, quedan contrastados los 22 IDs de E1. El siguiente paso propuesto agrupa los ocho registros de misión, sus referencias de autoría y la cobertura del perfil aislado. Sigue pendiente la admisión de E3.

## Ocho misiones contrastadas

2026-11-28. [Tarea](tasks.md#contraste-de-las-ocho-misiones) · [Registro por ID](registro-admision.md#contraste-de-las-ocho-misiones).

- MIS-E3-01. Ocho IDs únicos, una copia por ID y ocho localizadores contrastados. Se comprobaron las dos huellas de SRC-005 contra los archivos locales, las declaraciones de autoría y el registro de fuentes. El cotejo humano previo cubre las ocho lecturas por título.
- MIS-E3-02. El PDF local de SRC-001 coincide con su SHA-256 registrado. Se consultaron sus pp. 5, 14 y 17 y SRC-002, secciones «Missions», «Miscellaneous», «Action cards» y errata 2. Se cruzaron premios y dependencias con la suite aislada. Se reutilizó la evidencia publicada de `test-integrated-missions` de [T08.1b22](../008-preparacion-y-turnos/verification.md#t081b22--integración-de-misiones-m1m8), con 5932 comprobaciones. Se verificó en el código que esa suite usa las definiciones de misiones de autoría y componentes auxiliares ficticios. La suite integrada no se volvió a ejecutar para esta entrega documental.
- MIS-E3-03. `test-missions`, Godot 4.7.2, código 0 y 138 comprobaciones. La integración y la distribución del candidato siguen pendientes.

Revisión independiente `sdd_reviewer` (GPT-6.1 Sol, high) favorable. Contrastó cantidades, localizadores, huellas, cobertura, fronteras y enlaces. El mensaje de catálogo inválido en el registro de Godot corresponde al caso adverso previsto. Comprobación final de 568 enlaces locales en siete Markdown y del diff preparado, correcta. Sin dispensa. El contraste mantiene vigentes las decisiones registradas y la próxima propuesta es documentar recursos, pistas y marcadores restantes.

## Recursos y marcadores contrastados

2026-11-28. Base publicada y local `d285208b58f5ace6a2918fea82ab96b751e27a54`, con árbol inicialmente limpio. [Tarea](tasks.md#contraste-de-recursos-y-marcadores) · [Registro](registro-admision.md#contraste-de-recursos-y-marcadores).

- REC-E3-01. Se contrastaron las siete filas con SRC-001 pp. 3, 5, 7–8 y 12–17, SRC-004 para el panel, y SRC-002, errata 2 y secciones «Metal tokens & atium», «Combat» y «Miscellaneous». La huella SHA-256 de SRC-001 coincide con la registrada. Se distinguieron los recuentos físicos de los estados y suministros de partida.
- REC-E3-02. Se cruzó la representación de cada fila con preparación, validación, perfiles aislados, limpieza y E2. El registro identifica las dependencias del candidato y remite a A1–A3 y A6 para representación, ejecución y materiales.
- REC-E3-03. Godot 4.7.2, código 0 en las tres suites. `test-setup` 175 comprobaciones, `test-cleanup` 561 y `test-local-competitive` 4078. Los registros locales están en `tmp/e3-recursos/` y `tmp/godot/`. A1–A6 siguen pendientes para el candidato.

R2 documental. El coordinador cotejó fuentes, representaciones y pruebas y ejecutó las regresiones. Un `sdd_reviewer` (GPT-6.1 Sol, high) verificó de forma independiente REC-E3-01–03 y emitió dictamen favorable tras corregir una línea vacía al final de la tarea. Sin dispensa ni nuevas decisiones de reglas. Comprobación de enlaces locales y diff satisfactoria. Tiempo y tokens por tarea no disponibles.

Traspaso. Cruzar por ID el inventario de mercado con los resolutores y las pruebas existentes. E3 sigue abierta hasta verificar las rutas del mismo candidato en partidas de 2, 3 y 4 plazas y completar la evidencia de admisión.
