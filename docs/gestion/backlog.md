# Backlog por fases

Última revisión: 2026-10-29. IDs locales estables; **no son números de issues de GitHub**. La consulta al repositorio del 2026-10-26 no devolvió issues. Ninguna fila ha sido publicada por estas tareas documentales.

## Uso

- El [plan](../plan-de-trabajo.md) define las puertas de salida; aquí se identifican paquetes de trabajo para convertir en issues.
- Solo el primer lote está detallado. Los paquetes posteriores se refinan al llegar a su fase y pueden dividirse manteniendo el ID original como agrupador.
- Una referencia Pxx exige cerrar sus dependencias relevantes; una referencia Txx.n exige terminar esa tarea.
- Después de publicar, añadir la URL y mantener el estado operativo en GitHub. No reutilizar un ID para otro objetivo.
- No cerrar una fase por haber terminado una sola tarea si falta su criterio de salida.

## Primer lote: descubrimiento

### T00.1 — Sistema transversal de agentes SDD

- Tipo: herramientas/proceso. Fase P00, mejora posterior a su cierre documental. Spec: [SPEC-009](../specs/009-sistema-agentes/spec.md).
- Encargo del usuario: analizar alcance, consumo, eficiencia y calidad; implementar roles/modelos adecuados y revisión independiente para el desarrollo completo.
- Entrega: configuración nativa `.codex/`, política operativa, validador local, prueba de delegación y revisión de esta entrega. Sin SDK/servicios nuevos ni cambios del motor del juego.
- Aceptación: AC-01–06 de SPEC-009, evidencia y límites de carga/consumo explícitos. Estado: completada en configuración y aplicación por instrucciones, revisión independiente favorable; carga nativa automática no acreditada. [Evidencia](../specs/009-sistema-agentes/verification.md). Issue: sin publicar.
- No sustituye pruebas de reglas, experiencia visual ni cierre externo de P04; siguiente trabajo del juego conserva T08.2 en su parte confirmada.
- Ampliación R2 del 2026-10-29, AC-07: obligatoriedad y dispensas exclusivamente humanas; AGENTS/perfiles/plantillas y control de cierre alineados. Completada con revisión independiente favorable, validación TOML, enlaces/anclas y diff correctos; ninguna dispensa aplicable.
- Publicación autorizada expresamente el 2026-10-29 mediante commit/push de toda la entrega; la revisión que contiene esta entrada identifica el paquete. Sin issue/PR solicitada. No implica cierre de fases del juego.

### T01.1 — Identificar el reglamento aportado

- Tipo: investigación/documentación. Fase P01. Spec: [SPEC-001](../specs/001-alcance-y-reglamento/spec.md), AC-01.
- Entrada: reglamento o enlace y datos de portada del juego del usuario.
- Entrega realizada: SRC-001 con título, inglés, 1.ª edición/1.ª impresión (2024), 20 páginas, ubicación y SHA-256. La correspondencia con la caja española es DUD-003.
- Aceptación: otra sesión puede localizar la fuente e identificar sus páginas; cualquier dato no disponible queda explícito.
- Dependencia satisfecha: PDF del usuario. Estado: completada documentalmente el 2026-10-27. Issue: sin publicar.
- No incluye: transcribir cartas ni implementar reglas.

### T01.2 — Inventariar reglas, componentes y dudas

- Tipo: documentación. Fase P01. SPEC-001, AC-02.
- Entrega realizada: REG-001 a REG-075 tras incorporar SRC-002, inventario de cantidades/contenido faltante y DUD-001 a DUD-007 con sus estados. Véase [referencias](../referencias/README.md).
- Aceptación: se distingue lo confirmado de lo desconocido; las dos cartas de prueba no se consideran oficiales.
- Dependencia satisfecha: T01.1. Estado: inventario inicial del material disponible completado el 2026-10-27; sin publicar.
- Las 20 páginas se han revisado. El PDF no contiene todos los textos/cartas/pistas; el faltante está inventariado, no cubierto ni implementado.

### T02.1 — Acordar la primera entrega

- Tipo: decisión/documentación. Fase P02. SPEC-001, AC-03 a AC-05.
- Entrega: ficha de alcance con plataformas, jugadores, modo, catálogo, acceso, desconexiones y objetivos de presentación.
- Aceptación: Q-001 a Q-006 están resueltas al nivel requerido para pasar a P03; alojamiento/transporte finales pueden resolverse en P04.
- Dependencia: T01.2 para cerrar. Compatibilidad y resoluciones se concretarán durante P03/P05.
- Estado: núcleo funcional acordado: Windows, máximo cuatro humanos, modos, salas privadas sin cuentas y reconexión. Catálogo y detalles de presentación/interrupciones siguen parciales; se permite preparar P03. Issue: sin publicar.

