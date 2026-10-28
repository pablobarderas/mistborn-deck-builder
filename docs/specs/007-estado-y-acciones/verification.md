# Verificación de SPEC-007

Fecha de cierre técnico local: 2026-10-29. T07.1 y T07.2 implementadas y verificadas. P07 sigue abierta por la prueba externa y decisión de acceso de P04.

| Criterio | Evidencia ejecutada | Resultado |
| --- | --- | --- |
| AC-01 | `game_state_test.gd`: siete configuraciones y modos/cantidades inválidos | Aprobado como descriptor; sin preparación reglamentaria |
| AC-02 | Instancias, propiedad, zona única, referencias y copias profundas | Aprobado para almacenamiento |
| AC-03 | Round-trip de recursos, metales, misiones, Target, rival y escudos | Aprobado como almacenamiento, sin ejecutar sus reglas |
| AC-04 | `game_engine_test.gd`: misma semilla/snapshot y barajados, rechazo tras consumir RNG, reanudación desde snapshot | Aprobado con misma versión de motor |
| AC-05 | Candidato validado antes de publicación; invalidación después de mutar zona/RNG, cambios a metadatos/recibos y recursos inválidos conservan estado íntegro | Aprobado en núcleo local |
| AC-06 | Reintento idéntico inmediato/tardío y tras restaurar snapshot; mismo ID con contenido distinto, ID rechazado que luego se corrige | Aprobado por plaza estable; identidad remota aún sin conectar |
| AC-07 | Proyecciones propia/ajena, cambio de carta oculta, destinatario desconocido, ausencia de IDs privados/RNG/recibos y mutación de vista | Aprobado para política conservadora v1; no se ha inspeccionado tráfico real |
| AC-08 | Respuesta de otra plaza fuera del turno, paso/opciones/actor inválidos, bloqueo de acciones y reconstrucción desde snapshot | Aprobado con manejador ficticio; efectos y elecciones reales siguen P09 |
| AC-09 | Núcleo RefCounted sin escenas, Database o ENet; operación sin registro rechazada, manejadores ficticios solo en tests | Aprobado localmente; sin adaptador de producto |

Godot 4.7.2.stable.official.ed1daf0bf en Windows, indicado mediante `-GodotPath` a la copia local de Descargas. `powershell -NoProfile -ExecutionPolicy Bypass -File tools/godot.ps1 -Action test-engine -GodotPath <motor>` terminó con **P07_ENGINE_OK: 102 comprobaciones**, código 0; dos WARNING son rechazos de candidatos inválidos esperados. `-Action test-state` terminó con **1.725 comprobaciones**, `-Action test-catalog` con **220** y `-Action test` con **58**, todos código 0. El lanzador rechaza ERROR/SCRIPT ERROR en test-engine y test-state incluso con salida de proceso cero. Las regresiones se repitieron tras integrar el núcleo; el último cambio solo amplió tests de entrada y pasó test-engine con 102 comprobaciones. Logs ignorados en `tmp/godot/`.

P04 sigue sin prueba entre redes y sin decisión final de transporte/alojamiento. No se han implementado reglas, preparación, efectos, victoria, interfaz jugable ni sesiones reales. El catálogo actual conserva dos muestras y cero definiciones verificadas. La comprobación de privacidad cubre la proyección local, no paquetes de red. DUD-002/003/004/005/006 conservan su estado; ninguna bloqueó el núcleo local. El cierre de P07 requiere resolver su dependencia P04. Las modificaciones previas de `project.godot` y dos `.import` no pertenecen a esta entrega.
