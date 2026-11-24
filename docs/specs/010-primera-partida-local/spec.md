# E2 — Primera partida competitiva local

## Alcance y procedencia

E2 es un ensayo local cerrado de 2–4 plazas, sobre el núcleo de autoridad P07. Usa las 22 definiciones E1 promovidas **solo en memoria** para el ensayo; permanecen borradores, pendientes del cotejo humano. El mercado y el lote que completa las ocho misiones son fixtures declarados y no se atribuyen al producto físico. La selección de tres misiones debe proceder de la preparación aleatoria con semilla, no de una sustitución posterior. Las rutas de misión admitidas para la demostración completa son M5, M6 y M7, con reglas ya modeladas; si la selección aleatoria contiene otra misión, el perfil no admite esa partida y lo comunica antes de jugar. La cantidad física estructural exigida por GameSetup se conserva.

Fuentes de reglas: [SRC-001](../../referencias/README.md#src-001--reglamento-aportado-por-el-usuario), preparación, turnos, combate, misiones y fin; [SRC-002](https://www.brotherwisegames.com/mistborn-deckbuilding-game-faq), erratas, mercado, habilidades y final; [DEC-031](../../decisiones.md#dec-031--criterios-de-la-edición-española-y-reglas-competitivas). El [contraste especializado](tasks.md) se aplica al contrato. No se ejecuta texto descriptivo.

## Aceptación

- **E2-01 Preparación.** 2–4 plazas, personajes propios, mercado de seis, tres misiones y Target donde corresponde. Identidad de perfil ligada a contenido y fixture. Fallo explícito cuando la semilla produzca misiones no admitidas.
- **E2-02 Turnos.** Inicio, Financiación, 16 Entrenamientos, compra a descarte y reposición, recursos, nivel I, nivel II opcional en la compra, nivel III, Atium, quemas compatibles y combustible. Los fixtures de mercado de E2 son Acciones simples con efectos primarios declarados; su coste y efecto se ven en pantalla. La limpieza devuelve fichas, descarta/roba, avanza al siguiente jugador vivo y permite reciclaje.
- **E2-03 Final.** Avance y premios de M5/M6/M7, victoria por tres terceras cimas; combate con Target en 3–4, victoria por último superviviente. No se ofrece una acción cuyo resultado requiera una regla aún sin resolver.
- **E2-04 Autoridad.** Rechazos atómicos, conservación de RNG, privacidad de manos, restauración por checkpoint y registro reproducido. Los perfiles anteriores mantienen su contrato sin cambios.
- **E2-05 Interfaz.** Una pantalla local permite preparar y terminar al menos una partida de dos personas sin editar el estado. Controles de pasar el turno ocultan la mano del siguiente jugador hasta que tome su plaza; estado y errores entendibles, sin afirmar juego remoto.
- **E2-06 Verificación.** Pruebas de partida completa por misiones y combate con dos personas, Target con tres, reglas y casos adversos; recorrido visible real en Godot, regresiones pertinentes, dictamen independiente de reglas/código y revisión visual de capturas. Mantener límites de E1 y E2 visibles en documentación y pantalla.

## Límites

E2 no valida el contenido final, arte, mercado de 65 diseños, las ocho misiones jugables, cooperativo, solitario ni red. El catálogo E1 no se distribuye ni admite como producto mientras falte el cotejo. El supuesto de ensayo de acciones de mercado simples es explícito y queda aislado del catálogo final. Se evita el caso de agotamiento simultáneo del mazo de mercado y de eliminadas hasta fijar su regla.
