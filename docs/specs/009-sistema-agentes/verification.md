# Verificación de SPEC-009

Fecha: 2026-10-29. Estado: completada en configuración y aplicación por instrucciones, revisión independiente favorable. La carga nativa automática sigue no acreditada. Entorno: Windows, Python 3.12.14 disponible en el runtime local, Codex CLI 0.163.0-alpha.10.2. No se ha cambiado la versión de Godot ni ejecutado sus suites en esta entrega de herramientas/documentación.

| AC | Resultado observado | Estado |
| --- | --- | --- |
| AC-01 | Análisis de alcance/riesgos, alternativas y política económica en agentes-sdd.md; auditoría independiente de alcance Sol high. Separados coste por token, volumen de contexto y retrabajo; sin ahorro afirmado. | Aprobado |
| AC-02 | 7 TOML válidos; `tools/check_agents.py` código 0. `tests/agent_config_test.py`: 2 tests aprobados, incluidos once casos negativos en memoria sin alterar fuentes. Diagnóstico local termina con código 0 pero no muestra los nombres de roles; no acredita descubrimiento nativo. | Aprobado en el alcance de configuración/comprobación; carga nativa no acreditada |
| AC-03 | AGENTS/flujo solicitan delegación condicionada por riesgo, revisión, corrección y cierre; límites y alternativa explícita para clientes sin selector de rol. | Aprobado documentalmente; ensayo por instrucciones realizado |
| AC-04 | Matriz de puertas cubre los tres modos/rival, catálogo, atomicidad, privacidad/red/reconexión, visual y distribución; mantiene P04/P07/P08 pendientes. | Aprobado documentalmente; no es prueba del juego |
| AC-05 | `scope_audit` Sol high y `support_smoke` Luna medium ejecutados realmente. Apoyo leyó perfil, comprobó las siete asignaciones y ejecutó validador código 0; sin modificaciones. `final_review` Sol high revisó archivos/diff, ejecutó validador/tests, comprobó 135 enlaces y diff; sin defectos bloqueantes ni accionables. Verificó después el delta de lectura selectiva y plantilla, sin defectos nuevos. | Aprobado mediante perfiles aplicados por instrucciones |
| AC-06 | Índices, flujo, backlog, estado, plan, DEC-019, registro, plantillas y continuidad actualizados; enlaces locales y diff comprobados. Sin cambios del juego ni publicación. | Aprobado |
| AC-07 | Obligatoriedad en AGENTS/política, siete perfiles y plantillas/recuperación; dispensas exclusivamente humanas, trazables y acotadas, sin autoexcepciones ni cierre sin control o dispensa. Validación y revisión independiente favorables detalladas en la ampliación. | Aprobado documentalmente; no es un bloqueo técnico del cliente |

## Comandos y límites

- `python tools/check_agents.py`: `SDD_AGENTS_OK`, código 0. El Python real se obtuvo del runtime; el alias Windows puede no apuntar a un intérprete.
- Casos negativos: TOML mal formado, archivo ausente, nombre duplicado, campo ausente, modelo desconocido, esfuerzo inválido, tipo inválido, override de permiso, override de modelo principal, concurrencia booleana y referencia de instrucciones ausente. Primero se intentaron copias temporales y el sandbox denegó su creación; se sustituyeron por entradas simuladas en memoria. Los originales no se alteraron. Reproducción persistente: `python tests/agent_config_test.py`.
- Diagnóstico local: generación de esquema de app-server sin errores; `debug prompt-input` no acepta `--strict-config`. Sin ese parámetro, hubo acceso denegado a temporales normales de Codex; con ejecución autorizada fuera de esa restricción terminó con 0 y sin errores, pero sin los nombres de perfiles. No se realizó turno de modelo ni se cambió confianza/configuración personal. Esto no demuestra carga nativa; se conserva esa limitación expresamente y se usa la alternativa por instrucciones.
- Los perfiles de solo lectura heredan permisos del principal; son una restricción de conducta, no un sandbox separado. Solo se ejercitaron modelos Sol y Luna, no la disponibilidad efectiva de Terra/Astra en este equipo.

## Delegaciones y medición

Riesgo R1 de herramientas/proceso; el coordinador especifica e implementa. Tres agentes: auditoría de alcance (Sol/high), apoyo mecánico (Luna/medium), revisión final (Sol/high). Cuatro encargos contando la reactivación del mismo revisor para verificar el delta final de perfiles/plantilla. Contexto nuevo acotado; ninguna delegación descendente ni implementación concurrente. Tokens por tarea, caché, razonamiento, coste y comparación temporal controlada: **no disponibles**. No se acredita reducción de consumo ni robustez/jugabilidad final del producto.

## Ampliación AC-07 — Obligatoriedad

Encargo humano adicional del 2026-10-29; riesgo R2 por cambios de controles, coordinador como escritor único y revisión independiente Sol/high. Objetivo, AC y plan registrados en spec.md antes de editar. Dispensas humanas: ninguna. Se conservan los cambios locales anteriores; no hay cambios de modelos, permisos ni código del juego. Ampliación completada; no sustituye la evidencia histórica AC-01–06.

- `tools/check_agents.py`: siete perfiles válidos, código 0.
- `tests/agent_config_test.py`: dos tests aprobados, incluidos once casos negativos, código 0.
- Comprobación del coordinador: 143 enlaces locales y tres anclas Markdown válidos; `git diff --check` correcto. Revisor: 139 enlaces/destinos/anclas en su selección y diff correctos.
- `mandatory_sdd_review`, perfil aplicado por instrucciones, modelo Sol/high, contexto nuevo acotado: revisó obligatoriedad, excepciones, R0, control de cierre y coherencia entre documentos; ejecutó validador/tests y verificó enlaces/diff. Dictamen favorable, sin defectos accionables ni bloqueantes. Sin cambios posteriores de política: solo registro del cierre.
- Registro metodológico: R2, un coordinador escritor y un encargo al revisor independiente, sin descendientes; controles aplicables satisfechos y memoria/siguiente paso actualizados. Tokens y tiempo comparativo: no disponibles. No hubo hallazgos que exigieran corrección ni dispensas humanas. No se ejecutaron Godot, partidas, red, diagnóstico CLI ni carga nativa de perfiles en esta ampliación documental; no se afirmó esa evidencia. Sin commit/push.

## Dictamen de la entrega inicial y siguiente paso

Publicación autorizada en un encargo posterior del 2026-10-29: empaquetado R0 de esta entrega revisada, sin cambios del método. Se repiten validador/tests y comprobaciones documentales; el coordinador verificará el resultado de commit/push contra el remoto. Los registros anteriores «sin commit/push» se conservan como evidencia histórica de esas sesiones. La revisión Git que incorpora esta nota identifica la publicación; no se afirma aquí el resultado remoto antes de ejecutarlo.

Revisión independiente favorable: sin hallazgos bloqueantes ni defectos accionables. Una mejora de eficiencia aplicada: cada perfil consulta solo las secciones pertinentes de la guía después de la recuperación obligatoria. Se repitieron validador/tests por ese cambio y el revisor comprobó el delta; no fue necesario repetir toda la auditoría.

Siguiente tarea del juego: parte confirmada de T08.2, ciclo de mazo/descarte, con fuentes y DUD-006 conservadas. En próxima sesión compatible comprobar el descubrimiento nativo si se desea usar el selector de perfiles; mientras tanto aplicar el contrato y TOML mediante la delegación por instrucciones ya ensayada. Revisar resultados de modelos tras cinco entregas comparables. No se han ejecutado nuevas partidas, red, capturas ni exportaciones y no se ha hecho commit/push.
