# T08.2d — Contrato previo a la entrada en limpieza

Fecha: 2026-10-30. Entrega documental R2, posterior a T08.2c. La implementación de la entrada sigue pendiente. No modifica snapshot, versión del motor ni acciones admitidas. Fuentes: [SRC-001](../../referencias/fuentes/MistbornRulebook_V1.pdf), pp.14–17 y 19–20; [SRC-002](https://www.brotherwisegames.com/mistborn-deckbuilding-game-faq), Combat, Action cards y Solo & Co-op mode. Trazabilidad: [matriz REG](../../referencias/matriz-reglas.md) y [dudas](../../referencias/dudas.md).

## Aceptación documental

- **AC-19:** identificar las obligaciones previas y posteriores a limpieza por modo, con fuente y dependencias; no afirmar que una fase técnica acredita su cumplimiento.
- **AC-20:** explicar qué comprueba hoy el motor y por qué esos datos no autorizan una transición general. No aceptar indicadores del cliente como evidencia de efectos resueltos.
- **AC-21:** definir escenarios observables para la futura implementación, incluidos pausas, finales, rechazo y reintento; distinguirlos de pruebas ejecutadas.
- **AC-22:** dejar un desglose ordenado, primer paso ejecutable y bloqueos explícitos, conservando las dudas aplazadas. Revisar fuentes, código y enlaces independientemente antes del cierre documental.

## Secuencia y límites por modo

| Segmento | Competitivo 2–4 | Cooperativo 2–4 / solitario | Fuente y dependencia |
| --- | --- | --- | --- |
| Cierre de la parte libre | No continuar con efectos, elecciones o reacciones pendientes. | Mismo requisito; no atacar a compañeros ni sus aliados. | REG-054/069, SRC-002 Action cards; resolutor P09 pendiente. |
| Combate | Asignación a aliados antes que jugadores; se puede dejar ataque sin gastar. Aplicar Defender, Cloud y restricciones. | Atacar rival/adversarios con sus reglas; escudos persistentes, sin extrapolar el daño de aliados. | REG-036–038/051/057–058; SRC-002 Combat y Solo & Co-op mode. |
| Target | Solo 3–4 iniciales; distinguir portador activo, portador atacado, eliminación y paso posterior a todo el daño. Retirarlo al quedar dos. | No existe Target. | REG-039–041, SRC-001 pp.15–17 y FAQ Combat; requiere combate y eliminación resueltos. |
| Efectos de fin de turno | Resolver los que existan antes de dar por finalizado su segmento; no interpretar texto libre. | Los adversarios frente al activo pueden actuar al final de su turno antes del robo de nueva mano. | REG-056, SRC-001 p.19. No se fija un orden relativo al descarte que la fuente no precisa. |
| Finales | Evaluar las victorias aplicables cuando ocurren, sin retrasarlas artificialmente hasta limpieza: misiones, único superviviente, Confrontation. | Misiones no dan victoria directa; salud del rival/Confrontation, eliminación del equipo y agotamiento tienen reglas propias. | REG-035/044/063–064; resolutores pendientes, DUD-006 no resuelta. |
| Limpieza y nueva mano | Una vez satisfechas las obligaciones anteriores, usar el cierre interno existente; entrega `inicio` al siguiente vivo. | Tras las obligaciones previas al robo, cierre interno y entrega `rival` al mismo activo; la carta rival se resuelve después de la nueva mano. | REG-055/056, SRC-001 pp.17/19–20; T08.2a/b/c solo cubren el subconjunto documentado. |

La fila de finales es una obligación transversal, no un paso que se ejecuta únicamente después de los efectos de fin de turno. No se decide aquí la prioridad de eventos simultáneos no respaldada por las fuentes.

La entrega a `rival` al mismo activo presupone que sigue vivo. Si un efecto de adversario elimina al activo y quedan compañeros vivos, no se llama al cierre normal: `finish_cleanup` rechaza ese actor y REG-063 prohíbe que provoque un robo rival. Esta rama queda bloqueada hasta disponer del resolutor de eliminación y sucesión al siguiente superviviente; no se infiere aquí descarte o robo de mano del eliminado. Si no quedan supervivientes, corresponde la derrota y tampoco el cierre normal.

## Autoridad y modelo pendiente

`state_validator.gd` valida forma y referencias; no certifica historial reglamentario. `turn_cleanup.gd.finish_cleanup` exige `limpieza`, actor activo vivo, partida en curso, ausencia de resolución pendiente y guardias conservadoras. `game_engine.gd` aporta transacciones, recibos y control de actor/revisión. Ninguno resuelve aún combate, Target o finales.

`resolution=null`, `turn.counters={}`, ataque cero o la fase `combate` no demuestran que se resolvieran todas las obligaciones. Ataque cero tampoco debe convertirse en requisito reglamentario: gastar todo el daño es opcional. No añadir `combate_resuelto=true` al payload ni una API pública que simplemente escriba `limpieza`.

Antes de habilitar la entrada, el resolutor de autoridad debe representar una secuencia reanudable con pasos pendientes y terminados, elecciones/reacciones y su contexto derivado de reglas verificadas. Debe poder distinguir una secuencia terminada de otra que nunca empezó, y consumir su cierre una sola vez. Esto es un requisito de diseño técnico; la forma exacta, compatibilidad/versionado e integración con `resolution` quedan para la especificación de implementación. No usar flags genéricos de cartas como sustituto.

La futura transición pertenecerá a esa secuencia transaccional. Si una obligación carece de resolutor o contenido soportado, se bloqueará sin cambiar fase, cartas, recursos, recibos ni RNG. Un final confirmado no desemboca en limpieza ordinaria. No se fija aún un código público nuevo ni se registra una acción jugable.

## Escenarios exigidos a la futura implementación

Estos escenarios son aceptación futura, **no pruebas ejecutadas** en T08.2d:

1. Rechazar actor/fase/revisión incorrectos y una secuencia no iniciada, incompleta o reutilizada; conservar snapshot y RNG.
2. Pausar para elección o reacción y reanudar tras snapshot sin repetir daño, recompensas ni efectos. P07 debe conservar recibos y privacidad.
3. Competitivo de dos sin Target; de tres/cuatro con portador activo o atacado, daño reducido a cero, elección de nuevo portador y retirada al quedar dos. Probar ataque sobrante voluntario.
4. Competitivo con victoria por misiones, eliminación o Confrontation: no limpiar ni robar como si la partida continuara. No inventar prioridades simultáneas.
5. Cooperativo/solo con adversario frente al activo: resolver sus efectos pertinentes antes del robo; no borrarlo para superar la guardia actual. Mantener escudos y efectos continuos según contenido soportado.
6. Cooperativo/solo: no crear Target ni victoria por tres misiones; resolver carta rival después de nueva mano, respetando eliminados. Casos de agotamiento/simultaneidad de DUD-006 permanecen bloqueados.
7. Fallo tardío durante limpieza/robo: rollback de la secuencia compuesta y del RNG, incluidas devoluciones de Atium. Reintento aceptado no repite efectos. Cubrir las siete configuraciones.
8. Un adversario elimina al activo cooperativo antes de la nueva mano, con compañeros vivos: bloquear el cierre normal y no robar carta rival por el eliminado; el futuro resolutor debe entregar el turno al siguiente superviviente. Con el último superviviente eliminado, resolver derrota. No afirmar una política de descarte/robo del eliminado sin respaldo específico.

## Desglose y primer paso

1. **Siguiente trabajo ejecutable:** especificar el contrato mínimo de secuencia reanudable de autoridad para P08/P09, sobre `resolution` P07: pasos, contexto, procedencia, pausas, cierre único, persistencia y compatibilidad. Usar operaciones ficticias explícitas para probar el mecanismo sin declararlas reglas del juego. Clasificar R2 y exigir revisión independiente antes de implementar.
2. Sobre ese contrato, especificar e implementar combate y ventanas con un subconjunto de contenido declarado, incluidas restricciones y eliminaciones. Añadir Target competitivo cuando sus resolutores estén disponibles.
3. Incorporar efectos de fin de turno/adversarios y finales con fuentes y contenido soportado. Mantener DUD-004/005/006 y recompensas de entrenamiento fuera de inferencias.
4. Habilitar la transición a limpieza únicamente para las secuencias totalmente cubiertas; integrar T08.2a/b/c y ejecutar los escenarios anteriores. Después abordar el paso rival T08.3 y apertura tras entrenamiento T08.1b según sus dependencias.

T08.2d puede cerrarse como contrato documental revisado. T08.2 y P08 siguen abiertas; no hay un turno completo ni partida jugable. No se necesita solicitar de nuevo material aplazado para redactar el contrato técnico del primer paso.
