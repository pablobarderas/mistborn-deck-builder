# Plan de trabajo por fases

Última revisión: 2026-10-29. P00, el inventario inicial de P01, P03, la maqueta de P05 y el contrato inicial de P06 están completados en su alcance. P04 mantiene pendiente la prueba externa. Hay base ejecutable con datos de prueba; las reglas y partidas siguen sin implementar.

## Objetivo y situación

Crear una aplicación para Windows en español, visualmente cuidada y fiel al juego de mesa, con competitivo 2–4, cooperativo 2–4 y cooperativo en solitario. Máximo cuatro personas. Ya existe una pantalla inicial ejecutable que carga y muestra las dos cartas de prueba.

Acceso confirmado: salas privadas sin cuentas y capacidad de reconectarse a la misma plaza/partida. Pausa, reserva de plaza y pérdida del anfitrión se concretarán en P15; no se presuponen acordadas.

SRC-001 ya está identificado y leído: reglamento inglés de 2024, 1.ª edición/1.ª impresión. El usuario tiene la caja española; falta contrastar localización y completar cartas/pistas. Windows es la plataforma inicial confirmada; la maqueta 2D de P05 se acepta como dirección visual inicial.

## Cómo avanzar

- Cerrar cada fase con evidencia de su criterio de salida, no solo con código escrito.
- Las dependencias condicionan el cierre. Se pueden investigar tareas independientes antes sin convertir propuestas en decisiones.
- P04 y P05 pueden avanzar por separado tras P03. P11, P12 y P13 pueden avanzar por separado tras P10, respetando sus dependencias.
- Mantener una tarea de implementación activa por defecto y dividir tareas con varios comportamientos independientes.
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
| P08 | Preparación y turnos | P01, P07 | Pendiente |
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

- **E0 — Base documental:** P00. Documentación y plantillas preparadas para la entrega inicial en `main`.
- **E1 — Riesgos y aspecto explorados:** P01–P05. Arranque, vía de conexión y maqueta revisada.
- **E2 — Primera partida local:** P06–P10. Subconjunto identificado; no acredita fidelidad al catálogo completo.
- **E3 — Contenido e interfaz completos:** P11–P12.
- **E4 — Primera partida remota:** P13–P14, con sus dependencias.
- **E5 — Jugable con amigos:** P15–P16.
- **E6 — Entrega cuidada:** P17–P18.

La entrega final incluye los tres modos. La cobertura se comprueba en siete configuraciones: competitivo 2/3/4, cooperativo 2/3/4 y solitario 1. El rival se ejecuta por reglas y mazo, sin requerir un jugador adicional ni una IA estratégica.

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

**Avance 2026-10-29:** T07.1/2 implementadas/verificadas localmente en [SPEC-007](specs/007-estado-y-acciones/verification.md): 1.725 comprobaciones de estado y 102 del motor. Acciones estructurales con manejadores ficticios; la fase no cierra mientras P04 externa siga pendiente. No hay preparación ni reglas ejecutables de cartas.

### P08 — Preparación y turnos

**Objetivo:** Reproducir el inicio y la secuencia del juego confirmado.

**Trabajo:**

- Implementar preparación, reparto, orden de jugadores y fases del turno según REG.
- Cubrir transiciones, límites y los casos de mazo/descartes que existan en el reglamento.
- Implementar diferencias por modo: bonificaciones competitivas, Target y preparación del rival sin bonificaciones en solo/cooperativo (T08.3).

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

1. T01.1 y el inventario inicial T01.2 están documentados a partir del PDF recibido. Consultar [fuentes](referencias/README.md), [matriz](referencias/matriz-reglas.md) y [dudas](referencias/dudas.md).
2. P03, maqueta P05 y contrato inicial P06 completados. T07.1/2 implementadas y verificadas localmente según [SPEC-007](specs/007-estado-y-acciones/spec.md): 1.725 comprobaciones de estado y 102 del motor. Próximo trabajo independiente: especificar P08, preparación y turnos; P07 no cierra hasta completar P04. T04.2 sigue pendiente de segundo equipo y evidencia externa. Mantener T02.1 parcial por catálogo y detalles de fases posteriores.
3. Completar [SPEC-001](specs/001-alcance-y-reglamento/spec.md) y refinar [SPEC-002](specs/002-modos-y-cooperativo/spec.md) antes de la implementación dependiente.

Seguir el [flujo SDD e issues](gestion/desarrollo.md) y los [criterios de calidad](calidad.md). La entrega inicial versiona estas bases por encargo del usuario; las tareas aún no se han publicado como issues.
