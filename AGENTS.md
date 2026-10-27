# Reglas del proyecto

## Objetivo y alcance

Crear una adaptación digital de Mistborn Deckbuilder para que el propietario y sus amigos jueguen a distancia. Priorizar una partida correcta y comprensible antes de ampliar contenido o presentación.

Alcance confirmado: competitivo de 2–4, cooperativo de 2–4 y cooperativo en solitario; máximo cuatro personas. El idioma objetivo es español. SRC-001 es el reglamento inglés aportado por el usuario, identificado en `docs/referencias/README.md`; las reglas, páginas y dudas están en esa carpeta. Falta contrastar la localización española y completar el catálogo. Las cartas actuales son ejemplos de prueba, no una transcripción validada del juego de mesa. No inventar reglas ni presentar propuestas como decisiones del usuario.

## Recuperación del contexto

Acceso remoto confirmado: salas privadas sin cuentas y reconexión obligatoria a la misma partida/plaza. No volver a plantearlo como opcional. Transporte, alojamiento, pausa, tiempo de reserva de plaza y pérdida del anfitrión se concretan en sus fases; no se dan por acordados con esta decisión.

Al comenzar una tarea:

1. Leer este archivo y `docs/README.md`.
2. Leer `docs/estado-actual.md` y `docs/plan-de-trabajo.md`.
3. Consultar `docs/decisiones.md` y los documentos del área que se vaya a tocar. Para desarrollo por fases, leer `docs/gestion/desarrollo.md`, la tarea de `docs/gestion/backlog.md` y su especificación en `docs/specs/`. Usar `docs/registro-de-trabajo.md` para recuperar antecedentes cuando sea necesario.
4. Comprobar el código y `git status --short` antes de modificar archivos. La documentación puede quedarse desactualizada; registrar cualquier discrepancia.

No asumir que existe memoria persistente entre conversaciones. Todo acuerdo relevante, incertidumbre o siguiente paso debe quedar en el repositorio. Si falta contexto, explicitarlo y avanzar en lo que no dependa de él.

## Entorno y organización

- Motor: Godot 4.7.2 estable estándar, fijado en `.godot-version`; GDScript y renderizador Compatibility. No cambiar la versión silenciosamente.
- Plataforma inicial: aplicación para Windows; todos los participantes tienen Windows, confirmado el 2026-10-27. Versión mínima y requisitos de hardware pendientes; no volver a preguntar por el sistema operativo del grupo.
- Lenguaje: GDScript; no usar C#.
- `data/`: datos JSON de contenido.
- `scripts/`: lógica GDScript.
- `scenes/`: escenas `.tscn`, cuando se creen.
- `assets/images/`: convención prevista para imágenes nuevas; las rutas de los ejemplos actuales difieren y están pendientes de normalización.
- `docs/`: conocimiento duradero del proyecto.
- `tests/`: pruebas cuando exista lógica que verificar.

Crear carpetas cuando tengan contenido. No añadir dependencias, cambiar de motor o elegir una solución de red solo por comodidad sin documentar la decisión y su motivo.

## Desarrollo

- Usar tipado estático en GDScript siempre que sea posible.
- Variables y funciones en `snake_case`; clases y nodos en `PascalCase`.
- Separar reglas y estado de partida, presentación, carga de contenido y transporte de red. El código actual todavía no implementa esas capas.
- Mantener los identificadores de cartas estables. Cargar rutas visuales desde los datos; no incrustar imágenes en el código.
- Validar entradas y gestionar fallos de carga de archivos e instanciación de nodos con `push_error()` o `push_warning()` según corresponda.
- No interpretar el texto descriptivo de `efecto` como código ejecutable. Documentar un modelo de efectos antes de automatizarlos.
- Para el futuro multijugador, definir quién valida las acciones y qué información recibe cada jugador antes de implementar el transporte. No asumir que un cliente puede decidir el resultado de una acción.
- No introducir reglas caseras silenciosamente. Registrar las discrepancias con el juego y la decisión de adaptación.
- Consultar también SRC-002, FAQ y erratas oficiales, antes de implementar una regla de SRC-001. Las correcciones expresas del editor prevalecen sobre el PDF; conservar fuente y sección. El inventario documental no acredita fidelidad completa ni sustituye pruebas.
- Mantener explícitas las diferencias de preparación, combate, rival y victoria por modo. El motor del rival de solitario/cooperativo pertenece al alcance obligatorio; no se clasifica como una IA opcional. No dar por completado el juego con solo el competitivo.
- Conservar el trabajo existente del usuario y limitar los cambios al alcance de la tarea.

## Verificación

Comandos de desarrollo desde la raíz: `powershell -NoProfile -ExecutionPolicy Bypass -File tools/godot.ps1 -Action test` (importación y pruebas), `-Action run` (pantalla), `-Action editor` (editor) y `-Action preview` (captura real y salida). El motor local vive en `.tools/godot/`, excluido de Git; otra ruta se indica mediante `-GodotPath` o `GODOT_BIN`. Consulta `docs/desarrollo-local.md`.

El trabajo se organiza con SDD ligero: especificar comportamiento y aceptación, planificar, dividir en tareas, implementar y verificar. Las tareas pequeñas pueden usar solo una issue; las entregas complejas usan `spec.md`, `plan.md`, `tasks.md` y `verification.md`. No hay Spec Kit instalado. Los IDs locales Txx.n no son números de GitHub. Consultar `docs/gestion/desarrollo.md` y `docs/calidad.md`.

- Ejecutar comprobaciones proporcionales al cambio y describir el resultado real.
- En documentación: comprobar enlaces locales, coherencia de rutas y distinción entre implementado, propuesto y pendiente.
- En datos: validar JSON, campos, tipos, identificadores únicos y referencias según el contrato documentado.
- En reglas: cubrir con pruebas los turnos, recursos, zonas de cartas y condiciones de victoria relevantes cuando se implementen.
- En red: verificar al menos una partida con dos instancias y el tratamiento de acciones inválidas cuando exista esa funcionalidad.
- No afirmar que se ha probado Godot, una partida o una conexión si no se ha ejecutado. Registrar bloqueos y comprobaciones pendientes.

## Cierre de cada tarea

1. Actualizar `docs/estado-actual.md` si cambia el estado verificable del proyecto.
2. Actualizar tareas y siguiente paso en `docs/plan-de-trabajo.md`.
   Mantener también la tarea del backlog, su enlace a issue cuando exista y la evidencia de la especificación. No marcar una fase como terminada sin cumplir su criterio de salida.
3. Registrar decisiones duraderas en `docs/decisiones.md`, indicando si están aceptadas, propuestas o sustituidas.
4. Actualizar el documento temático afectado en lugar de duplicar la misma información.
5. Añadir a `docs/registro-de-trabajo.md` una entrada breve con fecha, cambios, validaciones y pendientes que permitan retomar el trabajo.
6. Entregar un resumen de cambios y limitaciones. No hacer commit, push o publicación salvo que la tarea lo autorice.

Mantener este archivo breve y estable: contiene instrucciones de trabajo; los detalles cambiantes viven en `docs/`. No guardar secretos, credenciales ni conversaciones completas como memoria.
