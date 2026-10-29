# Estado actual

Última revisión: 2026-10-29.

## Resumen

**T08.1a implementada y verificada localmente; T07.1/2 también.** P06 completada en su alcance de contrato inicial y validación. P05 aceptada como maqueta visual; P03 y T04.1 completadas en su alcance. P04 sigue abierta por la prueba entre redes. Existe tablero interactivo de muestra, sin partida jugable ni reglas de cartas ejecutables.

## Implementado y verificado

Sistema transversal de [agentes SDD](gestion/agentes-sdd.md) añadido el 2026-10-29 (SPEC-009): perfiles/modelos por riesgo, concurrencia limitada y revisión independiente. Configuración estática y delegación por instrucciones comprobadas; la carga nativa automática de perfiles no queda acreditada por el diagnóstico local. No cambia el avance del juego ni demuestra ahorro de tokens. Evidencia y revisión de la entrega en [SPEC-009](specs/009-sistema-agentes/verification.md).

Cumplimiento obligatorio por instrucción humana adicional del 2026-10-29 (DEC-020/AC-07): instrucciones, perfiles y plantillas exigen controles por riesgo y registro antes de editar/cerrar. Solo una dispensa humana explícita, trazable y con alcance/vigencia permite excepciones; no hay dispensas vigentes registradas para esta ampliación. Son obligaciones de instrucciones y evidencia, no un bloqueo técnico infalible del cliente.

El usuario autoriza el 2026-10-29 publicar todo el paquete T00.1/SPEC-009 por commit/push con el cambio de paradigma de desarrollo; el commit que contiene esta entrada conserva el método y su evidencia para otros equipos/chats. Las notas «sin commit/push» de las sesiones anteriores describen su estado histórico, no una prohibición vigente para esta entrega.

