# Primer ensayo integrado del motor

El perfil de prueba usa dos plazas (A y B), dos saldos (`reserva` y `carga`) y tres fichas identificadas para la prueba. Los saldos reserva y carga son los nombres del ensayo para `turn_resources.recursos` y `turn_resources.ataque`. El intercambio opera sobre el mismo diccionario validado. La partida de prueba termina cuando B canjea una carga y la autoridad confirma el resultado en el formato terminal existente. El registro y la carga de instantáneas serán propios del perfil. El alcance es una prueba de integración del motor con datos inventados.

## INT-E3-01 — Recorrido y cobertura

Estado inicial determinista. A tiene las fichas a1 y a2 en mano, el descarte vacío, 4 de reserva y 0 de carga. B tiene b1 en mano y 0 de carga. A está activa. El identificador de cada acción y la semilla se fijan en la prueba. Para que el resultado sea cargable, el fixture parte de tres recorridos numéricos ficticios con B en las posiciones 12, 12 y 11. El cierre de autoridad usa la primitiva de llegada existente en el último recorrido y conserva el formato validado por el motor. [Validador de estado](../../../scripts/game/state_validator.gd) · [Cierre de referencia](../../../tests/finalization_engine.gd).

| Frontera | Entrada y resultado esperado | Evidencia aislada que se reutiliza |
| --- | --- | --- |
| 1. Selección | A abre una ventana privada de selección. Se ofrecen a1 y a2 a A. Saldos y zonas conservan los valores iniciales. | [Selección privada](verification.md#selección-privada-verificada-en-el-motor). |
| 2. Alternativa | A elige a2. El motor la agrega al descarte y abre una ventana para elegir el destino de la operación. Queda a1 en mano. | [Traslado](verification.md#traslado-de-mano-a-descarte) y [alternativas](verification.md#alternativas-y-efectos-encadenados-verificados). |
| 3. Cierre de la primera secuencia | A elige donar. En un mismo segmento A canjea 2 de reserva por 1 de carga, transfiere esa carga a B y la autoridad registra una obligación privada para B. Quedan 2 de reserva y 0 de carga en A, y 1 de carga en B. En una ejecución independiente, la alternativa conservar deja 1 de carga en A y 0 en B, cierra la secuencia y no registra obligación. | [Intercambio](verification.md#intercambio-de-recursos), [encadenamiento](verification.md#alternativas-y-efectos-encadenados-verificados) y [persistencia](verification.md#ensayo-de-efectos-diferidos-y-reacciones-verificado). |
| 4a. Cambio de turno | La autoridad completa la limpieza de A y entrega el turno a B. Se reinician los saldos de A. La obligación persiste y la carga de B sigue en 1 porque la limpieza solo reinicia los recursos de la plaza saliente. | [Persistencia entre turnos](verification.md#ensayo-de-efectos-diferidos-y-reacciones-verificado). |
| 4b. Reacción | Un despacho de autoridad abre una única ventana para B al comprobar el evento de inicio de su turno. La ventana ofrece canjear y la carga de B sigue en 1. | [Despacho y reacción](verification.md#ensayo-de-efectos-diferidos-y-reacciones-verificado). |
| 5. Resultado | B elige canjear. El canje debita 1 de carga y acredita 1 en `turn_resources.mision`. En el mismo cierre la autoridad liquida la obligación y la primitiva de llegada consume ese punto al registrar la llegada al final del último recorrido. El resultado de B, el cierre y el recibo se confirman en una revisión. | [Confirmación de cierre](verification.md#ensayo-de-finalización). |

La prueba nueva debe cubrir la composición de selección con alternativa, el traspaso de carga entre plazas y las dos confirmaciones de autoridad. La primera confirma la obligación con la rama elegida. La segunda liquida la obligación al cerrar la reacción y confirma el resultado. La transferencia y el canje final necesitan operaciones del registro de ensayo. No se presupone que las operaciones aisladas se puedan registrar juntas sin adaptar la validación del perfil.

## INT-E3-02 — Rechazo, restauración y privacidad

| Caso | Comprobación prevista |
| --- | --- |
| Opción inválida o plaza incorrecta | Intentar seleccionar b1 como A y contestar desde la otra plaza en las dos ventanas de A y la de B. Volver a enviar una respuesta con un ID de ventana anterior y un ID de acción nuevo. Las opciones y las ventanas válidas siguen disponibles para el destinatario. |
| Fallo de la donación | En una variante válida con la carga de B en el máximo entero, la transferencia falla tras el canje de A. Se conservan la ventana de alternativa, los saldos anteriores al canje y a2 en descarte, que procede de un segmento ya confirmado. No aparece obligación. La rama conservar sigue disponible. |
| Evento repetido o prematuro | Enviar el evento antes del turno de B y repetirlo con otro ID de acción después de abrir la reacción. No se crea una segunda ventana. |
| Fallo del cierre terminal | Inyectar un error en el cierre después de preparar el débito y la liquidación. Se conserva la carga de B, la obligación y su ventana. El resultado continúa pendiente. Reintentar desde esa frontera con el cierre habilitado produce un único resultado. |
| Restauración y reenvío | Restaurar el estado inicial, cada ventana, el cierre inicial, el cambio de turno anterior al despacho y el estado terminal en una instancia del mismo perfil. Comparar el estado de autoridad, las vistas de A y B y los recibos con la ejecución continua desde cada frontera. Reenviar las acciones confirmadas con el mismo ID y contenido devuelve el recibo original sin avanzar la revisión. Reutilizar el ID con contenido distinto se rechaza. Una acción ordinaria nueva tras el cierre terminal se rechaza. |
| Carga inconsistente | En copias de instantáneas válidas, suprimir la obligación tras donar, borrar una ventana conservando sus recibos y alterar un recibo de cierre. Rechazar cada carga y conservar intacto el estado de la instancia de destino. |
| Vistas por plaza | Solo A recibe los IDs ofrecidos en su selección y las opciones de su alternativa. Solo B recibe las opciones de la reacción. Ninguna vista expone la obligación interna. El resultado confirmado es visible para ambas plazas. |

Cada rechazo compara el estado de autoridad completo, incluidos revisión, RNG y recibos, con el estado anterior al intento. Cada confirmación válida avanza una revisión. El total de instancias se conserva en ambas ramas y tras la restauración.

## INT-E3-03 — Implementación y verificación previstas

1. Crear un perfil versionado para las dos secuencias en el entorno de pruebas. Reutilizar el registro cerrado, las validaciones de ventana y la confirmación en `GameEngine`. Validar la consistencia entre obligación, ventana, turno y resultado al cargar una instantánea. Rechazar cargas que mezclen perfiles. [Contrato de secuencias](../008-preparacion-y-turnos/secuencia-reanudable.md) · [Motor](../../../scripts/game/game_engine.gd).
2. Implementar el recorrido en una prueba dirigida con semillas y acciones fijas. Registrar las instantáneas y recibos de la ejecución continua, restaurarlos en instancias nuevas y cubrir los casos adversos. Comprobar por separado la alternativa conservar, el límite entero y el fallo de cierre.
3. Ejecutar la importación, la prueba dirigida y `test-sequence`, `test-engine`, `test-state`, `test-deferred` y `test-finalization`. Contrastar los resultados y el aislamiento del perfil en revisión independiente.

Quedan pendientes de sus propias tareas la admisión del catálogo, las operaciones específicas de sus diseños, la distribución, los recorridos de 3 y 4 plazas y la interfaz de partida. La integración prevista no incluye red. E3 sigue abierta. [Cotejo del mercado](cotejo-mercado.md) · [Plan de trabajo](../../plan-de-trabajo.md#ruta-de-entregas-agrupadas-2026-11-23).
