# Capturar cartas por lotes desde Android

El usuario confirma Android el 2026-10-27. Objetivo: aportar imágenes legibles, sin copiar a mano cada carta ni tener que escribir JSON. La transcripción, estructura y detección de dudas se harán en el proyecto.

## Herramientas comprobadas

Recomendación para reunir varias cartas: Google Drive, captura de documentos. Admite páginas adicionales y guardado PDF/JPG; conserva el lote en un solo archivo. Pasos actuales en la [ayuda oficial de Drive](https://support.google.com/drive/answer/3145835?hl=es&co=GENIE.Platform%3DAndroid), consultada el 2026-10-27.

Para copiar texto puntual: Google Lens desde Google Fotos. Seleccionar la foto, abrir Lens y mantener pulsadas las palabras que se quieran copiar, según la [ayuda oficial de Google Fotos](https://support.google.com/photos/answer/7539151?hl=es&co=GENIE.Platform%3DAndroid). No hace falta hacerlo para todas las cartas: las imágenes/PDF bastan como entrada.

Estas herramientas extraen texto o preparan imágenes; no garantizan interpretar símbolos de metales, cifras, límites ni la semántica de una habilidad.

## Primer lote sugerido

Actualización 2026-11-09: el usuario ya aporta escaneos PNG locales en `C:\Users\pbard\Pictures\Digitalizaciones`, con subcarpetas `cartas_mercado` y `cartas_personajes`. La última revisión localiza 19 PNG. La [auditoría de mercado](referencias/auditoria-escaneos-2026-11-09.md) confirma los 65 diseños únicos y las 82 cartas físicas representadas. Tirón de hierro está completa y legible en mercado9.png; todos los grupos alcanzan los conteos esperados. No hace falta separar las hojas manualmente antes de comprobar cobertura.

Las cuatro hojas de entrenamiento ya están presentes; la de Vin ahora está en `cartas_personajes/vin/entrenamiento_monedas.png` y contiene cuatro entrenamientos y una carta rectangular de Financiación, no una ficha circular. También hay personajes, panel de niveles, misiones, monedas/metales y reversos. Se revisó su vista de conjunto para descartar una carta de mercado mezclada; falta verificar sus textos/contenido en detalle.

Prioridad acordada: completar y revisar el material competitivo; cobertura de mercado completa y siguiente trabajo de material: recorte y revisión detallada. Financiación tiene seis copias idénticas por personaje según confirmación del usuario: basta el escaneo existente para las 24 cartas, pendiente de incorporación al catálogo. No hacen falta escaneos de cada copia idéntica. El material exclusivo del Lord Legislador se deja para el final conforme a [DEC-027](decisiones.md#dec-027--competitivo-primero-lord-legislador-al-final). La guía Android siguiente conserva su utilidad como alternativa al escáner.

Empezar por 5–10 diseños para comprobar la legibilidad. Una carta por foto/página, completa y de frente. Buena luz difusa, sin reflejos ni dedos tapando bordes. Mantener color y detalles; evitar filtros que borren iconos o texto.

En Drive: abrir cámara/escaneo, capturar una carta, revisar el encuadre y añadir la siguiente página. Guardar el lote con un nombre como lote_001_mercado.pdf. La interfaz puede variar según versión; la guía oficial conserva los pasos actuales.

Si una pieza tiene dos caras con información distinta, capturar ambas y anotar su correspondencia. No hace falta fotografiar cada copia idéntica: indicar cantidad por diseño cuando se conozca. Si no se conoce, queda pendiente; no se supone que hay una sola.

No es obligatorio empezar ahora ni capturar toda la caja de una vez. Las fases técnicas independientes pueden continuar.

## Del lote al catálogo

1. Conservar original y nombre de lote; asignar fuente e identificar página/cara.
2. Transcribir nombre/texto/coste/metales y anotar cantidades. El OCR es ayuda, no la autoridad.
3. Incorporar como borrador, preservando cada duda y valores desconocidos como null donde el contrato lo permite.
4. Contrastar imagen, reglamento y FAQ; no completar números/iconos ilegibles por intuición.
5. Modelar efectos que se entienden con evidencia. Lo que falte permanece pendiente; no se convierte texto directamente en código.
6. Ejecutar validador, revisar discrepancias y solo entonces declarar contenido verificado. La implementación de efectos requiere después sus propias pruebas.

Los originales incorporados al proyecto se guardarán dentro de docs/referencias/ con carpeta de lote cuando haya contenido. El arte usado por la interfaz vive por separado en assets/images/; no se mezclan fuente de transcripción e ilustración provisional.

El registro de cada carta referencia fuente y localizador. Cambiar de PC no debe perder las imágenes que respaldan la transcripción. Ver [contrato v1](contrato-catalogo-v1.md). DUD-002/003 siguen abiertas hasta completar contenido/localización.
