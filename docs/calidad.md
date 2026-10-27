# Calidad y criterios de entrega

Esta lista define qué evidencia recoger. No acredita pruebas ya realizadas. Los valores concretos de rendimiento, resoluciones y dispositivos se fijarán en P02/P05 tras conocer el grupo.

| Área | Criterio de aceptación | Evidencia prevista |
| --- | --- | --- |
| Reglas | Cada regla del alcance se vincula a fuente, comportamiento y prueba; no hay discrepancias que cambien resultados. | Matriz REG y escenarios reproducibles. |
| Modos y jugadores | Competitivo 2/3/4, cooperativo 2/3/4 y solitario 1 funcionan con preparación y finales propios. | Siete configuraciones con evidencia; SPEC-002. |
| Rival cooperativo | Mazo, salud, Dominación, escudos, edictos y efectos colectivos se resuelven en orden y por una sola autoridad. | Casos de SPEC-002 y cartas/pistas completas del catálogo. |
| Catálogo | Todas las cartas y cantidades del alcance están inventariadas; efectos y excepciones tienen cobertura. | Inventario, validación de datos y pruebas de interacciones. |
| Estado | Un rechazo no altera la partida; instancias y zonas conservan sus invariantes. | Pruebas de transiciones válidas e inválidas. |
| Aleatoriedad | Mismos datos y semilla producen la secuencia esperada en pruebas; el resultado real lo decide la autoridad. | Pruebas reproducibles sin exponer estado privado a clientes. |
| Red | Los participantes ven el mismo estado público y sus vistas privadas correctas; una acción no se aplica dos veces. | Partida multiinstancia y fallos inyectados. |
| Privacidad de partida | Manos/mazos ocultos según reglas no se envían a rivales; ocultarlos visualmente no basta. | Inspección de payloads y registros de prueba. |
| Desconexión | Cada fallo tiene la respuesta acordada, sin corrupción ni espera infinita sin salida. | Corte de red, abandono y pérdida de autoridad. |
| Presentación | Cartas ampliables, textos legibles y acciones disponibles/pendientes claras en las resoluciones objetivo. | Capturas y recorrido de todos los flujos, incluidos casos saturados. |
| Animaciones | No alteran reglas, duplican acciones ni bloquean la interacción; efectos ambientales preservan lectura. | Partida real y revisión visual. |
| Acceso | Un amigo puede instalar/abrir, entrar y jugar siguiendo las instrucciones. | Prueba desde equipo limpio y red distinta. |
| Rendimiento | Se cumplen los objetivos fijados para los equipos admitidos. | Medición de tiempos de carga, respuesta y fluidez en esos equipos. |
| Distribución | Versión del juego, reglas y catálogo compatibles; errores de versión comprensibles. | Exportación desde copia limpia y prueba de incompatibilidad. |

## Estrategia progresiva

- P03: arranque comprobado y un mecanismo reproducible para ejecutar comprobaciones.
- P06–P09: pruebas pequeñas del catálogo y del motor, sin depender de la interfaz para comprobar reglas.
- P10: recorridos competitivos y solo/cooperativos con subconjunto, datos y semilla de prueba identificados.
- P11: matriz de cobertura e interacciones de cartas; incluir comportamientos de borde, no solo ejemplos felices.
- P13–P15: pruebas de protocolo, duplicados, identidad, información privada y desconexión.
- P16: siete configuraciones de modo/jugadores; grupo en dispositivos y redes reales, solitario en una instancia. Una prueba multijugador en un único equipo no sustituye evidencia externa.
- P17–P18: revisión visual, exportación y acceso desde copia limpia.

Elegir herramienta de pruebas y CI cuando se fije Godot. No instalar un framework ni crear un workflow que aparenten comprobar reglas inexistentes.

## Registro de verificación

Para cada criterio: entorno/versiones, escenario, datos/semilla si aplica, comando o pasos, resultado observado, aprobado/fallido/no ejecutado e incidencia relacionada. Guardar la evidencia en verification.md de la especificación o en la issue para tareas pequeñas. No almacenar secretos ni manos privadas reales en registros compartidos.

Una fase se cierra con sus evidencias. La entrega final requiere P11, P14–P18 y los criterios anteriores satisfechos para el alcance acordado.
