# Plan de SPEC-003

1. Fijar .godot-version y configurar project.godot: escena, Autoload, idioma y Compatibility.
2. Adaptar Database.gd con tipado, carga explícita, señales de éxito/error y validación mínima de IDs. Elegir fallo completo y catálogo vacío en esta base para no mostrar datos obsoletos.
3. Añadir pantalla y tarjeta de previsualización como escenas; tema y fondo vectorial propios. Mostrar contenido de ejemplo y sus cifras sin ejecutar efectos.
4. Añadir un lanzador PowerShell que resuelva el motor portátil o una ruta indicada, compruebe versión y propague fallos.
5. Ejecutar pruebas de carga y recuperación en GDScript sin framework externo; importar/arrancar una copia limpia de fuentes.
6. Capturar el render real mediante Godot y revisar legibilidad y distribución. Documentar entorno y evidencia en verification.md.

Referencias técnicas consultadas: [descarga oficial](https://godotengine.org/download/windows/), [CLI](https://docs.godotengine.org/en/stable/tutorials/editor/command_line_tutorial.html) y [JSON](https://docs.godotengine.org/en/stable/classes/class_json.html). Fecha: 2026-10-27.

No se modifica el contenido de cartas.json ni se fijan contratos de red o de efectos. .tools/, .godot/, tmp/ y builds/ quedan fuera de Git.
