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
