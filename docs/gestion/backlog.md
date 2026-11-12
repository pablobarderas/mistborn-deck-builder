# Backlog por fases

Última revisión: 2026-11-10. IDs locales estables; **no son números de issues de GitHub**. La consulta al repositorio del 2026-10-26 no devolvió issues. Ninguna fila ha sido publicada por estas tareas documentales.

## Uso

- El [plan](../plan-de-trabajo.md) define las puertas de salida; aquí se identifican paquetes de trabajo para convertir en issues.
- Solo el primer lote está detallado. Los paquetes posteriores se refinan al llegar a su fase y pueden dividirse manteniendo el ID original como agrupador.
- Una referencia Pxx exige cerrar sus dependencias relevantes; una referencia Txx.n exige terminar esa tarea.
- Después de publicar, añadir la URL y mantener el estado operativo en GitHub. No reutilizar un ID para otro objetivo.
- No cerrar una fase por haber terminado una sola tarea si falta su criterio de salida.

## Primer lote: descubrimiento

### Auditoría de escaneos de mercado 2026-11-09

- Ampliación de cierre solicitada por el usuario: revisar mercado9.png y confirmar cobertura de mercado. AC: imagen completa/legible de Tirón de hierro, 65 títulos únicos, grupos 10/10/10/10/21/4, 17 diseños con dos copias y total 82. Se mantiene R0 (inventario, sin catálogo ejecutable). Plan previo: inspección visual y metadatos; incorporar una fila al informe; actualizar estado de captura y comprobar cuentas/enlaces/diff. Responsable: coordinador; ninguna dispensa, sin commit/push. Completada: imagen correcta; todas las cuentas y lista exacta de duplicados comprobadas, 95 enlaces locales y diff correctos. Siguiente paso: recorte/revisión de datos; no más capturas de mercado para completar este inventario. La entrada de 64/65 inferior conserva el resultado de la primera revisión, sustituido por este cierre.

- Objetivo/AC: contar diseños presentes, identificar títulos/grupos y repeticiones en las ocho hojas de mercado, contrastar 65 diseños y 17 copias adicionales indicadas por el usuario, e informar faltantes o incertidumbres sin declarar catálogo jugable verificado.
- Riesgo R0: inventario visual de fuentes, sin interpretación de efectos ni modificación del catálogo/contrato. Responsable: coordinador; sin subagentes ni dispensas.
- Plan previo: generar vistas temporales de lectura sin alterar originales, revisar las hojas y contrastar títulos/conteos; conservar informe de evidencia. Verificación: unicidad, sumas por grupo, lista de duplicados físicos, revisión del diff y enlaces.
- Estado: auditoría completada; captura incompleta. [Informe](../referencias/auditoria-escaneos-2026-11-09.md): 64 diseños únicos, falta Tirón de hierro (azul); 80/82 cartas físicas representadas. Conteos verificados también sobre las filas del informe, diff revisado, 94 enlaces locales comprobados y git diff --check correcto. Sin pruebas Godot ni revisión independiente: inventario R0, no verificación del catálogo. Fetch y estado remoto consultados en edebe0c1211241b4a4e703b2d66c129df3d8147d; se preservan seis documentos locales modificados en el registro de prioridad anterior. Sin commit/push. Siguiente paso: una captura del diseño ausente y revalidar el recuento.

### Registro documental 2026-11-09 — Prioridad competitiva

- Objetivo/aceptación: registrar la instrucción humana «la parte del lord legislador será la última de todas» y el foco actual en combate entre Nacidos de la Bruma; conservar cooperativo/solitario en el alcance y sus criterios de cierre pendientes.
- Riesgo R0: transcripción de una prioridad explícita, sin interpretar reglas ni modificar código, catálogo, contratos o controles SDD. Responsable: coordinador; no requiere subagente.
- Plan: registrar decisión; enlazar desde estado/plan y orientar las capturas al competitivo. Verificación prevista: revisar diff, enlaces locales y coherencia entre prioridad y alcance. Sin commit/push ni dispensa.
- Estado: completado documentalmente; DEC-027 registrada y enlazada. Diff revisado, 80 enlaces locales comprobados y encabezado del ancla DEC-027 contrastado; git diff --check correcto. Sin pruebas Godot por tratarse exclusivamente de memoria documental. Contexto remoto consultado mediante fetch: main local y origin/main en edebe0c1211241b4a4e703b2d66c129df3d8147d, árbol inicialmente limpio. Issue: sin publicar. Siguiente paso: recibir/revisar entrenamientos y paneles competitivos; T08.2f continúa pendiente para el motor.

### T00.1 — Sistema transversal de agentes SDD

