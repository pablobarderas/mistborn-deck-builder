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
