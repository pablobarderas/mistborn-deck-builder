# Originales españoles de entrenamiento competitivo

Revisión del 2026-11-11 para T08.1b. [SRC-004](README.md#src-004--escaneos-españoles-de-entrenamiento) identifica los originales. Los cinco PNG miden 4960 × 7015 píxeles y las caras relevantes son legibles. La numeración de filas se refiere a los escaneos tal como están guardados, de arriba abajo.

| Archivo relativo a `cartas_personajes` | SHA-256 |
| --- | --- |
| `kelsier/entrenamiento_kelsier.png` | `2054E91A48E8C59692E971D284BB84930CA83D972FC1071678CEE566819E3F4B` |
| `marsh/entrenamiento_marsh.png` | `7000EC32F416BCF4444A5BD56293E7BB509C54CAB0F4D497327DF8F631985D1B` |
| `shan/entrenamiento_shan.png` | `2176DECDD2842A1DA701969ECE93993DCEEF3ACB5C87DFCCCAF7D971B2342BD6` |
| `vin/entrenamiento_monedas.png` | `EDB5D4838BAD62A3779BF4C36553C413DF050CEB05B6AE3DC6C1205FE7D2CB01` |
| `panel_niveles.png` | `C4FF1DE62CF9A7A9283F1E4B24B232E44D071A7AD8C8DE92980E51AB917EACED` |

## Cartas visibles

Cada metal de la tabla completa el título «Entrenamiento de…» y coincide con el metal impreso sobre su recuadro de efecto. Las cifras se listan en el orden de impresión con la carta orientada para lectura. Moneda corresponde al icono circular dorado, combate al rojo de armas cruzadas y cuadrado al icono beige numerado. El cuadrado representa puntos de misión según la leyenda de SRC-001 pp. 14 y 17. La capa negra es el icono de avance de entrenamiento.

| Personaje | Fila 1 | Fila 2 | Fila 3 | Fila 4 |
| --- | --- | --- | --- | --- |
| Kelsier | Estaño: cuadrado 2 | Cobre: combate 2, moneda 1 | Cinc: cuadrado 1, moneda 1 | Acero: combate 2, moneda 1 |
| Marsh | Bronce: cuadrado 2 | Hierro: combate 2, moneda 1 | Peltre: combate 2, moneda 1 | Latón: cuadrado 1, moneda 1 |
| Shan | Cinc: cuadrado 1, moneda 1 | Estaño: cuadrado 2 | Cobre: combate 2, moneda 1 | Acero: combate 2, moneda 1 |
| Vin | Bronce: cuadrado 2 | Hierro: combate 2, moneda 1 | Latón: cuadrado 1, moneda 1 | Peltre: combate 2, moneda 1 |

Las cuatro cartas de Vin están en la columna izquierda. La carta adicional de la esquina superior derecha se titula **Financiación** y muestra una moneda, sin metal impreso como requisito. El escaneo contiene un ejemplar de cada diseño mostrado. La preparación reglamentaria asigna cuatro cartas propias y seis Financiación a cada personaje (SRC-001 p. 5). La moneda no representa un Boxing (SRC-002, «Miscellaneous», REG-075).

## Pista del panel

Se observan 21 huecos desde la flecha de «Entrenamiento» hasta acero. Para localizar cada marca se numera el primer hueco como 0, coherente con el índice de preparación de T08.1a. En el PNG original la flecha está abajo y el recorrido sube. Las marcas se leen por la línea impresa que las une a su hueco, no por la columna de metal.

| Índices desde la flecha | Marca impresa |
| --- | --- |
| 0, 3, 9, 15 | Llama `+1` |
| 5, 8, 13 | Niveles I, II y III, respectivamente |
| 11, 16 | Ficha de Atium |
| 20 | Entrenamiento = ficha de Atium |
| 1, 2, 4, 6, 7, 10, 12, 14, 17, 18, 19 | Sin marca de recompensa |

SRC-001 pp. 12 y 17 identifica el avance al inicio del turno, el aumento de capacidad de quema y el desbloqueo de niveles. La [FAQ oficial SRC-002](https://www.brotherwisegames.com/mistborn-deckbuilding-game-faq) confirma entrenamiento en la primera ronda y corrige la recompensa continua: una vez alcanzado el final, cada avance posterior de entrenamiento otorga una ficha de Atium, incluido al comenzar el turno. La marca inicial representa la capacidad inicial de una ficha, ya registrada por la preparación. El avance de inicio del primer turno no vuelve a conceder esa capacidad. El nivel se desbloquea al alcanzarlo; su activación se trata aparte (REG-028–031).

## Paso siguiente para T08.1b

Especificar y probar avance de inicio, aumentos, desbloqueos y Atium con esta pista, incluyendo cruce de casillas y avances posteriores al final. La ejecución de las habilidades de personaje se trata aparte y el desbloqueo tardío se rige por DEC-032. La incorporación de cartas españolas, su gramática de efectos, la validación del perfil completo y la apertura de `libre` pertenecen a entregas posteriores. Los PNG originales están fuera de Git y este documento conserva evidencia de lectura, no definiciones ejecutables.
