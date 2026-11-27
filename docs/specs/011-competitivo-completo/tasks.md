# E3.1 — Registro trazable del mercado competitivo

2026-11-24. Recuperación: `main`, HEAD y `origin/main` en `5cb60011410d855304a0c2616487cee92a91aada`, árbol limpio tras `fetch`. E2 está publicada; E1 conserva el cotejo humano pendiente. Objetivo acotado por esa dependencia: registrar los 65 diseños y 82 copias del mercado con ID estable, localizador y huella de fuente local, sin transcribir efectos ni admitir cartas al producto.

Riesgo R2: el registro será entrada del futuro manifiesto y un recuento o vínculo erróneo puede contaminar la partida. Responsable de registro, herramienta y memoria: coordinador. Revisión independiente obligatoria, solo lectura, tras la implementación. Ninguna dispensa.

Aceptación: (1) cada fila de la auditoría SRC-005 tiene exactamente un ID y un localizador; (2) son 65 IDs y la suma de copias es 82, con 40 acciones de color, 21 aliados y 4 Atium; (3) las nueve huellas coinciden con archivos locales, sin incluir originales en Git ni el paquete; (4) el validador rechaza duplicados, falta de fuente, cantidad incorrecta y cambio de huella; (5) todo registro mantiene fidelidad, ejecución y distribución pendientes y no modifica E2.

Plan: derivar datos de la auditoría versionada y calcular huellas sobre los nueve originales locales; añadir registro y comprobación independiente del runtime; ejecutar casos positivos/negativos, comprobar diff y enlaces; solicitar revisión independiente y cerrar memoria solo si las puertas pasan. Siguiente dependencia: cotejo humano de caras y resolución de familias de efectos antes de promover definiciones.

## Cierre

E3.1 completada en alcance de **inventario no admitido**. [Datos](mercado-inventario.json) y [evidencia](verification.md). Los IDs se derivan de hoja, fila y posición, sin depender del orden del documento de auditoría. No hay issue publicada ni dispensa humana. E3 permanece abierta.

## E3.2 — Cotejo humano del mercado

2026-11-26. Recuperación con árbol limpio en `main`, HEAD y referencia recién obtenida de GitHub en `741dfc8946083e45e141ecec89d54e8930d8ee29`. E1 y M1–M8 ya tienen confirmación humana en sus respectivos alcances.

