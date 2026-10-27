# Verificación de SPEC-005

Estado: verificada técnicamente el 2026-10-27 en Windows, Godot 4.7.2.stable.official.ed1daf0bf, Compatibility/OpenGL 3.3, NVIDIA GeForce RTX 5060 Ti. Aceptada como dirección visual inicial por el usuario el mismo día: «haz commit y push, se ven bien las cartas si».

| Criterio | Evidencia |
| --- | --- |
| AC-01 | Superado; navegación real desde inicio, escena/lanzador propios. Catálogo intacto. |
| AC-02 | Superado para la propuesta; mercado, participantes, misiones, mano, metales, recursos y zona jugada revisados en captura. |
| AC-03 | Superado; selección, foco modal, Escape/cierre, colocación reversible, rechazo de doble activación y reinicio. |
| AC-04 | Implementado; paleta y tipografía en dirección visual. PDF revisado visualmente; rojo aclarado para contraste. |
| AC-05 | Superado en este entorno; seis capturas, tres resoluciones, diez cartas y desplazamiento hasta zona inferior/última carta. |
| AC-06 | Superado en alcance de maqueta: pruebas/documentos y confirmación visual del usuario; P05 cerrada como dirección inicial. |

## Ejecución real

- `powershell -NoProfile -ExecutionPolicy Bypass -File tools/godot.ps1 -Action preview-board`: código 0, `P05_BOARD_OK`, 39 comprobaciones y seis capturas. No se ejecuta con --headless porque comprueba render real.
- `-Action test`: código 0, 58 comprobaciones de arranque; ocho errores de datos esperados.
- `-Action preview`: código 0; inicio revisado con Ver tablero y Probar conexión. No se modifica la lógica del transporte de P04 ni se repite la prueba entre procesos sin necesidad.
- Ilustraciones generadas mediante herramienta integrada y guardadas dentro del proyecto. Prompt/procedencia en assets/images/board/README.md; estilos, tipografías, marco y texto se construyen con Godot.

## Capturas

Intermedios locales reproducibles en tmp/screenshots/ (excluidos de Git):

- board-1280.png: composición completa de referencia.
- board-detail.png: carta de mano ampliada y acción visual.
- board-1024-ten-cards.png: mano saturada y ventana compacta.
- board-1024-bottom.png: parte inferior accesible por desplazamiento.
- board-1024-detail.png: detalle completo en ventana compacta.
- board-1920.png: composición y cartas adaptadas a ventana grande.

## Ajustes tras revisar

Se corrigió el recalculo de ancho al redimensionar: debe observar el contenedor ya distribuido, no el ancho anterior del frame. Se redondeó el ancho hacia abajo para que seis cartas no excedan la fila por unos píxeles ni generen barras innecesarias. Una comprobación de mercado visible detectó el segundo caso y pasó tras corregirlo. Se aclaró el rojo de peltre para superar contraste 4,5:1 sobre superficie.

Se revisaron también mano vacía, IDs únicos con diez cartas, restauración de escalado al volver y catálogo sin modificaciones. El foco modal evita navegar a botones de fondo mientras está abierto.

## Límites y continuación

Propuesta visual con datos, entrenamiento, misiones, costes y efectos de muestra. No se verifican reglas ni estado legal. No incluye diseño de tablero cooperativo/solitario completo, textos oficiales largos, accesibilidad integral, DPI múltiples ni rendimiento de todos los equipos.

El usuario aprueba la presentación de las cartas y pide publicar la entrega. Se conserva como base visual de P05; no es aprobación del catálogo/arte definitivo. Siguiente fase independiente: P06, contrato del catálogo. La [dirección visual](../../diseno-visual.md) permite mantener o ajustar esta base durante el desarrollo.
