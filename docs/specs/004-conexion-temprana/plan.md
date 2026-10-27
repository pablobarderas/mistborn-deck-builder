# Plan de SPEC-004

## Decisión técnica del experimento

Anfitrión como autoridad y ENet/UDP fiable de Godot; sin dependencias ni servicio contratado. Usar MultiplayerPeer directamente con JSON UTF-8, sin deserialización de objetos ni RPC. El cliente pide una operación, nunca envía un estado que la autoridad deba aceptar. La interfaz no contiene decisiones de transporte.

Un Node de sesión es dueño del peer, sondea paquetes, negocia versión/clave/nombre, limita entradas y publica señales. Solo se difunden nombres/IDs y contador; la clave no aparece en snapshots ni logs. El código es un experimento aislado en scripts/network/, no el motor de reglas futuro.

Cada petición de incremento lleva secuencia creciente por conexión. Duplicados y saltos se rechazan. La clave se genera aleatoriamente por sesión. No existe cifrado propio ni servicio de identidad: este ensayo se orienta a red local o enlace privado de confianza; la publicación por Internet exige revisar el transporte final y el alojamiento.

## Alternativas y coste

| Vía | Requisitos | Coste y decisión |
| --- | --- | --- |
| ENet con anfitrión | Ruta UDP hacia el anfitrión; LAN, red privada entre equipos o reenvío de puerto si la red lo permite. | Sin cuota de servicio añadida por el prototipo. Elegido solo para investigar. |
| Servidor dedicado con ENet o WebSocket/TLS | Despliegue, mantenimiento y punto accesible; clientes inician conexión saliente. | Coste depende de proveedor/uso; no se contrata ni presupone gratis. Candidato si el acceso directo es incómodo. |
| WebRTC con señalización/relay | Señalización y posiblemente TURN; dependencias/integración y alojamiento. | Complejidad y posibles costes; no necesario para probar autoridad. |

Un código de sala por sí solo no resuelve NAT ni proporciona un relay. La elección de producto depende de AC-05 y de la facilidad de acceso para el grupo, no de la latencia de un contador.

## Entrega y verificación

1. Implementar sesión separada, pantalla experimental y acceso desde inicio.
2. Añadir prueba con procesos Godot independientes, clave/versiones incorrectas, duplicados, aforo, cierre y timeout.
3. Ejecutar regresión de arranque y captura gráfica de la nueva pantalla.
4. Preparar instrucciones y hoja de evidencia para dos redes. Mantener AC-05 abierto hasta ejecutar esa prueba.
