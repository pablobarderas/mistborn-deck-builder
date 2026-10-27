# SPEC-004 — Prueba temprana de conexión

Estado: implementación local verificada; cierre externo pendiente. Fase P04; tareas T04.1/2.

## Objetivo y límites

Demostrar transporte y autoridad antes de construir las reglas. Un anfitrión Windows admite hasta tres invitados sin cuentas. Cada participante tiene nombre y una conexión; el anfitrión valida solicitudes y publica un contador y la lista de participantes. La pantalla identifica claramente el carácter de prueba.

La invitación experimental necesita dirección, puerto y clave temporal compartida. No es todavía el código corto del producto. Volver a entrar crea una conexión nueva: recuperación de plaza/partida pertenece a P15. No hay estado de juego ni información privada de cartas. Al cerrar el anfitrión termina la prueba; no se inventan migración, pausa o reservas.

## Escenarios y aceptación

- AC-01: pantalla accesible desde el inicio, permite crear, unirse, enviar señal, desconectar y volver; mantiene el estilo existente y diagnósticos en español.
- AC-02: anfitrión y dos procesos cliente intercambian paquetes reales y convergen en lista/contador. El anfitrión es la única autoridad; el límite es cuatro personas incluyendo anfitrión.
- AC-03: rechazar clave incorrecta, versión incompatible y acciones inválidas. Una solicitud repetida no incrementa dos veces; una solicitud no autenticada no cambia estado. Validar formato/tamaño y limitar trabajo de paquetes por frame.
- AC-04: puerto ocupado, dirección/puerto/nombre inválidos y ausencia/pérdida del anfitrión producen salida diagnosticable; cerrar libera recursos y permite reintentar. Tiempo límite de acceso de 10 segundos.
- AC-05: documentar conexión entre redes, alternativas de transporte/alojamiento y requisitos; registrar evidencia de una prueba externa con dos equipos antes de cerrar P04. Localhost solo acredita AC-02/03/04 en este entorno.
- AC-06: pruebas de P03 siguen pasando; comandos reproducibles y estado/backlog actualizados sin afirmar multijugador final.

## Fuentes técnicas

Documentación oficial consultada el 2026-10-27: [multijugador](https://docs.godotengine.org/en/stable/tutorials/networking/high_level_multiplayer.html), [ENetMultiplayerPeer](https://docs.godotengine.org/en/stable/classes/class_enetmultiplayerpeer.html) y [MultiplayerPeer](https://docs.godotengine.org/en/stable/classes/class_multiplayerpeer.html). La referencia estable se contrasta ejecutando las API con Godot 4.7.2 fijado.
