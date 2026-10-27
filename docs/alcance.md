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

## Modos incluidos en la entrega final

| Modo | Personas | Condición de cobertura |
| --- | --- | --- |
| Competitivo | 2, 3 o 4 | Reglas comunes y diferencias de combate/Target; tres vías de victoria. |
| Solitario cooperativo | 1 | Rival completo, excepciones de misiones y finales del modo. |
| Cooperativo en grupo | 2, 3 o 4 | Rival completo, ayuda entre jugadores, decisiones colectivas y juego remoto. |

Máximo cuatro humanos; el rival de solo/cooperativo se resuelve por reglas y cartas, no consume una plaza humana. No se presupone un bot que simule a otro jugador competitivo.

Fuente de reglas disponible: SRC-001, reglamento **inglés**, 1.ª edición/1.ª impresión (2024), aportado por el usuario. Su correspondencia textual con la edición española todavía requiere contraste; ver [fuentes](referencias/README.md) y DUD-003.

La propuesta es cubrir el contenido base descrito por esa fuente; no se añaden expansiones por defecto. El PDF no contiene todo el texto de las cartas y pistas: [inventario faltante](referencias/componentes.md).

## Plataforma confirmada y presentación propuesta

Plataforma inicial: aplicación para Windows. El usuario confirma que todos disponen de ese sistema. No se exige acceso mediante navegador para la primera entrega. La versión mínima de Windows, los requisitos de hardware y las resoluciones de prueba se fijarán al preparar el entorno y la maqueta.

La presentación sigue como propuesta a revisar en P05: tablero 2D, cartas ampliables, zonas diferenciadas y ambientación de bruma sin sacrificar lectura.

| Alternativa | Ventaja | Condicionante |
| --- | --- | --- |
| Windows | Entorno nativo para desarrollar y probar con Godot. | Distribuir/actualizar ejecutable y resolver conexión externa. |
| Navegador | Acceso mediante enlace. | Exportación, alojamiento y transporte web compatibles; pruebas de navegadores. |

Comparación conservada como antecedente de la recomendación, apoyada en las condiciones de [exportación web](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html) y [red](https://docs.godotengine.org/en/stable/tutorials/networking/high_level_multiplayer.html) consultadas el 2026-10-26. La plataforma inicial queda resuelta con Windows; el transporte y alojamiento siguen pendientes.

## Decisiones y preguntas

| ID | Estado | Detalle |
| --- | --- | --- |
| Q-001 | Parcialmente resuelta | SRC-001 identificado como inglés de 2024; falta contraste con edición y terminología españolas. |
| Q-002 | Resuelta para plataforma | Todos tienen Windows; primera entrega como aplicación Windows. Versión mínima, hardware y resoluciones se concretarán en P03/P05. |
| Q-003 | Resuelta | Competitivo 2–4, cooperativo 2–4 y solitario cooperativo 1; máximo cuatro humanos. |
| Q-004 | Parcial | Se incluyen los tres modos; propuesta de contenido base, faltan catálogo completo y cualquier variante que se quiera añadir. |
| Q-005 | Pendiente | Requisitos de acceso remoto, anfitrión/servicio, costes y facilidad de entrada; decisión técnica tras P04. |
| Q-006 | Pendiente | Desconexión, reentrada y guardado; no vienen resueltos por las reglas del juego físico. |

## Prototipos y entrega fiel

P10 puede usar un subconjunto de cartas y escenarios identificado. Debe demostrar también un escenario de solitario/cooperativo, sin considerarse todavía cobertura del catálogo entero. P11 completa las cartas, misiones, personajes, mazo rival y pistas del alcance. La entrega final no se considera completa entregando solo competitivo.

Las pruebas finales abarcan las siete configuraciones: competitivo 2/3/4, cooperativo 2/3/4 y solitario 1.

## Opcionales

IA para oponentes competitivos, clasificación, matchmaking público, cuentas permanentes, espectadores, móvil específico, expansiones, guardado y migración de anfitrión necesitan justificación. El motor de cartas del rival cooperativo sí pertenece al alcance obligatorio; no es esa IA opcional.

## Pendiente para cerrar P02

Alcance exacto del catálogo base y variantes, acceso y desconexión. Los detalles de compatibilidad y resoluciones se concretarán en P03/P05. Plataforma Windows, número de participantes e inclusión de solo/cooperativo ya están resueltos y no deben volver a preguntarse.
