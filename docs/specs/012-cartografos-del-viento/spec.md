# Cartógrafos del Viento

Prototipo original competitivo presencial en un PC, con 2–4 plazas y seis rondas completas. Los participantes trazan rutas aéreas y amplían su mazo de instrumentos. Reglas, nombres y datos se definen para este prototipo. Español, teclado y ratón. Alcance local.

## Reglas

- Cada plaza recibe un mazo de ocho cartas con cuatro **Encargos** (+2 créditos) y cuatro **Observatorios** (+2 brújulas). La autoridad usa una semilla para barajar cada mazo y sortear la primera plaza. Se conserva ese orden circular durante las seis rondas.
- Al comenzar el turno la plaza roba cuatro cartas. Puede jugar hasta dos, de una en una. Los créditos y brújulas se conservan solo en ese turno. Puede intercalar juego, compra y trazado dentro de sus límites, y terminar en cualquier momento. Las cartas jugadas y las restantes de la mano se descartan al relevar. Si hace falta robar y se vacía el mazo, se baraja su descarte para continuar el robo.
- Puede comprar una carta por turno con créditos. La oferta tiene seis copias de cada instrumento para toda la mesa. Paga restando el coste de sus créditos. La compra entra al descarte de la plaza. **Planeador** cuesta 2 y da 3 brújulas, **Baliza** cuesta 3 y da 4 brújulas, **Taller** cuesta 2 y da 3 créditos, **Sextante** cuesta 3 y da 2 créditos y 2 brújulas.
- Puede trazar una etapa por turno con brújulas. Paga restando el coste de sus brújulas. Cada plaza progresa por su cuenta. Una ruta completada rechaza nuevas etapas. Los costes y puntos de cada ruta se aplican en orden, desde la primera etapa hasta la tercera.

| Ruta | Costes | Puntos de cada etapa |
| --- | --- | --- |
| Arrecifes | 2, 3, 4 | 1, 2, 3 |
| Cordillera | 3, 4, 5 | 2, 3, 4 |
| Corriente Polar | 4, 5, 6 | 3, 4, 5 |

Al terminar todas las plazas la sexta ronda, cada plaza suma los puntos de sus etapas más tres puntos si ha avanzado en las tres rutas. Ganan todas las plazas empatadas con la puntuación máxima.

## Aceptación

- CV-01. Arrancar desde el menú con 2, 3 o 4 plazas, mostrar relevo antes de revelar la mano activa y jugar con carta, compra, trazado y fin de turno. Mostrar costes, recursos, etapas, ronda y plaza. Reiniciar desde el resultado y volver al menú.
- CV-02. Completar seis rondas para cada tamaño de mesa con el mismo motor que usa la pantalla. Verificar reposición de mano, compra y descarte, límites de juego y oferta, puntuación, empate y conservación de cartas. Entradas inválidas, plaza equivocada y acciones tras el final se rechazan sin cambios.
- CV-03. La interfaz preserva la privacidad de la mano durante el relevo normal y se verifica con render real a 1280×800 y 1024×640. El catálogo se valida al cargar y utiliza identificadores estables. Verificar regresiones de arranque y motor.
