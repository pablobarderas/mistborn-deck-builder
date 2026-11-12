# Registro de decisiones

Usar IDs estables. Para cada decisión indicar fecha, estado, contexto, elección y consecuencias. No convertir una propuesta técnica en una preferencia del usuario. Cuando una decisión cambie, marcarla como sustituida y enlazar su reemplazo.

## DEC-001 — Godot y GDScript

- Fecha de registro: 2026-10-26.
- Estado: aceptada; heredada de las instrucciones existentes.
- Fuente: versión original de `data/instrucciones.md` y script existente.
- Decisión: usar Godot 4.x y GDScript, sin C#.
- Consecuencias: la versión exacta y las plataformas de exportación siguen pendientes. El uso de Godot no implica que ya exista un proyecto ejecutable.

## DEC-002 — Contexto duradero dentro del repositorio

- Fecha: 2026-10-26.
- Estado: aceptada para esta tarea.
- Fuente: petición del usuario de crear `AGENTS.md` y documentación que conserve el contexto a largo plazo.
- Decisión: instrucciones estables en `AGENTS.md`; estado, plan, temas y registro en `docs/`, dentro de la raíz Git.
- Consecuencias: actualizar la documentación al cerrar trabajo relevante. El archivo de la carpeta contenedora es solo un punto de entrada local y no está versionado por este repositorio.

## DEC-003 — Destino de uso

- Fecha: 2026-10-26.
- Estado: aceptada.
- Fuente: petición del usuario.
- Decisión: orientar el proyecto a partidas a distancia con amigos.
- Consecuencias: será necesario multijugador, pero no se han acordado plataforma, alojamiento, transporte, autoridad, número de jugadores ni modo inicial.

## DEC-004 — Fidelidad, presentación e idioma

- Fecha: 2026-10-26.
- Estado: aceptada; objetivos expresados por el usuario.
- Decisión: reproducir las reglas del juego de mesa y lograr una presentación cuidada, en español.
- Consecuencias: vincular reglas a fuentes y pruebas; revisar una maqueta temprana y el acabado en partida real. La edición exacta y el catálogo aún no están confirmados.

## DEC-005 — SDD ligero y tareas compatibles con GitHub

- Fecha: 2026-10-26.
- Estado: aceptada como método de trabajo; elección delegada por el usuario.
- Contexto: se pide un plan por fases y se propone usar issues y SDD si resulta eficiente.
- Decisión: especificaciones Markdown para entregas complejas, tareas pequeñas con aceptación y evidencia; backlog local y plantillas de GitHub. No instalar Spec Kit por ahora.
- Consecuencias: trazabilidad entre fase, tarea, especificación, regla y prueba. El plan anterior de cinco fases se sustituye por P00–P18. Publicar issues y subir documentos es un paso posterior; no ha ocurrido en esta tarea.

## DEC-006 — Windows y tablero 2D para comenzar

- Fecha: 2026-10-26.
- Estado: propuesta inicial; plataforma actualizada y aceptada en DEC-009. La propuesta visual 2D se revisará en P05.
- Contexto: el usuario pregunta qué opción sería más sencilla y bonita.
- Propuesta: empezar con aplicación Windows y tablero 2D; investigar pronto el acceso entre redes. Considerar navegador si la distribución mediante enlace o los equipos lo aconsejan.
- Motivo: simplificar el arranque con Godot; ambas plataformas pueden tener un acabado visual cuidado. La exportación web tiene condiciones propias y su red requiere transportes compatibles.
- Consecuencias: no fijar todavía ENet, WebSocket, WebRTC ni proveedor. Comparación y fuentes en [alcance](alcance.md).

## DEC-007 — Participantes y modos

- Fecha: 2026-10-27.
- Estado: aceptada; instrucción expresa del usuario.
- Decisión: máximo cuatro humanos; incluir competitivo 2–4, cooperativo 2–4 y cooperativo en solitario. Esta entrada actualiza lo pendiente de participantes/modo en DEC-003.
- Consecuencias: modelar rival por reglas y mazo, probar siete configuraciones y no considerar finalizada la entrega con solo competitivo. El rival no consume una plaza humana ni es un bot competitivo opcional.

