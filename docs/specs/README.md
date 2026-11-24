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
- [002 — Modos y cooperativo](002-modos-y-cooperativo/spec.md): borrador de reglas y aceptación; preparación inicial estructural por modo en SPEC-008, resto pendiente.
- [003 — Arranque Godot](003-arranque-godot/spec.md): P03 completada; proyecto ejecutable, carga observable y pruebas/captura verificadas.
- [004 — Conexión temprana](004-conexion-temprana/spec.md): ensayo local ENet con autoridad y procesos independientes verificado; prueba entre redes y alojamiento final pendientes.
- [005 — Maqueta del tablero](005-maqueta-tablero/spec.md): completada como dirección visual inicial; implementación, verificación y confirmación del usuario. Mercado, mano, detalle y estados de muestra.
- [006 — Contrato del catálogo](006-contrato-catalogo/spec.md): completada en contrato inicial; fuentes/revisión, gramática, migración y validación. Ninguna carta oficial verificada aún.

- [007 — Estado y acciones](007-estado-y-acciones/spec.md): T07.1/2 verificadas localmente (1.725 + 102 comprobaciones); cierre P07 pendiente de P04 externa.
- [008 — Preparación y turnos](008-preparacion-y-turnos/spec.md): servicios de preparación, cartas iniciales y misiones ensayados; [E1](008-preparacion-y-turnos/contenido-inicial-competitivo.md) y misiones tienen cotejo humano, mientras el perfil final sigue pendiente.
- [009 — Sistema de agentes SDD](009-sistema-agentes/spec.md): mejora transversal P00 y [AC-11 de publicación al cierre](009-sistema-agentes/tasks.md#ac-11--publicación-automática-al-completar-un-desarrollo) documentadas con revisión independiente; carga nativa automática no acreditada.
- [010 — Primera partida competitiva local](010-primera-partida-local/spec.md): E2 completada como ensayo 2–4 con fixture, reglas y pantalla verificadas; [límites y evidencia](010-primera-partida-local/verification.md). No admite catálogo final ni red.
- [011 — Competitivo completo](011-competitivo-completo/tasks.md): E3.1 registra el mercado completo por fuente y localizador; E3 sigue abierta por fidelidad, efectos y distribución.

No hay Spec Kit instalado. La estructura es propia y sigue el [flujo SDD ligero](../gestion/desarrollo.md).
