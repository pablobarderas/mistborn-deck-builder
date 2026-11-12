# Tareas de SPEC-008

### T08.1b10 — Validación y lote de catálogo de misiones

Registro previo 2026-11-12. Contrato publicado y verificado tras fetch en `cfecee9f5d9955a223c6bb3dbf8a3d02f46e73ac`, igual a HEAD/main con árbol limpio. Riesgo R2 por contrato de datos, admisión y fuentes físicas. Aceptación CAT-MIS-01–05 en el [contrato](catalogo-misiones.md). El coordinador posee el validador, datos y documentación; sdd_developer implementa la preparación y verificación local de las fuentes, y sdd_reviewer (Sol/high) revisa el resultado. Plan: añadir la rama v2, incorporar M1–M8 en carga explícita, preparar las fuentes originales, ejecutar pruebas del lote y regresiones de catálogo, arranque y perfiles, comprobar exclusiones y revisar. Se reutiliza el contraste reglamentario de T08.1b8–9. Sin dispensas.

### T08.1b9 — Contrato de catálogo para las misiones

Registro previo 2026-11-12. Fetch y estado publicado leídos en `55a9399b52e76c39ba75f3d52cf373f8baf699e2`, igual a HEAD de main, con árbol limpio. R2 documental por versionado, fuentes, semántica de premios y frontera de admisión. Aceptación: representar M1–M8 sin pérdida, definir validación y convivencia con P06 v1, registrar los originales ya cotejados de manera reproducible, y fijar pruebas de admisión y de integración posterior. El coordinador es el único escritor, se reutiliza el contraste reglamentario de T08.1b8 y se solicita revisión final independiente sdd_reviewer (Sol/high). Plan: inspeccionar cargador, validador y consumidores, especificar forma y ejemplos, comprobar cobertura, huellas, enlaces y diff, revisar y dejar traspaso para implementación. Sin dispensas.

### T08.1b8 — Transcripción de las ocho misiones

Registro previo 2026-11-12. Fetch y estado publicado comprobados en `916c81a05f84ff18c65335eaa8ade347ed59b0d4`, igual a HEAD de main y con árbol limpio. R2 documental por recorridos, recompensas y futura admisión de catálogo. Aceptación: cotejar las ocho cartas de SRC-005 con sus posiciones, premios de casilla, extras del primero y recompensas de cima, contrastar los símbolos y las reglas con SRC-001/002 y DEC-031, y delimitar lo que P06 permite representar. Plan: comprobar huellas, leer los originales y las páginas pertinentes, registrar un borrador trazable, verificar cobertura, enlaces y diff, y someter el resultado a revisión independiente. El coordinador es el único escritor, `mission_rules` (sdd_rules, Sol/high) contrasta las reglas y un sdd_reviewer (Sol/high) revisa la entrega. Sin dispensas.

### T08.2i — Robo personal con mazo y descarte agotados

Registro previo 2026-11-12. DEC-032 publicada en `02e38c723ac86f0492f2f5c64abb2a9b852030bf`; fetch posterior confirma HEAD, origin/main y árbol limpio. R2 por reglas, zonas privadas, RNG y cierre transaccional. Aceptación: robar hasta el total disponible, reciclar sólo al necesitarlo, aceptar robo vacío sin cambios/RNG, cerrar limpieza con mano corta y conservar rollback, recibos y privacidad. El coordinador posee `card_cycle.gd`, versión de motor, prueba de versión y documentación. `draw_tests` (sdd_developer, Sol/medium) posee las suites de ciclo y limpieza. Reutilizar contraste de DEC-032; revisión independiente sdd_reviewer Sol/high. Plan: mantener el contrato de retorno, limitar el bucle al total disponible, versionar la semántica conservando esquema 2, ejecutar ciclo/limpieza/estado/motor y regresiones P08 pertinentes. Sin dispensas.

### T08.1b7 — Desbloqueo tardío, robo y finales del rival

