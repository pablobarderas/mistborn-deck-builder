# SPEC-006 — Contrato y validación del catálogo

Estado: completada en el alcance de contrato inicial. P06, T06.1/2. Sin dependencia de fotografías para verificar el contrato; catálogo oficial completo pendiente de P11.

## Objetivo

Preparar incorporación por lotes de las cartas españolas con procedencia, revisión y efectos estructurados. No transcribir cartas inexistentes ni convertir los ejemplos actuales en cartas oficiales por su nombre.

## Alcance y aceptación

- AC-01: contrato versionado que distingue definición de carta e instancia futura; conserva IDs y texto/números de los dos ejemplos, identificados como muestra. Sin compatibilidad silenciosa con el array legado.
- AC-02: validar campos/tipos, enteros no negativos, enumeraciones, IDs, fuentes, vínculos y estructura de efectos. Diagnósticos con archivo, entrada/carta y campo. Error estructural rechaza toda la carga y permite recuperarla sin datos obsoletos.
- AC-03: texto impreso y efectos separados. Secuencias ordenadas, elección y condición estructuradas; operación pendiente explícita para familias que aún no se modelan. No ejecutar texto, objetos, scripts ni efectos en P06.
- AC-04: estados muestra/borrador/verificada, dudas y revisión lingüística. Las muestras/borradores/efectos pendientes nunca aparecen como definiciones verificadas para el futuro motor. Una declaración verificada exige fuente no ficticia y revisión completa, sin acreditar por sí sola fidelidad semántica.
- AC-05: ruta visual res:// normalizada a assets/images/, recurso ausente produce aviso y sustituto sin tumbar catálogo; rutas inseguras/tipos incorrectos son error. Fuentes físicas/locales deben existir. Referencias entre cartas y fuentes deben resolverse.
- AC-06: actualizar cargador y vista inicial, migrar ejemplos explícitamente, pruebas de contrato y recuperación/integración; conservar maqueta P05 independiente y regresión adecuada. Documentar flujo Android por lotes.

## Fuentes

SRC-001/002 y matriz REG: existen familias de recursos/robo/movimiento/entrenamiento/misiones, condiciones de metales, elección y rival. Este contrato inicial admite familias simples y marca como pendientes multiplicadores de Dominación, reacciones especiales y efectos no modelados. El contenido real y su equivalencia española necesitan fotos/listados contrastados; el contrato no sustituye ese trabajo.
