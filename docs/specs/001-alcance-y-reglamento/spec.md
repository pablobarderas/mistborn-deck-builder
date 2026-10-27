# SPEC-001 — Alcance y reglamento

- Estado: borrador; fuente e inventario inicial completados, decisiones de producto pendientes.
- Fecha de actualización: 2026-10-27.
- Fases: P01 y P02.
- Objetivos: PROD-001 a PROD-009 en [alcance](../../alcance.md).
- Issues GitHub: sin publicar.

## Problema

El usuario quiere un juego bonito y fiel al de mesa para amigos a distancia. El código solo contiene ejemplos; sin identificar reglas, catálogo, participantes y plataformas se corre el riesgo de construir comportamientos incorrectos o una distribución que el grupo no pueda usar.

## Dentro del alcance

Identificar el reglamento español, registrar fuentes y dudas, inventariar las reglas y el contenido relevante, acordar dispositivos, jugadores, modo, catálogo y política inicial de acceso/desconexión. Definir la primera entrega y el subconjunto de prototipo sin confundirlos.

## Fuera del alcance

Implementar una partida, crear imágenes finales, elegir un proveedor de alojamiento sin prueba, instalar Spec Kit o publicar automáticamente documentación e issues.

## Escenarios

- El usuario facilita el reglamento: registrar su identidad y mapear comportamientos a páginas/secciones.
- Una regla es ambigua: abrir una duda con sus consecuencias y bloquear solo lo dependiente.
- Todos los amigos utilizan Windows: orientar la primera exportación a ese sistema y concretar compatibilidad/resoluciones en P03/P05.
- El prototipo omite cartas: identificar ese subconjunto; mantener el catálogo final del alcance por separado.

## Aceptación

- **AC-01:** El reglamento está identificado y accesible mediante SRC con edición/idioma y páginas/secciones.
- **AC-02:** Existe un inventario preliminar de reglas y componentes del material disponible; cada entrada tiene fuente o duda explícita. Tras acordar el modo y catálogo se identifica qué parte pertenece al alcance. No se han convertido los datos de prueba en reglas oficiales.
- **AC-03:** Plataforma, número de jugadores y modo inicial están confirmados; las preguntas Q-001 a Q-004 están resueltas o justificadamente fuera del alcance.
- **AC-04:** Están registrados los requisitos de acceso y la respuesta deseada ante desconexiones (Q-005 y Q-006), distinguiendo necesidad de producto de solución técnica pendiente de P04.
- **AC-05:** El alcance distingue prototipo y entrega fiel, y especifica dispositivos/resoluciones de prueba y cómo se revisará el aspecto visual.

## Avance y bloqueos actuales

SRC-001 recibido y revisado: reglamento inglés de 2024, 1.ª edición/1.ª impresión, 20 páginas. Complementado con SRC-002 (FAQ y erratas oficiales): 75 reglas y siete registros DUD, de los que dos están resueltos y uno parcialmente. El producto sigue siendo español; falta contraste de localización y resolver lo abierto.

Jugadores y modos confirmados: competitivo 2–4, cooperativo 2–4 y solitario cooperativo 1; máximo cuatro humanos. [SPEC-002](../002-modos-y-cooperativo/spec.md) detalla sus comportamientos y pruebas.

Plataforma confirmada: aplicación Windows. Acceso confirmado: salas privadas sin cuentas y reconexión obligatoria a la plaza propia. Pendientes: catálogo/variantes, compatibilidad mínima, resolución/presentación y detalles de pausa/reserva/caída del anfitrión. El tablero 2D sigue como propuesta visual. No repetir preguntas resueltas.

El alcance funcional permite preparar P03; esta especificación sigue parcial hasta cerrar sus demás criterios. El detalle técnico de acceso se concreta en P04/P13 y la reconexión en P15, sin exigirlos para el arranque de Godot.
