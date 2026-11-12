# T08.1b5 — Perfil competitivo de producto

Alcance documental para competitivo de 2 a 4 plazas según [DEC-027](../../decisiones.md#dec-027--competitivo-primero-lord-legislador-al-final). Base reglamentaria: [SRC-001](../../referencias/README.md#src-001--reglamento-aportado-por-el-usuario), pp. 3, 5, 12–17; [SRC-002, FAQ y erratas del editor](https://www.brotherwisegames.com/mistborn-deckbuilding-game-faq); [matriz REG](../../referencias/matriz-reglas.md). La evidencia en español procede de [SRC-004](../../referencias/entrenamiento-competitivo.md) y [SRC-005](../../referencias/README.md#src-005--escaneos-españoles-de-personajes-misiones-y-mercado).

## Composición y evidencia

| Componente | Requisito del manifiesto base | Evidencia y trabajo pendiente |
| --- | --- | --- |
| Personajes y Training | Cuatro candidatos: Kelsier, Marsh, Shan y Vin, cada uno ligado a sus cuatro copias físicas de entrenamiento. Asignación aleatoria sin repetir personaje. Dos personajes pueden compartir títulos de Training. Conservar el vínculo físico documentado sin deducir identidad por el título. | SRC-004 acredita las cuatro agrupaciones; SRC-005 identifica las cuatro caras de personaje. Falta revisar e incorporar las definiciones, sus vínculos y las habilidades de personaje. |
| Financiación y pista | Un diseño de Financiación con 24 copias físicas, seis por mazo, y un recorrido común con cuatro pistas físicas. El mazo asignado tiene diez cartas, cinco en mano y cinco en mazo tras el reparto. Una pista en posición inicial y ocho metales ordinarios por plaza. | SRC-004 acredita carta y pista de 21 posiciones, DEC-027 confirma las copias de Financiación. Faltan los registros P06 y sus vínculos; los fixtures de Funding y entrenamiento conservan su carácter de prueba. |
| Mercado | Multiconjunto exacto de 82 copias: 60 acciones y 22 aliados según el inventario. Son 65 diseños, 17 de ellos con dos copias. Barajar todas y revelar seis. | [Auditoría de mercado](../../referencias/auditoria-escaneos-2026-11-09.md) localiza diseños y cantidades. Falta revisión sistemática de caras, costes, tipos, textos, símbolos y efectos para el catálogo. Incluye Guardadora y Confrontación. |
| Misiones | Ocho definiciones distintas, una copia de cada una; sortear tres sin reposición. Progreso inicial fuera del recorrido. La cima cuesta doce puntos de misión; conservar casillas, premios, elegibilidad del primero y orden de llegada. | Los ocho diseños M1–M8 están localizados más abajo. T08.1b8–10 transcriben y validan las ocho misiones en un lote v2 de carga explícita. Su resolución y admisión en partida siguen pendientes. |

REG-001–006 fija además primer jugador elegido y orden de mesa, salud inicial 36/38/40/40 según plaza en el orden de turno, un Boxing para la cuarta y Target para la última sólo en partidas de tres o cuatro. Quedan disponibles los suministros de Atium y Boxings conforme a las reglas. En el manifiesto competitivo, `rival` es nulo.

La admisión de producto deberá comprobar las cantidades y relaciones exactas de la edición base contra definiciones P06 revisadas, incluso con sólo dos plazas. El constructor [GameSetup](../../../scripts/game/game_setup.gd) comprueba tamaños, tipos, revisión y cotas de inventario, además de la unicidad de los personajes y las misiones. Esas comprobaciones permiten, por ejemplo, combinaciones de Training de otro personaje o sustituciones en mercado que respeten las cotas. La autoridad deberá verificar el multiconjunto y los vínculos antes de invocar el constructor. El catálogo de [muestras](../../../data/cartas.json) carece de estas definiciones verificadas.

Para el nivel II, [DEC-031](../../decisiones.md#dec-031--criterios-de-la-edición-española-y-reglas-competitivas) resuelve DUD-008 a favor del texto español. Al comprar una Acción o un Aliado, se puede activar la habilidad desbloqueada una vez por turno. Se resuelve inmediatamente su capacidad primaria sin quemar metal y después se elimina la carta (REG-031).

## Localizadores de misiones

Posiciones según las hojas originales de SRC-005. Los códigos M1–M8 impresos sirven para cotejo editorial.

| Código | Nombre en la carta | Hoja y posición |
| --- | --- | --- |
| M1 | Cavernas Skaa | `misiones.1.png`, superior izquierda |
| M2 | Guarnición de Luthadel | `misiones.1.png`, inferior izquierda |
| M3 | Fortaleza Venture | `misiones.1.png`, superior derecha |
| M4 | Kredik Shaw | `misiones.2.png`, superior derecha |
| M5 | Pozos de Hathsin | `misiones.2.png`, inferior izquierda |
| M6 | Tejados de Luthadel | `misiones.1.png`, inferior derecha |
| M7 | Escondite de la Banda | `misiones.2.png`, superior izquierda |
| M8 | Cantón de la Ortodoxia | `misiones.2.png`, inferior derecha |

## Inicio y finales en producto

Reutilizar la transacción de autoridad de [T08.1b4](inicio-competitivo.md) como referencia para el avance único, las recompensas de pista, los recibos y la apertura atómica de `libre`. [CompetitiveStart](../../../scripts/game/competitive_start.gd) exige misiones ficticias de una casilla y hereda un registro cerrado que sólo ejecuta Funding y excluye definiciones con efectos sin soporte. El perfil español completo requiere una admisión propia para las reglas siguientes y la clasificación de las demás definiciones conforme se revisen.

- **Guardadora (Keeper).** SRC-005, `mercado.5.png` fila 4 izquierda, carta 32/82. La obligación vincula la plaza y la carta apartada, incluso si el aliado fue derrotado, según SRC-002 «Player abilities & allies». La autoridad lleva esa carta a la mano antes de avanzar en entrenamiento. Ambos pasos pertenecen a la misma transacción de inicio, sin ventana de acción ni publicación intermedia. Acreditar privacidad, liquidación única y rollback conjunto.
- **Misiones.** Registrar las recompensas por plaza, distinguiendo premio de casilla, extra del primero y cima única o permanente (REG-032/033). Guarnición de Luthadel concede 2 de combate y Fortaleza Venture 2 monedas en el mismo momento en que se completan, además de repetir el beneficio una vez en cada turno posterior. Cavernas Skaa aumenta de forma permanente la capacidad de quema y Tejados de Luthadel otorga avances de entrenamiento por premios de misión. Kredik Shaw añade una carta al robar una nueva mano en el ciclo de limpieza (SRC-001 pp. 6 y 17); el robo de Guardadora pertenece al inicio. La finalización de las tres misiones de una misma plaza debe determinarse con el recorrido real y el estado de llegada, incluidos los marcadores conservados tras la eliminación.
- **Supervivencia.** Registrar el desenlace al quedar una sola plaza viva. La apertura debe rechazar estados sin continuidad acreditada y conservar los límites de salud y eliminación de REG-035.
- **Confrontación (Confrontation).** SRC-005, `mercado.6.png` fila 3 derecha, carta 4/82. El final depende de resolver su efecto de victoria con cuatro Atium en total, según REG-044. El avance puede dejar cuatro fichas disponibles y continuar el turno. La autoridad de producto deberá distinguir ambos casos mediante el evento confirmado y preservar el resultado al restaurar.

En el estado inicial recién preparado por la autoridad, los premios de misión y las obligaciones de cartas aún carecen de origen: las misiones están a cero y todavía no se ha jugado. Esa procedencia es útil para diseñar una comprobación de primer inicio. En turnos posteriores o al restaurar, la continuidad se acredita con el estado confirmado y sus eventos, incluido el estado privado pertinente. La validación estructural por sí sola deja esas condiciones abiertas.

## Posición en una misión competitiva

Contar únicamente los marcadores que ya entraron en el recorrido. Antes de la cima, todos los empatados en la posición mayor cumplen la condición de más alto y todos los empatados en la menor cumplen la de más bajo. Si hay al menos dos marcadores válidos y todos comparten la misma posición antes de la cima, cumplen ambas condiciones. Un único marcador dentro sólo cumple la de más alto. Tras completar la misión, la llegada posterior de otro cubo a la cima no le otorga la condición de más alto: la conserva en exclusiva el primer finalista. El premio de primero sigue ligado al orden de llegada. Aplican REG-034 y DEC-031.

## Comprobaciones para la integración posterior

| Caso | Resultado exigido |
| --- | --- |
| PERF-01 · Manifiesto | Para 2, 3 y 4 plazas, admitir el manifiesto completo con los vínculos correctos. Rechazar un Training de otro personaje, cambios de multiplicidad en mercado, duplicados de misión y contenido sin revisión antes de preparar el estado. |
| PERF-02 · Preparación | Con semilla reproducible, verificar los mazos personales, seis cartas en mercado, tres misiones distintas, orden, salud, Boxing y Target. La mano se mantiene privada. |
| PERF-03 · Obligaciones y recompensas | Admitir la restauración en `libre` con la carta de Guardadora reservada para el próximo turno de su plaza. En ese inicio, devolverla una sola vez antes de avanzar en entrenamiento, aunque el aliado haya sido derrotado. Confirmar juntos robo, avance y apertura. Si falla el avance, la carta sigue apartada. Probar privacidad y recibos al reintentar o restaurar. Probar la nueva mano de Kredik Shaw y que M2/M3 conceden el beneficio al completar y una vez en cada turno posterior, sin duplicarlo al reenviar. |
| PERF-04 · Continuidad | Cubrir victoria por tres misiones, único superviviente y Confrontación ya resuelta, y el caso positivo de cuatro Atium disponibles sin activación. Impedir abrir `libre` si queda por liquidar una obligación de ese inicio, hay un final pendiente o la procedencia impide comprobarlos. Probar rollback íntegro y reenvío idempotente. |
| PERF-05 · Nivel II | Tras desbloquearlo, admitir tanto Acción como Aliado, resolver la capacidad primaria antes de eliminar la carta y respetar la activación opcional una vez por turno sin metal. |
| PERF-06 · Posición en misión | Cubrir empate en el máximo, en el mínimo y en una posición intermedia. Con sólo dos cubos en la misma posición antes de la cima, ambos cumplen los dos extremos. Excluir los cubos sin iniciar y comprobar la excepción de un único marcador. Tras varias llegadas a la cima, únicamente el primero cuenta como más alto y su premio se concede una sola vez. |

La [transcripción de M1–M8](../../referencias/misiones-competitivas.md) reúne posiciones, símbolos y recompensas para la integración. El [lote v2 de carga explícita](catalogo-misiones.md) ya está validado; el [contrato de avance](avance-misiones.md) especifica su futura resolución. La admisión de producto requiere completar las restantes definiciones y reglas aplicables.
