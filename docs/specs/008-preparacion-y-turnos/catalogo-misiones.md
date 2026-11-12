# Contrato de catálogo para M1–M8

T08.1b9 especifica la ampliación de [P06 v1](../../contrato-catalogo-v1.md) necesaria para incorporar las ocho [misiones cotejadas](../../referencias/misiones-competitivas.md). Los ejemplos describen datos para un futuro validador. La carga de producto y la resolución de misiones son entregas posteriores.

## Versión y admisión

El nuevo lote usa el sobre P06 con `version_esquema: 2` e `id_catalogo: mistborn_es_misiones`. El validador seleccionará el contrato por la versión del documento completo. La rama v1 conserva su gramática, sus comprobaciones y la carga inicial de `data/cartas.json`. En v2, los tipos ajenos a misión mantienen su forma de carta v1 y se aplica la comprobación de fuentes físicas de v2. Se rechazan versiones desconocidas y mezclas de formas de casilla entre versiones.

Las ocho definiciones tendrán los IDs estables `mision_m1` a `mision_m8`, tipo `mision`, una copia cada una y coste de compra nulo. El lote se abre explícitamente por su ruta en una comprobación de catálogo separada de la instancia de arranque de `Database`. Validar el lote admite su contenido al conjunto de definiciones verificadas para ese documento. La futura autoridad de producto tendrá una puerta adicional para comprobar el manifiesto, los resolutores disponibles y la identidad del catálogo. Funding exige efectos inertes en las casillas e inicio competitivo exige un recorrido de una casilla. Las misiones del lote quedan fuera de ambos perfiles.

El contrato de datos no cambia la versión de los snapshots. Antes de integrar el resolutor en partida, se deberá fijar la compatibilidad con snapshots anteriores y ligar la identidad de autoridad al contenido validado. Las rutas locales de un PC no deben determinar el resultado de una partida.

## Recorrido y premios

`rasgos.recorridos` contiene exactamente un recorrido con ID `principal` y doce casillas en orden, con IDs `p01` a `p12`. La posición 0 es exterior al recorrido. Las cuatro ranuras físicas de la cima representan el orden de llegada a `p12`. El array `habilidades` queda vacío.

Cada casilla contiene exactamente `id`, `efectos` y `primero`. Las dos listas contienen, respectivamente, los efectos inmediatos para cada plaza que alcanza la casilla y los efectos inmediatos adicionales para la primera plaza que la alcanza. Una lista vacía indica ausencia de premio. En `p01`–`p11`, el extra exige que haya premio normal. En `p12` se añade el campo obligatorio `permanente`, que es nulo para una cima de premio único. En esa casilla debe haber premio normal en exactamente una forma, `efectos` no vacío o `permanente` no nulo. `primero` conserva su significado y se concede una sola vez.

Ejemplo de cima de Guarnición de Luthadel, M2.

```json
{
  "id": "p12",
  "efectos": [],
  "primero": [{"op": "ganar", "recurso": "ataque", "cantidad": 1, "objetivo": "propio"}],
  "permanente": {"tipo": "cada_turno", "recurso": "ataque", "cantidad": 2}
}
```

El premio permanente corresponde a la plaza que llega a la cima. Sus formas son cerradas y `cantidad` es un entero positivo.

| Forma de `permanente` | Aplicación |
| --- | --- |
| `{"tipo":"capacidad_quema","cantidad":1}` | M1 aumenta la capacidad de quema desde que se completa. |
| `{"tipo":"cada_turno","recurso":"ataque","cantidad":2}` o recurso `recursos` | M2 y M3 conceden combate y monedas respectivamente al completar y una vez en cada turno propio posterior, según DEC-031. El contrato del resolutor concretará el punto de aplicación en esos turnos. |
| `{"tipo":"mano_nueva","cantidad":1}` | M4 aumenta el número de cartas al robar la nueva mano en limpieza. Su extra del primero es un robo inmediato independiente. |

## Operaciones inmediatas

Las listas contienen de cero a 64 operaciones. Se reutilizan de v1 `ganar` (sólo `recursos`, `ataque` o `atium`), `robar`, `curar` y `avanzar` (sólo pista `entrenamiento`), todas con objetivo `propio`. El orden de una lista es el orden de sus operaciones. Se conserva `pendiente` para borradores y bloquea la revisión verificada. Las listas de misión admiten además estas formas exactas.

| Operación | Forma y significado |
| --- | --- |
| Refrescar uno o todos, M1 | `{"op":"refrescar_agotados","cantidad":1}` o `{"op":"refrescar_agotados","cantidad":"todos"}`. Se refiere a fichas ordinarias agotadas de la plaza. Refrescar conserva la marca de uso del turno. |
| Derrotar un aliado, M2 | `{"op":"derrotar_aliado_en_juego"}`. Modela el premio de derrota directa impreso. Las reglas de selección, reacciones y el tratamiento por modo quedan en el resolutor. |
| Eliminar cartas, M8 | `{"op":"eliminar_propias","maximo":1}` o `maximo: 4` para el premio normal de cima. Permite elegir desde cero hasta el máximo de cartas propias entre mano, descarte y juego. El extra del primero tiene su propio máximo de uno. |