## DEC-008 — Fuente identificada y localización pendiente

- Fecha: 2026-10-27.
- Estado: fuente de trabajo aceptada por haber sido aportada por el usuario como reglas oficiales; equivalencia española pendiente.
- Decisión: registrar el PDF como SRC-001, inglés, 1.ª edición/1.ª impresión de 2024, y documentar reglas por páginas/hash. Mantener español como idioma de producto.
- Consecuencias: no llamar español al archivo ni inventar traducciones oficiales, textos de cartas o correcciones de ambigüedades. El PDF permanece en la ruta original fuera de Git. Contenido faltante y contradicciones se registran en referencias.

## DEC-009 — Windows como plataforma inicial

- Fecha: 2026-10-27.
- Estado: aceptada para la primera entrega; el usuario confirma que todos tienen Windows tras la recomendación de aplicación nativa.
- Decisión: desarrollar y distribuir inicialmente una aplicación para Windows. Esta entrada resuelve la parte de plataforma de DEC-006 y Q-002.
- Consecuencias: orientar entorno y exportación a Windows; concretar versión mínima, hardware y resoluciones en P03/P05. Navegador queda como posible ampliación. El transporte y alojamiento siguen pendientes, y no se da por aprobado todavía el diseño visual.

## DEC-010 — Incorporar FAQ y erratas oficiales

- Fecha: 2026-10-27.
- Estado: aplicada a la documentación, dentro del objetivo de fidelidad oficial.
- Decisión: registrar SRC-002 y aplicar las correcciones expresas del editor sobre SRC-001, manteniendo identificadores, fuentes y estados de dudas.
- Consecuencias: actualizar matriz y especificaciones; no atribuir al PDF aclaraciones posteriores ni declarar resueltos casos sin respuesta. Los cambios de revisión siguen locales; no se publica otro commit sin encargo.

## DEC-011 — Salas privadas, sin cuentas y con reconexión

- Fecha: 2026-10-27.
- Estado: aceptada; confirmación expresa del usuario.
- Decisión: partidas en salas privadas para amigos, sin cuentas permanentes y con posibilidad de reconectarse a la misma partida/plaza.
- Consecuencias: identidad temporal recuperable, restaurar la vista propia y evitar acciones duplicadas. Reentrada deja de ser opcional en P15. Transporte, alojamiento e invitación se diseñarán en P04/P13; pausa, reserva de plaza y caída de autoridad se concretarán en P15. No se infieren guardado persistente ni migración de anfitrión.
- El núcleo funcional permite preparar P03; no exige cerrar ahora el catálogo ni todos los detalles de red. SPEC-001 mantiene sus criterios pendientes explícitos.

## DEC-012 — Base ejecutable de P03

- Fecha: 2026-10-27.
- Estado: implementada y verificada en el entorno Windows actual.
- Decisión: Godot 4.7.2 estable estándar y Compatibility; motor portátil local excluido de Git, versión fijada en .godot-version y lanzador PowerShell. Database como Autoload con señales y recarga observable. Pruebas de arranque en GDScript sin dependencia adicional.
- Motivo: no se encontró una instalación local; se preparó el motor desde su enlace oficial. La versión, importación, pantalla y copia limpia se comprobaron realmente.
- Consecuencias: preservar versión exacta y comandos reproducibles. El cargador rechaza por completo las entradas inválidas necesarias para indexar, sin conservar datos anteriores; el esquema completo sigue en P06. No hay implementación de reglas o red.

## DEC-013 — Continuidad entre equipos

