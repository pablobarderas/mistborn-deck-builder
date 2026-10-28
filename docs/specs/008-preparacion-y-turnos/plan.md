# Plan de SPEC-008

## T08.1a — Preparación estructural

`game_setup.gd` recibe definiciones verificadas, ID de catálogo, modo, plazas horarias, primer jugador competitivo, manifiesto y semilla. Comprueba forma, cantidades y tipos antes de crear estado. Usa un único RNG local para sorteo y barajados; conserva su estado en `authority`. Construye IDs de instancia locales y zonas por jugador. No hay llamada a `Database`, escena, red ni reloj.

El manifiesto es un contrato de entrada de autoridad, no un archivo de catálogo: `characters` contiene cuatro entradas `{character_id, starters}` con cuatro IDs; `funding_id`; `training_track_id`; `market_cards` con 82 IDs, repetidos según cantidad física; `missions` con ocho IDs distintos; `rival` es null en competitivo o `{definition_id, domination_id, cards}` con 36 IDs en los otros modos. Todas las definiciones referidas exigen estado `verificada` y cantidad positiva; las copias usadas no pueden exceder la cantidad declarada. Al completar el catálogo se construirá desde sus cantidades y relaciones contrastadas. Las pruebas usan definiciones mínimas ficticias marcadas verificadas únicamente como fixture; no aprueban cartas oficiales.

La pista de entrenamiento se registra en cada jugador porque la reanudación desde snapshot no debe depender de una configuración externa desaparecida. Por ello se amplía el esquema P07 y su versión de motor, actualizando fixtures y regresiones. `training=0` representa el primer espacio de la pista; `turn.phase=inicio` impide considerar realizado el avance inicial.

## Trabajo posterior

T08.1b implementará avance de entrenamiento y sus recompensas con pista verificada; después comenzará `libre`. T08.2 implementará acciones/puertas de fase, limpieza, robo y reciclado, incluida la decisión expresa sobre agotamiento total. T08.3 separará preparación/ronda rival y reglas por modo. No abrir el turno saltándose efectos aún no modelados.

## Verificación

Godot 4.7.2: prueba de preparación con siete configuraciones, cantidades, errores y determinismo; regresión de estado y motor. Comprobar ausencia de mutaciones en entrada y estado fallido. Los tests de preparación no son pruebas manuales de interfaz ni validación del catálogo real.
