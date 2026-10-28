# SPEC-007 — Estado y acciones de partida

- Fecha: 2026-10-28.
- Estado: T07.1 implementada y verificada localmente; T07.2 pendiente. P07 no cerrada.
- Tareas: T07.1 y T07.2; sin issues publicadas.
- Objetivo: construir un núcleo reproducible que conserve el estado, valide intenciones y entregue a cada plaza únicamente su información autorizada, sin depender de escenas ni transporte.

## Alcance y fuentes

Incluye representación de modos, jugadores, instancias, zonas, recursos, turno, rival y resoluciones pendientes; invariantes, aleatoriedad propia, acciones identificables, cambios atómicos y proyecciones. La autoridad es un componente lógico único; su alojamiento sigue pendiente de P04. El solitario usa el mismo núcleo local.

Fuentes: [contrato v1](../../contrato-catalogo-v1.md), [SPEC-002](../002-modos-y-cooperativo/spec.md), SRC-001/SRC-002 mediante la [matriz](../../referencias/matriz-reglas.md). REG-007/011 delimitan consulta de zonas; REG-012–024 exigen registrar usos y reacciones; REG-025/035–043 exigen persistencia y propiedad; REG-052–066 exigen rival, escudos y secuencias. Se conservan las correcciones SRC-002 recogidas en REG-016/026/029/030/040/041/047/058/068–075. P07 representa estas necesidades; no ejecuta aún esas reglas.

Quedan fuera preparación/reparto y turnos reglamentarios (P08), resolución de efectos y ventanas reglamentarias (P09), victoria (P10), interfaz jugable y transporte (P12–P15). No habrá acciones públicas genéricas para mover cartas o aumentar recursos. Los fixtures técnicos no son preparaciones oficiales ni cartas verificadas.

## Aceptación de la implementación futura

- **AC-01 — Modos:** el descriptor admite competitivo 2/3/4, cooperativo 2/3/4 y solitario 1; rechaza los demás, IDs de plaza duplicados y rival en competitivo. Sin preparar automáticamente salud, mazos ni bonificaciones.
- **AC-02 — Identidad y zonas:** dos copias del mismo diseño tienen instance_id distintos. Cada instancia pertenece a una sola zona, referencia una definición disponible y conserva propietario aunque cambie de zona. Un fallo de referencias, duplicación o propietario rechaza el estado completo. Obtener o modificar una copia no cambia el catálogo ni el estado interno.
- **AC-03 — Estado por modo:** se conservan recursos persistentes y del turno separados, uso/agotamiento de metales, progreso y orden de llegada de misiones, Target opcional y rival con mazo, descarte, Dominación y escudos. Las pruebas de almacenamiento no acreditan preparación, daño ni victoria reglamentarios.
- **AC-04 — Reproducibilidad:** mismo snapshot completo, versión del motor y secuencia de intenciones producen los mismos estados y resultados, incluidas extracciones aleatorias. Un rechazo no consume aleatoriedad ni cambia contador alguno.
- **AC-05 — Transacción:** una intención válida se aplica sobre una copia, se comprueban invariantes y se publica una sola revisión nueva. Error de formato, identidad, versión, revisión, legalidad, elección o invariantes conserva íntegramente el estado anterior y devuelve código estable sin detalles privados.
- **AC-06 — Reintentos:** repetir una intención aceptada con igual ID y contenido devuelve su acuse sin reaplicar ni incrementar revisión, incluso tras aceptar otras acciones. Reutilizar el ID con otro contenido se rechaza. La identidad es la plaza autenticada por el adaptador, nunca un campo del payload ni el peer de conexión.
- **AC-07 — Privacidad:** la proyección propia permite mano y descarte propios; ningún cliente recibe contenido/orden de mazos ocultos, semilla, estado RNG ni manos ajenas. Las cartas eliminadas son consultables por todos. Para zonas sin visibilidad confirmada se usa la política conservadora del plan; no se presenta como regla oficial. Un destinatario desconocido no obtiene vista. Cambiar una carta oculta conservando cantidades no cambia la vista ajena, incluidos eventos y errores.
- **AC-08 — Resolución pendiente:** una continuación identifica resolución, paso y plazas autorizadas. Rechazar destinatario, opción o resolución incorrectos conserva el estado. Una resolución bloqueada no permite saltarse pasos mediante otra acción; no impide respuestas expresamente autorizadas para otra plaza. Se prueba reanudación desde snapshot sin resolver ventanas de reglas todavía desconocidas.
- **AC-09 — Separación:** el núcleo y sus pruebas no requieren SceneTree, Database, ENet, reloj ni UI; reciben definiciones y contexto por parámetros. Una operación sin manejador se rechaza como no soportada. Los manejadores de pruebas solo existen en tests.

## Dependencias y dudas

P02 permite el núcleo local; P06 aporta definiciones. P04 sigue siendo dependencia de cierre: falta evidencia externa y decisión de acceso. Esto permite especificar y probar partes locales, sin declarar completada P07.

DUD-002/003 impiden catálogo fiel; DUD-004/005/006 bloquean sus reglas concretas. No hacen falta para almacenar estado o probar transacciones con fixtures. La visibilidad ajena de descartes y zonas del rival debe contrastarse antes de ampliar su proyección; por defecto no se revelan. Esta política técnica temporal no cambia el reglamento. No se decide pausa, reserva de plaza, guardado entre días ni migración de autoridad.