- Fecha: 2026-10-27.
- Estado: aceptada por petición del usuario de subir todo lo necesario a GitHub.
- Decisión: versionar P03, el contexto documental y una copia íntegra de SRC-001 en docs/referencias/fuentes/. Añadir instrucciones de clonación, preparación y reanudación en Codex.
- Consecuencias: sustituye la ubicación fuera de Git indicada en DEC-008 para el PDF; el hash se conserva. Motor, cachés y temporales siguen excluidos y se regeneran. El repositorio conserva los acuerdos, no el historial completo del chat.

## DEC-014 — Autoridad y transporte del experimento P04

- Fecha: 2026-10-27.
- Estado: implementada y verificada localmente; no fija el alojamiento final del producto.
- Decisión técnica: ENet/UDP fiable integrado en Godot, anfitrión como autoridad de contador/lista y hasta tres invitados. Clave temporal, IP/puerto y validación JSON; sin cuentas, RPC ni dependencias de servidor. Motivo y alternativas en [SPEC-004](specs/004-conexion-temprana/plan.md).
- Consecuencias: el cliente solicita y el anfitrión valida/aplica; secuencias por conexión evitan duplicados del ensayo. La autoridad final y proyecciones privadas del juego se concretarán antes de implementar sus reglas remotas. El prototipo no implementa reconexión a plaza ni cifrado.
- El usuario indica que ahora solo tiene un PC: T04.2 y el cierre de P04 requieren una futura prueba externa. No atribuir a localhost evidencia de NAT, dos redes o facilidad de acceso del grupo. No se contrata infraestructura ni se modifica la red del usuario.

## DEC-015 — Propuesta visual del tablero P05

- Fecha: 2026-10-27.
- Estado: dirección visual inicial implementada/verificada y aceptada el 2026-10-27; el usuario confirma presentación de las cartas y encarga commit/push.
- Petición confirmada: diseño limpio, moderno y bonito, colores concordantes con el reglamento. Se revisan visualmente portada y páginas 4/12/18 de SRC-001.
- Propuesta: azul noche/grafito, marfil/plata y acentos de metales; serif para títulos y sans para interfaz, zonas separadas y carta ampliada con foco modal. [Dirección visual](diseno-visual.md) conserva valores y límites.
- Consecuencias: escena autónoma de muestra, sin motor/red/catálogo oficial; ilustraciones provisionales generadas mediante herramienta integrada, atlas/prompt dentro del repositorio. 1280×800 como referencia; 1024×640 con desplazamiento y 1920×1080 adaptado. Cierra P05 en alcance de maqueta, sin fijar requisitos finales de hardware ni acreditar traducción/contenido o arte definitivo.

## DEC-016 — Contrato inicial y flujo de incorporación de cartas

- Fecha: 2026-10-27.
- Estado: implementada y verificada en alcance P06, por encargo de continuar con la fase siguiente.
- Decisión: sobre JSON v1 con fuentes, revisión y definiciones; texto separado de gramática. Rechazo atómico para errores, avisos/sustituto para arte pendiente, copias profundas y selección verificada separada. Los dos ejemplos conservan identidad/texto/números como muestras y cambian rutas inexistentes por null.
- Gramática inicial extensible; op pendiente bloquea verificación. No se ejecutan efectos ni se acredita equivalencia de texto/foto con la validación de estructura. Cantidad desconocida puede ser null en trabajo; no se supone una copia.
- El usuario tiene Android: se documentan Google Drive para lotes y Lens para texto puntual, contrastados con ayuda oficial. El proyecto recibe fotos/PDF y realiza transcripción/revisión asistida; no exige copiar a mano todas las cartas ni integra OCR en esta fase.
- Consecuencias: P06 cerrada como contrato inicial, catálogo oficial y DUD-002/003 pendientes. P07 debe separar instancias de definiciones. Ver [contrato](contrato-catalogo-v1.md) y [captura](captura-de-cartas.md).

## DEC-017 — Diseño local del núcleo P07

