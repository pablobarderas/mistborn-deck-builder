# Verificación

28 de noviembre de 2026. Base publicada y local `550fb98adbec88121485fcda2e23e33de15fbb0c` en `main`. Riesgo R3. Sin issue ni dispensas.

| Criterio | Evidencia | Resultado |
| --- | --- | --- |
| CV-01 | `preview-wind-cartographers` abrió la mesa desde el menú, eligió 2, 3 y 4 plazas y recorrió doce turnos de una partida de dos plazas con compras, etapas, resultado, reinicio y regreso al menú. | 203 comprobaciones de pantalla, código 0. |
| CV-02 | `test-wind-cartographers` completó mesas de 2, 3 y 4 con seis turnos por plaza. Comprobó reciclado, conservación, pagos, límites, seis compras de una oferta y rechazo atómico de la séptima, puntuación, ganador y empate. | 635 comprobaciones del motor, código 0. |
| CV-03 | Casos de catálogo válido e inválido en la prueba del motor. En el recorrido gráfico se comprobó que no hay controles de mano durante el relevo y se confirmó una entrega mediante Intro. Se guardaron cinco PNG `tmp/screenshots/wind-*.png` con render real de 1280×800 y 1024×640. | Catálogo, relevo, foco y resoluciones comprobados. |
| Regresiones | `test` y `test-engine` en Godot 4.7.2. El arranque incluye ocho errores de datos inducidos cuya gestión verifica la propia suite. | 58 y 102 comprobaciones, código 0. |

Los logs locales de las ejecuciones están en `tmp/godot/wind-wrapper-*.log`. Las capturas cubren preparación, relevo, turno, vista compacta y resultado.

## Revisiones y traspaso

- `sdd_rules` (GPT-6.1 Sol, alto) contrastó la coherencia del contrato original. El contrato explicita el pago, la intercalación de acciones y el límite de cada ruta. Su fuente es la especificación de este prototipo.
- `sdd_developer` (GPT-6.1 Sol, medio) implementó y verificó motor, catálogo y suite. El coordinador se ocupó de la interfaz, el inicio y el lanzador. Se ejecutó Godot en serie para compartir caché y logs.
- `sdd_reviewer` (GPT-6.1 Sol, alto) revisó CV-01–03 y la evidencia, con dictamen favorable. Sugirió cubrir la compra real de seis copias y el rechazo atómico de la séptima, incorporados a la suite.
- `sdd_visual` (GPT-6.1 Terra, medio) revisó las cinco capturas. Dictamen favorable a ambas resoluciones. La pantalla muestra la mano, oferta y rutas sin recortes. El relevo mantiene visible el foco y oculta la mano. La prueba gráfica confirma Intro en el relevo.

Se reutilizaron las ejecuciones, capturas y logs en las revisiones. Los reensayos se limitaron a las suites modificadas tras ampliar la cobertura y se conservaron las regresiones de arranque y motor. Sin métricas de consumo. Los controles de reglas, catálogo, estado y presentación se aplicaron al prototipo local. Red, persistencia, distribución y cooperativo quedan fuera de esta tarea.

CV-01–03 completados. La próxima comprobación propuesta es una partida humana para valorar balance y duración. El prototipo se abre desde **Jugar a Cartógrafos del Viento** en el menú del proyecto.
