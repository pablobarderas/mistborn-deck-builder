# Documentación del proyecto

T08.1b20. Implementación M2 verificada localmente: perfil aislado M2/M5/M7, snapshot 7/motor `p08-m2-defeat-1/godot-4.7.2`; **17 suites/11.712 comprobaciones**. Revisión independiente favorable sin hallazgos residuales. Sin Defender/Cloud reales, limpieza ni producto. [Resultado y límites](specs/008-preparacion-y-turnos/verification.md#t081b20--implementación-de-objetivos-y-premios-m2).

Antecedente T08.1b19 completado documentalmente y revisado favorablemente: [objetivos y premios M2](specs/008-preparacion-y-turnos/elecciones-m2.md), DEC-039 y DUD-010. [Cierre del contrato](specs/008-preparacion-y-turnos/verification.md#t081b19--contrato-de-objetivos-y-premios-m2); la implementación posterior se recoge arriba en T08.1b20.

Esta carpeta es la memoria explícita del proyecto. Permite recuperar el contexto leyendo archivos versionados; no depende de que una conversación anterior siga disponible.

## Orden de lectura

Antes de seleccionar trabajo, consultar siempre el estado publicado en GitHub con fetch y registrar su commit; contrastar con los cambios locales según [continuidad](continuar-en-otro-pc.md). Después seguir las lecturas obligatorias:

1. [AGENTS.md](../AGENTS.md): reglas de trabajo.
2. [Estado actual](estado-actual.md): qué existe y qué se ha comprobado.
3. [Plan de trabajo](plan-de-trabajo.md): 19 fases, dependencias, entregas y criterios de cierre.
4. [Decisiones](decisiones.md): acuerdos aceptados y alternativas pendientes.
5. Documento temático de la tarea: [reglas](reglas-del-juego.md), [arquitectura](arquitectura.md) o [datos de cartas](datos-de-cartas.md).

El [registro de trabajo](registro-de-trabajo.md) conserva cambios y verificaciones por sesión; no sustituye el estado actual.

## Producto, ejecución y calidad

- [Premios M1 implementados](specs/008-preparacion-y-turnos/elecciones-m1.md): T08.1b18, perfil aislado M1/M5/M7 y snapshot 6; 16 suites/10.475 comprobaciones y revisión independiente favorables. [Evidencia vigente](specs/008-preparacion-y-turnos/verification.md#t081b18--implementación-de-premios-m1).

- [Selección y premios M1](specs/008-preparacion-y-turnos/elecciones-m1.md): contrato T08.1b17 completado y revisado favorablemente, DEC-037; motor actual sin cambios. [Evidencia](specs/008-preparacion-y-turnos/verification.md#t081b17--contrato-de-selección-y-premios-m1).

- [Elecciones y eliminación M8](specs/008-preparacion-y-turnos/elecciones-m8.md): perfil aislado implementado y verificado con fixtures, sin integración de producto; [evidencia](specs/008-preparacion-y-turnos/verification.md#t081b16--implementación-de-elecciones-y-eliminación-m8).

El [cumplimiento de SDD](gestion/agentes-sdd.md#obligatoriedad-y-dispensas) es obligatorio en tareas que cambien el proyecto. Solo el humano puede dispensar expresamente requisitos; registrar alcance y vigencia. Una tarea pequeña usa el formato proporcional, sin omitir sus controles.

- [Continuar en otro PC con Codex](continuar-en-otro-pc.md): clon, motor y mensaje de reanudación.
- [Alcance](alcance.md): objetivos confirmados, Windows como plataforma inicial y preguntas pendientes.
- [Flujo SDD e issues](gestion/desarrollo.md): método, estados y uso de GitHub.
- [Agentes SDD](gestion/agentes-sdd.md): análisis de alcance, roles/modelos por riesgo, consumo, revisión independiente y puertas de calidad; SPEC-009.
- [Sesiones y traspaso](gestion/agentes-sdd.md#sesiones-y-traspaso): un objetivo verificable por chat, recuperación contrastada y cierre/traspaso breve antes de cambiar de objetivo.
- [Backlog](gestion/backlog.md): primer lote detallado y paquetes de fases posteriores.
- [Especificaciones](specs/README.md): formato y primera entrega en borrador.
- [Referencias y trazabilidad](referencias/README.md): recepción del reglamento y matriz de cobertura.
- [Reglas documentadas](referencias/matriz-reglas.md), [componentes](referencias/componentes.md) y [dudas](referencias/dudas.md): SRC-001 y las erratas/FAQ de SRC-002, consultadas el 2026-10-27; ambas en inglés.
- [Modos y cooperativo](specs/002-modos-y-cooperativo/spec.md): comportamiento y aceptación para competitivo 2–4, cooperativo 2–4 y solitario.
- [Estado y acciones de partida](specs/007-estado-y-acciones/spec.md): T07.1/2 implementadas/verificadas localmente; P07 espera prueba externa P04 y las reglas siguen pendientes.
- [Preparación y turnos](specs/008-preparacion-y-turnos/spec.md) cubre la preparación estructural y el inicio competitivo en un perfil aislado. Quedan pendientes la integración de producto, los turnos completos y el catálogo real.
- [Avance de misiones M5/M6/M7](specs/008-preparacion-y-turnos/verification.md#t081b12--resolutor-automático-de-misiones-m5m6m7): piloto automático verificado localmente con premios, primeras llegadas y victoria; reservas y componentes restantes ficticios, sin producto integrado.
- [Funding en perfil aislado](specs/008-preparacion-y-turnos/verification.md#t082h--implementación-de-funding): primera regla de carta implementada localmente en competitivo, con aplicación u omisión; pruebas y estado de revisión. No abre turno ni incorpora cartas españolas verificadas.
- [Calidad](calidad.md): evidencia necesaria de reglas, red, presentación y distribución.
- [Dirección visual y tablero](diseno-visual.md): P05 aceptada como base visual; paleta, interacciones y resoluciones de la maqueta.
- [Datos de cartas](datos-de-cartas.md) y [contrato v1](contrato-catalogo-v1.md): P06 implementada; procedencia, revisión, gramática y validación.
- [Captura desde Android](captura-de-cartas.md): reunir cartas por lotes con Drive; Lens para copiar texto puntual.

P03 ya tiene una base ejecutable: [desarrollo local](desarrollo-local.md) y [verificación de SPEC-003](specs/003-arranque-godot/verification.md). P04 añade [prueba de conexión](prueba-de-conexion.md) con lista y contador, verificada localmente; falta prueba externa. Todavía no se implementan partidas ni salas del producto. Las plantillas de `.github/` forman parte de la entrega documental inicial publicada.

## Cómo mantener el contexto

- El estado actual describe hechos comprobables; el plan describe trabajo futuro.
- Las decisiones distinguen propuestas de acuerdos aceptados y conservan el motivo de los cambios.
- Las reglas del juego deben incluir su fuente y las dudas abiertas.
- Al cambiar una interfaz, un formato o una regla, actualizar su documento en la misma tarea.
- Usar enlaces relativos para que los documentos funcionen en otro equipo.
- Fechar las revisiones importantes con `AAAA-MM-DD` y registrar solo contexto útil para continuar.
- No copiar toda la información en cada archivo. Enlazar al documento responsable de cada tema.

Las subcarpetas actuales son `gestion/` (proceso y backlog), `specs/` (entregas) y `referencias/` (fuentes y cobertura). Crear otras cuando tengan contenido y añadirlas al índice.
