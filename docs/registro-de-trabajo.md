# Registro de trabajo

## 2026-10-29 — Publicación de T07.1 y T07.2 local

- Por petición del usuario, T07.1 se registró como b3ff3c7 y se subió a origin/main. Se mantuvieron fuera los cambios previos de project.godot y dos .import.
- Implementada T07.2: núcleo de acciones con actor por parámetro de confianza, revisión, validación previa, RNG en snapshot, recibos duraderos en la sesión y vistas filtradas por destinatario. Manejadores ficticios solo en tests; no hay reglas, interfaz ni red del juego. version_motor pasa a p07-engine-2/godot-4.7.2 por el contrato de recibos/acciones.
- Verificación real: test-engine 102 comprobaciones; test-state 1.725, test-catalog 220 y test de arranque 58, todo código 0 con Godot 4.7.2. Dos avisos de rechazo esperados en el núcleo. Proyección de información oculta comprobada localmente; no tráfico remoto.
- Se actualizan estado, plan, SPEC-007, backlog, arquitectura y guía. P07 sigue abierta por P04 externa. Próximo trabajo independiente: especificar P08; las dudas de reglas y el catálogo faltante permanecen registrados.

## 2026-10-28 — T07.1: estado e invariantes locales

- Implementados scripts/game/game_state.gd y state_validator.gd: snapshot privado v1, modos/plazas, recursos, instancias/zonas, misiones, rival/escudos y resolución pendiente. Copias profundas, referencias e invariantes; rechazar una carga conserva el último estado válido. Sin interpretar efectos ni implementar reglas con DUD abiertas.
- Añadidos fixtures ficticios y tests/game_state_test.gd; acción test-state, marca P07_STATE_OK y rechazo de errores de motor/script. El almacén acepta parámetros de confianza; no es API de cliente ni la futura admisión de contenido del núcleo.
- Verificación real con Godot 4.7.2.stable.official.ed1daf0bf: 1.725 comprobaciones de estado, 220 de catálogo y 58 de arranque, código 0. Aviso/errores negativos anunciados; ningún error inesperado final. La importación necesitó acceso a los datos normales del perfil Windows. Motor en Descargas mediante -GodotPath; .tools/godot ausente, discrepancia documentada.
- Actualizados SPEC-007, tareas/backlog, estado, plan, arquitectura, guía local e índices. Enlaces y diff revisados. Conservados project.godot y dos .import previos; sin commit/push ni publicación.
- No hay nuevas dudas de reglas bloqueantes para este alcance. Próximo paso T07.2: transacciones, RNG, recibos por plaza y vistas privadas. P07 no cerrada; P04 externa y catálogo/reglas pendientes conservan sus bloqueos.

## 2026-10-28 — Especificación de P07

- Siguiendo el punto de reanudación, creada SPEC-007 con modelo, contrato de intenciones, transacción atómica, RNG, deduplicación por plaza y privacidad. Incluye rival y secuencias pausables, sin implementar reglas futuras ni inventar resoluciones de DUD.
- Refinadas T07.1/2, aceptación y plan de pruebas; actualizados índice, arquitectura, estado, plan y DEC-017. Corregida la lista antigua de decisiones pendientes que aún daba por no resuelta la carga P06.
- Conservados cambios previos en project.godot y dos archivos .import. Revisión del código confirma que aún no existe núcleo de partida.
- Verificación: enlaces locales de los documentos afectados y diff comprobados. Cambio documental: no se ejecutó Godot ni se acreditan pruebas de AC-01–09. Sin commit, push ni publicaciones.
- Próximo paso: implementar T07.1 local, luego T07.2. P07 no cerrada; sigue pendiente P04 entre redes, catálogo oficial y reglas con dudas abiertas.

## 2026-10-27 — Publicación de P06

- El usuario autoriza commit y push de los cambios. Se reúnen contrato/cargador, migración de muestras, pruebas, captura Android y documentación de continuidad.
- Se conservan las verificaciones de la implementación final: 220 comprobaciones de contrato, 58 de arranque y 39 de maqueta. En esta tarea solo cambia documentación de publicación; no se modifica la lógica ni hace falta repetir pruebas.
- El commit de esta entrada identifica la entrega en main. Comprobar revisión remota y árbol limpio tras el push. P04 externa y catálogo oficial siguen pendientes; próximo trabajo P07. Sin issues ni PR nuevas.

## 2026-10-27 — P06: contrato del catálogo y captura Android

