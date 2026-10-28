# Verificación de SPEC-007

Fecha: 2026-10-28. T07.1 implementada y verificada en su alcance estructural; T07.2 pendiente. P07 permanece abierta.

| Criterio | Evidencia ejecutada | Resultado / estado |
| --- | --- | --- |
| AC-01 | _test_modes: siete configuraciones y cantidades, IDs, orden, modo/rival y Target incompatibles | Aprobado estructuralmente; no prepara una partida |
| AC-02 | _test_state/_test_references: dos instancias del mismo diseño, conservación de propietario, zonas/referencias, congelación y copias profundas | Aprobado para el almacén; movimientos de juego aún no implementados |
| AC-03 | _test_state: round-trip completo de metales, recursos, misiones, rival/Dominación y escudos; referencias inválidas | Aprobado como almacenamiento, sin reglas de preparación/daño |
| AC-04 | Solo conservación de rng_seed/rng_state int64 comprobada | Reproducción de acciones pendiente de T07.2 |
| AC-05 | try_load rechaza snapshot inválido sin alterar el anterior y admite recuperación | Parcial; transacciones de acciones pendientes |
| AC-06 | Sin procesador ni recibos admitidos todavía | No ejecutado; T07.2 |
| AC-07 | Ninguna vista de cliente implementada; get_snapshot es privado de autoridad | No ejecutado; T07.2 |
| AC-08 | _test_resolution: cursor, origen, destinatarios y límites de opciones almacenados/validados | Parcial; responder/reanudar acciones pendiente |
| AC-09 | Componentes RefCounted con dependencias por parámetros; revisión sin uso de nodos/red/Database | Parcial; despacho de acciones pendientes |

## Ejecución real

- Entorno: Windows, Godot 4.7.2.stable.official.ed1daf0bf. Motor encontrado en C:/Users/pablo/Downloads/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe; .tools/godot no existe en este equipo. Se usó -GodotPath explícito, sin cambiar .godot-version ni el descubrimiento del lanzador.
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools/godot.ps1 -Action test-state -GodotPath <motor>`: importación sin errores, P07_STATE_OK, **1.725 comprobaciones**, código 0. Incluye mutaciones recursivas de tipos/campos, aislamiento del validador, objetos/ciclos y límites técnicos. Un WARNING de rechazo es el caso negativo anunciado como FALLO ESPERADO. Ningún SCRIPT ERROR ni ERROR en la ejecución final.
- `-Action test-catalog` con el mismo motor: P06_CATALOG_OK, **220 comprobaciones**, código 0; dos errores de carga esperados. No ejecuta efectos.
- `-Action test` con el mismo motor: P03_STARTUP_OK, **58 comprobaciones**, código 0; ocho errores de carga esperados.
- Logs locales regenerables: tmp/godot/test-state.log, test-catalog.log, test.log e import.log (ignorados por Git). El lanzador test-state exige marca final y rechaza errores nativos o de script aun con código 0.
- La primera importación restringida falló por acceso al almacén de certificados y guardado de ajustes de Godot en AppData. Se repitió con acceso normal al perfil Windows y se verificó con éxito. Durante desarrollo las pruebas detectaron comparaciones de tipos inválidos y un fixture con clave StringName; corregidos antes de la ejecución final.

## Límites y revisión

No hay preparación, turnos reglamentarios, efectos, acciones, proyecciones privadas ni partida jugable. Los fixtures no son contenido oficial. No se ejecutaron pruebas de red ni capturas: las escenas y el transporte no se modifican. P04 sigue pendiente de evidencia entre redes; las dudas de reglas conservan sus fases.

Se conservan las modificaciones previas de project.godot y dos .import, ajenas a esta entrega. No se cambia motor ni se publica. Documentación y enlaces locales revisados al cierre; detalle en el registro de trabajo.
