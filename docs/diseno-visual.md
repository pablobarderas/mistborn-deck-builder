# Dirección visual y maqueta de P05

Propuesta implementada el 2026-10-27 y aceptada como dirección visual inicial: el usuario confirma que las cartas se ven bien y pide commit/push. Petición: diseño limpio, moderno y bonito con colores concordantes con el reglamento. Arte/contenido definitivos siguen pendientes.

## Referencia y paleta

SRC-001 se ha revisado de nuevo mediante render de portada y páginas 4, 12 y 18. La portada aporta azul noche, bruma plateada y luz cálida; los tableros/cartas aportan grafito y colores de metales. La interfaz adapta esos rasgos con superficies planas, líneas finas, poco adorno y contraste de lectura. No intenta medir exactamente la tinta del PDF ni copiar sus marcos ornamentales.

| Uso | Color | Motivo |
| --- | --- | --- |
| Fondo | `#101923` | Azul noche de la ambientación. |
| Superficie | `#182430` | Grafito azulado para agrupar contenido. |
| Superficie elevada | `#20303e` | Hover y controles. |
| Línea | `#354654` | Separación discreta. |
| Texto principal | `#eeeae1` | Marfil suave. |
| Texto secundario | `#a7b5c1` | Plata/gris de la bruma. |
| Acción y selección | `#d4b77a` | Oro/latón cálido, reservado para acentos. |
| Foco frío | `#9cc8e4` | Azul plata. |
| Peltre / estaño | `#ce8894` / `#d67b84` | Rojos adaptados para leer sobre fondo oscuro. |
| Bronce / cobre | `#68b6a1` / `#d69b72` | Verde metálico y cobre. |
| Zinc / latón | `#d5d1b9` / `#d4b77a` | Marfil metálico y dorado. |
| Hierro / acero | `#75b7dd` / `#d5e4ee` | Azul y plata. |

Contraste calculado contra la superficie: texto principal 13,11:1, secundario 7,51:1; los ocho colores de metal superan 4,5:1. El rojo se aclaró tras revisión. Los estados también se identifican con nombres, punto activo, borde o texto; el color no es la única pista. Esto no equivale a una auditoría completa de accesibilidad.

## Jerarquía y espacio

Georgia/Cambria para marca y títulos; Segoe UI para controles y contenido. Texto de cartas pequeñas a 14 px, metadatos auxiliares a 11–13 px; descripción ampliada a 17 px. Los efectos oficiales futuros deben leerse en el detalle y revisarse con textos reales largos. No considerar la maqueta una validación del catálogo completo.

Margen exterior 22 px, separación de zonas 10–22 px, tarjetas con esquinas de 8–10 px. Sin textura detrás del texto ni animación ambiental. La ilustración se concentra en cartas y personaje; la mesa queda tranquila para reconocer zonas y acciones.

Distribución: participantes y tres misiones a la izquierda; mercado de seis cartas arriba; zona jugada y metales en el centro; mano, recursos y controles de demostración abajo. Los detalles aparecen en un panel centrado con fondo atenuado.

## Abrir e interactuar

Desde el inicio, pulsar **Ver tablero**, o ejecutar desde la raíz:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/godot.ps1 -Action board
```

- Pulsar carta o enfocarla con Tab y activarla: abre su detalle.
- **Cerrar**, Escape o pulsar el fondo exterior: vuelve a la mesa.
- En una carta de mano, **Llevar a mi mesa · demo** la mueve visualmente a la zona jugada. Una carta del mercado solo se consulta.
- Los metales alternan su estado visual; no consumen recursos ni ejecutan reglas.
- **Más cartas** alterna cinco/diez cartas; el desplazamiento horizontal permite llegar a todas.
- **Restablecer** recupera la muestra inicial; **Volver** regresa al inicio.

El panel ampliado captura el foco del teclado y lo devuelve al cerrar. Hover, foco, selección, activación y acción deshabilitada tienen estados diferenciados.

## Resoluciones de la propuesta

- 1280×800: referencia de revisión, mesa completa sin reducir la tipografía.
- 1920×1080: cartas de mercado y mano mayores y más espacio para zona jugada.
- 1024×640: ventana compacta admitida para el prototipo; desplazamiento vertical de la página y horizontal de mano cuando sea necesario. La carta ampliada cabe completa. No es aún un requisito final de compatibilidad.

La escena usa píxeles de interfaz reales y adapta sus contenedores; restaura el escalado de la ventana al volver al inicio. No cambia project.godot para el resto de pantallas. No se ha validado DPI de Windows, varios monitores o escalado del sistema distinto de este entorno.

## Contenido y evidencia

Todos los nombres, costes, recursos, pistas y efectos de esta escena son muestras locales de interfaz, aunque algunos nombres correspondan al universo. No forman un estado de partida válido ni un catálogo oficial. No se modifica `data/cartas.json`. Los símbolos de las misiones/estados son marcadores de interfaz, no símbolos alománticos oficiales.

[Atlas de ilustraciones](../assets/images/board/concept-atlas.png), generado mediante la herramienta integrada; [procedencia y prompt final](../assets/images/board/README.md). Los cuatro motivos se reutilizan en esta propuesta. El arte y la traducción oficial quedan pendientes de su fase de contenido.

Comando de verificación/captura: `-Action preview-board`. Evidencia, incidencias resueltas y limitaciones en [SPEC-005](specs/005-maqueta-tablero/verification.md). P05 se cierra en su alcance de maqueta con la confirmación visual del usuario; la base se podrá ajustar al integrar contenido real.
