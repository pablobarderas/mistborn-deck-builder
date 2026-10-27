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

## Decisiones aún pendientes

- Equivalencia con edición española, terminología, catálogo completo y dudas del reglamento recibido.
- Alcance mínimo de una partida jugable.
- Compatibilidad mínima de Windows y objetivos finales de hardware/resolución; Godot 4.7.2 ya está fijado.
- Carga del catálogo, validación y política ante errores.
- Modelo estructurado de efectos.
- Transporte/alojamiento, formato de invitación, pausa/reserva y pérdida de autoridad; salas privadas sin cuentas y reconexión ya están acordadas.

Registrar una nueva entrada cuando haya evidencia suficiente o un acuerdo; mientras tanto, mantener la incertidumbre explícita.
