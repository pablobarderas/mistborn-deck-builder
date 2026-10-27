# Registro de trabajo

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
