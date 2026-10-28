# SPEC-009 — Agentes para desarrollo SDD

Fecha: 2026-10-29. Estado: completada en configuración y flujo con aplicación por instrucciones, incluida ampliación obligatoria AC-07 revisada independientemente. Carga nativa automática no acreditada. Tarea: T00.1, mejora transversal de P00. Evidencia y límites en [verification.md](verification.md).

## Problema y alcance

El flujo SDD existe, pero carece de roles persistentes, selección de modelos y criterios de delegación. El usuario encarga analizar e implementar ese sistema, equilibrando consumo, tiempo y calidad para el alcance completo del juego. Esta entrega configura el trabajo de Codex; no implementa las fases pendientes del juego ni acredita su robustez final.

Mantener Windows, Godot 4.7.2/GDScript, español, siete configuraciones de modo/jugadores, rival obligatorio, salas privadas sin cuentas y reconexión. Conservar dependencias, dudas aplazadas, fuentes y dirección visual aceptada. No añadir servicios, SDK, claves, dependencias de ejecución del juego ni publicaciones.

## Comportamiento

- El coordinador clasifica la tarea por riesgo y aplica obligatoriamente el ciclo SDD proporcional. Las tareas R0 mecánicas pueden resolverse sin subagentes, conservando su registro y controles mínimos; una tarea funcional pequeña no queda exenta por su tamaño.
- Se conservan perfiles de planificación, desarrollo, revisión, reglas, visual, apoyo y escalado. Se activan por necesidad; no existe una cadena obligatoria de siete agentes.
- Cada encargo delimita entradas, salida, escritura, aceptación y verificación. La revisión independiente comprueba el resultado final; las afirmaciones del autor no sustituyen evidencia.
- La selección de modelo depende de dificultad; se escalan fallos/razonamiento, nunca la ausencia de una fuente. Se registra lo medible sin prometer ahorro.
- La configuración nativa tiene una alternativa explícita cuando el cliente solo permite delegar mediante instrucciones y modelo.

## Aceptación

| ID | Criterio |
| --- | --- |
| AC-01 | Análisis documentado del alcance, riesgos, alternativas, modelos y coste total, con fuentes y límites de lo medido. |
| AC-02 | Perfiles TOML de proyecto y concurrencia limitada, sin cambiar modelo principal, permisos, servicios o credenciales. Validación de sintaxis y campos; comprobación de reconocimiento local si el cliente lo permite. |
| AC-03 | AGENTS exige delegación bajo condiciones precisas; flujo integra especificación, plan, tareas, implementación, verificación, revisión, corrección y cierre. |
| AC-04 | Las puertas de calidad cubren reglas/modos, catálogo, estado, privacidad/red/reconexión, presentación y distribución; no cierran fases con evidencia parcial. |
| AC-05 | Hay una prueba real de delegación de alcance acotado y revisión independiente de esta entrega; registro de modelos, resultados y limitaciones. |
| AC-06 | Documentación, backlog, siguiente paso y registro coherentes; enlaces y diff comprobados. Sin cambios de reglas, código del juego ni publicación. |
| AC-07 | Por instrucción humana adicional, el método es obligatorio: solo dispensa humana explícita y registrada permite omitir requisitos; perfiles, recuperación, plantillas y cierre impiden autoexcepciones, degradación artificial de riesgo y cierre sin controles o dispensa válida. La falta de herramientas mantiene el control dependiente pendiente. |

Ampliación del 2026-10-29: el usuario pide integrar la metodología en las instrucciones de Codex e impedir omitirla salvo indicación humana expresa. Riesgo R2 porque cambia controles del proceso; coordinador edita documentación/perfiles, revisor independiente Sol/high comprueba coherencia y vías de omisión. Plan: endurecer AGENTS y política; alinear los siete perfiles, plantillas y recuperación; verificar TOML, enlaces y diff; revisar y registrar el cierre. No cambia modelos, permisos, concurrencia ni código del juego. Dispensas humanas para esta ampliación: ninguna.

## Fuentes y límites

Encargo del usuario del 2026-10-29; [alcance](../../alcance.md), [plan](../../plan-de-trabajo.md), [calidad](../../calidad.md), [flujo existente](../../gestion/desarrollo.md), SPEC-002/007/008. Fuentes técnicas y análisis en [sistema de agentes](../../gestion/agentes-sdd.md). No se dispone de comparativa controlada de consumo/latencia/calidad; los modelos son una política inicial revisable.