## Paquetes posteriores

Estos son candidatos a issues, no especificaciones listas para implementar. La aceptación definitiva debe derivarse del reglamento y del cierre de cada fase.

| ID | Fase | Resultado previsto | Dependencia mínima | Estado | GitHub |
| --- | --- | --- | --- | --- | --- |
| T03.1 | P03 | Godot 4.7.2, project.godot, tema y escena de inicio. | Núcleo P02 confirmado | Completada; SPEC-003 | Sin publicar |
| T03.2 | P03 | Autoload, diagnóstico, comandos y 58 comprobaciones en copia limpia. | T03.1 | Completada; SPEC-003 | Sin publicar |
| T04.1 | P04 | Probar dos clientes con mensajes de prueba y una autoridad identificada. | P03 | Completada localmente; SPEC-004, anfitrión + tres clientes independientes | Sin publicar |
| T04.2 | P04 | Probar la vía de acceso desde dos redes distintas; comparar anfitrión y servicio si hace falta, con requisitos y costes. | T04.1 | Parcial; guía/comparación listas, falta segundo equipo y evidencia externa | Sin publicar |
| T05.1 | P05 | Preparar una pantalla representativa con tablero, mano, carta ampliada y recursos de muestra. | P02, P03 | Completada técnicamente; SPEC-005, 39 comprobaciones | Sin publicar |
| T05.2 | P05 | Definir tipografías, colores, estados de interacción y resoluciones objetivo; revisar con el usuario. | T05.1 | Completada como dirección visual inicial; usuario confirma presentación de cartas | Sin publicar |
| T06.1 | P06 | Definir campos y efectos estructurados a partir del reglamento, separando definiciones e instancias. | P01, P03 | Completada en contrato inicial; SPEC-006 | Sin publicar |
| T06.2 | P06 | Validar tipos, IDs, referencias y recursos ausentes; decidir carga ante errores y migrar ejemplos. | T06.1 | Completada; 220 comprobaciones, migración y avisos | Sin publicar |
| T07.1 | P07 | Estado, zonas, instancias, modos/rival e invariantes con fixtures. | Núcleo P02, P06; P04 para cierre de fase | Completada localmente; SPEC-007, 1.725 comprobaciones de estado | Sin publicar |
| T07.2 | P07 | Transacciones, RNG, recibos por plaza, proyección privada y continuación. | T07.1 | Completada localmente; SPEC-007, 102 comprobaciones del motor | Sin publicar |
| T08.1 | P08 | Preparación, reparto, orden de jugadores y fases del turno según REG. | P01, P07 | T08.1a completada localmente; T08.1b espera pistas/recompensas verificadas; SPEC-008 | Sin publicar |
| T08.2 | P08 | Transiciones, límites y casos de mazo/descartes del reglamento. | T08.1 | SPEC-008; parte confirmada próxima al retomar, DUD-006 pendiente para agotamiento total | Sin publicar |
| T08.3 | P08 | Diferencias por modo: Target/bonificaciones y paso rival. | T08.2 | Preparación inicial por modo hecha en T08.1a; paso rival pendiente | Sin publicar |
| T09.1 | P09 | Implementar por familias los efectos confirmados, objetivos y elecciones pendientes. | P08 | Por refinar | Sin publicar |
| T09.2 | P09 | Definir orden de resolución, efectos encadenados y finalización; comprobar interacciones y objetivos inválidos. | T09.1 | Por refinar | Sin publicar |
| T09.3 | P09 | Adversarios, escudos, edictos, Dominación y decisiones colectivas. | T09.2, T08.3 | SPEC-002; catálogo/dudas pendientes | Sin publicar |
| T10.1 | P10 | Conectar una interfaz funcional al motor y aplicar condiciones de final y victoria confirmadas. | P05, P09 | Por refinar | Sin publicar |
| T10.2 | P10 | Completar una partida de prueba con preparación, turnos, efectos y resultado final. | T10.1 | Por refinar | Sin publicar |
| T10.3 | P10 | Completar escenario local solo/cooperativo con subconjunto identificado. | T10.2, T09.3 | SPEC-002; por refinar | Sin publicar |
| T11.1 | P11 | Inventariar y migrar todas las cartas, cantidades, componentes y excepciones del alcance. | P10 | Por refinar | Sin publicar |
| T11.2 | P11 | Completar trazabilidad fuente → REG/carta → especificación → prueba y comprobar combinaciones relevantes. | T11.1 | Por refinar | Sin publicar |
| T11.3 | P11 | Completar las 36 cartas rivales, pistas y excepciones de todos los modos. | T11.1, T10.3 | Pendiente de contenido completo | Sin publicar |
| T12.1 | P12 | Mostrar turno, recursos, zonas, elecciones, historial y resultado; ampliar cartas y explicar acciones no disponibles. | P05, P10 | Por refinar | Sin publicar |
| T12.2 | P12 | Adaptar la maqueta a casos reales: manos grandes, nombres largos, varias elecciones y resoluciones acordadas. | T12.1 | Por refinar | Sin publicar |
| T12.3 | P12 | Interfaz de rival, Dominación, escudos y elecciones colectivas. | T12.2, T09.3 | SPEC-002; por refinar | Sin publicar |
| T13.1 | P13 | Crear/unirse a salas privadas sin cuentas, identidad temporal recuperable, plazas y preparación. | P04, P10 | Por refinar | Sin publicar |
| T13.2 | P13 | Gestionar sala inexistente/llena, incompatibilidad de versiones y salida antes de empezar. | T13.1 | Por refinar | Sin publicar |
| T13.3 | P13 | Selección de modo, plazas hasta cuatro y ruta local de solitario. | T13.2 | SPEC-002; por refinar | Sin publicar |
| T14.1 | P14 | Enviar intenciones validadas, identificar acciones duplicadas y sincronizar cambios y elecciones. | P11, P12, P13 | Por refinar | Sin publicar |
| T14.2 | P14 | Filtrar estado privado en el envío y comprobar convergencia del estado público y vistas autorizadas. | T14.1 | Por refinar | Sin publicar |
| T14.3 | P14 | Sincronizar rival y decisiones cooperativas de 2–4. | T14.2, T11.3, T12.3, T13.3 | SPEC-002; por refinar | Sin publicar |
| T15.1 | P15 | Definir y aplicar pausa/reserva, abandono y pérdida de autoridad; reconexión obligatoria ya acordada. | P14 | Detalles pendientes | Sin publicar |
| T15.2 | P15 | Recuperar plaza propia y estado autorizado sin cuentas, reanudar elecciones y evitar acciones duplicadas. | T15.1 | Requisito obligatorio; por refinar | Sin publicar |
| T16.1 | P16 | Completar partidas con el número de jugadores objetivo y registrar incidencias reproducibles. | P15 | Por refinar | Sin publicar |
| T16.2 | P16 | Comprobar instalación/acceso, latencia, elecciones simultáneas si existen, visibilidad y resultados. | T16.1 | Por refinar | Sin publicar |
| T16.3 | P16 | Verificar competitivo 2/3/4, cooperativo 2/3/4 y solitario 1. | T16.2, T14.3 | No ejecutado | Sin publicar |
| T17.1 | P17 | Sustituir recursos provisionales, integrar animaciones, bruma y audio cuando estén acordados. | P11, P12, P16 | Por refinar | Sin publicar |
| T17.2 | P17 | Revisar legibilidad, ritmo, rendimiento, volumen y opciones para reducir efectos. | T17.1 | Por refinar | Sin publicar |
| T18.1 | P18 | Preparar exportación, versión, instrucciones de acceso, solución de problemas y notas de cambios. | P17 | Por refinar | Sin publicar |
| T18.2 | P18 | Ejecutar la lista de entrega y definir cómo registrar incidencias y distribuir actualizaciones. | T18.1 | Por refinar | Sin publicar |

