# Especificaciones

Cada entrega con varios comportamientos usa una carpeta `NNN-descripcion/` con cuatro archivos:

- `spec.md`: problema, alcance, fuentes, escenarios y criterios de aceptación; explica qué debe ocurrir.
- `plan.md`: diseño y pasos técnicos; explica cómo construirlo.
- `tasks.md`: tareas pequeñas, dependencias e IDs de issues.
- `verification.md`: evidencia por criterio y pendientes reales.

Estado de especificación: borrador, lista, en implementación, en verificación, completada o sustituida. Lista exige resolver las preguntas que cambian el comportamiento; completada exige evidencia. Estos estados no sustituyen el estado individual de una issue.

Reutilizar [la plantilla](plantilla.md) creando una carpeta numerada. Una sola especificación puede agrupar varias issues; un arreglo pequeño puede documentarse directamente en la issue.

Especificaciones actuales:

- [001 — Alcance y reglamento](001-alcance-y-reglamento/spec.md): fuente e inventario inicial documentados; decisiones de producto pendientes.
- [002 — Modos y cooperativo](002-modos-y-cooperativo/spec.md): borrador de reglas y aceptación para competitivo 2–4, cooperativo 2–4 y solitario 1; sin implementación.
- [003 — Arranque Godot](003-arranque-godot/spec.md): P03 completada; proyecto ejecutable, carga observable y pruebas/captura verificadas.
- [004 — Conexión temprana](004-conexion-temprana/spec.md): ensayo local ENet con autoridad y procesos independientes verificado; prueba entre redes y alojamiento final pendientes.
- [005 — Maqueta del tablero](005-maqueta-tablero/spec.md): completada como dirección visual inicial; implementación, verificación y confirmación del usuario. Mercado, mano, detalle y estados de muestra.

No hay Spec Kit instalado. La estructura es propia y sigue el [flujo SDD ligero](../gestion/desarrollo.md).
