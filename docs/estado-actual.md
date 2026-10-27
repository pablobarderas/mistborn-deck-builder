# Estado actual

Última revisión: 2026-10-27.

## Resumen

**P06 completada en su alcance de contrato inicial y validación.** P05 aceptada como maqueta visual; P03 y T04.1 completadas en su alcance. P04 sigue abierta por la prueba entre redes. Existe tablero interactivo de muestra, sin partida jugable ni reglas ejecutables.

## Implementado y verificado

| Elemento | Estado |
| --- | --- |
| project.godot / .godot-version | Godot 4.7.2 estable estándar, Compatibility, referencia visual 1280×800. |
| scripts/Database.gd / scripts/catalog/ | Autoload y validador v1; rechazo atómico, revisión/fuentes/efectos/referencias, avisos, conteos y copias profundas. Cero definiciones verificadas actuales. |
| scenes/MainScreen.tscn | Pantalla inicial en español; muestra catálogo, recarga y salida funcionales. |
| scenes/CardPreview.tscn | Nombre, cifras y descripción de cada ejemplo; sustituto de ilustración. |
| scenes/ConnectionScreen.tscn / scripts/network/connection_probe.gd | Ensayo ENet/UDP, anfitrión como autoridad, clave temporal, lista y contador. Se abre desde Probar conexión. |
| scenes/BoardPreview.tscn / scripts/board/ | Maqueta de mercado, participantes, misiones, mano, metales y recursos. Cartas ampliables y colocación visual reversible. Se abre desde Ver tablero. |
| assets/images/board/ | Atlas de cuatro ilustraciones provisionales generadas; procedencia y prompt conservados. |
| scenes/theme.tres / assets/images/ | Tema y fondo vectorial propios provisionales. |
| data/cartas.json | Sobre v1 con dos muestras migradas explícitamente; conserva IDs/texto/números y elimina rutas ficticias. No es catálogo oficial. |
| tools/godot.ps1 | Importar, ejecutar, editor, pruebas y capturas; acciones network, test-network y preview-network para el ensayo. |
| tests/ | Carga/recuperación, red con procesos independientes y capturas gráficas. |
| docs/specs/ | SPEC-001/002 parciales; SPEC-003/005/006 completadas en su alcance; SPEC-004 local verificada, externa pendiente. |
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

## Contrato y validación P06

- Contrato v1 en [datos de cartas](datos-de-cartas.md) y [detalle normativo](contrato-catalogo-v1.md). Definiciones, procedencia y estados muestra/borrador/verificada; cantidades desconocidas como null, texto separado de gramática y operación pendiente para lo no modelado.
- Errores estructurales rechazan toda la carga. Imágenes nulas/ausentes generan avisos y sustituto. Las fuentes físicas necesitan archivo; referencias resueltas. Definiciones verificadas exigen revisión declarada sin dudas ni dependencias sin verificar. El validador no certifica el contenido de una imagen ni ejecuta efectos.
- 220 comprobaciones de contrato, 58 de arranque y 39 de maqueta, código 0. Inicio con conteos/avisos revisado en captura real. El lanzador rechaza SCRIPT ERROR incluso con código 0.
- El usuario confirma Android; [captura por lotes](captura-de-cartas.md) explica Drive para escanear y Lens para texto puntual. No hay OCR integrado ni fotos de cartas recibidas todavía.
- T06.1/2 completadas. Continúan abiertas DUD-002/003 y la incorporación de contenido oficial; no convertir las muestras actuales en cartas verificadas.

## Pendiente de implementación

Motor de reglas y estado de partida, todos los modos, catálogo completo, interfaz jugable, salas privadas del producto, sincronización de partidas, recuperación de plaza y distribución. La red actual solo transporta el ensayo de contador.

La gramática de P06 es inicial y extensible: no cubre por sí sola todos los efectos reales todavía no recibidos. Nuevas familias requieren fuente, especificación y pruebas. Las rutas visuales del contrato se restringen a assets/images/; los dos ejemplos usan null y sustituto.

## Producto y fuentes

Confirmado: Windows, español, máximo cuatro humanos; competitivo 2–4, cooperativo 2–4 y solitario cooperativo 1. Salas privadas sin cuentas y reconexión obligatoria. El diseño visual actual es provisional; pausa/reserva de plaza y pérdida de autoridad se concretarán en P15.

SRC-001: PDF inglés de 2024, 1.ª edición/1.ª impresión, 20 páginas; leído y revisado visualmente. Copia original incluida en Git, ruta/hash en [fuentes](referencias/README.md). SRC-002 añade FAQ/erratas oficiales; 75 reglas documentadas, ninguna implementada. Siete registros DUD: dos resueltos, uno parcial y cuatro abiertos.

SRC-003 identifica la publicación española de Devir. El usuario aporta «Edición: David Pérez»; falta contrastar textos/tirada y completar cartas y pistas. No repetir la pregunta de editorial ni los acuerdos de acceso/jugadores.

## Repositorio y reanudación

La raíz Git es la carpeta que contiene project.godot y AGENTS.md; en el equipo original es mistborn-deck-builder/, dentro de la carpeta contenedora. La entrega documental inicial fue f2a5744. Esta entrega reúne las revisiones posteriores, P03 y el PDF para su publicación en main a petición del usuario. No se han creado issues. Consulta [continuar en otro PC](continuar-en-otro-pc.md); el historial de Git identifica el commit de esta entrega.

P04: T04.1 completada; T04.2 pendiente de segundo equipo y prueba entre redes. P05/P06 cerradas en su alcance. **Próximo trabajo: especificar P07, estado/acciones de partida**, pudiendo preparar lo local; no dar por cumplida su dependencia P04 para el cierre mientras falte evidencia externa. Los lotes de cartas pueden incorporarse en paralelo cuando estén disponibles. P04/P05 están publicadas en e5cd684; la entrega de P06 se publica en main por petición del usuario el 2026-10-27. Su revisión se identifica en el historial de Git. No se han creado issues.
