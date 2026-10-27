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

> Lee AGENTS.md y sigue su orden de recuperación de contexto. P03/P05 y el contrato inicial P06 están completados; P04 tiene T04.1 verificada localmente y T04.2 pendiente de otro equipo y prueba entre redes. Próximo trabajo: especificar P07 y preparar sus partes locales independientes, conservando la dependencia P04 para su cierre. El usuario tiene Android; cartas oficiales aún pendientes, no copiar valores de muestras como verificados. Conserva Windows, español, máximo cuatro jugadores, competitivo, cooperativo y solitario, salas privadas sin cuentas y reconexión. Revisa el estado real y no cierres P04 con localhost.

## Preparar el motor

Seguir [desarrollo local](desarrollo-local.md): descargar Godot 4.7.2 estable estándar para Windows y descomprimirlo en `.tools/godot/`, o indicar el ejecutable con `-GodotPath`.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/godot.ps1 -Action test
powershell -NoProfile -ExecutionPolicy Bypass -File tools/godot.ps1 -Action run
```

La prueba debe devolver `P03_STARTUP_OK` con 58 comprobaciones y código 0. Los ocho fallos marcados como esperados verifican la recuperación ante datos inválidos.

## Qué se conserva

Código, escenas, recursos propios, pruebas, herramientas, especificaciones, fases, decisiones, dudas de reglas y el [reglamento original](referencias/fuentes/MistbornRulebook_V1.pdf) están versionados. No hace falta copiar archivos del PC original para retomar el desarrollo.

Godot, cachés, logs y capturas temporales no se versionan; se instalan o regeneran con los comandos anteriores. La evidencia textual de P03 está en su [verificación](specs/003-arranque-godot/verification.md). Las entregas publicadas incluyen ensayo local de red, maqueta, ilustraciones y contrato inicial de catálogo P06, con fuentes y documentación de continuidad. Todavía no hay partida jugable ni ejecutable exportado para los amigos. Comprobar git status e historial antes de continuar.
