# Verificación de SPEC-004

Estado: comprobación local realizada el 2026-10-27, Godot 4.7.2.stable.official.ed1daf0bf, Windows. No cerrar P04 con localhost.

| Criterio | Estado |
| --- | --- |
| AC-01, pantalla y navegación | Superado localmente; captura gráfica, botones y navegación real. |
| AC-02, procesos y convergencia | Superado localmente; anfitrión y tres clientes en procesos independientes, contador 4/lista de cuatro; quinto no admitido. |
| AC-03, rechazos y duplicados | Superado localmente; clave, versión, sin admisión, duplicado, operación desconocida, raíz JSON, tamaño y snapshot forjado. |
| AC-04, fallos y cierre | Superado localmente; parámetros, puerto ocupado, timeout de acceso, retirada de participante, fin del anfitrión, liberación de puerto y reintento. |
| AC-05, dos redes y decisión final | Pendiente; requiere equipos externos |
| AC-06, regresión y documentación | Superado; 58 comprobaciones P03, guía y documentos de estado actualizados. |

## Evidencia reproducible

- `-Action test-network`: código 0, marca `P04_NETWORK_OK`, 47 comprobaciones del coordinador y 26 en siete procesos hijo (73 en total). Tres procesos admitidos convergen, siete clientes distintos prueban escenarios. Solo localhost.
- El único error de motor del coordinador es esperado: segundo servidor en puerto ocupado. Logs `tmp/godot/test-network.log` y `tmp/godot/p04-*.log`; los clientes terminan con `P04_CHILD_OK`.
- `-Action preview-network`: código 0, `P04_PREVIEW_OK`, 12 comprobaciones; tres capturas reales en Compatibility/OpenGL 3.3 con NVIDIA GeForce RTX 5060 Ti. Revisadas a 1280×800 y 1024×640; ajustado contraste de Volver/Desconectar y clave. Las capturas son intermedios locales reproducibles, excluidos de Git.
- `-Action test`: código 0, `P03_STARTUP_OK`, 58 comprobaciones; ocho errores de datos esperados.
- Navegación comprobada: inicio → botón Probar conexión → crear → señal → volver → inicio; puerto libre tras volver.
- Confirmación del usuario el 2026-10-27 tras la entrega: «Funciona perfecto». Aceptación del funcionamiento observado del prototipo, sin detalle adicional de pasos ni evidencia de otra red.

## Evidencia externa pendiente

El usuario confirma que solo tiene un PC disponible. No se ha comprobado LAN, NAT, cortafuegos, router, dos redes, exportación ni recuperación de una partida. ENet/anfitrión es la elección del experimento, no la decisión final de alojamiento.

Seguir [la guía](../../prueba-de-conexion.md) y registrar aquí la prueba externa. P05 puede continuar por separado mientras T04.2 permanece abierta.
