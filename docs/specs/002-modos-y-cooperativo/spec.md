# SPEC-002 — Modos y rival cooperativo

- Estado: borrador de comportamiento; no lista para implementación completa.
- Fecha: 2026-10-27.
- Fases: P06–P16 según tareas.
- Fuente: SRC-001 pp.5–20 y alcance confirmado por el usuario.
- Objetivo: compartir reglas comunes sin mezclar victorias, preparación y objetivos entre modos.

## Alcance

Competitivo con 2, 3 o 4 personas; cooperativo con 2, 3 o 4; solitario cooperativo con una persona. El rival se ejecuta mediante mazo y reglas, sin requerir una IA estratégica ni un jugador adicional. El solitario debe poder jugarse en una instancia local; el acceso remoto se usa para el grupo.

No incluye oponentes humanos simulados para competitivo, cambios de reglas ni expansiones. Las denominaciones técnicas de modo se decidirán en P07.

## Criterios de aceptación

- **AC-01:** La preparación acepta las siete configuraciones válidas y rechaza competitivo de una persona y cualquier partida de más de cuatro.
- **AC-02:** El competitivo aplica bonificaciones por orden y Target solo con 3–4; cooperativo/solo no usa ninguno de los dos (REG-001 a REG-006, REG-052).
- **AC-03:** El rival comienza con salud 48, Dominación 1 y mazo de 36; X usa el nivel visible actual hasta 6 (REG-052/053).
- **AC-04:** Se roba carta rival después del turno y nueva mano de cada superviviente; no hay ataques entre compañeros o a sus aliados (REG-054/055/063).
- **AC-05:** Los adversarios se pueden atacar entre jugadores, mantienen escudos destruidos y los pierden de izquierda a derecha con coste completo por escudo; matar aliado quita solo un escudo (REG-056 a REG-058).
- **AC-06:** Los edictos resuelven orden, pasos de Dominación, efecto extra, curación por misión y posiciones de limpieza; completan sus efectos si eliminan a un jugador (REG-059 a REG-062).
- **AC-07:** Las elecciones colectivas se resuelven mediante una asignación legal confirmada antes de continuar; en solitario todo recae en el único jugador (REG-066). El mecanismo de coordinación de interfaz es diseño pendiente.
- **AC-08:** Eliminados dejan de tener turno y de provocar robo rival; las condiciones por número de jugadores usan supervivientes (REG-063).
- **AC-09:** Competitivo tiene sus tres finales; cooperativo/solo sus dos victorias y dos derrotas. Tres misiones completas no ganan el cooperativo (REG-044/064).
- **AC-10:** Solitario usa su excepción de posición/recompensas de misión y Sense no afecta al rival (REG-045/065).
- **AC-11:** La sala permite elegir modo y hasta cuatro participantes; el cooperativo remoto valida las elecciones con la misma autoridad que aplica reglas. La partida local de uno no exige un segundo cliente.
- **AC-12:** La matriz de pruebas incluye competitivo 2/3/4, cooperativo 2/3/4 y solitario 1, con victoria, derrota/eliminación y fallos relevantes de red donde corresponda.

## Dependencias y bloqueos

DUD-001/004/005/006/007 afectan a partes de reglas compartidas o terminales. DUD-002 impide cubrir el catálogo completo; DUD-003 la nomenclatura española exacta. Se pueden especificar e implementar por separado las partes que no dependan de cada duda cuando exista proyecto ejecutable.

La privacidad debe derivarse de las zonas del reglamento; que el modo sea cooperativo no autoriza a enviar automáticamente todas las manos a todos los clientes.
