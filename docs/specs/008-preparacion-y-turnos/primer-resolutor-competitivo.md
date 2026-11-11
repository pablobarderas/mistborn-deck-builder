# T08.2g — Primer resolutor real competitivo: Funding

Fecha: 2026-11-11. Contrato documental R2, pendiente de implementación T08.2h. Amplía SPEC-008 sin cambiar todavía motor, esquema, catálogo o acciones disponibles. Registro previo y responsables en [tareas](tasks.md); implementación posterior en [plan](plan.md). No acredita una partida jugable.

Seguimiento: T08.2g fue publicada en `1e6c917`; T08.2h lleva este contrato a código local. El estado de implementación/pruebas se mantiene en [su evidencia](verification.md#t082h--implementación-de-funding); el resto del documento conserva el contrato previo y sus requisitos, no un resultado de ejecución.

## Elección y fuentes

Se selecciona jugar Funding: mover una instancia propia de la mano a juego y, si se elige aplicar su habilidad, obtener una moneda de la reserva del turno. Es la primera regla de carta sobre T08.2f. El identificador técnico de la reserva es `turn_resources.recursos`; **no** `persistent.boxings`. Financiación es el nombre observado en el inventario español, aún sin transcripción verificada incorporada.

| Obligación | Fuente contrastada | Consecuencia |
| --- | --- | --- |
| Funding produce una moneda sin coste ni metal asociado | SRC-001 p.11, Funding; REG-027 | Ganancia +1 al aplicar o +0 al omitir la habilidad, sin quemar, refrescar ni consumir límite de metal. |
| Jugar cartas durante la parte libre y colocarlas en juego | SRC-001 p.6, Deckbuilding 3/5, y p.17, Turn Structure 2A; REG-009 sólo para permanencia hasta limpieza | Exigir `libre`; la carta permanece en juego hasta su descarte posterior. |
| Los recursos obtenidos van a su reserva y se resuelven efectos en orden | SRC-002, Action cards; REG-069 | Aplicación atómica de movimiento y ganancia; no interpretar texto ni resumen visual. |
| Se pueden omitir habilidades voluntariamente | SRC-002, Action cards; REG-070 | Elegir aplicar u omitir al jugar Funding; no crear una reacción artificial. |
| Las monedas del turno y Boxings persistentes son distintos | SRC-001 pp.11/16–17; REG-043/042 | No crear Boxing ni gastar monedas para comprarlo como parte de jugar Funding. |

Fuentes: [PDF SRC-001](../../referencias/fuentes/MistbornRulebook_V1.pdf), [FAQ SRC-002](https://www.brotherwisegames.com/mistborn-deckbuilding-game-faq), [matriz](../../referencias/matriz-reglas.md). La FAQ se consulta para esta tarea; su ausencia de una excepción no certifica todas las cartas del catálogo pendiente.

Funding evita por ahora la ampliación que exige combate: `GameEngine.submit` prohíbe alterar `turn` y `lifecycle` dentro de una secuencia; asignación de daño, Target, reacciones y eliminación necesitan contratos adicionales. Esta elección técnica sigue la prioridad competitiva DEC-027, sin sustituir el objetivo posterior de combate entre jugadores.

## Alcance y puerta de contenido

Sólo competitivo 2/3/4, activo vivo, partida en curso, turno positivo, fase `libre` y ninguna resolución pendiente. Esta restricción de modos es una frontera de implementación, no una regla que prohíba Funding en cooperativo/solitario. No se implementa aquí apertura de `libre`, compras, Boxings, metales, otros efectos, combate, entrenamiento, finales ni red/UI. T08.1b y las puertas de [entrada a limpieza](entrada-a-limpieza.md) permanecen pendientes.

El futuro módulo admite exclusivamente una definición Funding revisada por autoridad, procedente de un catálogo válido, `revision.estado=verificada`, sin dudas ni dependencias pendientes. Debe comprobar el descriptor completo soportado: tipo `funding`, metales vacíos, una habilidad `al_jugar` con condición `siempre`, `limite_por_turno=null`, y exactamente `ganar/recursos/1/propio`. No basta un nombre, `resumen.recurso=1`, el tipo aislado ni una etiqueta `verificada`. Los demás campos obligatorios y las referencias deben pasar P06; cualquier habilidad/condición/rasgo mecánico adicional necesita soporte explícito y no puede ignorarse.

El perfil de soporte es código/configuración confiable de autoridad, nunca un booleano del cliente ni del snapshot. Debe auditar todas las definiciones que puedan intervenir, incluidos personajes, aliados, misiones/recompensas y efectos continuos/reactivos. En el primer perfil sólo se admiten Funding y componentes de prueba explícitamente inertes, con descriptores completos conocidos; cualquier definición o marca dinámica fuera de esa lista rechaza la acción antes de mover la carta. No deducir ausencia de efectos de `resolution=null`, `training=0` o de campos vacíos. No explorar manos ajenas para producir errores distintos según una carta secreta: la compatibilidad se comprueba sobre el perfil completo, con error público genérico.

Las pruebas podrán usar contenido ficticio declarado como tal para el resto del estado y una definición de prueba que represente **la regla** Funding del PDF. Esto permite probar una regla real sin afirmar que se ha incorporado una carta oficial española. `data/cartas.json` conserva sus dos muestras; no se habilita una ruta de producto hasta revisar contenido real y sus interacciones. El inventario de escaneos no sustituye el original: la ruta del otro PC no existe en este entorno y las imágenes no están versionadas. No se necesita pedir de nuevo material aplazado para cerrar este contrato documental.

## Intención, autoridad y resultado

Nombre reservado de intención: `jugar_funding`. Conserva el sobre v1 P07 (`match_id`, `action_id`, `expected_revision`, etc.); payload exacto `{ "instance_id": "...", "aplicar": true }`, con `aplicar` booleano obligatorio. No acepta cantidad, reserva, programa, fuente de definición, fase, ocurrencia ni acreditación de efectos elegidos por el cliente. No registra una operación genérica de ganar recursos accesible al jugador.

El adaptador de autoridad valida el perfil y deriva definición, propietario y zona de la instancia. Debe estar exactamente en la mano del actor activo, pertenecerle y corresponder a Funding soportada. Zonas se buscan por `kind`/`holder_id`, nunca por prefijos inventados de IDs. Rechazar instancia ajena, inexistente, de mazo/descarte/juego/eliminadas, actor eliminado, fase/modo incorrectos y cualquier estado fuera del perfil. La resolución bloquea nuevas acciones mediante P07.

Programa reservado `funding_play_v1`, fuente no nula igual a la instancia elegida. Contexto cerrado: campos base de T08.2f más `card_id: instance_id` y `apply_effect: bool`, copia de la elección validada; `source_id == context.card_id`. Destinatarios `[owner_id]`. Un único paso automático `play_and_gain` comprueba de nuevo las precondiciones, retira la instancia de mano preservando el orden restante, la añade al final de juego y suma exactamente uno a `turn_resources.recursos` si `apply_effect=true`; si es false mantiene el saldo. Ambas variantes juegan la carta y consumen la ocurrencia. No modifica la definición ni crea otra instancia. Sin ventana de elección, sin consumo de RNG, sin marcar una habilidad como usada una vez por turno.

Todo se ejecuta en la copia transaccional de P07. El paso no escribe resolución, ledger, recibos, revisión, `next_id`, fase o ciclo de vida; el núcleo asigna la resolución y sella el cierre. Fallo de validación final, overflow o límite técnico: rollback integral, también movimiento, RNG, IDs y recibos. Los límites int64 y de tamaño de P07 siguen siendo límites técnicos, no topes de monedas del reglamento.

### Ocurrencia y repetición

Cada juego legal desde mano es una ocurrencia. El adaptador deriva `occurrence_id = funding_play_<authority.next_id>` del contador previo al inicio; P07 asigna el ID de resolución e incrementa ese contador en la misma transacción. No se toma del `action_id` ni se reutiliza una ocurrencia cerrada. Esta asignación sólo es válida **después** de comprobar la elegibilidad de la instancia en mano y el perfil soportado: un ID nuevo no autoriza volver a jugar la carta que permanece en juego.

Un reenvío idéntico con el mismo `action_id` recupera el recibo original sin movimiento, ganancia ni cierre nuevos, incluso después de recargar el snapshot. El mismo ID con otro payload conserva el rechazo P07. Una nueva intención sobre la carta ya en juego es ilegal. Dos instancias Funding distintas de la mano son dos juegos válidos. No imponer un límite de una vez por carta/turno: si una futura regla soportada devuelve una carta a mano, el contrato de esa regla deberá permitir una nueva ocurrencia; T08.2h no implementará ese retorno.

### Errores y vistas

Conservar errores del sobre P07. Payload mal formado: `formato_invalido`; falta de legalidad o contenido/perfil no soportado: `accion_ilegal`; fallo interno/overflow/estado: `estado_invalido`. No ampliar en esta tarea la lista pública ni incluir nombres o IDs secretos en el error. El rechazo conserva snapshot, revision y recibos íntegros.

Después del éxito, las vistas existentes muestran +1 recursos (o saldo intacto si se omitió), una carta menos en la mano y Funding en la zona pública de juego. La mano ajena sólo cambia en cantidad; no se revela su contenido restante, mazo, RNG, contexto, recibos ni ledger. `resolution` queda null porque este programa termina sin pausa. El cierre acredita únicamente este juego Funding, jamás combate, fin de turno o permiso de entrar en limpieza.

## Compatibilidad y límites de integración

El diseño cabe en las firmas actuales de `SequenceRegistry`: callbacks GDScript estáticos, parámetros enlazados escalares y contextos planos. La fábrica de autoridad valida y copia las definiciones antes de registrar el programa; sólo enlaza IDs escalares ya aprobados, sin enlazar diccionarios a callbacks del registro ni confiar en objetos mutables externos. El código del paso necesita verificar identidad/posición de nuevo; el adaptador no muta el estado que se va a publicar.

No se modifica `GameEngine` para permitir cambios de `turn`/`lifecycle`, ni se debilitan invariantes para hacer pasar el programa. El programa usa esquema 2; la implementación deberá versionar la semántica nueva como `p08-funding-1/godot-4.7.2`, manteniendo el rechazo explícito de snapshots de versiones anteriores, sin migración heurística. Al cargar un snapshot con cierres Funding debe existir el mismo registro y perfil de contenido compatible, aunque no haya resolución activa. Un registro vacío o desconocido no puede borrar los cierres para aceptar la carga.

## Aceptación documental T08.2g

- **AC-35:** regla y reservas inequívocas, trazadas a PDF/FAQ; diferenciar prueba de regla y catálogo español verificado.
- **AC-36:** intención, perfil completo, legalidad, movimiento/ganancia, ocurrencia y errores especificados; sin puertas de fase falsas.
- **AC-37:** compatibilidad real con T08.2f, límites/privacidad/versionado e integración futura explícitos.
- **AC-38:** escenarios adversos y plan ejecutable de T08.2h, revisión independiente favorable, evidencia documental y traspaso. No exigir ni afirmar pruebas de código inexistente.

## Escenarios de implementación T08.2h

Estos escenarios son requisitos futuros; **no se han ejecutado** en T08.2g.

| Caso | Resultado observable exigido |
| --- | --- |
| FUND-01: competitivo 2/3/4, una Funding en mano | Instancia a juego, +1 recursos al aplicar / +0 al omitir, un recibo/cierre, revisión +1; resto de recursos/estado y RNG conservados. Probar saldo cero y positivo y las dos elecciones; omitir no permite volver a activar esa instancia en juego. |
| FUND-02: dos Funding distintas | +2 en dos intenciones; dos ocurrencias/cierres; ningún límite artificial por turno. |
| FUND-03: actor/plaza/fase/modo/zona ilegales | Rechazo integral; incluir `inicio`, `combate`, `limpieza`, partida finalizada, eliminado, cooperativo/solo y resolución pendiente. |
| FUND-04: payload y perfil falsificados | Rechazar cantidad/programa/fase extra, `aplicar` ausente/no booleano, instancia ajena/inexistente y definición con efecto adicional/no soportado aunque su resumen visual indique 1, condición distinta o revisión insuficiente. Error no filtra secretos. |
| FUND-05: duplicados y carga | Reenvío exacto antes/después de carga no duplica; ID reutilizado distinto rechaza; nueva intención sobre carta en juego rechaza; registro incompatible no carga. |
| FUND-06: atomicidad y límites | Saldo int64 máximo al aplicar (omitir conserva ese saldo válido), revisión/next_id máximos, candidato inválido o ledger lleno no mueven cartas ni consumen IDs/RNG/recibos. No aceptar sólo por código de salida sin marca de suite. |
| FUND-07: privacidad | Todos ven Funding jugada y saldo tanto al aplicar como al omitir; sólo propietario ve mano restante. Comparar vistas/errores ajenos con secretos distintos y mismo perfil soportado. |
| FUND-08: conservación y extensibilidad | No quema/refresca metal, no concede Boxing, no altera salud/misiones/Target/fase. No reutilizar cierre para limpieza; no declarar reentrada a mano implementada. Regresiones P07/P08 y catálogo. |

La integración futura con limpieza puede comprobar que la Funding jugada se descarta y recursos se reinician cuando un fixture sitúa legítimamente ese segmento. No presentarlo como transición `libre`→`limpieza` implementada ni como final de turno completo.
