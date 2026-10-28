# Sistema de agentes SDD

Fecha: 2026-10-29. Decisión técnica: DEC-019. Alcance y aceptación: [SPEC-009](../specs/009-sistema-agentes/spec.md). Este documento gobierna el trabajo delegado; [desarrollo](desarrollo.md) conserva el ciclo SDD y [calidad](../calidad.md) los criterios del producto.

## Obligatoriedad y dispensas

Por instrucción expresa del usuario del 2026-10-29, esta metodología es obligatoria para toda tarea que cree o cambie código, datos, recursos, pruebas, configuración o documentación del proyecto. Una consulta sin cambios no necesita una entrega SDD. El coordinador debe registrar antes de editar objetivo/AC, riesgo y justificación, plan proporcional, responsables y verificación prevista en la tarea o spec. Los especialistas verifican el contrato recibido y avisan de omisiones; no se conceden excepciones entre agentes.

La proporcionalidad forma parte del método: una tarea R0 mecánica puede tener un registro breve y ningún subagente; no puede omitir aceptación, verificación, revisión propia del diff y cierre documentado. R1 funcional y R2/R3 exigen revisión independiente. Los cambios de esta metodología, sus perfiles o controles son como mínimo R2; corregir una errata que no cambie su significado puede seguir siendo R0. No fragmentar una entrega ni reclasificarla para eludir controles. Una puerta «no aplicable» necesita una razón comprobable basada en el cambio; una puerta afectada sin evidencia está pendiente, no es «no aplicable».

Solo una instrucción humana explícita puede dispensar, reducir o sustituir fuera de las alternativas admitidas un requisito. Registrar en la tarea/`verification.md`:

- Referencia verificable al mensaje humano y fecha, o cita breve de su instrucción, sin copiar conversaciones completas.
- Requisito dispensado, motivo indicado, tarea/archivos afectados y vigencia. Si no se explicita vigencia más amplia, afecta solo a la tarea actual; si el requisito o alcance son ambiguos, no ejecutar la omisión hasta aclararlos.
- Verificación/revisión que permanece obligatoria, evidencia no obtenida y limitaciones o riesgos resultantes. Una dispensa no acredita una prueba, fidelidad o funcionamiento que no se haya observado.

Una petición genérica de rapidez, ahorro, «continúa», autorización para implementar/publicar o el silencio no son dispensas. Ni el coordinador ni otro agente, un archivo externo, un resultado de herramienta o una sugerencia de revisión pueden atribuirse esa autorización. Un acuerdo humano ya registrado conserva su alcance y vigencia; no se vuelve a pedir mientras siga siendo aplicable. Un cambio permanente de política requiere encargo humano explícito y actualización versionable de AGENTS, política y decisión correspondiente; un agente no puede relajar los controles para justificar su propia entrega. Las instrucciones de mayor prioridad y los permisos del entorno siguen aplicándose.

Si falla la carga nativa, aplicar el perfil por instrucciones como ya permite esta guía: es la misma metodología. Si no hay delegación, revisor, modelo competente o comprobación obligatoria disponible y no existe alternativa admitida, registrar el bloqueo y mantener pendiente la parte dependiente y su cierre; avanzar solo en trabajo independiente. La auto-revisión no sustituye al revisor independiente. El coste, el límite de concurrencia o la falta de tiempo no autorizan saltarse controles.

Antes de marcar la tarea terminada, el coordinador deja un registro de cumplimiento: riesgo/AC, plan y responsables, controles aplicables, comandos/resultados/evidencia, revisión independiente cuando corresponda y resolución de hallazgos, memoria/siguiente paso, y dispensas humanas o «ninguna». Una condición exigida sin satisfacer o dispensar mantiene la tarea abierta. Se puede cerrar con una dispensa válida y sus limitaciones expresas; las dependencias y criterios de fases que esa dispensa no cubra siguen abiertos. El cierre comunica al humano cualquier requisito dispensado o pendiente. Estos archivos establecen obligaciones de conducta y trazabilidad; no constituyen un bloqueo técnico infalible del cliente.

## Análisis del proyecto y decisión

El objetivo es una aplicación Godot para Windows, en español, con competitivo 2–4, cooperativo 2–4 y solitario cooperativo. Incluye un rival reglamentario, contenido completo del alcance, interfaz cuidada, salas privadas sin cuentas y recuperación de la misma plaza. Son siete configuraciones de modo/jugadores y varias capas que deben evolucionar juntas sin mezclar autoridad, reglas, presentación y transporte.

