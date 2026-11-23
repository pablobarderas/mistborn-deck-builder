# T08.1b30 — Procedencia y admisión del contenido final

Contrato documental para pasar del [catálogo de ejecución de ensayo](catalogo-ejecucion-sin-png.md) a un catálogo candidato de producto. La construcción de b29 demuestra separación de originales y ejecución, pero su perfil contiene fixtures. Esta tarea no modifica datos, motor ni manifiesto y no distribuye contenido.

## Registro por componente

Cada diseño y componente necesario para una configuración de partida tendrá un registro trazable con ID estable, edición/idioma, cantidad física, tipo y localizador dentro de la fuente, SHA-256 de los bytes originales cuando la fuente sea local, revisión de lectura y revisor. La revisión coteja por separado nombre, texto e iconos, números, coste, metales, cantidad, referencias y discrepancias con SRC-001/002. Una huella identifica el archivo; no demuestra que su transcripción sea correcta. Las dudas se vinculan a su decisión o quedan abiertas. Se conserva la fuente en autoría local según [DEC-044](../../decisiones.md#dec-044--fuentes-físicas-fuera-de-git-y-paquetes).

El registro distingue tres estados independientes:

| Dimensión | Condición para admitir | Si falta |
| --- | --- | --- |
| Fidelidad | Fuente identificada y cotejada por persona; definición, cantidad y referencias revisadas sin discrepancia pendiente que afecte la partida. | Sigue como muestra/borrador; un fixture jamás se promueve por pasar el validador. |
| Ejecución | Todas sus reglas, elecciones, reacciones y finales alcanzables tienen contrato y resolutor probado en el perfil objetivo; versión e identidad fijadas por autoridad. | Solo puede estar en un perfil de ensayo explícito; no se silencia un efecto. |
| Distribución | Procedencia y permiso o base concreta para incluir **cada** texto, icono, ilustración y recurso en el artefacto destinado a otras personas, con alcance y evidencia registrados. | No se incorpora ese material a Git, PCK ni instalador compartido; `ruta_imagen: null` no resuelve el texto o los iconos. |

Una conclusión técnica de fidelidad o ejecución no concede derechos de distribución. La política conservadora de b28 continúa; una autorización futura se registra por material y alcance, sin inferirla de poseer la caja, de que el repositorio sea privado o del ensayo exportado. Si se usa texto o arte original creado para el proyecto, se registra su autoría y relación con el contenido del juego antes de marcar la dimensión de distribución. Esta puerta es de gestión del proyecto, no una valoración jurídica definitiva.

## Inventario y frontera del perfil

La lista de contenido del lanzamiento se deriva del manifiesto de preparación y de todas las rutas alcanzables del modo elegido: mazos, mano inicial, mercado, personajes, misiones, entrenamiento, recompensas, rival y finales según corresponda. Para **cada** entrada se exige registro de las tres dimensiones; el manifiesto especifica IDs, cantidades y versión de catálogo. No se admite una mezcla de componentes reales con fixtures ni una entrada omitida porque su ruta se vea poco en las pruebas. Un subconjunto cerrado puede seguir existiendo como ensayo identificado, nunca como producto completo.

Estado comprobado hoy: b29 carga Perseguir y M1–M8 en un ensayo competitivo con componentes restantes ficticios. `data/perseguir.json` permanece en borrador; la prueba con copia verificada en memoria no cambia su estado. Las misiones tienen transcripción y perfiles aislados, no un catálogo completo de la caja. Falta el inventario final de cartas y piezas, la cobertura de resolutores y la evidencia de distribución de textos/arte. Ninguna configuración del producto cumple esta puerta actualmente.

## Construcción y admisión futuras

1. Crear un inventario versionado a partir de fuentes locales y descriptores, con revisión humana por componente. El constructor de autoría mantiene la presencia y huella de originales; no acepta una declaración nueva de `revision.estado` como sustituto de esa revisión.
2. Resolver la lista cerrada de cada modo contra el inventario: IDs únicos, cantidades suficientes, referencias presentes y efecto alcanzable cubierto. Fallar íntegramente ante cualquier fixture, borrador, duda bloqueante o programa sin prueba. Registrar los elementos excluidos y el motivo sin tratarlos como catálogo parcial listo para jugar.
3. Preparar un candidato de catálogo de ejecución sin originales, con identidad nueva ligada a definiciones, fuentes, resolutores y versión. La autoridad fija digest de payload y archivo en un manifiesto de lanzamiento; el cliente no elige huellas, revisión ni resultado. Los snapshots anteriores se rechazan salvo migración expresa.
4. Probar el mismo candidato en un clon limpio sin `evidencia_local/`: el cargador de ejecución prepara/restaura el perfil, mientras el JSON de autoría sigue rechazando fuentes ausentes. Antes de distribuir, aprobar el inventario de material incluido por dimensión de distribución y examinar el paquete real por rutas, nombres, huellas y bytes de originales y por texto/arte/iconos no admitidos. Una exportación limpia técnicamente no sustituye esa revisión de contenido.
5. Integrar en el producto solo después de probar preparación, acciones, restauración y finales del modo con el mismo catálogo candidato. UI, privacidad, red y confianza en el anfitrión mantienen sus puertas propias en P12–P15; un catálogo válido no las acredita.

Un cambio de fuente, transcripción, permiso, definición, resolutor, cantidad o lista cerrada reabre las revisiones afectadas y produce identidad nueva. Se conserva la evidencia del candidato anterior, sin reinterpretar snapshots. Los rechazos de construcción, carga y restauración no alteran el catálogo activo ni el estado de partida.

## Aceptación de este contrato y siguiente ejecución

| ID | Evidencia exigida |
| --- | --- |
| ADM-DOC-01 | Campos mínimos y cotejo de cada componente vinculados a SRC-001/002/005 y a la revisión humana, sin confundir huella con fidelidad. |
| ADM-DOC-02 | Estados de fidelidad, ejecución y distribución independientes; material sin evidencia de distribución queda fuera del paquete compartido. |
| ADM-DOC-03 | Lista cerrada por modo, cantidades/rutas alcanzables, prohibición de fixtures y cambio de identidad/versiones expresos. |
| ADM-DOC-04 | Plan reproducible de autoría, build, clon/exportación, restauración y producto con rechazos íntegros; pruebas futuras no declaradas ejecutadas aquí. |
| ADM-DOC-05 | Revisión independiente del contrato, enlaces/diff y traspaso; ninguna promoción de Perseguir o fase. |

Primer paso de implementación posterior: inventariar el contenido requerido para un perfil competitivo completo y registrar fuentes/estado por componente. Las lagunas de contenido y distribución deberán quedar visibles antes de construir un candidato; no se rellenan con fixtures ni con permisos supuestos.
