# E1 — Mazo inicial, personajes y pista

Registro de autoría para el ensayo competitivo. Los originales SRC-004/005 están en `C:/Users/pbard/Pictures/Digitalizaciones/cartas_personajes` y permanecen fuera de Git y del paquete. La lectura visual se contrasta con [SRC-001](../../referencias/README.md#src-001--reglamento-aportado-por-el-usuario), pp. 5, 7, 10–13 y 17, y [SRC-002](https://www.brotherwisegames.com/mistborn-deckbuilding-game-faq), secciones Errata, Player abilities & allies y Miscellaneous. La huella acredita el fichero, no la corrección de cada icono. Los identificadores son propuestos como estables para el lote; no son títulos editoriales.

## Fuentes locales y admisión

| Fuente | SHA-256 | Contenido y localizador |
| --- | --- | --- |
| `personajes.png` | `db0356c5fc95d1bf0178ff0ddf2d240ec87dbf24e4b38e34cf5c3bb95c96c952` | Cuatro caras: Kelsier arriba izquierda, Vin arriba derecha, Shan abajo izquierda y Marsh abajo derecha. |
| `kelsier/entrenamiento_kelsier.png` | `2054e91a48e8c59692e971d284bb84930ca83d972fc1071678cee566819e3f4b` | Cuatro cartas de Kelsier, filas 1–4. |
| `marsh/entrenamiento_marsh.png` | `7000ec32f416bcf4444a5bd56293e7bb509c54cab0f4d497327df8f631985d1b` | Cuatro cartas de Marsh, filas 1–4. |
| `shan/entrenamiento_shan.png` | `2176decdd2842a1da701969ece93993dceef3acb5c87dfcccaf7d971b2342bd6` | Cuatro cartas de Shan, filas 1–4. |
| `vin/entrenamiento_monedas.png` | `edb5d4838bad62a3779bf4c36553c413df050ceb05b6ae3dc6c1205fe7d2cb01` | Vin: cuatro cartas en columna izquierda; Financiación arriba derecha. |
| `panel_niveles.png` | `c4ff1de62cf9a7a9283f1e4b24b232e44d071a7ad8c8de92980e51ab917eaced` | Pista: 21 huecos, 0–20 desde la flecha. |

Las seis huellas se comprobaron sobre los archivos locales el 2026-11-23. Estado de distribución de **texto, iconos e ilustración: pendiente** por componente; no se infiere permiso de la caja ni de un escaneo. La ejecución se evalúa por ruta alcanzable y sigue separada de la lectura. No existe un manifiesto de producto admitido.

El [borrador de autoría](../../../data/inicio_competitivo.json) contiene 22 definiciones y seis fuentes; todas conservan `revision.estado = borrador`. Los originales se copiaron sólo a `evidencia_local/` ignorado para comprobar huellas y carga de autoría. Pese al nombre del campo de esquema, `texto_original` son **frases funcionales redactadas para este proyecto** a partir de los iconos y reglas: cantidades, recursos y condiciones, sin redacción editorial reproducida. Los nombres de Training son rótulos descriptivos propios; los personajes se identifican por sus nombres. `ruta_imagen` es nula en las 22 entradas; el JSON no contiene iconos ni ilustraciones. Esta autoría propia es la base para versionar el **fixture técnico**; la dimensión de distribución del contenido final sigue pendiente por componente, y publicar este ensayo no concede derechos sobre texto, iconos o arte editoriales. El campo `vinculos` liga propietarios y entrenamientos, pero la validación de esquema por sí sola no certifica el multiconjunto exacto de cada mazo. Los umbrales I/II/III viven en la regla de pista y aún no se aplican por leer el JSON.

## Identidad y composición

| ID de personaje | Cara | Entrenamientos propios, en orden físico de fila | Capacidad de nivel I al quemar metal propio |
| --- | --- | --- | --- |
| `kelsier` | superior izquierda | `kelsier_estano`, `kelsier_cobre`, `kelsier_cinc`, `kelsier_acero` | Acero: 2 combate. |
| `marsh` | inferior derecha | `marsh_bronce`, `marsh_hierro`, `marsh_peltre`, `marsh_laton` | Bronce: 1 punto de misión. |
| `shan` | inferior izquierda | `shan_cinc`, `shan_estano`, `shan_cobre`, `shan_acero` | Cinc: 2 monedas. |
| `vin` | superior derecha | `vin_bronce`, `vin_hierro`, `vin_laton`, `vin_peltre` | Peltre: 1 salud, 1 combate y 1 moneda. |

Cada personaje y cada carta de entrenamiento tiene una copia física; la pista tiene cuatro copias. Financiación es un diseño con 24 copias: seis por mazo personal. Preparar cuatro entrenamientos **del personaje asignado** más seis Financiación; barajar y robar cinco. Los cuatro personajes son distintos. Dos cartas con el mismo nombre de metal pero distinto propietario no son intercambiables.

La habilidad II común, al comprar una Acción o Aliado, puede resolver de inmediato la capacidad primaria y eliminar esa carta una vez por turno, sin quemar metal, según [DEC-031](../../decisiones.md#dec-031--criterios-de-la-edición-española-y-reglas-competitivas) y FAQ; queda condicionada a una compra real en E2. La habilidad III común de Atium concede 3 combate y 3 puntos de misión al quemarlo, una vez por turno; se activa también si el Atium sustituye al metal de otra carta. Su integración requiere una ruta de quemar Atium. Ninguna se considera ejecutada por estar descrita aquí.

## Efectos visibles de entrenamiento

Cada entrada usa como ID el de la tabla de personaje. El metal indicado es el metal impreso sobre el recuadro de capacidad primaria; la pareja de la ampolla se debe conservar por separado al construir la definición. Los iconos se describen en recursos del turno; no son texto ejecutable.

| ID | Primaria, tras quemar el metal indicado | Fuente |
| --- | --- | --- |
| `kelsier_estano` | 2 puntos de misión | hoja Kelsier, fila 1 |
| `kelsier_cobre` | 2 combate y 1 moneda | hoja Kelsier, fila 2 |
| `kelsier_cinc` | 1 punto de misión y 1 moneda | hoja Kelsier, fila 3 |
| `kelsier_acero` | 2 combate y 1 moneda | hoja Kelsier, fila 4 |
| `marsh_bronce` | 2 puntos de misión | hoja Marsh, fila 1 |
| `marsh_hierro` | 2 combate y 1 moneda | hoja Marsh, fila 2 |
| `marsh_peltre` | 2 combate y 1 moneda | hoja Marsh, fila 3 |
| `marsh_laton` | 1 punto de misión y 1 moneda | hoja Marsh, fila 4 |
| `shan_cinc` | 1 punto de misión y 1 moneda | hoja Shan, fila 1 |
| `shan_estano` | 2 puntos de misión | hoja Shan, fila 2 |
| `shan_cobre` | 2 combate y 1 moneda | hoja Shan, fila 3 |
| `shan_acero` | 2 combate y 1 moneda | hoja Shan, fila 4 |
| `vin_bronce` | 2 puntos de misión | hoja Vin, izquierda fila 1 |
| `vin_hierro` | 2 combate y 1 moneda | hoja Vin, izquierda fila 2 |
| `vin_laton` | 1 punto de misión y 1 moneda | hoja Vin, izquierda fila 3 |
| `vin_peltre` | 2 combate y 1 moneda | hoja Vin, izquierda fila 4 |

La [lectura anterior](../../referencias/entrenamiento-competitivo.md) detalla los símbolos y las marcas de pista. La pista usa los índices 0, 3, 9 y 15 para capacidad de quema; 5/8/13 para niveles I/II/III; 11 y 16 para Atium; 20 para Atium continuo. La FAQ corrige el premio al llegar al final: cada avance posterior, incluido el inicio de turno, concede una ficha adicional. [TrainingAdvance](../../../scripts/game/training_advance.gd) ya ejecuta esa secuencia con un descriptor de ensayo, sin conectar estas cartas reales.

## Puertas de E1

Antes de afirmar fidelidad de cada definición, cotejar la pareja de metales de la ampolla, coste no aplicable, fuente/localizador y efectos con revisor independiente. Antes de marcar ejecución, probar preparación y rechazo de vínculos falsos, uso de metal, aplicación/omisión de primaria, nivel desbloqueado, límite por turno, restauración y rollback en el perfil real de ensayo. La habilidad II y las rutas de mercado permanecen abiertas hasta E2. La admisión de producto y distribución requieren sus evidencias separadas según [T08.1b30](admision-contenido-final.md).

## Contrato de catálogo del lote

La siguiente ampliación de gramática usa versión 5 sólo cuando se solicita expresamente. Mantiene v1–v4 tal como están. En v5, una definición `entrenamiento` puede reservar puntos de misión propios en `al_jugar`, igual que una `accion` v3, siempre que la condición de metal asignado sea uno de sus dos metales. Una definición `personaje` puede reservar puntos de misión propios en `metal_quemado`; en esa condición admite Atium además de los ocho ordinarios. Atium en una `accion` o `entrenamiento` no se convierte en un metal de su ampolla. La gramática valida estructura, no ejecuta efectos ni acredita la carta. Rechazar misión para otros tipos/momentos, objetivos ajenos, metales fuera de esa condición y versiones antiguas. Las definiciones de nivel II siguen en borrador hasta contratar el programa de compra en E2.

## Ensayo de ejecución E1

El ensayo admite un **catálogo compuesto de prueba**: las 22 definiciones anteriores, promovidas sólo en memoria del fixture, más mercado y misiones ficticios declarados. La variante de ensayo omite exclusivamente la habilidad II pendiente de cada personaje y sustituye las casillas `pendiente` de la pista por `sin_efecto` en esa copia de memoria; `TrainingAdvance.PANEL` sigue siendo el único ejecutor de sus marcas reales. Estas sustituciones y el contenido íntegro de la variante forman parte de su identidad. No se escriben al JSON ni se presentan como producto o gramática ejecutable de pista. La autoridad comprueba el vínculo exacto antes de `GameSetup` y conserva el estado de autoridad y las zonas privadas según P07; `turn_resources` es público en la proyección P07. El inicio avanza la pista una vez con `TrainingAdvance` y abre `libre`; el primer turno también avanza. Para probar I/III sin simular una limpieza inexistente, el fixture dispone de checkpoints de autoridad explícitos con pista/Atium, validados al restaurar; esos checkpoints no acreditan un turno que llegue a ellos jugando. Se admiten solamente: jugar Financiación aplicando u omitiendo su moneda; jugar una Training aplicando/omitiendo su primaria con metal compatible de ficha ordinaria, Atium disponible o una carta propia de la pareja usada como metal; y activar nivel I/III según umbral y metal quemado, una vez por turno. Vin no supera 40 salud. La reserva de misión no asigna automáticamente puntos a una misión; combate y monedas permanecen en la reserva del turno.

El uso como metal y la primaria son rutas distintas: una carta usada como metal se mueve a juego sin ejecutar su propia primaria. Cada mazo inicial tiene una sola Training por pareja; para probar combustible de carta compatible, un checkpoint de ensayo puede añadir **una Acción ficticia propia** de la pareja, inerte y fijada en la identidad del fixture. No implica compra ni altera la composición inicial de seis Financiación y cuatro Training. Un token ordinario solo se usa una vez por turno y consume capacidad de quema; Atium no puede agotarse para eludir esa capacidad. Si una acción o restauración excede recursos, usa un metal/carta ajeno, repite una capacidad, intenta nivel bloqueado o contiene estado incompatible, se rechaza íntegramente. El motor no interpreta `texto_original`, no activa II, no compra ni abre limpieza, combate o finales. Pruebas de autoridad deben cubrir preparación 2/3/4, inicio, las 16 primarias, las cuatro firmas, Atium y restauración/reenvío sin duplicación. Lo no ejecutado mantiene E1 abierto.
