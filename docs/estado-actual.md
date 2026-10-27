# Estado actual

Última revisión: 2026-10-27.

## Resumen

**P03 completada:** existe un proyecto Godot ejecutable con pantalla en español, dos cartas de ejemplo, comprobación de catálogo y salida. No hay todavía partida jugable, reglas ejecutables ni salas.

## Implementado y verificado

| Elemento | Estado |
| --- | --- |
| project.godot / .godot-version | Godot 4.7.2 estable estándar, Compatibility, referencia visual 1280×800. |
| scripts/Database.gd | Autoload; carga al iniciar, recarga, señales, estado y diagnóstico. Rechaza raíz/entradas/IDs inválidos y no conserva un catálogo obsoleto. |
| scenes/MainScreen.tscn | Pantalla inicial en español; muestra catálogo, recarga y salida funcionales. |
| scenes/CardPreview.tscn | Nombre, cifras y descripción de cada ejemplo; sustituto de ilustración. |
| scenes/theme.tres / assets/images/ | Tema y fondo vectorial propios provisionales. |
| data/cartas.json | Dos ejemplos originales sin cambios de contenido; no son un catálogo oficial validado. |
| tools/godot.ps1 | Importar, ejecutar, editor, pruebas y captura; comprueba versión y resultados. |
| tests/ | Pruebas de carga/recuperación y captura gráfica. |
| docs/specs/ | SPEC-001/002 parciales; SPEC-003 completada en su alcance. |
| .github/ | Plantillas de issues y PR de la entrega inicial publicada. |

Motor portátil en .tools/godot/, ignorado por Git. Datos y cachés generados en .godot/ y tmp/ también ignorados. Los UID de scripts y ajustes de importación de recursos son metadatos de fuente.

## Verificación real de P03

- Godot devuelve 4.7.2.stable.official.ed1daf0bf.
- Importación y pruebas reales, código 0. Versión final desde tmp/clean-p03-final-a7f5c922 sin caché previa: 58 comprobaciones superadas.
- Ocho fallos de carga son entradas negativas esperadas; se verifica error visible, retirada del contenido anterior y recuperación con datos válidos.
- Captura gráfica 1280×800 revisada en Compatibility/OpenGL 3.3 sobre NVIDIA GeForce RTX 5060 Ti. El script sale mediante la señal del botón Salir.
- La resolución y GPU anteriores describen este entorno; los objetivos finales para los equipos del grupo siguen pendientes.
- No se han probado partidas, red ni exportación distribuible.

Comandos en [desarrollo local](desarrollo-local.md); evidencia por criterio en [SPEC-003](specs/003-arranque-godot/verification.md).

## Pendiente de implementación

Motor de reglas y estado de partida, todos los modos, catálogo completo, interfaz jugable, salas privadas, sincronización, reconexión y distribución.

La validación de datos es mínima: campos de efectos, tipos restantes, restricciones numéricas y referencias necesitan P06. Las rutas de imágenes originales apuntan a assets/cartas/, no a la convención assets/images/; la vista actual usa sustitutos y no modifica esas rutas.

## Producto y fuentes

Confirmado: Windows, español, máximo cuatro humanos; competitivo 2–4, cooperativo 2–4 y solitario cooperativo 1. Salas privadas sin cuentas y reconexión obligatoria. El diseño visual actual es provisional; pausa/reserva de plaza y pérdida de autoridad se concretarán en P15.

SRC-001: PDF inglés de 2024, 1.ª edición/1.ª impresión, 20 páginas; leído y revisado visualmente. Copia original incluida en Git, ruta/hash en [fuentes](referencias/README.md). SRC-002 añade FAQ/erratas oficiales; 75 reglas documentadas, ninguna implementada. Siete registros DUD: dos resueltos, uno parcial y cuatro abiertos.

SRC-003 identifica la publicación española de Devir. El usuario aporta «Edición: David Pérez»; falta contrastar textos/tirada y completar cartas y pistas. No repetir la pregunta de editorial ni los acuerdos de acceso/jugadores.

## Repositorio y reanudación

La raíz Git es la carpeta que contiene project.godot y AGENTS.md; en el equipo original es mistborn-deck-builder/, dentro de la carpeta contenedora. La entrega documental inicial fue f2a5744. Esta entrega reúne las revisiones posteriores, P03 y el PDF para su publicación en main a petición del usuario. No se han creado issues. Consulta [continuar en otro PC](continuar-en-otro-pc.md); el historial de Git identifica el commit de esta entrega.

Próxima fase de ejecución: **P04, especificar y probar una conexión entre redes**. P05 puede revisar la propuesta visual por separado. SPEC-001 mantiene detalles de catálogo y producto pendientes sin bloquear las tareas técnicas independientes. Consultar [plan](plan-de-trabajo.md) y [backlog](gestion/backlog.md).