Las cantidades numéricas de estas operaciones son enteros positivos. Los ejemplos reflejan los valores del lote. La comprobación de lote exige los valores y localizadores exactos de la transcripción, además de los tipos y restricciones del esquema. Las listas vacías sólo tienen el significado indicado para este recorrido v2. Las listas de efectos v1 conservan su mínimo de un elemento.

## Escaneos y verificación del lote

Las fuentes físicas v2 llevan `sha256` obligatorio como 64 dígitos hexadecimales en minúscula, junto con los campos P06. La validación de una fuente física comprueba la ruta segura `res://`, existencia y coincidencia del SHA-256 de sus bytes, una vez por fuente declarada. Error de lectura, archivo ausente o huella distinta rechazan el documento completo, también si sus cartas son borradores. Una misión verificada debe referenciar una fuente física v2 válida.

| ID de fuente | Ruta local prevista | Original |
| --- | --- | --- |
| `src_005_misiones_1` | `res://evidencia_local/src_005/misiones.1.png` | SRC-005, `misiones/misiones.1.png` |
| `src_005_misiones_2` | `res://evidencia_local/src_005/misiones.2.png` | SRC-005, `misiones/misiones.2.png` |

Las huellas de referencia son las publicadas en [SRC-005](../../referencias/README.md#src-005--escaneos-españoles-de-personajes-misiones-y-mercado). Ambas fuentes se declaran de tipo `carta_fisica` con `url: null`. Cada definición referencia la hoja correspondiente con su código impreso y cuadrante como localizador. La comprobación del lote coteja el par ruta y huella con SRC-005, además de la comprobación general de archivo y huella del validador. Se mantiene `ruta_imagen: null` hasta que exista arte de presentación.

La implementación preparará estas rutas a partir de la carpeta de originales que se indique al comando local. Comprobará las dos huellas de origen y ambos destinos antes de escribir. Si un destino existente difiere, informará del conflicto y dejará intactos ambos destinos. Cuando las comprobaciones pasen, copiará los PNG sin transformarlos y reutilizará las copias idénticas. El catálogo y el comando podrán versionarse. La carpeta local quedará excluida de Git y llevará un marcador `.gdignore` para evitar la importación de recursos. Su exclusión de exportación se comprobará con un preset de prueba al implementar, sin añadir un preset de distribución. Un clon sin los originales conserva el arranque con el catálogo de muestra. Quien tenga los originales podrá preparar y comprobar el lote localmente.

## Aceptación y plan de implementación

| Caso | Resultado exigido |
| --- | --- |
| CAT-MIS-01 · Compatibilidad | El catálogo de muestra y las suites v1 conservan sus resultados. Un documento de versión desconocida o una casilla de la otra versión se rechaza. |
| CAT-MIS-02 · Lote | Con los dos escaneos existentes, validar las ocho definiciones, ocho recorridos de doce casillas, 17 casillas intermedias con premio y ocho cimas. Comparar IDs, cantidades, localizadores, premios normales, extras y permanentes con la transcripción. La validación aporta ocho definiciones verificadas en el lote explícito. |
| CAT-MIS-03 · Errores de datos | Rechazar posiciones ausentes, repetidas o fuera de orden, extra intermedio sin premio normal, permanente fuera de la cima, cima sin premio normal o con las dos formas a la vez, operación desconocida, cantidades inválidas y `pendiente` en una verificada. Probar que un borrador con `pendiente` queda fuera de la selección verificada. |
| CAT-MIS-04 · Evidencia y carga | Comprobar preparación repetible y que un conflicto en el segundo destino deja intacto el primero. Ruta externa, huella inválida, ausencia o sustitución de una hoja y referencia inválida rechazan la carga explícita, sin resultados parciales. La comprobación de lote también rechaza sustituir una hoja junto con su huella declarada e intercambiar ambas hojas con referencias internamente coherentes. Probar recuperación al reponer la hoja, arranque con las muestras y exclusión de escaneos de Git, importación y exportación de prueba. |
| CAT-MIS-05 · Frontera de juego | Verificar que el nuevo lote no habilita acciones. Partir de un perfil aislado admitido, incluir una misión v2 con un descriptor coincidente y conservar Funding y las restantes definiciones válidas. Acreditar que el rechazo se debe a la misión v2. Para la integración futura, cubrir dos plazas en una misma casilla, reenvío y fallo de una recompensa, cimas con extras únicos y permanentes, aplicación M2/M3 al completar, nueva mano M4 y llegada de la misma plaza a las tres cimas. |

T08.1b10 implementará primero la validación de v2 y la preparación local de fuentes. Después incorporará y cotejará el JSON del lote. Ejecutará `test-catalog`, `test`, `test-setup`, `test-funding`, `test-start` y la comprobación específica del lote con los originales. El caso de la suite v1 que usa 2 como versión desconocida pasará a usar una versión aún sin soporte y conservará la comprobación de rechazo.

La transacción de avance, las elecciones, el registro del primero por casilla, la persistencia y la evaluación de finales pertenecen a la futura integración. El estado actual tiene `progress`, `rewards` y `arrival_order`. Acreditar quién llegó primero a cada casilla y el pago de sus premios exige comprobaciones de autoridad adicionales. El futuro contrato deberá fijar esas comprobaciones y el orden de resolución si la última cima coincide con un premio, conforme a REG-032/033/044.
