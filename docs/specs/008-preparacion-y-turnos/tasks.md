# Tareas de SPEC-008

| ID | Resultado | Estado |
| --- | --- | --- |
| T08.1a | Constructor de preparación, reparto, orden, bonificaciones y rival con manifiesto verificado. | Completada localmente; AC-01–06, 147 comprobaciones |
| T08.1b | Entrenamiento inicial/de turno y recompensas confirmadas; apertura de fase libre. | En espera de pistas/recompensas verificadas; usuario las deja pendientes por ahora |
| T08.2 | Transiciones, limpieza, mano siguiente y reciclado de mazos. | Agrupador abierto; T08.2a completada localmente, transiciones completas y DUD-006 pendientes |
| T08.2a | Primitivas internas de robo, reciclado personal y limpieza de cartas; AC-07–10. | Completada localmente; 262 comprobaciones y revisión independiente favorable |
| T08.2b | Cierre interno de limpieza y entrega a inicio/rival con guardias; AC-11–14. | Implementada, 334 comprobaciones; revisión independiente favorable |
| T08.2c | Contrato saldo/fichas y devolución del Atium usado; AC-15–18. | Implementada, limpieza 527 / estado 1.938; revisión independiente favorable |
| T08.2d | Contrato documental de entrada a limpieza; AC-19–22. | Completada como contrato documental, revisión favorable; transición sin implementar |
| T08.2e | [Contrato de secuencia reanudable](secuencia-reanudable.md); AC-23–28. | Completada documentalmente; revisión independiente favorable |
| T08.2f | Implementar secuencia interna con registro ficticio, esquema v2, pausas/cierre único/proyecciones; AC-29–34 y SEQ-01–10. | Completada localmente 2026-11-10; 253 comprobaciones de secuencia, regresiones y revisión independiente favorable; sin reglas ni transición real a limpieza |
| T08.3 | Paso rival y diferencias de modo durante la ronda. | Pendiente; efectos de P09 |
| T08.2g | [Primer resolutor competitivo: Funding](primer-resolutor-competitivo.md), contrato AC-35–38. | Completada documentalmente; revisión independiente favorable, sin implementación |
| T08.2h | Implementar juego Funding y elección aplicar/omitir; escenarios FUND-01–08. | Pendiente de implementación; T08.2g cerrada, perfil de pruebas, no catálogo español ni turno completo |

Sin issues publicadas. T08.1/2/3 del backlog siguen siendo agrupadores estables.

## T08.2g — Especificar el primer resolutor real competitivo

Registro previo, 2026-11-11. Objetivo: seleccionar y especificar un segmento reglamentario real sobre T08.2f, con fuentes, límites, contrato y escenarios verificables antes de implementar. Aceptación: fuentes SRC-001/SRC-002 contrastadas; contenido necesario identificado sin declarar verificados escaneos ausentes; contrato compatible con el núcleo o cambios necesarios explícitos; plan de implementación y casos adversos; revisión independiente y enlaces comprobados.

Riesgo R2: semántica de reglas, autoridad y efectos, aunque esta entrega sea documental. Plan: inspeccionar fuentes y código; contraste de reglas; redactar contrato/plan/escenarios; revisión independiente; corregir y registrar evidencia/traspaso. Coordinador único escritor de documentos; `resolver_rules` (sdd_rules, Sol/high) contrasta en lectura; sdd_reviewer Sol/high revisará el resultado. Sin descendientes ni dispensas. Verificación prevista: trazabilidad, coherencia con APIs reales, enlaces locales/anclas y `git diff --check`; Godot no aplica si no cambia código/datos/configuración.

Recuperación: fetch correcto y estado publicado leído en `2fdc4c35a1868b8bc600d4deccd6a865a4a37b63`, idéntico a HEAD/main, árbol inicialmente limpio. No hay avance remoto que integrar ni permiso de publicación para esta entrega. Estado: completada documentalmente, AC-35–38 y revisión independiente favorable; evidencia en verification.md. La implementación será una tarea posterior al contrato; P08 permanece abierta.
