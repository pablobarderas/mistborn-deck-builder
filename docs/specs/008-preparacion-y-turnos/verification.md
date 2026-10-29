# Verificación de SPEC-008

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
