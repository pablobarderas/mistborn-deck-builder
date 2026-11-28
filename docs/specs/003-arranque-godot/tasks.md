# Tareas de SPEC-003

| ID | Resultado | Depende de | Criterios | Estado |
| --- | --- | --- | --- | --- |
| T03.1 | Versión fija, configuración y escena inicial de Godot | Núcleo funcional P02 confirmado | AC-01, AC-03 | Completada 2026-10-27; sin publicar |
| T03.2 | Autoload, diagnóstico y comandos comprobados en copia limpia | T03.1 | AC-02, AC-04 a AC-06 | Completada 2026-10-27; sin publicar |

## T03.3 — Visibilidad del menú de inicio

Base local y publicada `9d2479c67c74c9ec5369536f049cf38b34fad2d9`, rama principal y árbol limpio. La captura de la retirada del prototipo muestra contenido del menú recortado a 1280×800. Riesgo R1 por la navegación y el foco de la pantalla de entrada. Sin issue ni dispensas.

- INI-01. Mostrar el menú completo a 1280×800 con el catálogo de arranque. A 1024×640, los controles del menú y la salida deben poder alcanzarse con teclado y ratón, incluso si la ventana requiere desplazamiento vertical.
- INI-02. Conservar los destinos de los botones, el diagnóstico de catálogo y las acciones de recarga y salida. Probar foco, área visible y desplazamiento con render real, y pasar la regresión de arranque.

Plan: el coordinador corrige el contenedor y los tamaños locales y amplía la captura de arranque para comprobar ambos tamaños y recorrer los botones con Tab. Revisión técnica y visual independientes antes del cierre. Alcance: interfaz del proyecto existente y su verificación. E3 mantiene sus criterios de admisión y ejecución.

Estado: INI-01/02 completados. [Pruebas y revisiones](verification.md#t033--visibilidad-del-menú-de-inicio).
