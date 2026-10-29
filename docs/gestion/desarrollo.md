# Desarrollo por especificaciones e issues

## Método elegido

SDD ligero es obligatorio: describir el comportamiento y cómo verificarlo antes de implementarlo. Las especificaciones viven en Git; GitHub Issues organiza el trabajo y las PR permiten revisar la entrega. Solo una instrucción humana explícita puede dispensar requisitos según [obligatoriedad y dispensas](agentes-sdd.md#obligatoriedad-y-dispensas); la proporcionalidad R0–R3 no permite omitir sus controles mínimos.

El usuario ha delegado la elección del método. Se adopta este flujo sin instalar herramientas adicionales. Está inspirado en [GitHub Spec Kit](https://github.github.com/spec-kit/) (consultado el 2026-10-26), pero no se ha instalado Spec Kit ni existen sus comandos en este proyecto.

## Fuentes de verdad

| Información | Ubicación responsable |
| --- | --- |
| Instrucciones de trabajo | [AGENTS.md](../../AGENTS.md) |
| Objetivos y preguntas de producto | [Alcance](../alcance.md) |
| Secuencia y cierre de fases | [Plan](../plan-de-trabajo.md) |
| Referencias oficiales y cobertura | [Referencias](../referencias/README.md) |
| Comportamiento y aceptación por entrega | [Especificaciones](../specs/README.md) |
| Diseño técnico y alternativas | plan.md de la especificación; decisiones duraderas en [decisiones](../decisiones.md) |
| Tareas antes de publicarlas | [Backlog local](backlog.md) |
| Estado operativo de tareas publicadas | Issue de GitHub y su PR; el backlog conserva ID y enlace |
| Hechos y último punto de reanudación | [Estado](../estado-actual.md) y [registro](../registro-de-trabajo.md) |

No copiar el texto completo de una especificación en una issue. Enlazar su ruta y resumir el resultado esperado. Si aún no está subida, indicar que es local y no inventar un enlace a GitHub.

## Ciclo de una entrega

1. **Seleccionar:** tomar una tarea con dependencias satisfechas; comprobar si ya existe una issue equivalente.
2. **Especificar:** escribir objetivo, alcance, fuentes, escenarios y criterios de aceptación numerados. Resolver las dudas que afecten a su comportamiento.
3. **Planificar:** describir cambios de datos/interfaces, archivos previstos, alternativas, riesgos y verificación. Registrar decisiones duraderas.
4. **Dividir:** crear tareas independientes, pequeñas y comprobables; cada una conserva un ID local estable y, cuando se publique, su número GitHub.
5. **Implementar:** trabajar dentro del alcance y mantener especificación y código coherentes. Una corrección pequeña puede usar solo la issue.
6. **Verificar:** registrar pruebas reales y resultados para cada criterio; separar aprobado, fallido y no ejecutado.
7. **Revisar y cerrar:** revisar diff y documentación; cerrar la issue tras integración y aceptación técnica. Actualizar estado y siguiente paso.

Para documentación o arreglos pequeños basta una issue con objetivo, alcance y aceptación. Una carpeta con cuatro documentos se reserva para entregas que cambien reglas, datos, arquitectura, red o varios comportamientos. No exigir una especificación por cada carta si comparten contrato y familia de efectos.

La revisión del usuario se pide para decisiones de producto, dudas de reglas y propuesta visual. Los cambios técnicos reversibles y la documentación pueden avanzar dentro de lo autorizado sin una aprobación repetida para cada archivo.

## Ejecución con agentes

El [sistema de agentes SDD](agentes-sdd.md) aplica este ciclo con un coordinador y especialistas bajo demanda. Clasificar riesgo antes de asignar trabajo; revisión independiente para entregas funcionales y cambios críticos. Los perfiles agrupan responsabilidades, no obligan a crear un agente por paso. El coordinador comprueba la evidencia final y mantiene la memoria; no se cierra una fase por el dictamen de un agente sin cumplir su criterio de salida. Configuración y límites en `.codex/`; aceptación y ensayo en [SPEC-009](../specs/009-sistema-agentes/spec.md).

Aplicar [un objetivo verificable por sesión](agentes-sdd.md#sesiones-y-traspaso), manteniendo su ciclo SDD y correcciones relacionados juntos. Documentar cierre o traspaso antes de cambiar de objetivo; una tarea interrumpida conserva su estado y puede retomarse en el mismo chat. El siguiente chat recupera documentos y comprueba Git/código; no recibe un historial completo por defecto. No implica crear chats automáticamente ni garantiza ahorro de tokens o aislamiento de archivos.

## Preparada y terminada

Una tarea está **lista** si tiene objetivo, límites, dependencias resueltas, fuentes cuando aplica y criterios verificables; no contiene preguntas que cambien el comportamiento a construir.

Está **terminada** si la implementación o documento satisface esos criterios, tiene evidencia, documentación actualizada y revisión realizada. En GitHub, una PR abierta es revisión pendiente; una issue cerrada por cancelación no significa funcionalidad entregada.

El cierre exige registro de cumplimiento metodológico y dispensas humanas, o «ninguna». Si falta un control obligatorio y no hay dispensa válida, la tarea sigue abierta. Una dispensa queda visible con su alcance y limitaciones; no permite marcar como aprobada una prueba no ejecutada ni cerrar dependencias que no cubra.

Los problemas de reglas pendientes bloquean su implementación, no todo el proyecto. Explicar el bloqueo y la tarea independiente que puede seguir.

## GitHub

Repositorio comprobado: [pablobarderas/mistborn-deck-builder](https://github.com/pablobarderas/mistborn-deck-builder). El 2026-10-26 es público, usa main y la búsqueda de issues no devolvió ninguna. Las plantillas forman parte de la entrega documental inicial autorizada para commit y push el 2026-10-27; GitHub las toma de la rama principal publicada.

- Una issue por resultado comprobable; una fase extensa agrupa varias issues.
- Títulos: `[P03] Crear proyecto Godot ejecutable`; conservar `T03.1` en el cuerpo para relacionarlo con el backlog.
- Estados: pendiente → lista → en curso → en revisión → terminada; bloqueada indica su dependencia concreta. No hace falta un tablero de Projects para empezar.
- Prioridad: P0 impide jugar/corrompe reglas o estado; P1 necesaria para la fase actual; P2 mejora posterior.
- Etiquetas opcionales: `tipo:funcionalidad`, `tipo:error`, `tipo:investigacion`, `tipo:documentacion`, `area:reglas`, `area:ui`, `area:red`. No se han creado ni se exigen en las plantillas.
- Agrupar por hito de entrega E0–E6 si resulta útil; no se han creado hitos ni Projects.
- Rama sugerida tras publicar issue: `feat/123-descripcion`, `fix/123-descripcion` o `docs/123-descripcion`.
- Referenciar `Closes #123` en la PR únicamente cuando su integración satisfaga toda la issue.
- No hacer commits, publicar issues/PR ni subir documentación por inferirlo de una tarea puramente documental; hacerlo cuando el trabajo encargado incluya esas acciones.

## Activación sin duplicados

La entrega inicial de bases se realiza mediante commit y push en `main` por encargo del usuario. Verificar la revisión remota al cerrar. Para nuevas entregas se recomienda rama/PR según el alcance encargado.

Cuando se encargue publicar tareas: consultar issues abiertas y cerradas; publicar solo el lote listo del backlog y registrar sus URLs. No crear retrospectivamente tareas ya completadas como si estuvieran pendientes. La siguiente fase se desglosa cuando sus entradas estén confirmadas.

No publicar ahora todo el catálogo de tareas futuras: sus detalles dependen del reglamento y de las pruebas técnicas. El [backlog](backlog.md) ya conserva la ruta completa.

Plantillas locales: [tarea](../../.github/ISSUE_TEMPLATE/tarea.md), [error](../../.github/ISSUE_TEMPLATE/error.md), [investigación](../../.github/ISSUE_TEMPLATE/investigacion.md) y [PR](../../.github/pull_request_template.md). Formato basado en la [documentación de GitHub](https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/syntax-for-issue-forms); usamos Markdown con cabecera YAML.
