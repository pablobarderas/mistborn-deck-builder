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
