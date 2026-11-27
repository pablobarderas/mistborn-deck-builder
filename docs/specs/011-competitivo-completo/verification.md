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
