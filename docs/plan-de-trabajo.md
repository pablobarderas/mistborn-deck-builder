# Plan de trabajo por fases

## Ruta de entregas agrupadas (2026-11-23)

El [ensayo de finalización](specs/011-competitivo-completo/verification.md#ensayo-de-finalización) completa FIN-01–03. El siguiente paso propuesto de E3 es precisar qué efectos del primer lote de integración quedan cubiertos por operaciones verificadas, qué excepciones requieren contrato y cómo se comprobará cada ruta.

Confirmación M1–M8 (2026-11-24): [ocho misiones cotejadas por el propietario](referencias/misiones-competitivas.md), con casillas, extras del primero y cimas. El cotejo documental del mercado se completó después en E3.2. La admisión de producto requiere además ejecución completa y permisos de distribución por material. [Evidencia](specs/008-preparacion-y-turnos/verification.md#confirmación-humana-de-misiones-m1m8--registro-previo).

Confirmación E1 (2026-11-24): cotejo humano del lote inicial completado; E1 cierra en alcance de ensayo, con datos aún en borrador y admisión/distribución pendientes. Las ocho misiones se confirmaron después, por separado. [Evidencia](specs/008-preparacion-y-turnos/verification.md#cotejo-humano-e1-y-consulta-de-misiones--registro-previo).

E3.1 (2026-11-24): [inventario del mercado](specs/011-competitivo-completo/tasks.md) completado y revisado, 65 diseños/82 copias. E3.2 (2026-11-27): [cotejo documental completado y revisado](specs/011-competitivo-completo/verification.md#copia-identificada-para-e32). Las secuencias ficticias verifican el intercambio de recursos, el traslado de mano a descarte, la [selección privada reanudable](specs/011-competitivo-completo/verification.md#selección-privada-verificada-en-el-motor) y las [alternativas y efectos encadenados](specs/011-competitivo-completo/verification.md#alternativas-y-efectos-encadenados-verificados). El [ensayo de efectos diferidos y reacciones](specs/011-competitivo-completo/verification.md#ensayo-de-efectos-diferidos-y-reacciones-verificado) verifica la obligación entre turnos y la ventana privada.

Avance anterior E1 (2026-11-24): registro de 22 borradores y ensayo de inicio/acciones iniciales verificados con fuentes locales; revisión independiente favorable y [evidencia](specs/008-preparacion-y-turnos/verification.md#e1--contenido-inicial-competitivo-y-ensayo-integrado). El cotejo humano pendiente entonces se confirmó después, según la nota superior; E2 usa un subconjunto de prueba sin atribuirle admisión al producto.

E2 (2026-11-24): primera partida local de ensayo completada con mercado ficticio, M5/M6/M7 y E1 solo en memoria; [verificación](specs/010-primera-partida-local/verification.md) y revisión independiente favorables. Siguiente entrega funcional E3, competitivo local completo; el cotejo humano E1 se confirmó después y no se infiere admisión del contenido.

Publicación de entregas: [AC-11/DEC-049](specs/009-sistema-agentes/tasks.md#ac-11--publicación-automática-al-completar-un-desarrollo) autoriza commit/push tras cierre satisfactorio; el trabajo parcial E1 de este paquete tiene autorización expresa. No altera las puertas de E3 ni la prioridad de sus fuentes.

La prioridad es llegar a partidas terminadas. P00–P18 siguen siendo criterios de cobertura y cierre, pero la unidad de entrega será un resultado jugable o un lote de contenido completo: especificación necesaria, implementación, pruebas, revisión y correcciones relacionadas en el mismo objetivo. No abrir una entrega independiente solo para redactar el contrato de una regla cuya fuente y comportamiento ya permiten implementarla. Conservar el registro previo y la revisión independiente exigidos por riesgo; ejecutar suites afectadas, no todas por rutina. [T00.2](specs/009-sistema-agentes/tasks.md#t002--entregas-agrupadas-hacia-una-partida-jugable).

| Entrega | Resultado comprobable | Entrada y límite |
| --- | --- | --- |
| E1 — contenido inicial competitivo | Registro y cotejo de cuatro personajes, 16 entrenamientos, Financiación y pista; definiciones y resolutores conectados en un ensayo de inicio/turno, con pruebas de fuentes, efectos y rechazos. | Usar SRC-001/002/004/005 locales; conservar estado de distribución separado. Si falta una cara o una duda altera el resultado, avanzar con las otras entradas y dejar la afectada abierta. |
| E2 — primera partida competitiva local | Preparación, compra, juego, combate, Target, misiones, limpieza y final en una interfaz funcional; partida terminada con subconjunto de contenido declarado. | El subconjunto es un ensayo jugable, no el catálogo completo ni una versión distribuible. Conectar reglas y pantalla antes de completar las 65 cartas. |
| E3 — competitivo completo local | Mercado de 65 diseños/82 copias y todas sus rutas y finales; partidas terminadas con 2, 3 y 4 plazas. | Agrupar por familias de efecto dentro de la entrega; el candidato de producto exige las tres puertas de T08.1b30, sin fixtures. |
| E4 — competitivo remoto recuperable | Salas privadas, autoridad única, vistas privadas, sincronización y reconexión de la misma plaza; partidas competitivas completas entre equipos/redes. | Resolver P04 externa y política de caída/abandono; probar duplicados, cortes y apropiación de plaza. P14/P16 aún no cierran sin los otros modos. |
| E5 — Lord Legislador y modos restantes | Rival, 36 cartas, escudos, Dominación y decisiones colectivas; escenarios terminados en solitario y cooperativo 2–4, también entre equipos para cooperativo. | Mantener diferencias de modo, victoria/derrota y pruebas propias. Se aborda después del competitivo según DEC-027 y no se elimina del alcance. |
| E6 — versión para el grupo | Interfaz y acabado revisados en partidas reales, siete configuraciones probadas y exportación limpia con instrucciones. | Verificar distribución de material y una copia ejecutada por otra persona; corregir defectos que impidan jugar o alteren reglas. |

E3 es el siguiente objetivo funcional. E1 y las misiones tienen cotejo humano, y el mercado tiene cotejo documental E3.2. Las entregas E3–E6 son hitos, no promesas de una sola sesión ni porcentajes de avance. Los lotes internos se abren solo cuando una dependencia o una revisión lo requiera, con aceptación observable y sin repetir documentación histórica. [Inventario y lagunas vigentes](specs/008-preparacion-y-turnos/inventario-competitivo-final.md).

Precisión de salida discreta (2026-11-15): completada con comprobación documental y revisión independiente favorables; siguiente objetivo del juego conservado. [Tarea](specs/009-sistema-agentes/tasks.md#salida-discreta-de-git-y-razonamientos).

Estilo conciso (2026-11-15): ajuste documental completado; revisión independiente favorable y comprobación documental correcta. [Tarea/evidencia](specs/009-sistema-agentes/tasks.md#estilo-conciso-de-respuesta). El siguiente objetivo del juego se conserva.

Última revisión: 2026-11-24. P00, el inventario inicial de P01, P03, la maqueta de P05 y el contrato inicial de P06 están completados en su alcance. P04 mantiene pendiente la prueba externa. E2 acredita turnos y partidas locales solo con fixture; contenido competitivo completo, modos restantes y remoto siguen pendientes.

## Objetivo y situación

Crear una aplicación para Windows en español, visualmente cuidada y fiel al juego de mesa, con competitivo 2–4, cooperativo 2–4 y cooperativo en solitario. Máximo cuatro personas. Ya existe una pantalla inicial ejecutable que carga y muestra las dos cartas de prueba.

Acceso confirmado: salas privadas sin cuentas y capacidad de reconectarse a la misma plaza/partida. Pausa, reserva de plaza y pérdida del anfitrión se concretarán en P15; no se presuponen acordadas.

SRC-001 ya está identificado y leído: reglamento inglés de 2024, 1.ª edición/1.ª impresión. El usuario tiene la caja española; falta contrastar localización y completar cartas/pistas. Windows es la plataforma inicial confirmada; la maqueta 2D de P05 se acepta como dirección visual inicial.

## Cómo avanzar

- T08.1b31: [inventario del competitivo completo](specs/008-preparacion-y-turnos/inventario-competitivo-final.md) con recuentos, fuentes y lagunas por componente. Siguiente: registro y cotejo individual del mazo inicial, personajes y pista; sin candidato de producto. [Evidencia](specs/008-preparacion-y-turnos/verification.md#t081b31--inventario-del-competitivo-completo).

- T08.1b30: [contrato de procedencia/admisión](specs/008-preparacion-y-turnos/admision-contenido-final.md) para contenido final, sin cambiar el ensayo ni atribuir permisos de distribución. Siguiente ejecución: inventario del perfil competitivo completo por componente y sus lagunas de fuente, resolutor y distribución. [Evidencia](specs/008-preparacion-y-turnos/verification.md#t081b30--procedencia-y-admisión-del-contenido-final).

- T08.1b29: [catálogo de ejecución sin PNG](specs/008-preparacion-y-turnos/catalogo-ejecucion-sin-png.md) implementado en ensayo aislado, con builder/cargador separados, clon limpio y PCK inspeccionado; revisión independiente favorable. No promueve Perseguir ni instala producto. Siguiente: contratar procedencia/admisión del catálogo final con componentes no ficticios y permiso de distribución de texto/arte antes de integrarlo. [Evidencia](specs/008-preparacion-y-turnos/verification.md#t081b29--catálogo-de-ejecución-sin-png).

- T08.1b28: [política de originales fuera de Git y paquetes](specs/008-preparacion-y-turnos/fuentes-sin-escaneos.md), contrato documental completado y revisado favorablemente. Siguiente implementación T08.1b29: catálogo de ejecución sin PNG, fijado por autoridad y probado en clon limpio/exportación. No promueve Perseguir ni acredita permiso para distribuir arte/texto. [Evidencia](specs/008-preparacion-y-turnos/verification.md#t081b28--fuentes-físicas-fuera-de-la-distribución).

- T08.1b27: [gramática v4 y perfil aislado de Perseguir](specs/008-preparacion-y-turnos/catalogo-vinculos-metal.md) completados localmente, con 393 pruebas dirigidas, 5932 de integración M1–M8, regresiones pertinentes y revisión independiente favorable. Mantiene la carta real en borrador; ensayos con copia verificada en memoria y fuente local por huella. Siguiente objetivo: resolver distribución del original antes de cualquier promoción y contratar receptora activa si se amplía Savant. [Evidencia](specs/008-preparacion-y-turnos/verification.md#t081b27--gramática-y-perfil-aislado-de-perseguir).

- T08.1b26: [contrato de activación de Perseguir](specs/008-preparacion-y-turnos/activacion-perseguir.md) completado documentalmente y revisado: primaria/Savant, omisiones, asignación de metal, autoridad y rollback. Siguiente paso: implementación separada de gramática y perfil aislado con pruebas; la carta sigue en borrador y no es jugable. [Traspaso](specs/008-preparacion-y-turnos/verification.md#t081b26--contrato-de-activación-de-perseguir).

- T08.1b25: fuente local reproducible y definición v3 de Perseguir en borrador, aislada del arranque y del motor. Siguiente objetivo: contrato de activación primaria/Savant y autoridad, antes de promover la carta. [Evidencia](specs/008-preparacion-y-turnos/verification.md#t081b25--fuente-y-borrador-de-perseguir).

- T08.1b24: [gramática v3 de puntos de misión](specs/008-preparacion-y-turnos/catalogo-puntos-mision.md) completada y revisada; publicación autorizada el 2026-11-16 en el commit que contiene esta nota, sin activar efectos. Siguiente objetivo: preparar fuente física reproducible y definición completa de Perseguir; después contratar activación primaria/Savant y autoridad. [Evidencia](specs/008-preparacion-y-turnos/verification.md#t081b24--gramática-de-puntos-de-misión).

- T08.1b23 completada documentalmente y revisada: [Perseguir](specs/008-preparacion-y-turnos/carta-perseguir.md), primera candidata real para generar puntos de misión. Siguiente paso: preparar fuente versionada y ampliación de catálogo; luego especificar activación de acción/Savant y autoridad. Sin implementación de carta ni cambio del estado jugable.

- Publicación T08.1b22 autorizada el 2026-11-14 y recogida en el commit de esta nota, con 18 suites/17.644 comprobaciones y revisión independiente favorables. Las menciones inferiores sin publicación son antecedentes. Siguiente propuesto: contrastar una carta real generadora de puntos de misión y especificar su integración; no iniciado. [Evidencia](specs/008-preparacion-y-turnos/verification.md#t081b22--integración-de-misiones-m1m8).

- T08.1b22 implementada y verificada localmente: servicio aislado de tres misiones distintas cualesquiera entre M1–M8, competitivo 2–4, snapshot 8/motor `p08-integrated-missions-1/godot-4.7.2`; **18 suites/17.644 comprobaciones**. Revisión independiente final favorable sin hallazgos residuales; cierre local completo. Sin producto, cartas activas, limpieza pública, UI/red ni rival. [Evidencia](specs/008-preparacion-y-turnos/verification.md#t081b22--integración-de-misiones-m1m8). Siguiente objetivo propuesto: contrastar una carta real generadora de puntos de misión y especificar su integración con el servicio combinado antes de automatizarla; su fuente/catálogo deben verificarse, sin admitir cartas activas por inferencia.

- T08.1b21 completada documentalmente y revisada favorablemente: [integración M1–M8](specs/008-preparacion-y-turnos/integracion-misiones.md). Tras revisión/enlaces/diff, publicar contrato antes de T08.1b22 según encargo humano; b22 implementará INT-01–08 sin producto ni cierre P08. [Traspaso](specs/008-preparacion-y-turnos/verification.md#t081b21--contrato-de-integración-de-misiones).

- T08.1b20. Implementación M2 verificada localmente: perfil aislado M2/M5/M7, snapshot 7/motor `p08-m2-defeat-1/godot-4.7.2`; **17 suites/11.712 comprobaciones**. Revisión independiente favorable sin hallazgos residuales. Sin Defender/Cloud reales, limpieza ni producto. [Evidencia vigente](specs/008-preparacion-y-turnos/verification.md#t081b20--implementación-de-objetivos-y-premios-m2). Siguiente objetivo propuesto: contrato de integración de misiones, selección de tres entre M1–M8 y composición de sus permanentes/inicio/carga, manteniendo el subconjunto de aliados inertes. No se inicia esa integración en esta entrega.

- T08.1b19 completada documentalmente y revisada favorablemente: [contrato M2](specs/008-preparacion-y-turnos/elecciones-m2.md), DEC-039 aceptada y DUD-010 resuelta. Selección, programa y permanente concretados para piloto M2/M5/M7; siguiente implementación propuesta T08.1b20, aún sin iniciar. [Traspaso vigente](specs/008-preparacion-y-turnos/verification.md#t081b19--contrato-de-objetivos-y-premios-m2). Borrador M2 publicado en `9edcd7c`; resolución y cierre nuevos sólo locales. Las notas inferiores de decisiones pendientes son antecedentes; M2-DOC-01–04 y enlaces/diff satisfechos; siguiente objetivo propuesto T08.1b20, sin implementar en esta entrega.

- Comunicación de todo el proyecto: indicativos de actividad con título escueto durante el trabajo, según [AGENTS](../AGENTS.md#comunicación-durante-el-trabajo) y DEC-038; [tarea de la instrucción](specs/009-sistema-agentes/tasks.md#comunicación-breve-durante-el-trabajo). El siguiente objetivo del juego se conserva.

- T08.1b18 completada localmente: [contrato M1-01–08](specs/008-preparacion-y-turnos/elecciones-m1.md), perfil M1/M5/M7 y snapshot 6; dieciséis suites/10.475 comprobaciones y revisión independiente favorables. Siguiente objetivo propuesto: especificar M2 (selección/derrota de Aliado y permanente) antes de implementarla. [Traspaso vigente](specs/008-preparacion-y-turnos/verification.md#t081b18--implementación-de-premios-m1). Sin publicación; las notas inferiores conservan antecedentes.

- T08.1b17 completada documentalmente y revisada favorablemente: [contrato M1 y plan T08.1b18](specs/008-preparacion-y-turnos/elecciones-m1.md). DEC-037 fija refresco obligatorio; siguiente propuesto T08.1b18, implementación del perfil M1/M5/M7; snapshot 5 sin cambios. [Traspaso vigente](specs/008-preparacion-y-turnos/verification.md#t081b17--contrato-de-selección-y-premios-m1). T08.1b15/16 ya publicadas en `3be2a8d`; las notas inferiores sin publicación conservan antecedentes.

- Traspaso vigente 2026-11-13: T08.1b16 implementada y verificada, revisión independiente favorable; perfil aislado M5/M7/M8, snapshot 5 y 15 suites/8.418 comprobaciones. [Evidencia M8](specs/008-preparacion-y-turnos/verification.md#t081b16--implementación-de-elecciones-y-eliminación-m8). Siguiente propuesto T08.1b17: contrato de selección de fichas agotadas y premios M1. Sin publicación, producto ni entrada a limpieza; el punto de reanudación inferior conserva los antecedentes.

- T08.1b4 integra el [inicio único competitivo](specs/008-preparacion-y-turnos/verification.md#t081b4--implementación-del-inicio-competitivo) en un perfil aislado. El primer paso para integrarlo al producto es contrastar el material disponible y delimitar las definiciones y misiones del manifiesto competitivo.

- La [lectura de las cinco piezas de entrenamiento](referencias/entrenamiento-competitivo.md) sustenta las recompensas de la pista competitiva. Siguen pendientes la activación de habilidades, el catálogo ejecutable y la transición a fase libre.

- Aplicar [AC-10, trabajo contenido](gestion/agentes-sdd.md#protocolo-operativo-de-trabajo-contenido--ac-10): lecturas/salidas acotadas, equipo mínimo necesario y evidencia centralizada; mantienen recuperación remota, pruebas y revisión. Mejora documental completada y revisada; no cambia las dependencias del juego.

- T08.2h completada localmente, revisión independiente favorable y 3.778 comprobaciones: [evidencia Funding](specs/008-preparacion-y-turnos/verification.md#t082h--implementación-de-funding). El siguiente objetivo será revisar e incorporar el material de entrenamiento/panel competitivo para desbloquear T08.1b; verificar disponibilidad real de originales, sin asumir que el inventario es contenido ejecutable. No abrir libre con fixtures en producto. Combate/Target y rival siguen pendientes.

- Antecedente publicado 2026-11-11: T08.2g especificó [Funding como primer resolutor competitivo](specs/008-preparacion-y-turnos/primer-resolutor-competitivo.md), con elección aplicar/omitir y perfil cerrado. Contrato documental completado con revisión independiente favorable; T08.2h ya implementa y verifica FUND-01–08 con contenido de prueba explícito. No abre `libre` ni combate/limpieza; incorporación del catálogo español sigue separada y pendiente. [Evidencia documental histórica](specs/008-preparacion-y-turnos/verification.md#t082g--contrato-del-primer-resolutor-competitivo).

- Captura actualizada 2026-11-09 tras revisar el lote: [65/65 diseños de mercado](referencias/auditoria-escaneos-2026-11-09.md), cobertura completa tras revisar Tirón de hierro; siguiente trabajo de material: recortar y revisar datos para su incorporación. Entrenamientos y panel ya recibidos, pendientes de revisión detallada e incorporación. Este es el siguiente paso de material; T08.2f del motor ya está verificada localmente.

- Prioridad humana 2026-11-09: competitivo entre Nacidos de la Bruma primero; la parte del Lord Legislador se abordará al final. [DEC-027](decisiones.md#dec-027--competitivo-primero-lord-legislador-al-final) conserva cooperativo/solitario y sus puertas de cierre pendientes. En digitalización, revisar entrenamiento y paneles del competitivo ya recibidos; en motor, T08.2f está completada localmente; sigue concretar el primer resolutor real competitivo con fuentes y contenido verificado.

- Mantener un objetivo verificable por sesión principal, con ciclo SDD completo y cierre/traspaso persistente antes de cambiar a otro objetivo; [política de sesiones](gestion/agentes-sdd.md#sesiones-y-traspaso). Una interrupción puede retomarse en el mismo chat; no crea permisos de publicación ni garantiza ahorro.
- Cerrar cada fase con evidencia de su criterio de salida, no solo con código escrito.
- Las dependencias condicionan el cierre. Se pueden investigar tareas independientes antes sin convertir propuestas en decisiones.
- P04 y P05 pueden avanzar por separado tras P03. P11, P12 y P13 pueden avanzar por separado tras P10, respetando sus dependencias.
- Mantener una tarea de implementación activa por defecto y dividir tareas con varios comportamientos independientes.
- Aplicar obligatoriamente el [sistema de agentes SDD](gestion/agentes-sdd.md): delegación/modelos según riesgo, revisión independiente y como máximo dos subagentes concurrentes; un propietario por archivo. Solo una dispensa humana explícita y registrada permite omitir requisitos; falta de herramientas no exime del control ni de mantener pendiente el cierre afectado. Mejora transversal T00.1/SPEC-009, sin añadir una fase al juego.
- Las reglas no confirmadas bloquean solo las tareas que dependan de ellas.
- El núcleo de P02 ya permite preparar P03: no se necesita completar el catálogo ni decidir toda la red para crear el proyecto ejecutable. La especificación general puede seguir parcial mientras se cierran detalles en sus fases.
- Revisar los prototipos antes de reutilizarlos en el producto.
- Estimar la fase siguiente cuando estén claras sus entradas; no fijar fechas globales sin conocer reglamento, catálogo y conectividad.

## Vista general

| Fase | Resultado | Depende de | Estado |
| --- | --- | --- | --- |
| P00 | Organización y memoria | — | Cerrada en documentación |
| P01 | Reglamento y referencias | P00 | Inventario inicial completado; dudas registradas |
| P02 | Alcance y plataformas | P01 | Núcleo funcional acordado; detalles pendientes |
| P03 | Proyecto Godot ejecutable | P02 | Completada y verificada |
| P04 | Prueba temprana de conexión | P03 | Prototipo local verificado; prueba externa pendiente |
| P05 | Dirección visual y maqueta | P02, P03 | Completada como maqueta y dirección visual inicial |
| P06 | Contrato del catálogo y carga | P01, P03 | Completada: contrato inicial, migración y validación |
| P07 | Estado y acciones de partida | P02, P04, P06 | T07.1/2 verificadas localmente; cierre pendiente de P04 externa |
| P08 | Preparación y turnos | P01, P07 | T08.1a verificada localmente; turnos y catálogo real pendientes |
| P09 | Efectos y elecciones | P08 | Pendiente |
| P10 | Primera partida local completa | P05, P09 | Pendiente |
| P11 | Cobertura del contenido acordado | P10 | Pendiente |
| P12 | Interfaz completa de partida | P05, P10 | Pendiente |
| P13 | Salas y participantes | P04, P10 | Pendiente |
| P14 | Partida remota sincronizada | P11, P12, P13 | Pendiente |
| P15 | Desconexiones y recuperación | P14 | Pendiente |
| P16 | Pruebas con amigos a distancia | P15 | Pendiente |
| P17 | Acabado visual, audio y usabilidad | P11, P12, P16 | Pendiente |
| P18 | Entrega estable para el grupo | P17 | Pendiente |

## Entregas revisables

La lista E0–E6 anterior quedó sustituida por la [ruta E1–E6](#ruta-de-entregas-agrupadas-2026-11-23). P00–P18 mantienen sus criterios de salida. La entrega final incluye los tres modos y siete configuraciones: competitivo 2/3/4, cooperativo 2/3/4 y solitario 1. El rival se ejecuta por reglas y mazo, sin requerir un jugador adicional ni una IA estratégica.

## Detalle de fases

### P00 — Organización y memoria

**Objetivo:** Trabajar con fases, tareas y contexto recuperable.

**Trabajo:**

- Mantener AGENTS.md, índice, estado y decisiones.
- Preparar SDD ligero, backlog y plantillas de GitHub.

**Cierre:** Documentos y enlaces comprobados, plantillas incluidas en `.github/`; verificar la publicación comparando `HEAD` con `origin/main`.

### P01 — Reglamento y referencias

**Objetivo:** Identificar la fuente del usuario, su idioma y edición, y convertir las reglas disponibles en referencias trazables.

**Trabajo:**

- Identificar portada, editorial, edición y versión del reglamento.
- Inventariar reglas, componentes, cartas y dudas; asignar SRC y REG cuando exista evidencia.

**Cierre:** Cada regla relevante tiene fuente y página/sección, o una duda explícita; no se usan cartas ficticias como referencia.

**Evidencia:** SRC-001 leído en sus 20 páginas y SRC-002 consultada; REG-001 a REG-075, componentes y DUD-001 a DUD-007 con sus estados. El inventario no acredita fidelidad ni interpretación completa. Consultar las erratas antes de implementar.

### P02 — Alcance y plataformas

**Objetivo:** Definir exactamente qué incluirá la primera entrega para amigos.

**Trabajo:**

- Registrar acuerdos ya confirmados: aplicación Windows, competitivo 2–4, cooperativo 2–4 y solitario 1. Concretar compatibilidad y resoluciones durante P03/P05.
- Registrar salas privadas, ausencia de cuentas y reconexión como requisitos obligatorios. Concretar la política detallada al preparar P15.
- Delimitar catálogo, acceso a salas, desconexiones y objetivos visuales; resolver preguntas Q-001 a Q-006.

**Cierre:** Se registra una ficha de alcance acordada con inclusiones y exclusiones, catálogo, acceso y desconexión. Windows y los modos ya están confirmados.

### P03 — Proyecto Godot ejecutable

**Objetivo:** Poder abrir, ejecutar y comprobar el proyecto desde una copia limpia.

**Trabajo:**

- Fijar versión de Godot 4, crear project.godot y escena de inicio.
- Definir comandos reales de arranque y comprobación; integrar el cargador sin cambiar aún las reglas.

**Cierre:** El arranque funciona en el entorno elegido y los pasos se han reproducido; no basta con crear archivos.

**Evidencia:** Godot 4.7.2 fijado, Database como Autoload, pantalla en español y 58 comprobaciones superadas en copia sin caché. Captura real 1280×800 revisada. Ver [SPEC-003](specs/003-arranque-godot/verification.md) y [comandos](desarrollo-local.md).

### P04 — Prueba temprana de conexión

**Objetivo:** Reducir el riesgo de acceso remoto antes de construir el juego completo.

**Trabajo:**

- Probar dos clientes con mensajes de prueba y una autoridad identificada.
- Probar la vía de acceso desde dos redes distintas; comparar anfitrión y servicio si hace falta, con requisitos y costes.

**Cierre:** Existe evidencia de comunicación externa y una decisión de transporte/alojamiento; una prueba solo en localhost no cierra esta fase.

**Avance 2026-10-27:** T04.1 completada en [SPEC-004](specs/004-conexion-temprana/spec.md): anfitrión/ENet, tres procesos cliente y contador, errores/duplicados/límite. T04.2 parcial: guía y comparación preparadas, falta ensayo entre redes. El usuario solo dispone de un PC; P05 puede avanzar por separado.

### P05 — Dirección visual y maqueta

**Objetivo:** Decidir pronto cómo se verá y usará el juego.

**Trabajo:**

- Preparar una pantalla representativa con tablero, mano, carta ampliada y recursos de muestra.
- Definir tipografías, colores, estados de interacción y resoluciones objetivo; revisar con el usuario.

**Cierre:** La propuesta visual ha sido revisada y hay capturas y criterios de legibilidad; los datos de muestra están identificados como tales.

**Cierre 2026-10-27:** [SPEC-005](specs/005-maqueta-tablero/spec.md) y [dirección visual](diseno-visual.md). T05.1/2 completadas como maqueta: seis capturas en tres resoluciones, 39 comprobaciones y confirmación del usuario de que las cartas se ven bien. Aceptada como base visual; no acredita contenido ni arte definitivo.

### P06 — Contrato del catálogo y carga

**Objetivo:** Cargar contenido fiable y diagnosticable.

**Trabajo:**

- Definir campos y efectos estructurados a partir del reglamento, separando definiciones e instancias.
- Validar tipos, IDs, referencias y recursos ausentes; decidir carga ante errores y migrar ejemplos.

**Cierre:** Los casos válidos e inválidos tienen resultados comprobados; el catálogo indica procedencia y los ejemplos no se confunden con cartas oficiales.

**Cierre 2026-10-27:** [SPEC-006](specs/006-contrato-catalogo/spec.md), contrato v1 y flujo Android por lotes. 220 comprobaciones de contrato, 58 de arranque y 39 de maqueta. Dos muestras, cero cartas oficiales verificadas. La gramática inicial admite pendientes y se ampliará con contenido real; no se ha implementado el motor.

### P07 — Estado y acciones de partida

**Objetivo:** Construir una base de reglas independiente de escenas y red.

**Trabajo:**

- Modelar jugadores, zonas, instancias, recursos, aleatoriedad y acciones identificables.
- Definir validación y cambios atómicos, versión de estado y proyección visible para cada jugador.
- Incluir modo, rival, Dominación, escudos y secuencias pausables para elecciones/reacciones; compartir motor entre solitario y red.

**Cierre:** Una secuencia reproducible conserva invariantes y rechaza acciones inválidas sin alterar el estado; la información privada tiene propietario.

**Avance 2026-10-29:** T07.1/2 implementadas/verificadas localmente en [SPEC-007](specs/007-estado-y-acciones/verification.md): 1.725 comprobaciones originales de estado (1.741 tras ampliar el esquema en P08) y 102 del motor. Acciones estructurales con manejadores ficticios; la fase no cierra mientras P04 externa siga pendiente. P08 añade preparación estructural, sin reglas ejecutables de cartas.

### P08 — Preparación y turnos

**Objetivo:** Reproducir el inicio y la secuencia del juego confirmado.

**Trabajo:**

- Implementar preparación, reparto, orden de jugadores y fases del turno según REG.
- Cubrir transiciones, límites y los casos de mazo/descartes que existan en el reglamento.
- Implementar diferencias por modo: bonificaciones competitivas, Target y preparación del rival sin bonificaciones en solo/cooperativo (T08.3).

**Avance 2026-10-30:** [SPEC-008](specs/008-preparacion-y-turnos/spec.md) divide la fase. T08.1a implementa preparación estructural y diferencias iniciales por modo, verificada con 147 comprobaciones; se rechaza un manifiesto incompleto/no verificado. T08.2a añade primitivas de limpieza de cartas y robo/reciclado personal (262 comprobaciones); revisión independiente en SPEC-008. T08.2b añade cierre interno a inicio/rival (334 comprobaciones; revisión favorable), con guardias de Atium usado y efectos sin modelar. T08.2c verifica saldo/fichas y devolución de Atium usado (527 limpieza, 1.938 estado; revisión favorable). La fase sigue abierta: faltan el entrenamiento de inicio, transiciones, efectos de limpieza y paso rival. No hay catálogo oficial para alimentar este constructor en producción. T08.1b requiere pista/recompensas verificadas; T08.2 conserva DUD-006 para agotamiento total.

**Cierre:** Los escenarios de preparación y turnos coinciden con su fuente y quedan probados, incluidas acciones fuera de turno.

### P09 — Efectos y elecciones

**Objetivo:** Resolver las mecánicas y elecciones de las cartas.

**Trabajo:**

- Implementar por familias los efectos confirmados, objetivos y elecciones pendientes.
- Definir orden de resolución, efectos encadenados y finalización; comprobar interacciones y objetivos inválidos.
- Añadir adversarios con escudos, edictos, Dominación y elecciones colectivas, con las dudas resueltas para el subconjunto usado (T09.3).

**Cierre:** Las familias usadas por el subconjunto inicial tienen pruebas y no quedan elecciones sin resolver ni efectos silenciosamente omitidos.

### P10 — Primera partida local completa

**Objetivo:** Jugar de principio a fin con un subconjunto explícito de contenido.

**Trabajo:**

- Conectar una interfaz funcional al motor y aplicar condiciones de final y victoria confirmadas.
- Completar una partida de prueba con preparación, turnos, efectos y resultado final.
- Completar también un escenario de solitario/cooperativo con contenido de prueba identificado y reglas de victoria/derrota propias (T10.3).

**Cierre:** Se terminan una partida competitiva y un escenario local solo/cooperativo reproducibles, registrando el subconjunto cubierto. Todavía no se acredita fidelidad al catálogo completo.

### P11 — Cobertura del contenido acordado

**Objetivo:** Completar las reglas y cartas incluidas en el alcance.

**Trabajo:**

- Inventariar y migrar todas las cartas, cantidades, componentes y excepciones del alcance.
- Completar trazabilidad fuente → REG/carta → especificación → prueba y comprobar combinaciones relevantes.
- Cubrir explícitamente las 36 cartas del rival, Dominación, entrenamiento y excepciones de solitario, sin extrapolar ejemplos del PDF al contenido faltante (T11.3).

**Cierre:** No quedan reglas o cartas del alcance sin implementar o verificar; las dudas que alteren resultados deben resolverse antes del cierre.

### P12 — Interfaz completa de partida

**Objetivo:** Hacer que todas las acciones se entiendan y se puedan realizar.

**Trabajo:**

- Mostrar turno, recursos, zonas, elecciones, historial y resultado; ampliar cartas y explicar acciones no disponibles.
- Adaptar la maqueta a casos reales: manos grandes, nombres largos, varias elecciones y resoluciones acordadas.
- Mostrar salud/mazo rival, Dominación, escudos, edictos y decisiones colectivas, además de reacciones fuera de turno (T12.3).

**Cierre:** Todos los flujos del alcance son accesibles sin editar el estado a mano; la interfaz respeta la información visible de cada jugador.

### P13 — Salas y participantes

**Objetivo:** Entrar, preparar e iniciar una partida remota.

**Trabajo:**

- Implementar crear/unirse, identidad de sesión, plazas y preparación de sala según el alcance.
- Usar salas privadas sin cuentas; vincular cada plaza a una identidad temporal recuperable que no dependa solo del nombre visible.
- Gestionar sala inexistente/llena, incompatibilidad de versiones y salida antes de empezar.
- Seleccionar competitivo/cooperativo, limitar a cuatro humanos y ofrecer una ruta local de solitario sin exigir otro cliente (T13.3).

**Cierre:** Varias instancias llegan a la misma partida y rechazan incorporaciones inválidas con mensajes comprensibles.

### P14 — Partida remota sincronizada

**Objetivo:** Jugar el contenido acordado con una única autoridad de reglas.

**Trabajo:**

- Enviar intenciones validadas, identificar acciones duplicadas y sincronizar cambios y elecciones.
- Filtrar estado privado en el envío y comprobar convergencia del estado público y vistas autorizadas.
- Sincronizar mazo rival y sus resultados desde una única autoridad, junto con escudos, Dominación y elecciones colectivas (T14.3).

**Cierre:** Se completan partidas competitivas y cooperativas remotas con las cantidades admitidas; no hay acciones duplicadas, divergencias ni información privada enviada fuera de su visibilidad autorizada.

### P15 — Desconexiones y recuperación

**Objetivo:** Dar un resultado definido a los fallos de conexión.

**Trabajo:**

- Implementar la política acordada para desconexión, abandono y pérdida de autoridad.
- Implementar la reconexión obligatoria: recuperar plaza, estado autorizado y elecciones pendientes, demostrando posesión de sesión y sin repetir acciones ya aplicadas.

**Cierre:** La política de pausa/reserva y caída de autoridad está definida; se prueban corte, reconexión propia, intento de ocupar plaza ajena y reenvío de acciones. Guardado entre días y migración de anfitrión siguen sujetos a alcance específico.

### P16 — Pruebas con amigos a distancia

**Objetivo:** Validar la experiencia desde dispositivos y redes reales.

**Trabajo:**

- Completar partidas con el número de jugadores objetivo y registrar incidencias reproducibles.
- Comprobar instalación/acceso, latencia, elecciones simultáneas si existen, visibilidad y resultados.
- Registrar evidencia de competitivo 2/3/4, cooperativo 2/3/4 y solitario 1 (T16.3), con finales y eliminación/reacciones propios de cada modo.

**Cierre:** El grupo puede entrar y terminar partidas; los defectos que impiden jugar o cambian reglas están resueltos y las limitaciones restantes registradas.

### P17 — Acabado visual, audio y usabilidad

**Objetivo:** Alcanzar el acabado visual acordado sin perder claridad.

**Trabajo:**

- Sustituir recursos provisionales, integrar animaciones, bruma y audio cuando estén acordados.
- Revisar legibilidad, ritmo, rendimiento, volumen y opciones para reducir efectos.

**Cierre:** El usuario revisa el acabado en una partida real; las animaciones no bloquean acciones ni ocultan información y se cumplen los objetivos registrados.

### P18 — Entrega estable para el grupo

**Objetivo:** Distribuir una versión reproducible y fácil de usar.

**Trabajo:**

- Preparar exportación, versión, instrucciones de acceso, solución de problemas y notas de cambios.
- Ejecutar la lista de entrega y definir cómo registrar incidencias y distribuir actualizaciones.

**Cierre:** Una copia limpia permite ejecutar la versión y completar una partida remota; se conservan evidencia de pruebas y limitaciones conocidas.

## Punto de reanudación

2026-11-14. T08.1b20 completada localmente, verificación y revisión independiente favorables. [Evidencia, estado Git y pendientes](specs/008-preparacion-y-turnos/verification.md#t081b20--implementación-de-objetivos-y-premios-m2). Cierre local completado; siguiente objetivo propuesto: contrato de integración de misiones M1–M8. No repetir M2 ni atribuir Defender/Cloud, limpieza, catálogo o producto al piloto. Sin commit/push nuevos.

2026-11-14. DUD-010 resuelta por respuesta «si» y DEC-039; contrato T08.1b19 completado documentalmente y revisado favorablemente. Siguiente objetivo propuesto: T08.1b20, versión/admisión del piloto M2/M5/M7 según su contrato; no reabrir decisiones aceptadas. [Fuentes, APIs, responsables y estado Git](specs/008-preparacion-y-turnos/verification.md#t081b19--contrato-de-objetivos-y-premios-m2). No repetir implementación M1 publicada; M2 sigue sin código y sus escenarios son futuros.

2026-11-13. T08.1b17 completada documentalmente y revisada favorablemente sobre main/`3be2a8d`, sólo Markdown local. [Traspaso vigente](specs/008-preparacion-y-turnos/verification.md#t081b17--contrato-de-selección-y-premios-m1): DEC-037 y contrato único revisados; primer paso T08.1b18: versión y derivación de capacidad por perfil. No repetir M8 publicada ni confundir el contrato con M1 implementada. Sin commit/push, producto ni entrada a limpieza. Notas inferiores históricas.

2026-11-13. T08.1b16 implementada y verificada localmente, revisión independiente favorable. [Resultado, evidencia y traspaso](specs/008-preparacion-y-turnos/verification.md#t081b16--implementación-de-elecciones-y-eliminación-m8): perfil aislado M5/M7/M8, snapshot 5, 15 suites/8.418 comprobaciones. Cambios locales de T08.1b15/16 sobre `d5d6403`, sin commit/push. Siguiente objetivo propuesto T08.1b17, contrato de selección/premios M1; no rehacer M8 ni admitirla en perfiles anteriores. Entrada a limpieza/producto, P04 externa y modos con rival siguen pendientes. Las entradas inferiores conservan antecedentes.

2026-11-13. T08.1b15 completada documentalmente con revisión independiente favorable: [contrato M8 y plan de implementación](specs/008-preparacion-y-turnos/elecciones-m8.md). T08.1b14 está publicada en `d5d6403`, confirmado tras fetch. Próxima implementación T08.1b16: ventanas completas y cierre vacío, proyección privada y perfil aislado M5/M7/M8; contrato revisado, implementación todavía no iniciada. Sin código ni publicación de T08.1b15. [Evidencia vigente](specs/008-preparacion-y-turnos/verification.md#t081b15--contrato-de-elecciones-y-eliminación-m8). Las notas siguientes son antecedentes.

2026-11-13. T08.1b14 completada localmente y revisada: perfil aislado M3/M4/M7 con inicio y cierre internos según [contrato de permanentes](specs/008-preparacion-y-turnos/permanentes-misiones.md), 14 suites/7.904 comprobaciones. Sin commit/push, entrada a limpieza ni producto. Siguiente propuesto T08.1b15: especificar elecciones y eliminación opcional de M8, fuentes/AC y enlace con secuencias antes de implementarla. [Evidencia vigente](specs/008-preparacion-y-turnos/verification.md#t081b14--implementación-de-permanentes-m3m4). Las entradas inferiores conservan antecedentes.

2026-11-12. T08.1b12 completada localmente y revisada: [avance automático M5/M6/M7](specs/008-preparacion-y-turnos/verification.md#t081b12--resolutor-automático-de-misiones-m5m6m7), esquema 3, 5.418 comprobaciones. T08.1b11 publicada en `2bc058c`; T08.1b12 se publica por encargo expreso en el commit que incorpora esta actualización. Siguiente objetivo T08.1b13: especificar integración de permanentes M3/M4 y aplicación única en inicio/limpieza. Mantener pendientes elecciones, cartas generadoras de puntos, catálogo restante, integración de producto y modos con rival.

2026-11-12. T08.1b11 concreta el [avance de misiones](specs/008-preparacion-y-turnos/avance-misiones.md), MIS-01–06 y DEC-034; completada documentalmente con revisión independiente favorable. Siguiente implementación T08.1b12: perfil automático M5/M6/M7 con primeras llegadas y victoria, esquema de snapshot nuevo y núcleo de entrenamiento compartido. Elecciones, permanentes e integración de producto siguen pendientes.

2026-11-12. T08.1b8 transcribe M1–M8, T08.1b9 especifica su [contrato de catálogo v2](specs/008-preparacion-y-turnos/catalogo-misiones.md) y T08.1b10 incorpora el lote en carga explícita. Siguiente paso propuesto: especificar la transacción competitiva de avance de misión, sus premios y sus finales.

2026-11-12. T08.2i aplica el robo personal de DEC-032. La activación de habilidades y el paso del Lord Legislador requieren sus resolutores. [Evidencia y traspaso](specs/008-preparacion-y-turnos/verification.md#t082i--robo-personal-con-mazo-y-descarte-agotados).

2026-11-12. DEC-032 resuelve DUD-004/006 para la adaptación. Su aplicación se incorpora a las tareas de habilidades, robo personal y finales del rival. [Evidencia y traspaso](specs/008-preparacion-y-turnos/verification.md#t081b7--desbloqueo-tardío-robo-y-finales-del-rival).

2026-11-12. T08.1b5 delimita el perfil competitivo de producto y T08.1b6 recoge DEC-031. [Evidencia y traspaso](specs/008-preparacion-y-turnos/verification.md#t081b6--resoluciones-de-reglas-del-perfil-competitivo).

Antecedente del 2026-11-12. Contrato T08.1b3 publicado en `fd75e23` e inicio aislado T08.1b4 publicado en `69c1ef2`. [Evidencia y traspaso](specs/008-preparacion-y-turnos/verification.md#t081b4--implementación-del-inicio-competitivo).

Actualización vigente 2026-11-12. T08.1b2 publicada en `ab3ef55`. T08.1b3 completada documentalmente con revisión independiente. El siguiente objetivo es T08.1b4. [Evidencia y traspaso](specs/008-preparacion-y-turnos/verification.md#t081b3--contrato-del-inicio-único-competitivo).

Actualización vigente 2026-11-11: [T08.1b2](specs/008-preparacion-y-turnos/verification.md#t081b2--operación-interna-de-avance-competitivo) implementada y probada con un perfil aislado. Siguiente objetivo: diseñar la transacción de inicio competitivo de ENT-AC-04. Las notas de reanudación inferiores son antecedentes.

Publicación de la entrega T08.2f autorizada el 2026-11-10; la revisión que incorpora esta nota identifica su commit. Las notas de cambios locales sin commit/push siguientes son históricas. No cambia el siguiente objetivo ni autoriza publicar entregas futuras.

Actualización vigente 2026-11-10: T08.2f completada localmente, 253 comprobaciones de secuencias y 3.353 con regresiones, revisión independiente favorable. Esquema 2/motor `p08-sequence-1/godot-4.7.2`; [evidencia y traspaso](specs/008-preparacion-y-turnos/verification.md#t082f--implementación-de-secuencias-reanudables). HEAD/origin/main consultados mediante fetch en `7a9f25c`; cambios locales sin commit/push. Siguiente objetivo: especificar el primer resolutor real de competitivo con reglamento y escaneos pertinentes verificados, antes de habilitar combate/entrada a limpieza. Lord Legislador al final según DEC-027. No repetir el núcleo ficticio; las entradas inferiores son antecedentes.

Actualización 2026-11-01: comprobar siempre primero el estado de GitHub mediante fetch y registrar el commit consultado, preservando diferencias locales. Recuperación actual desde `6caed87`. [T08.2e](specs/008-preparacion-y-turnos/secuencia-reanudable.md) completa el contrato de secuencias con revisión documental independiente favorable; próximo trabajo: T08.2f con operaciones ficticias y SEQ-01–10. No repetir P07 ni T08.2a/b/c/d. Las entradas anteriores son antecedentes; ninguna habilita transición a limpieza sin resolutores reales.

Actualización 2026-10-30: T08.2d redacta el [contrato de entrada a limpieza](specs/008-preparacion-y-turnos/entrada-a-limpieza.md), revisado independientemente. No existe segmento de entrada seguro con el modelo actual. El primer paso siguiente es especificar la secuencia reanudable de autoridad P08/P09, con operaciones ficticias explícitas para verificar pausas, cierre único y rollback antes de conectar combate/Target/efectos. El traspaso T08.2c inferior queda como antecedente.

Objetivo cerrado localmente 2026-10-30: T08.2c (contrato y devolución de Atium usado), AC-15–18 de SPEC-008. Sustituye como próximo trabajo el contrato pendiente indicado en el punto 2 inferior. Implementación y pruebas locales completadas (limpieza 527, estado 1.938); revisión independiente favorable; [evidencia vigente](specs/008-preparacion-y-turnos/verification.md#t082c--saldo-y-devolución-de-atium). Mantener sin resolver por inferencia entrenamiento, combate/Target/efectos, rival, DUD-006 y P04 externa.

1. T01.1 y el inventario inicial T01.2 están documentados a partir del PDF recibido. Consultar [fuentes](referencias/README.md), [matriz](referencias/matriz-reglas.md) y [dudas](referencias/dudas.md).
2. P03, maqueta P05 y contrato inicial P06 completados. T07.1/2 implementadas y verificadas localmente; T08.1a prepara el estado con [SPEC-008](specs/008-preparacion-y-turnos/spec.md), 147 comprobaciones. El usuario mantiene pendientes por ahora las fotos del material español y las dudas de reglas; no reinterpretarlas ni insistir al retomar. T08.2a implementa ya el ciclo personal confirmado (262 comprobaciones); T08.2b implementa el cierre interno del subconjunto confirmado de limpieza (334 comprobaciones, revisión favorable); T08.2c fija y verifica contrato saldo/fichas de Atium y devolución de usadas (revisión favorable), conservando pendientes efectos previos, combate, entrenamiento y DUD-006. [Evidencia y traspaso](specs/008-preparacion-y-turnos/verification.md#t082b--cierre-interno-de-limpieza). T08.1b espera pistas/recompensas verificadas. P07 no cierra hasta completar P04; T04.2 sigue pendiente de segundo equipo y evidencia externa. Mantener T02.1 parcial por catálogo y detalles de fases posteriores.
3. Completar [SPEC-001](specs/001-alcance-y-reglamento/spec.md) y refinar [SPEC-002](specs/002-modos-y-cooperativo/spec.md) antes de la implementación dependiente.

T00.1/AC-08 completada y revisada; publicación detallada autorizada en encargo posterior del 2026-10-29, con [cierre y traspaso](specs/009-sistema-agentes/verification.md#ampliación-ac-08--sesiones-y-contexto). Para otro objetivo del juego, usar un chat nuevo centrado en el siguiente pendiente de T08.2 (puertas de combate/efectos tras el contrato de Atium T08.2c) y contrastar el traspaso de SPEC-008/estado/Git; no rehacer la auditoría de agentes ni inferir permiso de publicación de futuras entregas.

Seguir el [flujo SDD e issues](gestion/desarrollo.md) y los [criterios de calidad](calidad.md). La entrega inicial versiona estas bases por encargo del usuario; las tareas aún no se han publicado como issues.