- Fecha: 2026-10-28.
- Estado: T07.1 implementada el 2026-10-28 y T07.2 el 2026-10-29; ambas verificadas localmente. P07 no cerrada por P04 externa.
- Decisión técnica: núcleo independiente de escenas/red, transacciones sobre copia, revisiones y recibos por plaza estable, RNG por partida y proyecciones construidas por lista permitida. Motivo: permitir reproducibilidad, rechazo atómico y privacidad antes de conectar transporte.
- Alcance y alternativas en [SPEC-007](specs/007-estado-y-acciones/plan.md). Las restricciones provisionales de visibilidad no son reglas oficiales ni acuerdos de producto. Las operaciones de prueba no serán acciones públicas del jugador.
- Consecuencias: T07.1 precede a T07.2; P04 externa sigue siendo dependencia de cierre. No decide alojamiento, política de desconexión ni reglas con dudas abiertas.

## DEC-018 — Preparación estructural P08

- Fecha: 2026-10-29.
- Estado: decisión técnica implementada y verificada localmente en T08.1a; no es una decisión sobre contenido o reglas pendientes.
- Se separa el manifiesto de copias físicas del catálogo y del snapshot. La autoridad lo construirá con definiciones verificadas, cantidades positivas y relaciones contrastadas; el constructor rechaza omisiones, tipos/cantidades incompatibles y no toca entradas en error.
- Se registra `training_track_id` por plaza y se inicia la fase `inicio` sin ejecutar entrenamiento ni recompensas. Esto permite reanudar un snapshot con su pista identificada y evita abrir un turno como si ya se hubiese aplicado una recompensa desconocida. Se incrementa `version_motor` por la ampliación del esquema.
- Consecuencias: la preparación local se puede probar con fixtures; no se puede alimentar desde las dos muestras actuales. El catálogo oficial y la ejecución del turno siguen pendientes. Véase [SPEC-008](specs/008-preparacion-y-turnos/plan.md).

## DEC-019 — Agentes SDD proporcionales al riesgo

- Fecha: 2026-10-29. Estado: decisión técnica adoptada por encargo explícito del usuario de analizar e implementar el sistema.
- Decisión: coordinador de la sesión y siete perfiles disponibles bajo demanda; Luna medium para apoyo mecánico, Sol medium/high para desarrollo/planificación/reglas/revisión, Terra medium para inspección visual y Astra high solo para escalado difícil. El modelo principal no se cambia. Como máximo dos subagentes concurrentes, un propietario por archivo y sin delegación descendente.
- Motivo: el juego combina reglas/modos/rival, catálogo aún incompleto, privacidad/reconexión y experiencia visual. El contraste independiente protege cambios críticos; un agente por micro paso o todos los especialistas activos duplicarían contexto y coordinación. No existe ahorro de tokens medido ni garantía de calidad por elegir un modelo.
- Consecuencias: [política y análisis](gestion/agentes-sdd.md), configuración de proyecto `.codex/`, validador y [SPEC-009](specs/009-sistema-agentes/spec.md). AGENTS solicita revisión independiente proporcional al riesgo. Si la herramienta no selecciona perfiles, el coordinador transmite instrucciones/modelo explícitos y registra ese modo de aplicación; no se afirma carga nativa sin evidencia.
- No modifica motor, reglas, decisiones de producto, permisos de publicación ni cierres de fase. Material/dudas aplazados y P04 externa continúan pendientes. Modelos disponibles, consumo efectivo y compatibilidad del cliente se comprueban por entorno; revisar la política tras cinco entregas comparables.

## DEC-020 — Cumplimiento obligatorio y dispensas exclusivamente humanas