- El usuario pide la fase siguiente antes de recopilar cartas y consulta cómo ahorrar transcripción en móvil; confirma Android. Ayuda oficial contrastada: Drive para escaneos por lotes, Lens para texto puntual. Guía incorporada sin instalar/integrar OCR.
- SPEC-006 y sobre JSON v1 con fuentes/revisión, definición separada de instancia futura, efectos/condiciones/recorridos y operación pendiente. Dos ejemplos migrados explícitamente: IDs, texto/números conservados como muestras; rutas ficticias sustituidas por null. Cero cartas oficiales verificadas.
- Validador separado, rechazo atómico, referencias, tipos/números/enums, rutas, avisos de arte, estados/revisión y selección verificada. API devuelve copias profundas; presentación actualizada. No se ejecuta texto ni se implementan efectos.
- Verificación final: 220 comprobaciones de contrato, 58 de arranque y 39 de maqueta, código 0; captura del inicio con conteos/avisos revisada. Casos de tipos inesperados revelaron errores de comparación corregidos; el lanzador ahora rechaza SCRIPT ERROR aunque el proceso devuelva 0. Dos errores de carga del test de catálogo y ocho de arranque son negativos esperados.
- T06.1/2 y P06 completadas en alcance inicial. DUD-002/003 y catálogo real siguen pendientes; P07 se puede especificar/localmente preparar sin dar por cumplida la dependencia externa P04. Datos y arte de P05 siguen separados. Sin nuevo commit/push ni issues.

## 2026-10-27 — Aceptación visual y publicación de P04/P05

- El usuario pide «haz commit y push, se ven bien las cartas si». Se registra aceptación de la dirección visual inicial, especialmente presentación de cartas; T05.2 y P05 cerradas en alcance de maqueta. Arte/catálogo/reglas finales siguen pendientes.
- Estado, plan, backlog, especificación, decisiones y guía de reanudación actualizados. Próximo trabajo independiente: P06; T04.2 sigue pendiente de prueba entre redes con segundo equipo.
- El commit de esta entrada reúne código/escenas, herramientas, pruebas, ilustraciones con procedencia y documentación de P04/P05. Se conservan las verificaciones ya ejecutadas: P04 73 comprobaciones locales, P05 39 y regresión de arranque 58. Solo se ajusta el mensaje final del test visual para no indicar aceptación pendiente; la lógica verificada permanece igual y la anotación documental no requiere repetir pruebas.
- Publicación autorizada en main; comprobar al terminar que la revisión remota coincide y el árbol queda limpio. No se crean issues ni PR.

## 2026-10-27 — P05: propuesta visual del tablero

- El usuario encarga diseño limpio, moderno y bonito, con colores del PDF. Se revisan renders de portada y páginas 4/12/18 de SRC-001 mediante la habilidad PDF. SPEC-005 escrita antes de construir la propuesta.
- Paleta azul noche/grafito, plata/marfil y acentos de metales; tipografía, espacio y estados documentados. Atlas de cuatro ilustraciones provisionales generado con herramienta integrada y copiado dentro del proyecto, con prompt y hash; no se extrae ni altera arte oficial.
- Escena y componentes separados de catálogo/red: mercado, mano, cuatro participantes, misiones, metales y recursos de muestra. Modal con foco/Escape, acción visual de mano a mesa, reinicio, mano de diez cartas y desplazamiento. Acceso desde Ver tablero y acciones board/preview-board.
- Verificación final: 39 comprobaciones con render real, seis capturas en 1280×800/1920×1080/1024×640, mano saturada/vacía y navegación. Se corrigen ancho al redimensionar y redondeo que generaba barras innecesarias; se aclara rojo para contraste. Regresión P03: 58 comprobaciones, código 0, y captura del inicio revisada.
- T05.1 completada técnicamente. T05.2/P05 quedan en revisión del usuario; la propuesta concreta no se considera aceptada aún. P04 externa sigue pendiente. No se implementan reglas ni se valida catálogo con estos datos. Sin commit/push ni issues nuevas; se conserva el trabajo local de P04.

## 2026-10-27 — Confirmación del prototipo por el usuario

- Tras entregar el ensayo de conexión, el usuario indica «Funciona perfecto». Registrado en estado y verificación de SPEC-004 sin inferir pasos concretos ni prueba externa.
- T04.2 sigue pendiente; el siguiente trabajo independiente disponible es P05. Sin cambios de código ni nuevas pruebas necesarias para esta anotación documental.

## 2026-10-27 — P04: prototipo de conexión local