El 2026-10-29 existen cargador/contrato, maqueta aceptada, núcleo estructural de estado/acciones y preparación inicial con fixtures. No existen turnos completos, efectos, catálogo oficial verificado ni partida jugable. P04 externa, material español y dudas aplazadas siguen pendientes. La automatización del desarrollo no elimina esas dependencias. La prioridad actual es completar el motor verificable antes de integrar la presentación y red definitivas; después, validar partidas y acabado en dispositivos reales.

| Área/fases | Fallo de alto impacto | Consecuencia para la organización |
| --- | --- | --- |
| P06/P11, contenido | JSON correcto pero carta, cantidad o traducción equivocada | Apoyo mecánico para inventarios; contraste humano/asistido con fuente y revisión independiente antes de declarar verificada. |
| P07–P09, motor | Mutación en rechazo, RNG divergente, elección saltada, reacción ilegal | Sol, pruebas de invariantes y secuencias; revisión final independiente. Especialista de reglas cuando cambie comportamiento reglamentario. |
| P08–P11, modos | Completar competitivo y omitir rival, Dominación o finales cooperativos | Aceptación separada por modo; compartir motor sin homogeneizar reglas diferentes. |
| P13–P15, red | Cliente impone resultados, secretos en payloads o recuperación de plaza ajena | Sol con revisión adversaria; separar identidad, conexión y plaza. Evidencia entre procesos y redes. |
| P05/P12/P17, experiencia | Maqueta bonita sin acciones completas, saturación o animación bloqueante | Especialista visual en interfaz ejecutada y capturas; desarrollo integra acciones reales y vistas autorizadas. |
| P10/P16/P18, integración | Muchos tests unitarios pero ninguna partida completa o exportación utilizable | Coordinador exige recorridos hasta final, siete configuraciones en la entrega final y copia limpia/otro equipo. |

Decisión: **coordinador existente y especialistas bajo demanda**, con revisión independiente proporcional al riesgo. El coordinador especifica, planifica, divide, integra y cierra. Puede delegar planificación compleja, implementación o inspección; no crea un agente distinto para cada paso ni mantiene un equipo en espera. Las fases dependientes siguen secuenciales. Tras P10, P11/P12/P13 pueden aportar frentes independientes si sus contratos y dependencias están listos.

Alternativas consideradas: un solo agente siempre ahorra traspasos pero pierde contraste independiente en cambios críticos; siete agentes siempre activos duplican lecturas y coordinación; Astra para todo eleva coste sin evidencia de beneficio; Luna para todo arriesga retrabajo en reglas/privacidad; framework propio añade mantenimiento y servicios innecesarios. El sistema usa las herramientas de Codex y archivos versionados, sin API propia, claves ni dependencias del juego.

## Modelos y roles

Política inicial elegida por el proyecto, no una comparativa medida. El modelo del coordinador permanece como lo haya elegido el usuario en su sesión. No se configura un modelo global ni un modelo por defecto para todo subagente.

| Perfil | Modelo / esfuerzo | Cuándo activarlo |
| --- | --- | --- |
| [sdd_support](../../.codex/agents/sdd_support.toml) | GPT-6 Luna / medium | Inventarios, enlaces, comandos conocidos, cambios mecánicos con contrato cerrado. No decide semántica de reglas ni arquitectura. |
| [sdd_planner](../../.codex/agents/sdd_planner.toml) | GPT-6.1 Sol / high | Entrega con varios comportamientos o contrato nuevo; agrupa spec, plan y tareas. El coordinador asume este trabajo si ya tiene contexto suficiente. |
| [sdd_developer](../../.codex/agents/sdd_developer.toml) | GPT-6.1 Sol / medium | Implementación y pruebas de una tarea coherente. Elevar a high al analizar atomicidad, continuaciones, protocolo o interacciones complejas. |
| [sdd_reviewer](../../.codex/agents/sdd_reviewer.toml) | GPT-6.1 Sol / high | Revisión independiente del resultado final; obligatorio para riesgo R2 y entregas funcionales R1. No edita código. |
| [sdd_rules](../../.codex/agents/sdd_rules.toml) | GPT-6.1 Sol / high | Nueva interpretación/implementación de reglas, diferencias por modo, efectos o finales; antes del código si el contrato aún necesita contraste. No decide DUD sin fuente. |
| [sdd_visual](../../.codex/agents/sdd_visual.toml) | GPT-6.1 Terra / medium | Revisión de capturas/recorridos reales, claridad, estados y dirección P05; cambios visuales acotados si se le asignan archivos. |
| [sdd_escalation](../../.codex/agents/sdd_escalation.toml) | GPT-6 Astra / high | Problema difícil reproducible, desacuerdo técnico fundamentado o fallo persistente tras una corrección dirigida. Una pregunta delimitada, no auditoría global. |

