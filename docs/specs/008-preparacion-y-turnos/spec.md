# SPEC-008 — Preparación y turnos

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

DUD-002/003 impiden preparar una partida con contenido real hasta verificar el catálogo y su traducción. DUD-006 afecta el robo con mazo y descarte vacíos; T08.2 lo tratará explícitamente, sin inventar carta ni resultado. Las recompensas concretas de pistas no se conocen aún y bloquean la apertura automática de `libre` tras `inicio`. SRC-002 corrige la mención a Mission Track en la regla de Atium continuo y confirma entrenamiento en la primera ronda.

## T08.2b — Cierre interno de limpieza y entrega de fase

Servicio interno de autoridad, sin acción pública ni transición combate→limpieza. El llamador sólo sitúa `limpieza` tras resolver combate, Target, efectos previos y condiciones terminales (incluidas misiones); el servicio no comprueba victorias. Se comprueban bloqueos representables; esto no certifica efectos aún sin modelar ni crea un turno jugable.

- **AC-11:** aceptar exclusivamente snapshot válido, lifecycle en_curso, fase limpieza, plaza activa viva con salud positiva, número de turno positivo y sin resolución pendiente. Rechazar entradas inválidas, fuera de fase/turno y finalizadas sin cambiar snapshot/RNG. Rechazar como `regla_pendiente` counters del turno o flags de instancias propias no vacíos, adversarios frente al activo y Atium marcado usado: no hay contrato saldo/ficha de Atium ni efectos para resolverlos todavía.
- **AC-12:** componer limpieza de cartas y robo de cinco sobre copia, conservando aliados en juego. Reiniciar recursos del turno a cero, burned, ability_uses del activo y de sus instancias propias (contrato técnico: todos esos contadores expiran al terminar el turno propio), y used_this_turn de metales ordinarios. Conservar exhausted, Atium sin usar y saldo persistente, Boxings, salud, entrenamiento, burn_limit, flags vacíos, jugadores y zonas ajenas. Atium usado se bloquea, nunca se devuelve incorrectamente ni se borra su saldo por inferencia.
- **AC-13:** competitivo pasa al siguiente vivo en player_order, incrementa turn.number y queda en inicio; no abre libre ni ejecuta entrenamiento. Exigir al menos dos supervivientes y coherencia eliminated/salud, dejando finales aún no implementados bloqueados. Cooperativo/solo bloquea rival.health=0 como final pendiente; conserva activo y número, queda en rival después del robo sin tocar el rival. No ofrecer API para salir de rival ni para abrir libre.
- **AC-14:** fallo de robo por DUD-006 revierte también limpieza, contadores, fase y RNG; éxito determinista conserva invariantes. Probar siete configuraciones, orden con eliminados y vuelta, guardias, persistentes/privacidad y composición con recibos/reintentos/rollback P07. La API devuelve sólo ok/codigo; el adaptador futuro mapeará regla_pendiente a los códigos permitidos por P07 sin registrar una acción de producto.

Fuentes: SRC-001 pp.7–8 (fichas, Flaring y Atium), 13 (personaje), 17 (estructura), 19–20 (adversarios y paso rival); SRC-002 FAQ Player abilities & allies y Metal tokens & atium. Reset contable antes del robo es convención técnica de transacción, no orden adicional atribuido al reglamento. Se mantiene la devolución reglamentaria del Atium usado como pendiente de contrato; este bloqueo no introduce una regla casera.
