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

> Lee AGENTS.md y sigue su orden de recuperación de contexto. P03 está completada y verificada; continuamos con P04, especificación y prueba temprana de conexión entre redes. Conserva los acuerdos de Windows, español, máximo cuatro jugadores, competitivo, cooperativo y solitario, salas privadas sin cuentas y reconexión. Revisa el estado real antes de implementar y no cierres P04 solo con pruebas en localhost.

## Preparar el motor

Seguir [desarrollo local](desarrollo-local.md): descargar Godot 4.7.2 estable estándar para Windows y descomprimirlo en `.tools/godot/`, o indicar el ejecutable con `-GodotPath`.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/godot.ps1 -Action test
powershell -NoProfile -ExecutionPolicy Bypass -File tools/godot.ps1 -Action run
```

La prueba debe devolver `P03_STARTUP_OK` con 58 comprobaciones y código 0. Los ocho fallos marcados como esperados verifican la recuperación ante datos inválidos.

## Qué se conserva

Código, escenas, recursos propios, pruebas, herramientas, especificaciones, fases, decisiones, dudas de reglas y el [reglamento original](referencias/fuentes/MistbornRulebook_V1.pdf) están versionados. No hace falta copiar archivos del PC original para retomar el desarrollo.

Godot, cachés, logs y capturas temporales no se versionan; se instalan o regeneran con los comandos anteriores. La evidencia textual de P03 está en su [verificación](specs/003-arranque-godot/verification.md). No existe todavía una partida jugable, ni red, ni un ejecutable exportado para los amigos.
