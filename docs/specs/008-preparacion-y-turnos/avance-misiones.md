# Contrato de avance de misiones competitivo

T08.1b11 es una entrega documental R2 para competitivo de 2–4 plazas. T08.1b12 implementa el primer perfil automático M5/M6/M7 descrito aquí; verificación y revisión en [evidencia](verification.md#t081b12--resolutor-automático-de-misiones-m5m6m7). No habilita una partida de producto ni amplía los perfiles actuales de Funding o inicio competitivo.

Fuentes: [SRC-001](../../referencias/README.md#src-001--reglamento-aportado-por-el-usuario), pp. 8–9, 12–14 y 17; [SRC-002, FAQ oficial](https://www.brotherwisegames.com/mistborn-deckbuilding-game-faq), «Missions», «Metal tokens & atium», «Action cards» y «Miscellaneous» (consulta 2026-11-12); [transcripción SRC-005](../../referencias/misiones-competitivas.md), [catálogo v2](catalogo-misiones.md), REG-032–035/044/045 y DEC-031/032. [DEC-034](../../decisiones.md#dec-034--orden-de-premios-y-victoria-por-misiones) resuelve el orden no explicitado por las fuentes: normal antes del extra; victoria por la tercera cima antes de sus premios.

## Intención y autoridad

La intención `avanzar_mision` usa el sobre de P07 y un payload exacto `{mission_id}`. Consume **un punto neto de misión** de `players[].turn_resources.mision`, la reserva de la plaza activa y avanza su marcador una casilla. Repetir acciones permite repartir puntos entre las tres misiones, sin saltar premios intermedios. No se admite cantidad, posición de destino, premio, primer jugador, ganador, programa o snapshot decidido por el cliente. Las pérdidas de puntos afectan a la reserva; nunca retroceden un marcador.

La autoridad exige partida en curso, competitivo de 2–4, fase `libre`, actor activo vivo, salud/eliminación coherentes, al menos dos vivos, `resolution == null`, reserva neta suficiente y recorrido conocido con progreso 0–11. Una misión terminada no consume puntos. Antes de empezar, comprobar continuidad y ausencia de un final previo o pendiente. Tener cuatro Atium no acredita Confrontación ni provoca victoria por sí solo.

El perfil reconoce las definiciones completas y sus efectos, también fuera de juego, y la identidad canonicalizada del catálogo validado. Una reserva numérica no demuestra que Sense u otros modificadores se hayan aplicado. El piloto excluye esos efectos por descriptor y procedencia; no permite una bandera de cliente «sin pendientes». El catálogo de misiones no aporta cartas generadoras de puntos: el fixture de autoridad proporciona reservas netas declaradamente ficticias.

P07 serializa la intención desde lectura hasta publicación y conserva su contrato de recibos: duplicado idéntico devuelve recibo original aun tras finalizar; ID reutilizado con contenido distinto se rechaza; nuevo ID requiere revisión vigente. Una nueva intención válida desde la posición siguiente es un nuevo gasto legítimo, no una repetición del mismo paso. No se añade una entrada pública de aplicar premios.

## Estado de snapshot 3 e invariantes

T08.1b12 usa **esquema de snapshot 3 y motor `p08-missions-1/godot-4.7.2`**. T08.1b11 especificó el formato sin cambiar entonces el motor. El catálogo conserva su versión 2, independiente del snapshot. No hay migración implícita de esquema 2: sus posiciones no permiten reconstruir quién llegó primero a una casilla intermedia.

Por misión se mantienen `definition_id`, `progress`, `rewards` y `arrival_order`, y se añade `first_arrivals`: mapa exacto de `p01`…`p12` a plaza o null. El mapa registra todas las casillas, incluso sin premio. Al entrar por primera vez se fija la plaza; nunca se sobrescribe, tampoco tras eliminarla. `arrival_order` contiene una vez cada plaza que alcanzó 12, en orden de llegada, y su primera plaza coincide con `first_arrivals.p12`.

- Hay tres misiones distintas admitidas. Cada progreso es un entero 0–12, con una entrada por plaza. Cero queda fuera del recorrido. No existen retrocesos en este perfil.
- Para cada casilla, si nadie la alcanzó, su primera llegada es null. Si alguien la alcanzó, existe una primera plaza que también la alcanzó. El orden verdadero proviene del estado confirmado, no se certifica sólo por estas relaciones estructurales.
- `rewards[plaza]` sigue siendo una lista sin duplicados de IDs públicos de grupos liquidados: por ejemplo `p04_normal`, `p04_primero` y `p12_permanente`. Sólo se marca un grupo no vacío tras ejecutar todas sus operaciones, o una elección de omisión reglamentariamente permitida. No registrar premios inexistentes, de casillas no alcanzadas ni extras de otra plaza.
- En un estado estable en curso deben estar liquidados todos los premios alcanzados. Durante una pausa futura, únicamente la resolución de autoridad vinculada a esa plaza/casilla puede explicar grupos pendientes; el cursor impide repetir operaciones ya confirmadas. No confundir primera llegada, premio pendiente y premio liquidado.
- La eliminación conserva marcadores, primeras llegadas, premios y orden de cima. Una plaza eliminada no actúa ni vuelve disponibles extras.

Se añade al snapshot `outcome`, null mientras siga en curso. El primer perfil sólo admite como resultado `{winner_id, reason: "tres_misiones", mission_id, turn_number}`: ganador vivo con las tres posiciones a 12, última misión identificada y turno de la acción ganadora. `lifecycle == "finalizada"` y ese resultado se confirman juntos. Cualquier otro final exige su propio contrato; el perfil no admite estados que puedan haberlo producido. Los constructores/fixtures de esquema 3 declaran `outcome: null` y mapas de primera llegada con valores null antes de cualquier avance, con las claves del recorrido de cada perfil, sin reinterpretar snapshots antiguos.

En una victoria inmediata, la última cima no liquida sus grupos de premio y no instala su permanente. Esa omisión sólo es válida en la misión/turno del resultado terminal confirmado. No deja una resolución ni una obligación posterior. Las otras dos misiones completadas conservan sus premios anteriores.

## Transacción y prioridad

1. Validar intención, recibo, revisión, perfil y estado; comprobar soporte de **todas** las operaciones que implicaría la llegada antes de mutar. Un efecto aún no soportado produce rechazo íntegro, no avance parcial. En el caso terminal conocido los premios no se ejecutan por DEC-034.
2. Sobre copia, descontar uno y avanzar exactamente uno. Fijar la primera llegada si estaba vacía. Si llega a 12, añadir a `arrival_order` una vez, incluso siendo segundo, tercero o cuarto.
3. Si la plaza acaba de completar las tres misiones, registrar `outcome` y finalizar inmediatamente. No conceder premios de esa última casilla, no abrir elecciones, no conceder permanentes ni continuar turno, limpieza o rival.
4. Si continúa, resolver el premio normal de la casilla, o instalar/aplicar su permanente de cima, y después el extra del primero si pertenece a esta plaza. El extra es adicional y se liquida una sola vez. Cada lista conserva su orden del catálogo. No permitir otras acciones entre llegada y premios.
5. Validar candidato completo y delta autorizado; P07 confirma revisión, RNG, contadores y recibo junto al cambio. Publicar únicamente la proyección confirmada.

Para el piloto automático todo el paso es una sola transacción: un fallo de premio, overflow, colisión de ID, perfil o validación revierte gasto, progreso, primeras llegadas, orden, premios, recursos, salud, fichas, RNG, revisión y recibos. La curación limita a 40; alcanzar ese límite no es un error ni genera otro recurso.

Para futuros premios con elecciones se reutilizará el [contrato de secuencia](secuencia-reanudable.md): cada segmento hasta pausa o cierre es atómico; efectos confirmados antes de una pausa permanecen al fallar una respuesta. La llegada y la reserva del primer premio se confirman junto a la primera pausa. La restauración conserva cursor y estado, nunca repite el gasto. Antes de habilitar esas misiones, se especificarán programas, contexto, ventanas, límites y validación de grupos parcialmente resueltos. El motor actual protege `turn` y `lifecycle` durante secuencias: no eliminar esa guarda para permitir finales desde callbacks. El piloto automático utilizará un manejador cerrado con delta terminal validado; un futuro cierre terminal de secuencia necesita diseño propio.

## Premios y permanentes

T08.1b15 concreta las futuras elecciones, límites, programas y validación de premios pendientes de M8 en el [contrato de eliminación](elecciones-m8.md). No amplía los perfiles ejecutables actuales.

T08.1b13 concreta la futura integración de M3/M4, marcas privadas y nueva mano en el [contrato de permanentes](permanentes-misiones.md), sin ampliar el piloto actualmente ejecutable.

| Misión | Resolución exigida al integrarla |
| --- | --- |
| M1 | Selección de fichas ordinarias agotadas propias; refrescar no borra `used_this_turn`. Atium no se agota. La cima aumenta capacidad de quema una vez y después refresca todas si es primero. Antes de implementar: definir selección cuando hay menos fichas que el premio y las ventanas de selección. |
| M2 | Combate a la reserva. El extra intermedio requiere definir aliados elegibles, objetivo y reacciones a derrota directa; no convertirlo en daño de combate ni ignorar defensas. Cima: instalar +2 combate, aplicarlo al llegar y después +1 si es primero. No ejecutar extras sin el contrato de objetivos/reacciones. |
| M3 | Monedas a la reserva del turno, nunca Boxings. Cima: instalar +2, aplicarlo al completar y después +3 si es primero. |
| M4 | Robo inmediato mediante CardCycle y DEC-032. Cima: instalar +1 a la nueva mano de limpieza, después robar dos si es primero. No aplicar ese +1 a cada robo ni al extra inmediato. |
| M5 | Moneda y combate según posición; curación del primero con techo 40. Cima: una ficha de Atium normal y otra si es primero, con saldo/fichas/contador coherentes según DEC-024. Cuatro Atium disponibles no ganan automáticamente. |
| M6 | Componer avances unitarios con la semántica de TrainingAdvance, sin abrir turno ni activar habilidades. Su API actual exige `inicio`: extraer un núcleo de candidato compartido con guardas de llamador para misión en `libre` e inicio, sin falsear temporalmente la fase ni relajar el consumo único del inicio. El extra va después del paso normal: desde 19, dos avances llegan a 20 y después ganan Atium. Mantener límite previo, desbloqueos y extremo de pista del contrato de entrenamiento. |
| M7 | Curación normal y después adicional del primero, ambas hasta salud 40. El exceso se pierde. |
| M8 | Eliminación propia opcional desde mano, descarte o juego; cero es válido. Elegir primero hasta el máximo normal y después hasta uno adicional si es primero, sin volver a elegir cartas retiradas. Conservar efectos ya obtenidos al eliminar una carta jugada. Antes de habilitar: contrato de ventanas/identificadores privados y casos con más de 16 candidatas; no truncar opciones al límite actual de SequenceRegistry. |

La FAQ no establece omisión general de todos los premios de misión. La opcionalidad de M8 no se extrapola a refrescos, robos o derrotas de aliados. Los casos sin objetivos y las reacciones de M1/M2 quedan pendientes, sin inventar una solución silenciosa.

Los permanentes se derivan de los grupos de cima liquidados y se validan contra la misión exacta; no son banderas libres. M1 aplica el aumento una sola vez y la limpieza no lo retira. M4 modifica únicamente el tamaño de la nueva mano. M2/M3 se aplicarán en el inicio propio posterior, dentro del mismo commit de inicio, **después del entrenamiento y antes de abrir libre**, sin ventana intermedia. Este punto es una elección técnica del contrato: el perfil completo deberá contrastar las interacciones de otras cartas antes de admitirlas. Llevar marca privada por misión/plaza/número de turno aplicado y fijarla también al completar, para evitar duplicación en ese turno; rechazar marcas futuras o incompatibles con el origen confirmado.

## Carga y privacidad

La fuente de autoridad selecciona el último estado confirmado por partida y perfil, siguiendo el [inicio competitivo](inicio-competitivo.md). Restaurar sólo un motor vacío y conservar recibos, llegadas, grupos, resultado y RNG exacto. Un snapshot estructuralmente válido, uno anterior al commit o una copia enviada por cliente no acreditan continuidad.

La proyección pública puede mostrar progreso, grupos liquidados, primeras llegadas, orden de cima y resultado por lista permitida. No copiar cursor, contexto, programas, recibos, RNG ni marcas privadas de aplicación por turno. Las ventanas revelan opciones sólo al destinatario según P07. Un descarte/una mano ajenos no se hacen públicos por usar M8; cualquier revelación de una carta eliminada sigue la política de zona autorizada. Los errores públicos conservan los códigos genéricos existentes.

Cooperativo y solitario conservan sus propios finales y reglas de adversarios/posición; completar tres misiones no les concede esta victoria. Quedan fuera del perfil y se abordarán conforme a DEC-027. La sala, persistencia en disco, reconexión y transporte siguen en sus fases.

## Aceptación y primer plan de implementación

| Criterio | Casos que deberá ejecutar T08.1b12 o la integración indicada |
| --- | --- |
| MIS-01 — Gasto e invariantes | Competitivo 2/3/4: avance 0→1, gasto unitario, reparto entre recorridos, posiciones 0–12 y rechazo desde 12. Rechazar saldo insuficiente, actor/fase/modo/resolución incorrectos, primera llegada contradictoria y grupos inventados. No retroceder por negativos. |
| MIS-02 — Primeros y premios | A alcanza premio, B lo alcanza después: normal para ambos, extra sólo A. Restaurar y reenviar sin duplicar. Primera llegada intermedia no deducida de la cima ni de la posición actual. Conservar primero eliminado. Orden normal→extra, incluyendo casos donde el primero llega a salud 40. |
| MIS-03 — Fallo e idempotencia | Fallos inyectados después del descuento, de la llegada y de un premio conservan snapshot/RNG/IDs/recibos completos. Duplicado idéntico antes/después de restaurar; ID conflictivo; nueva acción válida para el paso siguiente. Futuras pausas: respuesta inválida conserva exactamente la pausa previa, sin repetir pago. |
| MIS-04 — Permanentes | En integración: M1 no se duplica; M2/M3 al completar y una vez por turno posterior, sin repetirse al reenviar/restaurar; M4 aumenta sólo la nueva mano, incluido robo corto. Rechazar marcas desconocidas y obligación pendiente antes de libre. Estos casos no se acreditan con el piloto. |
| MIS-05 — Terminal | De 11 a 12 en tercera misión: descontar punto, registrar llegada y ganador, finalizar sin sus premios. Repetición devuelve recibo, nuevas acciones fallan. Completar sólo una/dos no gana; no exigir ser primero en todas; cuatro Atium sin Confrontación no gana. Rechazar resultados falsificados y estados con un final anterior no liquidado. |
| MIS-06 — Admisión/carga/privacidad | Rechazar snapshot 2, catálogo cambiado bajo mismo ID, fixture no reconocido, perfil con Sense/obligaciones sin soporte, modo rival y copia antigua. Proyección no filtra secretos ni metadatos privados; destinatario futuro puede responder desde su vista. Probar restauración estable y terminal; pausas sólo al integrar elecciones. |

**T08.1b12: primer resolutor automático aislado.** Seleccionar exactamente M5/M6/M7 y reconocer las ocho definiciones del lote real validado, más el resto de un fixture cerrado declarado, con fuentes v2 disponibles. Soportar posiciones vacías, todos los premios de esas tres misiones y su final terminal. La pista de entrenamiento seguirá siendo un fixture explícito compatible con su contrato, sin declarar validada la pista española del producto. No seleccionar M1/M2/M3/M4/M8 como si sus efectos fueran inertes; que estén en el catálogo sin seleccionarse no autoriza ejecutarlas. La admisión y las pruebas distinguirán esas definiciones disponibles de las tres misiones activas.

Plan: (1) actualizar esquema/versión, constructores/fixtures y validación de llegadas/grupos/resultado; (2) añadir servicio interno de candidato y adaptador de autoridad con consumo y delta cerrado; (3) extraer el núcleo de entrenamiento conservando sus guardas de inicio, implementar premios soportados y recibos/terminal; (4) ejecutar suite nueva y regresiones de estado, motor, catálogo v1/v2, preparación, ciclo, limpieza, secuencia, Funding, entrenamiento e inicio, con Godot 4.7.2; (5) revisión independiente R2 y cierre documentado. Reutilizar el contraste de fuentes de esta entrega. Los permanentes de inicio, elecciones y las demás misiones requerirán integración posterior con sus contratos concretos. No añadir UI ni red al piloto.

T08.1b11 se cerró documentalmente. La ejecución del subconjunto automático MIS-01–03/05/06 y sus límites se registra en [T08.1b12](verification.md#t081b12--resolutor-automático-de-misiones-m5m6m7); MIS-04, elecciones y pausas siguen siendo pruebas futuras.
