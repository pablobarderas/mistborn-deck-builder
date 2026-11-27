# Alternativas y efectos encadenados

Contrato de un programa ficticio para el ensayo competitivo local de E3. Prueba la elección de una rama y el orden de sus operaciones. La elección única y el orden se contrastaron con [SRC-001, p. 17](https://www.brotherwisegames.com/s/MistbornRulebook_V1.pdf) y [SRC-002, Action cards](https://www.brotherwisegames.com/mistborn-deckbuilding-game-faq), REG-067 y REG-069. La elección obligatoria pertenece a este ensayo. La omisión de habilidades y la activación separada de recuadros se rigen por sus propios contratos de producto. [Matriz de reglas](../../referencias/matriz-reglas.md).

## ALT-01 · Oferta y ramas

El registro exclusivo de pruebas define dos pasos, un automático inicial y una ventana final. El automático añade una unidad de `recursos` del jugador activo. Si ese incremento falla, se rechaza el inicio completo. La autoridad fija al jugador activo como dueño y único destinatario. El constructor de la ventana devuelve `kind=eleccion`, `min=max=1` y los tokens `rama_a`, `rama_b` en ese orden. La oferta es fija en este ensayo. Cada operación comprueba sus precondiciones al ejecutarse.

La plaza destinataria recibe ambos tokens y responde mediante `responder` con la revisión, resolución, paso y un token. Las otras plazas conservan la vista habitual de una resolución bloqueada. Los tokens identifican únicamente alternativas de la oferta. Las operaciones, cantidades, destinos y orden proceden de código local del registro. [Proyección](../../../scripts/game/game_projection.gd) y [contrato de secuencias](../008-preparacion-y-turnos/secuencia-reanudable.md).

| Token | Operaciones sobre los saldos del dueño |
| --- | --- |
| `rama_a` | Cambiar 2 de `recursos` por 3 de `ataque`. Después cambiar 3 de `ataque` por 4 de `mision`, leyendo el resultado del primer cambio. |
| `rama_b` | Cambiar 1 de `recursos` por 1 de `mision`. |

Cada cambio reutiliza [TurnResourceExchange](../../../scripts/game/turn_resource_exchange.gd). Si un cambio falla, el ejecutor de la ventana devuelve falso de inmediato. Las ramas se despachan dentro de ese ejecutor sobre el candidato de P07, con funciones locales y orden fijo. La cadena usa el cursor de la propia ventana y se completa en la acción de respuesta. El cierre es el del programa, sin estado adicional para la rama. Una respuesta aceptada queda asociada a su recibo por el mecanismo existente. Las dos ramas carecen de pasos con nuevas pausas o efectos externos. Las cadenas que necesiten otra decisión, una reacción o una frontera propia requieren contrato específico.

## ALT-02 · Restauración y confirmación

Después del paso automático se confirma la ventana abierta. Al restaurar, el motor exige el mismo perfil versionado de pruebas, el programa registrado y la oferta reconstruida en el mismo orden. El perfil se versiona según el contrato de secuencias. La respuesta válida reconstituye la oferta antes de ejecutar la rama. Si una plaza existente distinta de la destinataria responde o si el paso, la resolución o las opciones son inválidos, el motor devuelve `eleccion_invalida` en esa ventana para una respuesta bien formada y de revisión vigente. Una identidad desconocida o una revisión obsoleta conserva su rechazo actual.

El ensayo crea un registro independiente para `alternatives_v1`. La autoridad fija `test_alternatives_v1` como identidad de catálogo del ensayo al construir el motor, y la carga exige además la versión del motor base. El registro anterior conserva sus programas y su identidad. La regla de versionado del contrato de secuencias sigue aplicándose a los cambios de un registro instalado o de la semántica de sus programas. Al cruzar registros o identidades de catálogo, la pausa del ensayo se rechaza.

El éxito de la respuesta confirma todos los cambios de la rama, el cierre y un recibo en una sola revisión. Los cambios del ensayo consumen cero RNG. Si falla un cambio, se devuelve `accion_ilegal` y se conserva íntegro el snapshot pausado, con la unidad ya confirmada al iniciar, el RNG, las revisiones, los recibos y los cierres anteriores. Una respuesta válida posterior puede usar la ventana todavía abierta. El reenvío idéntico de una respuesta aceptada recupera su recibo incluso después del cierre. Otra respuesta para la ventana consumida se rechaza.

## ALT-03 · Casos de verificación

Los saldos se dan en orden `recursos`, `ataque`, `mision`. Cada rama se prueba desde la misma frontera inicial. Comparar snapshots completos en los rechazos y revisar la frontera y el recibo de cada éxito.

| Escenario | Resultado esperado |
| --- | --- |
| Inicio con saldos `(4, 0, 0)`. Responder con cada rama en una ejecución separada. | Al abrir, saldos `(5, 0, 0)`. A termina en `(3, 0, 4)` y B en `(4, 0, 1)`. A solo puede completar el segundo cambio tras acreditar el primero. Cada respuesta confirma una revisión, un recibo y un cierre. |
| Inicio con `recursos` en el máximo int64. | El incremento falla y se conserva el snapshot inicial completo. |
| La otra plaza intenta elegir. El destinatario envía un token desconocido, una selección vacía, un token duplicado, ambos tokens o un paso o resolución ajenos. | Con revisión vigente y formato válido, cada intento se rechaza con `eleccion_invalida`; el snapshot pausado queda intacto. Comparar la vista autorizada y la ajena para comprobar que solo la primera incluye la oferta. |
| Exportar la pausa y cargarla en un motor nuevo con el mismo registro y versiones. Ejecutar la misma respuesta en ambos, para cada rama. Alterar también una copia de la pausa permutando los tokens y otra sustituyendo uno por un ID válido no ofertado. | Paridad exacta de ventana, snapshot final, RNG y recibo en las restauraciones válidas. Las ofertas alteradas impiden la carga y preservan el estado que tenía el motor receptor. |
| Iniciar con saldos `(4, 0, MAX_INT-3)`, siendo `MAX_INT` el máximo int64. Elegir A. Elegir después B en la ventana conservada. | El primer cambio de A cabe y el segundo desborda `mision`. El rechazo conserva el snapshot pausado completo `(5, 0, MAX_INT-3)`. B puede confirmarse desde esa frontera y termina en `(4, 0, MAX_INT-2)`. |
| Reenviar la respuesta aceptada y después intentar una respuesta diferente para la ventana consumida con otro ID y revisión vigente. | El reenvío devuelve el recibo original. El nuevo intento se rechaza. Ambos conservan el snapshot final. |

La siguiente tarea implementará el fixture en el [registro de pruebas](../../../tests/sequence_fixtures.gd) y verificará esta matriz desde las entradas del motor en [las pruebas de secuencias](../../../tests/sequence_test.gd). Se ejecutarán importación y las suites de secuencias, motor y estado. El contrato corresponde a operaciones ficticias de saldos y no admite contenido de producto.