Luna es candidato para trabajo repetitivo y acotado; Terra para inspección visual; Sol equilibra desarrollo y revisión; Astra queda como reserva. No se usa `max`/`ultra` por defecto. No se instalan versiones antiguas ni se rotan modelos buscando una respuesta favorable. Si el perfil necesita más esfuerzo, el coordinador aplica una variante explícita: en clientes donde el archivo prevalezca sobre los parámetros de lanzamiento, delega instrucciones/modelo/esfuerzo expresos mediante el mecanismo compatible, en lugar de afirmar que una sobreescritura ignorada se aplicó.

Si el modelo no está disponible: registrar el error real; Luna/Terra pueden sustituirse por Sol con el mismo contrato. Sol puede sustituirse por el modelo competente disponible de la sesión sin degradar comprobaciones. Astra es opcional: su ausencia no autoriza cerrar un riesgo sin resolver. La tabla no garantiza disponibilidad en otras cuentas/equipos ni consumo concreto de la suscripción. No modificar autenticación ni permisos para conseguir un modelo.

## Clasificación y activación

Clasificar por el riesgo mayor; el número de líneas no determina la dificultad.

| Nivel | Ejemplo | Flujo mínimo |
| --- | --- | --- |
| R0 — mecánico | Enlace, errata documental, inventario sin interpretación | Coordinador solo; apoyo únicamente para un lote que justifique el traspaso. Diff y comprobación pertinente. |
| R1 — funcional acotado | Componente UI con contrato estable, diagnóstico o herramienta local | Coordinador o desarrollador; pruebas pertinentes y un revisor independiente. Inspección visual si cambia presentación. |
| R2 — crítico | Regla/efecto, estado/RNG, esquema, privacidad, autoridad, protocolo, reconexión o controles de la metodología | Especificación y plan previos; contraste de reglas si aplica; un implementador y revisión independiente Sol high; pruebas de casos adversos pertinentes. |
| R3 — integración/entrega | Cierre de fase, partida completa o distribución | R2 más las puertas de salida y recorridos reales de esa entrega; visual/red/reglas solo según lo afectado. R3 no obliga a Astra ni a todos los perfiles. |

AGENTS exige estas delegaciones para futuras tareas del proyecto dentro del alcance autorizado; solo una dispensa humana explícita puede eximir de una revisión obligatoria. No hace falta que el usuario pida de nuevo cada subagente. Esto no autoriza commits, push, publicaciones, infraestructura de pago o mensajes a otras personas.

Concurrencia: máximo dos subagentes abiertos, además del principal, en [.codex/config.toml](../../.codex/config.toml); el límite real del cliente puede ser menor. Usar normalmente uno, con una implementación activa. Dos escritores solo con archivos distintos y contrato estable; no editar en paralelo memoria global, proyecto Godot, imports o esquemas compartidos. Pruebas que compartan caché/logs/puertos/ventana Godot se ejecutan en serie bajo un responsable. No lanzar capturas y modificar UI simultáneamente. El coordinador espera, integra y libera/finaliza el trabajo antes del siguiente lote; subagentes no crean descendientes.

Presupuesto de coordinación orientativo: tarea pequeña sin subagentes; funcional habitual un autor y un revisor (si el principal implementa, solo un subagente). Un especialista adicional cuando resuelva una pregunta concreta. Más de cuatro delegaciones por entrega requiere explicar la necesidad en la evidencia, incluyendo agentes reiniciados; no es un tope que permita omitir pruebas. Evitar repetir una revisión general si basta volver a revisar el defecto corregido y sus rutas afectadas.

## Ciclo operativo