- AC-10 (2026-11-11): reducir redundancia manteniendo controles, R2 documental, completada con revisión independiente favorable; [tarea y registro previo](../specs/009-sistema-agentes/tasks.md#ac-10--reducir-trabajo-redundante-sin-rebajar-controles). Sin issue ni publicación.

- Tipo: herramientas/proceso. Fase P00, mejora posterior a su cierre documental. Spec: [SPEC-009](../specs/009-sistema-agentes/spec.md).
- Encargo del usuario: analizar alcance, consumo, eficiencia y calidad; implementar roles/modelos adecuados y revisión independiente para el desarrollo completo.
- Entrega: configuración nativa `.codex/`, política operativa, validador local, prueba de delegación y revisión de esta entrega. Sin SDK/servicios nuevos ni cambios del motor del juego.
- Aceptación: AC-01–06 de SPEC-009, evidencia y límites de carga/consumo explícitos. Estado: completada en configuración y aplicación por instrucciones, revisión independiente favorable; carga nativa automática no acreditada. [Evidencia](../specs/009-sistema-agentes/verification.md). Issue: sin publicar.
- No sustituye pruebas de reglas, experiencia visual ni cierre externo de P04; siguiente trabajo del juego conserva T08.2 en su parte confirmada.
- Ampliación R2 del 2026-10-29, AC-07: obligatoriedad y dispensas exclusivamente humanas; AGENTS/perfiles/plantillas y control de cierre alineados. Completada con revisión independiente favorable, validación TOML, enlaces/anclas y diff correctos; ninguna dispensa aplicable.
- Publicación autorizada expresamente el 2026-10-29 mediante commit/push de toda la entrega; la revisión que contiene esta entrada identifica el paquete. Sin issue/PR solicitada. No implica cierre de fases del juego.
- Ampliación R2 AC-08 del 2026-10-29: un objetivo verificable por sesión, cierre/traspaso y recuperación mínima contrastada; completada con revisión independiente favorable, enlaces/anclas y diff correctos. Sin dispensas; publicación mediante commit/push detallado autorizada expresamente en encargo posterior del mismo día. La revisión que incorpora esta nota identifica la entrega. [Evidencia y traspaso](../specs/009-sistema-agentes/verification.md#ampliación-ac-08--sesiones-y-contexto).

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
| T08.1 | P08 | Preparación, reparto, orden de jugadores y fases del turno según REG. | P01, P07 | T08.1a completada localmente. T08.1b tiene el paso interno competitivo verificado; falta integrar el inicio. | Sin publicar |
| T08.2 | P08 | Transiciones, límites y casos de mazo/descartes del reglamento. | T08.1 | SPEC-008; T08.2a implementada/verificada (262), revisión en SPEC; T08.2b implementada/probada (334), revisión favorable; T08.2c saldo/devolución Atium verificada (527 limpieza, 1.938 estado), revisión favorable; pendientes combate/efectos y aplicar DEC-032 al robo personal | Sin publicar |
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

Subdivisión actual de T08.2: T08.2e, [contrato de secuencia reanudable](../specs/008-preparacion-y-turnos/secuencia-reanudable.md), AC-23–28, completada documentalmente con revisión favorable; T08.2f, implementación y pruebas SEQ-01–10 completadas localmente el 2026-11-10: 253 comprobaciones de secuencias, regresiones y revisión independiente favorable. [Evidencia y siguiente objetivo](../specs/008-preparacion-y-turnos/verification.md#t082f--implementación-de-secuencias-reanudables): especificar primer resolutor real competitivo. Ambas sin issue publicada. No son cierre P08 ni repetición de ciclo/limpieza/Atium. Ampliación T00.1/SPEC-009 AC-09: consulta obligatoria del estado GitHub antes de seleccionar trabajo, por instrucción humana del 2026-11-01; revisión conjunta favorable.

Una incidencia encontrada durante una fase recibe su propia issue con reproducción y comportamiento esperado. Si cambia reglas o estado, tiene prioridad sobre el avance de contenido. Una corrección debe enlazar el criterio REG/AC afectado y su comprobación de regresión.

Documentos y plantillas se incluyen en la entrega inicial autorizada para commit y push el 2026-10-27. Publicar el primer lote como issues es un paso independiente todavía pendiente. No se han creado etiquetas, hitos ni tablero de Projects.

## Refinamiento P07

[SPEC-007](../specs/007-estado-y-acciones/spec.md) y sus [tareas](../specs/007-estado-y-acciones/tasks.md) concretan T07.1/2 para trabajo local. T07.1/2 implementadas localmente con 1.725 y 102 comprobaciones; evidencia en verification.md. P04 externa sigue condicionando el cierre.

## Refinamiento P08

T08.1b11 (R2 documental) especifica [avance de misiones, MIS-01–06](../specs/008-preparacion-y-turnos/avance-misiones.md) y DEC-034. Completada documentalmente con revisión independiente favorable. T08.1b12 queda planificada para el primer resolutor aislado M5/M6/M7. Sin issue publicada.

T08.1b7 (R2 documental) registra DEC-032 y está publicada en `02e38c7`. T08.2i aplica el robo personal. Queda aplicar el desbloqueo tardío en el resolutor de habilidades y la prioridad de finales del rival en T08.3. [Casos y evidencia](../specs/008-preparacion-y-turnos/verification.md#t082i--robo-personal-con-mazo-y-descarte-agotados).

T08.1b9 (R2 documental), publicada en `cfecee9`, especifica el [contrato de catálogo v2 de misiones](../specs/008-preparacion-y-turnos/catalogo-misiones.md). T08.1b10 implementa validación, preparación de fuentes y comprobación local de M1–M8. [Evidencia](../specs/008-preparacion-y-turnos/verification.md#t081b10--validación-y-lote-de-catálogo-de-misiones). Sin issue publicada.

T08.1b8 (R2 documental) reúne la [transcripción de M1–M8](../referencias/misiones-competitivas.md). [Evidencia](../specs/008-preparacion-y-turnos/verification.md#t081b8--transcripción-de-las-ocho-misiones). Sin issue publicada.

T08.1b5 y T08.1b6 (R2 documental): [delimitación del perfil competitivo de producto](../specs/008-preparacion-y-turnos/perfil-competitivo-producto.md) y resoluciones de DEC-031. PERF-01–06 quedan para la integración. Sin issue publicada.

T08.1b1: [contrato del avance de entrenamiento competitivo](../specs/008-preparacion-y-turnos/avance-entrenamiento.md), R2 documental, ENT-AC-01 a 04. T08.1b2 implementa y prueba ENT-AC-01 a 03 con perfil aislado SRC-004. Sigue la especificación de integración de inicio único y apertura de `libre` (ENT-AC-04). [Evidencia](../specs/008-preparacion-y-turnos/verification.md#t081b2--operación-interna-de-avance-competitivo). Sin issue publicada.

T08.1b3 publicada en `fd75e23`. T08.1b4, publicada en `69c1ef2`, implementa ENT-AC-04 en el perfil aislado. [Evidencia](../specs/008-preparacion-y-turnos/verification.md#t081b4--implementación-del-inicio-competitivo). Sin issue publicada.

T08.1b dispone de [originales y lectura del panel competitivo](../referencias/entrenamiento-competitivo.md), utilizados como fuente de las recompensas del paso interno. La incorporación de las cartas y la pista al catálogo ejecutable sigue pendiente.

T08.2h: implementación local de Funding completada, revisión independiente favorable y 3.778 comprobaciones, escenarios FUND-01–08; [evidencia](../specs/008-preparacion-y-turnos/verification.md#t082h--implementación-de-funding). Sólo perfil aislado competitivo, sin catálogo oficial ni fases nuevas. Sin issue ni commit/push. Siguiente objetivo: revisión de entrenamiento/panel competitivo para T08.1b, condicionada a disponer de originales verificables.

T08.2g, [contrato del primer resolutor competitivo](../specs/008-preparacion-y-turnos/primer-resolutor-competitivo.md), AC-35–38, R2: completada documentalmente con revisión independiente favorable (2026-11-11). Funding desde mano con elección aplicar/omitir; contraste de reglas y plan registrados en SPEC-008. T08.2h completada localmente: perfil cerrado y FUND-01–08, según entrada superior. Sin issues publicadas; no incorpora catálogo español ni completa turno/combate. [Evidencia y traspaso](../specs/008-preparacion-y-turnos/verification.md#t082g--contrato-del-primer-resolutor-competitivo).

T08.2c completada localmente, revisión independiente favorable (2026-10-30): contrato de saldo total igual a fichas y devolución atómica del Atium usado, [AC-15–18](../specs/008-preparacion-y-turnos/spec.md#t082c--saldo-y-devolución-de-atium). Reemplaza el pendiente contable descrito abajo; entrenamiento, combate/efectos, rival y aplicación de DEC-032 al robo personal siguen pendientes. Sin issue publicada.

[SPEC-008](../specs/008-preparacion-y-turnos/spec.md) divide T08.1 en preparación estructural (T08.1a) y entrenamiento/arranque de turno (T08.1b). T08.1a completada localmente con 147 comprobaciones; [evidencia](../specs/008-preparacion-y-turnos/verification.md). T08.2a implementa ciclo personal de cartas (262 comprobaciones); T08.2b añade cierre interno de limpieza a inicio/rival (334 comprobaciones, revisión favorable); T08.2 sigue abierto por combate/efectos, entrenamiento y aplicación de DEC-032 al robo personal; Atium usado se cubre en T08.2c. T08.3 sigue pendiente. La fase no se cierra con el constructor porque no hay catálogo verificado, reglas de turno completas ni partida jugable.

### T08.2d — Contrato previo a entrada en limpieza

Entrega documental R2: [contrato y AC-19–22](../specs/008-preparacion-y-turnos/entrada-a-limpieza.md). Contrato documental completado y revisado independientemente; sin transición implementada. Entrada funcional bloqueada por resolutores de combate/Target/efectos/finales; siguiente paso: contrato de secuencia reanudable P08/P09. Sin issue publicada.
