# Verificación de SPEC-008

## T08.1b14 — Implementación de permanentes M3/M4

Publicación autorizada el 2026-11-13 mediante «haz el commit y el push». Registro previo R0 de empaquetado: objetivo publicar los 27 archivos revisados de T08.1b14, sin cambios funcionales; coordinador responsable. Fetch confirma HEAD/origin/main en `bc9bdb1`, con los cambios locales de esta entrega preservados. Plan/aceptación: reutilizar las 14 suites/7.904 comprobaciones y revisión independiente favorable, actualizar notas de publicación, comprobar enlaces/diff e índice, hacer commit/push y verificar coincidencia remota y árbol limpio. Ninguna dispensa. El commit que contiene esta nota identifica la publicación; las menciones inferiores sin commit/push describen el estado previo al permiso. Siguiente objetivo propuesto T08.1b15, aún sin iniciar.

2026-11-13. Completada y verificada localmente, revisión independiente favorable; [registro previo R2 y responsabilidades](tasks.md#t081b14--implementación-de-permanentes-m3m4). Recuperación mediante fetch correcto: HEAD/origin/main `bc9bdb1d70ba6d50ca8507679f8b7b71745ff66d`, rama main y árbol inicialmente limpio. T08.1b13 publicada y revisada favorablemente; las notas superiores de estado/plan «en revisión documental» no reflejaban su cierre acreditado aquí. Objetivo PERM-01–06 y plan en [permanentes M3/M4](permanentes-misiones.md). Se reutiliza su contraste favorable SRC-001/002/005 y DEC-031/032/034; no se cambia interpretación reglamentaria.

Implementación y pruebas delegadas a `permanents_impl`, perfil de desarrollador aplicado por instrucciones, GPT-6.1 Sol/high por composición atómica, RNG y restauración. Propiedad inicial: scripts/game/, tests/ y tools/godot.ps1; entregada al coordinador para integración final. Coordinador documentación y ejecución serial de Godot. `permanents_review`, sdd_reviewer nativo Sol/high, revisa el diff funcional y evidencia. Sin dispensas, sin commit/push. Sin UI/transporte, no aplican nuevas capturas o pruebas de red; siguen abiertas las dependencias de P04/P08 y los modos con rival. Tokens/coste no disponibles.

Incidencias de desarrollo: el autor quedó `pending_init` tras un cambio de permisos del entorno y se reactivó el mismo encargo sin perder archivos. Importación inicial real correcta. Tres corridas diagnósticas de la suite nueva fallaron y no se aceptan como evidencia favorable: claves nuevas StringName en el fixture, comparación de descriptores JSON con float integral frente a literales int en las guardas nuevas y Atium agotado ilegalmente en el fixture de limpieza. Corregidos con claves String explícitas, guardas de forma exacta/comparación numérica y Atium usado sin agotarlo; se mantienen las reglas. El revisor identificó además la ausencia de fallo postrobo: añadido doble de prueba que recorre llegada M4 y cierre reales, constata reciclado/RNG modificado antes del rechazo, comprueba snapshot completo intacto y confirma posteriormente una sola vez con el mismo ID. El coordinador repite la suite afectada antes de iniciar regresiones. Logs finales reproducibles con las acciones del lanzador; los diagnósticos no sustituyen resultados limpios.

Resultado: snapshot 4/motor `p08-permanents-1/godot-4.7.2`, ledger privado M3 y adaptador `permanents_play.gd` con entradas internas de inicio/cierre y avance público. M4 deriva nueva mano 5/6 sin marca mutable propia. Se conserva el perfil M5/M6/M7. El adaptador nuevo restaura desde fuente tipada confirmada; no añade una preparación de producto ni una transición `libre -> limpieza`. Constructor genérico y fixtures crean el ledger vacío. Catálogo v2 y fuentes reales de misiones intactos; pista, componentes y reservas restantes siguen siendo fixtures. DEC-035 registra el diseño técnico.

| Criterio | Evidencia ejecutada en `tests/permanents_test.gd` | Resultado |
| --- | --- | --- |
| PERM-01 | Primera/segunda llegada M3/M4, premios intermedios y cima, Boxings, grupos/marcas, reciclado | Aprobado, 2/3/4 plazas |
| PERM-02 | Un entrenamiento/+2, regreso posterior, ajenos intactos, recibo repetido/restaurado, nuevo ID y petición antigua | Aprobado, 2/3/4 plazas |
| PERM-03 | Mano 5/6, 0/3/5/6/10 cartas desde mazo/descarte, RNG sólo al barajar, devolución de Atium y ocurrencia única | Aprobado, 2/3/4 plazas |
| PERM-04 | Overflow +2/+3 y tras entrenamiento, recompensa fallida, revisión agotada, esquema/marcas/perfil/origen inválidos; fallos postrobo reales de M4 y cierre con rollback completo y reintento | Aprobado |
| PERM-05 | Tercera cima M3/M4 antes de premios, reintento ganador, finales rechazados; eliminación conserva marcas y entrega salta eliminado | Aprobado |
| PERM-06 | Namespaces internos vedados antes de recibo, payload manipulado, dos solicitudes de igual revisión, vistas propias/ajenas y restauradas | Aprobado en API local serializada |

Ejecución oficial serial: `powershell -NoProfile -ExecutionPolicy Bypass -File tools/godot.ps1 -Action <acción> -GodotPath 'C:/Users/pablo/Downloads/godot/Godot_v4.7.2-stable_win64_console.exe'`. Godot **4.7.2.stable.official.ed1daf0bf**. Acciones/resultados: `test-permanents` **2.478**; `test-mission-advance` **878**; `test-start` **199**; `test-training` **295**; `test-cleanup` **561**; `test-cycle` **269**; `test-state` **2.073**; `test-engine` **102**; `test-setup` **175**; `test-funding` **205**; `test-sequence` **253**; `test-catalog` **220**; `test-missions` **138**; `test` **58**. **14 suites, 7.904 comprobaciones, todas código 0 y sin SCRIPT ERROR**. Los ocho errores de carga del arranque, los dos ERROR de catálogo v1 (esquema inválido/tamaño mayor de 4 MiB) y el ERROR de fuente ausente del catálogo de misiones son negativos esperados, identificados como tales por las suites. Marcas `_OK` comprobadas por el lanzador. Logs locales ignorados `tmp/t081b14-<acción>.txt` y `tmp/godot/<acción>.log`, no acompañan otro clon. Las fuentes de misiones deben prepararse según [desarrollo local](../../desarrollo-local.md#catálogo-de-misiones) antes de reproducir sus suites. El número de comprobaciones no acredita una partida completa ni fidelidad del catálogo restante.

Se reutilizaron contrato/contraste y comprobador documental, sin nueva interpretación ni suites de UI/red ajenas al servicio. Dos delegaciones sin descendientes; mismo autor y mismo revisor para correcciones. Tras la evidencia funcional sólo se ajustó el comentario de cabecera del candidato compartido y metadatos documentales. Siguiente objetivo propuesto T08.1b15: especificar las elecciones y eliminación opcional de M8 sobre secuencias reanudables, con fuentes y pruebas previstas antes de implementarla. M1/M2, cartas generadoras de puntos, entrada a limpieza, producto, P04 externa y modos con rival permanecen pendientes. Sin autorización de publicación.

Dictamen final `permanents_review` favorable, sin bloqueantes vigentes. Inspeccionó módulos/diff contra PERM-01–06, correcciones y logs finales directamente; confirmó las 14 marcas/7.904 comprobaciones y negativos esperados. El hueco postrobo y los defectos detectados se corrigieron y revalidaron antes del dictamen. Cumplimiento R2: registro/AC/plan previos, contraste reglamentario reutilizado, implementación, pruebas adversas/regresiones y revisión independiente satisfechos; ninguna dispensa. Coordinador: `py -3 tmp/t081b5-previews/check_docs.py`, 13 Markdown/342 enlaces locales/155 anclas correctos; `git diff --check`, código 0. Corregida durante el cierre una ancla errónea de desarrollo local antes de la comprobación final; sólo metadatos después del dictamen.

Traspaso: main/HEAD `bc9bdb1`, cambios locales de código, tests, lanzador y documentación de esta entrega; seis nuevos archivos de fuente/UID en scripts/game y tests. Sin trabajo ajeno previo conocido, commit ni push. T08.1b14 cerrada en su alcance aislado; P08 abierta. Para continuar: recuperar GitHub y este traspaso, preparar el contrato T08.1b15 propuesto sin rehacer T08.1b13/14 ni interpretar el fixture de limpieza como fin de turno reglamentario.

## T08.1b13 — Contrato de permanentes M3/M4

Publicación 2026-11-13 autorizada mediante «haz commit y push». Registro previo R0 de empaquetado: objetivo publicar los diez Markdown revisados, sin cambios semánticos; coordinador responsable. Fetch confirma HEAD/origin/main en `4905b4e`. Reutilizar revisión favorable, comprobar enlaces/anclas, diff e índice, commit/push y verificar remoto/árbol limpio. Ninguna dispensa. El commit que contiene esta nota publica T08.1b13; las menciones inferiores sin publicación son históricas. Siguiente objetivo T08.1b14 sin iniciar.

2026-11-13. [Registro previo R2](tasks.md#t081b13--contrato-de-permanentes-m3m4), iniciado el 2026-11-12. Fetch correcto y estado publicado leído en `4905b4e129dd736bd8cd5d08c0cba6b3c14db3bb`, igual a HEAD/main, árbol inicialmente limpio. Coordinador único escritor. Se inspeccionaron CompetitiveStart, MissionPlay/MissionAdvance, TurnCleanup y GameProjection: perfiles incompatibles entre sí, sólo cinco cartas en el cierre actual y ausencia de recibos en la primitiva de limpieza. El contrato conserva estas fronteras y planifica un adaptador coherente, sin retirar guardas.

`permanent_rules` (sdd_rules nativo, Sol/high) contrastó visualmente SRC-001 pp.6/8–9/14/17 y consultó la FAQ oficial vigente, sin corrección específica M3/M4; reutilizó la transcripción previamente cotejada de SRC-005. Dictamen favorable al comportamiento: M3 +2 y luego +3 si primero, repetición en inicio como elección técnica; M4 extra inmediato de dos y nueva mano de seis, incluida limpieza del turno de llegada; robo corto y prioridad terminal según DEC-032/034. Sin nueva decisión de reglas ni dispensa humana.

[Contrato y escenarios previstos PERM-01–06](permanentes-misiones.md). `permanent_review` (sdd_reviewer nativo, Sol/high) revisó contrato completo, diff, fuentes/DEC y APIs, sin hallazgos bloqueantes ni cambios semánticos solicitados. Confirmó las fronteras de perfiles y ausencia de entrada a limpieza habilitada. Ejecutó `git diff --check`, código 0, e inspeccionó el comprobador documental. El coordinador ejecutó `py -3 tmp/t081b5-previews/check_docs.py`: 10 Markdown, 258 enlaces locales y 128 anclas correctos, incluido el archivo nuevo; el script también conserva sus comprobaciones de inventario. Godot no ejecutado: no cambia código ni datos y los escenarios pertenecen a T08.1b14. Versiones actuales conservadas; snapshot 4 sólo especificado. Visual/red no aplican a este cambio exclusivamente Markdown. Tokens/coste no disponibles.

Cumplimiento: registro previo R2, coordinador único escritor, dos delegaciones de sólo lectura, contraste de reglas y revisión independiente satisfechos; ninguna dispensa. Se reutilizaron transcripción SRC-005 y comprobador existente, sin repetir suites Godot históricas ni auditar fuentes ajenas al objetivo. Sin retrabajo semántico tras revisión; cierre sólo de metadatos y comprobación documental final.

Traspaso: T08.1b13 completada documentalmente y revisada, cambios locales exclusivamente documentales sobre `4905b4e`, sin commit/push. Próximo objetivo T08.1b14: implementar el perfil cerrado M3/M4/M7 empezando por esquema/marcas y composiciones de autoridad. Permanecen pendientes entrada a limpieza, cartas generadoras de puntos, catálogo restante, producto, P04 externa y modos con rival.

## T08.1b12 — Resolutor automático de misiones M5/M6/M7

2026-11-12. Publicación autorizada expresamente mediante «haz el commit y el push». Empaquetado R0 del coordinador sobre `2bc058cde2ae0abfacbedb081294ed94e5b0a18e`, igual a HEAD/origin/main tras fetch. Objetivo/aceptación: publicar los 35 archivos revisados de T08.1b12 (incluidos cuatro scripts nuevos y sus UID), comprobar enlaces/diff, alcance del índice y exclusión de fuentes locales; verificar después HEAD remoto y árbol limpio. Se reutilizan las 13 suites/5.418 comprobaciones y la revisión independiente favorable, sin cambios funcionales posteriores. Plan: actualizar esta nota y memoria de publicación, comprobar, commit/push y confirmar GitHub. Ninguna dispensa. El commit que contiene esta nota identifica la publicación; las menciones inferiores a trabajo local sin publicar conservan el estado anterior al permiso.

2026-11-12. [Registro previo R2](tasks.md#t081b12--resolutor-automático-de-misiones-m5m6m7). T08.1b11 publicada/verificada en `2bc058cde2ae0abfacbedb081294ed94e5b0a18e`, igual a HEAD/main tras fetch y árbol limpio. El encargo «haz el commit y el push y vamos con lo siguiente» continúa este objetivo sin autorizar publicar su implementación. Se reutiliza contraste SRC-001/002/005 de T08.1b11 y DEC-034.

Implementados esquema 3/motor `p08-missions-1/godot-4.7.2`, primeras llegadas, recurso neto `mision`, resultado terminal y perfil cerrado de M5/M6/M7. Catálogo v2 real completo; personajes/pista/cartas y reservas son fixtures. La fuente de autoridad tipada selecciona el último estado; no hay carga desde clientes ni persistencia de disco. El punto de misión aún carece de generador de producto. Nueva llamada Training `advance_for_mission` comparte núcleo con inicio conservando cada guarda. La limpieza reinicia `mision`.

Godot `4.7.2.stable.official.ed1daf0bf`. Ejecuciones mediante `tools/godot.ps1 -GodotPath C:/Users/pablo/Downloads/godot/Godot_v4.7.2-stable_win64_console.exe -Action <suite>`. Logs locales ignorados `tmp/godot/<suite>.log`. Prueba nueva `test-mission-advance`: **878 comprobaciones**, código 0, incluido snapshot esperado integral tras premio M5. Total con regresiones: **5.418 comprobaciones en 13 suites**. Regresiones aprobadas sin errores de script: estado 2.065, motor 102, preparación 175, ciclo 269, limpieza 561, secuencias 253, Funding 205, entrenamiento 295, inicio 199, catálogo de misiones 138, catálogo v1 220 y arranque 58. Los rechazos de carga anunciados en las suites negativas son esperados.

| AC | Evidencia y límites |
| --- | --- |
| MIS-01 | 2/3/4 plazas, pago/progreso unitario, reparto, techo, actor/revisión/payload inválidos, saldo cero y contabilidad incompatible. |
| MIS-02 | Normal/extra, primeros intermedios distintos de cima, varias plazas y conservación tras eliminación; cap de salud y Training sucesivo. |
| MIS-03 | Reenvío/ID conflictivo/carga, fallo en segundo premio de recursos, segunda ficha/contador y Training tras normal; snapshot entero conservado en rechazos. Contenedores readonly/tipados rechazados antes de escribir. |
| MIS-04 | No ejecutado: permanentes de otras misiones fuera del perfil. |
| MIS-05 | Tercera cima de M5, M6 o M7 en 2/3/4 plazas, sin premios, recibo/restauración terminal, otro primer finalista y falsificaciones. Cuatro Atium sin Confrontación no gana. |
| MIS-06 | Snapshot viejo, modo rival, catálogo/descriptores modificados, modificador/obligación desconocidos, fuente y última revisión, motor ya cargado, proyección por plaza y secretos distintos con misma vista ajena. Pausas/elecciones no ejecutadas: fuera del perfil. |

Responsables: coordinador, nuevos módulos/tests, lanzador e integración/documentos; `mission_schema` (sdd_developer, Sol/medium), esquema/constructor/proyección/Training/limpieza y ajustes de fixtures/tests existentes. Separación por archivos; Godot sólo coordinador en serie. `mission_impl_review` (sdd_reviewer, Sol/high), revisión independiente favorable tras examinar código, diff, contrato, rutas P07/Training, catálogo, pruebas/logs y delta documental. Sin dispensa. Dos delegaciones, sin descendientes. Se reutilizan lecturas/contraste y resultados de cada suite sin repetir importaciones por revisor; no hay métricas de tokens/coste disponibles.

Correcciones previas al cierre: permiso del entorno impedía certificados/ajustes Godot; rerun autorizado fuera del aislamiento. Constante Projection de un test chocaba con tipo builtin; renombrada ViewBuilder. Dos claves creadas con sintaxis de propiedad eran StringName, rechazadas correctamente por el contrato de estado; corregidas a claves String explícitas. Casos combinados de outcome no-null y dependencias malformadas añadidos, sin modificar el validador para aceptar datos inválidos. Revisión final favorable sin bloqueantes. La mejora propuesta de comprobar el snapshot premiado completo se incorporó en `_test_exact_delta` y se reejecutó la suite de misiones. El revisor no duplicó ejecuciones Godot; el coordinador comprobó códigos, marcas y ausencia de errores de script. Metodología R2 satisfecha: registro previo, plan/propietarios, contraste reutilizado, pruebas, revisión, correcciones y memoria; ninguna dispensa. UI/red no aplican a este servicio sin integración gráfica ni transporte, y sus puertas siguen pendientes para producto.

Traspaso: T08.1b12 completada y verificada localmente sobre main/`2bc058c`; sin commit/push de esta implementación. Cambios en nuevos módulos/tests de misión y UID, esquema/constructor/proyección/Training/limpieza, fixtures/tests afectados, lanzador y documentos de contrato/memoria. Las fuentes locales v2 ya preparadas permanecen excluidas de Git; el lote de datos no se modifica. Próximo objetivo T08.1b13: especificar la integración de permanentes de M3/M4 y su aplicación única en inicio/limpieza antes de implementarla; no seleccionar aún misiones con elecciones sin sus contratos. P08 y producto siguen abiertos; no hay turno completo, generador real de puntos, persistencia/reconexión ni validación externa P04. Token/coste: no disponible. Comprobación final: 14 Markdown, 346 enlaces locales y 142 anclas correctos; `git diff --check` con la configuración Git del proyecto termina en 0. Sólo avisos habituales LF/CRLF, sin cambios de configuración. Estado Git limitado a la entrega local enumerada, sin archivos de fuentes físicas ni modificaciones de catálogo.

## T08.1b11 — Contrato del avance de misiones competitivo

2026-11-12. Publicación autorizada mediante «haz el commit y el push y vamos con lo siguiente». Empaquetado R0 del coordinador, sobre `7f8c579`, igual a HEAD/origin/main tras fetch. Plan y aceptación: comprobar enlaces/diff y alcance de los diez Markdown revisados, publicar y verificar sincronización remota/árbol limpio. Se reutilizan contraste y revisión R2; el commit que contiene esta nota identifica la publicación. La implementación futura no queda autorizada para publicar por este permiso.

2026-11-12. [Registro previo R2](tasks.md#t081b11--contrato-del-avance-de-misiones-competitivo). Fetch y estado publicado contrastados en `7f8c579550cf4752d25c904208d59a63eae36448`, igual a HEAD/main y árbol inicialmente limpio. Coordinador único escritor. `mission_rules` (sdd_rules, Sol/high) contrastó directamente SRC-001 pp.8–9/14/17, FAQ vigente y SRC-005. El usuario resolvió los dos órdenes ambiguos mediante DEC-034. [Contrato, aceptación y plan](avance-misiones.md). `mission_review` (sdd_reviewer, Sol/high) dio dictamen favorable sin bloqueantes tras comprobar el contrato, delta documental, TrainingAdvance, P07, SequenceRegistry y la FAQ en vivo. Reprodujo 217 enlaces locales, 89 anclas y `git diff --check`, correctos. Se aclaró que los mapas iniciales llevan valores null con las claves del recorrido de cada perfil y que M6 necesita un núcleo compartido sin falsear la fase. Godot y MIS-01–06 no ejecutados: esta entrega no cambia código.

Cumplimiento: objetivo/AC, riesgo R2, plan y propietario registrados antes de editar; contraste de reglas y revisión independiente satisfechos, dos delegaciones sin descendientes, ninguna dispensa. Se corrigió el desfase del documento de perfil que aún describía el lote ya validado como pendiente/borrador. Comprobación final tras actualizar la memoria: 10 Markdown, 248 enlaces locales y 113 anclas correctos, `git diff --check` correcto; estado Git con los diez Markdown de esta entrega (incluido el contrato nuevo).

Traspaso: T08.1b11 completada documentalmente, main sobre `7f8c579`, cambios locales exclusivamente Markdown, sin commit/push. DEC-034 aceptada; snapshot 3, resultado y primeras llegadas sólo especificados, motor actual sin cambios. Primer paso T08.1b12: implementar el perfil aislado M5/M6/M7, empezando por esquema/validación y núcleo de entrenamiento compartido, según MIS-01–06. Permanentes de inicio, elecciones de M1/M2/M8, catálogo restante, integración de producto, red externa y rival conservan sus dependencias. No atribuir fidelidad de partida ni pruebas ejecutadas a este contrato.

## T08.1b10 — Validación y lote de catálogo de misiones

2026-11-12. Publicación autorizada expresamente por el usuario. Empaquetado R0 a cargo del coordinador sobre `cfecee9`, igual a HEAD tras el fetch. Aceptación y plan: comprobar enlaces, diff, alcance del índice y exclusión de los escaneos, publicar en `main` y verificar la rama remota y el árbol limpio. Se reutilizan las pruebas y la revisión R2. El commit que incorpora esta nota identifica la publicación.

2026-11-12. [Registro previo R2](tasks.md#t081b10--validación-y-lote-de-catálogo-de-misiones). Contrato publicado y comprobado por fetch en `cfecee9f5d9955a223c6bb3dbf8a3d02f46e73ac`, igual a HEAD de main antes de implementar. [Comandos de preparación y prueba](../../desarrollo-local.md#catálogo-de-misiones).

Godot `4.7.2.stable.official.ed1daf0bf`, lanzador `tools/godot.ps1`, código 0 y sin errores de script en la ejecución final. **967 comprobaciones**: misiones 138, catálogo v1 220, arranque 58, preparación 147, Funding 205 e inicio 199. Los fallos de carga de los casos negativos son esperados. CAT-MIS-01–03 verifican compatibilidad, 96 casillas, 17 premios intermedios y ocho cimas, referencias y rechazos. CAT-MIS-04 verifica huellas, sustitución coordinada, recuperación y carga separada. CAT-MIS-05 verifica la frontera del catálogo frente a los perfiles aislados.

`mission_sources` (sdd_developer, Sol/medium) implementó y ejecutó `tests/mission_sources_test.ps1` con ambos originales y Godot 4.7.2. Código 0 y `MISSION_SOURCES_OK`: precomprobación de destinos, copia exacta, reejecución, exclusión de Git e importación y ZIP de exportación de prueba con control positivo. `mission_impl_review` (sdd_reviewer, Sol/high) dio dictamen favorable tras el guard de tipos de fuente v2 y la regresión correspondiente. Su prueba aislada cubrió 242 mutaciones sin errores de script. Dos delegaciones sin descendientes ni dispensas.

Los originales quedan en la digitalización y sus copias de trabajo en `evidencia_local/`. Queda pendiente el resolutor y la admisión de producto. Siguiente paso propuesto: especificar la transacción de avance competitivo, el registro de primeras llegadas, la aplicación de premios y la prioridad de finales.

## T08.1b9 — Contrato de catálogo para las misiones

2026-11-12. Publicación autorizada por el usuario. Empaquetado R0 del coordinador sobre `55a9399`: comprobar alcance, enlaces e índice, publicar en main y verificar remoto y árbol limpio. Se reutiliza la revisión R2. El commit que incorpora esta nota identifica la publicación y la nota local inferior es histórica.

2026-11-12. [Registro previo R2](tasks.md#t081b9--contrato-de-catálogo-para-las-misiones). Fetch y estado publicado contrastados en `55a9399b52e76c39ba75f3d52cf373f8baf699e2`, igual a HEAD con árbol inicialmente limpio. Se reutiliza el contraste de T08.1b8. [Contrato y CAT-MIS-01–05](catalogo-misiones.md).

Se comprobaron las dos huellas SHA-256 contra SRC-005, el JSON de la cima de M2, los cinco casos de aceptación, 239 enlaces locales, 112 anclas y `git diff --check`. `mission_contract_review` (sdd_reviewer, Sol/high) dio un dictamen favorable tras revisar los casos añadidos de sustitución de fuentes, conflicto de destino y rechazo desde un perfil por lo demás admisible. Una delegación sin descendientes ni dispensas.

Especificación completada localmente. Godot, el lote ejecutable y la exportación de prueba quedan para T08.1b10. Primer paso: añadir la rama de validación v2 conservando la carga de v1. Sin commit ni push.

## T08.1b8 — Transcripción de las ocho misiones

2026-11-12. Publicación autorizada expresamente por el usuario. Empaquetado R0 a cargo del coordinador sobre la base publicada `916c81a05f84ff18c65335eaa8ade347ed59b0d4`, igual a HEAD tras el fetch. Aceptación y plan: aclarar el traspaso sin alterar la transcripción revisada, comprobar enlaces, diff e índice, publicar en `main` y comprobar que la rama remota contiene el commit y el árbol queda limpio. Se reutiliza la revisión R2. El commit que incorpora esta nota identifica la entrega.

2026-11-12. [Registro previo R2](tasks.md#t081b8--transcripción-de-las-ocho-misiones). Fetch y estado publicado contrastados en `916c81a05f84ff18c65335eaa8ade347ed59b0d4`, igual a HEAD con árbol inicialmente limpio. Las dos huellas SHA-256 coinciden con SRC-005. El coordinador leyó las dos hojas originales y contrastó el ejemplo de SRC-001 p. 14 y la leyenda de p. 17. `mission_rules` (sdd_rules, Sol/high) cotejó de forma independiente las casillas y recompensas de las ocho misiones, la FAQ SRC-002 y DEC-031. [Transcripción y encaje con P06](../../referencias/misiones-competitivas.md).

Verificación de cobertura: ocho códigos y localizadores únicos, 17 casillas intermedias con premio y ocho cimas, cuatro de premio permanente y cuatro de premio único. Comprobados 198 enlaces locales, 91 anclas y `git diff --check`. `mission_review` (sdd_reviewer, Sol/high) emitió dictamen favorable tras revisar el lote, fuentes, P06 y documentación. Se incorporó su sugerencia de acotar la comparación de posiciones a competitivo y remitir a REG-065 para solitario. Godot queda fuera de esta verificación documental. Dos delegaciones sin descendientes ni dispensas.

Transcripción documental completada. El lote conserva estado de borrador para catálogo. Primer paso siguiente propuesto: especificar extras del primero, duración y aplicación de los premios y efectos sin representación, y cómo registrar en P06 los escaneos existentes de SRC-005.

## T08.2i — Robo personal con mazo y descarte agotados

2026-11-12. El usuario autoriza «haz commit y push» para T08.2i. Empaquetado R0 a cargo del coordinador: fetch y estado remoto comprobados en `02e38c7`; revisar alcance del índice y espacios, publicar en `main` y verificar coincidencia con GitHub y árbol limpio. Se reutilizan las pruebas y la revisión R2 del cambio funcional. El commit que incorpora esta nota identifica la entrega publicada; el estado local descrito abajo es histórico.

2026-11-12. [Registro R2](tasks.md#t082i--robo-personal-con-mazo-y-descarte-agotados) y [ROBO-01–03](spec.md#t082i--robo-personal-con-mazo-y-descarte-agotados). Base publicada `02e38c723ac86f0492f2f5c64abb2a9b852030bf`, igual a HEAD y origin/main, árbol inicial limpio. Contraste reglamentario reutilizado de DEC-032. El coordinador implementó el cambio y versionó el motor; `draw_tests` (sdd_developer, Sol/medium) fue propietario de las suites de ciclo y limpieza.

Godot `4.7.2.stable.official.ed1daf0bf`, lanzador `tools/godot.ps1`. Código 0 y marcas de éxito en once suites, **4.295 comprobaciones**: ciclo 269, limpieza 561, estado 2.006, motor 102, preparación 147, secuencias 253, Funding 205, entrenamiento 275, inicio 199, catálogo 220 y arranque 58. Los ocho errores de carga de arranque son casos negativos esperados. Los intentos iniciales de importación se corrigieron usando la distribución portátil completa y ejecutando fuera del aislamiento que impedía leer el almacén de certificados.

`profile_review` (sdd_reviewer, Sol/high) emitió dictamen favorable tras revisar el diff funcional y nueve logs de Godot. El coordinador verificó las dos regresiones restantes. Dos delegaciones sin descendientes ni dispensas. Métricas de tokens no disponibles. Comprobados 238 enlaces locales, 106 anclas y diff limpio. Entrega funcional verificada en el árbol local, sin commit ni push.

Traspaso: esquema 2, motor `p08-draw-1/godot-4.7.2`. El cambio se aplica por la misma llamada de `TurnCleanup` al ciclo y deja los snapshots anteriores fuera de la versión admitida. Las otras dos reglas de DEC-032 requieren el resolutor de habilidades y el paso del Lord Legislador. Siguiente lote de contenido: M1–M8.

## T08.1b7 — Desbloqueo tardío, robo y finales del rival

2026-11-12. Publicación autorizada por «haz el commit y push y ponte con los arreglos». Empaquetado R0 por el coordinador sobre `5fe5e65`, con revisión del índice, enlaces y diff. El commit que contiene esta nota identifica la entrega documental. Se comprobará su recepción en `origin/main` y el árbol limpio antes de iniciar el arreglo del robo personal.

2026-11-12. [Registro previo R2](tasks.md#t081b7--desbloqueo-tardío-robo-y-finales-del-rival). Fetch y estado publicado contrastados en `5fe5e65b632e78a6a4c64b3894fa646fcde171a9`, igual a HEAD y árbol limpio. El usuario resuelve DUD-004/006 mediante DEC-032. `profile_rules` (sdd_rules, Sol/high) contrastó SRC-001 pp. 6, 12–13 y 19–20, SRC-002 y las guardias vigentes en `CardCycle` y `TurnCleanup`. [Escenarios previstos](spec.md#t081b7--reglas-acordadas-para-desbloqueo-robo-y-finales). Siguiente paso: revisar y transcribir M1–M8.

`profile_review` (sdd_reviewer, Sol/high) emitió dictamen independiente favorable tras precisar la condición para intentar el robo rival y distinguir las dos victorias de prueba. Coordinador único escritor, dos delegaciones acotadas sin descendientes ni dispensas. Métricas de tokens no disponibles. Comprobados 257 enlaces locales, 110 anclas y diff limpio. Entrega documental completada en el árbol local, sin commit ni push. No se ejecutó Godot; el motor y sus pruebas quedan para las tareas de implementación.

## Publicación conjunta de T08.1b5 y T08.1b6

2026-11-12. El usuario autoriza expresamente «haz commit y push de todo». Empaquetado R0 a cargo del coordinador: publicar en `main` los cambios documentales ya revisados de T08.1b5 y T08.1b6. El fetch confirmó que la base local y publicada coincide en `69c1ef254bf2fb78b71454da2518567c351e1303`. Aceptación: revisar el alcance del índice, comprobar enlaces y espacios, publicar y verificar coincidencia de HEAD con GitHub y árbol limpio. Se reutilizan las revisiones R2 de las entregas; el empaquetado no cambia reglas. El commit que incorpora esta nota identifica la publicación y las notas de trabajo local inferiores son históricas. Siguiente paso: revisar y transcribir M1–M8.

## T08.1b6 — Resoluciones de reglas del perfil competitivo

2026-11-12. [Registro previo R2](tasks.md#t081b6--resoluciones-de-reglas-del-perfil-competitivo). HEAD y origin/main comprobados en `69c1ef254bf2fb78b71454da2518567c351e1303`. T08.1b5 se conserva en el árbol local. [DEC-031](../../decisiones.md#dec-031--criterios-de-la-edición-española-y-reglas-competitivas) procede de la indicación expresa del usuario sobre edición, orden de inicio, premios y posiciones. DUD-005 se resuelve al comparar plazas y DUD-008 se resuelve con el texto español. Los escenarios PERF-03/05/06 recogen las consecuencias para la futura implementación.

`profile_rules` (sdd_rules, Sol/high) contrastó SRC-001 pp. 14 y 20 y reutilizó el cotejo de SRC-002/005. `profile_review` (sdd_reviewer, Sol/high) emitió dictamen favorable tras precisar el caso de dos cubos, la prioridad del primer finalista y el alcance por modo. Coordinador único escritor, dos delegaciones sin descendientes ni dispensas. Métricas de tokens no disponibles.

Comprobados 263 enlaces locales, 103 anclas y diff sin errores de espacios. Entrega documental completada en el árbol local, sin commit ni push. Godot y PERF-01–06 corresponden a la futura integración. Siguiente paso: revisar y transcribir M1–M8 con DEC-031 y P06.

## T08.1b5 — Delimitación del perfil competitivo de producto

2026-11-12. [Registro previo R2](tasks.md#t081b5--delimitación-del-perfil-competitivo-de-producto). Fetch, estado publicado y árbol inicial contrastados en `main` y `origin/main` en `69c1ef254bf2fb78b71454da2518567c351e1303`. [Delimitación y casos de integración](perfil-competitivo-producto.md).

- **Inventario.** Composición contrastada con SRC-001, SRC-004, DEC-027 y la auditoría de mercado. Se localizaron los cuatro personajes y las ocho misiones y se cotejaron Guardadora y Confrontación en SRC-005. El recuento de la auditoría devuelve 65 diseños y 82 copias, 60 acciones y 22 aliados.
- **Admisión.** Contrastadas las comprobaciones de `GameSetup` y `CompetitiveStart`. El perfil de producto necesita contenido revisado, comprobación exacta del manifiesto y reglas de obligaciones, premios y finales. La diferencia de fuentes sobre el nivel II queda en [DUD-008](../../referencias/dudas.md).
- **Traspaso.** Primer lote de contenido propuesto: revisar y transcribir las ocho misiones M1–M8 contra los originales y P06. Conservar como borrador los premios o condiciones pendientes. PERF-01–04 son comprobaciones previstas de integración. Godot no se ejecuta en esta entrega documental.

Revisión independiente favorable. `profile_rules` (sdd_rules, Sol/high) contrastó el reglamento, la FAQ y los originales. `profile_review` (sdd_reviewer, Sol/high) reprodujo los recuentos, comprobó las huellas de SRC-005 y revisó el delta final. A raíz de la revisión se precisaron la activación opcional del nivel II y el caso de restauración con una obligación futura de Guardadora. El coordinador fue el único autor. Dos delegaciones acotadas, sin descendientes ni dispensas. Métricas de tokens no disponibles.

Comprobación final del coordinador: 198 enlaces locales, 77 anclas y diff sin errores de espacios. Entrega documental completada en el árbol local, sin commit ni push. P08 continúa abierta por contenido e integración.

## T08.1b4 — Implementación del inicio competitivo

Publicación autorizada por el usuario el 2026-11-12. Empaquetado R0 a cargo del coordinador, con fetch confirmado en `fd75e23`. Se comprueban el alcance del índice, el diff y la coincidencia con `origin/main` después de publicar. El traspaso inferior recoge el estado previo a esta publicación.

2026-11-12. Contrato T08.1b3 publicado con autorización en `fd75e232657f7e477b8f2e92ba685785ddea392c`, coincidente con HEAD y origin/main por fetch. [Registro previo R2](tasks.md#t081b4--implementación-del-inicio-competitivo). Coordinador autor del adaptador, motor, lanzador y documentación. `start_tests` (sdd_developer Sol/medium) fue propietario de la suite y fixtures. Contraste reglamentario de T08.1b3 reutilizado y FAQ consultada. Dos delegaciones acotadas, sin descendientes ni dispensas. Métricas de tokens no disponibles.

| Criterio | Resultado en el perfil de prueba |
| --- | --- |
| INI-01 | Preparación real P08 con fixtures para 2/3/4 plazas, incluidas cantidades integrales de JSON. Inicio de cada plaza, avance, capacidad, Atium, manos intactas y Funding en libre. |
| INI-02 | Recibo idéntico tras otro commit, restauración y finalización. Rechazo de ID distinto en la revisión anterior, turno anterior, llamada reentrante y uso público del tipo o prefijo reservado. |
| INI-03 | Se excluye el perfil con Keeper derrotado y un pendiente, y se rechazan marcas desconocidas incluso fuera de juego. |
| INI-04 | Puerta cerrada con único superviviente, misiones de otra plaza completadas, perfil incompatible con Confrontation o partida finalizada. La cuarta ficha obtenida por entrenamiento permite abrir libre. |
| INI-05 | Se rechazan carga anterior, perfil o fuente incompatibles, solicitudes inválidas y fallos de candidato. Se prueba rollback del avance y, por separado, del commit P07 al intentar añadir el recibo 10.001. La vista ajena conserva la privacidad. |

Godot `4.7.2.stable.official.ed1daf0bf`. `tools/godot.ps1 -Action test-start` con `-GodotPath` de [desarrollo local](../../desarrollo-local.md#inicio-competitivo-aislado) registró **199 comprobaciones** y `P08_START_OK`. Diez regresiones sumaron **4.053** (entrenamiento 275, preparación 147, estado 2.004, secuencias 253, Funding 205, limpieza 527, motor 102, ciclo 262, catálogo 220 y arranque 58). Todas salieron con código 0 y sin errores de script. Los avisos de rechazo en la suite y los ocho errores de carga del arranque corresponden a entradas negativas.

`training_review` (sdd_reviewer Sol/high) reprodujo un error de script con una fuente de restauración cuya firma tenía dos argumentos de tipo incorrecto. La interfaz tipada `SnapshotSource` y el caso de rechazo corrigen el fallo. Revisión final independiente favorable tras repetir la comprobación y revisar la prueba de capacidad de recibos.

Comprobados 222 enlaces locales, cuatro anclas y espacios del diff y de los archivos nuevos.

Traspaso local en `main` desde `fd75e23`, sin commit ni push de T08.1b4. Esquema 2, versión compartida de motor `p08-start-1/godot-4.7.2`. Restauración y entregas posteriores usan fixtures. El perfil de producto requiere catálogo, obligaciones y finales aplicables. Primer paso: contrastar material disponible y delimitar definiciones y misiones del manifiesto competitivo. La persistencia duradera, el transporte y los modos con rival conservan su trabajo propio.

## T08.1b3 — Contrato del inicio único competitivo

Publicación autorizada por el usuario el 2026-11-12. Empaquetado R0 del contrato revisado a cargo del coordinador, con fetch confirmado en `ab3ef55`. Se comprueban alcance del índice, diff y coincidencia con `origin/main` tras publicar.

2026-11-12. T08.1b2 publicada en `ab3ef5573596713ec03a06a965d25e7b8cfc33d9`. Fetch posterior, documento remoto y HEAD coincidieron con árbol limpio al comenzar T08.1b3. [Registro previo R2](tasks.md#t081b3--contrato-del-inicio-único-competitivo). Coordinador único escritor. `training_rules` (sdd_rules Sol/high) contrastó SRC-001/002 y la lectura SRC-004 para avance, Keeper y finales. Dos encargos acotados de solo lectura, sin descendientes ni dispensas. Métricas de tokens no disponibles.

`training_review` (sdd_reviewer Sol/high) revisó el [contrato](inicio-competitivo.md) frente a P07 y T08.1b2. Detectó dos riesgos de doble aplicación, por sustitución del estado con una revisión anterior y por transacciones intercaladas. El contrato limita la restauración al último estado confirmado para ese perfil en un motor vacío y exige una autoridad que serialice las operaciones. INI-02/05 cubren ambas correcciones. Dictamen documental final favorable.

ENT-AC-04 queda especificado con INI-01–05 y plan de implementación. Comprobados 176 enlaces locales, cinco anclas y `git diff --check`. Los escenarios de Godot quedan pendientes de ejecución en T08.1b4. T08.1b3 sólo cambia documentación.

Traspaso en `main` desde `ab3ef55`, con T08.1b3 local. Siguiente objetivo T08.1b4. Empezar por separar las entradas interna y pública sobre la transacción compartida de P07, fijar la admisión del perfil aislado y ejecutar INI-01–05. La integración de producto requiere catálogo, obligaciones y finales resueltos. Los modos con rival y P15 conservan su trabajo propio.

## T08.1b2 — Operación interna de avance competitivo

El usuario autorizó el commit y push de T08.1b2 el 2026-11-12. Empaquetado R0 a cargo del coordinador sobre `c6f11e8`, confirmado mediante fetch. Se comprueba que el índice contiene sólo la entrega revisada, que el diff no tiene errores y que el commit coincide con `origin/main` tras publicar. El traspaso inferior describe el cierre previo a la publicación.

2026-11-11. Recuperación con fetch en `c6f11e8367f50fcef818dc68d00cb4719a7eb6bf`, igual a HEAD de main, árbol inicialmente limpio. R2 con [registro previo](tasks.md#t081b2--operación-interna-de-avance-competitivo). Coordinador único autor. `training_rules` (sdd_rules Sol/high) contrastó las recompensas contra SRC-001/002/004 y confirmó las fronteras del paso. Se reutilizaron el inventario visual y el contrato revisado. Sin dispensas.

| Criterio | Evidencia |
| --- | --- |
| ENT-AC-01 | Recorrido completo de la pista competitiva de 2 a 4 plazas, primer avance con límite inicial 1, tres aumentos acumulativos y tres niveles derivados. Rechazo de perfiles con marcas reordenadas, identidad distinta o catálogo incompatible. |
| ENT-AC-02 | Incrementos en 11 y 16, llegada a 20 y dos avances posteriores. Comparación del delta completo, incluidos saldo, fichas, contador y Atium previamente usado. |
| ENT-AC-03 | Entradas adversas, colisión, desbordamientos, contenedores incompatibles y candidato que rebasa el presupuesto estructural. Original intacto en rechazo, candidato separado en éxito, conservación de RNG, fases y cierres/recibos Funding. |
| ENT-AC-04 | Pendiente de integración del inicio único, obligaciones y finales de partida antes de abrir `libre`. |

Godot `4.7.2.stable.official.ed1daf0bf` desde [la ruta local comprobada](../../desarrollo-local.md#avance-de-entrenamiento-competitivo). Se ejecutó `powershell -NoProfile -ExecutionPolicy Bypass -File tools/godot.ps1 -Action <acción> -GodotPath <ruta>` para cada suite. El entorno restringido bloqueaba el almacén de certificados y el guardado de preferencias de Godot. La ejecución con acceso a ambos completó importación y pruebas.

Las diez acciones pasaron con código 0 y sin errores de script. En total, **4.053 comprobaciones**. Entrenamiento 275, preparación 147, estado 2.004, secuencias 253, Funding 205, limpieza 527, motor 102, ciclo 262, catálogo 220 y arranque 58. Los ocho errores de carga del arranque corresponden a casos negativos previstos.

Comprobados 187 enlaces locales, las cuatro anclas de esta entrega y `git diff --check`.

`training_review` (sdd_reviewer Sol/high) reprodujo un error de script al comparar campos mal tipados del perfil y de las definiciones. El coordinador añadió guardas de tipo y seis casos de rechazo, y repitió las diez suites. El revisor repitió 24 variantes puntuales en un proyecto temporal y confirmó el rechazo sin errores de script. Dictamen final favorable para ENT-AC-01 a 03. Dos delegaciones acotadas de solo lectura, sin descendientes. Métricas de tokens no disponibles.

Traspaso local en `main` desde `c6f11e8`, sin commit ni push de esta entrega. El módulo usa un perfil de prueba y conserva esquema 2 y motor `p08-funding-1/godot-4.7.2`. Siguiente objetivo: especificar la transacción de inicio único ENT-AC-04, con reenvíos, obligaciones pendientes como Keeper y condiciones de final. El perfil de producto, la activación de habilidades y los modos con rival requieren entregas posteriores.

## T08.1b1 — Contrato del avance competitivo

Publicación autorizada el 2026-11-11. Empaquetado R0 a cargo del coordinador, con fetch confirmado en `13bb11f` y revisión independiente previa del contrato. Aceptación: publicar el contrato revisado y mantener el estado coherente con Git. Comprobar enlaces, índice y coincidencia con el remoto. Los datos de trabajo local del traspaso inferior corresponden al cierre previo a la publicación.

2026-11-11. Contrato documental R2 completado. Fetch y estado publicado comprobados en `13bb11f`, publicación de la revisión de originales. Registro previo en tasks.md. Coordinador único escritor. `advance_rules` (sdd_rules Sol/high) contrastó SRC-001, FAQ vigente y SRC-004 para primera ronda, umbrales, Atium terminal y Keeper. `advance_review` (sdd_reviewer Sol/high) revisó el contrato y su delta frente a las APIs e invariantes actuales. Dictamen favorable tras concretar guardas de fase/vida, orden de la pista, y los casos de Keeper y final de partida en la futura integración. Sin dispensas ni descendientes.

[ENT-AC-01 a 04](avance-entrenamiento.md#aceptación-y-pruebas-previstas) están especificados y revisados. Enlaces locales y `git diff --check` comprobados. No se ejecutó Godot porque el cambio es documental. Los casos funcionales siguen previstos, no aprobados por esta revisión.

Traspaso: `main`, HEAD/origin/main `13bb11f`, sólo documentación local sin commit ni push. T08.1b2 implementará y probará ENT-AC-01 a 03 con un perfil aislado ligado a SRC-004. ENT-AC-04, obligaciones de inicio y apertura de `libre` siguen pendientes de integración. Mantener DUD-004 y modos del rival fuera de esta subentrega.

## T08.1b — Revisión previa de los originales competitivos

Publicación autorizada mediante «haz commit y push y vamos con lo siguiente». Empaquetado R0 a cargo del coordinador. Fetch y estado publicado contrastados en `b07303b`, igual a HEAD. Comprobar el índice y la coincidencia remota. Se conserva la revisión independiente y la evidencia de 132 enlaces y anclas locales. Las menciones inferiores a trabajo local describen el cierre previo a la autorización.

2026-11-11. Fetch y estado publicado contrastados en `b07303b`, HEAD/main inicialmente limpio. El usuario aporta la carpeta local. Se identificaron y revisaron cinco PNG (cuatro hojas y panel), con huellas, filas, marcas e índices en [SRC-004](../../referencias/entrenamiento-competitivo.md). Los originales siguen fuera de Git. Las vistas temporales ignoradas se generaron en `tmp/t081b-inspection/`.

R2, registro previo en tasks.md, coordinador único escritor. Contraste `training_rules` (sdd_rules Sol/high) de SRC-001 y FAQ oficial vigente: primera casilla en preparación, avance incluso en primera ronda, recompensas inmediatas, Atium por avances posteriores al final, niveles y DUD-004, iconos MISSION/TRAIN. `training_review` (sdd_reviewer Sol/high) comprobó independientemente las cinco huellas/dimensiones, 21 huecos y marcas, 16 cartas y Financiación. Lectura visual favorable. Se atendieron las precisiones de estado de la tarea y fecha del índice de fuentes. Ninguna dispensa ni delegación descendiente.

Aceptación del registro previo: (1) cinco originales identificados y legibles, aprobado; (2) localizadores, huellas y lectura comprobados, aprobado; (3) distinción entre marcas visibles, reglas contrastadas y dependencias pendientes, aprobado. Enlaces locales y `git diff --check` correctos.

Traspaso: `main` en `b07303b`, cambios documentales locales. El objetivo de revisión de originales queda completado. T08.1b sigue abierta. Primer paso: especificar avance inicial y recompensas de pista con SRC-001/002/004 y casos límite, separando el desbloqueo de niveles de su ejecución. Para verificar activaciones habrá que revisar las habilidades en las fichas de personaje y conservar DUD-004. No se ejecutó Godot porque sólo cambió documentación. Sin commit ni push.

## T08.2h — Implementación de Funding

Publicación autorizada mediante «antes haz commit y push de lo actual». Empaquetado documental R0 a cargo del coordinador. Fetch y estado publicado contrastados en `f412e32`, igual a HEAD. Comprobar el índice y la coincidencia remota. Se conserva la evidencia técnica de las 3.778 comprobaciones y la revisión independiente. Las menciones inferiores a trabajo local sin publicar describen el cierre anterior a esta autorización.

2026-11-11, completada localmente, riesgo R2, revisión independiente favorable. Contrato publicado T08.2g y escenarios FUND-01–08; registro previo/responsables en tasks.md y plan de nueve suites en plan.md. Publicación anterior confirmada: main/HEAD/origin/main y `ls-remote` en `1e6c91747737d0c867a928763f0e3d11873091cf`, fetch posterior correcto y estado remoto leído antes de seleccionar esta implementación. Árbol limpio tras publicar; el permiso de commit/push se aplicó a T08.2g, no al código futuro.

Entorno recuperado: `.tools/godot/` no existe en este PC, pese a la nota del estado publicado desde otro equipo. Motor encontrado en `C:/Users/pablo/Downloads/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe`; las pruebas usarán `-GodotPath`. No se ha cambiado ni instalado el motor. Implementador `funding_impl`, perfil sdd_developer aplicado por instrucciones Sol/high (TOML leído), único propietario de código/fixtures/lanzador; coordinador conserva documentación y revisión final. Sin dispensas, descendientes, UI ni transporte nuevos.

Implementación, pruebas oficiales y revisión independiente completadas. Fuente y límite de contenido: [contrato](primer-resolutor-competitivo.md); los componentes inertes son fixtures y el catálogo español sigue sin incorporarse.

Reanudación por «retoma donde se haya quedado»: fetch actualizado correcto, HEAD/origin/main continúan en `1e6c917`; se preservan cambios locales del implementador en módulo/fixtures/suite/UID, versión del validador, prueba de estado y lanzador, además de los tres documentos de planificación. El agente se detuvo por límite de uso antes de entregar evidencia; no había log test-funding que acreditase aprobación. Se reactiva el mismo encargado y conserva propiedad de código/Godot hasta entregar, sin reiniciar la tarea ni atribuir pruebas no ejecutadas.

Resultado: [adaptador Funding](../../../scripts/game/funding_play.gd), [fixture completo](../../../tests/funding_fixtures.gd) y [suite](../../../tests/funding_play_test.gd), esquema 2/motor `p08-funding-1/godot-4.7.2`; acción `test-funding` en lanzador. No se modifican las protecciones de GameEngine. Identidad técnica canonicalizada del documento P06; el perfil sólo admite una Funding y descriptores inertes completos idénticos a las demás definiciones. Igualdad de claves independiente del orden y números integrales de JSON normalizados; el ID editorial no basta para aceptar otra versión del contenido.

| Escenario | Evidencia de la suite Funding |
| --- | --- |
| FUND-01/02 | Competitivo 2/3/4, saldo previo cero/positivo, aplicar y omitir, dos instancias distintas, Target preservado, cambios de snapshot exactos y cierre por juego. |
| FUND-03/04 | Actor/fase/modo/vida/zona/resolución, payload, definición y perfil completo, marcas dinámicas; entradas externas mutables no alteran efectos. |
| FUND-05 | Recibos antes/después de round-trip, ID contradictorio y carta ya jugada, registro vacío, claves reordenadas, JSON y contenido cambiado, rechazo de versión anterior. |
| FUND-06 | Overflow saldo/revisión/contador, omisión con saldo máximo, límite de nodos/ledger y rechazo final sin cambios; contenedor tipado incompatible sin error de script. |
| FUND-07 | Vistas reales propias/ajenas, carta jugada pública, mano/mazo ocultos y errores iguales con secretos distintos. |
| FUND-08 | Preservación de recursos persistentes/metales/salud/Target/misiones/fase; cierre no habilita limpieza; composición interna sólo desde fixture explícito en limpieza. |

Ejecución oficial del coordinador tras liberar código, nueve acciones seriales con Godot `4.7.2.stable.official.ed1daf0bf`: `powershell -NoProfile -ExecutionPolicy Bypass -File tools/godot.ps1 -Action <acción> -GodotPath 'C:/Users/pablo/Downloads/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe'`. Cada acción importa primero; todas devuelven código 0, marca final esperada y ningún SCRIPT ERROR.

| Acción | Comprobaciones |
| --- | ---: |
| test-funding | 205 |
| test-sequence | 253 |
| test-state | 2.004 |
| test-engine | 102 |
| test-setup | 147 |
| test-cycle | 262 |
| test-cleanup | 527 |
| test-catalog | 220 |
| test | 58 |

Total consolidado **3.778 comprobaciones**. Tras las tres correcciones de revisión se repitió oficialmente test-funding (205, código 0, importación limpia y sin ERROR/SCRIPT ERROR); las otras ocho suites conservan sus 3.573 comprobaciones, pues las correcciones sólo modifican funding_play.gd y su suite, sin cambios del núcleo, lanzador o fixtures comunes. Los dos errores de carga de catálogo y ocho de arranque son negativos esperados; las demás acciones no contienen ERROR, los WARNING corresponden a rechazos deliberados. Logs ignorados `tmp/godot/t082h-final-<acción>.txt` y `<acción>.log`; no acompañan otro clon, reproducir con el comando anterior. El fallo inicial restringido de certificados/ajustes no se cuenta como prueba aprobada; la ejecución oficial usa permisos normales autorizados.

Correcciones antes de revisión: caso de números JSON integrales distinto de igualdad profunda int/float, rechazo de zona Array[int] que habría emitido SCRIPT ERROR al añadir ID textual, y sustitución accidental en el argumento LogName de test-sequence detectada por el coordinador y reparada. Tras correcciones se ejecutan las nueve suites anteriores. Ninguna adaptación reglamentaria ni modificación de muestras de producto. Revisión independiente `funding_code_review`, sdd_reviewer Sol/high, solicitada sobre diff/contrato/fuentes/evidencia; dictamen técnico favorable tras corregir los tres hallazgos siguientes.

Hallazgos de revisión corregidos y confirmados por el revisor: carga admitía flags desconocidos en mano ajena que alteraban la aceptación visible de jugar Funding; comparación de descriptores Variant frente a catálogo JSON no normalizaba enteros en ambos lados; carga no correlacionaba ocurrencia Funding con el sufijo de su ID de cierre, admitiendo colisión futura. El revisor los reprodujo en un probe local ignorado (`tmp/t082h-review-probe.gd`/`tmp/godot/t082h-review-probe.log`); su arranque aislado avisó de certificados, por lo que no sustituye la ejecución oficial limpia. Corrección realizada por el mismo implementador sólo en módulo/suite Funding: validación estructural y dinámica previa a publicación; igualdad recursiva de forma/tipos con equivalencia numérica integral (fracciones rechazadas); cierre resolution_N correlacionado con funding_play_N. Regresiones A/B, comparación cruzada JSON/Variant y cierre incompatible conservan estado. Test-funding final: 205 comprobaciones aprobadas por implementador y coordinador. Revisión final favorable: `funding_code_review` confirmó las tres correcciones, sin bloqueantes residuales, y contrastó los logs oficiales consolidados; no se repiten las ocho suites sin cambios de sus dependencias.

Cumplimiento y cierre T08.2h: registro previo R2, contrato/fuentes, autor único, pruebas FUND-01–08 y regresiones, revisión independiente adversaria y tres hallazgos resueltos, memoria/traspaso completos. Implementador `funding_impl` Sol/high por instrucciones (reanuda el mismo encargo tras límite de uso) y revisor `funding_code_review` sdd_reviewer Sol/high nativo, sin descendientes. Ninguna dispensa. Coordinador y revisor verifican 14 Markdown, 208 enlaces locales y 51 anclas sin errores; `git diff --check` limpio. No se ejecutan UI/red/partida completa porque no son parte de esta API; sus puertas de fase permanecen abiertas.

Traspaso de cierre: main, HEAD/origin/main `1e6c917`, T08.2g publicada; T08.2h local sin commit/push. Archivos: módulo Funding/UID, fixture y suite/UID, versión del validador y su prueba, lanzador y 14 Markdown de especificación/memoria. Ningún cambio ajeno descartado. Resultado: primer programa reglamentario acotado con aplicación/omisión, admisión de perfil y cierre/recibos coherentes; no catálogo oficial ni turno completo. Primer paso del siguiente objetivo: revisar material de entrenamiento/panel competitivo para preparar T08.1b, comprobando disponibilidad de originales (los escaneos del inventario no están aquí); no inferir recompensas ni abrir libre con fixture. Conservar pendientes P04 externa, catálogo, combate/Target/finales, rival y DUD-004/005/006. No repetir el núcleo o Funding ya verificados; recuperar estado remoto y este traspaso al iniciar otra sesión.

## T08.2g — Contrato del primer resolutor competitivo

La implementación posterior T08.2h ya está completada localmente en la sección superior; esta sección conserva evidencia y traspaso históricos del contrato.

Publicación autorizada posteriormente el 2026-11-11: «haz commit y push y vamos con el siguiente paso». El commit que contiene esta nota identifica la entrega documental revisada; las menciones sin publicación inferiores son históricas. Se continúa T08.2h en esta sesión por instrucción expresa, tras comprobar publicación; no se autoriza automáticamente publicar su implementación futura.

2026-11-11. Completada documentalmente R2, AC-35–38 del [contrato Funding](primer-resolutor-competitivo.md), revisión independiente favorable. Registro previo en tasks.md; coordinador único escritor, sin dispensas ni publicación. Fetch correcto y estado remoto leído en main/HEAD/origin/main `2fdc4c35a1868b8bc600d4deccd6a865a4a37b63`, árbol inicial limpio; no había avance que integrar. El intento inicial de fetch restringido no pudo abrir FETCH_HEAD; la ejecución autorizada posterior terminó con código 0.

Contraste `resolver_rules`, perfil nativo sdd_rules Sol/high, sólo lectura y sin descendientes: inspección visual del PDF pp.6/10/11/17 y FAQ oficial consultada para la tarea, actualización declarada enero 2025. Confirma Funding +1 moneda sin metal y reserva distinta de Boxings; REG-070 exige admitir omisión voluntaria, incorporada como booleano tipado sin ventana artificial. No se halló excepción específica de Funding; eso no certifica el catálogo ausente. La ruta de escaneos del otro PC no existe aquí; permanecen sin incorporar/verificar.

Inspección del coordinador: `game_engine.gd`, `sequence_registry.gd`, `sequence_resolver.gd`, `state_validator.gd`, `game_projection.gd` y contrato P06. Las firmas estáticas admiten contexto plano/booleano y enlaces escalares; el núcleo prohíbe cambiar turno/ciclo de vida durante la secuencia. Se documentan perfil cerrado, revalidación, ocurrencias por juego legal, reenvíos y versionado. No se modifica código, datos ni configuración; Godot no ejecutado por no aplicar a este cambio documental. FUND-01–08 son pruebas futuras, no aprobadas.

Revisión independiente `funding_review`, perfil nativo sdd_reviewer Sol/high, sin descendientes: dictamen favorable, sin bloqueantes. Contrasta diff/contrato, APIs actuales, PDF p.11 renderizada y FAQ oficial. Delta confirmado por el revisor, incluidas las dos precisiones y la conservación del contenido previo en los documentos de memoria. Dos precisiones integradas: referencia directa a juego libre en PDF pp.6/17 (REG-009 sólo permanencia hasta limpieza) y FUND-04 exige rechazar descriptor no soportado aunque el resumen diga 1, sin convertir ese resumen en dato mecánico. Revisor y coordinador verifican 10 Markdown, 126 enlaces locales y 31 anclas sin errores; `git diff --check` correcto. El intento de fetch del revisor en lectura fue denegado; la consulta remota correcta corresponde al coordinador.

Cumplimiento: AC-35 fuentes y reservas; AC-36 perfil/intención/ocurrencia/omisiones; AC-37 firmas/versionado/privacidad; AC-38 plan y FUND-01–08, revisión y controles documentales satisfechos. Dos subagentes nativos Sol/high, ninguna dispensa; no hay cambio visual ni transporte que probar. Un error transitorio de sustitución de texto durante metadatos de cierre se detectó por diff y se corrigió preservando exactamente el contenido previo de los tres documentos afectados; el diff final contiene sólo las adiciones previstas. T08.2h implementará después el perfil aislado sin presentar los fixtures como cartas españolas verificadas. P04 externa, entrenamiento, catálogo, combate/Target/finales, rival y DUD-004/005/006 siguen abiertos.

Traspaso de cierre: rama main, HEAD `2fdc4c3`; diez Markdown exclusivamente de T08.2g, incluido contrato nuevo, sin cambios ajenos iniciales ni commit/push. T08.2g cerrada documentalmente; implementación T08.2h pendiente. No repetir T08.2f. Primer paso del siguiente objetivo: implementar T08.2h según plan.md, manteniendo los bloqueos de entrada a limpieza y apertura de libre; recuperar este traspaso y comprobar GitHub al iniciar otra sesión.

## T08.2f — Implementación de secuencias reanudables

Publicación autorizada tras el cierre el 2026-11-10: «haz commit y push». Empaquetado R0 documentado en el registro de trabajo, sin cambios de código ni semántica respecto al dictamen final. El commit que contiene esta nota identifica la entrega; las referencias sin publicación inferiores son históricas. Comprobar índice, push y coincidencia remota al finalizar.

2026-11-10. **Completada localmente**, AC-29–34 y SEQ-01–10, riesgo R2; revisión independiente favorable. Fetch y estado publicado comprobados al retomar y tras la interrupción en `7a9f25c8eee44364b09c624178d0fd9aaf57e35c`, igual a HEAD de main. Al comenzar sólo existían los tres documentos de planificación; la implementación nueva permanece sin commit/push.

Resultado: [registro cerrado](../../../scripts/game/sequence_registry.gd), [resolutor](../../../scripts/game/sequence_resolver.gd), esquema 2/motor `p08-sequence-1/godot-4.7.2`, integración P07 y proyección por destinatario. Los adaptadores de inicio proponen desde copia aislada; P07 conserva autoridad sobre resolución, ledger, revisión y recibos. CardCycle/TurnCleanup aceptan el mismo registro para conservar cierres anteriores. No hay programas ni operaciones de cartas registrados en producto.

| Criterio | Evidencia en tests/sequence_test.gd |
| --- | --- |
| AC-29 | SEQ-06/09/10: registro congelado, parámetros y contexto cerrados, operación desconocida o firma incompatible después de pausa rechazada antes de iniciar; 64/65 pasos y 16/17 opciones. |
| AC-30 | SEQ-02/06/09: round-trip Variant int64 a motor nuevo, rechazo v1, cursor/ventana/contexto/ledger corruptos y registro incompatible sin sustituir estado. |
| AC-31 | SEQ-01–04: orden/azar esperado, pausas sucesivas, reacción ajena, fallo antes y después de respuesta conserva snapshot completo de la última intención aceptada. |
| AC-32 | SEQ-05/09/10: cierre y recibo únicos, repetición tras carga, ocurrencia consumida, manejadores que borran/reescriben/inventan cierres o congelan contenedores; overflow sin truncado. |
| AC-33 | SEQ-07/08: identidad separada, respuestas inválidas, declinación explícita, vistas ajenas iguales pese a secretos distintos; respuesta construida sólo desde vista propia. |
| AC-34 | SEQ-10: pausa/carga/respuesta en competitivo 2/3/4, cooperativo 2/3/4 y solo 1, reacción ajena donde existe otra plaza; suites siguientes y revisión final. |

Comando reproducible desde la raíz: `powershell -NoProfile -ExecutionPolicy Bypass -File tools/godot.ps1 -Action <acción>`. Godot portátil 4.7.2.stable.official.ed1daf0bf. Ejecución final secuencial tras las correcciones, código 0 en las siete acciones, importaciones limpias y ningún SCRIPT ERROR:

| Acción | Marca / comprobaciones |
| --- | --- |
| test-sequence | P08_SEQUENCE_OK / 253 |
| test-state | P07_STATE_OK / 2.004 |
| test-engine | P07_ENGINE_OK / 102 |
| test-setup | P08_SETUP_OK / 147 |
| test-cycle | P08_CYCLE_OK / 262 |
| test-cleanup | P08_CLEANUP_OK / 527 |
| test | P03_STARTUP_OK / 58 |

Total: 3.353 comprobaciones. Los ocho ERROR de carga anunciados por arranque son casos negativos esperados; los WARNING de estado corresponden a rechazos deliberados. Logs locales ignorados `tmp/godot/<acción>.log` (`test.log` para arranque) y `final-<acción>-output.txt`; no viajan en otro clon, repetir comandos para reproducir. La ejecución restringida inicial produjo `Safe save failed` en importación incluso con APPDATA temporal: no se cuenta como verificación completa. Las ejecuciones finales usaron permiso de ejecución fuera del sandbox y perfil normal, sin alterar ajustes globales. El lanzador convierte cada ErrorRecord a texto antes de detectar errores; dos sondas nativas con stderr ERROR/SCRIPT ERROR y salida 0 se rechazaron con salida 1 (`launcher-error-probe-output.txt`, `launcher-script-error-probe-output.txt`).

Comprobación documental final: 14 Markdown modificados, 160 enlaces locales y 40 anclas válidos; `git diff --check` correcto y ocho archivos nuevos revisados también para espacios/líneas finales, al no figurar en el diff de archivos seguidos. No se han alterado catálogo, escenas ni material escaneado.

Revisión: `sequence_review` encontró aridad incompatible y diccionarios tipados en contenedores de commit; corregidos con regresiones. Tras límite de uso/interrupción, `sequence_review_final` reprodujo un callback de cinco argumentos con tipo Vector2 incompatible y detectó contenedores de sólo lectura y retornos incompatibles. El coordinador corrigió firmas completas y mutabilidad, añadió los casos y repitió suites. Dictamen final favorable tras inspeccionar diff, nuevas rutas, pruebas y logs finales; ningún hallazgo bloqueante restante. La sonda temporal del defecto previo no forma parte de la suite aprobada.

Cumplimiento: plan/AC previos, propietario único por archivo, implementador Sol/high y revisores Sol/high aplicados por instrucciones; coordinador asumió código después de la interrupción. Cuatro delegaciones contando el implementador original interrumpido, su sustituto y los dos revisores; nunca más de dos simultáneos ni descendientes. Ninguna dispensa. No hay UI/transporte ni nueva interpretación reglamentaria, por lo que no aplican capturas, ensayo de red ni nuevo contraste de reglas a esta entrega. P04/P07/P08 conservan sus puertas abiertas.

Traspaso: main/`7a9f25c`, cambios locales en scripts/game/, tests/, tools/godot.ps1 y documentación; nuevos módulos/fixtures/tests y sus UID incluidos en el árbol de trabajo. El permiso anterior de publicación se completó para el inventario, no se publica T08.2f. Siguiente objetivo: especificar el primer resolutor real de competitivo con fuentes y material verificado pertinente, antes de habilitar las puertas de T08.2d. No repetir el núcleo ficticio; no inferir combate, turno completo, catálogo oficial, guardado en disco o reconexión a partir de estas pruebas.

## T08.2e — Contrato de secuencia reanudable y recuperación remota

Publicación autorizada posteriormente el 2026-11-01: «vale haz commit y push de estos cambios». Empaquetado R0 registrado en el registro de trabajo, conservando contrato/revisión R2 sin cambios semánticos. El commit que incorpora esta nota identifica T08.2e y SPEC-009 AC-09; comprobar HEAD remoto y árbol limpio al publicar. Las notas inferiores «sin commit/push» conservan el estado histórico anterior a este permiso, no una prohibición vigente para esta entrega. No autoriza publicaciones futuras.

2026-11-01. Completada documentalmente con revisión independiente favorable, R2, AC-23–28 y SPEC-009 AC-09. Objetivo/plan/responsables registrados antes de editar en plan.md; coordinador único escritor. Encargo «Vamos a avanzar con el siguiente paso», precisado por consulta **siempre** del estado GitHub. Sin dispensas ni permiso de commit/push.

Recuperación real: árbol limpio en main/`16b8247`; primer fetch restringido falló (`getaddrinfo`), segundo fetch con ejecución autorizada obtuvo `origin/main=6caed87`. Leído `git show origin/main:docs/estado-actual.md`; once commits nuevos incluían P07 y avances P08. Fast-forward correcto a `6caed87`, sin sobrescribir cambios ni crear commit. Se descartó la selección inicial obsoleta de P07 antes de escribir código. Diferencia ambiental registrada: motor portátil presente en este PC, frente a ruta de Descargas del otro equipo.

Apoyo de diseño `sequence_contract_check`, perfil sdd_planner aplicado por instrucciones, Sol/high, contexto nuevo y sólo lectura sin descendientes: inspeccionó P07/T08.2d y señaló esquema cerrado v1, bloqueo si resolution sin pending, falta de step_id en proyección y ausencia de evidencia de cierre. Integrados en contrato; entre alternativas de testigo único/ledger se eligió ledger por ocurrencia con límites explícitos. Este apoyo no sustituye la revisión independiente final.

Resultado documental: [contrato](secuencia-reanudable.md), forma futura v2/registro/cierre/privacidad, SEQ-01–10 y desglose T08.2f; AGENTS/política/continuidad exigen consulta remota y preservación de diferencias locales. No se modifica ningún GDScript, dato, configuración o recurso; no se ejecuta Godot ni se afirman nuevas pruebas de turno/partida/red. No se reinterpreta regla alguna, por lo que no requiere contraste reglamentario nuevo; se conservan fuentes/puertas T08.2d. No hay UI ni transporte que verificar.

Revisión independiente `sequence_review`, sdd_reviewer Sol/high por instrucciones, contexto nuevo/lectura sin descendientes: dictamen favorable, sin bloqueantes. Inspeccionó diff completo y contrato nuevo, motor/estado/proyección/limpieza y límites de T08.2d. Una mejora integrada y delta confirmado: SEQ-09 exige rechazo de manejadores que borran, reescriben o inventan cierres aunque produzcan candidato estructuralmente válido. Su intento adicional de fetch falló por entorno; no se presenta como consulta remota correcta ni invalida el fetch previo acreditado del coordinador.

Comprobaciones: revisor, 18 Markdown/173 enlaces locales/28 anclas sin errores y diff correcto; cierre del coordinador tras añadir enlace de traspaso al estado, 18 Markdown/174 enlaces/29 anclas sin errores, `git diff --check` correcto. La primera comprobación con Python falló por alias WindowsApps inaccesible; se sustituyó por PowerShell sin instalar dependencias. AC-23–28 aprobados documentalmente y AC-09 por instrucción/protocolo alineados y recuperación real. SEQ-01–10 no ejecutados. Dos delegaciones Sol/high, sin descendientes; ninguna dispensa. Tokens/tiempo comparativo no disponibles. Tras dictamen sólo metadatos/enlace de cierre; ninguna función de juego declarada probada.

Traspaso de cierre: main/`6caed87`, 18 Markdown locales de esta entrega (incluido contrato nuevo), sin commit/push. T08.2e y ampliación AC-09 terminadas documentalmente. Siguiente objetivo T08.2f: implementar núcleo de secuencias con fixtures y pruebas/regresiones, luego reglas respaldadas por fuentes. Conservar P04/P07/P08 abiertas, catálogo y dudas aplazados; no repetir T08.2a/b/c/d ni usar cierre ficticio para entrar en limpieza. Consultar de nuevo GitHub antes de seleccionar el trabajo en otra sesión y contrastar estos cambios locales todavía no publicados.

## T08.2c — Saldo y devolución de Atium

Publicación autorizada posteriormente el 2026-10-30: «vale pues haz commit y push». Empaquetado R0 registrado en el registro de trabajo, sin cambios funcionales y conservando evidencia/revisión R2. Las notas anteriores sin publicación son históricas. El commit que incorpora esta entrada identifica T08.2c; verificar HEAD remoto y árbol limpio después de publicar. No autoriza publicaciones futuras.

Revisión independiente final atium_review/sdd_reviewer Sol high favorable: sin hallazgos bloqueantes ni mejoras necesarias. Inspeccionó diff, fuentes PDF p.8/FAQ oficial, composición CardCycle/P07, logs y proyecciones; reprodujo limpieza **527 comprobaciones, código 0**, sin ERROR/SCRIPT ERROR con acceso normal al perfil. Log ignorado `tmp/godot/t082c-review-cleanup.log`; su primera corrida restringida falló certificados y no cuenta como evidencia limpia. Verificó 12 Markdown, 105 enlaces locales y 22 anclas, sin fallos; diff sin errores. Coordinador obtuvo los mismos resultados documentales. Tras dictamen sólo se actualizan metadatos de cierre.

Cierre metodológico: AC-15–18 aprobados en el subconjunto, riesgo R2, objetivo/plan/propietarios previos, contraste de reglas, pruebas adversas/regresiones y revisión independiente satisfechos. Tres delegaciones nativas sin descendientes: atium_rules Sol/high, atium_impl Sol/medium, atium_review Sol/high. Coordinador integra y actualiza memoria una sola vez. Ninguna dispensa; no hay datos comparativos de tokens/tiempo. Sin cambios visuales/transporte: esas comprobaciones no aplican a esta API; P04/P08 conservan sus puertas. T08.2c cerrada localmente, sin commit/push.

Completada localmente, 2026-10-30. Objetivo/AC-15–18, R2 justificado, plan y propietarios registrados antes del código. Recuperación main/c370d0f limpio. Contraste previo atium_rules/sdd_rules Sol high: SRC-001 p.8 revisada visualmente con skill PDF, contexto pp.17/19–20, y SRC-002 FAQ «Metal tokens & atium» consultada en vivo. Confirma devolución de usadas, conservación de no usadas y suministro no limitado por componentes. Igualdad total/fichas y restricción de Atium no agotado son contrato técnico explícito del subconjunto, sin extrapolar cartas ausentes. Pruebas y revisión independiente satisfechas; ninguna dispensa ni autorización de publicación.

Implementación atium_impl/sdd_developer Sol medium en validador, limpieza y tres fixtures/suites; propiedad liberada antes de las pruebas. Coordinador integró corrección de guardas de tipo. Resultados oficiales Godot 4.7.2.stable.official.ed1daf0bf: `powershell -NoProfile -ExecutionPolicy Bypass -File tools/godot.ps1 -Action test-cleanup -GodotPath 'C:/Users/pablo/Downloads/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe'` pasa con **P08_CLEANUP_OK, 527 comprobaciones, código 0**, importación sin errores tras corrección final.

Regresiones en serie con ese ejecutable y `--path . --headless --script res://tests/<suite>`: estado **1.938**, motor **102**, preparación **147**, ciclo **262**, arranque **58**, código 0, marcas OK y ninguna marca SCRIPT ERROR. Arranque incluye ocho negativos esperados. Logs locales ignorados `tmp/godot/test-cleanup.log`, `tmp/godot/import.log`, `tmp/godot/t082c-<suite>.log` y `.txt`; no acompañan otro clon. AC-15/18: suite de estado, siete configuraciones/todas plazas/tipos/total/cero/40 fichas/versiones anteriores. AC-16/17: suite limpieza, mezcla/todas/ninguna/cero, conservación ajena, agotamiento con rollback, transacción P07/reintento/reanudación/proyecciones.

Incidencias resueltas: primera importación restringida no accedía a certificados/ajustes del perfil Windows; repetida con permisos normales pasó. Primera regresión de estado imprimió SCRIPT ERROR pese a código 0, por comparar metal/exhausted de tipos inválidos; no se aceptó como aprobada. Se añadieron guardas de tipo antes de comparaciones y se repitieron estado/regresiones/limpieza oficial con éxito. Revisión independiente del resultado corregido favorable.

Traspaso de cierre T08.2c: main/c370d0f; árbol inicial limpio, cambios de esta tarea en cinco GDScript y documentación SPEC-008, contrato P07, arquitectura, decisiones/estado/plan/backlog/registro. Sin cambios ajenos conocidos ni commit/push. Ninguna dispensa. Objetivo actual terminado. Siguiente objetivo: especificar la entrada a limpieza y puertas previas de combate/Target/efectos/finales, sin saltar entrenamiento ni inventar datos/dudas pendientes; sólo implementar partes cuyas fuentes y modelo estén disponibles. No repetir ciclo ni contrato de Atium. P08/P04 abiertas; no hay turno completo, catálogo real ni partida jugable.

Fecha: 2026-10-29. T08.1a implementada y verificada localmente. P08 sigue abierta.

| Criterio | Evidencia ejecutada | Resultado |
| --- | --- | --- |
| AC-01 | `game_setup_test.gd`: siete configuraciones y rechazos de modo, plaza, ID y semilla | Aprobado |
| AC-02 | Rechazo de mercado/mazo rival incompletos, tipo incorrecto, misión repetida, definición no verificada y existencias insuficientes, incluidas pistas | Aprobado con fixtures ficticios |
| AC-03 | Conteos de instancias/zonas, metales, mano inicial, misiones y mercado | Aprobado estructuralmente |
| AC-04 | Salud/Boxing por puesto y Target de competitivo 3–4 | Aprobado |
| AC-05 | Rival 48/1/36 y ausencia en competitivo; sorteo cooperativo y elección competitiva | Aprobado |
| AC-06 | Validador P07, determinismo de semilla, RNG/IDs conservados y entradas sin mutar | Aprobado |

`powershell -NoProfile -ExecutionPolicy Bypass -File tools/godot.ps1 -Action test-setup -GodotPath <Godot 4.7.2>`: **P08_SETUP_OK, 147 comprobaciones, código 0**. Godot 4.7.2.stable.official.ed1daf0bf. Regresiones directas con el mismo Godot: `game_state_test.gd` **1.741**, `game_engine_test.gd` **102**, `catalog_test.gd` **220** y `startup_test.gd` **58**, todos código 0. Los errores/avisos de tests negativos anteriores son esperados. El lanzador importó los scripts y no informó errores.

No hay catálogo oficial verificado, escena de partida, entrenamiento ejecutable ni ronda completa. Los fixtures simulan cantidades/tipos: no prueban la transcripción ni las recompensas del juego. No se requiere prueba manual de interfaz para esta API local; P04 externa sigue pendiente y P08 requerirá pruebas de partida cuando conecte UI/reglas.

## T08.2a — Ciclo personal de cartas

Fecha 2026-10-29. Riesgo R2, objetivo y plan registrados previamente en plan.md; AC-07–10 en spec.md. T08.2a completada localmente con pruebas y revisión independiente favorable. T08.2/P08 continúan abiertas. Ninguna dispensa humana ni permiso de publicación.

| Criterio | Evidencia ejecutada | Resultado |
| --- | --- | --- |
| AC-07 | Robo ordenado, cero, última carta sin reciclado anticipado, reciclado con RNG explícito | Aprobado |
| AC-08 | Selección mixta mano/juego, orden explícito, limpieza conserva aliados en juego y descarta aliados en mano | Aprobado |
| AC-09 | Cantidades/tipos/IDs/estado inválidos; exceso y agotamiento exacto; snapshot/RNG intactos en rechazo | Aprobado; DUD-006 sigue abierta |
| AC-10 | Siete configuraciones, zonas con IDs no canónicos, determinismo, invariantes, zonas ajenas/rival intactas, recibos/reintento/proyección y rollback compuesto | Aprobado con fixtures ficticios |

Comando ejecutado desde raíz: `powershell -NoProfile -ExecutionPolicy Bypass -File tools/godot.ps1 -Action test-cycle -GodotPath 'C:/Users/pablo/Downloads/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe'`: **P08_CYCLE_OK, 262 comprobaciones, código 0**, importación sin errores. Godot 4.7.2.stable.official.ed1daf0bf. Logs locales ignorados: `tmp/godot/import.log`, `tmp/godot/test-cycle.log`; no acompañan otro clon, reproducir con el mismo comando y ruta local de motor.

Regresiones ejecutadas en serie: `test-setup` **147** y scripts `game_state_test.gd` **1.741**, `game_engine_test.gd` **102**, `catalog_test.gd` **220**, `startup_test.gd` **58**, todos código 0 y marcas finales correctas. Logs `tmp/godot/t082a-*.log`. Errores de catálogo/arranque y aviso de snapshot son negativos esperados. La primera importación restringida falló por certificado/perfil Windows; repetida con acceso normal a datos Godot pasó. La suite nueva detectó un nombre `Engine` que colisionaba con clase nativa: corregido a `GameCore` antes de pasar; ningún error de script se considera aprobado.

Responsables: `rules_deck`/sdd_rules Sol high contrastó PDF pp.6/17/19/20 y FAQ oficial consultada hoy; `deck_impl`/sdd_developer Sol medium escribió módulo, tests y lanzador sin delegación; tras finalizar, coordinador retomó propiedad para corregir el nombre del test e integrar/verificar. Revisión final `cycle_review`/sdd_reviewer Sol high favorable: inspección independiente de módulo/tests/P07, logs reales, FAQ y PDF pp.6/17 mediante runtime, diff y enlaces; sin defectos bloqueantes ni cambios de código solicitados. Tres delegaciones, perfiles nativos, sin descendientes. Tokens/tiempo comparativo no disponibles. No hay UI, red ni cambio de esquema/versiones, por lo que no se requiere captura ni prueba de red para esta API; P04 externa y puertas de cierre P08 conservan sus requisitos.

Traspaso: rama `main`, HEAD inicial `7b75181`, árbol inicial limpio. Cambios locales de esta entrega: módulo/test/.uid, lanzador y documentación SPEC-008/estado/plan/backlog/arquitectura/guía/referencias/registro. Sin trabajo ajeno local previo, commit ni push. Fuentes/convenciones y persistencia RNG en plan.md. No hay turno jugable, efectos, entrenamiento ni tratamiento terminal nuevo. Primer paso siguiente: especificar las transiciones/limpieza completa independientes de entrenamiento y efectos, sin abrir automáticamente `libre`. No volver a pedir material aplazado ni resolver DUD-006 por inferencia.

Cierre metodológico: objetivo/AC, riesgo R2, plan y propietarios previos, contraste de reglas, implementación, pruebas y revisión independiente satisfechos; ninguna dispensa. Comprobación documental del coordinador: 13 Markdown, 96 enlaces locales y 9 anclas correctos, diff sin errores. El revisor comprobó también los enlaces y el delta de documentación. Tras su dictamen solo se actualizan metadatos de cierre; T08.2a cerrada localmente, T08.2/P08/P04 siguen abiertas.

Publicación autorizada en encargo posterior del 2026-10-29: «haz commit y push». Empaquetado R0 registrado en el registro de trabajo, sin cambios funcionales ni repetición de controles R2 ya satisfechos. La revisión que contiene esta entrada identifica la entrega; las notas anteriores sin publicación describen el estado previo al permiso. Verificar HEAD remoto y árbol limpio tras publicar; no extender este permiso a futuras entregas.

## T08.2b — Cierre interno de limpieza

Completada localmente (2026-10-30): AC-11–14, riesgo R2 y plan/propietarios registrados antes del código. Git inicial main/9e46660 limpio. Contraste turn_rules/sdd_rules Sol high completado; implementación cleanup_impl/sdd_developer Sol medium asignada a módulo/tests/lanzador. Pruebas y revisión independiente satisfechas según evidencia siguiente; no hay dispensa ni autorización de publicación.

| Criterio | Evidencia ejecutada | Resultado |
| --- | --- | --- |
| AC-11 | Siete configuraciones; rechazos de snapshot, actor, fase, resolución, counters/flags, Atium usado y adversarios propios | Aprobado |
| AC-12 | Descarte/robo5 y usos temporales propios; preserva agotamiento, persistentes, burn_limit y ajenos; RNG intacto sin reciclado | Aprobado con fixtures |
| AC-13 | Siguiente vivo, orden circular, overflow, muerte/final pendiente, entrega inicio/rival y rechazo de repetición | Aprobado en subconjunto |
| AC-14 | Agotamiento/exacto, rollback total y RNG, determinismo, recibos/reanudación/reintento P07 y vistas privadas | Aprobado |

Ejecución oficial: `powershell -NoProfile -ExecutionPolicy Bypass -File tools/godot.ps1 -Action test-cleanup -GodotPath 'C:/Users/pablo/Downloads/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe'`: **P08_CLEANUP_OK, 334 comprobaciones, código 0**, importación sin errores, Godot 4.7.2.stable.official.ed1daf0bf. Log ignorado `tmp/godot/test-cleanup.log`, salida completa `tmp/godot/t082b-cleanup-run.txt`. Regresiones directas en serie: ciclo **262**, preparación **147**, estado **1.741**, motor **102**, arranque **58**, código 0 y ninguna marca SCRIPT ERROR; negativos del arranque esperados. Logs `tmp/godot/t082b-*_test.gd.log` y `.txt`; reproducibles con `--path . --headless --script res://tests/<suite>` y ese Godot. No acompañan otro clon.

Incidencias resueltas antes de revisión: primera importación restringida no podía leer certificados/guardar ajustes de Godot; repetida con acceso normal al perfil pasó. Primera suite falló por claves StringName introducidas con asignación de punto en el fixture: corregidas a claves String, con diagnóstico/retorno temprano para evitar fallos en cadena. No hubo cambio de contrato ni algoritmo para hacer pasar una regla distinta. Desarrollador ejecutó una corrida de diagnóstico reservada; coordinador ejecutó oficial y regresiones en serie. No se acepta el ERROR de entorno como aprobado: la ejecución oficial carece de él.

Revisión independiente favorable de cleanup_review/sdd_reviewer Sol high, sin hallazgos bloqueantes; reprodujo test-cleanup (334, código 0), inspeccionó fuentes PDF/FAQ y verificó 12 Markdown/95 enlaces locales/14 anclas. No se ha probado una partida, UI, red ni material real. No hay cambio de esquema ni handlers públicos. P08 sigue abierta por entrenamiento, combate/Target/efectos, Atium usado y rival; DUD-006 y P04 externa conservan sus bloqueos.

Cierre metodológico: R2, objetivo/AC y plan previos, contraste de reglas, implementación, pruebas adversas/regresiones y revisión independiente satisfechos. Tres delegaciones: turn_rules Sol/high, cleanup_impl Sol/medium y cleanup_review Sol/high, perfiles nativos sin descendientes; coordinador responsable de integración/memoria. Ninguna dispensa, tokens y tiempo comparativo no disponibles. No cambia presentación/red/esquema: esas puertas no aplican a esta API; las de P04/P08 siguen exigidas. Tras revisión sólo se actualizan metadatos de cierre y enlaces al traspaso actual.

Traspaso T08.2b: rama main, HEAD 9e46660; árbol inicial limpio, sin trabajo ajeno previo conocido. Entrega local sin commit/push: turn_cleanup.gd/test y sus .uid, tools/godot.ps1, SPEC-008 y documentación de estado/plan/backlog/arquitectura/guía/decisiones/cobertura/registro. DEC-023 fija contrato técnico, no nuevas reglas de producto. Logs ignorados en tmp/godot no acompañan otro clon; comandos anteriores los reproducen. Resultado: cierre seguro del subconjunto, nunca turno/partida completa. Primer paso siguiente: definir y probar contrato entre persistent.atium y fichas materializadas para devolver sólo Atium usado; conservar pendiente apertura libre por entrenamiento y puertas de combate/Target/efectos/rival. No rehacer ciclo T08.2a ni resolver DUD-006, material aplazado o P04 externa por inferencia. Para el siguiente objetivo usar chat nuevo con este traspaso, sin inferir autorización de publicación.

Publicación autorizada posteriormente el 2026-10-30: «haz commit y push». Empaquetado R0 registrado en el registro de trabajo, conservando pruebas y revisión R2 ya satisfechas, sin nuevos cambios funcionales. Las notas anteriores sin publicación son históricas. El commit que contiene esta entrada identifica T08.2b; comprobar HEAD remoto y árbol limpio tras publicar. No extiende permisos a entregas posteriores.
## T08.2d — Contrato previo a entrada en limpieza

Publicación autorizada posteriormente el 2026-10-30: «haz commit y push». Empaquetado R0 registrado en el registro de trabajo, sin cambios funcionales ni alteración del contrato revisado. Las notas sin autorización siguientes son históricas. El commit que incorpora esta nota identifica la entrega; verificar sincronía remota y árbol limpio tras publicar. No amplía permisos a entregas futuras.

2026-10-30. Entrega exclusivamente documental R2, [AC-19–22](entrada-a-limpieza.md). Objetivo/plan/propietarios registrados antes de editar el contrato. Recuperación main/f3fbf54, árbol inicialmente limpio; sin trabajo ajeno local conocido. T08.2c ya publicada según HEAD, sin necesidad de repetir su implementación. Sin autorización nueva de commit/push ni dispensas.

Contraste previo cleanup_entry_rules/sdd_rules Sol high, lectura sin descendientes: SRC-001 pp.15–20 y FAQ SRC-002 consultada en vivo (Combat, Action cards, Player abilities & allies y Solo & Co-op mode). Confirma que fase, ataque cero y ausencia de resolución no acreditan combate/Target/finales; no hay segmento de entrada seguro implementable con el modelo actual. Se entrega contrato/desglose en lugar de habilitar un salto de fase. No se fija orden adversario/descarte sin fuente, ni prioridad terminal para DUD-006.

Coordinador único autor documental. Inspeccionados turn_cleanup.gd, state_validator.gd y game_engine.gd: hay cierre interno y transacciones, sin resolutores de las obligaciones anteriores. AC-19: matriz por modo y fuentes. AC-20: límites explícitos y prohibición de aceptar marcas del cliente como acreditación. AC-21: ocho escenarios de aceptación futura, expresamente no ejecutados. AC-22: dependencias y siguiente contrato técnico de secuencia reanudable. Revisión independiente entry_contract_review/sdd_reviewer Sol high favorable tras corregir la rama de muerte del activo por adversario: sin cierre normal ni robo rival por eliminado, sucesión pendiente del resolutor correspondiente. El revisor contrastó directamente PDF pp.14–20 y FAQ en vivo, e inspeccionó captura renderizada pp.15–20 (tmp/pdfs/t082d-review-pages.png, local ignorada; no acompaña otro clon). Hallazgo corregido y delta confirmado por el revisor.

Verificación final: nueve Markdown, 69 enlaces locales y 15 anclas correctos; revisor confirmó independientemente los 69 enlaces. git diff --check sin errores tras retirar una línea vacía final detectada por revisión. No se ejecuta Godot: no hay cambios de código, datos, configuración ni recursos. No hay prueba nueva de turno, UI, red o partida; siguen pendientes P04/P08. Cierre metodológico documental: AC-19–22 satisfechos, R2/plan previo, contraste y revisión independiente realizados, ninguna dispensa. Dos delegaciones nativas sin descendientes; coordinador único escritor e integrador. No se adopta formato de estado ni nueva decisión de producto.

Traspaso: main/f3fbf54, nueve Markdown locales de esta entrega; sin cambios ajenos conocidos ni commit/push. T08.2d cerrada como contrato documental; entrada funcional, T08.2 y P08 abiertas. Siguiente objetivo ejecutable: contrato del resolutor reanudable P08/P09 con registro cerrado de operaciones soportadas, pasos, pausas, cierre único, persistencia y pruebas con fixtures declarados. No repetir T08.2a/b/c ni pedir material aplazado; no habilitar transición sin los resolutores de combate/Target/efectos/finales.
