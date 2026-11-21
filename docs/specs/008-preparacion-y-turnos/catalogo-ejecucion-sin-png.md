# T08.1b29 — Catálogo de ejecución sin PNG

## Alcance

El primer artefacto es **un ensayo aislado** para Perseguir y las ocho misiones: combina definiciones reales contrastadas con componentes ficticios ya declarados como fixtures. No admite `data/perseguir.json` al producto, no convierte sus cartas en un catálogo publicable y no sustituye la revisión humana ni la autorización de contenido final. El entorno de autoría conserva los tres PNG de SRC-005 en `evidencia_local/src_005/`; el clon de ejecución carece de esa carpeta.

## Contrato de construcción y carga

La construcción recibe un documento de autoría v4 y lo somete al validador existente, incluida presencia y SHA-256 de toda fuente física y revisión declarada. Sólo después admite el conjunto cerrado de descriptores y resolutores del perfil de ensayo. Produce un artefacto v1 determinista: versión de formato, identidad de catálogo y resolutor, fuentes por ID/tipo/huella, definiciones necesarias y digest canónico. Excluye rutas a originales, bytes PNG, imágenes, OCR auxiliar y campos de revisión destinados a autoría.

La carga es una interfaz distinta. La autoridad fija por código la versión, el digest del contenido y el SHA-256 del archivo completo del único artefacto de ensayo admitido; comprueba los bytes antes de analizar JSON para que cambios de formato o claves duplicadas tampoco se admitan. Ni el cliente ni el propio artefacto pueden escoger las huellas esperadas. La identidad del perfil y del snapshot liga contenido y resolutor. Reemplazar una definición, fuente o versión requiere nuevas huellas fijadas y, si cambia el estado, una migración explícita; nunca se interpreta un snapshot viejo bajo definiciones nuevas.

El perfil nuevo sólo sirve para restaurar y ejecutar el subconjunto cerrado ya probado de Perseguir y M1–M8. No se añade al arranque ni a la red. Los perfiles anteriores conservan la validación de autoría con fuentes presentes; el JSON v4 no adquiere un modo de carga sin fuentes. Un rechazo de construcción, carga, restauración u operación no deja una admisión parcial.

## Verificación prevista

Los criterios FUE-01–07 y los responsables están en [tasks.md](tasks.md#t081b29--catálogo-de-ejecución-sin-originales-registro-previo). La construcción se ejecuta con `build-runtime-catalog` y las suites dirigidas con `test-runtime-authoring` y `test-runtime-catalog` desde `tools/godot.ps1`. `tools/test_runtime_distribution.ps1` reproduce clon sin originales, exportación PCK y examen de rutas, nombres, huellas y bytes de `misiones.1.png`, `misiones.2.png` y `mercado.3.png`. Los resultados reales y límites están en [verification.md](verification.md#t081b29--catálogo-de-ejecución-sin-png).

La identidad del paquete de ensayo no autentica un anfitrión con ejecutable modificado. Elección de alojamiento y confianza continúan en P13–P14. La distribución final de texto, iconos y arte requiere revisión propia según [la política de originales](fuentes-sin-escaneos.md).
