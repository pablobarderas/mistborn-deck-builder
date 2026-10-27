# Registro de trabajo

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
