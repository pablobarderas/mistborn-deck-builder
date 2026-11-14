# SPEC-008 — Preparación y turnos

## T08.1b21 — Contrato de integración de misiones

Contrato [M1–M8](integracion-misiones.md) completado documentalmente y revisado favorablemente: INT-DOC-01–04, futuro perfil aislado de tres misiones distintas entre ocho, competitivo 2–4; snapshot 8 sólo previsto, motor publicado snapshot 7 sin cambios. Plan de implementación y escenarios INT-01–08 en el contrato; [registro previo](tasks.md#t081b21--contrato-de-integración-de-misiones-m1m8). No admite cartas activas/producto ni cierre P08.

## T08.1b20 — Objetivos y premios M2

Implementada y verificada localmente: [M2-01–07 y rechazo de admisión M2-08](elecciones-m2.md), perfil aislado M2/M5/M7, snapshot 7 y programa `m2_first_v1`. Traslado al descarte del propietario, marca permanente e inicio interno; 17 suites/11.712 comprobaciones. Revisión independiente favorable sin hallazgos residuales; T08.1b20 completada localmente. [Registro previo](tasks.md#t081b20--implementación-de-objetivos-y-premios-m2) y [evidencia](verification.md#t081b20--implementación-de-objetivos-y-premios-m2). Defender/Cloud reales, limpieza y producto fuera del piloto.

## T08.1b19 — Objetivos y premios M2

[Contrato de M2](elecciones-m2.md), M2-DOC-01–04 satisfechos documentalmente y revisión independiente favorable. DEC-039 resuelve DUD-010; piloto futuro M2/M5/M7, M2-01–07 y rechazo de contenido no admitido de M2-08. Las pruebas reales Defender/Cloud de M2-08 pertenecen a producto. Snapshot 6 vigente sin cambios; snapshot 7 sólo previsto para T08.1b20, sin código M2. [Evidencia y traspaso](verification.md#t081b19--contrato-de-objetivos-y-premios-m2).

## T08.1b18 — Premios M1 implementados

[Contrato M1-01–08](elecciones-m1.md), perfil aislado M1/M5/M7 competitivo 2/3/4, snapshot 6/motor `p08-m1-refresh-1/godot-4.7.2`. Selección obligatoria, vacío automático, cima directa con capacidad y refresco total; tercera misión terminal antes de premios. Implementación verificada localmente con 16 suites/10.475 comprobaciones y revisión independiente favorable, sin producto/quema/limpieza; [evidencia vigente](verification.md#t081b18--implementación-de-premios-m1). Las secciones inferiores conservan versiones históricas.

## T08.1b17 — Contrato M1

[Selección de fichas agotadas, refresco total y capacidad permanente](elecciones-m1.md), M1-DOC-01–04 y escenarios futuros M1-01–08. Completada documentalmente con revisión independiente favorable. DEC-037 fija refresco obligatorio, selección para una y total automático. Código/motor vigentes sin cambios, snapshot 5; snapshot 6 y perfil aislado M1/M5/M7 sólo previstos para T08.1b18. [Evidencia y traspaso](verification.md#t081b17--contrato-de-selección-y-premios-m1).

## T08.1b16 — Elecciones M8 implementadas

[Contrato M8-01–08](elecciones-m8.md), perfil aislado M5/M7/M8 competitivo 2–4: eliminación opcional normal/extra, ventanas privadas completas y restauración sin repetir llegada/premios. Snapshot 5, 15 suites/8.418 comprobaciones; revisión independiente favorable. [Evidencia](verification.md#t081b16--implementación-de-elecciones-y-eliminación-m8). No habilita producto ni entrada a limpieza ni modos con rival; las notas inferiores de versiones anteriores conservan antecedentes.

## T08.1b15 — Contrato de elecciones M8

[Contrato, M8-DOC-01–04 y escenarios futuros M8-01–08](elecciones-m8.md): eliminación propia opcional, ventanas privadas completas, normal antes de extra y restauración sin repetir premios. Entrega documental completada con revisión independiente favorable; snapshot 5 sólo previsto para T08.1b16. No cambia el código ni admite M8 en los perfiles actuales. [Evidencia](verification.md#t081b15--contrato-de-elecciones-y-eliminación-m8).

## T08.1b13/14 — Permanentes M3/M4

[Contrato, PERM-01–06 y plan de implementación](permanentes-misiones.md): M3 al completar y una vez por inicio posterior; M4 sólo al robar nueva mano. T08.1b14 implementa snapshot 4/motor de permanentes, perfil aislado M3/M4/M7 con fixtures y entrada a limpieza pendiente. [Evidencia de ejecución y revisión](verification.md#t081b14--implementación-de-permanentes-m3m4).

## T08.1b12 — Resolutor automático M5/M6/M7

[Contrato MIS-01–06](avance-misiones.md). El primer perfil implementa MIS-01–03/05/06 en competitivo 2–4 con las tres misiones automáticas, reservas/componentes ficticios y nuevo esquema. MIS-04, elecciones y pausas permanecen pendientes para otras misiones. [Evidencia de ejecución y revisión](verification.md#t081b12--resolutor-automático-de-misiones-m5m6m7). No cierra P08 ni integra producto.

## T08.1b9 — Catálogo de misiones

El [contrato de catálogo para M1–M8](catalogo-misiones.md) define la forma v2, las fuentes físicas y CAT-MIS-01–05. T08.1b10 implementa la validación del contenido en carga explícita. La admisión de partida pertenece a la integración.

## T08.2i — Robo personal con mazo y descarte agotados

Aplica el robo personal de [DEC-032](../../decisiones.md#dec-032--desbloqueo-tardío-robo-personal-y-finales-del-rival). El resultado de `CardCycle.draw` conserva `ok` y `codigo`: tanto un robo parcial como uno vacío son aceptados. El esquema sigue en 2 y el motor usa `p08-draw-1/godot-4.7.2`.

- **ROBO-01:** tomar todas las cartas disponibles hasta la cantidad solicitada. Reciclar sólo al necesitar otra carta. Una solicitud válida con ambas zonas vacías no cambia el estado ni el RNG.
- **ROBO-02:** el cierre interno de limpieza entrega una mano corta y conserva sus reglas de recursos, Atium, privacidad y fase en las siete configuraciones. El rechazo posterior conserva snapshot y RNG y el reenvío de una acción confirmada no repite el robo.
- **ROBO-03:** rechazar entradas inválidas y snapshots de motor anterior. Conservar los demás bloqueos de limpieza y la separación entre robo personal, mercado y rival.

## T08.1b7 — Reglas acordadas para desbloqueo, robo y finales

[DEC-032](../../decisiones.md#dec-032--desbloqueo-tardío-robo-personal-y-finales-del-rival) fija el comportamiento de producto. Los criterios de las entregas aisladas inferiores conservan el comportamiento verificado entonces. T08.2i sustituye la guardia de agotamiento personal. Los escenarios de activación y del rival siguen destinados a sus integraciones.

- **Desbloqueo.** Quemar el metal requerido, alcanzar el umbral después y poder activar la habilidad en ese turno. Rechazar el uso antes de desbloquearla, sin el metal requerido o cuando ya se usó ese turno. La activación de nivel II conserva su condición de compra.
- **Robo personal.** Solicitar cinco cartas con dos en el mazo y una en el descarte: robar las tres disponibles, reciclar sólo al necesitarlo y completar el efecto con una mano más corta. Con ambas zonas vacías, el robo aporta cero cartas y no consume RNG. En limpieza, probar también el avance de fase con la mano más corta y el rollback si falla otra validación de la transacción.
- **Rival.** Aplicar [SPEC-002, AC-09](../002-modos-y-cooperativo/spec.md#criterios-de-aceptación) en solitario y cooperativo. Comprobar victoria durante el turno humano con mazo rival vacío, resolución de la última carta existente y derrota al siguiente intento de robo si la partida continúa.

## T08.1b5 — Perfil competitivo de producto

[Delimitación del perfil](perfil-competitivo-producto.md) con inventario, localizadores de misiones y dependencias del inicio. T08.1b6 incorpora DEC-031 a los escenarios PERF-01–06 para la integración posterior. La preparación y el inicio con contenido de producto siguen pendientes.

## T08.1b3/b4 — Inicio único competitivo

El [contrato de inicio competitivo](inicio-competitivo.md) concreta ENT-AC-04. T08.1b4 implementa y prueba el avance y la apertura atómicos, el reenvío de autoridad y las comprobaciones de obligaciones y finales en el perfil aislado. [Evidencia y traspaso](verification.md#t081b4--implementación-del-inicio-competitivo).

## T08.1b1/b2 — Avance de entrenamiento competitivo

[Contrato del avance](avance-entrenamiento.md), ENT-AC-01 a 04. La preparación sitúa el marcador en la primera casilla. T08.1b2 implementa la operación interna que calcula un paso y su recompensa de SRC-004 en competitivo. La apertura de `libre` requiere una integración de autoridad que consuma el inicio una sola vez y resuelva las obligaciones previas. [Evidencia y traspaso](verification.md#t081b2--operación-interna-de-avance-competitivo).

## T08.2h — Funding ejecutable en perfil aislado

Implementación completada localmente del [contrato](primer-resolutor-competitivo.md) y escenarios FUND-01–08, con pruebas y revisión independiente favorable en [verification.md](verification.md#t082h--implementación-de-funding). Se conserva esquema 2, versión de motor `p08-funding-1/godot-4.7.2`, sin migración implícita. Los criterios de aceptación de implementación son los ocho escenarios del contrato, no los AC-35–38 exclusivamente documentales de T08.2g.

## T08.2g — Primer resolutor competitivo

[Contrato Funding](primer-resolutor-competitivo.md), AC-35–38 y escenarios futuros FUND-01–08: juego desde mano, elección aplicar/omitir, reserva del turno, autoridad y cierre único. Entrega documental histórica; T08.2h implementada según la sección superior. No incorpora catálogo oficial ni abre fases.

## T08.2f — Implementación interna de secuencias reanudables

Encargo 2026-11-09. Contrato normativo: [secuencia reanudable](secuencia-reanudable.md); los criterios siguientes llevan ese diseño a código, sin añadir reglas reales.

Completada localmente 2026-11-10, con revisión independiente favorable y 3.353 comprobaciones entre secuencias y regresiones. [Evidencia, hallazgos corregidos y traspaso](verification.md#t082f--implementación-de-secuencias-reanudables). Las ampliaciones inferiores conservan sus versiones históricas.

- **AC-29:** registro cerrado congelado al crear el motor, validación de todos los pasos/operaciones/contexto, límites explícitos y rechazo de programas incompatibles incluso después de una ventana; ningún programa ficticio se registra en producto.
- **AC-30:** snapshot v2 y motor p08-sequence-1/godot-4.7.2, sin migración implícita; carga atómica y validación de pausa/contexto/turno/ledger. Exportar/cargar conserva RNG int64 y permite reanudar en otro motor equivalente.
- **AC-31:** avanzar pasos en una transacción hasta ventana o cierre; respuesta legal completa un paso y reanuda, error revierte todo el segmento actual. Conservar efectos de segmentos previamente aceptados; no cambiar fase/turno ni activar reglas de cartas.
- **AC-32:** cierre único por ocurrencia, sellado por P07 con revisión aplicada; manejadores no pueden inventar, borrar o alterar cierres. Recibos, reintentos idénticos/contradictorios, ventanas obsoletas y ocurrencias cerradas mantienen idempotencia y rollback.
- **AC-33:** proyección por lista permitida: solo destinatario recibe step_id/opciones/límites; ningún cliente recibe cursor/programa/contexto/ledger/RNG. Identidades de paso/resolución opacas y actor separado del payload; rechazar respuestas inválidas sin efectos ni fugas.
- **AC-34:** ejecutar SEQ-01–10 y regresiones estado/motor/preparación/ciclo/limpieza/arranque con fixtures explícitos en las siete configuraciones. Registrar evidencia y revisión independiente antes de cerrar la entrega; no cerrar P08, P04 ni reglas pendientes.

Ampliación documental 2026-11-01: [T08.2e, secuencia reanudable](secuencia-reanudable.md), AC-23–28. Contrato técnico previo a implementación T08.2f; no modifica todavía el snapshot ni habilita la entrada a limpieza.

## T08.2c — Saldo y devolución de Atium

Ampliación 2026-10-30, REG-019/020: SRC-001 p.8 (Atium, Flaring y Refreshing), SRC-002 FAQ «Metal tokens & atium». Contrato técnico del subconjunto: cada unidad poseída de Atium tiene una ficha en `metals`; `persistent.atium` es el total de esas fichas, incluidas las usadas hasta devolverlas al limpiar. No hay reserva virtual ni doble saldo gastable: las disponibles se identifican por `used_this_turn=false`. No se implementa su ganancia, quema, refresco ni Confrontation.

- **AC-15:** el validador exige igualdad exacta saldo/conteo de Atium en cada plaza, además de tipos/IDs existentes. Atium exige `exhausted=false`: no puede hacer Flaring, única fuente de agotamiento modelada. Es una restricción del subconjunto soportado, no afirmación sobre cartas aún ausentes. Rechazar saldo menor/mayor, negativos, tipos inválidos y agotamiento de Atium sin mutación. Cero fichas/cero saldo y cantidades superiores al suministro físico son válidos dentro de límites técnicos existentes.
- **AC-16:** desde limpieza válida, retirar exclusivamente las fichas de Atium usadas y reducir el total en igual cantidad; preservar IDs/orden/estado de las no usadas, Boxings, agotamiento ordinario y jugadores ajenos. Sin usados, conservar todo el Atium. Se elimina sólo la guardia de Atium usado de AC-11/12; las demás puertas se mantienen. No hay contador de suministro finito.
- **AC-17:** devolución y decremento forman parte de la transacción de limpieza/robo/fase: DUD-006 o rechazo posterior P07 revierte también saldo/fichas/RNG; reintento no duplica devolución. Cubrir mezcla, todas/ninguna usadas, siete configuraciones y snapshot/proyecciones coherentes sin detalles privados en respuesta.
- **AC-18:** subir `version_motor` a `p08-atium-1/godot-4.7.2` y conservar esquema v1 (misma forma, semántica más estricta). Rechazar versiones anteriores sin migración ni reparación heurística; adaptar fixtures explícitamente. Regresiones de estado, motor, preparación, ciclo y limpieza. No acredita turno completo, catálogo real ni cierre de P08.

- Fecha: 2026-10-29.
- Estado: T08.1a, T08.2a, T08.2b y T08.2c implementadas y verificadas localmente (revisión T08.2c favorable); P08 no se cierra hasta ejecutar los turnos y las diferencias restantes por modo.
- Fuentes: SRC-001 pp.5–6, 12, 17–20; SRC-002, «Errata 2» y «Miscellaneous» (entrenamiento en primera ronda).
- Dependencias: estado/acciones P07 localmente verificadas; P04 externa pendiente para el cierre formal de P07. Catálogo completo pendiente por DUD-002/003.

## Alcance

El siguiente contrato se concreta en [entrada a limpieza](entrada-a-limpieza.md), T08.2d. Es una especificación de las dependencias y puertas pendientes; no habilita una transición ni acredita combate implementado.

La preparación crea un snapshot privado para los siete modos/cantidades permitidos. El adaptador de autoridad aporta exclusivamente definiciones verificadas y un manifiesto con las copias físicas identificadas; ninguna carta de muestra se trata como oficial. El orden de las plazas recibido representa el sentido horario. Competitivo recibe primer jugador elegido; cooperativo sortea el primero con RNG de partida. Se barajan mazos, se revelan seis cartas de mercado, se seleccionan tres de ocho misiones y se reparten cinco cartas por plaza. La fase inicial queda en `inicio`: todavía debe aplicarse el avance de entrenamiento antes de abrir la parte libre.

T08.1a no aplica entrenamiento, recompensas, efectos, ataques, compras ni victoria. Tampoco conecta escenas o transporte. T08.2a implementa el ciclo personal de cartas como servicio interno; T08.1b y el resto de T08.2 abordarán el turno completo. T08.3 cubrirá los efectos específicos del rival y los modos donde correspondan; su resolución depende de P09.

## Aceptación de T08.1a

- **AC-01:** rechazar modo/cantidad/plazas/IDs inválidos sin producir un snapshot ni consumir estado externo.
- **AC-02:** exigir cuatro personajes, cuatro cartas iniciales por personaje, seis Funding por plaza, 82 cartas de mercado, ocho misiones y, en solo/cooperativo, 36 cartas del rival, su ficha y la pista de Dominación; todos referencian definiciones verificadas del tipo adecuado y no exceden sus cantidades físicas. El manifiesto declara la pista de entrenamiento. Rechazar ausencias, tipos y existencias incorrectos.
- **AC-03:** crear instancias únicas, zonas personales y compartidas, ocho fichas de metal por plaza, salud base 36, entrenamiento inicial, seis cartas de mercado, tres misiones distintas y mano inicial de cinco. Misma semilla y entrada producen el mismo snapshot completo.
- **AC-04:** competitivo aplica +2/+4/+4 de salud según orden; cuarto recibe un Boxing; Target solo con tres/cuatro en el último. Cooperativo/solo no reciben estas bonificaciones ni Target.
- **AC-05:** solo/cooperativo crea rival de salud 48, Dominación visible 1 y mazo de 36. Competitivo no incluye rival ni sus zonas. El primer jugador cooperativo se sortea; el competitivo usa la plaza elegida.
- **AC-06:** el snapshot pasa el validador P07, no altera definiciones ni manifiesto y guarda el estado RNG posterior a los barajados. No se declara jugable una partida por pasar esta prueba.

## T08.2a — Ciclo personal de cartas confirmado

Subentrega de T08.2: servicio interno de autoridad, independiente de escenas y transporte. Recibe snapshot validado, definiciones y RNG de la transacción; no registra acciones públicas de robo ni permite que el cliente elija una cantidad. El extremo final del array representa la carta superior, como en T08.1a. Busca zonas por `kind` y `holder_id`, sin imponer IDs derivados del nombre de plaza.

- **AC-07:** robar N cartas personales a la mano conserva orden del mazo, identidad y propiedad. Solo al necesitar otra carta con mazo vacío se baraja el descarte con el RNG de partida; no se recicla anticipadamente ni se usa el RNG global. N=0 es operación vacía, N negativo/no entero se rechaza.
- **AC-08:** descartar una selección explícita, única y propia de cartas de mano/juego las mueve al descarte sin ejecutar efectos; una carta obtenida se puede dirigir al descarte desde el futuro manejador correspondiente, fuera de esta API. La limpieza de cartas descarta la mano y las cartas en juego salvo aliados, que permanecen. No resetea recursos, metales ni habilidades ni anuncia un turno completado.
- **AC-09:** entradas inválidas, plaza inexistente y robo superior a mazo+descarte se rechazan sin modificar snapshot ni RNG. El agotamiento devuelve `regla_pendiente`: bloqueo técnico por DUD-006, no robo parcial, derrota ni regla casera. El robo exacto de todas las cartas disponibles tiene éxito sin reciclar al finalizar.
- **AC-10:** probar siete configuraciones, determinismo de snapshot/RNG, conservación de zonas ajenas/rival/mercado, validación P07 y composición dentro de una transacción P07 con recibos y rechazo atómico. No cambiar fases ni saltar entrenamiento/resoluciones; los futuros manejadores decidirán cuándo llamar estas primitivas.

## Dudas y límites

DUD-002/003 impiden preparar una partida con contenido real hasta verificar el catálogo y su traducción. El robo personal con mazo y descarte agotados se cubre en T08.2i. [SRC-004](../../referencias/entrenamiento-competitivo.md) documenta las recompensas del panel competitivo. La apertura automática de `libre` tras `inicio` requiere especificación y ejecución del avance y sus obligaciones. SRC-002 corrige la mención a Mission Track en la regla de Atium continuo y confirma entrenamiento en la primera ronda.

## T08.2b — Cierre interno de limpieza y entrega de fase

Servicio interno de autoridad, sin acción pública ni transición combate→limpieza. El llamador sólo sitúa `limpieza` tras resolver combate, Target, efectos previos y condiciones terminales (incluidas misiones); el servicio no comprueba victorias. Se comprueban bloqueos representables; esto no certifica efectos aún sin modelar ni crea un turno jugable.

- **AC-11:** aceptar exclusivamente snapshot válido, lifecycle en_curso, fase limpieza, plaza activa viva con salud positiva, número de turno positivo y sin resolución pendiente. Rechazar entradas inválidas, fuera de fase/turno y finalizadas sin cambiar snapshot/RNG. Rechazar como `regla_pendiente` counters del turno o flags de instancias propias no vacíos, adversarios frente al activo y Atium marcado usado: no hay contrato saldo/ficha de Atium ni efectos para resolverlos todavía.
- **AC-12:** componer limpieza de cartas y robo de cinco sobre copia, conservando aliados en juego. Reiniciar recursos del turno a cero, burned, ability_uses del activo y de sus instancias propias (contrato técnico: todos esos contadores expiran al terminar el turno propio), y used_this_turn de metales ordinarios. Conservar exhausted, Atium sin usar y saldo persistente, Boxings, salud, entrenamiento, burn_limit, flags vacíos, jugadores y zonas ajenas. Atium usado se bloquea, nunca se devuelve incorrectamente ni se borra su saldo por inferencia.
- **AC-13:** competitivo pasa al siguiente vivo en player_order, incrementa turn.number y queda en inicio; no abre libre ni ejecuta entrenamiento. Exigir al menos dos supervivientes y coherencia eliminated/salud, dejando finales aún no implementados bloqueados. Cooperativo/solo bloquea rival.health=0 como final pendiente; conserva activo y número, queda en rival después del robo sin tocar el rival. No ofrecer API para salir de rival ni para abrir libre.
- **AC-14:** fallo de robo por DUD-006 revierte también limpieza, contadores, fase y RNG; éxito determinista conserva invariantes. Probar siete configuraciones, orden con eliminados y vuelta, guardias, persistentes/privacidad y composición con recibos/reintentos/rollback P07. La API devuelve sólo ok/codigo; el adaptador futuro mapeará regla_pendiente a los códigos permitidos por P07 sin registrar una acción de producto.

Fuentes: SRC-001 pp.7–8 (fichas, Flaring y Atium), 13 (personaje), 17 (estructura), 19–20 (adversarios y paso rival); SRC-002 FAQ Player abilities & allies y Metal tokens & atium. Reset contable antes del robo es convención técnica de transacción, no orden adicional atribuido al reglamento. Se mantiene la devolución reglamentaria del Atium usado como pendiente de contrato; este bloqueo no introduce una regla casera.
