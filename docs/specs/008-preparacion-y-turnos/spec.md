# SPEC-008 — Preparación y turnos

- Fecha: 2026-10-29.
- Estado: T08.1a implementada y verificada localmente; P08 no se cierra hasta ejecutar los turnos y las diferencias restantes por modo.
- Fuentes: SRC-001 pp.5–6, 12, 17–20; SRC-002, «Errata 2» y «Miscellaneous» (entrenamiento en primera ronda).
- Dependencias: estado/acciones P07 localmente verificadas; P04 externa pendiente para el cierre formal de P07. Catálogo completo pendiente por DUD-002/003.

## Alcance

La preparación crea un snapshot privado para los siete modos/cantidades permitidos. El adaptador de autoridad aporta exclusivamente definiciones verificadas y un manifiesto con las copias físicas identificadas; ninguna carta de muestra se trata como oficial. El orden de las plazas recibido representa el sentido horario. Competitivo recibe primer jugador elegido; cooperativo sortea el primero con RNG de partida. Se barajan mazos, se revelan seis cartas de mercado, se seleccionan tres de ocho misiones y se reparten cinco cartas por plaza. La fase inicial queda en `inicio`: todavía debe aplicarse el avance de entrenamiento antes de abrir la parte libre.

T08.1a no aplica entrenamiento, recompensas, efectos, ataques, compras ni victoria. Tampoco conecta escenas o transporte. T08.1b y T08.2 abordarán el turno y el ciclo del mazo. T08.3 cubrirá los efectos específicos del rival y los modos donde correspondan; su resolución depende de P09.

## Aceptación de T08.1a

- **AC-01:** rechazar modo/cantidad/plazas/IDs inválidos sin producir un snapshot ni consumir estado externo.
- **AC-02:** exigir cuatro personajes, cuatro cartas iniciales por personaje, seis Funding por plaza, 82 cartas de mercado, ocho misiones y, en solo/cooperativo, 36 cartas del rival, su ficha y la pista de Dominación; todos referencian definiciones verificadas del tipo adecuado y no exceden sus cantidades físicas. El manifiesto declara la pista de entrenamiento. Rechazar ausencias, tipos y existencias incorrectos.
- **AC-03:** crear instancias únicas, zonas personales y compartidas, ocho fichas de metal por plaza, salud base 36, entrenamiento inicial, seis cartas de mercado, tres misiones distintas y mano inicial de cinco. Misma semilla y entrada producen el mismo snapshot completo.
- **AC-04:** competitivo aplica +2/+4/+4 de salud según orden; cuarto recibe un Boxing; Target solo con tres/cuatro en el último. Cooperativo/solo no reciben estas bonificaciones ni Target.
- **AC-05:** solo/cooperativo crea rival de salud 48, Dominación visible 1 y mazo de 36. Competitivo no incluye rival ni sus zonas. El primer jugador cooperativo se sortea; el competitivo usa la plaza elegida.
- **AC-06:** el snapshot pasa el validador P07, no altera definiciones ni manifiesto y guarda el estado RNG posterior a los barajados. No se declara jugable una partida por pasar esta prueba.

## Dudas y límites

DUD-002/003 impiden preparar una partida con contenido real hasta verificar el catálogo y su traducción. DUD-006 afecta el robo con mazo y descarte vacíos; T08.2 lo tratará explícitamente, sin inventar carta ni resultado. Las recompensas concretas de pistas no se conocen aún y bloquean la apertura automática de `libre` tras `inicio`. SRC-002 corrige la mención a Mission Track en la regla de Atium continuo y confirma entrenamiento en la primera ronda.
