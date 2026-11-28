# E3 — Lote de integración y pruebas de admisión

## Perímetro del candidato

El candidato abarca el competitivo local de 2–4 plazas. Su manifiesto debe resolver la [lista cerrada de T08.1b31](../008-preparacion-y-turnos/inventario-competitivo-final.md#lista-cerrada-que-debe-resolver-el-manifiesto) y sus dependencias transitivas, incluidas las definiciones que ninguna partida individual llega a seleccionar. El modo cooperativo, el rival y la conexión remota tienen entregas propias. La aceptación de este documento prepara las pruebas del lote; la aceptación del candidato requiere ejecutarlas.

| Componente del lote | Evidencia disponible | Pendiente para el candidato |
| --- | --- | --- |
| Personajes, entrenamientos, Financiación y pista | [Cotejo humano de E1](../008-preparacion-y-turnos/verification.md#cotejo-humano-e1-y-consulta-de-misiones--registro-previo) y ensayo de inicio. | Completar registros de admisión, fijar definiciones y verificar sus rutas con el conjunto integrado. |
| Mercado completo | [E3.2](verification.md#copia-identificada-para-e32) identifica la copia cotejada y sus correcciones. El [inventario](mercado-inventario.json) fija 65 IDs y 82 copias. | Relacionar cada ID con su definición candidata, su evidencia de ejecución y los materiales admitidos. Cubrir cada efecto alcanzable. |
| Ocho misiones | [Cotejo humano por título](../008-preparacion-y-turnos/verification.md#confirmación-humana-de-misiones-m1m8--registro-previo) y ejecución en perfil aislado. | Integrar todas las referencias con el contenido candidato y verificar sus rutas desde el perfil objetivo. |
| Recursos, pistas y marcadores restantes | El inventario consigna los componentes, su aplicación por tamaño de mesa y sus fuentes. [E2](../010-primera-partida-local/verification.md) cubre parte de su ejecución con fixtures. | Registrar la representación elegida y comprobar preparación, recorrido y cierre con el mismo lote. |

La [matriz de efectos](familias-de-efectos.md) y el [primer ensayo integrado](verification.md#primer-ensayo-integrado-verificado) aportan operaciones y regresiones reutilizables. Para cada ruta alcanzable, la ficha de ejecución del candidato recogerá el ID y la versión del resolutor, los casos positivos y adversos, y su resultado con la definición candidata. Una ruta pendiente bloquea el lote completo.

## Pruebas de admisión propuestas

Aplicar las tres evidencias independientes del [contrato de admisión](../008-preparacion-y-turnos/admision-contenido-final.md#registro-por-componente) a cada componente. Para repetir las pruebas, conservar la revisión de código, la versión del resolutor, los digests de autoría, payload y archivo, la lista de IDs y cantidades y los registros de ejecución. Conservar los originales y sus rutas privadas en el entorno de autoría.

| Caso | Entrada y resultado que se debe comprobar |
| --- | --- |
| A1. Inventario y referencias | Comparar el multiconjunto candidato con una lista esperada derivada del inventario, independiente del manifiesto candidato. Probar por separado un ID ausente, uno duplicado, una cantidad alterada, una referencia rota y un fixture. Cada variante rechaza el lote antes de preparar estado. |
| A2. Fidelidad y procedencia | Vincular cada definición a su revisión y su huella de fuente cuando proceda. Probar fuente ausente, huella distinta y duda bloqueante por separado, incluso con el estado declarado como verificado. La construcción se rechaza y conserva el artefacto válido anterior. Para el mercado, resolver la huella respecto de la copia E3.2 que se usó en el cotejo. |
| A3. Ejecución | Cruzar las rutas alcanzables del manifiesto con el registro de resolutores y las pruebas del candidato. Retirar un resolutor y dejar una ruta pendiente en variantes separadas. Ambas bloquean la admisión. Durante el recorrido, una acción inválida conserva el estado completo, revisión, RNG y recibos. |
| A4. Identidad y carga | Fijar manifiesto, digests y versión desde la autoridad. Cargar el artefacto válido en un clon limpio sin originales. Cambiar por separado bytes de archivo, payload, lista de IDs o versión y comprobar el rechazo del control correspondiente, con el catálogo previo intacto. La carga de autoría exige las fuentes por su vía propia. |
| A5. Restauración | Guardar y restaurar con la misma identidad. Rechazar una instantánea de otro perfil o versión sin una migración aprobada, conservando la partida activa. Probar reenvío de un recibo tras una restauración válida y comprobar que no duplica la acción. |
| A6. Paquete | Cruzar ruta, identidad y base de inclusión de cada material con el paquete real. Inspeccionar el contenido empaquetado y los recursos importados, con comprobación de huellas y bytes de originales. Un recurso sin evidencia o un original incluido bloquea la aprobación del paquete. |

El [cargador b29](../008-preparacion-y-turnos/catalogo-ejecucion-sin-png.md) y sus suites sirven de referencia para A2/A4/A6. Su manifiesto está fijado al ensayo b29. El candidato requiere una identidad propia y pruebas con su artefacto efectivo.

## Recorridos con el candidato

Usar el mismo artefacto admitido en A1–A4 para las tres configuraciones. Fijar semilla y registrar reparto, orden de acciones, revisiones y vistas por plaza. En cada configuración, recorrer preparación, un ciclo completo de turnos y un final verificable por la autoridad. Guardar y restaurar tras la preparación, en una resolución pendiente y al terminar, verificando A5 y las vistas privadas. Añadir pruebas dirigidas por familia para cubrir las rutas alcanzables que queden fuera de esos recorridos.

| Plazas | Comprobación específica |
| --- | --- |
| 2 | Comprobar la configuración de combate de dos plazas y el resultado al cerrar por eliminación. |
| 3 | Comprobar el relevo de Target y el orden después de una eliminación. Cerrar por la vía de misiones. |
| 4 | Comprobar orden inicial y continuidad entre cuatro plazas, incluida una ventana que atraviese un relevo. Cerrar por Confrontación y verificar el rechazo de nuevas acciones de juego tras el cierre. |

Antes de ejecutar, fijar expectativas de cada recorrido con la especificación vigente y SRC-001/002. Registrar semilla, pruebas, resultado y limitaciones por tamaño de mesa. El cierre de E3 requiere además la verificación de la interfaz competitiva local con el candidato. A6 corresponde al paquete que se pretenda compartir.
