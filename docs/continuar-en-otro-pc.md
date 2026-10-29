# Continuar en otro PC con Codex

## Recuperar el proyecto

Con Git instalado y acceso al repositorio:

```powershell
git clone https://github.com/pablobarderas/mistborn-deck-builder.git
cd mistborn-deck-builder
git status --short
```

Si ya existe un clon, revisar primero sus cambios locales y, con el árbol limpio y en main, ejecutar `git pull --ff-only`.

Abrir esta carpeta como proyecto en Codex. No hace falta reproducir la carpeta contenedora del PC original. El repositorio conserva el contexto de trabajo; no incluye una copia del historial del chat. Se puede continuar desde una conversación nueva con este mensaje:

El [sistema de agentes SDD](gestion/agentes-sdd.md) y sus perfiles `.codex/` también viajan con el repositorio. Usar un cliente compatible, comprobar los modelos disponibles y abrir sesión nueva si no recarga perfiles. El documento explica la alternativa por instrucciones cuando la herramienta de delegación no selecciona roles nativos; no hace falta instalar un SDK ni una API propia.

Aplicar esta metodología obligatoriamente al retomar: registrar riesgo/AC/plan antes de editar y cumplir los controles de revisión y cierre. Solo una dispensa humana explícita, con alcance/vigencia registrados, puede eximir un requisito; cambiar de equipo, cliente o chat no suspende el método. La ausencia de herramientas deja pendiente el control dependiente, no autoriza sustituir revisión independiente por auto-revisión.

> Lee AGENTS.md y sigue su orden de recuperación de contexto. T07.1/2 y T08.1a están implementadas y verificadas localmente; P07 sigue abierta porque P04 necesita prueba entre redes con otro equipo. P08 tiene SPEC-008: la preparación estructural está hecha, pero no hay entrenamiento ni turnos completos. El usuario deja pendientes por ahora las fotos del material español y DUD-004/005/006; no inventes respuestas ni vuelvas a pedirlas al empezar. Sin ese material, continúa con la parte confirmada de T08.2 (ciclo del mazo y descarte) y conserva DUD-006 para agotamiento total. El catálogo actual tiene dos muestras y cero cartas oficiales verificadas. Conserva Windows, español, máximo cuatro jugadores, competitivo, cooperativo y solitario, salas privadas sin cuentas y reconexión obligatoria. Revisa Git y los documentos de estado antes de editar.

## Cambiar de sesión o retomar una tarea

Usar [sesiones y traspaso](gestion/agentes-sdd.md#sesiones-y-traspaso): un objetivo verificable por chat principal, con todo su ciclo SDD. Antes de cambiar a otro objetivo, guardar cierre/traspaso y enlazarlo desde estado/plan; conservar tareas interrumpidas como en curso o bloqueadas. Puede retomarse el mismo chat mientras siga siendo la misma tarea. La regla no autoriza por sí sola crear chats ni publicar cambios.

Mensaje breve reutilizable para un chat nuevo:

> Lee AGENTS.md y recupera el contexto obligatorio. El objetivo de esta sesión es [ID y resultado verificable]. Consulta el traspaso en [ruta de tarea/verification.md y sección], contrástalo con el estado actual, Git y código antes de editar. Conserva decisiones, bloqueos y cambios ajenos; aplica agentes/revisión según riesgo. Completa los pasos relacionados de ese objetivo y deja cierre o traspaso con evidencia y siguiente paso. No presupongas permiso para commit/push ni para crear otros chats.

Al cambiar también de equipo, indicar qué evidencia/artefactos solo existen en el PC anterior y cómo reproducirlos. Antes de cualquier `git pull`, revisar archivos locales. Los chats en el mismo directorio pueden compartir cambios; no confundir conversación independiente con checkout aislado.

## Preparar el motor

Seguir [desarrollo local](desarrollo-local.md): descargar Godot 4.7.2 estable estándar para Windows y descomprimirlo en `.tools/godot/`, o indicar el ejecutable con `-GodotPath`.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/godot.ps1 -Action test
powershell -NoProfile -ExecutionPolicy Bypass -File tools/godot.ps1 -Action run
```

La prueba de arranque debe devolver `P03_STARTUP_OK` con 58 comprobaciones y código 0. Para comprobar el último avance local, ejecutar también `-Action test-setup` (147 comprobaciones). Los ocho fallos de carga marcados como esperados verifican la recuperación ante datos inválidos.

## Qué se conserva

Código, escenas, recursos propios, pruebas, herramientas, especificaciones, fases, decisiones, dudas de reglas y el [reglamento original](referencias/fuentes/MistbornRulebook_V1.pdf) están versionados. No hace falta copiar archivos del PC original para retomar el desarrollo.

Godot, cachés, logs y capturas temporales no se versionan; se instalan o regeneran con los comandos anteriores. La evidencia de P08 está en su [verificación](specs/008-preparacion-y-turnos/verification.md). Las entregas publicadas incluyen ensayo local de red, maqueta, ilustraciones, contrato inicial de catálogo y preparación estructural. Todavía no hay partida jugable ni ejecutable exportado para los amigos. Comprobar git status e historial antes de continuar. Los antiguos cambios locales de `project.godot` y dos `.import` se revisaron y descartaron el 2026-10-29; el árbol quedó limpio.