- El usuario pide el siguiente paso tras revisar favorablemente la pantalla inicial. Se inicia P04 conforme al plan; confirma que ahora solo dispone de un PC.
- SPEC-004 escrita antes de implementar. Sesión experimental separada de UI y catálogo: ENet/UDP fiable, anfitrión como autoridad, hasta tres invitados, clave aleatoria y admisión por protocolo/nombre. Lista y contador con secuencias por conexión; validación de solicitudes, límites y timeout. No representa partida ni recuperación de plaza.
- Nueva pantalla con crear/unirse/señal/desconectar/volver; acceso desde inicio. Lanzador con network, test-network y preview-network. No se añade infraestructura ni dependencias ni se cambia cortafuegos/router.
- Verificación: 47 comprobaciones del coordinador y 26 en siete procesos hijo, código 0, solo localhost; incluye cuatro personas simultáneas, quinto rechazado, errores y duplicados, fin del anfitrión, liberación y reintento. Regresión P03: 58 comprobaciones, código 0. Captura/navegación: 12 comprobaciones, tres imágenes reales a 1280×800/1024×640; contraste ajustado tras inspección.
- T04.1 completada localmente; T04.2 parcial con guía y comparación de alternativas, pendiente segundo equipo y evidencia externa. P04 queda abierta; P05 puede avanzar por separado. DEC-014 describe elección del experimento, no alojamiento definitivo.
- Documentos de estado, plan, backlog, arquitectura, calidad e instrucciones actualizados. Cambios locales sin commit/push ni issues nuevas.

## 2026-10-27 — Entrega para continuar en otro PC

- El usuario autoriza subir a GitHub todo lo necesario. Se reúne P03 y las revisiones documentales previas; se añade guía de reanudación enlazada desde README e índice.
- SRC-001 se copia al repositorio sin modificar; SHA-256 idéntico al registrado. Se actualizan fuente, estado y DEC-013 para eliminar la dependencia de una ruta externa.
- Pruebas repetidas antes de publicar: 58 comprobaciones, código 0, ocho errores negativos esperados. Motor, cachés y temporales quedan ignorados. No se crean issues ni se avanza P04 en esta tarea.
- El commit de esta entrada identifica la entrega; comprobar sincronización de main con origin tras el push.

Entradas breves en orden cronológico. Conservar cambios, motivos y verificaciones útiles; el estado vigente se consulta en [estado actual](estado-actual.md).

## 2026-10-26 — Análisis inicial y documentación

- Petición: analizar el proyecto y preparar instrucciones y memoria duradera para una adaptación de Mistborn jugable a distancia con amigos.
- Base inspeccionada: dos commits en `main`, último `3806537`; árbol limpio al inicio. Contenido funcional: un cargador GDScript y dos cartas de prueba.
- Hallazgos: falta `project.godot`; no hay escenas, imágenes, reglas ejecutables, red ni pruebas. El cargador no valida campos ni IDs duplicados; las rutas visuales difieren de la convención original.
- Cambios: `AGENTS.md` en la raíz Git, entrada de orientación en la carpeta contenedora, `README.md` e índice y documentos temáticos en `docs/`. La ubicación antigua de instrucciones remite a la nueva fuente única.
- Verificación: inspección del contenido y Git; comprobación del JSON y de enlaces relativos de los documentos. No se ejecutó Godot: faltan configuración del proyecto y un ejecutable identificado en `PATH`.
- Pendiente: confirmar reglamento, alcance y plataforma antes de implementar la primera partida. Continuar por la fase 1 del plan.
- No se modificó el comportamiento de `Database.gd` ni el contenido de las cartas de prueba.

## 2026-10-26 — Fases, SDD e integración preparada con GitHub

- Petición: definir fases claras, documentación necesaria y un método eficiente con issues y SDD si procede.
- Información nueva: el usuario tiene el juego en español; edición exacta y número de participantes pendientes. Pide recomendación sobre plataforma; se propone Windows/2D, sin darlo por aceptado.
- Análisis: Godot permite aplicación nativa y web; se consultaron fuentes oficiales de exportación/red, GitHub y Spec Kit. Se adopta SDD ligero sin instalar herramientas.
- GitHub: conector confirma el repositorio público y main; búsqueda sin issues. No se ha mutado GitHub.
- Cambios: plan de 19 fases con entregables, dependencias y cierre; alcance, calidad, proceso, backlog y trazabilidad de fuentes. SPEC-001 en borrador con aceptación, tareas y verificación. Plantillas locales de issues y PR. Índice, AGENTS, estado y decisiones actualizados.
- Validación: 26 documentos Markdown, 63 enlaces locales, 19 fases con dependencias anteriores válidas, 35 IDs de tareas únicos, cinco criterios de SPEC-001 trazados a verificación y tres cabeceras de plantillas de issue comprobados. Sin espacios finales detectados; `git diff --check` correcto. Sin pruebas del juego porque no se ha implementado funcionalidad.
- Reanudación: recibir reglamento español para T01.1; concretar dispositivos y jugadores. Publicación del flujo en GitHub pendiente de encargo, sin commits ni push.

