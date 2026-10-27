# Reglas del juego

Última revisión: 2026-10-27.

## Fuente y alcance

Se ha leído y revisado visualmente SRC-001: Mistborn: The Deckbuilding Game, Brotherwise Games, 1.ª edición/1.ª impresión, 2024, 20 páginas. El archivo aportado es inglés; el usuario tiene la caja española y quiere el producto en español. No se da por confirmada la equivalencia textual de ambas localizaciones.

Modos confirmados: competitivo de 2–4, cooperativo de 2–4 y cooperativo en solitario. El rival se resuelve por cartas y reglas. Ver [alcance](alcance.md).

## Referencia duradera

- [Fuente, hash y mapa de páginas](referencias/README.md).
- [Matriz de reglas](referencias/matriz-reglas.md): REG-001 a REG-067.
- [Componentes y catálogo pendiente](referencias/componentes.md).
- [Dudas abiertas](referencias/dudas.md).
- [Especificación de modos](specs/002-modos-y-cooperativo/spec.md).

## Diferencias que debe preservar la implementación

- La preparación competitiva da bonificaciones por orden; solo/cooperativo no las da.
- Target existe con 3–4 jugadores competitivos y se retira al quedar 2; solo/cooperativo no lo usa.
- Competitivo permite ganar por tres misiones, supervivencia o Confrontation con cuatro Atium.
- Solo/cooperativo gana por derrotar al rival o Confrontation; pierde por agotar el mazo rival o eliminación de todos. Completar las tres misiones no basta para ganar, pero limita la curación rival.
- El Lord Ruler usa salud, mazo, Dominación, adversarios con escudos y edictos; se resuelve carta después de cada turno de superviviente.
- Hay decisiones y reacciones fuera del turno activo. La interfaz y la red deben permitirlas; no basta con bloquear toda interacción al resto de jugadores.
- Solitario tiene sus propias condiciones para posición y recompensas de misiones.

Páginas de referencia: preparación 5/18; turnos y combate 15–17/19; finales y excepciones 17/20. El detalle trazable está en la matriz.

## Estado real

Solo existe documentación de estas reglas. Database.gd y cartas.json siguen siendo ejemplos técnicos sin motor del juego. El PDF no enumera todo el catálogo ni muestra todos los textos/pistas; no se ha acreditado fidelidad completa.

Algunas cláusulas tienen dudas expresas, incluida una referencia inconsistente a la pista de misiones en el beneficio final de entrenamiento de la página 12. Resolverlas mediante fuentes antes de codificarlas. No introducir reglas caseras silenciosamente.