- Fecha: 2026-10-29. Estado: aceptada por instrucción expresa del usuario: integrar la metodología en los documentos de Codex e impedir omitirla salvo indicación humana expresa. Complementa DEC-019; conserva sus roles, modelos y proporcionalidad.
- Decisión: SDD obligatorio para toda tarea que cambie el proyecto; registro antes de editar y control de cierre según riesgo. Solo una instrucción humana explícita puede dispensar requisitos, con referencia, requisito afectado, alcance y vigencia registrados. Sin vigencia más amplia explícita, se limita a la tarea actual. Ningún agente puede conceder excepciones ni relajar los controles para eximir su propio trabajo; cambiar el método es como mínimo R2.
- Consecuencias: AGENTS, política, siete perfiles, plantillas y recuperación alineados. R0 puede prescindir de agentes dentro de su flujo mínimo; no permite reclasificar o fragmentar un cambio para evitar revisión. Las limitaciones técnicas mantienen pendiente el control dependiente; auto-revisión no sustituye revisión independiente. Una dispensa no convierte evidencia ausente en prueba aprobada ni autoriza publicaciones por sí misma.
- Alcance: obligaciones de conducta y trazabilidad versionables, no un bloqueo técnico infalible del cliente. No altera reglas, decisiones de producto, permisos ni criterios de fases que una dispensa no cubra. Evidencia de la ampliación en AC-07 de [SPEC-009](specs/009-sistema-agentes/verification.md).

## DEC-021 — Un objetivo verificable por sesión y traspaso persistente

- Fecha: 2026-10-29. Estado: aceptada expresamente por el usuario al encargar «Adelante con ello» sobre la propuesta de organizar sesiones por objetivo con cierre/traspaso documentado. Complementa DEC-019/020; no dispensa controles SDD.
- Decisión: una sesión principal reúne los pasos SDD, pruebas y correcciones de un objetivo verificable. Antes de cambiar a otro objetivo, guardar cierre/traspaso breve en la tarea o documento responsable y enlazarlo desde estado/plan. Una interrupción conserva la tarea abierta y permite retomarla en el mismo chat; no se exige una sesión por micro paso ni por cantidad fija de mensajes/tokens.
- Consecuencias: traspaso con objetivo/AC/estado, Git y cambios locales relevantes, decisiones/rutas, evidencia/revisión, bloqueos/dispensas y primer paso siguiente. La siguiente sesión conserva la recuperación obligatoria, contrasta el resumen con archivos/Git y consulta después contexto temático mínimo. Subagentes acotados permanecen dentro del objetivo principal.
- Límites: no autoriza creación/mensajería de chats, commit/push ni aislamiento de archivos por inferencia; las publicaciones se autorizan por entrega. Solo una instrucción humana expresa puede dispensar esta regla, con alcance/vigencia registrados. No hay ahorro de tokens medido ni garantía de reducción; valorar coste de reconstrucción y retrabajo. Evidencia en AC-08 de [SPEC-009](specs/009-sistema-agentes/verification.md).

## DEC-022 — Ciclo personal interno y agotamiento pendiente

- Fecha: 2026-10-29. Estado: decisión técnica implementada y verificada localmente en T08.2a; revisión independiente en SPEC-008.
- Decisión: servicio interno de robo/reciclado personal, descarte y limpieza de cartas con RNG transaccional, sin acciones públicas de robo. El motor P07 envuelve operaciones compuestas y persiste el RNG al commit. Contrato y convenciones reproducibles en [SPEC-008/plan](specs/008-preparacion-y-turnos/plan.md).
- Consecuencias en T08.2a: rechazo técnico atómico `regla_pendiente` cuando el robo excede mazo+descarte. DEC-032 y T08.2i sustituyen esa guardia por el robo de las cartas disponibles.

## DEC-023 — Cierre interno de limpieza con puertas conservadoras

Contrato saldo/fichas y guardia de Atium usado sustituidos por DEC-024; el resto se mantiene.

- Fecha: 2026-10-30. Estado: decisión técnica implementada y verificada localmente en T08.2b, con revisión independiente favorable.
- Decisión: servicio de autoridad únicamente desde limpieza, sin acción pública que pueda saltar combate, Target, efectos o finales. Compone descarte/robo y resets sobre copia; competitivo entrega inicio al siguiente vivo, cooperativo/solo entrega rival al mismo activo. No abre libre ni ejecuta entrenamiento/rival.
- Los mapas ability_uses de jugador/instancias se definen como usos temporales del turno propio. Flags y counters sin duración modelada bloquean; burn_limit y agotamiento Flaring se conservan. Se bloquea Atium usado hasta definir relación entre saldo persistente y fichas, conservando Atium no usado. No es una adaptación de la regla de devolución, que sigue pendiente de ejecutar.
- Consecuencias: [AC-11–14 y límites](specs/008-preparacion-y-turnos/spec.md). La autoridad llamadora sigue obligada a resolver efectos y finales antes de entrar en limpieza; estas guardias no acreditan un turno completo ni una partida jugable. P08/P04 y DUD pendientes se conservan.
## DEC-024 — Atium materializado y saldo total coherente