## Mantenimiento y errores

Una incidencia encontrada durante una fase recibe su propia issue con reproducción y comportamiento esperado. Si cambia reglas o estado, tiene prioridad sobre el avance de contenido. Una corrección debe enlazar el criterio REG/AC afectado y su comprobación de regresión.

Documentos y plantillas se incluyen en la entrega inicial autorizada para commit y push el 2026-10-27. Publicar el primer lote como issues es un paso independiente todavía pendiente. No se han creado etiquetas, hitos ni tablero de Projects.

## Refinamiento P07

[SPEC-007](../specs/007-estado-y-acciones/spec.md) y sus [tareas](../specs/007-estado-y-acciones/tasks.md) concretan T07.1/2 para trabajo local. T07.1/2 implementadas localmente con 1.725 y 102 comprobaciones; evidencia en verification.md. P04 externa sigue condicionando el cierre.

## Refinamiento P08

[SPEC-008](../specs/008-preparacion-y-turnos/spec.md) divide T08.1 en preparación estructural (T08.1a) y entrenamiento/arranque de turno (T08.1b). T08.1a completada localmente con 147 comprobaciones; [evidencia](../specs/008-preparacion-y-turnos/verification.md). T08.2/3 siguen pendientes. La fase no se cierra con el constructor porque no hay catálogo verificado, reglas de turno completas ni partida jugable.
