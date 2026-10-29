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

## Decisiones aún pendientes

- Equivalencia con edición española, terminología, catálogo completo y dudas del reglamento recibido.
- Alcance mínimo de una partida jugable.
- Compatibilidad mínima de Windows y objetivos finales de hardware/resolución; Godot 4.7.2 ya está fijado.
- Ampliación del contrato y gramática de efectos para contenido real; contrato inicial y política de carga resueltos en DEC-016.
- Implementación de reglas/efectos y adaptación del núcleo a contenido verificado; el núcleo local estructural ya existe (DEC-017) y la preparación estructural en DEC-018.
- Transporte/alojamiento, formato de invitación, pausa/reserva y pérdida de autoridad; salas privadas sin cuentas y reconexión ya están acordadas.

Registrar una nueva entrada cuando haya evidencia suficiente o un acuerdo; mientras tanto, mantener la incertidumbre explícita.