Ampliación AC-08/DEC-021 completada y revisada independientemente: un objetivo verificable por sesión principal con cierre/traspaso persistente y recuperación contrastada. El paquete anterior se publicó en `f5d77dc`; un encargo posterior del 2026-10-29 autoriza expresamente commit/push detallado de AC-08. La revisión que contiene esta actualización identifica su entrega; las notas anteriores de trabajo local describen el estado previo al permiso. [Estado, evidencia y traspaso de AC-08](specs/009-sistema-agentes/verification.md#ampliación-ac-08--sesiones-y-contexto); siguiente objetivo del juego sigue siendo la parte confirmada de T08.2, sin reabrir material/dudas aplazados.

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
| scripts/game/ | T07.1/2: estado privado, invariantes, acciones atómicas, RNG y proyecciones por jugador. Sin manejadores de reglas reales. |
| scripts/game/game_setup.gd | T08.1a: preparación estructural determinista de siete configuraciones desde manifiesto y definiciones verificadas. No abre el turno libre ni interpreta efectos. |
| tests/ | Estado (1.741 tras P08), preparación (147) y acciones (102) con fixtures ficticios, catálogo/carga, red experimental y capturas; resultados históricos documentados, no nuevas pruebas en SPEC-009. |
| docs/specs/ | SPEC-001/002 parciales; SPEC-003/005/006 completadas en su alcance; SPEC-004 local verificada, externa pendiente; SPEC-007 local verificada (T07.1/2), P04 externa pendiente para cierre P07; SPEC-008 T08.1a verificada, P08 abierta. |
| .github/ | Plantillas de issues y PR de la entrega inicial publicada. |

El motor portátil previsto en .tools/godot/ se ignora por Git; en este equipo no existe y se usa Godot 4.7.2 desde Descargas mediante -GodotPath. Datos y cachés generados en .godot/ y tmp/ también ignorados. Los UID de scripts y ajustes de importación de recursos son metadatos de fuente.

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

Motor de reglas/acciones, preparación de todos los modos, catálogo completo, interfaz jugable, salas privadas del producto, sincronización de partidas, recuperación de plaza y distribución. La red actual solo transporta el ensayo de contador.

La gramática de P06 es inicial y extensible: no cubre por sí sola todos los efectos reales todavía no recibidos. Nuevas familias requieren fuente, especificación y pruebas. Las rutas visuales del contrato se restringen a assets/images/; los dos ejemplos usan null y sustituto.

## Producto y fuentes

Confirmado: Windows, español, máximo cuatro humanos; competitivo 2–4, cooperativo 2–4 y solitario cooperativo 1. Salas privadas sin cuentas y reconexión obligatoria. El diseño visual actual es provisional; pausa/reserva de plaza y pérdida de autoridad se concretarán en P15.

SRC-001: PDF inglés de 2024, 1.ª edición/1.ª impresión, 20 páginas; leído y revisado visualmente. Copia original incluida en Git, ruta/hash en [fuentes](referencias/README.md). SRC-002 añade FAQ/erratas oficiales; 75 reglas documentadas, con cobertura estructural parcial de REG-001–006/052 en T08.1a. Siete registros DUD: dos resueltos, uno parcial y cuatro abiertos.

SRC-003 identifica la publicación española de Devir. El usuario aporta «Edición: David Pérez»; falta contrastar textos/tirada y completar cartas y pistas. No repetir la pregunta de editorial ni los acuerdos de acceso/jugadores.

## Repositorio y reanudación

La raíz Git es la carpeta que contiene project.godot y AGENTS.md. T07.1 (`b3ff3c7`), T07.2 (`1930313`) y T08.1a (`acb507a`) están publicadas en `origin/main`. No se han creado issues. Consulta [continuar en otro PC](continuar-en-otro-pc.md) para la reanudación. El 2026-10-29 se revisaron y descartaron los tres cambios locales antiguos de Godot (`project.godot` y dos `.import`); la prueba de arranque volvió a pasar y el árbol de trabajo quedó limpio.

P04: T04.1 completada; T04.2 pendiente de segundo equipo y prueba entre redes. P05/P06 cerradas en su alcance. **T07.1/2 y T08.1a implementadas y verificadas localmente.** El usuario deja por ahora pendientes las fotos del material español y las DUD-004/005/006; no se ha acordado ninguna interpretación nueva. T08.1b espera pistas y recompensas verificadas. Al reanudar sin ese material, el siguiente trabajo independiente es la parte confirmada de T08.2 (ciclo del mazo y descarte), manteniendo sin resolver el caso de mazo y descarte vacíos. No dar por cumplida la dependencia P04 para cerrar P07. No se han creado issues.

## Núcleo local de P07

[SPEC-007](specs/007-estado-y-acciones/spec.md) define estado, acciones atómicas, recibos por plaza, RNG reproducible, privacidad y resoluciones pendientes. T07.1 implementada: almacén RefCounted y validador de invariantes sin escenas/red, copias profundas y rechazo completo de snapshots inválidos. 1.725 comprobaciones de estado, 220 de catálogo y 58 de arranque, código 0. T07.2 implementada localmente: intenciones validadas, cambios atómicos, RNG reproducible, recibos por plaza y proyecciones conservadoras. 102 comprobaciones del motor, código 0. No hay manejadores de reglas ni adaptador de red/producto. La política conservadora de zonas no contrastadas está identificada como provisional. P07 sigue abierta y mantiene dependencia de cierre P04.

## Preparación local de P08

[SPEC-008](specs/008-preparacion-y-turnos/spec.md) concreta T08.1a. `game_setup.gd` exige un manifiesto completo y definiciones declaradas verificadas, con cantidades suficientes; sin ello rechaza la preparación. Sortea personajes/misiones y primer jugador cooperativo, baraja mazos, reparte manos, aplica bonificaciones/Target solo en competitivo y crea rival 48/1/36 en cooperativo/solo. Deja `turn.phase=inicio`: el entrenamiento inicial y sus recompensas no se han ejecutado. El esquema de estado añade `training_track_id` por jugador y sube `version_motor` a `p08-setup-1/godot-4.7.2`.

Pruebas reales: `test-setup` 147 comprobaciones; regresión de estado 1.741, motor 102, catálogo 220 y arranque 58, código 0. No existe manifiesto de cartas reales ni adaptador de producto, por lo que no se puede iniciar una partida auténtica. No se ha probado interfaz manual de P08; aún no existe. P04 externa sigue pendiente.
