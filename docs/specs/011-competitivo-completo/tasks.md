# E3.1 — Registro trazable del mercado competitivo

2026-11-24. Recuperación: `main`, HEAD y `origin/main` en `5cb60011410d855304a0c2616487cee92a91aada`, árbol limpio tras `fetch`. E2 está publicada; E1 conserva el cotejo humano pendiente. Objetivo acotado por esa dependencia: registrar los 65 diseños y 82 copias del mercado con ID estable, localizador y huella de fuente local, sin transcribir efectos ni admitir cartas al producto.

Riesgo R2: el registro será entrada del futuro manifiesto y un recuento o vínculo erróneo puede contaminar la partida. Responsable de registro, herramienta y memoria: coordinador. Revisión independiente obligatoria, solo lectura, tras la implementación. Ninguna dispensa.

Aceptación: (1) cada fila de la auditoría SRC-005 tiene exactamente un ID y un localizador; (2) son 65 IDs y la suma de copias es 82, con 40 acciones de color, 21 aliados y 4 Atium; (3) las nueve huellas coinciden con archivos locales, sin incluir originales en Git ni el paquete; (4) el validador rechaza duplicados, falta de fuente, cantidad incorrecta y cambio de huella; (5) todo registro mantiene fidelidad, ejecución y distribución pendientes y no modifica E2.

Plan: derivar datos de la auditoría versionada y calcular huellas sobre los nueve originales locales; añadir registro y comprobación independiente del runtime; ejecutar casos positivos/negativos, comprobar diff y enlaces; solicitar revisión independiente y cerrar memoria solo si las puertas pasan. Siguiente dependencia: cotejo humano de caras y resolución de familias de efectos antes de promover definiciones.

## Cierre

E3.1 completada en alcance de **inventario no admitido**. [Datos](mercado-inventario.json) y [evidencia](verification.md). Los IDs se derivan de hoja, fila y posición, sin depender del orden del documento de auditoría. No hay issue publicada ni dispensa humana. E3 permanece abierta.