Registro previo 2026-11-12. Fetch y estado publicado contrastados en `5fe5e65b632e78a6a4c64b3894fa646fcde171a9`, igual a HEAD y árbol limpio. R2 documental por acciones legales, robo privado y condiciones terminales. Aceptación: cerrar DUD-004/006 según la decisión expresa del usuario, precisar los casos comprobables y distinguir la regla futura de la guardia actual. Coordinador único escritor, contraste de `profile_rules` (sdd_rules, Sol/high) y revisión independiente sdd_reviewer Sol/high. Plan: contrastar fuentes, código y contratos; actualizar REG/DUD, aceptación y traspaso; verificar enlaces y diff. Sin dispensas.

### T08.1b6 — Resoluciones de reglas del perfil competitivo

Registro previo 2026-11-12. Fetch y estado publicado en `69c1ef254bf2fb78b71454da2518567c351e1303`, igual a HEAD. Se conserva T08.1b5 en el árbol local. Riesgo R2 documental por elegibilidad y orden de efectos, premios y posiciones de misión. Objetivo y aceptación: registrar las decisiones expresas sobre fuente española, nivel II, Guardadora, M2/M3 y empates; reflejarlas en REG, DUD y casos de integración sin cambiar el motor. Coordinador único escritor, contraste de `profile_rules` (sdd_rules, Sol/high) y revisión independiente sdd_reviewer Sol/high. Plan: actualizar fuentes, contrato y traspaso; comprobar coherencia, enlaces y diff. Sin dispensas.

### T08.1b5 — Delimitación del perfil competitivo de producto

Registro previo 2026-11-12. `git fetch origin` y estado publicado contrastados en `69c1ef254bf2fb78b71454da2518567c351e1303`, igual a HEAD de `main`, árbol limpio y fast-forward al día. Objetivo documental R2 por catálogo, reglas y admisión de autoridad. Aceptación: (1) especificar inventario y relaciones del manifiesto para 2–4 plazas, con evidencia y faltantes por componente; (2) delimitar qué puede reutilizarse del inicio aislado y qué reglas bloquean la admisión real; (3) dejar criterios comprobables para la siguiente integración y un primer paso acotado de contenido. El coordinador es propietario de la documentación, `profile_rules` (sdd_rules, Sol/high) contrasta reglas y un sdd_reviewer (Sol/high) revisará el diff. Plan: contrastar fuentes, inventario, P06 y APIs, redactar alcance, comprobar enlaces y diff, revisar y registrar el traspaso. Entrega documental, sin dispensas.

### T08.1b4 — Implementación del inicio competitivo

