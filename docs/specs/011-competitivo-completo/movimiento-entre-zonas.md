# Contrato de movimiento entre zonas

El primer traslado de prueba lleva instancias de la mano al descarte de una misma plaza. Su propósito es comprobar la operación y su integración en una secuencia automática ficticia. Las rutas que cambian la propiedad, manipulan zonas compartidas o del rival, o dependen de una elección quedan para contratos posteriores.

## MOV-01 · Entrada y resultado

La operación interna recibe el candidato de autoridad, el ID de la plaza y una lista ordenada de uno o más `instance_id`. En la secuencia de prueba, la plaza se obtiene de `context.owner_id` y el registro de pruebas construye la lista a partir de campos escalares internos de tipo `id`. Así, un ID bien formado pero ausente llega a la operación para que esta lo rechace. La intención del cliente usa el sobre existente. El cliente carece de parámetros para fijar plaza, origen, destino, orden o IDs del traslado.

La autoridad resuelve las zonas por `holder_id` y `kind`. El origen es `mano` y el destino `descarte`. Cada ID debe ser válido, único en la lista y estar en la mano de la plaza indicada, con `owner_id` de esa plaza. Se exige la selección completa antes de modificar el candidato. Dos copias de una definición pueden moverse juntas si sus IDs son distintos.

Al aceptar, se retiran las instancias de la mano conservando el orden relativo de las restantes. Se añaden al final del descarte en el orden recibido, después de todas las instancias que ya estaban allí. El traslado conserva el conjunto de instancias, sus definiciones, propietario y estado individual. Solo modifica las dos listas de cartas. El traslado consume cero RNG.

## MOV-02 · Integración y rechazo

Reutilizar [`CardCycle.discard`](../../../scripts/game/card_cycle.gd) para validar el estado, retirar y añadir las cartas y comprobar el candidato final. Aplicar antes las condiciones más estrictas de esta operación. El ciclo existente admite también cartas en juego y una lista vacía. En el perfil ficticio se construye con el mismo catálogo y registro de secuencias que usa la autoridad.

Rechazar listas vacías, tipos o IDs mal formados, duplicados, una plaza desconocida y cualquier ID que falte en la mano indicada, aunque figure en otra zona propia o pertenezca a otra plaza. Cualquier fallo devuelve falso y conserva intacto el candidato que recibió la operación. El contrato de [secuencias](../008-preparacion-y-turnos/secuencia-reanudable.md#ejecución-pausas-y-cierre) cubre el fallo del segmento completo y el reenvío. [GameEngine](../../../scripts/game/game_engine.gd) confirma revisión, recibo y RNG. Para un fallo de la operación en una secuencia válida se aplica `accion_ilegal`, sin identificar la carta causante ni confirmar dónde se encuentra. Las vistas conservan la política de [SPEC-007](../007-estado-y-acciones/spec.md).

## MOV-03 · Verificación del traslado

| Caso | Resultado esperado |
| --- | --- |
| Traslado desde una mano ficticia `[a, b, c]` a un descarte `[d]`, con entrada `[c, a]` | Mano `[b]` y descarte `[d, c, a]`. Si `a` y `c` comparten definición, se conservan sus identidades, dueño y estado. Las demás zonas y el RNG quedan iguales. |
| API interna con una lista vacía, entrada mal formada, plaza inexistente o lista con un ID repetido, ausente, ajeno o en juego | Rechazo. Combinar cada ID inválido con uno válido cuando corresponda y comparar el candidato completo previo y posterior. |
| Secuencia ficticia válida y reenvío de la misma intención | El primer envío cierra la secuencia con una revisión y un recibo. El reenvío devuelve el mismo recibo, sin otro traslado ni cambio del estado completo. |
| Fallo del traslado tras un paso ficticio que modifica un saldo y consume RNG | Se conserva el snapshot completo anterior, incluidos saldo, listas, RNG, revisión, recibos y cierres. Los rechazos por ID ausente o ajeno devuelven el mismo resultado público. |
| Segundo observador con las mismas cantidades y vistas públicas en dos estados que difieren solo en identidades ocultas | La proyección del observador tras el traslado es igual en ambos estados. La plaza titular recibe su mano y descarte actualizados. |

La [evidencia de implementación](verification.md#traslado-de-mano-a-descarte) registra los resultados de las suites de ciclo, secuencias, motor y estado.
