# Verificación de SPEC-008

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
