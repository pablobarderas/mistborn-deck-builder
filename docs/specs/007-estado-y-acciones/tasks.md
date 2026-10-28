# Tareas de SPEC-007

T07.1 y T07.2 completadas y verificadas localmente. P07 conserva la dependencia de cierre P04 externa. Sin issues publicadas.

| ID estable | Resultado comprobable | Dependencia | Aceptación | Estado |
| --- | --- | --- | --- | --- |
| T07.1 | Estado tipado, instancias/zonas, modos, rival, resoluciones y validación de invariantes; copias y fixtures explícitos. | Núcleo P02, P06; trabajo local independiente de acceso externo | AC-01–03, AC-09 | Completada localmente; 1.725 comprobaciones en test-state |
| T07.2 | Núcleo transaccional, RNG reproducible, deduplicación por plaza, proyecciones y continuación; lanzador y pruebas negativas. | T07.1 | AC-04–09 | Completada localmente; 102 comprobaciones en test-engine |

P07 conserva la dependencia de cierre P04. T04.2 está pendiente de segundo equipo y prueba entre redes; no bloquear por ello el trabajo local independiente ni marcar P07 terminada.

Al implementar: registrar resultados por AC, actualizar arquitectura/estado/plan y mantener privacidad conservadora donde falte contraste. Las reglas concretas de preparación, efectos y finales pertenecen a P08–P10.
