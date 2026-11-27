# Selección privada de una carta de la mano

Contrato para un programa ficticio de E3. La ventana prueba la elección obligatoria de una instancia propia y su traslado a descarte mediante la operación ya verificada. La cardinalidad y los casos límite corresponden a este programa de prueba.

## SEL-01 · Oferta y vista del destinatario

La autoridad fija al jugador activo como dueño y único destinatario. Al preparar la solicitud, lee por `holder_id` y `kind=mano` la lista ordenada de instancias de su mano. Los candidatos son todas las instancias de esa mano y deben pertenecerle. Dos copias de una misma definición generan dos opciones distintas. Con una sola instancia se abre la ventana y se exige confirmación. Con cero instancias o más de 16, el límite por defecto del registro, el inicio se rechaza con `accion_ilegal`, sin ventana ni cambios confirmados. El programa de prueba conserva la mano intacta hasta la respuesta.

La solicitud interna guarda en el contexto escalar `hand_binding` con tipo `id`. Su valor es el prefijo `hand_` seguido del SHA-256 hexadecimal en minúsculas de la serialización JSON compacta del array ordenado de `instance_id`, mediante `JSON.stringify` en Godot. El constructor de la oferta comprueba esa huella, la propiedad y el tamaño de la lista. Si una comprobación falla, devuelve `null`. En caso válido devuelve `kind=eleccion`, el destinatario único, `min=max=1` y un token por posición de la mano en el formato `o00001`, `o00002`, etc. El formato solo expresa el ordinal. La huella permite detectar una mano alterada con el mismo número de cartas en un snapshot con el contexto original.

La [proyección existente](../../../scripts/game/game_projection.gd) entrega al destinatario la lista de cartas de su mano en ese mismo orden y la lista de tokens de la ventana. En el cliente de prueba se emparejan por posición para identificar qué carta representa cada opción. El destinatario responde con un token usando `resolution_id`, `step_id` y la revisión de su vista. Las demás plazas reciben el estado de bloqueo de la ventana y los recuentos habituales de las zonas. La proyección conserva su lista permitida y el contexto queda en la autoridad.

## SEL-02 · Restauración, respuesta y traslado

El [validador de snapshots](../../../scripts/game/state_validator.gd) reconstruye la oferta del paso mediante el mismo registro y exige que coincida con `pending`. El [resolutor](../../../scripts/game/sequence_resolver.gd) vuelve a aplicar esta comprobación antes de ejecutar la respuesta. Una mano alterada respecto a la huella o una oferta persistida alterada invalidan la restauración. El snapshot de autoridad es la fuente de restauración. La huella comprueba la correspondencia entre la mano y el contexto persistido.

El motor valida actor, revisión, resolución, paso y opción según el contrato vigente. Con la opción válida, la autoridad consulta la posición en la oferta reconstruida y toma la instancia correspondiente de la mano. [Contrato de secuencias](../008-preparacion-y-turnos/secuencia-reanudable.md#ejecución-pausas-y-cierre).

El ciclo valida el estado antes y después del traslado. La resolución pendiente persistida describe la mano de antes de elegir. Para que esa oferta previa no invalide la validación posterior del ciclo, el paso crea una copia profunda del candidato, pone `resolution=null` solo en esa copia y llama a `CardCycle.discard_from_hand` con la plaza y el único ID elegido. Tras un resultado válido, copia al candidato del motor solo las listas de cartas de mano y descarte de esa plaza. Ante un fallo devuelve error sin copiar nada. El motor conserva el control de la resolución en el candidato y publica la nueva frontera con su validación habitual. [CardCycle](../../../scripts/game/card_cycle.gd) y [contrato de traslado](movimiento-entre-zonas.md).

La elección y el traslado consumen cero RNG. El motor confirma la reanudación con una sola revisión, un recibo y un cierre. El mismo envío recupera su recibo. Una nueva intención para una ventana consumida se rechaza.

Si falla el traslado o un paso posterior en el mismo segmento, el rechazo conserva el snapshot pausado completo, incluidas las revisiones y efectos ya confirmados al abrir la ventana. El traslado fallido se traduce en `accion_ilegal`. Los rechazos usan los códigos existentes, sin detallar las cartas implicadas.

## SEL-03 · Casos de verificación

| Escenario | Resultado esperado |
| --- | --- |
| Mano de dos copias de la misma definición y descarte previo. Elegir la segunda copia con la vista del destinatario y repetir la prueba tras restaurar la pausa en un motor nuevo con el mismo registro. | Se mueve solo la segunda instancia al final del descarte. La primera mantiene su posición y ambas conservan identidad, dueño y estado individual. El programa usa el ciclo real y conserva el resto de las zonas. Snapshot completo, RNG, revisión y recibo iguales entre ambas ejecuciones. |
| Una carta, 16 cartas, mano vacía y 17 cartas. | Se ofrece una opción en el primer caso y 16 en el segundo. Los dos últimos rechazan el inicio de forma atómica. |
| Respuesta de otra plaza, resolución o paso ajeno, token no ofertado, ID de instancia como opción en un fixture que usa IDs distintos de los tokens, respuesta vacía, dos tokens iguales o dos tokens distintos. | Rechazo y snapshot pausado intacto. |
| Restaurar una pausa con la mano reordenada, con una instancia sustituida por otra válida de la misma plaza y recuento, o con opciones persistidas permutadas. | Restauración rechazada en los tres casos. |
| Fallo tras el traslado, provocado por un paso ficticio posterior que consume RNG. | Se conserva el snapshot pausado completo. Si el inicio confirmó un efecto previo, este se conserva. |
| Reenviar la respuesta aceptada y enviar otra intención para la ventana consumida. | El reenvío idéntico devuelve el recibo existente. El nuevo intento se rechaza. Ambos conservan el estado final. |
| Dos partidas con la misma información pública y cartas privadas distintas, antes y después de responder. | Igualdad de las vistas de la otra plaza en cada frontera. Solo el destinatario puede asociar tokens con sus cartas. |

La implementación deberá ejecutar los casos dirigidos en el registro de pruebas y las regresiones de secuencias, ciclo, motor y estado.
