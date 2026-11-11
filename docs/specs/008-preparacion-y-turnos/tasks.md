# Tareas de SPEC-008

### T08.1b — Revisión previa de los originales competitivos

Registro previo 2026-11-11. El usuario aporta `C:/Users/pablo/Documents/Digitalizaciones`. Fetch correcto y estado publicado leídos en `b07303bc77f6ac6cd6419c628afdf44268ac313b`, igual a HEAD/main con árbol limpio. La mención a T08.2h local en el resumen publicado es histórica, pues ese commit contiene su implementación.

Objetivo y aceptación: identificar y revisar las cuatro hojas de entrenamiento y el panel de niveles, conservar localizadores y huellas, y distinguir lo visible de las reglas y dependencias pendientes para T08.1b. Riesgo R2 por su uso futuro como fuente de reglas y catálogo. El coordinador inspecciona y redacta. Contraste especializado para la lectura reglamentaria y revisión independiente de la evidencia antes del cierre. Comprobaciones: correspondencia de fuentes, lectura visual, enlaces y diff. Alcance documental, sin incorporar catálogo ejecutable ni abrir fases. Ninguna dispensa ni autorización de publicación.

| ID | Resultado | Estado |
| --- | --- | --- |
| T08.1a | Constructor de preparación, reparto, orden, bonificaciones y rival con manifiesto verificado. | Completada localmente; AC-01–06, 147 comprobaciones |
| T08.1b | Entrenamiento inicial/de turno y recompensas confirmadas; apertura de fase libre. | Fuente competitiva revisada en [SRC-004](../../referencias/entrenamiento-competitivo.md). Pendientes la especificación del avance, implementación y pruebas. |
| T08.2 | Transiciones, limpieza, mano siguiente y reciclado de mazos. | Agrupador abierto; T08.2a completada localmente, transiciones completas y DUD-006 pendientes |
| T08.2a | Primitivas internas de robo, reciclado personal y limpieza de cartas; AC-07–10. | Completada localmente; 262 comprobaciones y revisión independiente favorable |
| T08.2b | Cierre interno de limpieza y entrega a inicio/rival con guardias; AC-11–14. | Implementada, 334 comprobaciones; revisión independiente favorable |
| T08.2c | Contrato saldo/fichas y devolución del Atium usado; AC-15–18. | Implementada, limpieza 527 / estado 1.938; revisión independiente favorable |
| T08.2d | Contrato documental de entrada a limpieza; AC-19–22. | Completada como contrato documental, revisión favorable; transición sin implementar |
| T08.2e | [Contrato de secuencia reanudable](secuencia-reanudable.md); AC-23–28. | Completada documentalmente; revisión independiente favorable |
| T08.2f | Implementar secuencia interna con registro ficticio, esquema v2, pausas/cierre único/proyecciones; AC-29–34 y SEQ-01–10. | Completada localmente 2026-11-10; 253 comprobaciones de secuencia, regresiones y revisión independiente favorable; sin reglas ni transición real a limpieza |
| T08.3 | Paso rival y diferencias de modo durante la ronda. | Pendiente; efectos de P09 |
| T08.2g | [Primer resolutor competitivo: Funding](primer-resolutor-competitivo.md), contrato AC-35–38. | Completada documentalmente; revisión independiente favorable, sin implementación |
| T08.2h | Implementar juego Funding y elección aplicar/omitir; escenarios FUND-01–08. | Completada localmente; FUND-01–08, 205 Funding / 3.778 total, revisión independiente favorable; no catálogo español ni turno completo |

Sin issues publicadas. T08.1/2/3 del backlog siguen siendo agrupadores estables.

## T08.2g — Especificar el primer resolutor real competitivo

Registro previo, 2026-11-11. Objetivo: seleccionar y especificar un segmento reglamentario real sobre T08.2f, con fuentes, límites, contrato y escenarios verificables antes de implementar. Aceptación: fuentes SRC-001/SRC-002 contrastadas; contenido necesario identificado sin declarar verificados escaneos ausentes; contrato compatible con el núcleo o cambios necesarios explícitos; plan de implementación y casos adversos; revisión independiente y enlaces comprobados.

Riesgo R2: semántica de reglas, autoridad y efectos, aunque esta entrega sea documental. Plan: inspeccionar fuentes y código; contraste de reglas; redactar contrato/plan/escenarios; revisión independiente; corregir y registrar evidencia/traspaso. Coordinador único escritor de documentos; `resolver_rules` (sdd_rules, Sol/high) contrasta en lectura; sdd_reviewer Sol/high revisará el resultado. Sin descendientes ni dispensas. Verificación prevista: trazabilidad, coherencia con APIs reales, enlaces locales/anclas y `git diff --check`; Godot no aplica si no cambia código/datos/configuración.

Recuperación: fetch correcto y estado publicado leído en `2fdc4c35a1868b8bc600d4deccd6a865a4a37b63`, idéntico a HEAD/main, árbol inicialmente limpio. No hay avance remoto que integrar ni permiso de publicación para esta entrega. Estado: completada documentalmente, AC-35–38 y revisión independiente favorable; evidencia en verification.md. La implementación será una tarea posterior al contrato; P08 permanece abierta.

## T08.2h — Implementación de Funding (registro previo)

2026-11-11. Autorización: «haz commit y push y vamos con el siguiente paso»; T08.2g publicada y verificada en GitHub/main `1e6c91747737d0c867a928763f0e3d11873091cf`, fetch posterior correcto, estado publicado leído y árbol limpio antes de este registro. Continuación de objetivo en esta sesión expresamente solicitada; no dispensa controles R2 ni autoriza publicar código futuro.

Objetivo/AC: implementar el contrato T08.2g y satisfacer FUND-01–08: perfil cerrado, juego atómico +1/+0, legalidad, recibos/carga, privacidad y límites. Riesgo R2 por reglas/autoridad/estado. Plan vigente en plan.md; contraste SRC-001/002 y omisión ya completado en T08.2g, no se introduce regla nueva. Responsable de código: `funding_impl`, perfil sdd_developer por instrucciones Sol/high para atomicidad e integración; propietario exclusivo de funding_play.gd/UID, tests/fixtures/suites afectados, state_validator.gd (versión) y tools/godot.ps1. Coordinador único escritor de documentación e integrador, revisión independiente posterior sdd_reviewer Sol/high; sin descendientes.

Verificación prevista: FUND-01–08 y nueve suites del plan, ejecución Godot en serie bajo un responsable, importación y marcas limpias; enlaces/diff y revisión independiente final. Sin cambios visuales/red, esas comprobaciones no aplican a esta API. Ninguna dispensa; P04/P07/P08 y catálogo español mantienen sus puertas. Estado: completada localmente; evidencia en verification.md, ninguna dispensa, no commit/push de implementación.
