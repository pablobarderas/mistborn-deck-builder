# Estado actual

Última revisión: 2026-10-27.

## Resumen

**P05 completada en su alcance de maqueta, verificada técnicamente y aceptada como dirección visual inicial por el usuario.** P03 completada y T04.1 verificada localmente; P04 sigue abierta por la prueba entre redes. Existe tablero interactivo de muestra, sin partida jugable ni reglas ejecutables.

## Implementado y verificado

| Elemento | Estado |
| --- | --- |
| project.godot / .godot-version | Godot 4.7.2 estable estándar, Compatibility, referencia visual 1280×800. |
| scripts/Database.gd | Autoload; carga al iniciar, recarga, señales, estado y diagnóstico. Rechaza raíz/entradas/IDs inválidos y no conserva un catálogo obsoleto. |
| scenes/MainScreen.tscn | Pantalla inicial en español; muestra catálogo, recarga y salida funcionales. |
| scenes/CardPreview.tscn | Nombre, cifras y descripción de cada ejemplo; sustituto de ilustración. |
| scenes/ConnectionScreen.tscn / scripts/network/connection_probe.gd | Ensayo ENet/UDP, anfitrión como autoridad, clave temporal, lista y contador. Se abre desde Probar conexión. |
| scenes/BoardPreview.tscn / scripts/board/ | Maqueta de mercado, participantes, misiones, mano, metales y recursos. Cartas ampliables y colocación visual reversible. Se abre desde Ver tablero. |
| assets/images/board/ | Atlas de cuatro ilustraciones provisionales generadas; procedencia y prompt conservados. |
| scenes/theme.tres / assets/images/ | Tema y fondo vectorial propios provisionales. |
| data/cartas.json | Dos ejemplos originales sin cambios de contenido; no son un catálogo oficial validado. |
| tools/godot.ps1 | Importar, ejecutar, editor, pruebas y capturas; acciones network, test-network y preview-network para el ensayo. |
| tests/ | Carga/recuperación, red con procesos independientes y capturas gráficas. |
| docs/specs/ | SPEC-001/002 parciales; SPEC-003 completada; SPEC-004 local verificada, externa pendiente; SPEC-005 completada como maqueta inicial. |
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

## Verificación local de P04

- ENet con anfitrión y tres clientes independientes: lista de cuatro y contador convergente. 47 comprobaciones del coordinador y 26 de siete procesos hijo, código 0. Rechazados accesos incorrectos, quinto participante, acciones inválidas/repetidas y estado forjado.
- Navegación, botones y liberación de puerto comprobados con render real: 12 comprobaciones y capturas a 1280×800 y 1024×640. P03 conserva sus 58 comprobaciones.
- El usuario dispone de un solo PC. No hay evidencia externa; transporte/alojamiento del producto siguen pendientes. No confundir conexión experimental con salas de partida o recuperación de plaza.
- El usuario confirma que la pantalla inicial se ve bien; esto no sustituye la revisión del tablero de P05.
- Tras entregar P04 local, el usuario confirma «Funciona perfecto»; registrado en SPEC-004. La prueba entre redes sigue pendiente.

Instrucciones para dos ventanas en [prueba de conexión](prueba-de-conexion.md); criterios y evidencia en [SPEC-004](specs/004-conexion-temprana/verification.md).

## Propuesta visual de P05

- Petición confirmada: limpia, moderna y bonita, con colores concordantes con el PDF. Adaptación azul noche/grafito, plata/marfil y acentos de metales; [dirección visual](diseno-visual.md) documenta tipografías y estados.
- Escena autónoma con seis cartas de mercado, cinco/diez de mano, tres misiones y cuatro participantes de muestra. Detalle, Escape, foco, alternancia visual de metales, colocación de carta y reinicio. No modifica catálogo ni usa reglas/red.
- Verificación: 39 comprobaciones, código 0; seis capturas reales a 1280×800, 1920×1080 y 1024×640. Regresión P03: 58 comprobaciones y captura del inicio correctas.
- T05.1 y T05.2 completadas en alcance de maqueta. El usuario confirma «se ven bien las cartas» y autoriza commit/push. Arte, valores, traducciones y efectos siguen siendo provisionales; no declarar fidelidad del catálogo ni aprobación del arte definitivo con esta maqueta.

Abrir con Ver tablero o `-Action board`; reproducir comprobaciones con `-Action preview-board`. Evidencia en [SPEC-005](specs/005-maqueta-tablero/verification.md).

## Pendiente de implementación

Motor de reglas y estado de partida, todos los modos, catálogo completo, interfaz jugable, salas privadas del producto, sincronización de partidas, recuperación de plaza y distribución. La red actual solo transporta el ensayo de contador.

La validación de datos es mínima: campos de efectos, tipos restantes, restricciones numéricas y referencias necesitan P06. Las rutas de imágenes originales apuntan a assets/cartas/, no a la convención assets/images/; la vista actual usa sustitutos y no modifica esas rutas.

## Producto y fuentes

Confirmado: Windows, español, máximo cuatro humanos; competitivo 2–4, cooperativo 2–4 y solitario cooperativo 1. Salas privadas sin cuentas y reconexión obligatoria. El diseño visual actual es provisional; pausa/reserva de plaza y pérdida de autoridad se concretarán en P15.

SRC-001: PDF inglés de 2024, 1.ª edición/1.ª impresión, 20 páginas; leído y revisado visualmente. Copia original incluida en Git, ruta/hash en [fuentes](referencias/README.md). SRC-002 añade FAQ/erratas oficiales; 75 reglas documentadas, ninguna implementada. Siete registros DUD: dos resueltos, uno parcial y cuatro abiertos.

SRC-003 identifica la publicación española de Devir. El usuario aporta «Edición: David Pérez»; falta contrastar textos/tirada y completar cartas y pistas. No repetir la pregunta de editorial ni los acuerdos de acceso/jugadores.

## Repositorio y reanudación

La raíz Git es la carpeta que contiene project.godot y AGENTS.md; en el equipo original es mistborn-deck-builder/, dentro de la carpeta contenedora. La entrega documental inicial fue f2a5744. Esta entrega reúne las revisiones posteriores, P03 y el PDF para su publicación en main a petición del usuario. No se han creado issues. Consulta [continuar en otro PC](continuar-en-otro-pc.md); el historial de Git identifica el commit de esta entrega.

P04: T04.1 completada; T04.2 pendiente de segundo equipo y prueba entre redes. P05 cerrada como dirección visual inicial. **Siguiente fase independiente: P06, contrato del catálogo**. SPEC-001 mantiene detalles de contenido y producto pendientes sin bloquear tareas independientes. Consultar [plan](plan-de-trabajo.md) y [backlog](gestion/backlog.md). La entrega de P04/P05 se reúne en un commit para main por petición del usuario; el historial de Git identifica la revisión publicada. No se han creado issues.
