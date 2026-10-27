# Matriz inicial de reglas

Revisión: 2026-10-27. Fuentes SRC-001 y SRC-002 del [registro](README.md). Un número de página sin prefijo refiere a SRC-001; SRC-002 se identifica por sección. Las erratas expresas del editor prevalecen sobre el PDF.

Este es un inventario documental inicial, no un motor ejecutable ni una transcripción completa de las cartas. Todas las filas están **documentadas, sin implementar y sin prueba ejecutada**. Consultar el estado de cada DUD en [dudas](dudas.md): algunas ya están resueltas por SRC-002, otras siguen abiertas.

La referencia es inglesa. Los términos Burning, Flaring, Target, Funding, Savant, etc. conservan la identidad del original; la nomenclatura oficial española está pendiente de contraste.

## Reglas y cobertura prevista

Cada fila tiene un caso planificado `CAS-REG-nnn`; al implementar se sustituirá por el enlace a la prueba y su evidencia. Estos casos todavía no existen como tests. SPEC-001 cubre su inventario, no su implementación; [SPEC-002](../specs/002-modos-y-cooperativo/spec.md) añade aceptación de modos.

| ID | Comportamiento resumido | Fuente: página o sección | Modo | Caso previsto |
| --- | --- | --- | --- | --- |
| REG-001 | Preparación individual: personaje aleatorio, entrenamiento inicial, ocho metales, cuatro cartas Training del personaje y seis Funding; salud base 36. | 5, 7 | Todos | CAS-REG-001 |
| REG-002 | Solo en competitivo: segundo jugador +2 de salud; tercero y cuarto +4; cuarto además recibe un Boxing. | 5 | Competitivo | CAS-REG-002 |
| REG-003 | Barajar mercado y revelar seis cartas; suministros de Atium y Boxings accesibles. | 5 | Todos | CAS-REG-003 |
| REG-004 | Seleccionar al azar tres de las ocho misiones y colocar un marcador por jugador fuera de cada recorrido. | 5, 14 | Todos | CAS-REG-004 |
| REG-005 | Elegir primer jugador y robar cinco cartas iniciales por jugador; orden alrededor de la mesa. | 5, 19 | Todos | CAS-REG-005 |
| REG-006 | Con tres o cuatro jugadores competitivos, el último en el orden inicial recibe Target. | 5, 15 | Competitivo 3–4 | CAS-REG-006 |
| REG-007 | Cada jugador puede consultar su mano y descarte, pero no mirar el contenido de su mazo. | 6 | Todos | CAS-REG-007 |
| REG-008 | Salvo indicación contraria, las cartas obtenidas van inmediatamente al descarte del propietario. | 6 | Todos | CAS-REG-008 |
| REG-009 | Al final del turno se descartan cartas en juego salvo aliados y cartas restantes en mano; después se roban cinco. | 6, 17 | Todos | CAS-REG-009 |
| REG-010 | Cuando se necesita robar con el mazo vacío, se baraja el descarte para formar un nuevo mazo; si tampoco hay descarte, consultar DUD-006. | 6 | Todos | CAS-REG-010 |
| REG-011 | Las cartas eliminadas van a una pila común que cualquiera puede consultar. | 6, 10 | Todos | CAS-REG-011 |
| REG-012 | El límite inicial permite quemar una ficha de metal por turno; entrenamiento y efectos pueden ampliarlo. Al final del recorrido permite cuatro. | 7, 12 | Todos | CAS-REG-012 |
| REG-013 | Cada ficha ordinaria de metal se usa como máximo una vez por turno, incluso si se refresca durante ese turno. | 8 | Todos | CAS-REG-013 |
| REG-014 | Una carta de acción usada como metal proporciona uno de los dos de su pareja sin consumir el límite de fichas quemadas; no hay límite de cartas usadas así. | 7, 10 | Todos | CAS-REG-014 |
| REG-015 | Se puede quemar una ficha o carta como metal sin activar una acción directamente para otros efectos que observen metales quemados. | 7, 11 | Todos | CAS-REG-015 |
| REG-016 | Flaring usa una ficha no gastada este turno y no agotada, permite superar el límite normal, cuenta como quemar y deja la ficha agotada hasta refrescarla. Puede hacerse antes de agotar el límite normal. | 8; SRC-002 Metal tokens & atium | Todos | CAS-REG-016 |
| REG-017 | Descartar una carta permite refrescar un metal de su pareja; refrescar no cuenta como quemar ni activa por sí mismo aliados/personaje/Savant. | 8 | Todos | CAS-REG-017 |
| REG-018 | Refrescar no habilita una segunda utilización de la misma ficha dentro del turno; una ficha refrescada aún no usada sí puede usarse. | 8 | Todos | CAS-REG-018 |
| REG-019 | Atium como ficha es de un uso, vuelve al suministro al final del turno, ocupa capacidad de quemado y no puede hacer Flaring; como comodín cuenta también como el metal sustituido. | 8 | Todos | CAS-REG-019 |
| REG-020 | Una acción de Atium usada como metal puede alimentar cualquier carta; descartada para refrescar puede refrescar cualquier metal. El suministro físico de Atium no es un límite de reglas. | 8 | Todos | CAS-REG-020 |
| REG-021 | Las acciones requieren asignar el metal indicado; la habilidad se resuelve al activarla y no se repite por quemar más metales iguales en otro lugar. | 10 | Todos | CAS-REG-021 |
| REG-022 | Las habilidades adicionales de una acción exigen completar primero la superior y todos los metales adicionales del siguiente umbral. | 10 | Todos | CAS-REG-022 |
| REG-023 | Savant se activa cuando la carta se usa como metal; no por jugar sus acciones ni por descartarla para refrescar. | 10 | Todos | CAS-REG-023 |
| REG-024 | Las habilidades fuera de turno se usan en el momento indicado descartando la carta, sin pagar metal; esa carta ya no se utiliza para otro fin. | 10 | Todos | CAS-REG-024 |
| REG-025 | Los aliados permanecen entre turnos; derrotarlos los manda al descarte de su propietario. No se usan como metal ni para refrescar. | 11 | Todos | CAS-REG-025 |
| REG-026 | Los aliados observan los metales quemados, incluidos los usados en otras cartas; pueden activarse tras entrar con metal ya quemado. Algunos efectos son continuos. Riot: REG-047. | 11; SRC-002 Player abilities & allies | Todos | CAS-REG-026 |
| REG-027 | Funding solo aparece en los mazos iniciales, produce una moneda y carece de metal o coste de activación por metal. | 11 | Todos | CAS-REG-027 |
| REG-028 | Al inicio del turno se avanza un paso de entrenamiento; cartas y misiones también pueden avanzarlo. Las recompensas se desbloquean inmediatamente. | 12, 17 | Todos | CAS-REG-028 |
| REG-029 | Al final del entrenamiento, avanzar esa pista concede Atium; no la de misiones. | 12 corregida por SRC-002 Errata 2 | Todos | CAS-REG-029 |
| REG-030 | Los niveles I y III del personaje se activan una vez por turno. | 13; SRC-002 Player abilities & allies | Todos | CAS-REG-030 |
| REG-031 | La habilidad común de segundo nivel permite una vez por turno eliminar una acción recién comprada del mercado y resolver su efecto superior sin quemar metal. | 13 | Todos | CAS-REG-031 |
| REG-032 | Cada misión requiere doce puntos hasta la cima; los puntos ganados pueden repartirse entre recorridos. Alcanzar una recompensa la concede inmediatamente. | 14 | Todos | CAS-REG-032 |
| REG-033 | Las recompensas intermedias son de un uso; hay extras para el primero. La cima registra orden de llegada y su recompensa puede ser única o permanente; el extra del primero es único. | 14 | Todos | CAS-REG-033 |
| REG-034 | Quien no ha entrado en un recorrido no cuenta en él. El único marcador dentro es el más alto, no el más bajo; el primero en completar queda permanentemente más alto. Empates: DUD-005. | 14 | Competitivo/grupo | CAS-REG-034 |
| REG-035 | La salud de un personaje nunca supera 40; llegar a cero lo elimina. Sus cartas y marcadores de misión permanecen según las zonas indicadas por el reglamento. | 13, 15, 16 | Todos | CAS-REG-035 |
| REG-036 | Los puntos de combate se asignan al final del turno, primero a aliados y después a jugadores; se pueden repartir. No es obligatorio gastar todo el daño. | 15, 17 | Competitivo | CAS-REG-036 |
| REG-037 | Un aliado solo se derrota con un ataque que cubra su defensa; no conserva daño parcial. Al morir pasa inmediatamente al descarte de su propietario. | 15 | Todos | CAS-REG-037 |
| REG-038 | Defender impide atacar al propietario y a sus aliados sin Defender hasta resolver los defensores; respetar las restricciones de objetivos. | 9, 15, 16 | Todos según objetivo | CAS-REG-038 |
| REG-039 | Con Target en otro jugador, el daño que se asigne a jugadores va al portador; si pierde salud puede pasarlo después de resolver todo el daño del turno. Daño reducido a cero no permite pasarlo. | 9, 15, 17 | Competitivo 3–4 | CAS-REG-039 |
| REG-040 | Si el jugador activo porta Target, su daño restante tras atacar aliados se aplica íntegro a cada rival, con defensores y reducciones individuales. | 16; SRC-002 Combat | Competitivo 3–4 | CAS-REG-040 |
| REG-041 | Al eliminar al portador de Target, el atacante elige nuevo portador, incluido él mismo, y aplica el remanente; al quedar solo dos jugadores, se retira Target. | 16; SRC-002 Combat | Competitivo 3–4 | CAS-REG-041 |
| REG-042 | Se puede comprar durante la parte libre del turno con monedas suficientes; la carta va al descarte y el mercado se repone inmediatamente. Las monedas no pasan a turnos futuros. | 16, 17 | Todos | CAS-REG-042 |
| REG-043 | Un Boxing cuesta dos monedas y luego se devuelve al suministro para obtener una; persiste entre turnos y el suministro físico no lo limita. | 11, 16 | Todos | CAS-REG-043 |
| REG-044 | El competitivo termina al completar las tres misiones, quedar como único superviviente o activar Confrontation con cuatro Atium. | 17 | Competitivo | CAS-REG-044 |
| REG-045 | Sense limita avances de misión a lo largo de todo el turno, consumiendo su reducción contra los puntos que se obtengan; no afecta al Lord Ruler. | 9, 20 | Todos con excepción cooperativa | CAS-REG-045 |
| REG-046 | Seek permite usar el efecto superior de una acción del mercado hasta el coste indicado; no de un aliado. | 9 | Todos | CAS-REG-046 |
| REG-047 | Riot añade una activación superior de un aliado propio, máximo una por aliado/turno; no impide la normal. | SRC-002 Errata 3; sustituye p.9 | Todos | CAS-REG-047 |
| REG-048 | Soothe elimina cartas propias de mano, descarte o juego; eliminar una ya jugada no anula efectos que ya se obtuvieron. | 9, 10 | Todos | CAS-REG-048 |
| REG-049 | Pull mueve cartas del descarte a la parte superior del mazo; una compra recién obtenida ya está en el descarte. El texto permite descartar cartas de mano para usarlas con Pull. | 9 | Todos | CAS-REG-049 |
| REG-050 | Push elimina una carta del mercado y se repone inmediatamente. | 9 | Todos | CAS-REG-050 |
| REG-051 | Cloud funciona según el texto de la carta: reduce daño al jugador o evita una derrota de aliado; el daño consumido en protegerlo se pierde pero puede ser atacado otra vez con daño restante. | 9, 16 | Todos | CAS-REG-051 |
| REG-052 | Solo/cooperativo usa la preparación normal sin Target ni bonificaciones iniciales, más Lord Ruler con 48 de salud, mazo de 36 cartas y Dominación inicial uno. | 18 | Solo/cooperativo | CAS-REG-052 |
| REG-053 | La Dominación llega hasta seis; algunos pasos solo producen efectos. X usa el mayor valor visible actual, no la suma de valores anteriores. | 18 | Solo/cooperativo | CAS-REG-053 |
| REG-054 | En cooperativo no se ataca a compañeros ni a sus aliados; se permite ayudar a protegerlos con efectos como Cloud. | 19 | Cooperativo | CAS-REG-054 |
| REG-055 | Después del turno de cada jugador y de robar su nueva mano se roba y resuelve la carta superior del mazo del Lord Ruler. | 19 | Solo/cooperativo | CAS-REG-055 |
| REG-056 | Un adversario permanece frente a quien lo roba hasta ser derrotado; puede tener efecto permanente o efecto al final del turno de ese jugador antes de robar. El ejemplo recién robado empieza en el siguiente turno. | 19 | Solo/cooperativo | CAS-REG-056 |
| REG-057 | Un adversario tiene de uno a tres escudos, destruidos de izquierda a derecha con daño suficiente para cada escudo; X depende de Dominación. Los escudos destruidos permanecen marcados; se pueden destruir varios en un turno. | 19 | Solo/cooperativo | CAS-REG-057 |
| REG-058 | Cualquier jugador puede atacar a cualquier adversario; un efecto que mata un aliado destruye un escudo de adversario, no toda la carta. Excepción: REG-073. | 19; SRC-002 Solo & Co-op mode | Solo/cooperativo | CAS-REG-058 |
| REG-059 | Un edicto se resuelve en orden y luego se descarta: Dominación, efecto adicional si existe, curación y limpieza del mercado. Si alguien muere, se terminan sus efectos antes de continuar. | 20 | Solo/cooperativo | CAS-REG-059 |
| REG-060 | Cada avance de Dominación revela y resuelve de inmediato su efecto; algunos edictos dependen del número de jugadores. Al cambiar de cara se sigue el procedimiento del recorrido. | 20 | Solo/cooperativo | CAS-REG-060 |
| REG-061 | Cada misión no completada cura diez de salud al Lord Ruler, hasta 48; basta que un jugador alcance la cima para considerarla completada. | 20 | Solo/cooperativo | CAS-REG-061 |
| REG-062 | La limpieza por edicto elimina las dos posiciones del mercado marcadas en la carta y las repone inmediatamente. | 20 | Solo/cooperativo | CAS-REG-062 |
| REG-063 | Un eliminado no tiene más turnos ni provoca robos del Lord Ruler. Las condiciones por número de jugadores usan el nuevo total de supervivientes. | 20 | Solo/cooperativo | CAS-REG-063 |
| REG-064 | El equipo pierde si se agota el mazo del Lord Ruler o mueren todos; gana al bajar su salud a cero o usar cuatro Atium en Confrontation. Completar las tres misiones no da victoria directa. Última carta/simultaneidad: DUD-006. | 20 | Solo/cooperativo | CAS-REG-064 |
| REG-065 | En solitario se es más bajo solo tras entrar y antes de la primera recompensa; más alto tras recibir la recompensa más alta anterior a la final. Se reciben todas las recompensas de primero. | 20 | Solo | CAS-REG-065 |
| REG-066 | Los efectos Collective se reparten entre los jugadores según el efecto; con uno solo, ese jugador asume todo. La aplicación exacta depende del texto del edicto. | 20 | Solo/cooperativo | CAS-REG-066 |
| REG-067 | Una barra entre iconos representa elegir una alternativa, no obtenerlas todas. | 17 | Todos | CAS-REG-067 |
| REG-068 | Mercado agotado: barajar la pila eliminada como nuevo mazo. | SRC-002 Miscellaneous | Todos | CAS-REG-068 |
| REG-069 | Resolver efectos en orden; los recursos pasan a sus reservas del turno. | SRC-002 Action cards | Todos | CAS-REG-069 |
| REG-070 | Pueden omitirse habilidades y eliminaciones. | SRC-002 Action cards | Todos | CAS-REG-070 |
| REG-071 | El rival ataca al jugador o Defender, salvo excepción impresa. | SRC-002 Solo & Co-op mode | Solo/cooperativo | CAS-REG-071 |
| REG-072 | En solitario, efectos para otro jugador no recaen en ti. | SRC-002 Solo & Co-op mode | Solo | CAS-REG-072 |
| REG-073 | La segunda habilidad de Maelstrom destruye todos los escudos de todos los adversarios. | SRC-002 Solo & Co-op mode | Solo/cooperativo | CAS-REG-073 |
| REG-074 | 2X, 3X, etc. multiplican la Dominación actual. | SRC-002 Solo & Co-op mode | Solo/cooperativo | CAS-REG-074 |
| REG-075 | Los iconos de moneda no son Boxings; estos se identifican por texto. | SRC-002 Miscellaneous | Todos | CAS-REG-075 |

## Límites del inventario

No detalla el texto de las 82 cartas de mercado, las 40 iniciales, las ocho misiones, los cuatro personajes, las 36 cartas del rival ni todas las casillas de entrenamiento/Dominación: el reglamento muestra ejemplos, no un catálogo completo legible de todo el contenido. Ese material debe incorporarse y verificarse en tareas propias.

Los nombres de tipos de carta no implican que se haya contado cuántas acciones, aliados, edictos o adversarios únicos hay. Ver [componentes](componentes.md).

No se calcula aún porcentaje de fidelidad: el catálogo está incompleto y hay dudas que afectan a resultados.