- Fecha: 2026-10-30. Estado: contrato técnico implementado/verificado localmente en T08.2c; revisión independiente favorable. Sustituye exclusivamente la independencia saldo/fichas y bloqueo por Atium usado de DEC-023; conserva sus demás puertas.
- Decisión: cada unidad de Atium poseída se materializa en `metals`; `persistent.atium` es su total exacto, incluidas usadas hasta devolverlas al limpiar, nunca una reserva adicional. Las disponibles se cuentan por fichas no usadas. Rechazar discrepancias, sin corregirlas automáticamente. Atium no agotado en el subconjunto cuyo único agotamiento modelado es Flaring, prohibido para Atium.
- Consecuencias: retirar usadas y descontar igual cantidad sobre la copia transaccional de limpieza. Sin contador global finito de suministro. Cambio semántico a motor `p08-atium-1/godot-4.7.2`, esquema v1, sin migración heurística de snapshots anteriores. Ganancia, quema, refresco, Confrontation y excepciones de cartas ausentes siguen pendientes. Fuentes y AC en [SPEC-008](specs/008-preparacion-y-turnos/spec.md#t082c--saldo-y-devolución-de-atium).

## DEC-025 — Consultar siempre el estado publicado al reanudar

- Fecha: 2026-11-01. Estado: aceptada por instrucción expresa del usuario: «Asegura el siguiente paso SIEMPRE desde el documento de estado del proyecto github ya que hubo cambios desde otro pc».
- Decisión: obtener la referencia actual de GitHub y leer su estado antes de seleccionar trabajo; registrar hash, contrastar con HEAD/cambios locales/traspaso y conservar divergencias. Un fallo de fetch no convierte la referencia cacheada en evidencia vigente; la selección dependiente espera confirmación remota.
- Consecuencias: actualización de AGENTS, política SDD y [continuidad](continuar-en-otro-pc.md). Esta sesión detectó once commits nuevos y actualizó main de `16b8247` a `6caed87` sin conflictos. No autoriza reset, descarte, commit ni push. Complementa DEC-021; controles SDD y permisos permanecen.

## DEC-026 — Contrato mínimo de secuencias, previo a implementación

Actualización 2026-11-10: diseño implementado en T08.2f, esquema 2/motor `p08-sequence-1/godot-4.7.2`, con revisión independiente favorable. El registro sólo admite funciones estáticas GDScript con firmas inspeccionables compatibles y argumentos enlazados escalares; P07 invoca el resolutor y sella el cierre, mientras los adaptadores de inicio trabajan sobre copia aislada. Se conservan límites, ausencia de migración y obligación de versionar cambios semánticos. [Evidencia y restricciones](specs/008-preparacion-y-turnos/verification.md#t082f--implementación-de-secuencias-reanudables). La entrada original siguiente conserva el estado documental de noviembre 1.

- Fecha: 2026-11-01. Estado: diseño técnico documental T08.2e completado con revisión independiente favorable, no implementado.
- Decisión de diseño: registro cerrado de programas, avance transaccional hasta pausa o cierre, una plaza por ventana en el primer subconjunto, evidencia privada de cierre por ocurrencia e IDs opacos. Reservar esquema v2/motor nuevo para la implementación; rechazar migración implícita.
- Motivo: P07 aporta transacciones y selección pero no reanudación general ni consumo de cierre; una resolución ausente no demuestra obligaciones cumplidas. Se prefiere ledger explícito a dejar una resolución cerrada no nula, preservando el significado de ausencia de bloqueo; sus límites y conservación están documentados.
- Consecuencias: [contrato/escenarios T08.2e](specs/008-preparacion-y-turnos/secuencia-reanudable.md). Sólo programas ficticios en la primera implementación T08.2f. No satisface puertas reglamentarias de T08.2d ni define coordinación colectiva, prioridad terminal o política de reconexión.

## DEC-027 — Competitivo primero, Lord Legislador al final

- Fecha: 2026-11-09. Estado: aceptada por instrucción explícita del usuario: «la parte del lord legislador será la última de todas, de momento nos centraremos en el combate de nacidos de la bruma entre ellos».
- Prioridad: centrar la captura de material y el desarrollo inmediato en competitivo entre Nacidos de la Bruma; abordar la parte del Lord Legislador al final. No solicitar ahora su mazo, Dominación ni otros componentes exclusivos del rival.
- Alcance: cooperativo y solitario siguen comprometidos; se aplazan, no se eliminan. Los criterios de cierre que exigen esos modos continúan pendientes hasta implementarlos y verificarlos. Esta prioridad no habilita combate sin reglas/efectos ni sustituye las dependencias técnicas existentes.
- Capturas actuales: completar los entrenamientos de los otros tres personajes y las pistas/paneles necesarios para competitivo. El usuario confirma que Financiación tiene seis copias idénticas por personaje al inicio; basta el diseño escaneado para representar las 24 cartas. Esta confirmación no incorpora ni verifica automáticamente el catálogo.

## DEC-028 — Funding como primer programa reglamentario competitivo

Ampliación técnica T08.2h, 2026-11-11: adaptador GameEngine con perfil completo validado, registro cerrado y `catalog_identity()` derivada por SHA-256 del catálogo canonicalizado. Sólo una Funding es compatible y los descriptores inertes coinciden exactamente con las demás definiciones; el documento validado identifica así el perfil completo. Reordenar claves o reconstruir enteros desde JSON conserva identidad; cambiar contenido bajo el mismo ID editorial impide cargar cierres. Esquema 2/motor `p08-funding-1/godot-4.7.2`, sin migración. [Estado de pruebas y revisión](specs/008-preparacion-y-turnos/verification.md#t082h--implementación-de-funding); no cambia el contrato P06 ni incorpora catálogo oficial.

- Fecha: 2026-11-11. Estado: diseño técnico T08.2g completado documentalmente y revisado independientemente; implementación T08.2h completada localmente y revisada independientemente. No es una nueva preferencia humana ni una regla casera.
- Elección: programa cerrado de juego Funding con movimiento mano→juego y aplicación u omisión explícita de su moneda según SRC-001 p.11 y SRC-002 Action cards. Usa reserva del turno, nunca Boxings. Motivo: primera regla de carta compatible con T08.2f, sin ampliar fases/terminales antes del contrato de combate.
- Consecuencias: [contrato, contenido soportado y escenarios](specs/008-preparacion-y-turnos/primer-resolutor-competitivo.md). Sólo competitivo 2–4 en esta implementación; conserva cooperativo/solo como alcance posterior y DEC-027. Descriptores completos y perfil cerrado de autoridad; fixtures no verifican catálogo español. El futuro cambio semántico versionará motor, sin migración implícita. No autoriza entrada a limpieza ni apertura de libre.

## DEC-029 — Reducir redundancia sin rebajar calidad

- Fecha: 2026-11-11. Estado: política implementada documentalmente y revisada independientemente, por encargo humano «de acuerdo pues vamos a mejorar eso» sobre el consumo excesivo observado. Aplicar [AC-10](gestion/agentes-sdd.md#protocolo-operativo-de-trabajo-contenido--ac-10): lectura y salida selectivas, delegación mínima justificada, coordinación por resultados, reutilización comprobable de pruebas y memoria sin copias del mismo informe. Mantiene todos los controles SDD y permisos; ninguna dispensa ni ahorro medido atribuido.

## DEC-030 — Consumo del inicio competitivo por transición de fase

2026-11-12. Diseño técnico implementado en T08.1b4 para el perfil aislado. Reutiliza los recibos de P07 con una entrada interna separada de las acciones de jugador. Consume el inicio al confirmar la transición y el avance en la misma transacción. El perfil cerrado identifica la ocurrencia por partida, turno y plaza con transiciones monotónicas. La fuente tipada de autoridad selecciona el último estado confirmado. [Contrato y límites](specs/008-preparacion-y-turnos/inicio-competitivo.md).

## DEC-031 — Criterios de la edición española y reglas competitivas

2026-11-12. Aceptada por indicación expresa del usuario para T08.1b6.

- En discrepancias de este tipo entre el material español y el inglés, usar el material de la edición española del proyecto. Para el nivel II, se admite comprar una Acción o un Aliado, resolver su capacidad primaria y eliminar la carta después. Se conserva el contraste con la FAQ y las erratas expresas del editor.
- La carta apartada por Guardadora pasa a la mano antes de avanzar en la pista de entrenamiento, dentro de un único inicio de turno. El orden es interno, sin ventana de acción ni estado intermedio visible.
- Guarnición de Luthadel y Fortaleza Venture conceden su beneficio permanente en el momento de completar la misión, también en ese turno. En turnos posteriores se aplica una vez por turno.
- Al comparar plazas en competitivo o cooperativo, todos los marcadores empatados en un extremo cumplen la condición de ese extremo. Los marcadores que aún no han entrado en la misión quedan fuera del cálculo. Se conservan los casos reglamentarios de único marcador, primero en completar y la excepción de solitario de REG-065.

[Reglas y escenarios](specs/008-preparacion-y-turnos/perfil-competitivo-producto.md).

## DEC-032 — Desbloqueo tardío, robo personal y finales del rival

2026-11-12. Aceptada por indicación expresa del usuario. Cierra DUD-004 y DUD-006 para la adaptación.

- Una habilidad de personaje que acaba de desbloquearse puede activarse ese mismo turno si su metal requerido ya se quemó en ese turno. Se conservan los demás requisitos y el límite de una activación por turno de los niveles I y III.
- Ante un robo personal, reciclar el descarte si se acaba el mazo. Si ambos están vacíos, omitir las cartas que queden por robar. Las cartas obtenidas antes de agotar ambas zonas permanecen en la mano. T08.2i aplica esta regla y sustituye el bloqueo técnico de DEC-022.
- En solitario y cooperativo, ganar inmediatamente cuando la salud del Lord Legislador llega a cero o se resuelve Confrontación con cuatro Atium. Si ocurre durante el turno humano, la partida termina antes del robo rival. Si la partida continúa, tras descartar y robar la nueva mano se intenta robar la carta rival. Se pierde inmediatamente si su mazo ya está vacío en ese intento. Si queda una carta, se roba y se resuelve según su efecto.

[Casos de integración](specs/008-preparacion-y-turnos/verification.md#t081b7--desbloqueo-tardío-robo-y-finales-del-rival).

## Decisiones aún pendientes

- Equivalencia con edición española, terminología, catálogo completo y dudas del reglamento recibido.
- Alcance mínimo de una partida jugable.
- Compatibilidad mínima de Windows y objetivos finales de hardware/resolución; Godot 4.7.2 ya está fijado.
- Ampliación del contrato y gramática de efectos para contenido real; contrato inicial y política de carga resueltos en DEC-016.
- Implementación de reglas/efectos y adaptación del núcleo a contenido verificado; el núcleo local estructural ya existe (DEC-017) y la preparación estructural en DEC-018.
- Transporte/alojamiento, formato de invitación, pausa/reserva y pérdida de autoridad; salas privadas sin cuentas y reconexión ya están acordadas.

Registrar una nueva entrada cuando haya evidencia suficiente o un acuerdo; mientras tanto, mantener la incertidumbre explícita.
