# Registro de decisiones

## DEC-056 — Confirmación de cierre de secuencia en el ensayo E3

2026-11-27. Decisión técnica aplicada en FIN-01–03. El motor protege el resultado durante la secuencia y permite que la confirmación de autoridad del cierre indique un error. Ese error aborta la transacción antes de publicar el candidato. El perfil de ensayo usa la confirmación para registrar la llegada y el resultado junto con el recibo. [Contrato](specs/011-competitivo-completo/finalizacion.md) · [Evidencia](specs/011-competitivo-completo/verification.md#ensayo-de-finalización).

## DEC-055 — Persistencia y reacción en el ensayo E3

2026-11-27. Propuesta técnica para la implementación del ensayo ficticio. El perfil versionado conserva la obligación en un campo privado de autoridad independiente de la secuencia activa. El despacho en el turno siguiente confirma la ventana y la respuesta liquida la obligación junto con el cierre de la ocurrencia. La propuesta se limita a DIF-01–03. [Contrato](specs/011-competitivo-completo/efectos-diferidos-y-reacciones.md).

## DEC-054 — Esconderse ante derrota directa

2026-11-27. Aceptada para la adaptación por respuesta afirmativa del propietario al cuarto caso del cotejo. Esconderse puede impedir la derrota de un aliado en juego por Asesinar, Lanzamonedas o Vorágine aunque el efecto no gaste puntos de combate. Cada uso de Esconderse protege a un aliado. En Vorágine, el efecto sigue aplicándose a los demás aliados afectados y al Mercado. La decisión se apoya en la protección frente a derrota impresa en SRC-005. SRC-001 pp. 9–10 y 16 describe Nublar y el combate gastado, sin aclarar estas derrotas directas. [Cotejo y evidencia](specs/011-competitivo-completo/verification.md#decisión-sobre-esconderse).

## DEC-053 — Defensor ante Asesinar y Lanzamonedas

2026-11-27. Aceptada para la adaptación por respuesta del propietario al tercer caso del cotejo. Si un oponente tiene al menos un Defensor en juego, Asesinar y Lanzamonedas solo pueden elegir a sus aliados con Defensor. La protección se aplica por oponente. El propietario se apoya en la restricción de objetivos de las cartas españolas de SRC-005 (Brazo de peltre, Soldado y Mataneblinos). SRC-001 pp. 9 y 15–16 describe el ataque ordinario y DEC-039 regula el premio de M2. [Cotejo y evidencia](specs/011-competitivo-completo/verification.md#decisión-sobre-defensor).

## DEC-052 — Perforar con una sola Acción elegible

2026-11-27. Aceptada para la adaptación por respuesta del propietario al segundo caso del cotejo de mercado. Si al resolver la secundaria de Perforar solo hay una Acción del Mercado que cueste 6 o menos, el recuadro completo queda sin efecto. Se conservan los efectos ya resueltos de la primaria. La cara de SRC-005 pide dos Acciones distintas. SRC-001 p. 9 y SRC-002 «Action cards» no detallan este caso de resolución parcial. [Cotejo y evidencia](specs/011-competitivo-completo/verification.md#decisión-sobre-perforar).

## DEC-051 — Confrontación con la pila de eliminadas vacía

2026-11-27. Aceptada para la adaptación por respuesta del propietario al primer caso del cotejo de mercado. Al asignar el primer atium a Confrontación con la pila de eliminadas vacía, el recuadro primario se tramita sin copiar ninguna carta. La victoria se obtiene al asignar los tres atiums adicionales y resolver el recuadro secundario. Aplicable al competitivo, cooperativo y solitario. La decisión cubre la falta de objetivo de esta primaria y conserva el requisito de los cuatro atiums y el orden de los recuadros. SRC-001 pp. 10, 17 y 20 y SRC-002 no aclaran de forma expresa esa combinación. [Cotejo y evidencia](specs/011-competitivo-completo/verification.md#decisión-sobre-confrontación).

## DEC-050 — Identidad del inventario del mercado

- Fecha: 2026-11-24. Estado: decisión técnica de E3.1, revisada favorablemente.
- Contexto: la auditoría identifica 65 diseños por hoja, fila y posición; el orden de sus filas puede cambiar sin cambiar las cartas físicas.
- Decisión: asignar el ID de inventario desde ese localizador, conservar las nueve huellas y guardar el registro de autoría fuera de `data/`, con fidelidad, ejecución y distribución pendientes. No usar una secuencia ordinal del documento ni conectar el inventario al runtime por inferencia.
- Consecuencias: un cambio de original, localizador o cantidad exige nuevo cotejo; la huella no acredita fidelidad ni permiso. [Evidencia](specs/011-competitivo-completo/verification.md).

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

## DEC-033 — Catálogo v2 de misiones con evidencia local

2026-11-12. Diseño técnico de T08.1b9 implementado localmente en T08.1b10. Usar un documento v2 de carga explícita, con premios de casilla, extras del primero y cima permanente diferenciados. Reutilizar los originales de SRC-005 como fuentes locales con SHA-256. La ruta de arranque sigue cargando el catálogo v1 de muestra. [Contrato](specs/008-preparacion-y-turnos/catalogo-misiones.md).

## DEC-034 — Orden de premios y victoria por misiones

2026-11-12. Aceptada expresamente por el usuario durante T08.1b11: «Premio normal y después extra del primero» y «Victoria inmediata antes de los premios». Resuelve dos órdenes que SRC-001 pp.14/17 no explicita conjuntamente.

- Al alcanzar una casilla, resolver primero el premio normal (o permanente de cima) y después el extra del primero cuando corresponda.
- Al completar la tercera misión competitiva, confirmar la llegada y la victoria inmediatamente, antes de los premios de esa última cima. No concederlos ni continuar el turno. Los premios de las misiones anteriores permanecen.

Es una decisión de adaptación, no una errata atribuida al editor. El [contrato de avance](specs/008-preparacion-y-turnos/avance-misiones.md) fija consumo, estado y escenarios; T08.1b12 la implementa localmente para M5/M6/M7, con snapshot 3/motor `p08-missions-1/godot-4.7.2`, primeras llegadas y resultado persistidos sin migración implícita desde esquema 2. No cambia finales de cooperativo/solitario.

## DEC-035 — Permanentes competitivos con marcas y cierre interno

2026-11-13. Diseño técnico de T08.1b14 implementado y verificado localmente, con [revisión independiente favorable](specs/008-preparacion-y-turnos/verification.md#t081b14--implementación-de-permanentes-m3m4). El perfil aislado M3/M4/M7 comparte candidatos de misión y P07 para confirmar llegada, inicio y nueva mano. Snapshot 4/motor `p08-permanents-1/godot-4.7.2`, sin migración implícita. M3 conserva marcas privadas de adquisición/última aplicación; M4 deriva mano 5/6 de su premio liquidado. Los namespaces internos de inicio/cierre quedan vedados a la entrada pública antes de consultar recibos. No habilita entrada a limpieza, cartas generadoras de puntos, producto ni modos con rival. No modifica las decisiones humanas DEC-031/032/034; [contrato normativo](specs/008-preparacion-y-turnos/permanentes-misiones.md).

## DEC-036 — Elecciones M8 por segmentos con capacidad reservada

2026-11-13. Diseño técnico implementado y verificado localmente en T08.1b16, revisión independiente favorable; [contrato](specs/008-preparacion-y-turnos/elecciones-m8.md) y [evidencia](specs/008-preparacion-y-turnos/verification.md#t081b16--implementación-de-elecciones-y-eliminación-m8). P07 selecciona DIRECT/SEQUENCE desde autoridad congelada, con gasto/llegada automática y ventanas privadas normal/extra, cierre vacío explícito y grupos ligados a cursor. M8 declara 10.000 opciones frente a 16 por defecto y conserva límites globales; reserva capacidad para respuestas/cierre antes del gasto y al restaurar. Delta y RNG real se validan antes de publicar. Snapshot 5 sin migración implícita desde 4, perfil aislado M5/M7/M8 con fixtures restantes. No modifica las reglas humanas de DEC-034 ni habilita producto, limpieza o rival.

## DEC-037 — Refresco obligatorio de premios M1

Aplicación técnica T08.1b18, 2026-11-13: perfil aislado M1/M5/M7 y capacidad base+bonus derivada del grupo liquidado, snapshot 6 sin migración implícita desde 5. Implementada y verificada localmente, revisión independiente favorable, sin nuevas decisiones de reglas ni integración de producto. [Evidencia y estado de revisión](specs/008-preparacion-y-turnos/verification.md#t081b18--implementación-de-premios-m1).

2026-11-13. Aceptada por respuesta expresa del usuario en T08.1b17: «Refrescar obligatoriamente si hay fichas agotadas (si es una, elegir cuál; si son todas, automático)», a una consulta que incluía tanto el premio selectivo como el total. Resuelve DUD-009 para la adaptación; SRC-001/002 no aclaran inequívocamente su omisión en premios de misión. No se atribuye al editor.

- Cada premio de refrescar una ficha ordinaria agotada de M1 exige elegir una si existe alguna; no se permite omitir. Incluso una única candidata mantiene la selección. Sin candidatas se liquida automáticamente sin efecto.
- El premio de refrescar todas se aplica automáticamente y sin opción de omisión ni subconjunto. No altera `used_this_turn` ni permite reutilizar una ficha usada ese turno.
- Normal antes del extra y victoria por la tercera cima antes de sus premios conservan DEC-034. El [contrato M1](specs/008-preparacion-y-turnos/elecciones-m1.md) concreta programas, grupos, capacidad y pruebas futuras. No cambia el motor en esta entrega documental ni decide opcionalidad de otras familias de efectos.

## DEC-038 — Indicativos breves durante el trabajo

2026-11-13. Aceptada por instrucción expresa del usuario, para todo el proyecto: durante el trabajo mostrar únicamente un indicativo de actividad con título escueto; evitar narración interna, detalles técnicos, logs y actualizaciones repetitivas. Sólo preguntas imprescindibles y bloqueos que requieran intervención interrumpen ese formato; resultados relevantes y limitaciones en un cierre breve. Norma en [AGENTS](../AGENTS.md#comunicación-durante-el-trabajo). Ampliación expresa del mismo día: extenderlo a herramientas y operaciones similares, mostrando sólo archivos editados, sin diffs, líneas, código, comandos completos ni volcados; lecturas/pruebas/Git con salida mínima. Usar mecanismos sin detalle automático cuando sea posible. La evidencia y los controles SDD permanecen obligatorios. [Registro de la tarea](specs/009-sistema-agentes/tasks.md#comunicación-breve-durante-el-trabajo).

## DEC-039 — Objetivos y obligatoriedad del premio M2

Aplicación técnica T08.1b20: piloto aislado M2/M5/M7, snapshot 7 y programa `m2_first_v1`, traslado al descarte del propietario e inicio interno con +2 ataque; verificado localmente y revisado favorablemente sin hallazgos residuales. No cambia las reglas humanas ni acredita Defender/Cloud reales. [Evidencia](specs/008-preparacion-y-turnos/verification.md#t081b20--implementación-de-objetivos-y-premios-m2).

2026-11-14. Aceptada por respuesta humana «si» a la propuesta conjunta posterior a publicar el borrador M2: permitir aliados propios y rivales, exigir el premio si existe objetivo válido y liquidarlo sin efecto si no hay objetivos, respetando Defender de cada rival. Resuelve [DUD-010](referencias/dudas.md) para la adaptación. SRC-005 M2 no explicita propiedad ni omisión y SRC-001/002 no aclaran inequívocamente estos casos; no se atribuye esta resolución al editor ni se extrapola DEC-037.

- La plaza que recibe el premio elige exactamente un aliado legal en juego, propio o rival. Incluso con una única opción se mantiene selección explícita; no se admite omisión. Sin objetivos legales, liquidar automáticamente sin efecto, ventana vacía ni deuda futura.
- Aplicar Defender por propietario rival: si ese rival controla aliados con Defender, sólo sus Defender son elegibles. No protege aliados de otros rivales ni restringe al propietario que selecciona uno de sus propios aliados.
- Una derrota directa no gasta combate ni paga defensa numérica. Cloud y otras protecciones continúan dependiendo del texto verificado de cada carta; esta decisión no crea reacciones ni resuelve las cartas pendientes del producto.

Contrato y escenarios en [M2](specs/008-preparacion-y-turnos/elecciones-m2.md). El piloto futuro con aliados inertes no acredita Defender, Cloud, habilidades ni una partida de producto. Esta entrega registra reglas y plan; snapshot 6 vigente sin cambios.

## DEC-040 — Composición de misiones por definición

2026-11-14. Diseño técnico de T08.1b21/T08.1b22, implementado y verificado localmente; no cambia reglas humanas. Un servicio interno combina tres misiones distintas entre M1–M8 con catálogo inerte congelado, registro cerrado de cinco programas y fuente tipada. Grupos/ledger se validan por definición de la misión actual, capacidad M1 se suma a entrenamiento/M6 y marcas M2/M3 se aplican por recurso en inicio único. Los perfiles anteriores mantienen sus conjuntos exactos.

Snapshot 8/motor `p08-integrated-missions-1/godot-4.7.2`, sin migración desde 7. Delta y RNG se reconstruyen por acción, permitiendo azar legítimo de M4/cierre sin concederlo a otras operaciones. El cierre interno no abre limpieza pública, producto ni modos con rival. [Contrato](specs/008-preparacion-y-turnos/integracion-misiones.md) y [evidencia](specs/008-preparacion-y-turnos/verification.md#t081b22--integración-de-misiones-m1m8). DEC-031/032/034/037/039 siguen vigentes.

## Decisiones aún pendientes

- Equivalencia con edición española, terminología, catálogo completo y dudas del reglamento recibido.
- Alcance mínimo de una partida jugable.
- Compatibilidad mínima de Windows y objetivos finales de hardware/resolución; Godot 4.7.2 ya está fijado.
- Ampliación del contrato y gramática de efectos para contenido real; contrato inicial y política de carga resueltos en DEC-016.
- Implementación de reglas/efectos y adaptación del núcleo a contenido verificado; el núcleo local estructural ya existe (DEC-017) y la preparación estructural en DEC-018.
- Transporte/alojamiento, formato de invitación, pausa/reserva y pérdida de autoridad; salas privadas sin cuentas y reconexión ya están acordadas.

Registrar una nueva entrada cuando haya evidencia suficiente o un acuerdo; mientras tanto, mantener la incertidumbre explícita.

## DEC-041 — Respuestas concisas con evidencia conservada

Precisión humana del 2026-11-15: omitir comandos y salidas de Git en la comunicación visible y no exponer razonamientos antes del cierre. Capturar salidas para evidencia local; mantener las comprobaciones obligatorias. El cierre conserva resultados y justificaciones breves necesarias, sin razonamiento interno. No se garantiza ocultación de metadatos impuestos por el cliente. [Evidencia](specs/009-sistema-agentes/verification.md#salida-discreta-de-git-y-razonamientos).

2026-11-15. Aceptada por el encargo humano de contrastar AGENTS con sus pautas de estilo y dejar la opción óptima. Complementa DEC-038: español, respuestas directas sin relleno ni repeticiones y detalle técnico sólo necesario. El cierre indica cambio y verificación mínima, con bloqueos o limitaciones relevantes; se evita interpretar «únicamente qué has cambiado» como permiso para ocultarlos. Calidad, documentación, pruebas y revisión permanecen obligatorias. Norma central en [AGENTS](../AGENTS.md#comunicación-durante-el-trabajo); [evidencia](specs/009-sistema-agentes/verification.md#estilo-conciso-de-respuesta). Sin ahorro medido ni cambios de modelos/permisos.

## DEC-042 — Gramática v3 para reserva de puntos de misión

2026-11-16. Decisión técnica local de T08.1b24: conservar v1/v2 y crear v3 para `ganar mision` sólo en habilidades de acción de momentos `al_jugar` o `metal_quemado`, con objetivo propio. La forma representa una reserva de turno y no el avance de un recorrido. Las acciones v3 declaradas verificadas requieren fuente física local con huella, además de revisión. No cambia reglas humanas ni activa efectos. [Contrato](specs/008-preparacion-y-turnos/catalogo-puntos-mision.md) y [evidencia](specs/008-preparacion-y-turnos/verification.md#t081b24--gramática-de-puntos-de-misión).

## DEC-043 — Vínculos de metal v4 y piloto aislado de Perseguir

2026-11-19. Decisión técnica local de T08.1b27, verificada en perfil aislado: v4 distingue metal asignado a una primaria de uso de la propia instancia como metal. El validador admite las formas sólo para Acción y su momento correspondiente; la autoridad del perfil cerrado valida instancia, fuente, efecto y recibo antes de aplicar recursos. El `burned` de una ficha registra su metal físico: Atium sigue siendo Atium aunque sustituya bronce; una carta combustible no consume cupo de fichas. La quema ordinaria marca uso del turno sin agotar la ficha. [Gramática](specs/008-preparacion-y-turnos/catalogo-vinculos-metal.md) y [evidencia](specs/008-preparacion-y-turnos/verification.md#t081b27--gramática-y-perfil-aislado-de-perseguir). No es decisión humana nueva ni habilita el catálogo de arranque, la distribución del escaneo u otros efectos.

## DEC-044 — Fuentes físicas fuera de Git y paquetes

2026-11-19. Decisión técnica local aceptada tras revisión independiente en T08.1b28. Los escaneos de SRC-005 se conservan para cotejo local por SHA, fuera de Git y de los paquetes para jugadores. La autoría validará originales y revisión humana; una construcción futura emitirá un catálogo de ejecución versionado y fijado por la autoridad, sin PNG y sin aceptar autodeclaraciones del cliente. El manifiesto no acredita la integridad de un anfitrión modificado; alojamiento/confianza siguen pendientes en P13–P14. El validador v4 actual conserva sus exigencias; ningún JSON se promueve ni se distribuye por esta decisión documental. Arte y texto finales tendrán revisión de procedencia separada. [Contrato](specs/008-preparacion-y-turnos/fuentes-sin-escaneos.md) y [evidencia](specs/008-preparacion-y-turnos/verification.md#t081b28--fuentes-físicas-fuera-de-la-distribución). No se atribuye esta elección al usuario ni se afirma una licencia editorial.

Aplicación técnica T08.1b29 (2026-11-21): ensayo aislado construido y cargado con manifiesto que fija además el SHA-256 de los bytes del archivo antes de analizar JSON. Clon y PCK probados sin los tres PNG; no se ha decidido distribución de texto/arte ni admisión al producto. [Evidencia](specs/008-preparacion-y-turnos/verification.md#t081b29--catálogo-de-ejecución-sin-png).

## DEC-045 — Puerta separada del catálogo final

2026-11-23. Decisión técnica de T08.1b30: el contenido final requiere evidencias independientes de fidelidad al componente, ejecución completa en el perfil y distribución del material incluido, además de un manifiesto cerrado sin fixtures. Una aprobación en una dimensión no sustituye las otras. No atribuye permiso editorial ni cambia el ensayo b29. [Contrato](specs/008-preparacion-y-turnos/admision-contenido-final.md) y [evidencia](specs/008-preparacion-y-turnos/verification.md#t081b30--procedencia-y-admisión-del-contenido-final).

## DEC-046 — Entregas agrupadas orientadas a partidas completas

2026-11-23. Estado: aceptada por el encargo humano de unificar pasos sin perder calidad y terminar el proyecto con menos fragmentación. La ruta E1–E6 agrupa contenido y comportamiento relacionado hasta un resultado comprobable; dentro de cada entrega se mantienen fuentes, aceptación previa, pruebas pertinentes, revisión independiente por riesgo y correcciones. Sustituye los antiguos nombres E0–E6; P00–P18 conservan su alcance y criterios de cierre. Una dependencia externa puede dejar una entrada abierta sin detener trabajo independiente. No se dispensan controles ni se presumen permisos de distribución. [Plan](plan-de-trabajo.md#ruta-de-entregas-agrupadas-2026-11-23).

## DEC-047 — Gramática v5 y variante de ensayo del contenido inicial

2026-11-24. Estado: decisión técnica local de E1, revisión independiente favorable. La gramática v5 admite puntos de misión propios en Training/personaje con momentos acotados y Atium en la condición de personaje, sin cambiar v1–v4 ni ejecutar texto. El JSON de 22 componentes físicos permanece en borrador. Para probar el inicio, una variante solo en memoria omite nivel II y las casillas pendientes de pista; `TrainingAdvance.PANEL` resuelve las marcas, con mercado y misiones ficticios y checkpoints declarados. Su identidad no equivale a admisión de producto ni a permiso de distribución. Nivel II y compra requieren E2. [Contrato](specs/008-preparacion-y-turnos/contenido-inicial-competitivo.md) y [evidencia](specs/008-preparacion-y-turnos/verification.md#e1--contenido-inicial-competitivo-y-ensayo-integrado).

## DEC-048 — Perfil cerrado para la primera partida local

2026-11-24. Estado: decisión técnica E2 revisada favorablemente, solo de ensayo. Un perfil propio, sin relajar guardas de E1/P07, une las cartas iniciales provisionales, cuatro Acciones ficticias y M5/M6/M7 seleccionadas por semilla de `GameSetup`. Autoridad fija contenido, RNG, vistas privadas y registro para replay; la pantalla envía intenciones y tapa manos al pasar el equipo. Comprar/canjear Boxings y el último superviviente se implementan dentro de este perfil. Se rechaza compra sin mercado ni eliminadas cuando ambos se agotan, sin inventar reposición. Ningún fixture acredita fidelidad/distribución ni cambia la prioridad de E3–E6. [Contrato](specs/010-primera-partida-local/spec.md) y [evidencia](specs/010-primera-partida-local/verification.md).

## DEC-049 — Commit y push al terminar satisfactoriamente

2026-11-24. Estado: instrucción humana permanente para este repositorio. El coordinador hace commit y push de cada entrega de desarrollo satisfactoriamente completada, incluida una entrega documental, después de aceptación, pruebas, revisión aplicable y cierre; verifica la referencia remota. No se vuelve a pedir permiso en cada tarea. Una entrega abierta, fallida o bloqueada no se publica automáticamente; una orden expresa puede autorizar trabajo parcial, como E1 en el presente paquete. No se fuerza un push ni se incluyen secretos, escaneos locales, artefactos ignorados o cambios ajenos. Esta decisión no autoriza PR, issues, despliegue ni distribución por otras vías y no modifica controles de calidad. [Regla](../AGENTS.md#cierre-de-cada-tarea) y [política](gestion/agentes-sdd.md#publicación-al-cierre-satisfactorio).