1. **Recuperar y seleccionar.** Leer el contexto obligatorio y Git; localizar tarea, fuentes y dependencias. No volver a preguntar por Windows, modos, cuentas o material aplazado. Registrar discrepancias sin corregir archivos ajenos al alcance.
2. **Especificar y planificar.** Clasificar riesgo, fijar AC observables, fuentes/REG, capas, compatibilidad y comandos. En reglas, consultar SRC-002 además de SRC-001. Encargar al especialista solo lo que falte. No implementar una DUD que cambie el resultado.
3. **Dividir y asignar.** Paquetes comprobables por comportamiento; cada uno tiene propietario y archivos. Acordar el contrato antes de paralelizar. Cuatro documentos por entrega compleja; una issue/tarea breve puede bastar para R0/R1.
4. **Implementar y comprobar.** El autor ejecuta los checks necesarios, conserva entradas ajenas y entrega resultados. Los tests deben verificar comportamiento y errores, sin limitarse a copiar el algoritmo. El coordinador integra y resuelve conflictos.
5. **Revisar el resultado final.** Un agente diferente examina diff, AC/fuentes y pruebas. No recibe únicamente el relato del autor; obtiene las rutas y evidencia originales. Reporta defectos con impacto y reproducción. Puede ejecutar pruebas con artefactos temporales; no modifica fuentes.
6. **Corregir y revalidar.** Priorizar fallos que cambien reglas, filtren información o impidan jugar. Corregir y repetir la prueba afectada; si cambia código relevante después de revisar, revisar ese delta antes del cierre. Tras un intento dirigido fallido, cambiar diagnóstico/esfuerzo/modelo con una razón; escalar a Astra solo si persiste una cuestión técnica difícil. Falta de fuente sigue pendiente.
7. **Cerrar con evidencia.** Coordinador comprueba las puertas, marca aprobado/fallido/no ejecutado y actualiza una vez estado, plan, tarea, verificación, decisiones y registro. Un bloqueo externo no se convierte en aprobado; seleccionar siguiente tarea independiente. No publicar sin autorización.

### Contrato para cada encargo

Usar el siguiente bloque en el mensaje de delegación. Las rutas sustituyen copias extensas; el agente conserva la recuperación obligatoria de AGENTS.

```text
Tarea y perfil/modelo/esfuerzo; nivel R0–R3 y motivo:
Objetivo y pregunta concreta:
AC/REG, fuentes y archivos de entrada mínimos:
Salida esperada y evidencia:
Archivos permitidos para escritura (o solo lectura):
Fuera de alcance, decisiones y bloqueos que conservar:
Pruebas/comandos; recursos compartidos reservados:
Cumplimiento metodológico; dispensas humanas aplicables o ninguna:
No delegar ni publicar. Informar si el contrato necesita cambiar.
Resultado breve: cambios o hallazgos, rutas/líneas, pruebas/resultados,
incertidumbres y siguiente paso; sin volcar logs completos.
```

Preferir contexto nuevo y acotado (`fork_turns="none"` cuando exista) con instrucciones/rutas necesarias. Heredar todo el chat solo si aporta información imprescindible no registrada y explicar el motivo. No pedir a cada especialista que audite todo el repositorio ni que relea íntegro este análisis: después de la recuperación obligatoria, consultar solo las secciones de política pertinentes a su contrato. Las guías de rol limitan respuestas por orientación, nunca a costa de omitir un defecto o reproducción. Agrupar búsquedas independientes, filtrar salida y conservar logs/capturas en `tmp/`, excluido de Git.

## Puertas de calidad del juego

No sustituyen [calidad](../calidad.md) ni los AC de cada spec. El coordinador selecciona las afectadas y registra las no aplicables con motivo.

| Puerta | Evidencia para aceptar |
| --- | --- |
| Reglas/modos/rival | SRC/REG → AC → prueba; preparación, objetivos, reacciones, rival y finales distintos por modo. P10 completa competitivo y escenario solo/cooperativo con subconjunto identificado; P11/P16 completan alcance y siete configuraciones. |
| Catálogo | Procedencia, texto/cantidades contrastados, referencias y efectos cubiertos. El validador estructural, OCR y fixtures no certifican una carta. No promover muestras por comodidad. |
| Estado/acciones | Conservación de zonas/instancias/recursos, rechazo atómico, secuencia RNG, duplicados y continuación de elecciones; acciones inválidas y fuera de turno. |
| Red/privacidad | Autoridad única; inspección de payloads, eventos, recibos y errores por plaza; no enviar secretos para ocultarlos después en UI. Probar procesos y reintentos reales. P04 exige redes distintas; localhost no cierra P04/P07. |
| Salas/reconexión | Sin cuentas, propiedad temporal de plaza, credencial propia separada de nombre/código común; corte, recuperación de vista/elección y rechazo de apropiación/repetición. Política de pausa/reserva/anfitrión definida antes de cerrar P15. |
| Presentación | Aplicación ejecutada, capturas vistas y flujos reales incluidos compra, combate, reacción, elección, rival y final según entrega; textos largos/manos grandes, foco y resoluciones acordadas. Animaciones no bloquean ni duplican acciones. P05 no acepta el arte final ni toda la UI. |
| Distribución | Exportación/copia limpia, versiones compatibles, instrucciones que otra persona puede seguir y evidencia real en otro equipo/red; compatibilidad/hardware pendientes se resuelven antes del cierre. |