Registro previo 2026-11-12. Contrato T08.1b3 publicado y comprobado por fetch en `fd75e232657f7e477b8f2e92ba685785ddea392c`, igual a HEAD de main con árbol limpio. Riesgo R2 por estado, reglas, privacidad y autoridad. Aceptación en [INI-01–05](inicio-competitivo.md#escenarios-para-t081b4). El coordinador posee el motor, adaptador, versión, lanzador y documentación. `start_tests` posee la suite y fixtures nuevos. Reutilizar el contraste SRC-001/002/004 del contrato, comprobar FAQ y solicitar revisión independiente final. Validar la entrada separada, admisión y commit compartido con la suite y regresiones del plan. Sin dispensas.

### T08.1b3 — Contrato del inicio único competitivo

Registro previo 2026-11-12. T08.1b2 publicada con autorización expresa. Fetch posterior y `git show` contrastados en `ab3ef5573596713ec03a06a965d25e7b8cfc33d9`, igual a HEAD de main con árbol limpio. Objetivo documental R2 por autoridad, idempotencia, privacidad y reglas de final. Aceptación: especificar ENT-AC-04, el subconjunto implementable y las pruebas de avance único, reenvío, obligaciones, finales y fallo atómico. Coordinador único autor, contraste de `training_rules` y revisión independiente de `training_review`. Verificación documental contra SRC-001/002/004, P07/P08, enlaces y diff. Sin dispensas. La implementación será una tarea posterior.

### T08.1b2 — Operación interna de avance competitivo

Registro previo 2026-11-11. Fetch y estado publicado contrastados en `c6f11e8367f50fcef818dc68d00cb4719a7eb6bf`, igual a HEAD de main y árbol inicialmente limpio. Objetivo y aceptación en [ENT-AC-01 a 03](avance-entrenamiento.md#aceptación-y-pruebas-previstas). Riesgo R2 por aplicación de reglas, cambio de estado y uso del contador de autoridad. Coordinador propietario del módulo, suite, lanzador y documentación. `training_rules` contrasta SRC-001/002/004 y `training_review` revisará el diff final de forma independiente. Plan: validar el perfil aislado y el estado, calcular y verificar el candidato, ejecutar `test-training` y las regresiones del plan, revisar y registrar evidencia. ENT-AC-04 queda para la integración. Sin dispensas.

### T08.1b1 — Contrato del avance de entrenamiento competitivo

Registro previo 2026-11-11. Fetch posterior a publicación y estado comprobados en `13bb11fca786fa2f227e9455062da83eb4b5a51d`, igual a HEAD/main y árbol limpio. El usuario pide continuar tras publicar la revisión de originales. Objetivo: especificar la operación interna de avance y las condiciones de integración con inicio de turno. Aceptación: ENT-AC-01 a 04, cobertura de las 21 casillas, atomicidad, Atium y prevención de doble inicio. R2 por reglas, estado y autoridad. Coordinador único escritor, contraste reglamentario específico y revisión independiente de contrato. Plan: contrastar SRC-001/002/004 y el estado vigente, escribir contrato y escenarios, verificar referencias y diff, revisar y registrar el traspaso. Sólo documentación, sin dispensa ni publicación de este nuevo trabajo.

### T08.1b — Revisión previa de los originales competitivos

Registro previo 2026-11-11. El usuario aporta `C:/Users/pablo/Documents/Digitalizaciones`. Fetch correcto y estado publicado leídos en `b07303bc77f6ac6cd6419c628afdf44268ac313b`, igual a HEAD/main con árbol limpio. La mención a T08.2h local en el resumen publicado es histórica, pues ese commit contiene su implementación.

Objetivo y aceptación: identificar y revisar las cuatro hojas de entrenamiento y el panel de niveles, conservar localizadores y huellas, y distinguir lo visible de las reglas y dependencias pendientes para T08.1b. Riesgo R2 por su uso futuro como fuente de reglas y catálogo. El coordinador inspecciona y redacta. Contraste especializado para la lectura reglamentaria y revisión independiente de la evidencia antes del cierre. Comprobaciones: correspondencia de fuentes, lectura visual, enlaces y diff. Alcance documental, sin incorporar catálogo ejecutable ni abrir fases. Ninguna dispensa ni autorización de publicación.

| ID | Resultado | Estado |
| --- | --- | --- |
| T08.1a | Constructor de preparación, reparto, orden, bonificaciones y rival con manifiesto verificado. | Completada localmente; AC-01–06, 147 comprobaciones |
| T08.1b | Entrenamiento inicial/de turno y recompensas confirmadas; apertura de fase libre. | Inicio competitivo verificado en perfil aislado. Pendientes integración de producto y demás modos. |
| T08.1b1 | [Contrato del avance competitivo](avance-entrenamiento.md), ENT-AC-01 a 04. | Completada documentalmente con revisión independiente favorable. |
| T08.1b2 | Implementar y probar un paso interno con ENT-AC-01 a 03. | Completada localmente con revisión favorable. [Evidencia](verification.md#t081b2--operación-interna-de-avance-competitivo). ENT-AC-04 queda para la integración. |
| T08.1b3 | [Contrato del inicio competitivo](inicio-competitivo.md) y plan de pruebas para ENT-AC-04. | Completada documentalmente con revisión independiente favorable. |
| T08.1b4 | Implementar el inicio competitivo en perfil aislado y verificar INI-01–05. | Completada localmente con revisión favorable. [Evidencia](verification.md#t081b4--implementación-del-inicio-competitivo). |
| T08.2 | Transiciones, limpieza, mano siguiente y reciclado de mazos. | Agrupador abierto; T08.2a completada localmente y T08.2i aplica DEC-032 al robo personal. Transiciones completas pendientes. |
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