Objetivo: registrar la revisión por diseño de las 65 entradas y 82 copias de [SRC-005](../../referencias/README.md#src-005--escaneos-españoles-de-personajes-misiones-y-mercado), según el [contrato de fidelidad](../008-preparacion-y-turnos/admision-contenido-final.md#registro-por-componente).

Riesgo R2 para el cotejo completo: un error de lectura o cantidad afecta la preparación o las reglas posteriores. El coordinador prepara las fichas y registra evidencia, el propietario coteja las fuentes y un revisor independiente verifica el registro antes del cierre. La preparación mecánica de la ficha se comprueba contra el inventario. Ninguna dispensa.

1. Preparar el primer lote en orden físico, vinculado a los IDs y a la fuente del inventario.
2. Registrar por diseño edición e idioma, persona y fecha del cotejo, campos revisados, correcciones y dudas. Para las cantidades, contrastar las 65 filas del inventario con la evidencia de duplicados aportada por el propietario y recogida en la [auditoría de escaneos](../../referencias/auditoria-escaneos-2026-11-09.md#fuentes-y-método). Contrastar las referencias o discrepancias con SRC-001/002.
3. Repetir por hojas. Para cerrar, verificar cobertura 65/82, conservar separadas las puertas de ejecución y distribución, y obtener revisión independiente del registro y sus fuentes.
4. Reconciliar la procedencia de la copia local que se usó para el cotejo. Registrar la declaración del propietario, identificar las nueve hojas de esa copia por SHA-256 y contrastar sus localizadores y cobertura con el inventario. Conservar por separado las huellas históricas de E3.1. Responsable: coordinador; comprobaciones de huellas, correspondencia de filas y enlaces, y revisión independiente final.

Estado: completada en alcance documental. El propietario confirmó los nueve lotes y resolvió los cuatro casos del contraste. Se comprobaron 65 diseños y 82 copias y se identificaron las nueve huellas de los escaneos cotejados. Revisión independiente final favorable. Siguiente paso de E3: especificar las familias de efectos y sus pruebas. [Ficha de cotejo](cotejo-mercado.md) y [evidencia](verification.md#copia-identificada-para-e32).

## Matriz técnica de efectos y pruebas

Base publicada y local `c8a9c0059f2e1f4f3846d33ffaa5e160dbe4fe40`, árbol limpio al retomar. Objetivo documental: concretar las familias de operaciones reutilizables y los casos de prueba con contenido ficticio. Riesgo R2 por el alcance de las futuras operaciones sobre estado, secuencias y vistas privadas.

Aceptación: (1) cada familia tiene resultado observable y al menos un caso adverso; (2) se trazan las garantías comunes de autoridad, reanudación y privacidad al contrato existente; (3) se distinguen pruebas propuestas de cobertura existente y condiciones de cierre de E3. El coordinador redacta y verifica enlaces y coherencia. Un revisor independiente contrasta el documento con las interfaces actuales y los tres criterios antes de publicar.

Estado: completada en alcance de propuesta técnica. Los tres criterios cuentan con comprobación documental y revisión independiente favorable. Sin dispensa. [Matriz propuesta](familias-de-efectos.md) y [evidencia](verification.md#verificación-de-la-matriz-técnica-de-efectos).

## Operación de intercambio de recursos

Base publicada y local `59a1afd1fc38a1a9ca3cb16a7d22b56d6c191cfd`. Objetivo: implementar y probar la familia de recursos con una operación reutilizable que debita un saldo y acredita otro del mismo jugador. El coordinador implementa y verifica. Un revisor independiente verifica alcance y pruebas. Riesgo R2 por mutación de estado.

Contrato y aceptación: opera sobre el diccionario fiable de saldos de un candidato. Solo admite dos claves existentes distintas, cantidades positivas y saldos enteros no negativos. Si falta saldo, el destino desbordaría el límite entero o la entrada es inválida, devuelve falso con ambos saldos intactos. Si tiene éxito devuelve verdadero y modifica ambos saldos. El motor sigue controlando autoridad, revisión, recibo y RNG. Una secuencia ficticia debe comprobar éxito y reenvío, saldo insuficiente y desbordamiento, con igualdad del estado completo en rechazos. Verificar también claves y cantidades inválidas en la API y ejecutar regresiones de motor, secuencias y estado. El registro de prueba no se incorpora al producto.

Estado: completada con un programa ficticio de verificación. Criterios comprobados y revisión independiente favorable. Ninguna dispensa. [Evidencia](verification.md#intercambio-de-recursos).

## Contrato de movimiento entre zonas

Objetivo: especificar un primer traslado entre zonas personales para un programa ficticio. Recuperación en `main`, árbol limpio, HEAD y referencia recién obtenida de GitHub en `62671315066b0d413353656f10e34449992a9f08`. Riesgo R2 porque el contrato afecta a la conservación de instancias, la atomicidad y la privacidad.

- MOV-01. Definir los parámetros internos, el origen y destino autorizados, el orden y las invariantes del traslado.
- MOV-02. Delimitar la reutilización del ciclo existente y definir rechazos sin cambios parciales ni divulgación de cartas.
- MOV-03. Fijar escenarios reproducibles de integración y regresión en un registro ficticio. El alcance de esta entrega es documental.

Plan: el coordinador contrasta el validador, el ciclo y el resolutor, redacta el contrato y comprueba enlaces, criterios y coherencia con las APIs. Un revisor independiente contrasta el resultado con MOV-01–03. Tras la revisión, el coordinador actualiza la memoria y publica la entrega documental si cumple los criterios. Ninguna dispensa.

Estado: completada en alcance documental. Siguiente paso de E3: implementar el traslado con el ciclo existente y verificarlo mediante un programa ficticio. [Contrato](movimiento-entre-zonas.md) y [evidencia](verification.md#contrato-de-movimiento-entre-zonas).

## Implementación del traslado de mano a descarte

Base recuperada en rama principal limpia, con HEAD y referencia remota recién obtenida en d6c81cc3bc2e32144d6209c5366bb9829f0d6f90. Riesgo R2 por mutación de zonas, atomicidad y privacidad.

El coordinador implementa la operación de [MOV-01 y MOV-02](movimiento-entre-zonas.md) reutilizando la validación y el traslado de CardCycle. La integra mediante un programa automático exclusivo de pruebas y ejecuta los casos MOV-03 y las suites de ciclo, secuencias, motor y estado. La aceptación exige comprobar orden, identidad, propietario, rechazo sin mutación parcial, recibo único, reversión del segmento y vistas por plaza. Revisión independiente antes del cierre. Ninguna dispensa.

Entrega completada en alcance de operación interna y secuencia ficticia. [Verificación y revisión](verification.md#traslado-de-mano-a-descarte). E3 sigue abierta. Siguiente contrato propuesto: selección privada de una instancia y reanudación de su traslado.

## Contrato de selección privada y traslado

Objetivo: especificar una ventana de prueba que permite elegir una instancia de la mano propia y reanudar su traslado a descarte. Recuperación en `main` limpio, con HEAD y referencia recién obtenida de GitHub en `80c835fcc36e0d925ed77ff856a901eabd8e4ea3`. Riesgo R2 por autoridad, privacidad y restauración.

- SEL-01. Fijar destinatario, candidatos, cardinalidad y asociación reconstruible entre opciones opacas e instancias. Definir los límites y qué recibe cada plaza.
- SEL-02. Fijar la validación de la oferta al restaurar y responder, el traslado, la reversión del segmento y el reenvío.
- SEL-03. Definir casos de prueba reproducibles para los límites, la privacidad y la paridad tras restaurar. La ejecución en Godot corresponde a la implementación.

Plan: el coordinador contrasta registro, proyección, restauración y traslado, redacta el contrato y comprueba enlaces, criterios y coherencia. Un revisor independiente contrasta SEL-01–03 antes del cierre. Ninguna dispensa.

Completada en alcance documental. El siguiente paso de E3 es implementar el programa ficticio y ejecutar SEL-03 y las regresiones requeridas. [Contrato](seleccion-privada.md) y [evidencia](verification.md#selección-privada-y-reanudación-del-traslado).

## Implementación de la selección privada y el traslado

Objetivo de esta sesión. Implementar el programa ficticio del [contrato de selección privada](seleccion-privada.md) y verificar SEL-01–03 desde las entradas del motor. Recuperación en rama principal limpia, con HEAD y referencia recién obtenida de GitHub en `25466cfec921bfb9f64525ba76fd754506129dcb`.

Riesgo R2 por selección privada, autoridad, mutación de zonas y restauración. El coordinador implementa el registro y los casos dirigidos en las pruebas de secuencias, reutiliza el ciclo con la copia auxiliar definida en SEL-02 y ejecuta la importación y las suites de secuencias, ciclo, motor y estado. Aceptación conforme a toda la matriz SEL-03, incluida la comparación de vistas y snapshots y el fallo después de mover. Revisión técnica independiente antes de cerrar. Ninguna dispensa.

Completada en alcance de programa ficticio. SEL-01–03 verificados y revisión independiente favorable. El siguiente paso técnico propuesto es concretar el contrato de alternativas y efectos encadenados. [Evidencia](verification.md#selección-privada-verificada-en-el-motor).

## Contrato de alternativas y efectos encadenados

Objetivo: especificar un programa ficticio de E3 con dos ramas excluyentes y una cadena automática de dos pasos. Recuperación en `main` limpio, con HEAD y referencia recién obtenida de GitHub en `7ec0ab8d43afcb2c2c2a1f2b5a2bc3a821fdc71c`.

Riesgo R2 por autoridad, orden, restauración y reversión parcial entre segmentos. El coordinador redacta el contrato sobre el registro existente y comprueba el alcance, los enlaces y los casos de aceptación. Un especialista contrasta límites con SRC-001/002 y un revisor independiente verifica el contrato y su encaje con el motor. Ninguna dispensa.

- ALT-01. Fijar la oferta de dos opciones, su destinatario, la correspondencia con ramas locales y los límites de la composición.
- ALT-02. Fijar el orden, las fronteras de confirmación, la restauración, el rechazo y el reenvío.
- ALT-03. Definir casos reproducibles de ambas ramas, privacidad, restauración y reversión después de ejecutar el primer paso de la cadena.

Completada en alcance documental, con contraste de fuentes y revisión independiente favorables. Siguiente tarea: implementar el programa ficticio y verificar ALT-03. [Contrato](alternativas-y-encadenamiento.md) y [evidencia](verification.md#contrato-de-alternativas-y-efectos-encadenados).

## Implementación de alternativas y efectos encadenados

Objetivo. Implementar el [programa ficticio](alternativas-y-encadenamiento.md) y verificar ALT-01–03 desde las entradas del motor. Rama principal limpia y referencia publicada recién obtenida en `a34cec127f0334536a36f843fe139d5686a1858f`.

Riesgo R2 por autoridad, privacidad, restauración y reversión parcial. El coordinador implementa un registro de ensayo aislado con identidad versionada, reutiliza el intercambio de recursos y prueba ambas ramas, rechazos atómicos, restauración y reenvío. Ejecutará importación y regresiones de secuencias, motor y estado. Se requiere revisión técnica independiente del resultado y se reutiliza el contraste de reglas del contrato para este programa ficticio. Ninguna dispensa.

Completada en alcance de ensayo. ALT-01–03 verificados y revisión independiente favorable. E3 sigue abierta. Siguiente paso técnico propuesto: especificar el ensayo de efectos diferidos y reacciones. [Evidencia](verification.md#alternativas-y-efectos-encadenados-verificados).

## Contrato de efectos diferidos y reacciones

Objetivo. Especificar un ensayo ficticio con una obligación que sobrevive a un cambio de turno y una ventana fuera de turno. Recuperación en `main` limpio, con HEAD y referencia recién obtenida de GitHub en `519d8b60df206ed4d6b8feff1f86b0b329eec8ef`. R2 por persistencia, identidad del disparador, autoridad y privacidad.

- DIF-01. Definir el perfil, la obligación y las condiciones de persistencia y activación a través de un turno.
- DIF-02. Definir destinatario, visibilidad, restauración, cierre atómico y reenvío, incluso al repetir el disparador con otro ID de acción.
- DIF-03. Fijar pruebas reproducibles de éxito, rechazo, restauración y compatibilidad.

El coordinador redacta el contrato y comprueba enlaces y coherencia con motor, secuencias, estado y cambio de turno. `sdd_rules` contrasta los límites con SRC-001/002 y `sdd_reviewer` revisa de forma independiente los tres criterios. El alcance es documental. Las pruebas en Godot corresponden a la implementación posterior. Ninguna dispensa.

Completada en alcance documental, con revisión independiente favorable. Siguiente tarea: implementar el perfil ficticio y verificar DIF-03. [Contrato](efectos-diferidos-y-reacciones.md) y [evidencia](verification.md#contrato-de-efectos-diferidos-y-reacciones).

## Ensayo de efectos diferidos y reacciones

En curso desde el 2026-11-27. Base publicada y local alineadas en `5d53290e5f6a8f60d259617bbec5cd963f34dfa4`, con árbol limpio al recuperar. El objetivo es ejecutar [DIF-01–03](efectos-diferidos-y-reacciones.md) con dos plazas ficticias y restauración local. Riesgo R2 por esquema privado, fronteras de turno, autoridad y atomicidad.

- El coordinador implementa la selección del perfil aislado por registro, reutilizando la validación compartida de estado, limpieza, ciclo y avance de inicio.
- El coordinador adapta la transacción de la autoridad para admitir las dos acciones internas del ensayo, aplicar el bloqueo tras los recibos y liquidar junto al cierre. El programa y el catálogo son fixtures.
- El coordinador ejecuta DIF-03, importación y regresiones de secuencias, motor, estado, inicio, entrenamiento, ciclo y limpieza. Un `sdd_reviewer` realiza la revisión independiente final. El contraste de fuentes ya consta en el contrato y el ensayo no incorpora reglas de cartas. Sin cambios de interfaz ni transporte. Ninguna dispensa.

Completada en alcance de ensayo. DIF-01–03 verificados y revisión independiente favorable. El siguiente paso técnico propuesto es especificar el ensayo de finalización. [Evidencia](verification.md#ensayo-de-efectos-diferidos-y-reacciones-verificado).

## Contrato del ensayo de finalización

Objetivo. Especificar un programa ficticio que confirme un resultado terminal al cerrar su secuencia. Recuperación en `main` limpio, alineado con la referencia recién obtenida en `d0a09b8ac9731bbd844f00c7f7344cab887af781`. Riesgo R2 por autoridad, atomicidad, restauración e invariantes de estado.

- FIN-01. Delimitar el perfil y los datos de prueba, la entrada y el resultado que calcula la autoridad.
- FIN-02. Fijar la frontera atómica, la protección del estado, la visibilidad, el reenvío y el rechazo de acciones nuevas.
- FIN-03. Definir pruebas reproducibles de éxito, restauración, rechazo, reversión y compatibilidad.

El coordinador redacta el contrato y verifica sus enlaces y coherencia con motor, resolutor, validador y proyección. `sdd_rules` contrasta el alcance con SRC-001/002 y `sdd_reviewer` revisa el documento final frente a FIN-01–03. Las pruebas en Godot corresponden a la implementación posterior. Ninguna dispensa.

Completada en alcance documental, con contraste de fuentes y revisión independiente favorables. Sigue la implementación del perfil ficticio y la ejecución de FIN-03. [Contrato](finalizacion.md) · [Evidencia](verification.md#contrato-del-ensayo-de-finalización).