## 2026-10-27 — Reglamento recibido y modos confirmados

- Información del usuario: máximo cuatro personas; incluir cooperativo en solitario y en grupo. Se conserva competitivo 2–4, cooperativo 2–4 y solitario 1 como alcance final.
- Fuente: `C:/projects/mistborn-deckbuilder/MistbornRulebook_V1.pdf`, SRC-001. Es inglés, 20 páginas, Brotherwise Games, 1.ª edición/1.ª impresión, 2024. Metadatos y hash en referencias; original intacto y fuera de la raíz Git.
- Lectura: extracción inicial con pypdf incompleta en varios bloques; contraste con pdfplumber y revisión visual de las 20 páginas renderizadas con Poppler. Se revisaron diagramas, iconos, preparación y reglas de pp.18–20.
- Resultado: 67 reglas con página y caso previsto, inventario físico y de contenido faltante, siete dudas explícitas. El PDF no incluye todos los textos/cantidades por diseño ni todas las pistas; la localización española sigue pendiente.
- Plan: T01.1 completada documentalmente y T01.2 completada como inventario inicial del material disponible. P02 sigue parcial. Nueva SPEC-002 con 12 criterios; ocho tareas añadidas, 43 en total. Fases y calidad cubren las siete configuraciones de modo/jugadores.
- Contratos: documentada la insuficiencia de los campos actuales para acciones, aliados, reacciones, escudos y edictos. No se modificó el código ni el JSON de prueba.
- Validación: 33 documentos Markdown, 92 enlaces locales, 67 REG, siete DUD, 43 IDs de tarea únicos, 19 fases sin dependencias posteriores y 17 criterios AC trazados. Hash/tamaño y 20 páginas/20 renderizados comprobados; `git diff --check` correcto. Intermedios de PDF retirados después de la revisión; `/tmp/` excluido de Git. Sin pruebas de juego ni ejecución de Godot.
- Reanudación: T02.1 (dispositivos/plataforma, acceso, desconexión y catálogo), recopilar contenido español por lotes y resolver DUD antes de implementar reglas dependientes. Jugadores y modos ya están acordados. No se publicaron issues ni commits.

## 2026-10-27 — Plataforma Windows confirmada

- El usuario confirma que todos los participantes tienen Windows, respondiendo a la recomendación de aplicación nativa.
- Se registra aplicación Windows como plataforma inicial en DEC-009 y se resuelve Q-002 a nivel de plataforma. La propuesta visual 2D se revisará en P05; compatibilidad mínima, hardware y resoluciones siguen pendientes de P03/P05.
- AGENTS, alcance, plan, arquitectura, estado, backlog y SPEC-001 actualizados para no repetir la pregunta. P02 sigue parcial por catálogo, acceso y desconexiones.
- Verificación: enlaces locales, ausencia de contradicciones sobre la plataforma actual y `git diff --check`. Sin cambios de código ni pruebas del juego.
- Siguiente paso: requisitos de acceso/desconexión y contenido del catálogo; no quedan pendientes de sistema operativo ni cantidad/modos de participantes. No se publicaron issues ni commits.

## 2026-10-27 — Entrega inicial de bases documentales

- El usuario solicita expresamente hacer commit y push de todo lo preparado. Rama actual: `main`; remoto: `origin` en `pablobarderas/mistborn-deck-builder`. Se actualiza la referencia remota antes de publicar.
- La entrega agrupa AGENTS, documentación de producto y reglas, 19 fases, 43 tareas, especificaciones, plantillas de GitHub, enlace desde las instrucciones anteriores y exclusión de temporales.
- El PDF original y el AGENTS de orientación de la carpeta contenedora están fuera de la raíz Git y no forman parte de este commit. El código y las dos cartas de prueba permanecen sin cambios.
- Verificación: enlaces y contenido documental, JSON existente, `git diff --check` y revisión de los archivos preparados. El push debe verificarse al cierre contra la revisión de `refs/heads/main` en el remoto; el resultado verificable queda en el historial Git y en el resumen de entrega.
- Las issues del backlog no se crean por este encargo. Próximo trabajo: acceso/desconexión y catálogo de contenido oficial.

## 2026-10-27 — Auditoría de interpretación y aclaraciones oficiales