Comandos ya disponibles: `tools/godot.ps1` con `-Action test`, `test-catalog`, `test-state`, `test-engine`, `test-setup`, `test-network`, `preview`, `preview-board` y `preview-network`; usar `-GodotPath`/`GODOT_BIN` según [desarrollo local](../desarrollo-local.md). Elegir por cambios y dependencias, no ejecutar todas las suites por cada documento. Cualquier `SCRIPT ERROR` invalida la prueba aunque el proceso termine con cero. No confundir el número de aserciones con cobertura de reglas.

## Consumo y evaluación

Un modelo más barato no usa necesariamente menos tokens. Más agentes multiplican contexto y razonamiento; el coste útil incluye lecturas, herramientas, coordinación, correcciones y revisión. En API también importan precios/tokens de razonamiento/caché; las cuotas de Codex son otro sistema y no se convierten en euros sin datos. No hay ahorro porcentual acreditado ni precio fijo guardado.

En `verification.md` (o la tarea breve R0/R1) registrar: riesgo, roles/modelos/esfuerzo efectivos, motivo de delegación/escalado, número de delegaciones, checks/defectos/retrabajo, resultado y tiempo si se mide. Añadir tokens de entrada/salida/razonamiento/cache solo si el cliente los facilita por tarea; de lo contrario, **no disponible**. No inferirlos de longitud de respuesta, diferencias en cuota o tiempo transcurrido. Mantener logs extensos fuera del contexto principal.

Reevaluar después de cinco entregas comparables: aceptación al primer intento, defectos detectados antes/después del cierre, correcciones, tiempo y consumo disponible. Si Luna requiere reinterpretación frecuente, mover esa clase a Sol; si una tarea Sol resulta mecánica y estable, probar Luna con los mismos criterios. Terra se evalúa por defectos visuales observados; Astra por resolver un bloqueo específico. No bajar calidad ni eliminar revisión crítica para cumplir una estimación de consumo. Detener iteraciones cosméticas cuando aceptación y revisión ya pasan; mejorar el producto en su fase, no pulir indefinidamente el proceso.

## Carga, compatibilidad y comprobación

Los perfiles son archivos nativos de proyecto, no skills ni chats persistentes. Codex debe confiar en el proyecto para aplicar su configuración. Abrir una sesión nueva si el cliente no recarga perfiles; no cambiar automáticamente la confianza o configuración personal. Cada perfil declara su modelo/esfuerzo. Los roles de solo lectura son una instrucción de conducta: heredan el sandbox del principal y no constituyen un aislamiento de permisos independiente.

En un cliente que permita seleccionar agentes nativos, invocar el nombre del perfil. **Si la herramienta solo expone tarea, mensaje y modelo** (como en el ensayo de esta entrega), el coordinador lee el TOML, transmite `developer_instructions` y contrato en el mensaje y selecciona el mismo modelo/esfuerzo. Registrar «perfil aplicado por instrucciones», sin afirmar carga nativa automática. Las limitaciones del cliente no se eluden mediante procesos de modelo/API paralelos ocultos. Si no hay herramientas de delegación, informar y dejar pendiente la revisión independiente exigida; se puede avanzar en trabajo no dependiente.

Validación estática, con Python 3.11+ (biblioteca estándar, fuera de Godot):

```powershell
python tools/check_agents.py
python tests/agent_config_test.py
```

Usar el Python configurado en el equipo si `python` es solo el alias de Windows; no instalar paquetes para este comando. El validador comprueba el contrato de los archivos, no disponibilidad de modelos, carga nativa, fidelidad del juego ni comportamiento futuro de los agentes. Evidencia real, incluidos límites de reconocimiento local y ensayo, en [verification.md](../specs/009-sistema-agentes/verification.md).

Fuentes consultadas el 2026-10-29: [OpenAI Docs: subagentes](https://learn.chatgpt.com/docs/agent-configuration/subagents), [referencia de configuración](https://learn.chatgpt.com/docs/config-file/config-reference) y [familia GPT-6](https://developers.openai.com/api/docs/guides/latest-model). Se usan para formato y capacidades; riesgo, umbrales, roles y política económica son decisiones del proyecto. Revisar compatibilidad al actualizar Codex y modelos, sin migrarlos silenciosamente.
