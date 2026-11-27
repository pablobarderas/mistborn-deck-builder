# Familias de efectos y pruebas del motor

Propuesta técnica para probar la resolución de efectos con definiciones ficticias. Los casos fijan entradas y resultados de prueba. La lista de operaciones admitidas, la semántica de cada carta y los criterios de salida de E3 se definen en sus propias entregas.

## Familias y aceptación propuesta

| Familia | Caso positivo | Caso adverso |
| --- | --- | --- |
| Recursos | Una operación de prueba gasta 2 unidades y concede 3 de otro recurso en un solo segmento confirmado. | Con saldo 1, el segmento falla y conserva ambos saldos, la revisión y el RNG. |
| Zonas de cartas | Una instancia se traslada a una zona admitida. El destino conserva el orden que indique la operación de prueba y el total de instancias coincide. [Primer contrato](movimiento-entre-zonas.md) | Una instancia ajena, inexistente o repetida en la misma selección se rechaza sin movimiento parcial. |
| Selección | Una [instrucción ficticia](seleccion-privada.md) pide elegir una instancia de la mano propia. La plaza autorizada selecciona una y el segmento se reanuda una vez. | Se rechazan un ID fuera de las opciones, una respuesta de otra plaza y una respuesta a una ventana anterior. |
| Alternativas y efectos encadenados | Un programa ficticio ofrece dos ramas y registra solo la elegida. Una rama con dos pasos los aplica en el orden definido. [Contrato](alternativas-y-encadenamiento.md) | Una rama desconocida o un fallo en el segundo paso revierte el segmento que lo contiene. Si hay un segmento anterior confirmado, este conserva su resultado. |
| Efectos diferidos y reacciones | Un programa ficticio responde a un evento registrado. Tras restaurar desde una frontera confirmada, la obligación pendiente se ejecuta en su momento y queda liquidada. [Contrato](efectos-diferidos-y-reacciones.md) | Repetir el evento o el recibo no vuelve a ejecutarla. Un evento fuera de la fase prevista no abre una ventana. |
| Finalización | Una operación terminal ficticia guarda el resultado y cierra su resolución. La restauración devuelve el mismo resultado confirmado. | Una acción ordinaria posterior se rechaza y no cambia el resultado. |

Los valores anteriores pertenecen a las pruebas. Cada operación futura deberá declarar sus objetivos, cardinalidad, destino, orden, momento de aplicación y resultado si faltan candidatos. Si alguna decisión depende de una regla pendiente, el contrato queda abierto hasta contar con su fuente o aceptación.

## Autoridad y reanudación

- [GameEngine](../../../scripts/game/game_engine.gd) valida intenciones y confirma los cambios. [SequenceResolver](../../../scripts/game/sequence_resolver.gd) procesa cada segmento sobre el candidato. Usar el [contrato de secuencias](../008-preparacion-y-turnos/secuencia-reanudable.md) como base del registro cerrado, las ventanas y la restauración.
- Extender las pruebas existentes del [motor](../../../tests/game_engine_test.gd), las [secuencias](../../../tests/sequence_test.gd) o el [ciclo de cartas](../../../tests/card_cycle_test.gd) según la operación. Cada prueba compara estado, revisión, RNG y recibo cuando corresponda. Para opciones privadas, comprobar tanto la vista del destinatario como la de otra plaza.
- Una ventana válida es una frontera confirmada. Si la selección posterior se rechaza, la ventana y los segmentos anteriores conservan su estado. Un reenvío aceptado devuelve el recibo existente sin volver a aplicar el efecto.
- Los programas de prueba se registran localmente. Los clientes envían intenciones y elecciones. Las vistas solo incluyen los datos que corresponden a la plaza.

El motor actual protege el ciclo de vida y el turno durante una secuencia. La prueba de finalización exige definir una ruta de autoridad compatible o ampliar expresamente ese contrato. Para el ensayo diferido se ha especificado la persistencia de la obligación fuera de la secuencia activa. Su ejecución queda pendiente.

## Verificación de una futura implementación

1. Acordar el contrato de una familia y añadir casos aislados de éxito y rechazo.
2. Ejecutarlos a través del motor con un programa de prueba y comprobar las vistas, la restauración y el reenvío si hay una frontera persistida.
3. Ejecutar las regresiones pertinentes y pedir revisión independiente del cambio. Registrar resultados reales por criterio y mantener los pendientes de integración en el [plan de E3](../../plan-de-trabajo.md#ruta-de-entregas-agrupadas-2026-11-23).

Esta matriz documenta pruebas propuestas. La evidencia de ejecución de cada familia se registrará con su implementación.
