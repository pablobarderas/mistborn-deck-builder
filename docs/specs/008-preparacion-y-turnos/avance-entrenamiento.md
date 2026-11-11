# T08.1b1 — Contrato del avance de entrenamiento competitivo

Especificación documental para competitivo de 2 a 4 plazas. Fuentes: [SRC-001](../../referencias/README.md#src-001--reglamento-aportado-por-el-usuario), pp. 5, 7, 12–13 y 17; [SRC-002](https://www.brotherwisegames.com/mistborn-deckbuilding-game-faq), errata 2, «Player abilities & allies» y «Miscellaneous»; [SRC-004](../../referencias/entrenamiento-competitivo.md), panel físico y sus índices. REG-001/012/019/028–031, DEC-024 y DUD-004.

## Comportamiento

La preparación deja el marcador en `training=0` y la capacidad de quema de fichas en `burn_limit=1`. La marca `+1` de la primera casilla representa esa capacidad inicial. Antes de las acciones libres, el jugador activo avanza un paso incluso en su primer turno. Preparar la partida o entregar el turno en `inicio` deja ese avance pendiente.

| Casilla alcanzada (índice desde 0) | Resultado de un paso |
| --- | --- |
| 3, 9, 15 | Aumenta en uno el límite de fichas. El incremento se suma al valor que ya tiene el jugador. |
| 5, 8, 13 | Queda disponible el nivel I, II o III, respectivamente, según la posición alcanzada. |
| 11, 16 | Otorga inmediatamente una ficha de Atium. |
| 20 | Activa la recompensa continua. Llegar desde 19 deja el marcador en 20. |
| Las demás casillas alcanzables | Sólo avanza el marcador. |
| Un paso solicitado estando ya en 20 | El marcador permanece en 20 y se obtiene una ficha de Atium. |

Los niveles alcanzados se consultan por umbral en la posición del marcador. Evitar una segunda copia persistente de los desbloqueos. La operación de avance no ejecuta las habilidades, no consume sus usos ni decide si un metal quemado antes del desbloqueo permite activarlas (DUD-004). La capacidad base alcanza 4 sólo por la pista; no tratar 4 como tope general para efectos futuros. Un avance normal de misión no se convierte en Atium. Si una recompensa de misión indica TRAIN, su futuro resolutor solicitará el avance de entrenamiento correspondiente.

## Contrato técnico para T08.1b2

Implementar una operación interna para **un solo paso** de la plaza activa. Recibe un snapshot de autoridad y las definiciones/pista ya seleccionadas por esa autoridad. Valida snapshot, modo, partida en curso, actor activo con `eliminated == false` y `health > 0`, turno positivo, pista compatible y posición entre 0 y 20. En T08.1b2 sólo admite `turn.phase == inicio` y `resolution == null`. El cliente no elige pista, índice, recompensa, cantidad ni momento. No se registra una acción pública de avance.

Usar un perfil cerrado del panel SRC-004 con las 21 posiciones, asociado explícitamente por autoridad a `training_track_id` y a un catálogo compatible. El tipo `pista_entrenamiento` o un nombre parecido no bastan para seleccionar el perfil. Verificar la definición ligada, su identidad y la secuencia ordenada de las 21 posiciones con sus marcas antes de mutar. P06 no modela hoy el incremento de capacidad, los umbrales de nivel ni la conversión terminal como efectos genéricos. La implementación aislada puede enlazar un fixture a un descriptor técnico explícito de este panel. Cualquier incorporación de una pista ejecutable al catálogo requerirá su propio contrato y revisión de contenido. No interpretar texto ni reutilizar marcas genéricas para simular recompensas.

Calcular sobre una copia profunda candidata, con guardias de tipo, límites y posibilidad de escritura. Al conceder Atium, materializar una ficha `{token_id, metal: "atium", exhausted: false, used_this_turn: false}` y sumar uno a `persistent.atium` en el mismo commit. Reservar `token_atium_<next_id>` en el contador de autoridad, comprobando unicidad entre las fichas de la plaza y que el contador pueda incrementarse. Rechazar desbordamiento, colisión o candidato inválido sin tocar el original, incluido saldo, fichas, posición, capacidad y contador. Conservar los campos ajenos, el RNG y las fichas previas. Usar el mismo registro de secuencias del motor al validar, para no rechazar ni borrar cierres válidos anteriores. El candidato conserva la fase y no escribe revisión, recibos, resolución ni ledger.

La operación aislada devuelve éxito con candidato validado o rechazo sin candidato. La posición por sí sola no distingue dos solicitudes del mismo avance de inicio. Antes de conectarla al producto, el futuro orquestador deberá consumir una única ocurrencia de inicio por partida, número de turno y plaza activa. Debe comprometer avance, recompensas y salida de `inicio` en una única transacción de autoridad, con reenvíos gestionados por P07 y rechazo de nuevas intenciones que pretendan repetir el inicio ya consumido. Si existen obligaciones que deban resolverse antes de abrir `libre`, mantener la puerta cerrada hasta disponer de su resolutor. El camino de secuencia existente protege `turn` y `lifecycle`, por lo que no se puede hacer la transición desde su callback. La integración exige su propio diseño y pruebas; la operación aislada no acredita que el turno esté abierto.

Un ejemplo de obligación de inicio es robar la carta apartada por Keeper, incluso si el aliado fue derrotado entre turnos. La FAQ no fija su orden relativo con el avance de entrenamiento. El orquestador debe comprobar las condiciones de final aplicables antes de abrir `libre`; un snapshot estructuralmente válido en curso no acredita esa comprobación. Llegar a 20 u obtener una cuarta ficha de Atium no activa por sí solo la victoria por Confrontation (REG-044).

Avances de más de un paso, activación de habilidades y soporte de otros modos quedan para entregas propias. SRC-001/002 permiten aplicar efectos unitarios sucesivos en orden. Por ejemplo, dos avances unitarios desde 19 llegan primero a 20 y luego conceden una ficha. La especificación no interpreta un efecto agregado de una carta todavía sin contrastar. En solo y cooperativo la regla base comparte pista, pero existen excepciones por efectos del rival que pueden impedir avanzar. No extrapolar la guarda competitiva ni conceder recompensa por un avance impedido.

## Aceptación y pruebas previstas

| Criterio | Casos exigidos para la implementación aislada o la integración indicada |
| --- | --- |
| ENT-AC-01 — Perfil y avance | Fixture en la primera casilla con límite 1. Primer avance 0→1 sin otro aumento. Recorrer las 21 posiciones y comprobar casillas vacías, tres incrementos y tres desbloqueos, respetando la capacidad previa. Rechazar pista o catálogo incompatibles, incluso una pista con el mismo ID, tipo y número de casillas pero con las recompensas reordenadas. |
| ENT-AC-02 — Atium | 10→11 y 15→16 otorgan exactamente una ficha cada vez; 19→20 habilita la conversión sin ficha inmediata; cada paso posterior concede una ficha y conserva índice 20. Saldo y fichas coinciden incluso con Atium previo usado. |
| ENT-AC-03 — Atomicidad | Cubrir competitivo 2/3/4, rechazo de actor ajeno/eliminado, fase, modo, resolución o índice inválidos; overflow, colisión, contenedores incompatibles y fallo de validación final. El rechazo conserva todo el snapshot. En éxito sólo cambian los campos descritos, sin RNG, activaciones ni transición. Mantener cierres Funding anteriores. |
| ENT-AC-04 — Inicio único (integración futura) | En el primer turno de cada plaza hay un avance. Reenvío devuelve recibo previo. Solicitud nueva tras consumirse el inicio no vuelve a premiar. Cubrir Keeper derrotado con robo pendiente, una obligación no soportada y un final aplicable como único superviviente. No abrir `libre` con obligaciones pendientes ni tras un final. Un fallo de transacción conserva fase, avance y recompensa previos. Conservar los escenarios separados de solo/cooperativo para su futura integración. |

T08.1b1 se cierra al revisar estas condiciones contra fuentes y APIs vigentes. ENT-AC-01 a 03 orientan T08.1b2, implementación y pruebas de la operación interna. ENT-AC-04 queda como condición del futuro orquestador. Aquí no se ejecutan estos escenarios ni se cambia el motor.