- El usuario pregunta si todo el PDF está interpretado correctamente y ofrece resolver dudas. No se afirma validación completa: lectura, inventario, interpretación y pruebas son estados distintos.
- Se localiza y lee SRC-002, FAQ del editor con actualización declarada de enero de 2025. Registro, matriz y especificaciones actualizados; no se copia la página completa.
- Inventario ampliado de 67 a 75 reglas, con fuentes por fila. DUD-001/007 resueltas; DUD-004 parcial; cuatro abiertas. Se conserva el historial de IDs.
- Se pregunta la editorial de la caja española para contrastar localización. Faltan catálogo y aclaraciones de casos límite; no se inventan respuestas.
- Verificación: enlaces, coherencia de IDs y estados y diff revisados. No se ejecutan pruebas del juego ni se modifica código. Cambios locales posteriores a `f2a5744`, sin nuevo commit/push en esta revisión.

## 2026-10-27 — Crédito de la copia española

- El usuario indica que únicamente encuentra «Edición: David Pérez». Se registra como crédito personal observado, sin inferir tirada ni atribuir empresa a esa persona.
- Se consultan el anuncio y la ficha oficiales de Devir, registrados en SRC-003. Permiten identificar la publicación española, pero no acreditar equivalencia de todos los textos de la copia del usuario.
- No se encuentra enlace accesible al reglamento español en las páginas consultadas; la página de Devir España devuelve 403 a la consulta. No se usan traducciones comunitarias como reglas oficiales.
- DUD-003 sigue abierta para contraste de localización. No repetir la pregunta de editorial; seguir con SRC-001/002 y pedir material español concreto cuando una tarea lo necesite.
- Verificación: enlaces locales y diff documental. Sin cambios de reglas, código, commit ni push.

## 2026-10-27 — Acceso privado y reconexión confirmados

- El usuario confirma salas privadas sin cuentas y posibilidad de reconectar. Registrado en PROD-008/009 y DEC-011; reentrada pasa a ser obligatoria en P15.
- Alcance, arquitectura, plan, backlog, calidad, estado y SPEC-001 actualizados. Criterios: recuperar plaza propia y estado visible, conservar elecciones pendientes y no repetir acciones, usando identidad temporal compatible con no tener cuentas.
- Pausa durante el corte, tiempo de reserva y pérdida del anfitrión siguen sin concretar; no se registran como acuerdos del usuario. Transporte/proveedor y guardado persistente tampoco se eligen en esta tarea.
- El núcleo de alcance permite preparar P03; la especificación general continúa parcial por detalles asignados a fases posteriores y material de catálogo pendiente.
- Verificación: enlaces, referencias y diff documental comprobados. No se implementó red ni se ejecutaron pruebas del juego. Sin commit/push nuevos.

## 2026-10-27 — P03: proyecto Godot ejecutable

- Autorización del usuario: «Vamos a por ello», sobre P03. SPEC-003 creada antes de implementar; conserva criterios y evidencia.
- No se encontró Godot en las ubicaciones habituales. Preparado motor portátil 4.7.2 estable desde el enlace oficial; ejecutable devuelve 4.7.2.stable.official.ed1daf0bf. .godot-version fija la versión y .tools/ queda ignorado. SHA-256 del ZIP local: 731980f9608d61333e5baf54a2ef17210acc7a538446c0cb9969f002aca1e953 (huella calculada para identificar esta descarga, no contraste con un manifiesto externo).
- Implementado project.godot, Autoload Database, pantalla y tarjetas de prueba, tema y fondo SVG propios. El JSON original no cambia. Carga/recarga y señales de error; validación mínima de estructura e IDs, sin implementar el esquema completo de P06.
- Herramientas: lanzador PowerShell para importar, ejecutar, editor, pruebas y captura. Casos negativos y recuperación en GDScript sin framework. Los archivos temporales se excluyen de Git y del escaneo de Godot.
- Verificación final: 58 comprobaciones en copia de fuentes sin .godot previa; código 0. Ocho errores de carga esperados y recuperación comprobada. Captura real 1280×800 en OpenGL/Compatibility revisada, salida mediante la señal del botón. Arranque normal de la escena configurada sin errores; ruta de motor ausente rechazada con código 1. La primera ejecución requirió permiso para los datos normales de Godot en el perfil Windows. Documentación: 38 archivos y 102 enlaces locales comprobados; `git diff --check` correcto.
- P03 y T03.1/2 completadas en su alcance. Estado, plan, decisiones, arquitectura, datos, README y guía local actualizados. Detalles y rutas de evidencia en SPEC-003.
- Sigue pendiente P04 para probar conexión externa; P05 puede revisar la propuesta visual. No se han implementado reglas, salas o reconexión ni exportado una versión distribuible. Sin nuevo commit/push; se conserva el trabajo documental previo.
