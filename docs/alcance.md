# Alcance y decisiones de producto

Última revisión: 2026-10-27.

## Objetivos confirmados

| ID | Objetivo | Evidencia |
| --- | --- | --- |
| PROD-001 | Jugar a distancia con amigos. | Petición inicial. |
| PROD-002 | Mantener las reglas del juego de mesa. | Consulta de viabilidad y continuación del proyecto. |
| PROD-003 | Resultado visual bonito y cuidado. | Consulta de viabilidad. |
| PROD-004 | Fases claras y contexto duradero. | Peticiones de documentación. |
| PROD-005 | Juego en español. | Respuesta del usuario de 2026-10-26. |
| PROD-006 | Máximo cuatro personas; incluir cooperativo en solitario y en grupo. | Instrucción del usuario de 2026-10-27. |
| PROD-007 | Aplicación para Windows como plataforma inicial; todos los participantes disponen de Windows. | Confirmación del usuario de 2026-10-27 tras la recomendación de plataforma. |
| PROD-008 | Salas privadas para amigos, sin crear cuentas de usuario. | Confirmación del usuario de 2026-10-27. |
| PROD-009 | Poder reconectarse a la misma partida y recuperar la plaza propia. | Confirmación del usuario de 2026-10-27. |

## Modos incluidos en la entrega final

| Modo | Personas | Condición de cobertura |
| --- | --- | --- |
| Competitivo | 2, 3 o 4 | Reglas comunes y diferencias de combate/Target; tres vías de victoria. |
| Solitario cooperativo | 1 | Rival completo, excepciones de misiones y finales del modo. |
| Cooperativo en grupo | 2, 3 o 4 | Rival completo, ayuda entre jugadores, decisiones colectivas y juego remoto. |

Máximo cuatro humanos; el rival de solo/cooperativo se resuelve por reglas y cartas, no consume una plaza humana. No se presupone un bot que simule a otro jugador competitivo.

Fuente de reglas disponible: SRC-001, reglamento **inglés**, 1.ª edición/1.ª impresión (2024), aportado por el usuario. Su correspondencia textual con la edición española todavía requiere contraste; ver [fuentes](referencias/README.md) y DUD-003.

La interpretación se complementa con SRC-002, FAQ/erratas del editor. Las correcciones expresas prevalecen sobre el PDF; los casos no respondidos continúan como dudas.

SRC-003 identifica la publicación española de Devir. El usuario aporta el crédito «Edición: David Pérez»; no confirma por sí solo tirada ni equivalencia completa de textos. DUD-003 permanece abierta para el contraste de localización, sin volver a pedir el nombre de editorial.

La propuesta es cubrir el contenido base descrito por esa fuente; no se añaden expansiones por defecto. El PDF no contiene todo el texto de las cartas y pistas: [inventario faltante](referencias/componentes.md).

## Plataforma y dirección visual inicial confirmadas

Plataforma inicial: aplicación para Windows. El usuario confirma que todos disponen de ese sistema. No se exige acceso mediante navegador para la primera entrega. La versión mínima de Windows, los requisitos de hardware y las resoluciones de prueba se fijarán al preparar el entorno y la maqueta.

La maqueta 2D de P05 está aceptada como dirección visual inicial: cartas ampliables, zonas diferenciadas y una presentación legible. El acabado final, arte, animaciones y ambientación de bruma se concretan en P12/P17; la aceptación de la maqueta no acredita esos elementos ni una interfaz jugable completa. Véase [dirección visual](diseno-visual.md) y DEC-015.

| Alternativa | Ventaja | Condicionante |
| --- | --- | --- |
| Windows | Entorno nativo para desarrollar y probar con Godot. | Distribuir/actualizar ejecutable y resolver conexión externa. |
| Navegador | Acceso mediante enlace. | Exportación, alojamiento y transporte web compatibles; pruebas de navegadores. |

Comparación conservada como antecedente de la recomendación, apoyada en las condiciones de [exportación web](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html) y [red](https://docs.godotengine.org/en/stable/tutorials/networking/high_level_multiplayer.html) consultadas el 2026-10-26. La plataforma inicial queda resuelta con Windows; el transporte y alojamiento siguen pendientes.

## Acceso y reconexión confirmados

La primera entrega tendrá salas privadas sin registro ni cuentas permanentes. Se compartirá una invitación o código; su formato y el modo de conexión se diseñarán en P04/P13. No habrá un listado público necesario para encontrar las partidas del grupo.

La reconexión es obligatoria: al recuperar conexión con la autoridad de una partida todavía activa, el jugador debe volver a su plaza y recibir el estado que le corresponde, incluidas sus cartas y elecciones pendientes. Una reconexión no debe repetir una acción ya aplicada ni crear un jugador nuevo.

La identidad temporal de sesión debe permitir recuperar la plaza sin cuentas; el nombre visible y el código de sala no bastan por sí solos para demostrar que se es su propietario. El mecanismo concreto se diseñará en P13/P15.

Quedan por concretar pausa durante el corte, tiempo de reserva de plaza y comportamiento si cae la autoridad/anfitrión. El usuario no ha confirmado una política concreta para esos casos. Guardar partidas entre días y migrar anfitrión siguen como ampliaciones por decidir.

## Estado de las preguntas

| ID | Estado | Detalle |
| --- | --- | --- |
| Q-001 | Parcialmente resuelta | SRC-001 identificado como inglés de 2024; falta contraste con edición y terminología españolas. |
| Q-002 | Resuelta para plataforma | Todos tienen Windows; primera entrega como aplicación Windows. Versión mínima, hardware y resoluciones se concretarán en P03/P05. |
| Q-003 | Resuelta | Competitivo 2–4, cooperativo 2–4 y solitario cooperativo 1; máximo cuatro humanos. |
| Q-004 | Parcial | Se incluyen los tres modos; propuesta de contenido base, faltan catálogo completo y cualquier variante que se quiera añadir. |
| Q-005 | Acceso funcional resuelto | Salas privadas sin cuentas. Transporte, anfitrión/servicio, costes y formato de invitación se decidirán en P04/P13. |
| Q-006 | Reconexión confirmada; detalles pendientes | Recuperar partida/plaza es obligatorio. Pausa, tiempo de reserva, caída del anfitrión y guardado persistente se concretarán al diseñar P15. |

## Prototipos y entrega fiel

P10 puede usar un subconjunto de cartas y escenarios identificado. Debe demostrar también un escenario de solitario/cooperativo, sin considerarse todavía cobertura del catálogo entero. P11 completa las cartas, misiones, personajes, mazo rival y pistas del alcance. La entrega final no se considera completa entregando solo competitivo.

Las pruebas finales abarcan las siete configuraciones: competitivo 2/3/4, cooperativo 2/3/4 y solitario 1.

## Opcionales

IA para oponentes competitivos, clasificación, matchmaking público, cuentas permanentes, espectadores, móvil específico, expansiones, guardado y migración de anfitrión necesitan justificación. El motor de cartas del rival cooperativo sí pertenece al alcance obligatorio; no es esa IA opcional.

## Pendiente para cerrar P02

El núcleo funcional está acordado: Windows, modos/jugadores, salas privadas sin cuentas y reconexión. La ficha completa conserva pendientes de catálogo, presentación y política detallada de interrupciones. Los detalles de compatibilidad/resolución se concretarán en P03/P05 y la red en P04/P13/P15; no bloquean preparar el proyecto ejecutable de P03. No repetir preguntas ya resueltas.
