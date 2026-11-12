# Misiones de la edición española

Borrador documental de T08.1b8. Se han cotejado los ocho diseños de SRC-005, una copia física por diseño. Los códigos M1–M8 son los impresos en las cartas. Las hojas originales y sus huellas están identificadas en [SRC-005](README.md#src-005--escaneos-españoles-de-personajes-misiones-y-mercado).

## Recorridos y recompensas

La posición es el número de puntos acumulados en ese recorrido. En 0, el cubo está sobre la ilustración y queda fuera de la pista. La franja inferior, con el borde en ángulo, es la casilla 1. Se cuenta de abajo arriba hasta la casilla 11 y se llega a la cima en 12. Las cuatro ranuras de la cima registran orden de llegada de izquierda a derecha. Las casillas intermedias omitidas de la tabla carecen de premio.

Cada premio intermedio se obtiene una vez por plaza al llegar a la casilla. El extra marcado «1.º» se suma al premio normal y lo recibe una sola vez la primera plaza que alcanza esa posición. En la cima, el premio normal puede ser único o permanente y el extra del primero es siempre único. Referencia de lectura en SRC-001, p. 14, con Pozos de Hathsin como ejemplo anotado.

| Código y nombre | Hoja y posición | Casillas con premio normal | Extra del primero en esas casillas | Premio normal de la cima | Extra del primero en la cima |
| --- | --- | --- | --- | --- | --- |
| M1 · Cavernas Skaa | `misiones.1.png`, superior izquierda | 5 y 9, refrescar 1 metal | Refrescar 1 metal adicional en cada una | Permanente, capacidad de quemar 1 ficha de metal adicional por turno | Refrescar todos los metales agotados |
| M2 · Guarnición de Luthadel | `misiones.1.png`, inferior izquierda | 4, 1 combate. 7, 2 combate. 10, 3 combate | Derrotar a 1 Aliado en juego en cada una | Permanente, 2 combate cada turno | 1 combate |
| M3 · Fortaleza Venture | `misiones.1.png`, superior derecha | 4, 6, 8 y 10, 1 moneda | 1 moneda adicional en cada una | Permanente, 2 monedas cada turno | 3 monedas |
| M4 · Kredik Shaw | `misiones.2.png`, superior derecha | 4 y 8, robar 1 carta | Robar 1 carta adicional en cada una | Permanente, +1 carta al robar una nueva mano | Robar 2 cartas |
| M5 · Pozos de Hathsin | `misiones.2.png`, inferior izquierda | 4, 1 moneda. 8, 2 combate | 4, 1 moneda. 8, curar 2 | Una vez, 1 Atium | 1 Atium |
| M6 · Tejados de Luthadel | `misiones.1.png`, inferior derecha | 6, avanzar 1 en entrenamiento | Avanzar 1 adicional en entrenamiento | Una vez, avanzar 1 en entrenamiento | Avanzar 1 en entrenamiento |
| M7 · Escondite de la Banda | `misiones.2.png`, superior izquierda | 6, curar 4 | Curar 2 | Una vez, curar 6 | Curar 2 |
| M8 · Cantón de la Ortodoxia | `misiones.2.png`, inferior derecha | 5 y 9, eliminar 1 carta | Eliminar 1 carta adicional en cada una | Una vez, eliminar hasta 4 cartas | Eliminar 1 carta adicional |

## Lectura de los símbolos y reglas aplicables

- Los iconos de moneda, combate, curación, entrenamiento, robo, refresco, quema adicional y eliminación corresponden a la leyenda de SRC-001, p. 17. El Atium de M5 coincide con el ejemplo anotado de p. 14. Las monedas de M3 y M5 alimentan la reserva del turno, según SRC-002, «Miscellaneous». El combate se suma a su reserva según «Combat».
- En M1 se refrescan fichas agotadas. Una ficha ya usada este turno sigue usada tras refrescarla y Atium no se agota. El premio permanente incrementa la capacidad de quema. Fuentes en SRC-001, pp. 8, 12 y 17, y SRC-002, «Metal tokens & atium».
- M2 distingue el combate que entra en la reserva y el premio escrito de derrota de un Aliado. La selección y las reacciones a la derrota quedan para el contrato de resolución. Por [DEC-031](../decisiones.md#dec-031--criterios-de-la-edición-española-y-reglas-competitivas), M2 y M3 conceden su beneficio permanente al completar y una vez en cada turno posterior.
- En M4, el robo de dos cartas del primer finalista se concede al llegar. El premio permanente aumenta en una carta la nueva mano que se roba durante la limpieza. El ciclo personal aplica [DEC-032](../decisiones.md#dec-032--desbloqueo-tardío-robo-personal-y-finales-del-rival) si se agotan mazo y descarte. Fuentes en SRC-005 M4 y SRC-001, pp. 6, 14 y 17.
- En M8, la eliminación puede omitirse. Se eligen cartas propias de la mano, el descarte o el área de juego. El extra del primero es adicional al máximo de cuatro de la recompensa normal. Fuentes en SRC-001, pp. 6, 9 y 17, y SRC-002, «Action cards».
- Los puntos de misión pueden repartirse entre recorridos durante el turno. Los negativos reducen la reserva y dejan intactas las posiciones. En competitivo, DEC-031 determina los empates y el primer finalista conserva la posición más alta aunque lleguen más cubos a la cima. Una misma plaza gana al completar las tres misiones de la partida aunque otra plaza se haya adelantado en alguna. Fuentes en SRC-001, pp. 14 y 17, y SRC-002, «Missions». Las reglas de posición propias de solitario están en REG-065. [Matriz de reglas](matriz-reglas.md).

## Encaje con P06

[P06](../contrato-catalogo-v1.md#rasgos-y-recorridos) admite casillas ordenadas y primitivas para monedas, combate, curación, robo, Atium y avance de entrenamiento. Hace falta representar por separado el premio normal y el extra del primero, y distinguir en la cima el efecto único, los efectos permanentes y sus momentos de aplicación. La gramática actual también necesita expresar la selección de fichas agotadas y el refresco de todas, el aumento de capacidad de quema, la derrota directa de un aliado y la eliminación opcional de hasta una cantidad desde varias zonas.

El lote queda en este borrador. Los dos escaneos de SRC-005 ya se han cotejado y sus originales siguen en la digitalización externa. Para incorporar el lote al catálogo, el siguiente trabajo propuesto es especificar la representación de recorridos y premios, con casos para primera llegada, reenvío y cima, y cómo registrar esos mismos escaneos mediante la ruta `res://` que exige P06.
