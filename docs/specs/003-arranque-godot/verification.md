# Verificación de SPEC-003

Estado: verificada el 2026-10-27 en Windows, Godot 4.7.2.stable.official.ed1daf0bf. Render real OpenGL 3.3, Compatibility, NVIDIA GeForce RTX 5060 Ti. Esto valida el entorno de desarrollo actual, no los equipos de todo el grupo.

| Criterio | Evidencia requerida | Estado |
| --- | --- | --- |
| AC-01 | Ejecutable devuelve la versión fijada; importación del proyecto y carga de escena sin errores de script. | Superado |
| AC-02 | startup_test verifica Autoload previo, dos IDs originales y nombres/cifras mostrados. | Superado |
| AC-03 | Captura gráfica 1280×800 revisada; recarga por señal del botón y salida mediante su señal real. | Superado |
| AC-04 | Ocho entradas negativas, catálogo vacío tras rechazo, error visible y recuperación con recarga válida. | Superado |
| AC-05 | Lanzador usado para importación, test y preview con código 0 y marcas esperadas. Ruta de motor ausente rechazada con código no cero. | Superado |
| AC-06 | Copia final tmp/clean-p03-final-a7f5c922 sin .godot previa: 58 comprobaciones, código 0. Render final revisado. | Superado |

## Evidencia y reproducción

- Prueba: `powershell -NoProfile -ExecutionPolicy Bypass -File tools/godot.ps1 -Action test`.
- Resultado final en copia de fuentes: `P03_STARTUP_OK: 58 comprobaciones`. Los ocho errores de carga del log están precedidos por `FALLO ESPERADO` y se verifican expresamente.
- Captura: `powershell -NoProfile -ExecutionPolicy Bypass -File tools/godot.ps1 -Action preview`; marca `P03_PREVIEW_OK` y salida 0.
- Captura final local: `tmp/screenshots/main-screen.png`; log gráfico: `tmp/godot/preview.log`; prueba de copia limpia: `tmp/clean-p03-final-a7f5c922/test-output.txt`. Intermedios excluidos de Git, reproducibles mediante los comandos.
- No se modificó data/cartas.json. No hay reglas ejecutadas, multijugador ni exportación distribuible.

La primera ejecución bajo las restricciones del entorno no podía crear la carpeta normal de datos de Godot en el perfil Windows. Se repitió con permiso de ejecución local y las comprobaciones terminaron correctamente. La primera captura avisó de una copia de proyecto anidada en tmp; el lanzador ahora crea tmp/.gdignore y la captura final ya no presenta ese aviso.

Guía completa: [desarrollo local](../../desarrollo-local.md).

## T03.3 — Visibilidad del menú de inicio

28 de noviembre de 2026. Base local y publicada `9d2479c67c74c9ec5369536f049cf38b34fad2d9`. La captura anterior de 1280×800 mostraba recorte de la cabecera y el pie. La corrección compacta los márgenes y el título. El contenedor de la página desplaza el contenido cuando se necesita y sigue el foco.

| Criterio | Evidencia | Resultado |
| --- | --- | --- |
| INI-01 | `preview` comprueba dimensiones y áreas visibles. Capturas reales de 1280×800 y 1024×640 muestran completos cabecera, acciones, catálogo y pie. En la vista compacta se recorre el menú con Tab hasta «Salir». | Código 0 y `P03_PREVIEW_OK`. |
| INI-02 | La prueba comprueba las cinco conexiones de botones. Un diagnóstico largo de ensayo fuerza la barra vertical en 1024×640 y se comprueban rueda y seguimiento del foco. `test` prueba arranque, diagnóstico, rechazo y recuperación. `preview-network` entra desde el menú y regresa. | `test` 58 comprobaciones y `preview-network` 12, código 0. Los ocho casos negativos del arranque fueron esperados. |

Capturas en `tmp/screenshots/main-screen.png`, `main-screen-compact.png` y `main-screen-compact-exit.png`. Evidencia en `tmp/godot/menu-{preview,test,preview-network}-wrapper.log`. Los PNG y logs son locales y reproducibles.

Riesgo R1. El coordinador implementó y ejecutó las suites en serie. `sdd_visual` (GPT-6.1 Terra, medio) inspeccionó las tres capturas y confirmó legibilidad y foco. `sdd_reviewer` (GPT-6.1 Sol, alto) revisó INI-01/02. La primera pasada del ensayo solo cubría rueda de forma condicional y se amplió con desbordamiento forzado. Las revisiones reutilizaron las capturas y logs. Sin issue, dispensas ni métricas de consumo.

Dictámenes técnico y visual favorables. El ensayo ampliado verifica rueda y Tab con desbordamiento sin depender de la altura del catálogo de arranque. T03.3 completada y lista para publicar.
