# Verificación de SPEC-006

Verificada el 2026-10-27, Windows y Godot 4.7.2.stable.official.ed1daf0bf. No atribuir a validación de estructura la fidelidad ni ejecución de efectos.

| Criterio | Estado |
| --- | --- |
| AC-01, versión y migración | Superado; dos muestras con IDs/texto/números conservados, sobre v1 y rechazo del legado. |
| AC-02, validación y atomicidad | Superado; tipos, límites, claves, referencias, rechazo completo/recuperación y archivo de más de 4 MiB. |
| AC-03, gramática sin ejecución | Superado en gramática inicial; familias, condiciones, elección, profundidad y operación pendiente. |
| AC-04, revisión y filtrado | Superado; cero muestras verificadas, declaraciones inconsistentes rechazadas y dependencias revisadas. |
| AC-05, referencias y recursos | Superado; rutas/fuentes, imagen ausente con aviso/sustituto e imagen existente en vista. |
| AC-06, integración/documentos | Superado; 220 + 58 + 39 comprobaciones, captura del inicio revisada y guía Android. |

## Ejecución y evidencia

- -Action test-catalog: P06_CATALOG_OK, 220 comprobaciones, código 0. Dos fallos de carga expresamente esperados (esquema incorrecto y tamaño excesivo); sin errores de script en ejecución final.
- -Action test: P03_STARTUP_OK, 58 comprobaciones, código 0. Fixtures negativos migrados al sobre v1 para seguir probando cada campo en lugar de fallar todos por raíz incorrecta.
- -Action preview y -Action preview-board: código 0; 39 comprobaciones del tablero y seis capturas reales. Inicio revisado con estados y cuatro avisos de muestra/imagen; la maqueta mantiene sus propios datos y no modifica el catálogo.
- Logs locales en tmp/godot/test-catalog.log, test.log, preview.log y preview-board.log. Captura inicial en tmp/screenshots/main-screen.png. Intermedios ignorados, reproducibles por comandos.
- Validado uso por copia profunda: modificar una definición recibida o vaciar el diccionario de presentación no muta el catálogo.

## Incidencias corregidas

Un auxiliar de test coincidía con Object._set; renombrado. Los casos con objetos donde se esperaban strings detectaron comparaciones de Variant incompatibles: ahora se corta tras diagnosticar tipos. Godot puede devolver código 0 aun con SCRIPT ERROR; el lanzador ahora rechaza esos errores además de exigir las marcas de prueba. Se repitieron los casos hasta ejecución limpia.

## Límites

No hay cartas oficiales verificadas ni interpretación semántica automática, ejecución de efectos, OCR integrado, validación de todo el contenido físico o prueba de exportación. Las declaraciones verificadas positivas de los tests son fixtures ficticios de estructura, no transcripciones de cartas.

Gramática inicial extensible; los efectos no expresables permanecen pendientes. Fuentes locales comprobadas por presencia y referencia; su contenido y equivalencia lingüística requieren revisión humana/asistida. No se han creado issues, commit ni push en esta entrega.
