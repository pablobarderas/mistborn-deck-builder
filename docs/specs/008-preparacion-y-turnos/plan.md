# Plan de SPEC-008

## Encargo activo 2026-10-29 — T08.2a, ciclo personal de cartas

Reanudación autorizada por «vamos a continuar con el desarrollo». Git inicial limpio, `main`, HEAD `7b75181`. Objetivo verificable: operaciones internas de autoridad para robo con reciclado y descarte personal, con limpieza exclusivamente de cartas. Riesgo R2: modifica zonas privadas y RNG y aplica REG-009/010/025. No incluye finalización completa de turno, entrenamiento, recursos/metales, efectos, rival ni resolución de DUD-006; T08.2 permanece agrupador abierto.

Plan y propietarios: coordinador especifica e integra y es único escritor de documentación; `sdd_rules` contrasta SRC-001/002 antes del código; un desarrollador será propietario exclusivo del módulo de ciclo, sus pruebas y el comando de ejecución; `sdd_reviewer` revisará el diff final independientemente. Sin delegación descendente ni dispensas. No se requiere revisión visual: API sin escena ni presentación. Pruebas Godot en serie por el coordinador, versión 4.7.2 encontrada en Downloads mediante `-GodotPath`; la ruta portátil documentada no existe en este clon.

Verificación prevista: orden de robo, reciclado solo ante necesidad, determinismo y conservación RNG, identidad/cantidad/propiedad, aliados persistentes, agotamiento sin mutación parcial ni RNG consumido, siete configuraciones, validador de estado y regresiones de preparación/motor/estado. Comprobar enlaces y diff y conservar revisión/hallazgos/traspaso en verification.md. Ningún permiso de commit/push de entregas anteriores se extiende a ésta.

Contrato técnico: `card_cycle.gd` se construye con definiciones y catálogo; `draw(snapshot, player_id, count, rng)`, `discard(snapshot, player_id, instance_ids)` y `cleanup_cards(snapshot, player_id)` devuelven `{ok, codigo}` sin identidades privadas. Cada operación valida y prepara una copia antes de aceptar cambios. `draw` copia el RNG recibido y solo avanza el original en éxito; no persiste `authority.rng_state`: el commit de `GameEngine` lo hace. Un llamador directo debe persistir ese RNG al guardar. Componer limpieza y robo requiere la transacción exterior P07 para que un fallo posterior también deshaga la limpieza.

Convenciones técnicas reproducibles, no reglas impresas: parte superior al final del array, Fisher–Yates descendente con RNG explícito, descarte explícito en orden de selección, limpieza primero mano y después no aliados en el orden de juego. No cambia esquema ni versión del snapshot al añadir este servicio sin registro de acciones de producto. Se prefiere un servicio personal a generalizar el reciclado: mercado y rival tienen reglas diferentes.

Contraste previo `rules_deck` (perfil nativo `sdd_rules`, Sol/high): SRC-001 pp.6 (Deckbuilding 5–7), 17 (Turn Structure 5–6), 19–20 y SRC-002 FAQ oficial consultada 2026-10-29. Confirma REG-009/010/025 y límites REG-055/056/068; no encuentra aclaración expresa de DUD-006. Aliados en mano sí se descartan; solo los ya en juego permanecen. Ninguna interpretación de agotamiento ni excepción de carta sin contenido verificado.

## T08.1a — Preparación estructural

`game_setup.gd` recibe definiciones verificadas, ID de catálogo, modo, plazas horarias, primer jugador competitivo, manifiesto y semilla. Comprueba forma, cantidades y tipos antes de crear estado. Usa un único RNG local para sorteo y barajados; conserva su estado en `authority`. Construye IDs de instancia locales y zonas por jugador. No hay llamada a `Database`, escena, red ni reloj.

El manifiesto es un contrato de entrada de autoridad, no un archivo de catálogo: `characters` contiene cuatro entradas `{character_id, starters}` con cuatro IDs; `funding_id`; `training_track_id`; `market_cards` con 82 IDs, repetidos según cantidad física; `missions` con ocho IDs distintos; `rival` es null en competitivo o `{definition_id, domination_id, cards}` con 36 IDs en los otros modos. Todas las definiciones referidas exigen estado `verificada` y cantidad positiva; las copias usadas no pueden exceder la cantidad declarada. Al completar el catálogo se construirá desde sus cantidades y relaciones contrastadas. Las pruebas usan definiciones mínimas ficticias marcadas verificadas únicamente como fixture; no aprueban cartas oficiales.

La pista de entrenamiento se registra en cada jugador porque la reanudación desde snapshot no debe depender de una configuración externa desaparecida. Por ello se amplía el esquema P07 y su versión de motor, actualizando fixtures y regresiones. `training=0` representa el primer espacio de la pista; `turn.phase=inicio` impide considerar realizado el avance inicial.

## Trabajo posterior

T08.1b implementará avance de entrenamiento y sus recompensas con pista verificada; después comenzará `libre`. T08.2 implementará acciones/puertas de fase, limpieza, robo y reciclado, incluida la decisión expresa sobre agotamiento total. T08.3 separará preparación/ronda rival y reglas por modo. No abrir el turno saltándose efectos aún no modelados.

## Verificación

Godot 4.7.2: prueba de preparación con siete configuraciones, cantidades, errores y determinismo; regresión de estado y motor. Comprobar ausencia de mutaciones en entrada y estado fallido. Los tests de preparación no son pruebas manuales de interfaz ni validación del catálogo real.
