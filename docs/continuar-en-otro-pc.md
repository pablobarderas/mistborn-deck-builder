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

> Lee AGENTS.md y sigue su orden de recuperación de contexto. T07.1/2 y T08.1a están implementadas y verificadas localmente; P07 sigue abierta porque P04 necesita prueba entre redes con otro equipo. P08 tiene SPEC-008: la preparación estructural está hecha, pero no hay entrenamiento ni turnos completos. El usuario deja pendientes por ahora las fotos del material español y DUD-004/005/006; no inventes respuestas ni vuelvas a pedirlas al empezar. Sin ese material, continúa con la parte confirmada de T08.2 (ciclo del mazo y descarte) y conserva DUD-006 para agotamiento total. El catálogo actual tiene dos muestras y cero cartas oficiales verificadas. Conserva Windows, español, máximo cuatro jugadores, competitivo, cooperativo y solitario, salas privadas sin cuentas y reconexión obligatoria. Revisa Git y los documentos de estado antes de editar.

## Preparar el motor

Seguir [desarrollo local](desarrollo-local.md): descargar Godot 4.7.2 estable estándar para Windows y descomprimirlo en `.tools/godot/`, o indicar el ejecutable con `-GodotPath`.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/godot.ps1 -Action test
powershell -NoProfile -ExecutionPolicy Bypass -File tools/godot.ps1 -Action run
```

La prueba de arranque debe devolver `P03_STARTUP_OK` con 58 comprobaciones y código 0. Para comprobar el último avance local, ejecutar también `-Action test-setup` (147 comprobaciones). Los ocho fallos de carga marcados como esperados verifican la recuperación ante datos inválidos.

## Qué se conserva

Código, escenas, recursos propios, pruebas, herramientas, especificaciones, fases, decisiones, dudas de reglas y el [reglamento original](referencias/fuentes/MistbornRulebook_V1.pdf) están versionados. No hace falta copiar archivos del PC original para retomar el desarrollo.

Godot, cachés, logs y capturas temporales no se versionan; se instalan o regeneran con los comandos anteriores. La evidencia de P08 está en su [verificación](specs/008-preparacion-y-turnos/verification.md). Las entregas publicadas incluyen ensayo local de red, maqueta, ilustraciones, contrato inicial de catálogo y preparación estructural. Todavía no hay partida jugable ni ejecutable exportado para los amigos. Comprobar git status e historial antes de continuar. En el PC original permanecen cambios locales previos de `project.godot` y dos `.import` ajenos a T07/T08; no están en Git ni deben suponerse disponibles en otro clon.
