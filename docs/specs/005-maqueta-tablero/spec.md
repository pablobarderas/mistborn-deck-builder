# SPEC-005 — Dirección visual y maqueta del tablero

Estado: completada en su alcance de maqueta; verificada técnicamente y aceptada como dirección visual inicial el 2026-10-27. El usuario confirma que las cartas se ven bien y autoriza commit/push. P05, T05.1/2. El contenido y arte final siguen pendientes.

## Objetivo

Crear una maqueta interactiva del tablero, limpia, moderna y bonita, con colores concordantes con SRC-001. El usuario encarga esta dirección visual el 2026-10-27. P04 no bloquea este trabajo: falta su ensayo entre redes.

## Alcance

Tablero de muestra con mercado, misiones, participantes, metales, recursos, mano y zona jugada. Cartas ampliables, foco de teclado, selección clara y desplazamiento cuando falte espacio. Ilustraciones provisionales propias; no transcribir textos oficiales ni presentar efectos inventados como reglas del juego. El contenido debe identificarse como muestra.

Seleccionar una carta abre su detalle; cerrar recupera la mesa. La demostración de selección/juego visual mueve una carta de la mano a una zona de mesa sin aplicar efectos, gastar recursos ni simular un turno válido. Debe ser reversible. El botón Volver regresa al inicio.

## Aceptación

- AC-01: entrada desde inicio y acción de lanzador; maqueta sin dependencias de red ni cambios en cartas.json.
- AC-02: composición muestra mercado, tres misiones, cuatro participantes, mano, ocho metales, recursos y zona jugada; diferencia visual entre zonas.
- AC-03: carta ampliada legible, cierre por botón/Escape, foco y selección; interacción de muestra reversible con estados habilitado/deshabilitado coherentes.
- AC-04: paleta documentada según portada/páginas 4/12/18 del PDF: azul noche, grafito, plata, marfil y acentos de metales. Tipografía y espaciado consistentes, sin ruido ornamental.
- AC-05: capturas reales y revisión en 1280×800, 1920×1080 y ventana 1024×640; acceder a todo mediante desplazamiento si es necesario. Escena saturada con diez cartas de mano. Tamaños legibles definidos y limitaciones explícitas.
- AC-06: pruebas proporcionales de navegación/interacciones y regresión de arranque; documentos actualizados. T05.2/P05 solo se cierran tras revisión de esta propuesta por el usuario.

## Fuentes

SRC-001, portada y páginas 4, 12 y 18, revisadas visualmente de nuevo. La paleta de interfaz es una adaptación, no una medición exacta de tinta ni una reproducción de símbolos del juego. Falta verificar terminología española de cartas y componentes; los textos de muestra lo indican.
